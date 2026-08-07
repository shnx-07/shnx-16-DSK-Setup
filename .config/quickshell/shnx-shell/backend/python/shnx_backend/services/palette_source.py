from __future__ import annotations

import asyncio
import hashlib
import logging
import os
import shutil
from pathlib import Path
from typing import Any


class PaletteSourceError(RuntimeError):
    """Raised when a Matugen palette source cannot be prepared."""


class PaletteSourceService:
    """
    Prepares a stable image source for Matugen.

    Rules:

        static image
            -> use original wallpaper directly

        GIF
            -> extract representative still frame

        video
            -> extract representative still frame

    This service does not apply wallpapers.

    It owns only:

        wallpaper media
            ->
        Matugen-compatible image
            ->
        generate-theme.sh
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

    def __init__(self) -> None:
        self._logger = logging.getLogger(__name__)

        self._project_root = (
            Path(__file__)
            .resolve()
            .parents[4]
        )

        self._generate_script = (
            self._project_root
            / "scripts"
            / "generate-theme.sh"
        )

        cache_home = Path(
            os.environ.get(
                "XDG_CACHE_HOME",
                str(Path.home() / ".cache"),
            )
        )

        self._cache_directory = (
            cache_home
            / "shnx-shell"
            / "palette-sources"
        )

    async def generate(
        self,
        path: str,
        media_type: str | None = None,
    ) -> dict[str, Any]:
        """
        Prepare a Matugen source and generate the SHNX palette.
        """

        wallpaper = self._normalize_path(
            path
        )

        detected_type = (
            self._normalize_media_type(
                media_type
            )
            if media_type
            else self._detect_type(
                wallpaper
            )
        )

        if detected_type is None:
            raise PaletteSourceError(
                "Unsupported wallpaper format for palette generation: "
                f"{wallpaper.suffix}"
            )

        source_image = await self.prepare_source(
            wallpaper=wallpaper,
            media_type=detected_type,
        )

        await self._run_generate_theme(
            source_image
        )

        return {
            "success": True,
            "wallpaper": str(wallpaper),
            "type": detected_type,
            "source": str(source_image),
        }

    async def prepare_source(
        self,
        wallpaper: Path,
        media_type: str,
    ) -> Path:
        """
        Return an image Matugen can consume.
        """

        if media_type == "static":
            return wallpaper

        if media_type in {
            "gif",
            "video",
        }:
            return await self._extract_frame(
                wallpaper=wallpaper,
                media_type=media_type,
            )

        raise PaletteSourceError(
            f"Unsupported palette source type: {media_type}"
        )

    def _normalize_path(
        self,
        path: str,
    ) -> Path:
        if not isinstance(path, str):
            raise PaletteSourceError(
                "Palette source path must be a string."
            )

        if not path.strip():
            raise PaletteSourceError(
                "Palette source path cannot be empty."
            )

        expanded = os.path.expandvars(
            os.path.expanduser(path)
        )

        wallpaper = Path(
            expanded
        ).resolve()

        if not wallpaper.exists():
            raise PaletteSourceError(
                f"Wallpaper does not exist: {wallpaper}"
            )

        if not wallpaper.is_file():
            raise PaletteSourceError(
                f"Wallpaper is not a file: {wallpaper}"
            )

        return wallpaper

    def _normalize_media_type(
        self,
        media_type: str,
    ) -> str:
        value = (
            media_type
            .strip()
            .lower()
        )

        if value not in {
            "static",
            "gif",
            "video",
        }:
            raise PaletteSourceError(
                f"Unsupported wallpaper type: {media_type}"
            )

        return value

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

    async def _extract_frame(
        self,
        wallpaper: Path,
        media_type: str,
    ) -> Path:
        """
        Extract a deterministic representative frame.

        GIF:
            use a frame near the beginning.

        Video:
            seek a little into the video so title/black frames
            are less likely to become the palette source.
        """

        if shutil.which("ffmpeg") is None:
            raise PaletteSourceError(
                "ffmpeg is required for GIF/video palette extraction."
            )

        self._cache_directory.mkdir(
            parents=True,
            exist_ok=True,
        )

        cache_key = self._cache_key(
            wallpaper
        )

        output = (
            self._cache_directory
            / f"{cache_key}.png"
        )

        if self._cache_is_current(
            wallpaper,
            output,
        ):
            self._logger.debug(
                "Using cached palette source: %s",
                output,
            )

            return output

        temporary_output = output.with_suffix(
            ".tmp.png"
        )

        temporary_output.unlink(
            missing_ok=True
        )

        if media_type == "video":
            command = [
                "ffmpeg",
                "-hide_banner",
                "-loglevel",
                "error",
                "-y",
                "-ss",
                "1",
                "-i",
                str(wallpaper),
                "-frames:v",
                "1",
                "-vf",
                "scale='min(1920,iw)':-2",
                str(temporary_output),
            ]

        else:
            command = [
                "ffmpeg",
                "-hide_banner",
                "-loglevel",
                "error",
                "-y",
                "-i",
                str(wallpaper),
                "-frames:v",
                "1",
                "-vf",
                "scale='min(1920,iw)':-2",
                str(temporary_output),
            ]

        self._logger.info(
            "Preparing Matugen source from %s wallpaper: %s",
            media_type,
            wallpaper,
        )

        process = await asyncio.create_subprocess_exec(
            *command,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
        )

        stdout, stderr = await process.communicate()

        if process.returncode != 0:
            message = (
                stderr.decode(
                    errors="replace"
                ).strip()
                or stdout.decode(
                    errors="replace"
                ).strip()
                or "ffmpeg palette source extraction failed."
            )

            temporary_output.unlink(
                missing_ok=True
            )

            raise PaletteSourceError(
                message
            )

        if (
            not temporary_output.exists()
            or temporary_output.stat().st_size == 0
        ):
            temporary_output.unlink(
                missing_ok=True
            )

            raise PaletteSourceError(
                "ffmpeg did not create a valid palette source image."
            )

        temporary_output.replace(
            output
        )

        return output

    async def _run_generate_theme(
        self,
        source_image: Path,
    ) -> None:
        if not self._generate_script.exists():
            raise PaletteSourceError(
                "Theme generation script does not exist: "
                f"{self._generate_script}"
            )

        if not self._generate_script.is_file():
            raise PaletteSourceError(
                "Theme generation script is not a file: "
                f"{self._generate_script}"
            )

        self._logger.info(
            "Generating Matugen palette from: %s",
            source_image,
        )

        process = await asyncio.create_subprocess_exec(
            "bash",
            str(self._generate_script),
            str(source_image),
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
        )

        stdout, stderr = await process.communicate()

        standard_output = stdout.decode(
            errors="replace"
        ).strip()

        standard_error = stderr.decode(
            errors="replace"
        ).strip()

        if standard_output:
            self._logger.info(
                "%s",
                standard_output,
            )

        if process.returncode != 0:
            raise PaletteSourceError(
                standard_error
                or standard_output
                or "Matugen theme generation failed."
            )

    def _cache_key(
        self,
        wallpaper: Path,
    ) -> str:
        stat = wallpaper.stat()

        identity = (
            f"{wallpaper}:"
            f"{stat.st_size}:"
            f"{stat.st_mtime_ns}"
        )

        return hashlib.sha256(
            identity.encode(
                "utf-8"
            )
        ).hexdigest()[:24]

    def _cache_is_current(
        self,
        wallpaper: Path,
        cached_source: Path,
    ) -> bool:
        if not cached_source.exists():
            return False

        if not cached_source.is_file():
            return False

        if cached_source.stat().st_size == 0:
            return False

        return True
