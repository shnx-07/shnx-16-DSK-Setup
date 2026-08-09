from __future__ import annotations

import re
from typing import Any

from shnx_backend.system import hyprland


_MODE_RE = re.compile(
    r"^(?P<width>\d+)x(?P<height>\d+)@(?P<hz>[\d.]+)(?:Hz)?$"
)


def _parse_mode(mode: str) -> dict[str, Any] | None:
    """
    Convert:

        2560x1440@143.99899Hz

    into:

        {
            "resolution": "2560x1440",
            "width": 2560,
            "height": 1440,
            "hz": 144.0
        }
    """

    if not isinstance(mode, str):
        return None

    match = _MODE_RE.match(mode.strip())

    if not match:
        return None

    width = int(match.group("width"))
    height = int(match.group("height"))
    hz = round(float(match.group("hz")), 2)

    return {
        "resolution": f"{width}x{height}",
        "width": width,
        "height": height,
        "hz": hz,
    }


def _parse_available_modes(raw_modes: list[str]) -> list[dict]:
    modes: list[dict] = []
    seen: set[tuple[int, int, float]] = set()

    for raw_mode in raw_modes:
        mode = _parse_mode(raw_mode)

        if mode is None:
            continue

        key = (
            mode["width"],
            mode["height"],
            mode["hz"],
        )

        if key in seen:
            continue

        seen.add(key)
        modes.append(mode)

    modes.sort(
        key=lambda item: (
            -item["width"],
            -item["height"],
            -item["hz"],
        )
    )

    return modes


def _monitor_enabled(monitor: dict) -> bool:
    """
    Hyprland monitor JSON may expose disabled directly.

    Keep this isolated here so we can adapt if Hyprland's JSON
    representation changes later.
    """

    return not bool(monitor.get("disabled", False))


def get_monitors() -> list[dict]:
    raw_monitors = hyprland.monitors(include_inactive=True)

    monitors: list[dict] = []

    for monitor in raw_monitors:
        width = int(monitor.get("width", 0) or 0)
        height = int(monitor.get("height", 0) or 0)

        available_modes = _parse_available_modes(
            monitor.get("availableModes", []) or []
        )

        monitors.append(
            {
                "id": monitor.get("id"),
                "name": monitor.get("name", ""),
                "description": monitor.get("description", ""),
                "make": monitor.get("make", ""),
                "model": monitor.get("model", ""),
                "serial": monitor.get("serial", ""),

                "enabled": _monitor_enabled(monitor),
                "focused": bool(monitor.get("focused", False)),

                "width": width,
                "height": height,
                "resolution": (
                    f"{width}x{height}"
                    if width > 0 and height > 0
                    else ""
                ),

                "refreshRate": round(
                    float(monitor.get("refreshRate", 0.0) or 0.0),
                    2,
                ),

                "scale": round(
                    float(monitor.get("scale", 1.0) or 1.0),
                    2,
                ),

                "x": int(monitor.get("x", 0) or 0),
                "y": int(monitor.get("y", 0) or 0),

                "workspace": (
                    monitor.get("activeWorkspace", {}) or {}
                ).get("name", ""),

                "availableModes": available_modes,
            }
        )

    return monitors


def get_monitor(name: str) -> dict | None:
    for monitor in get_monitors():
        if monitor["name"] == name:
            return monitor

    return None


def get_enabled_monitors() -> list[dict]:
    return [
        monitor
        for monitor in get_monitors()
        if monitor["enabled"]
    ]


def set_monitor(
    name: str,
    *,
    resolution: str | None = None,
    refresh_rate: float | None = None,
    scale: float = 1.0,
    enabled: bool = True,
    position: str | None = None,
) -> dict:
    if not name:
        raise ValueError("Monitor name cannot be empty")

    current = get_monitor(name)
    if not enabled:
        monitors = get_monitors()

        enabled_monitors = [
            monitor
            for monitor in monitors
            if monitor.get(
                "enabled",
                False,
            )
        ]

        enabled_names = {
            monitor["name"]
            for monitor
            in enabled_monitors
        }

        if (
            name in enabled_names
            and len(enabled_names) <= 1
        ):
            raise ValueError(
                "Cannot disable the last enabled monitor"
            )

    if not enabled:
        hyprland.configure_monitor(
            output=name,
            disabled=True,
        )

        return {
            "success": True,
            "name": name,
            "enabled": False,
        }

    if resolution:
        mode = resolution

        if refresh_rate is not None:
            mode += f"@{float(refresh_rate):g}"
    else:
        mode = "preferred"

    if position is None:
        if current and current["enabled"]:
            position = f"{current['x']}x{current['y']}"
        else:
            position = "auto"

    scale = max(
        0.5,
        min(4.0, float(scale)),
    )

    hyprland.configure_monitor(
        output=name,
        mode=mode,
        position=position,
        scale=scale,
        disabled=False,
    )

    return {
        "success": True,
        "name": name,
        "enabled": True,
        "mode": mode,
        "position": position,
        "scale": scale,
    }
