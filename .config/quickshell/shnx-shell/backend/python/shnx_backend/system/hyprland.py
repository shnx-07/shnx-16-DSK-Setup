from __future__ import annotations
import asyncio
import os
from collections.abc import AsyncIterator
from pathlib import Path
import json
import subprocess
from typing import Any


class HyprlandError(RuntimeError):
    """Raised when a hyprctl command fails."""


def _run(
    command: list[str],
    *,
    json_output: bool = False,
    timeout: float = 5.0,
) -> Any:
    try:
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
            timeout=timeout,
            check=False,
        )

    except FileNotFoundError as exc:
        raise HyprlandError(
            f"Command not found: {command[0]}"
        ) from exc

    except subprocess.TimeoutExpired as exc:
        raise HyprlandError(
            f"Command timed out: {' '.join(command)}"
        ) from exc

    if result.returncode != 0:
        error = (
            result.stderr.strip()
            or result.stdout.strip()
            or f"Command exited with {result.returncode}"
        )

        raise HyprlandError(error)

    output = result.stdout.strip()

    if not json_output:
        return output

    if not output:
        return None

    try:
        return json.loads(output)

    except json.JSONDecodeError as exc:
        raise HyprlandError(
            f"Invalid JSON returned: {output}"
        ) from exc


def run(
    *args: str,
    json_output: bool = False,
    timeout: float = 5.0,
) -> Any:
    command = ["hyprctl"]

    if json_output:
        command.append("-j")

    command.extend(str(arg) for arg in args)

    return _run(
        command,
        json_output=json_output,
        timeout=timeout,
    )


def eval_lua(code: str) -> str:
    """
    Execute Lua code inside the running Hyprland instance.

    Example:
        eval_lua(
            'hl.config({ input = { sensitivity = -0.15 } })'
        )
    """

    if not isinstance(code, str) or not code.strip():
        raise ValueError("Lua code cannot be empty")

    return run(
        "eval",
        code,
        json_output=False,
    )


def monitors(
    include_inactive: bool = True,
) -> list[dict]:
    if include_inactive:
        result = run(
            "monitors",
            "all",
            json_output=True,
        )
    else:
        result = run(
            "monitors",
            json_output=True,
        )

    return result if isinstance(result, list) else []

def workspaces() -> list[dict]:
    """
    Return all currently known Hyprland workspaces.

    Read-only operation.
    """

    result = run(
        "workspaces",
        json_output=True,
    )

    return result if isinstance(result, list) else []


def active_workspace() -> dict:
    """
    Return the currently focused/active Hyprland workspace.

    Read-only operation.
    """

    result = run(
        "activeworkspace",
        json_output=True,
    )

    return result if isinstance(result, dict) else {}

def get_option(option: str) -> dict:
    option = option.replace(":", ".")

    result = run(
        "getoption",
        option,
        json_output=True,
    )

    return result if isinstance(result, dict) else {}


def set_input(
    *,
    sensitivity: float | None = None,
    accel_profile: str | None = None,
) -> str:
    values: list[str] = []

    if sensitivity is not None:
        values.append(
            f"sensitivity = {float(sensitivity):g}"
        )

    if accel_profile is not None:
        escaped = (
            str(accel_profile)
            .replace("\\", "\\\\")
            .replace('"', '\\"')
        )

        values.append(
            f'accel_profile = "{escaped}"'
        )

    if not values:
        raise ValueError(
            "At least one input setting is required"
        )

    lua = (
        "hl.config({ input = { "
        + ", ".join(values)
        + " } })"
    )

    return eval_lua(lua)


def configure_monitor(
    *,
    output: str,
    mode: str = "preferred",
    position: str = "auto",
    scale: float = 1.0,
    disabled: bool = False,
) -> str:
    if not output:
        raise ValueError(
            "Monitor output cannot be empty"
        )

    escaped_output = (
        output
        .replace("\\", "\\\\")
        .replace('"', '\\"')
    )

    if disabled:
        lua = (
            "hl.monitor({ "
            f'output = "{escaped_output}", '
            "disabled = true "
            "})"
        )

        return eval_lua(lua)

    escaped_mode = (
        mode
        .replace("\\", "\\\\")
        .replace('"', '\\"')
    )

    escaped_position = (
        position
        .replace("\\", "\\\\")
        .replace('"', '\\"')
    )

    lua = (
        "hl.monitor({ "
        f'output = "{escaped_output}", '
        f'mode = "{escaped_mode}", '
        f'position = "{escaped_position}", '
        f"scale = {float(scale):g}, "
        "disabled = false "
        "})"
    )

    return eval_lua(lua)

def event_socket_path() -> Path:
    runtime_directory = os.environ.get(
        "XDG_RUNTIME_DIR"
    )

    instance_signature = os.environ.get(
        "HYPRLAND_INSTANCE_SIGNATURE"
    )

    if not runtime_directory:
        raise HyprlandError(
            "XDG_RUNTIME_DIR is not set"
        )

    if not instance_signature:
        raise HyprlandError(
            "HYPRLAND_INSTANCE_SIGNATURE is not set"
        )

    return (
        Path(runtime_directory)
        / "hypr"
        / instance_signature
        / ".socket2.sock"
    )


async def events() -> AsyncIterator[
    tuple[str, str]
]:
    """
    Yield Hyprland socket2 events as:

        (event_name, event_data)
    """

    socket_path = event_socket_path()

    reader, writer = await asyncio.open_unix_connection(
        str(socket_path)
    )

    try:
        while True:
            raw_line = await reader.readline()

            if not raw_line:
                break

            line = raw_line.decode(
                "utf-8",
                errors="replace",
            ).rstrip("\n")

            if ">>" not in line:
                continue

            event_name, event_data = line.split(
                ">>",
                1,
            )

            yield (
                event_name.strip(),
                event_data.strip(),
            )

    finally:
        writer.close()

        try:
            await writer.wait_closed()
        except Exception:
            pass
