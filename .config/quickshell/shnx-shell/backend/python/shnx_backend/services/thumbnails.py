from __future__ import annotations

import asyncio
import hashlib
import logging
import os
import shutil
from pathlib import Path
from typing import Any


class ThumbnailError(RuntimeError):
    """Raised when a wallpaper preview cannot be generated."""


class ThumbnailService:
    """
    Generate lightweight, still wallpaper previews.

    Important rules:

    - Static wallpapers produce a resized still thumbnail.
    - GIF wallpapers produce ONE still frame only.
    - Video wallpapers produce ONE still poster only.
    - The carousel never receives animated media.
    - Generated previews are cached.
    - Cache identity changes when the source file changes.

    Preview format:
        PNG

    Cache layout:
        ~/.cache/shnx-shell/wallpapers/
        ├── thumbnails/
        └── posters/
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

    DEFAULT_WIDTH = 640
    DEFAULT_HEIGHT = 360

    MIN_DIMENSION = 64
    MAX_DIMENSION = 1920

    DEFAULT_CONCURRENCY = 2
    MAX_CONCURRENCY = 4

    def __init__(self) -> None:
        self._logger = logging.getLogger(__name__)

        cache_home = os.environ.get(
            "XDG_CACHE_HOME",
            str(Path.home() / ".cache"),
        )

        self._cache_root = (
            Path(cache_home)
            / "shnx-shell"
            / "wallpapers"
        )

        self._thumbnail_directory = (
            self._cache_root
            / "thumbnails"
        )

        self._poster_directory = (
            self._cache_root
            / "posters"
        )

        self._ensure_cache_directories()

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    async def ensure_preview(
        self,
        path: str,
        media_type: str | None = None,
        width: int = DEFAULT_WIDTH,
        height: int = DEFAULT_HEIGHT,
    ) -> dict[str, Any]:
        """
        Return a cached preview for one wallpaper.

        If no valid cached preview exists, generate one.
        """

        source = self._normalize_source(path)

        detected_type = (
            media_type
            if media_type
            else self._detect_type(source)
        )

        if detected_type not in {
            "static",
            "gif",
            "video",
        }:
            raise ThumbnailError(
                f"Unsupported wallpaper type: {detected_type}"
            )

        width = self._sanitize_dimension(
            width,
            self.DEFAULT_WIDTH,
        )

        height = self._sanitize_dimension(
            height,
            self.DEFAULT_HEIGHT,
        )

        preview = self._preview_cache_path(
            source=source,
            media_type=detected_type,
            width=width,
            height=height,
        )

        if self._valid_cached_preview(preview):
            return self._build_result(
                source=source,
                media_type=detected_type,
                preview=preview,
                cached=True,
            )

        preview.unlink(
            missing_ok=True
        )

        await self._generate_preview(
            source=source,
            media_type=detected_type,
            output=preview,
            width=width,
            height=height,
        )

        if not self._valid_cached_preview(preview):
            preview.unlink(
                missing_ok=True
            )

            raise ThumbnailError(
                "Preview generation completed but "
                "no valid preview was produced."
            )

        return self._build_result(
            source=source,
            media_type=detected_type,
            preview=preview,
            cached=False,
        )

    async def ensure_many(
        self,
        wallpapers: list[dict[str, Any]],
        width: int = DEFAULT_WIDTH,
        height: int = DEFAULT_HEIGHT,
        concurrency: int = DEFAULT_CONCURRENCY,
    ) -> list[dict[str, Any]]:
        """
        Generate previews for a wallpaper library.

        Work is intentionally bounded so opening a folder containing
        hundreds of wallpapers does not launch hundreds of ffmpeg
        processes simultaneously.
        """

        if not isinstance(wallpapers, list):
            raise ThumbnailError(
                "wallpapers must be a list."
            )

        try:
            concurrency = int(concurrency)

        except (
            TypeError,
            ValueError,
        ):
            concurrency = self.DEFAULT_CONCURRENCY

        concurrency = max(
            1,
            min(
                concurrency,
                self.MAX_CONCURRENCY,
            ),
        )

        semaphore = asyncio.Semaphore(
            concurrency
        )

        async def worker(
            wallpaper: dict[str, Any],
        ) -> dict[str, Any]:
            if not isinstance(
                wallpaper,
                dict,
            ):
                return {
                    "success": False,
                    "path": "",
                    "type": None,
                    "preview": None,
                    "error": (
                        "Wallpaper entry must be an object."
                    ),
                }

            path = wallpaper.get(
                "path",
                "",
            )

            media_type = wallpaper.get(
                "type",
                None,
            )

            async with semaphore:
                try:
                    preview = (
                        await self.ensure_preview(
                            path=path,
                            media_type=media_type,
                            width=width,
                            height=height,
                        )
                    )

                    return {
                        "success": True,
                        **preview,
                    }

                except Exception as error:
                    self._logger.warning(
                        "Could not generate preview "
                        "for %s: %s",
                        path,
                        error,
                    )

                    return {
                        "success": False,
                        "path": path,
                        "type": media_type,
                        "preview": None,
                        "error": str(error),
                    }

        tasks = [
            asyncio.create_task(
                worker(wallpaper)
            )
            for wallpaper in wallpapers
        ]

        if not tasks:
            return []

        return await asyncio.gather(
            *tasks
        )

    # ------------------------------------------------------------------
    # Paths / cache
    # ------------------------------------------------------------------

    def _ensure_cache_directories(
        self,
    ) -> None:
        self._thumbnail_directory.mkdir(
            parents=True,
            exist_ok=True,
        )

        self._poster_directory.mkdir(
            parents=True,
            exist_ok=True,
        )

    def _normalize_source(
        self,
        path: str,
    ) -> Path:
        if not isinstance(
            path,
            str,
        ):
            raise ThumbnailError(
                "Wallpaper path must be a string."
            )

        if not path.strip():
            raise ThumbnailError(
                "Wallpaper path cannot be empty."
            )

        expanded = os.path.expandvars(
            os.path.expanduser(path)
        )

        source = Path(
            expanded
        ).resolve()

        if not source.exists():
            raise ThumbnailError(
                f"Wallpaper does not exist: {source}"
            )

        if not source.is_file():
            raise ThumbnailError(
                f"Wallpaper is not a file: {source}"
            )

        return source

    def _preview_cache_path(
        self,
        source: Path,
        media_type: str,
        width: int,
        height: int,
    ) -> Path:
        stat = source.stat()

        identity = "|".join(
            (
                str(source),
                str(stat.st_size),
                str(stat.st_mtime_ns),
                media_type,
                str(width),
                str(height),
                "preview-v2",
            )
        )

        digest = hashlib.sha256(
            identity.encode(
                "utf-8"
            )
        ).hexdigest()[:24]

        if media_type == "static":
            directory = (
                self._thumbnail_directory
            )

        else:
            directory = (
                self._poster_directory
            )

        return (
            directory
            / f"{digest}.png"
        )

    def _valid_cached_preview(
        self,
        path: Path,
    ) -> bool:
        if not path.exists():
            return False

        if not path.is_file():
            return False

        try:
            return path.stat().st_size > 0

        except OSError:
            return False

    # ------------------------------------------------------------------
    # Media detection
    # ------------------------------------------------------------------

    def _detect_type(
        self,
        path: Path,
    ) -> str | None:
        extension = (
            path.suffix.lower()
        )

        if (
            extension
            in self.STATIC_EXTENSIONS
        ):
            return "static"

        if (
            extension
            in self.GIF_EXTENSIONS
        ):
            return "gif"

        if (
            extension
            in self.VIDEO_EXTENSIONS
        ):
            return "video"

        return None

    # ------------------------------------------------------------------
    # Dimensions
    # ------------------------------------------------------------------

    def _sanitize_dimension(
        self,
        value: int,
        fallback: int,
    ) -> int:
        try:
            value = int(value)

        except (
            TypeError,
            ValueError,
        ):
            value = fallback

        return max(
            self.MIN_DIMENSION,
            min(
                value,
                self.MAX_DIMENSION,
            ),
        )

    # ------------------------------------------------------------------
    # Preview generation
    # ------------------------------------------------------------------

    async def _generate_preview(
        self,
        source: Path,
        media_type: str,
        output: Path,
        width: int,
        height: int,
    ) -> None:
        ffmpeg = shutil.which(
            "ffmpeg"
        )

        if ffmpeg is None:
            raise ThumbnailError(
                "ffmpeg is not installed."
            )

        output.parent.mkdir(
            parents=True,
            exist_ok=True,
        )

        temporary = output.with_name(
            output.stem
            + ".tmp"
            + output.suffix
        )

        temporary.unlink(
            missing_ok=True
        )

        try:
            if media_type == "static":
                await self._generate_static_preview(
                    ffmpeg=ffmpeg,
                    source=source,
                    output=temporary,
                    width=width,
                    height=height,
                )

            elif media_type == "gif":
                await self._generate_gif_preview(
                    ffmpeg=ffmpeg,
                    source=source,
                    output=temporary,
                    width=width,
                    height=height,
                )

            elif media_type == "video":
                await self._generate_video_preview(
                    ffmpeg=ffmpeg,
                    source=source,
                    output=temporary,
                    width=width,
                    height=height,
                )

            else:
                raise ThumbnailError(
                    f"Unsupported media type: "
                    f"{media_type}"
                )

            if not self._valid_cached_preview(
                temporary
            ):
                raise ThumbnailError(
                    "ffmpeg did not create "
                    "a valid preview."
                )

            temporary.replace(
                output
            )

        except Exception:
            temporary.unlink(
                missing_ok=True
            )

            raise

    async def _generate_static_preview(
        self,
        ffmpeg: str,
        source: Path,
        output: Path,
        width: int,
        height: int,
    ) -> None:
        command = [
            ffmpeg,
            "-hide_banner",
            "-loglevel",
            "error",
            "-y",

            "-i",
            str(source),

            "-frames:v",
            "1",

            "-vf",
            self._scale_filter(
                width,
                height,
            ),

            "-threads",
            "1",

            str(output),
        ]

        await self._run_ffmpeg(
            command
        )

    async def _generate_gif_preview(
        self,
        ffmpeg: str,
        source: Path,
        output: Path,
        width: int,
        height: int,
    ) -> None:
        """
        Extract exactly one still frame.

        We intentionally do not seek into the GIF because short GIFs,
        unusual frame disposal, or tiny durations can otherwise cause
        ffmpeg to successfully exit without writing a frame.
        """

        command = [
            ffmpeg,
            "-hide_banner",
            "-loglevel",
            "error",
            "-y",

            "-i",
            str(source),

            "-frames:v",
            "1",

            "-vf",
            self._scale_filter(
                width,
                height,
            ),

            "-threads",
            "1",

            str(output),
        ]

        await self._run_ffmpeg(
            command
        )

    async def _generate_video_preview(
        self,
        ffmpeg: str,
        source: Path,
        output: Path,
        width: int,
        height: int,
    ) -> None:
        """
        Try a frame at 1 second first.

        If the video is shorter than that or seeking produces no frame,
        fall back to the first decodable frame.
        """

        seek_command = [
            ffmpeg,
            "-hide_banner",
            "-loglevel",
            "error",
            "-y",

            "-ss",
            "1.0",

            "-i",
            str(source),

            "-frames:v",
            "1",

            "-vf",
            self._scale_filter(
                width,
                height,
            ),

            "-threads",
            "1",

            str(output),
        ]

        try:
            await self._run_ffmpeg(
                seek_command
            )

            if self._valid_cached_preview(
                output
            ):
                return

        except ThumbnailError:
            pass

        output.unlink(
            missing_ok=True
        )

        fallback_command = [
            ffmpeg,
            "-hide_banner",
            "-loglevel",
            "error",
            "-y",

            "-i",
            str(source),

            "-frames:v",
            "1",

            "-vf",
            self._scale_filter(
                width,
                height,
            ),

            "-threads",
            "1",

            str(output),
        ]

        await self._run_ffmpeg(
            fallback_command
        )

    async def _run_ffmpeg(
        self,
        command: list[str],
    ) -> None:
        self._logger.debug(
            "Running preview command: %s",
            " ".join(command),
        )

        process = (
            await asyncio.create_subprocess_exec(
                *command,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
            )
        )

        stdout, stderr = (
            await process.communicate()
        )

        if process.returncode == 0:
            return

        stdout_text = (
            stdout.decode(
                errors="replace"
            ).strip()
        )

        stderr_text = (
            stderr.decode(
                errors="replace"
            ).strip()
        )

        message = (
            stderr_text
            or stdout_text
            or (
                "ffmpeg preview generation "
                f"failed with code "
                f"{process.returncode}."
            )
        )

        raise ThumbnailError(
            message
        )

    # ------------------------------------------------------------------
    # FFmpeg filters
    # ------------------------------------------------------------------

    def _scale_filter(
        self,
        width: int,
        height: int,
    ) -> str:
        """
        Fill the requested preview dimensions.

        Aspect ratio is preserved, then excess edges are cropped from
        the center.

        No animated output is produced.
        """

        return (
            f"scale={width}:{height}:"
            "force_original_aspect_ratio=increase,"
            f"crop={width}:{height}"
        )

    # ------------------------------------------------------------------
    # Result
    # ------------------------------------------------------------------

    def _build_result(
        self,
        source: Path,
        media_type: str,
        preview: Path,
        cached: bool,
    ) -> dict[str, Any]:
        return {
            "path": str(source),
            "type": media_type,
            "preview": str(preview),
            "cached": cached,
        }
