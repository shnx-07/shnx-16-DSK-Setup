import QtQuick

import qs.core as Core
import qs.theme as ShellTheme
import qs.motion as Motion

Rectangle {
    id: root

    implicitWidth:
        workspaceRow.implicitWidth + 8

    implicitHeight:
        32

    antialiasing:
        false

    radius:
        ShellTheme.Theme.radius.button

    color:
        ShellTheme.Theme.colors.surfaceContainer

    border.width:
        0

    Row {
        id: workspaceRow

        anchors.centerIn:
            parent

        spacing:
            2

        Repeater {
            model:
                Core.ServiceRegistry.hyprland.workspaces

            delegate: Rectangle {
                id: workspaceButton

                required property var modelData

                readonly property bool validWorkspace:
                    modelData
                    && modelData.id > 0

                readonly property bool selected:
                    validWorkspace
                    && modelData.focused

                readonly property bool active:
                    validWorkspace
                    && modelData.active

                readonly property bool urgent:
                    validWorkspace
                    && modelData.urgent

                visible:
                    validWorkspace

                width:
                    visible
                        ? 30
                        : 0

                height:
                    26

                antialiasing:
                    false

                radius:
                    ShellTheme.Theme.radius.small

                color: {
                    if (workspaceButton.urgent)
                        return ShellTheme.Theme.colors.errorContainer

                    if (workspaceButton.selected)
                        return ShellTheme.Theme.colors.surfaceContainerHighest

                    if (workspaceMouse.containsMouse)
                        return ShellTheme.Theme.colors.hoverOverlay

                    return "transparent"
                }

                scale:
                    workspaceMouse.pressed
                        ? Motion.MotionTokens.compactPressScale
                        : workspaceMouse.containsMouse
                            ? Motion.MotionTokens.hoverScale
                            : 1.0

                border.width:
                    workspaceButton.selected || workspaceButton.urgent
                        ? 0.3
                        : 0

                border.color: {
                    if (workspaceButton.urgent)
                        return ShellTheme.Theme.colors.error

                    if (workspaceButton.selected)
                        return ShellTheme.Theme.colors.outline

                    return "transparent"
                }

                Behavior on color {
                    ColorAnimation {
                        duration:
                            Motion.MotionTokens.quick

                        easing.type:
                            Motion.Easing.standard
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration:
                            Motion.MotionTokens.quick

                        easing.type:
                            Motion.Easing.standard
                    }
                }

                Behavior on border.color {
                    ColorAnimation {
                        duration:
                            Motion.MotionTokens.quick

                        easing.type:
                            Motion.Easing.standard
                    }
                }

                Text {
                    anchors.centerIn:
                        parent

                    text:
                        workspaceButton.modelData
                            ? workspaceButton.modelData.name
                            : ""

                    color:
                        workspaceButton.selected
                            ? ShellTheme.Theme.colors.on_surface
                            : ShellTheme.Theme.colors.on_surface_variant

                    font.pixelSize:
                        ShellTheme.Theme.typography.labelMedium

                    font.weight:
                        workspaceButton.selected
                            ? Font.Bold
                            : Font.DemiBold
                }

                MouseArea {
                    id: workspaceMouse

                    anchors.fill:
                        parent

                    hoverEnabled:
                        true

                    cursorShape:
                        Qt.PointingHandCursor

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
