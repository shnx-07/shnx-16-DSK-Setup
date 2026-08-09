from __future__ import annotations

from copy import deepcopy
from typing import Any

from shnx_backend.services.display import (
    get_monitors,
)
from shnx_backend.services.input import (
    get_mouse_settings,
)
from shnx_backend.services.persistence import (
    load_system_settings,
    save_system_settings,
)

from shnx_backend.services.display import (
    get_monitor,
    get_monitors,
    set_monitor,
)
from shnx_backend.services.display_topology import (
    get_topology_snapshot,
)
DEFAULT_SETTINGS = {
    "display": {
        "monitors": {},
    },
    "input": {
        "mouse": {
            "sensitivity": 0.0,
            "accelProfile": "adaptive",
        },
    },
}


def _merge_dict(
    base: dict,
    override: dict,
) -> dict:
    result = deepcopy(base)

    for key, value in override.items():
        if (
            isinstance(value, dict)
            and isinstance(
                result.get(key),
                dict,
            )
        ):
            result[key] = _merge_dict(
                result[key],
                value,
            )
        else:
            result[key] = deepcopy(value)

    return result


def get_saved_settings() -> dict:
    saved = load_system_settings()

    return _merge_dict(
        DEFAULT_SETTINGS,
        saved,
    )


def save_monitor_preferences(
    monitor: dict,
) -> None:
    name = monitor.get("name")

    if not name:
        return

    settings = get_saved_settings()

    monitors = settings.setdefault(
        "display",
        {},
    ).setdefault(
        "monitors",
        {},
    )

    monitors[name] = {
        "resolution": monitor.get(
            "resolution",
            "",
        ),
        "refreshRate": monitor.get(
            "refreshRate",
            0.0,
        ),
        "scale": monitor.get(
            "scale",
            1.0,
        ),
        "x": monitor.get(
            "x",
            0,
        ),
        "y": monitor.get(
            "y",
            0,
        ),
        "enabled": monitor.get(
            "enabled",
            True,
        ),
    }

    save_system_settings(
        settings
    )


def save_mouse_preferences(
    mouse: dict,
) -> None:
    settings = get_saved_settings()

    settings.setdefault(
        "input",
        {},
    )["mouse"] = {
        "sensitivity": mouse.get(
            "sensitivity",
            0.0,
        ),
        "accelProfile": mouse.get(
            "accelProfile",
            "adaptive",
        ),
    }

    save_system_settings(
        settings
    )


def sync_runtime_state() -> dict:
    """
    Capture current live Hyprland state while preserving settings
    for monitors that are currently disconnected.
    """

    monitors = get_monitors()
    mouse = get_mouse_settings()

    settings = get_saved_settings()

    display_settings = settings.setdefault(
        "display",
        {},
    )

    monitor_settings = display_settings.setdefault(
        "monitors",
        {},
    )

    for monitor in monitors:
        name = monitor.get("name")

        if not name:
            continue

        monitor_settings[name] = {
            "resolution": monitor.get(
                "resolution",
                "",
            ),
            "refreshRate": monitor.get(
                "refreshRate",
                0.0,
            ),
            "scale": monitor.get(
                "scale",
                1.0,
            ),
            "x": monitor.get(
                "x",
                0,
            ),
            "y": monitor.get(
                "y",
                0,
            ),
            "enabled": monitor.get(
                "enabled",
                True,
            ),
        }

    settings["input"] = {
        "mouse": {
            "sensitivity": mouse.get(
                "sensitivity",
                0.0,
            ),
            "accelProfile": mouse.get(
                "accelProfile",
                "adaptive",
            ),
        },
    }

    save_system_settings(settings)

    return settings


def restore_monitor_preferences(
    name: str,
) -> dict | None:
    """
    Restore saved configuration for one connected monitor.

    Returns None when there are no saved settings for the output.
    """

    if not name:
        return None

    settings = get_saved_settings()

    saved_monitor = (
        settings
        .get("display", {})
        .get("monitors", {})
        .get(name)
    )

    if not isinstance(saved_monitor, dict):
        return None

    current = get_monitor(name)

    if current is None:
        return None

    resolution = saved_monitor.get("resolution")

    refresh_rate = saved_monitor.get(
        "refreshRate"
    )

    scale = saved_monitor.get(
        "scale",
        1.0,
    )

    x = saved_monitor.get("x", 0)
    y = saved_monitor.get("y", 0)

    enabled = saved_monitor.get(
        "enabled",
        True,
    )

    return set_monitor(
        name,
        resolution=resolution or None,
        refresh_rate=refresh_rate,
        scale=scale,
        enabled=enabled,
        position=f"{x}x{y}",
    )


def get_state() -> dict:
    monitors = get_monitors()
    mouse = get_mouse_settings()

    enabled_monitors = [
        monitor
        for monitor in monitors
        if monitor.get(
            "enabled",
            False,
        )
    ]

    topology = get_topology_snapshot()

    return {
        "display": {
            "monitors": monitors,

            "enabledMonitors": [
                monitor["name"]
                for monitor
                in enabled_monitors
            ],

            "monitorCount": len(
                monitors
            ),

            "enabledMonitorCount": len(
                enabled_monitors
            ),

            # Read-only topology state.
            "focusedMonitor": topology[
                "focusedMonitor"
            ],

            "activeWorkspace": topology[
                "activeWorkspace"
            ],

            "workspaces": topology[
                "workspaces"
            ],

            "workspaceOwnership": topology[
                "workspaceOwnership"
            ],
        },

        "input": {
            "mouse": mouse,
        },

        "saved": get_saved_settings(),
    }
