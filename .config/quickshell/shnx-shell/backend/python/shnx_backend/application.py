from __future__ import annotations

import asyncio
import logging
import os
from pathlib import Path

from .ipc.messages import (
    IncomingMessage,
    PROTOCOL_VERSION,
    error_message,
    event_message,
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


from .services.display import set_monitor
from .services.input import set_mouse

from .services.system_settings import (
    get_state,
    restore_monitor_preferences,
    save_monitor_preferences,
    save_mouse_preferences,
)

from .system import hyprland
from .system.hyprland import HyprlandError
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

        hyprland_task = asyncio.create_task(
            self._watch_hyprland_events(),
            name="hyprland-event-watcher",
        )

        try:
            await self._server.serve_forever()

        except asyncio.CancelledError:
            raise

        finally:
            hyprland_task.cancel()

            try:
                await hyprland_task
            except asyncio.CancelledError:
                pass

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
        if message.command == "system.settings.get":
            return await self._handle_system_settings_get(
                message
            )

        if message.command == "display.set":
            return await self._handle_display_set(
                message
            )

        if message.command == "input.set":
            return await self._handle_input_set(
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
    # System settings
    # ------------------------------------------------------------------

    async def _handle_system_settings_get(
        self,
        message: IncomingMessage,
    ) -> dict:
        try:
            state = await asyncio.to_thread(
                get_state
            )

        except HyprlandError as error:
            return error_message(
                request_id=message.request_id,
                code="hyprland_unavailable",
                message=str(error),
            )

        except Exception as error:
            self._logger.exception(
                "Failed to read system settings"
            )

            return error_message(
                request_id=message.request_id,
                code="system_settings_unavailable",
                message=str(error),
            )

        return response_message(
            request_id=message.request_id,
            command="system.settings.get",
            payload=state,
        )


    # ------------------------------------------------------------------
    # Display
    # ------------------------------------------------------------------

    async def _handle_display_set(self, message):
        payload = message.payload

        name = payload.get("name")

        if not isinstance(name, str) or not name.strip():
            return error_message(
                request_id=message.request_id,
                code="display_invalid_name",
                message="A monitor name is required",
            )

        resolution = payload.get("resolution")
        refresh_rate = payload.get("refresh_rate")
        scale = payload.get("scale", 1.0)
        enabled = payload.get("enabled", True)
        position = payload.get("position")

        try:
            result = await asyncio.to_thread(
                set_monitor,
                name,
                resolution=resolution,
                refresh_rate=refresh_rate,
                scale=scale,
                enabled=enabled,
                position=position,
            )

            state = await asyncio.to_thread(get_state)

            actual_monitor = next(
                (
                    monitor
                    for monitor in state["display"]["monitors"]
                    if monitor.get("name") == name
                ),
                None,
            )

            if actual_monitor is not None:
                await asyncio.to_thread(
                    save_monitor_preferences,
                    actual_monitor,
                )

            state = await asyncio.to_thread(get_state)

            await self._emit_event(
                "display.changed",
                state["display"],
            )

            return response_message(
                request_id=message.request_id,
                command=message.command,
                payload={
                    "result": result,
                    "display": state["display"],
                    "saved": state.get("saved", {}),
                },
            )

        except ValueError as exc:
            return error_message(
                request_id=message.request_id,
                code="display_invalid_request",
                message=str(exc),
            )

        except HyprlandError as exc:
            return error_message(
                request_id=message.request_id,
                code="display_hyprland_error",
                message=str(exc),
            )

        except Exception as exc:
            return error_message(
                request_id=message.request_id,
                code="display_internal_error",
                message=str(exc),
            )


    # ------------------------------------------------------------------
    # Input
    # ------------------------------------------------------------------

    async def _handle_input_set(self, message):
        payload = message.payload

        sensitivity = payload.get("sensitivity")
        accel_profile = payload.get("accel_profile")

        try:
            result = await asyncio.to_thread(
                set_mouse,
                sensitivity=sensitivity,
                accel_profile=accel_profile,
            )

            state = await asyncio.to_thread(get_state)

            actual_mouse = state["input"]["mouse"]

            await asyncio.to_thread(
                save_mouse_preferences,
                actual_mouse,
            )

            state = await asyncio.to_thread(get_state)

            return response_message(
                request_id=message.request_id,
                command=message.command,
                payload={
                    "result": result,
                    "input": state["input"],
                    "saved": state.get("saved", {}),
                },
            )

        except ValueError as exc:
            return error_message(
                request_id=message.request_id,
                code="input_invalid_request",
                message=str(exc),
            )

        except HyprlandError as exc:
            return error_message(
                request_id=message.request_id,
                code="input_hyprland_error",
                message=str(exc),
            )

        except Exception as exc:
            return error_message(
                request_id=message.request_id,
                code="input_internal_error",
                message=str(exc),
            )

    async def _watch_hyprland_events(
        self,
    ) -> None:
        while True:
            try:
                async for (
                    event_name,
                    event_data,
                ) in hyprland.events():

                    if event_name == "monitoradded":
                        await self._handle_monitor_added(
                            event_data
                        )

                    elif event_name == "monitorremoved":
                        await self._handle_monitor_removed(
                            event_data
                        )

            except asyncio.CancelledError:
                raise

            except Exception:
                self._logger.exception(
                    "Hyprland event watcher failed"
                )

                await asyncio.sleep(1.0)




    async def _handle_monitor_added(
        self,
        name: str,
    ) -> None:
        name = name.strip()

        if not name:
            return

        self._logger.info(
            "Monitor connected: %s",
            name,
        )

        await asyncio.sleep(0.15)

        restored = False

        try:
            result = await asyncio.to_thread(
                restore_monitor_preferences,
                name,
            )

            restored = (
                result is not None
            )

            if restored:
                self._logger.info(
                    "Restored settings for monitor %s",
                    name,
                )
            else:
                self._logger.info(
                    "No saved settings for monitor %s",
                    name,
                )

        except Exception:
            self._logger.exception(
                "Failed restoring monitor %s",
                name,
            )

        state = await asyncio.to_thread(
            get_state
        )

        monitor = next(
            (
                item
                for item
                in state["display"]["monitors"]
                if item.get("name") == name
            ),
            None,
        )

        await self._emit_event(
            "display.monitorAdded",
            {
                "name": name,
                "restored": restored,
                "monitor": monitor,
            },
        )

        await self._emit_event(
            "display.changed",
            state["display"],
        )


    async def _handle_monitor_removed(
        self,
        name: str,
    ) -> None:
        name = name.strip()

        if not name:
            return

        self._logger.info(
            "Monitor disconnected: %s",
            name,
        )

        # Give Hyprland a moment to update monitor state.
        await asyncio.sleep(0.1)

        state = await asyncio.to_thread(
            get_state
        )

        await self._emit_event(
            "display.monitorRemoved",
            {
                "name": name,
            },
        )

        await self._emit_event(
            "display.changed",
            state["display"],
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
    
    
    async def _emit_event(
        self,
        event: str,
        payload: dict | None = None,
    ) -> None:
        await self._server.broadcast(
            event_message(
                event=event,
                payload=payload or {},
            )
        ) 
    
    
    
