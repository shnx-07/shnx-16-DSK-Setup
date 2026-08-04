from __future__ import annotations

import asyncio
import json
import logging
import os
import tempfile
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path
from typing import Any


class WeatherError(RuntimeError):
    pass


class WeatherService:
    GEOCODING_ENDPOINT = (
        "https://geocoding-api.open-meteo.com/v1/search"
    )

    FORECAST_ENDPOINT = (
        "https://api.open-meteo.com/v1/forecast"
    )

    CACHE_VERSION = 1
    CACHE_MAX_AGE_SECONDS = 30 * 60
    REQUEST_TIMEOUT_SECONDS = 12

    def __init__(self) -> None:
        self._logger = logging.getLogger(__name__)

        state_home = Path(
            os.environ.get(
                "XDG_STATE_HOME",
                Path.home() / ".local" / "state",
            )
        )

        self._cache_path = (
            state_home
            / "shnx-shell"
            / "weather.json"
        )

    async def get_weather(
        self,
        *,
        location: str,
        force_refresh: bool = False,
    ) -> dict[str, Any]:
        normalized_location = location.strip()

        if not normalized_location:
            raise WeatherError(
                "A weather location is required."
            )

        cached = self._read_cache()

        if (
            not force_refresh
            and cached is not None
            and self._cache_matches_location(
                cached,
                normalized_location,
            )
            and self._cache_is_fresh(cached)
        ):
            return self._cache_payload(
                cached,
                stale=False,
            )

        try:
            fresh = await asyncio.to_thread(
                self._fetch_weather_sync,
                normalized_location,
            )
        except Exception as error:
            self._logger.warning(
                "Fresh weather request failed: %s",
                error,
            )

            if (
                cached is not None
                and self._cache_matches_location(
                    cached,
                    normalized_location,
                )
            ):
                return self._cache_payload(
                    cached,
                    stale=True,
                )

            if isinstance(error, WeatherError):
                raise

            raise WeatherError(
                "Weather data is currently unavailable."
            ) from error

        cache_document = {
            "cache_version": self.CACHE_VERSION,
            "saved_at": int(time.time()),
            "query": normalized_location,
            "weather": fresh,
        }

        self._write_cache(cache_document)

        result = dict(fresh)
        result["cached"] = False
        result["stale"] = False

        return result

    def _fetch_weather_sync(
        self,
        location: str,
    ) -> dict[str, Any]:
        resolved_location = self._geocode(location)

        forecast = self._fetch_forecast(
            latitude=resolved_location["latitude"],
            longitude=resolved_location["longitude"],
            timezone=resolved_location.get("timezone", "auto"),
        )

        return self._normalize_weather(
            query=location,
            location=resolved_location,
            forecast=forecast,
        )

    def _geocode(
        self,
        location: str,
    ) -> dict[str, Any]:
        query = urllib.parse.urlencode(
            {
                "name": location,
                "count": 1,
                "language": "en",
                "format": "json",
            }
        )

        response = self._request_json(
            f"{self.GEOCODING_ENDPOINT}?{query}"
        )

        results = response.get("results")

        if not isinstance(results, list) or not results:
            raise WeatherError(
                f"No weather location matched {location!r}."
            )

        result = results[0]

        latitude = result.get("latitude")
        longitude = result.get("longitude")

        if not isinstance(latitude, (int, float)):
            raise WeatherError(
                "The weather provider returned no latitude."
            )

        if not isinstance(longitude, (int, float)):
            raise WeatherError(
                "The weather provider returned no longitude."
            )

        return {
            "name": str(
                result.get("name") or location
            ),
            "admin1": str(
                result.get("admin1") or ""
            ),
            "country": str(
                result.get("country") or ""
            ),
            "country_code": str(
                result.get("country_code") or ""
            ),
            "latitude": float(latitude),
            "longitude": float(longitude),
            "timezone": str(
                result.get("timezone") or "auto"
            ),
        }

    def _fetch_forecast(
        self,
        *,
        latitude: float,
        longitude: float,
        timezone: str,
    ) -> dict[str, Any]:
        query = urllib.parse.urlencode(
            {
                "latitude": latitude,
                "longitude": longitude,
                "timezone": (
                    timezone
                    if timezone and timezone != "auto"
                    else "auto"
                ),
                "forecast_days": 1,
                "current": ",".join(
                    [
                        "temperature_2m",
                        "apparent_temperature",
                        "relative_humidity_2m",
                        "weather_code",
                        "is_day",
                        "precipitation",
                        "wind_speed_10m",
                    ]
                ),
                "daily": ",".join(
                    [
                        "temperature_2m_max",
                        "temperature_2m_min",
                        "precipitation_probability_max",
                        "weather_code",
                    ]
                ),
            }
        )

        return self._request_json(
            f"{self.FORECAST_ENDPOINT}?{query}"
        )

    def _normalize_weather(
        self,
        *,
        query: str,
        location: dict[str, Any],
        forecast: dict[str, Any],
    ) -> dict[str, Any]:
        current = forecast.get("current")
        daily = forecast.get("daily")

        if not isinstance(current, dict):
            raise WeatherError(
                "The weather provider returned no current data."
            )

        if not isinstance(daily, dict):
            raise WeatherError(
                "The weather provider returned no daily data."
            )

        weather_code = self._integer(
            current.get("weather_code"),
            default=-1,
        )

        daily_code = self._first_integer(
            daily.get("weather_code"),
            default=weather_code,
        )

        effective_code = (
            weather_code
            if weather_code >= 0
            else daily_code
        )

        return {
            "provider": "Open-Meteo",
            "query": query,
            "location": self._display_location(location),
            "location_name": location["name"],
            "region": location["admin1"],
            "country": location["country"],
            "country_code": location["country_code"],
            "latitude": location["latitude"],
            "longitude": location["longitude"],
            "timezone": str(
                forecast.get("timezone")
                or location.get("timezone")
                or ""
            ),
            "condition": self._condition_name(
                effective_code
            ),
            "condition_icon": self._condition_icon(
                effective_code,
                self._integer(
                    current.get("is_day"),
                    default=1,
                )
                == 1,
            ),
            "weather_code": effective_code,
            "temperature": self._number(
                current.get("temperature_2m")
            ),
            "apparent_temperature": self._number(
                current.get("apparent_temperature")
            ),
            "high": self._first_number(
                daily.get("temperature_2m_max")
            ),
            "low": self._first_number(
                daily.get("temperature_2m_min")
            ),
            "precipitation_probability": (
                self._first_integer(
                    daily.get(
                        "precipitation_probability_max"
                    ),
                    default=0,
                )
            ),
            "precipitation": self._number(
                current.get("precipitation")
            ),
            "humidity": self._integer(
                current.get(
                    "relative_humidity_2m"
                ),
                default=0,
            ),
            "wind_speed": self._number(
                current.get("wind_speed_10m")
            ),
            "is_day": self._integer(
                current.get("is_day"),
                default=1,
            )
            == 1,
            "observed_at": str(
                current.get("time") or ""
            ),
            "updated_at": int(time.time()),
        }

    def _request_json(
        self,
        url: str,
    ) -> dict[str, Any]:
        request = urllib.request.Request(
            url,
            headers={
                "Accept": "application/json",
                "User-Agent": "SHNX-SHELL/0.1",
            },
        )

        try:
            with urllib.request.urlopen(
                request,
                timeout=self.REQUEST_TIMEOUT_SECONDS,
            ) as response:
                body = response.read()
        except urllib.error.HTTPError as error:
            raise WeatherError(
                f"Weather provider HTTP error {error.code}."
            ) from error
        except urllib.error.URLError as error:
            raise WeatherError(
                "Could not reach the weather provider."
            ) from error
        except TimeoutError as error:
            raise WeatherError(
                "The weather request timed out."
            ) from error

        try:
            decoded = json.loads(
                body.decode("utf-8")
            )
        except (
            UnicodeDecodeError,
            json.JSONDecodeError,
        ) as error:
            raise WeatherError(
                "The weather provider returned invalid JSON."
            ) from error

        if not isinstance(decoded, dict):
            raise WeatherError(
                "The weather provider returned an invalid response."
            )

        if decoded.get("error") is True:
            raise WeatherError(
                str(
                    decoded.get("reason")
                    or "Weather provider error."
                )
            )

        return decoded

    def _read_cache(
        self,
    ) -> dict[str, Any] | None:
        try:
            with self._cache_path.open(
                "r",
                encoding="utf-8",
            ) as cache_file:
                cached = json.load(cache_file)
        except FileNotFoundError:
            return None
        except (
            OSError,
            json.JSONDecodeError,
        ) as error:
            self._logger.warning(
                "Could not read weather cache: %s",
                error,
            )
            return None

        if not isinstance(cached, dict):
            return None

        if (
            cached.get("cache_version")
            != self.CACHE_VERSION
        ):
            return None

        if not isinstance(
            cached.get("weather"),
            dict,
        ):
            return None

        return cached

    def _write_cache(
        self,
        cache_document: dict[str, Any],
    ) -> None:
        self._cache_path.parent.mkdir(
            parents=True,
            exist_ok=True,
        )

        temporary_path: Path | None = None

        try:
            with tempfile.NamedTemporaryFile(
                mode="w",
                encoding="utf-8",
                dir=self._cache_path.parent,
                prefix="weather-",
                suffix=".tmp",
                delete=False,
            ) as temporary_file:
                json.dump(
                    cache_document,
                    temporary_file,
                    ensure_ascii=False,
                    separators=(",", ":"),
                )
                temporary_file.flush()
                os.fsync(temporary_file.fileno())

                temporary_path = Path(
                    temporary_file.name
                )

            temporary_path.replace(
                self._cache_path
            )
        except OSError as error:
            self._logger.warning(
                "Could not write weather cache: %s",
                error,
            )

            if temporary_path is not None:
                try:
                    temporary_path.unlink(
                        missing_ok=True
                    )
                except OSError:
                    pass

    def _cache_payload(
        self,
        cached: dict[str, Any],
        *,
        stale: bool,
    ) -> dict[str, Any]:
        result = dict(cached["weather"])
        result["cached"] = True
        result["stale"] = stale
        result["cache_saved_at"] = self._integer(
            cached.get("saved_at"),
            default=0,
        )

        return result

    def _cache_matches_location(
        self,
        cached: dict[str, Any],
        location: str,
    ) -> bool:
        query = cached.get("query")

        return (
            isinstance(query, str)
            and query.casefold()
            == location.casefold()
        )

    def _cache_is_fresh(
        self,
        cached: dict[str, Any],
    ) -> bool:
        saved_at = self._integer(
            cached.get("saved_at"),
            default=0,
        )

        if saved_at <= 0:
            return False

        return (
            int(time.time()) - saved_at
            <= self.CACHE_MAX_AGE_SECONDS
        )

    @staticmethod
    def _display_location(
        location: dict[str, Any],
    ) -> str:
        pieces: list[str] = []

        for value in (
            location.get("name"),
            location.get("admin1"),
            location.get("country"),
        ):
            text = str(value or "").strip()

            if text and text not in pieces:
                pieces.append(text)

        return ", ".join(pieces)

    @staticmethod
    def _number(
        value: Any,
        *,
        default: float = 0.0,
    ) -> float:
        if isinstance(value, bool):
            return default

        if isinstance(value, (int, float)):
            return float(value)

        return default

    @classmethod
    def _first_number(
        cls,
        value: Any,
        *,
        default: float = 0.0,
    ) -> float:
        if (
            isinstance(value, list)
            and value
        ):
            return cls._number(
                value[0],
                default=default,
            )

        return default

    @staticmethod
    def _integer(
        value: Any,
        *,
        default: int = 0,
    ) -> int:
        if isinstance(value, bool):
            return default

        if isinstance(value, (int, float)):
            return int(value)

        return default

    @classmethod
    def _first_integer(
        cls,
        value: Any,
        *,
        default: int = 0,
    ) -> int:
        if (
            isinstance(value, list)
            and value
        ):
            return cls._integer(
                value[0],
                default=default,
            )

        return default

    @staticmethod
    def _condition_name(
        code: int,
    ) -> str:
        conditions = {
            0: "Clear sky",
            1: "Mainly clear",
            2: "Partly cloudy",
            3: "Overcast",
            45: "Fog",
            48: "Rime fog",
            51: "Light drizzle",
            53: "Drizzle",
            55: "Heavy drizzle",
            56: "Freezing drizzle",
            57: "Heavy freezing drizzle",
            61: "Light rain",
            63: "Rain",
            65: "Heavy rain",
            66: "Freezing rain",
            67: "Heavy freezing rain",
            71: "Light snow",
            73: "Snow",
            75: "Heavy snow",
            77: "Snow grains",
            80: "Light showers",
            81: "Showers",
            82: "Heavy showers",
            85: "Light snow showers",
            86: "Heavy snow showers",
            95: "Thunderstorm",
            96: "Thunderstorm with hail",
            99: "Severe thunderstorm with hail",
        }

        return conditions.get(
            code,
            "Unknown conditions",
        )

    @staticmethod
    def _condition_icon(
        code: int,
        is_day: bool,
    ) -> str:
        if code == 0:
            return "󰖙" if is_day else "󰖔"

        if code in (1, 2):
            return "󰖕" if is_day else "󰼱"

        if code == 3:
            return "󰖐"

        if code in (45, 48):
            return "󰖑"

        if code in (
            51,
            53,
            55,
            56,
            57,
        ):
            return "󰖗"

        if code in (
            61,
            63,
            65,
            66,
            67,
            80,
            81,
            82,
        ):
            return "󰖖"

        if code in (
            71,
            73,
            75,
            77,
            85,
            86,
        ):
            return "󰖘"

        if code in (95, 96, 99):
            return "󰖓"

        return "󰖐"
