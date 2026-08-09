import QtQuick

import Quickshell
import Quickshell.Wayland

import qs.core as Core
import qs.theme as ShellTheme

import "../../components/layout" as Layout
import "./display" as Display
import "./input" as Input

PanelWindow {
    id: root

    visible:
        Core.PanelController.systemPanelOpen

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color:
        "transparent"

    exclusionMode:
        ExclusionMode.Ignore

    aboveWindows: true
    focusable: true

    /*
     * Dimmed desktop backdrop.
     */
    Rectangle {
        anchors.fill:
            parent

        color:
            ShellTheme.Theme.colors.scrim

        opacity: 0.38

        MouseArea {
            anchors.fill:
                parent

            onClicked:
                Core.PanelController.close()
        }
    }

    /*
     * Main settings surface.
     */
    Layout.Surface {
        id: panelSurface

        width:
            Math.min(
                580,
                Math.max(
                    360,
                    parent.width
                    - ShellTheme.Theme.spacing.large * 2
                )
            )

        height:
            Math.min(
                720,
                Math.max(
                    480,
                    parent.height
                    - ShellTheme.Theme.spacing.xxxLarge * 2
                )
            )

        anchors.centerIn:
            parent

        backgroundColor:
            ShellTheme.Theme.colors.surfaceContainer

        borderWidth: 1

        MouseArea {
            anchors.fill:
                parent

            /*
             * Prevent clicks inside the panel from reaching
             * the backdrop MouseArea.
             */
            acceptedButtons:
                Qt.LeftButton
                | Qt.RightButton
                | Qt.MiddleButton

            propagateComposedEvents:
                false
        }

        Column {
            anchors.fill:
                parent

            Layout.PanelHeader {
                width:
                    parent.width

                title:
                    "Display & Input"

                subtitle:
                    "Monitor and pointer settings"

                showBackButton:
                    false

                showCloseButton:
                    true

                onCloseRequested:
                    Core.PanelController.close()
            }

            Layout.Divider {
                width:
                    parent.width
            }

            Flickable {
                id: flickable

                width:
                    parent.width

                height:
                    Math.max(
                        0,
                        parent.height
                        - y
                    )

                contentWidth:
                    width

                contentHeight:
                    contentColumn.implicitHeight
                    + ShellTheme.Theme.spacing.large * 2

                clip:
                    true

                boundsBehavior:
                    Flickable.StopAtBounds

                Column {
                    id: contentColumn

                    x:
                        ShellTheme.Theme.spacing.large

                    y:
                        ShellTheme.Theme.spacing.large

                    width:
                        Math.max(
                            0,
                            flickable.width
                            - ShellTheme.Theme.spacing.large * 2
                        )

                    spacing:
                        ShellTheme.Theme.spacing.large

                    Display.DisplaySection {
                        width:
                            parent.width
                    }

                    Layout.Divider {
                        width:
                            parent.width
                    }

                    Input.InputSection {
                        width:
                            parent.width
                    }
                }
            }
        }
    }

    /*
     * ESC closes the panel.
     */
    Shortcut {
        enabled:
            root.visible

        sequence:
            "Escape"

        onActivated:
            Core.PanelController.close()
    }

    onVisibleChanged: {
        if (!visible)
            return

        Core.ServiceRegistry.display.refresh()
        Core.ServiceRegistry.input.refresh()
    }
}
