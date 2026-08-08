import QtQuick
import qs.core as Core
import qs.theme as ShellTheme

Rectangle {
    id: root

    implicitWidth: workspaceRow.implicitWidth + 8
    implicitHeight: 32

    radius: ShellTheme.Theme.radius.button

    color: ShellTheme.Theme.colors.surfaceContainer

    border.width: 1
    border.color: ShellTheme.Theme.colors.outlineVariant

    Row {
        id: workspaceRow

        anchors.centerIn: parent
        spacing: 2

        Repeater {
            model: Core.ServiceRegistry.hyprland.workspaces

            delegate: Rectangle {
                id: workspaceButton

                required property var modelData

                readonly property bool validWorkspace:
                    modelData && modelData.id > 0

                readonly property bool selected:
                    validWorkspace && modelData.focused

                readonly property bool active:
                    validWorkspace && modelData.active

                readonly property bool urgent:
                    validWorkspace && modelData.urgent

                visible: validWorkspace

                width: visible ? 30 : 0
                height: 26

                radius: ShellTheme.Theme.radius.small

                color: {
                    if (urgent)
                        return ShellTheme.Theme.colors.errorContainer

                    if (selected)
                        return ShellTheme.Theme.colors.surfaceContainerHighest

                    if (workspaceMouse.containsMouse)
                        return ShellTheme.Theme.colors.hoverOverlay

                    return "transparent"
                }

                border.width:
                    selected || urgent
                        ? 1
                        : 0

                border.color: {
                    if (urgent)
                        return ShellTheme.Theme.colors.error

                    if (selected)
                        return ShellTheme.Theme.colors.outline

                    return "transparent"
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 120
                    }
                }

                Behavior on border.color {
                    ColorAnimation {
                        duration: 120
                    }
                }

                Text {
                    anchors.centerIn: parent

                    text: workspaceButton.modelData
                        ? workspaceButton.modelData.name
                        : ""

                    color: workspaceButton.selected
                        ? ShellTheme.Theme.colors.on_surface
                        : ShellTheme.Theme.colors.on_surface_variant

                    font.pixelSize: ShellTheme.Theme.typography.labelMedium

                    font.weight:
                        workspaceButton.selected
                            ? Font.Bold
                            : Font.DemiBold
                }

                MouseArea {
                    id: workspaceMouse

                    anchors.fill: parent

                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        Core.ServiceRegistry.hyprland
                            .activateWorkspace(
                                workspaceButton.modelData
                            )
                    }
                }
            }
        }
    }
}
