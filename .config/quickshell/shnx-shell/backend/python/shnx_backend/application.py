from __future__ import annotations

import asyncio
import logging
import os
from pathlib import Path

from .ipc.messages import (
    IncomingMessage,
    PROTOCOL_VERSION,
    error_message,
    response_message,
)
from .ipc.server import IpcServer
from .services.weather import (
    WeatherError,
    WeatherService,
)


class BackendApplication:
    def __init__(self) -> None:
        self._logger = logging.getLogger(__name__)

        runtime_directory = Path(
            os.environ.get(
                "XDG_RUNTIME_DIR",
                f"/tmp/shnx-shell-{os.getuid()}",
            )
        )

        self._socket_path = (
            runtime_directory
            / "shnx-shell"
            / "backend.sock"
        )

        self._weather = WeatherService()

        self._server = IpcServer(
            socket_path=self._socket_path,
            message_handler=self._handle_message,
        )

    async def run(self) -> None:
        await self._server.start()

        self._logger.info(
            "Backend started with protocol version %s",
            PROTOCOL_VERSION,
        )

        try:
            await self._server.serve_forever()
        except asyncio.CancelledError:
            raise
        finally:
            await self._server.stop()
            self._logger.info("Backend stopped")

    async def _handle_message(
        self,
        message: IncomingMessage,
    ) -> dict:
        if message.message_type != "command":
            return error_message(
                request_id=message.request_id,
                code="unsupported_message_type",
                message=(
                    "The backend accepts command messages only."
                ),
            )

        if message.command == "hello":
            return response_message(
                request_id=message.request_id,
                command="hello",
                payload={
                    "backend": "shnx-backend",
                    "backend_version": "0.1.0",
                    "protocol_version": PROTOCOL_VERSION,
                },
            )

        if message.command == "ping":
            return response_message(
                request_id=message.request_id,
                command="ping",
                payload={
                    "reply": "pong",
                },
            )

        if message.command == "weather.get":
            return await self._handle_weather_get(
                message
            )

        return error_message(
            request_id=message.request_id,
            code="unknown_command",
            message=(
                f"Unknown command: {message.command!r}"
            ),
        )

    async def _handle_weather_get(
        self,
        message: IncomingMessage,
    ) -> dict:
        location = message.payload.get(
            "location",
            "",
        )

        force_refresh = message.payload.get(
            "force_refresh",
            False,
        )

        if not isinstance(location, str):
            return error_message(
                request_id=message.request_id,
                code="invalid_weather_location",
                message=(
                    "weather.get location must be a string."
                ),
            )

        if not isinstance(force_refresh, bool):
            return error_message(
                request_id=message.request_id,
                code="invalid_force_refresh",
                message=(
                    "force_refresh must be a boolean."
                ),
            )

        try:
            weather = await self._weather.get_weather(
                location=location,
                force_refresh=force_refresh,
            )
        except WeatherError as error:
            return error_message(
                request_id=message.request_id,
                code="weather_unavailable",
                message=str(error),
            )

        return response_message(
            request_id=message.request_id,
            command="weather.get",
            payload=weather,
        )
