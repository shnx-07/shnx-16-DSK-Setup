from __future__ import annotations

import os
import shutil
import subprocess
from datetime import datetime
from pathlib import Path
from typing import Optional


class ScreenshotError(RuntimeError):
    pass


class ScreenshotService:
    def __init__(self) -> None:
        self._save_dir = self._get_screenshot_directory()
        self._save_dir.mkdir(parents=True, exist_ok=True)
        self._clipboard_process: Optional[subprocess.Popen] = None

    # ---------------------------------------------------------
    # PATHS
    # ---------------------------------------------------------

    @staticmethod
    def _get_screenshot_directory() -> Path:
        """
        Resolve the user's Pictures directory and append Screenshots.

        Falls back to ~/Pictures/Screenshots.
        """
        pictures_dir: Optional[Path] = None

        if shutil.which("xdg-user-dir"):
            try:
                result = subprocess.run(
                    ["xdg-user-dir", "PICTURES"],
                    capture_output=True,
                    text=True,
                    timeout=2,
                    check=False,
                )

                value = result.stdout.strip()

                if value:
                    pictures_dir = Path(value).expanduser()

            except (OSError, subprocess.SubprocessError):
                pass

        if pictures_dir is None:
            pictures_dir = Path.home() / "Pictures"

        return pictures_dir / "Screenshots"

    def _new_filename(self) -> Path:
        timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
        return self._save_dir / f"Screenshot_{timestamp}.png"

    # ---------------------------------------------------------
    # DEPENDENCIES
    # ---------------------------------------------------------

    @staticmethod
    def _require(command: str) -> None:
        if shutil.which(command) is None:
            raise ScreenshotError(
                f"Required command is not installed: {command}"
            )

    def _check_dependencies(self) -> None:
        self._require("grim")
        self._require("wl-copy")

    # ---------------------------------------------------------
    # CLIPBOARD
    # ---------------------------------------------------------

    def _copy_to_clipboard(self, path: Path) -> None:
        try:
            image_data = path.read_bytes()

            if self._clipboard_process is not None:
                if self._clipboard_process.poll() is None:
                    self._clipboard_process.terminate()

                self._clipboard_process = None

            process = subprocess.Popen(
                [
                    "wl-copy",
                    "--foreground",
                    "--type",
                    "image/png",
                ],
                stdin=subprocess.PIPE,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )

            if process.stdin is None:
                process.kill()
                raise ScreenshotError("Could not open wl-copy stdin")

            process.stdin.write(image_data)
            process.stdin.close()

            self._clipboard_process = process

        except OSError as exc:
            raise ScreenshotError(
                f"Could not copy screenshot to clipboard: {exc}"
            ) from exc

    # ---------------------------------------------------------
    # FULL SCREENSHOT
    # ---------------------------------------------------------

    def capture_full(
        self,
        output: Optional[str] = None,
    ) -> dict:
        """
        Capture a full monitor.

        output:
            Hyprland monitor/output name such as:
                eDP-1
                HDMI-A-1

        When output is None, grim uses its normal full-output behaviour.
        """

        self._check_dependencies()

        destination = self._new_filename()

        command = ["grim"]

        if output:
            command.extend(["-o", output])

        command.append(str(destination))

        result = subprocess.run(
            command,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.PIPE,
            text=True,
            check=False,
        )

        if result.returncode != 0:
            destination.unlink(missing_ok=True)

            raise ScreenshotError(
                result.stderr.strip()
                or "grim failed to capture the screen"
            )

        if not destination.exists() or destination.stat().st_size == 0:
            destination.unlink(missing_ok=True)
            raise ScreenshotError("Screenshot file was empty")

        self._copy_to_clipboard(destination)

        return {
            "success": True,
            "type": "full",
            "path": str(destination),
            "output": output,
        }

    # ---------------------------------------------------------
    # SNIPPING SCREENSHOT
    # ---------------------------------------------------------

    def capture_region(
        self,
        geometry: str,
    ) -> dict:
        """
        Capture an already-selected Wayland geometry.

        Expected format:
            "x,y WIDTHxHEIGHT"

        Example:
            "500,300 800x500"

        QML will eventually produce this geometry.
        """

        self._check_dependencies()

        geometry = geometry.strip()

        if not geometry:
            raise ScreenshotError("Screenshot geometry is empty")

        destination = self._new_filename()

        result = subprocess.run(
            [
                "grim",
                "-g",
                geometry,
                str(destination),
            ],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.PIPE,
            text=True,
            check=False,
        )

        if result.returncode != 0:
            destination.unlink(missing_ok=True)

            raise ScreenshotError(
                result.stderr.strip()
                or "grim failed to capture selected region"
            )

        if not destination.exists() or destination.stat().st_size == 0:
            destination.unlink(missing_ok=True)
            raise ScreenshotError("Screenshot file was empty")

        self._copy_to_clipboard(destination)

        return {
            "success": True,
            "type": "region",
            "path": str(destination),
            "geometry": geometry,
        }


# Optional module-level instance for simple importing.
screenshot_service = ScreenshotService()
