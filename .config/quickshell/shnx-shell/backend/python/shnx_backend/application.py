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

from .services.thumbnails import (
    ThumbnailError,
    ThumbnailService,
)

from .services.wallpaper import (
    WallpaperError,
    WallpaperService,
)

from .services.weather import (
    WeatherError,
    WeatherService,
)

from .services.palette_source import (
    PaletteSourceError,
    PaletteSourceService,
)
from .services.search import (
    SearchError,
    SearchService,
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
        self._wallpaper = WallpaperService()
        self._thumbnails = ThumbnailService()
        self._palette_source = PaletteSourceService()
        self._search = SearchService()

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

            self._logger.info(
                "Backend stopped"
            )

    # ------------------------------------------------------------------
    # Command router
    # ------------------------------------------------------------------

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

        if message.command == "wallpaper.scan":
            return await self._handle_wallpaper_scan(
                message
            )

        if message.command == "wallpaper.refresh":
            return await self._handle_wallpaper_refresh(
                message
            )

        if message.command == "wallpaper.apply":
            return await self._handle_wallpaper_apply(
                message
            )

        if message.command == "wallpaper.preview":
            return await self._handle_wallpaper_preview(
                message
            )

        if message.command == "wallpaper.previews":
            return await self._handle_wallpaper_previews(
                message
            )
        if message.command == "search.files":
            return await self._handle_search_files(
                message
            )
        if message.command == "search.open":
            return await self._handle_search_open(
                message
            )
        if message.command == "search.command":
            return await self._handle_search_command(
                message
            )
        if message.command == "theme.generate":
            return await self._handle_theme_generate(
                message
            )

        return error_message(
            request_id=message.request_id,
            code="unknown_command",
            message=(
                f"Unknown command: {message.command!r}"
            ),
        )

    # ------------------------------------------------------------------
    # Weather
    # ------------------------------------------------------------------

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
    
    # ------------------------------------------------------------------
    # search Files
    # ------------------------------------------------------------------

    async def _handle_search_files(
        self,
        message: IncomingMessage,
    ) -> dict:
        query = message.payload.get(
            "query",
            "",
        )

        limit = message.payload.get(
            "limit",
            SearchService.DEFAULT_LIMIT,
        )

        if not isinstance(query, str):
            return error_message(
                request_id=message.request_id,
                code="invalid_search_query",
                message=(
                    "search.files query must be a string."
                ),
            )

        if isinstance(limit, bool) or not isinstance(
            limit,
            int,
        ):
            return error_message(
                request_id=message.request_id,
                code="invalid_search_limit",
                message=(
                    "search.files limit must be an integer."
                ),
            )

        if limit <= 0:
            return error_message(
                request_id=message.request_id,
                code="invalid_search_limit",
                message=(
                    "search.files limit must be greater than zero."
                ),
            )

        try:
            result = await self._search.search_files(
                query=query,
                limit=limit,
            )

        except SearchError as error:
            return error_message(
                request_id=message.request_id,
                code="search_failed",
                message=str(error),
            )

        except Exception:
            self._logger.exception(
                "Unexpected filesystem search failure"
            )

            return error_message(
                request_id=message.request_id,
                code="search_failed",
                message=(
                    "Filesystem search failed unexpectedly."
                ),
            )

        return response_message(
            request_id=message.request_id,
            command="search.files",
            payload=result,
        )




    async def _handle_search_open(
        self,
        message: IncomingMessage,
    ) -> dict:
        path = message.payload.get(
            "path",
            "",
        )

        if not isinstance(path, str):
            return error_message(
                request_id=message.request_id,
                code="invalid_search_path",
                message=(
                    "search.open path must be a string."
                ),
            )

        if not path.strip():
            return error_message(
                request_id=message.request_id,
                code="invalid_search_path",
                message=(
                    "search.open requires a path."
                ),
            )

        try:
            result = await self._search.open_path(
                path=path,
            )

        except SearchError as error:
            return error_message(
                request_id=message.request_id,
                code="search_open_failed",
                message=str(error),
            )

        except Exception:
            self._logger.exception(
                "Unexpected search open failure"
            )

            return error_message(
                request_id=message.request_id,
                code="search_open_failed",
                message=(
                    "Opening the search result failed unexpectedly."
                ),
            )

        return response_message(
            request_id=message.request_id,
            command="search.open",
            payload=result,
        )


    async def _handle_search_command(
        self,
        message: IncomingMessage,
    ) -> dict:
        command = message.payload.get(
            "command",
            "",
        )

        if not isinstance(command, str):
            return error_message(
                request_id=message.request_id,
                code="invalid_search_command",
                message=(
                    "search.command command must be a string."
                ),
            )

        if not command.strip():
            return error_message(
                request_id=message.request_id,
                code="invalid_search_command",
                message=(
                    "search.command requires a command."
                ),
            )

        try:
            result = await self._search.run_command(
                command=command,
            )

        except SearchError as error:
            return error_message(
                request_id=message.request_id,
                code="search_command_failed",
                message=str(error),
            )

        except Exception:
            self._logger.exception(
                "Unexpected command execution failure"
            )

            return error_message(
                request_id=message.request_id,
                code="search_command_failed",
                message=(
                    "Command execution failed unexpectedly."
                ),
            )

        return response_message(
            request_id=message.request_id,
            command="search.command",
            payload=result,
        )
    # ------------------------------------------------------------------
    # Wallpaper library
    # ------------------------------------------------------------------

    async def _handle_wallpaper_scan(
        self,
        message: IncomingMessage,
    ) -> dict:
        folders = message.payload.get(
            "folders",
            None,
        )

        validation_error = self._validate_folders(
            folders
        )

        if validation_error is not None:
            return error_message(
                request_id=message.request_id,
                code="invalid_wallpaper_folders",
                message=validation_error,
            )

        try:
            result = await self._wallpaper.scan(
                folders=folders
            )

        except WallpaperError as error:
            return error_message(
                request_id=message.request_id,
                code="wallpaper_scan_failed",
                message=str(error),
            )

        except Exception:
            self._logger.exception(
                "Unexpected wallpaper scan failure"
            )

            return error_message(
                request_id=message.request_id,
                code="wallpaper_scan_failed",
                message=(
                    "Wallpaper scan failed unexpectedly."
                ),
            )

        return response_message(
            request_id=message.request_id,
            command="wallpaper.scan",
            payload=result,
        )

    async def _handle_wallpaper_refresh(
        self,
        message: IncomingMessage,
    ) -> dict:
        folders = message.payload.get(
            "folders",
            None,
        )

        validation_error = self._validate_folders(
            folders
        )

        if validation_error is not None:
            return error_message(
                request_id=message.request_id,
                code="invalid_wallpaper_folders",
                message=validation_error,
            )

        try:
            result = await self._wallpaper.refresh(
                folders=folders
            )

        except WallpaperError as error:
            return error_message(
                request_id=message.request_id,
                code="wallpaper_refresh_failed",
                message=str(error),
            )

        except Exception:
            self._logger.exception(
                "Unexpected wallpaper refresh failure"
            )

            return error_message(
                request_id=message.request_id,
                code="wallpaper_refresh_failed",
                message=(
                    "Wallpaper refresh failed unexpectedly."
                ),
            )

        return response_message(
            request_id=message.request_id,
            command="wallpaper.refresh",
            payload=result,
        )

    # ------------------------------------------------------------------
    # Wallpaper apply
    # ------------------------------------------------------------------

    async def _handle_wallpaper_apply(
        self,
        message: IncomingMessage,
    ) -> dict:
        path = message.payload.get(
            "path",
            "",
        )

        transition = message.payload.get(
            "transition",
            "random",
        )

        if not isinstance(path, str):
            return error_message(
                request_id=message.request_id,
                code="invalid_wallpaper_path",
                message=(
                    "wallpaper.apply path must be a string."
                ),
            )

        if not path.strip():
            return error_message(
                request_id=message.request_id,
                code="invalid_wallpaper_path",
                message=(
                    "wallpaper.apply requires a wallpaper path."
                ),
            )

        if not isinstance(transition, str):
            return error_message(
                request_id=message.request_id,
                code="invalid_wallpaper_transition",
                message=(
                    "wallpaper.apply transition must "
                    "be a string."
                ),
            )

        try:
            result = await self._wallpaper.apply(
                path=path,
                transition=transition,
            )

        except WallpaperError as error:
            return error_message(
                request_id=message.request_id,
                code="wallpaper_apply_failed",
                message=str(error),
            )

        except Exception:
            self._logger.exception(
                "Unexpected wallpaper apply failure"
            )

            return error_message(
                request_id=message.request_id,
                code="wallpaper_apply_failed",
                message=(
                    "Wallpaper application failed unexpectedly."
                ),
            )

        return response_message(
            request_id=message.request_id,
            command="wallpaper.apply",
            payload=result,
        )

    # ------------------------------------------------------------------
    # Wallpaper previews
    # ------------------------------------------------------------------

    async def _handle_wallpaper_preview(
        self,
        message: IncomingMessage,
    ) -> dict:
        path = message.payload.get(
            "path",
            "",
        )

        media_type = message.payload.get(
            "type",
            None,
        )

        width = message.payload.get(
            "width",
            ThumbnailService.DEFAULT_WIDTH,
        )

        height = message.payload.get(
            "height",
            ThumbnailService.DEFAULT_HEIGHT,
        )

        if not isinstance(path, str):
            return error_message(
                request_id=message.request_id,
                code="invalid_preview_path",
                message=(
                    "wallpaper.preview path must be a string."
                ),
            )

        if not path.strip():
            return error_message(
                request_id=message.request_id,
                code="invalid_preview_path",
                message=(
                    "wallpaper.preview requires a path."
                ),
            )

        if (
            media_type is not None
            and not isinstance(media_type, str)
        ):
            return error_message(
                request_id=message.request_id,
                code="invalid_preview_type",
                message=(
                    "wallpaper.preview type must "
                    "be a string or null."
                ),
            )

        if not self._valid_dimension(width):
            return error_message(
                request_id=message.request_id,
                code="invalid_preview_width",
                message=(
                    "wallpaper.preview width must "
                    "be a positive integer."
                ),
            )

        if not self._valid_dimension(height):
            return error_message(
                request_id=message.request_id,
                code="invalid_preview_height",
                message=(
                    "wallpaper.preview height must "
                    "be a positive integer."
                ),
            )

        try:
            result = (
                await self._thumbnails.ensure_preview(
                    path=path,
                    media_type=media_type,
                    width=width,
                    height=height,
                )
            )

        except ThumbnailError as error:
            return error_message(
                request_id=message.request_id,
                code="wallpaper_preview_failed",
                message=str(error),
            )

        except Exception:
            self._logger.exception(
                "Unexpected wallpaper preview failure"
            )

            return error_message(
                request_id=message.request_id,
                code="wallpaper_preview_failed",
                message=(
                    "Wallpaper preview generation "
                    "failed unexpectedly."
                ),
            )

        return response_message(
            request_id=message.request_id,
            command="wallpaper.preview",
            payload=result,
        )

    async def _handle_wallpaper_previews(
        self,
        message: IncomingMessage,
    ) -> dict:
        wallpapers = message.payload.get(
            "wallpapers",
            [],
        )

        width = message.payload.get(
            "width",
            ThumbnailService.DEFAULT_WIDTH,
        )

        height = message.payload.get(
            "height",
            ThumbnailService.DEFAULT_HEIGHT,
        )

        concurrency = message.payload.get(
            "concurrency",
            ThumbnailService.DEFAULT_CONCURRENCY,
        )

        if not isinstance(wallpapers, list):
            return error_message(
                request_id=message.request_id,
                code="invalid_preview_library",
                message=(
                    "wallpaper.previews wallpapers "
                    "must be a list."
                ),
            )

        for wallpaper in wallpapers:
            if not isinstance(wallpaper, dict):
                return error_message(
                    request_id=message.request_id,
                    code="invalid_preview_entry",
                    message=(
                        "Every wallpaper preview entry "
                        "must be an object."
                    ),
                )

            path = wallpaper.get(
                "path",
                "",
            )

            if not isinstance(path, str):
                return error_message(
                    request_id=message.request_id,
                    code="invalid_preview_path",
                    message=(
                        "Every preview path must "
                        "be a string."
                    ),
                )

            if not path.strip():
                return error_message(
                    request_id=message.request_id,
                    code="invalid_preview_path",
                    message=(
                        "Every preview entry requires "
                        "a wallpaper path."
                    ),
                )

            media_type = wallpaper.get(
                "type",
                None,
            )

            if (
                media_type is not None
                and not isinstance(
                    media_type,
                    str,
                )
            ):
                return error_message(
                    request_id=message.request_id,
                    code="invalid_preview_type",
                    message=(
                        "Every preview type must "
                        "be a string or null."
                    ),
                )

        if not self._valid_dimension(width):
            return error_message(
                request_id=message.request_id,
                code="invalid_preview_width",
                message=(
                    "wallpaper.previews width must "
                    "be a positive integer."
                ),
            )

        if not self._valid_dimension(height):
            return error_message(
                request_id=message.request_id,
                code="invalid_preview_height",
                message=(
                    "wallpaper.previews height must "
                    "be a positive integer."
                ),
            )

        if not self._valid_positive_integer(
            concurrency
        ):
            return error_message(
                request_id=message.request_id,
                code="invalid_preview_concurrency",
                message=(
                    "wallpaper.previews concurrency "
                    "must be a positive integer."
                ),
            )

        try:
            results = (
                await self._thumbnails.ensure_many(
                    wallpapers=wallpapers,
                    width=width,
                    height=height,
                    concurrency=concurrency,
                )
            )

        except ThumbnailError as error:
            return error_message(
                request_id=message.request_id,
                code="wallpaper_previews_failed",
                message=str(error),
            )

        except Exception:
            self._logger.exception(
                "Unexpected wallpaper previews failure"
            )

            return error_message(
                request_id=message.request_id,
                code="wallpaper_previews_failed",
                message=(
                    "Wallpaper preview generation "
                    "failed unexpectedly."
                ),
            )

        return response_message(
            request_id=message.request_id,
            command="wallpaper.previews",
            payload={
                "previews": results,
            },
        )
    
    async def _handle_theme_generate(
        self,
        message: IncomingMessage,
    ) -> dict:
        path = message.payload.get(
            "path",
            "",
        )

        media_type = message.payload.get(
            "type",
            None,
        )

        if not isinstance(path, str):
            return error_message(
                request_id=message.request_id,
                code="invalid_palette_path",
                message="theme.generate path must be a string.",
            )

        if not path.strip():
            return error_message(
                request_id=message.request_id,
                code="invalid_palette_path",
                message="theme.generate requires a wallpaper path.",
            )

        if (
            media_type is not None
            and not isinstance(media_type, str)
        ):
            return error_message(
                request_id=message.request_id,
                code="invalid_palette_type",
                message=(
                    "theme.generate type must "
                    "be a string or null."
                ),
            )

        try:
            result = await self._palette_source.generate(
                path=path,
                media_type=media_type,
            )

        except PaletteSourceError as error:
            return error_message(
                request_id=message.request_id,
                code="theme_generate_failed",
                message=str(error),
            )

        except Exception:
            self._logger.exception(
                "Unexpected theme generation failure"
            )

            return error_message(
                request_id=message.request_id,
                code="theme_generate_failed",
                message=(
                    "Theme generation failed unexpectedly."
                ),
            )

        return response_message(
            request_id=message.request_id,
            command="theme.generate",
            payload=result,
        )




    # ------------------------------------------------------------------
    # Validation helpers
    # ------------------------------------------------------------------

    def _validate_folders(
        self,
        folders,
    ) -> str | None:
        if folders is None:
            return None

        if not isinstance(folders, list):
            return (
                "Wallpaper folders must be a list."
            )

        for folder in folders:
            if not isinstance(folder, str):
                return (
                    "Every wallpaper source folder "
                    "must be a string."
                )

        return None

    def _valid_dimension(
        self,
        value,
    ) -> bool:
        if isinstance(value, bool):
            return False

        if not isinstance(value, int):
            return False

        return value > 0

    def _valid_positive_integer(
        self,
        value,
    ) -> bool:
        if isinstance(value, bool):
            return False

        if not isinstance(value, int):
            return False

        return value > 0
