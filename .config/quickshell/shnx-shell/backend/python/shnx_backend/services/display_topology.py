from __future__ import annotations

from typing import Any

from shnx_backend.services.display import get_monitors
from shnx_backend.system import hyprland


def _normalise_workspace(
    workspace: dict[str, Any],
) -> dict[str, Any]:
    """
    Convert Hyprland's workspace object into the stable shape
    used by SHNX.

    This function is intentionally read-only.
    """

    workspace_id = workspace.get("id", 0)

    try:
        workspace_id = int(workspace_id)
    except (TypeError, ValueError):
        workspace_id = 0

    name = workspace.get("name", "")

    if not isinstance(name, str):
        name = str(name or "")

    monitor = workspace.get("monitor", "")

    if not isinstance(monitor, str):
        monitor = str(monitor or "")

    windows = workspace.get("windows", 0)

    try:
        windows = int(windows)
    except (TypeError, ValueError):
        windows = 0

    return {
        "id": workspace_id,
        "name": name,
        "monitor": monitor,
        "windows": windows,

        # Keep this explicit because special workspaces must not
        # accidentally enter our normal workspace migration policy.
        "special": (
            workspace_id < 0
            or name == "special"
            or name.startswith("special:")
        ),

        "hasFullscreen": bool(
            workspace.get("hasfullscreen", False)
        ),

        "lastWindow": workspace.get(
            "lastwindow",
            "",
        ),

        "lastWindowTitle": workspace.get(
            "lastwindowtitle",
            "",
        ),
    }


def get_workspaces() -> list[dict[str, Any]]:
    """
    Return all current workspaces with their monitor ownership.

    This is observation only. It never changes Hyprland state.
    """

    raw_workspaces = hyprland.workspaces()

    workspaces = [
        _normalise_workspace(workspace)
        for workspace in raw_workspaces
        if isinstance(workspace, dict)
    ]

    workspaces.sort(
        key=lambda workspace: (
            workspace["special"],
            workspace["id"],
            workspace["name"],
        )
    )

    return workspaces


def get_focused_monitor(
    monitors: list[dict[str, Any]] | None = None,
) -> str:
    """
    Return the monitor Hyprland currently marks as focused.
    """

    if monitors is None:
        monitors = get_monitors()

    for monitor in monitors:
        if not isinstance(monitor, dict):
            continue

        if not monitor.get("enabled", False):
            continue

        if monitor.get("focused", False):
            name = monitor.get("name", "")

            if isinstance(name, str):
                return name

    return ""


def get_active_workspace() -> dict[str, Any]:
    """
    Return the currently focused workspace in SHNX's stable shape.
    """

    workspace = hyprland.active_workspace()

    if not workspace:
        return {}

    return _normalise_workspace(workspace)


def get_workspace_ownership(
    workspaces: list[dict[str, Any]] | None = None,
) -> dict[str, str]:
    """
    Return:

        workspace name -> monitor name

    Example:

        {
            "1": "eDP-1",
            "2": "HDMI-A-1"
        }

    Special workspaces are intentionally excluded.
    """

    if workspaces is None:
        workspaces = get_workspaces()

    ownership: dict[str, str] = {}

    for workspace in workspaces:
        if workspace.get("special", False):
            continue

        name = workspace.get("name", "")
        monitor = workspace.get("monitor", "")

        if not name or not monitor:
            continue

        ownership[str(name)] = str(monitor)

    return ownership


def get_topology_snapshot() -> dict[str, Any]:
    """
    Capture the current display/workspace topology.

    IMPORTANT:
    This function performs queries only.

    It must never:
      - configure a monitor
      - move a workspace
      - focus a workspace
      - focus a monitor
      - write persistent settings
    """

    monitors = get_monitors()
    workspaces = get_workspaces()

    return {
        "focusedMonitor": get_focused_monitor(
            monitors
        ),

        "activeWorkspace": get_active_workspace(),

        "workspaces": workspaces,

        "workspaceOwnership": get_workspace_ownership(
            workspaces
        ),
    }
