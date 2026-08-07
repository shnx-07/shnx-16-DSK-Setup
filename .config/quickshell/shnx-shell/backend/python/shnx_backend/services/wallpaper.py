from __future__ import annotations

import asyncio
import logging
import os
import random
import shutil
import signal
from dataclasses import dataclass
from pathlib import Path
from typing import Any


class WallpaperError(RuntimeError):
    """Raised when a wallpaper operation cannot be completed."""


@dataclass(frozen=True)
class WallpaperItem:
    path: Path
    media_type: str
    source_folder: Path

    def to_dict(self) -> dict[str, Any]:
        stat = self.path.stat()

        return {
            "id": str(self.path),
            "path": str(self.path),
            "name": self.path.name,
            "type": self.media_type,
            "sourceFolder": str(self.source_folder),
            "extension": self.path.suffix.lower(),
            "size": stat.st_size,
            "modified": int(stat.st_mtime),
        }


class WallpaperService:
    """
    Backend wallpaper domain service.

    Responsibilities:
      - recursively scan configured wallpaper folders
      - classify static / GIF / video wallpapers
      - apply static and GIF wallpapers through awww
      - apply video wallpapers through mpvpaper
      - switch safely between wallpaper engines
      - retain the last confirmed working wallpaper
      - provide rollback when a new wallpaper fails

    Thumbnail/poster generation is intentionally NOT handled here.
    Matugen/palette generation is intentionally NOT handled here.
    """

    STATIC_EXTENSIONS = {
        ".png",
        ".jpg",
        ".jpeg",
        ".webp",
    }

    GIF_EXTENSIONS = {
        ".gif",
    }

    VIDEO_EXTENSIONS = {
        ".mp4",
        ".webm",
        ".mkv",
        ".mov",
        ".m4v",
    }

    TRANSITIONS = (
        "fade",
        "left",
        "right",
        "top",
        "bottom",
        "wipe",
        "wave",
        "grow",
        "center",
        "any",
    )

    DEFAULT_SOURCE_FOLDER = (
        Path.home()
        / "Pictures"
        / "Wallpapers"
    )

    def __init__(self) -> None:
        self._logger = logging.getLogger(__name__)

        self._current_wallpaper: Path | None = None
        self._current_type: str | None = None

        self._previous_wallpaper: Path | None = None
        self._previous_type: str | None = None

        self._last_transition: str | None = None

        self._mpvpaper_process: asyncio.subprocess.Process | None = None

    async def scan(
        self,
        folders: list[str] | None = None,
    ) -> dict[str, Any]:
        """
        Scan wallpaper folders recursively.

        This returns metadata only.
        It does not decode or preview media.
        """

        resolved_folders = self._resolve_folders(
            folders
        )

        wallpapers: list[WallpaperItem] = []

        for folder in resolved_folders:
            if not folder.exists():
                continue

            if not folder.is_dir():
                continue

            try:
                entries = folder.rglob("*")

                for path in entries:
                    if not path.is_file():
                        continue

                    media_type = self._detect_type(
                        path
                    )

                    if media_type is None:
                        continue

                    wallpapers.append(
                        WallpaperItem(
                            path=path.resolve(),
                            media_type=media_type,
                            source_folder=folder,
                        )
                    )

            except OSError as error:
                self._logger.warning(
                    "Could not scan wallpaper folder %s: %s",
                    folder,
                    error,
                )

        wallpapers.sort(
            key=lambda item: item.path.name.lower()
        )

        return {
            "wallpapers": [
                item.to_dict()
                for item in wallpapers
            ],
            "folders": [
                str(folder)
                for folder in resolved_folders
            ],
            "current": (
                str(self._current_wallpaper)
                if self._current_wallpaper
                else None
            ),
        }

    async def refresh(
        self,
        folders: list[str] | None = None,
    ) -> dict[str, Any]:
        """
        Current first-pass refresh behavior.

        Later this will use persisted metadata/cache timestamps
        and update only changed filesystem entries.
        """

        return await self.scan(folders)

    async def apply(
        self,
        path: str,
        transition: str = "random",
    ) -> dict[str, Any]:
        wallpaper = self._normalize_wallpaper_path(
            path
        )

        media_type = self._detect_type(
            wallpaper
        )

        if media_type is None:
            raise WallpaperError(
                f"Unsupported wallpaper format: "
                f"{wallpaper.suffix}"
            )

        previous_wallpaper = self._current_wallpaper
        previous_type = self._current_type

        self._previous_wallpaper = previous_wallpaper
        self._previous_type = previous_type

        chosen_transition = (
            self._choose_transition()
            if transition == "random"
            else transition
        )

        try:
            if media_type in {
                "static",
                "gif",
            }:
                await self._apply_awww(
                    wallpaper,
                    chosen_transition,
                )

            elif media_type == "video":
                await self._apply_video(
                    wallpaper
                )

            else:
                raise WallpaperError(
                    f"Unsupported wallpaper type: "
                    f"{media_type}"
                )

        except Exception as error:
            self._logger.error(
                "Wallpaper apply failed for %s: %s",
                wallpaper,
                error,
            )

            rollback_error: Exception | None = None

            if previous_wallpaper is not None:
                try:
                    await self._restore_wallpaper(
                        previous_wallpaper,
                        previous_type,
                    )

                except Exception as restore_error:
                    rollback_error = restore_error

                    self._logger.exception(
                        "Wallpaper rollback failed"
                    )

            if rollback_error is not None:
                raise WallpaperError(
                    "Wallpaper application failed and "
                    "rollback also failed: "
                    f"{rollback_error}"
                ) from error

            raise WallpaperError(
                str(error)
            ) from error

        self._current_wallpaper = wallpaper
        self._current_type = media_type

        self._previous_wallpaper = None
        self._previous_type = None

        return {
            "success": True,
            "path": str(wallpaper),
            "type": media_type,
            "transition": chosen_transition,
        }

    def _resolve_folders(
        self,
        folders: list[str] | None,
    ) -> list[Path]:
        if not folders:
            folders = [
                str(self.DEFAULT_SOURCE_FOLDER)
            ]

        resolved: list[Path] = []

        for folder in folders:
            if not isinstance(folder, str):
                continue

            expanded = os.path.expandvars(
                os.path.expanduser(folder)
            )

            path = Path(expanded).resolve()

            if path not in resolved:
                resolved.append(path)

        return resolved

    def _normalize_wallpaper_path(
        self,
        path: str,
    ) -> Path:
        if not isinstance(path, str):
            raise WallpaperError(
                "Wallpaper path must be a string."
            )

        expanded = os.path.expandvars(
            os.path.expanduser(path)
        )

        wallpaper = Path(expanded).resolve()

        if not wallpaper.exists():
            raise WallpaperError(
                f"Wallpaper does not exist: "
                f"{wallpaper}"
            )

        if not wallpaper.is_file():
            raise WallpaperError(
                f"Wallpaper is not a file: "
                f"{wallpaper}"
            )

        return wallpaper

    def _detect_type(
        self,
        path: Path,
    ) -> str | None:
        suffix = path.suffix.lower()

        if suffix in self.STATIC_EXTENSIONS:
            return "static"

        if suffix in self.GIF_EXTENSIONS:
            return "gif"

        if suffix in self.VIDEO_EXTENSIONS:
            return "video"

        return None

    def _choose_transition(self) -> str:
        transitions = [
            transition
            for transition in self.TRANSITIONS
            if transition != self._last_transition
        ]

        transition = random.choice(
            transitions
        )

        self._last_transition = transition

        return transition

    async def _ensure_awww_daemon(
        self,
    ) -> None:
        if shutil.which("awww") is None:
            raise WallpaperError(
                "awww is not installed."
            )

        if shutil.which("awww-daemon") is None:
            raise WallpaperError(
                "awww-daemon is not installed."
            )

        query = await asyncio.create_subprocess_exec(
            "awww",
            "query",
            stdout=asyncio.subprocess.DEVNULL,
            stderr=asyncio.subprocess.DEVNULL,
        )

        result = await query.wait()

        if result == 0:
            return

        self._logger.info(
            "Starting awww-daemon"
        )

        await asyncio.create_subprocess_exec(
            "awww-daemon",
            stdout=asyncio.subprocess.DEVNULL,
            stderr=asyncio.subprocess.DEVNULL,
            start_new_session=True,
        )

        for _ in range(20):
            await asyncio.sleep(0.1)

            probe = (
                await asyncio.create_subprocess_exec(
                    "awww",
                    "query",
                    stdout=(
                        asyncio.subprocess.DEVNULL
                    ),
                    stderr=(
                        asyncio.subprocess.DEVNULL
                    ),
                )
            )

            if await probe.wait() == 0:
                return

        raise WallpaperError(
            "awww-daemon did not become ready."
        )

    async def _apply_awww(
        self,
        wallpaper: Path,
        transition: str,
    ) -> None:
        await self._stop_mpvpaper()

        await self._ensure_awww_daemon()

        command = [
            "awww",
            "img",
            str(wallpaper),
            "--transition-type",
            transition,
            "--transition-duration",
            "0.65",
        ]

        self._logger.info(
            "Applying wallpaper with awww: %s",
            wallpaper,
        )

        process = await asyncio.create_subprocess_exec(
            *command,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
        )

        stdout, stderr = (
            await process.communicate()
        )

        if process.returncode != 0:
            message = (
                stderr.decode(
                    errors="replace"
                ).strip()
                or stdout.decode(
                    errors="replace"
                ).strip()
                or "awww failed."
            )

            raise WallpaperError(
                message
            )

    async def _apply_video(
        self,
        wallpaper: Path,
    ) -> None:
        if shutil.which("mpvpaper") is None:
            raise WallpaperError(
                "mpvpaper is not installed."
            )

        await self._stop_mpvpaper()

        await self._clear_awww()

        command = [
            "mpvpaper",
            "--fork",
            "--auto-pause",
            "--mpv-options",
            (
                "no-audio "
                "loop-file=inf "
                "hwdec=auto"
            ),
            "ALL",
            str(wallpaper),
        ]

        self._logger.info(
            "Applying video wallpaper: %s",
            wallpaper,
        )

        process = await asyncio.create_subprocess_exec(
            *command,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
        )

        stdout, stderr = (
            await process.communicate()
        )

        if process.returncode != 0:
            message = (
                stderr.decode(
                    errors="replace"
                ).strip()
                or stdout.decode(
                    errors="replace"
                ).strip()
                or "mpvpaper failed."
            )

            raise WallpaperError(
                message
            )

        await asyncio.sleep(0.25)

    async def _stop_mpvpaper(
        self,
    ) -> None:
        """
        Stop existing mpvpaper instances owned by the user.

        Later we can replace this with explicit PID/state ownership
        when persistent wallpaper state is added.
        """

        process = await asyncio.create_subprocess_exec(
            "pkill",
            "-x",
            "mpvpaper",
            stdout=asyncio.subprocess.DEVNULL,
            stderr=asyncio.subprocess.DEVNULL,
        )

        await process.wait()

    async def _clear_awww(
        self,
    ) -> None:
        if shutil.which("awww") is None:
            return

        process = await asyncio.create_subprocess_exec(
            "awww",
            "clear",
            stdout=asyncio.subprocess.DEVNULL,
            stderr=asyncio.subprocess.DEVNULL,
        )

        await process.wait()

    async def _restore_wallpaper(
        self,
        wallpaper: Path,
        media_type: str | None,
    ) -> None:
        if media_type in {
            "static",
            "gif",
        }:
            await self._apply_awww(
                wallpaper,
                "fade",
            )

            self._current_wallpaper = wallpaper
            self._current_type = media_type
            return

        if media_type == "video":
            await self._apply_video(
                wallpaper
            )

            self._current_wallpaper = wallpaper
            self._current_type = media_type
            return

        raise WallpaperError(
            "Previous wallpaper type is unknown."
        )
