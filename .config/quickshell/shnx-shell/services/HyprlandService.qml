import QtQuick
import Quickshell.Hyprland

QtObject {
    id: root

    readonly property var workspaces: Hyprland.workspaces
    readonly property var focusedWorkspace: Hyprland.focusedWorkspace
    readonly property var focusedMonitor: Hyprland.focusedMonitor
    readonly property var activeToplevel: Hyprland.activeToplevel

    readonly property bool activeWindowIsOnFocusedWorkspace: {
        const toplevel = activeToplevel
        const workspace = focusedWorkspace

        if (!toplevel || !workspace || !toplevel.workspace)
            return false

        return toplevel.workspace.id === workspace.id
    }

    readonly property string activeWindowTitle: {
        const toplevel = activeToplevel

        if (!activeWindowIsOnFocusedWorkspace)
            return ""

        if (toplevel.title && toplevel.title.length > 0)
            return toplevel.title

        if (toplevel.wayland
                && toplevel.wayland.appId
                && toplevel.wayland.appId.length > 0) {
            return toplevel.wayland.appId
        }

        return ""
    }

    readonly property string activeWindowAppId: {
        const toplevel = activeToplevel

        if (!activeWindowIsOnFocusedWorkspace || !toplevel.wayland)
            return ""

        return toplevel.wayland.appId ?? ""
    }

    function activateWorkspace(workspace) {
        if (workspace)
            workspace.activate()
    }

    function refreshWorkspaces() {
        Hyprland.refreshWorkspaces()
    }

    function refreshToplevels() {
        Hyprland.refreshToplevels()
    }
}
