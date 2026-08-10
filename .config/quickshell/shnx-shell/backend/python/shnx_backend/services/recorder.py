from __future__ import annotations

import os
import signal
import subprocess
import time
from datetime import datetime
from pathlib import Path
from typing import Optional


class RecorderError(RuntimeError):
    pass


class RecorderService:
    def __init__(self) -> None:
        self._process: Optional[subprocess.Popen] = None
        self._output_path: Optional[Path] = None

        self._paused = False

        # Recording timing state.
        self._started_at: Optional[float] = None
        self._pause_started_at: Optional[float] = None
        self._paused_seconds: float = 0.0

    @property
    def active(self) -> bool:
        return (
            self._process is not None
            and self._process.poll() is None
        )

    @property
    def paused(self) -> bool:
        return self._paused if self.active else False

    def _recordings_dir(self) -> Path:
        path = Path.home() / "Videos" / "Recordings"
        path.mkdir(parents=True, exist_ok=True)
        return path

    def _new_output_path(self) -> Path:
        timestamp = datetime.now().strftime(
            "%Y-%m-%d_%H-%M-%S"
        )

        return (
            self._recordings_dir()
            / f"Recording_{timestamp}.mp4"
        )

    def _elapsed_seconds(self) -> int:
        if not self.active or self._started_at is None:
            return 0

        now = time.monotonic()

        paused_seconds = self._paused_seconds

        if (
            self._paused
            and self._pause_started_at is not None
        ):
            paused_seconds += (
                now - self._pause_started_at
            )

        elapsed = (
            now
            - self._started_at
            - paused_seconds
        )

        return max(0, int(elapsed))

    def start(self, output: str) -> dict:
        if self.active:
            raise RecorderError(
                "Screen recording is already active"
            )

        if not output:
            raise RecorderError(
                "Monitor output is required"
            )

        destination = self._new_output_path()

        command = [
            "gpu-screen-recorder",
            "-w",
            output,
            "-f",
            "60",
            "-k",
            "h264",
            "-o",
            str(destination),
        ]

        try:
            process = subprocess.Popen(
                command,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.PIPE,
                start_new_session=True,
            )
        except OSError as exc:
            raise RecorderError(
                f"Could not start recorder: {exc}"
            ) from exc

        self._process = process
        self._output_path = destination

        self._paused = False
        self._started_at = time.monotonic()
        self._pause_started_at = None
        self._paused_seconds = 0.0

        return self.status()

    def pause(self) -> dict:
        if not self.active or self._process is None:
            raise RecorderError(
                "No active screen recording"
            )

        if self._paused:
            return self.status()

        os.kill(
            self._process.pid,
            signal.SIGUSR2,
        )

        self._paused = True
        self._pause_started_at = time.monotonic()

        return self.status()

    def resume(self) -> dict:
        if not self.active or self._process is None:
            raise RecorderError(
                "No active screen recording"
            )

        if not self._paused:
            return self.status()

        os.kill(
            self._process.pid,
            signal.SIGUSR2,
        )

        if self._pause_started_at is not None:
            self._paused_seconds += (
                time.monotonic()
                - self._pause_started_at
            )

        self._pause_started_at = None
        self._paused = False

        return self.status()

    def stop(self) -> dict:
        if not self.active or self._process is None:
            raise RecorderError(
                "No active screen recording"
            )

        process = self._process
        output_path = self._output_path

        final_elapsed = self._elapsed_seconds()

        try:
            os.kill(
                process.pid,
                signal.SIGINT,
            )

            process.wait(timeout=10)

        except subprocess.TimeoutExpired:
            process.terminate()

            try:
                process.wait(timeout=3)
            except subprocess.TimeoutExpired:
                process.kill()

        finally:
            self._process = None
            self._paused = False
            self._output_path = None

            self._started_at = None
            self._pause_started_at = None
            self._paused_seconds = 0.0

        return {
            "success": True,
            "active": False,
            "paused": False,
            "elapsed": final_elapsed,
            "path": (
                str(output_path)
                if output_path is not None
                else ""
            ),
            "pid": None,
        }

    def status(self) -> dict:
        return {
            "success": True,
            "active": self.active,
            "paused": self.paused,
            "elapsed": self._elapsed_seconds(),
            "path": (
                str(self._output_path)
                if self._output_path is not None
                else ""
            ),
            "pid": (
                self._process.pid
                if self.active
                and self._process is not None
                else None
            ),
        }


recorder_service = RecorderService()
