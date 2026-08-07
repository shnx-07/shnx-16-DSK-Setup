import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

import qs.core as Core
import qs.theme as ShellTheme

Scope {
    id: root

    readonly property int windowHeight: 132
    readonly property int bottomMargin: 22

    Variants {
      model: Quickshell.screens


        delegate: Component {
            Scope {
                id: screenScope

                required property var modelData

                readonly property var screenMonitor:
                    Core.ServiceRegistry.hyprland.monitorForScreen(modelData)

                readonly property bool isFocusedMonitor: {
                    const focusedMonitor =
                        Core.ServiceRegistry.hyprland.focusedMonitor

                    if (!focusedMonitor)
                        return modelData === Quickshell.screens[0]

                    return screenMonitor === focusedMonitor
                }

                readonly property bool dockVisible:
                    Core.UtilityDockController.open
                    && isFocusedMonitor

                PanelWindow {
                    id: dockWindow

                    screen: screenScope.modelData
                    visible: screenScope.dockVisible

                    anchors {
                        left: true
                        right: true
                        bottom: true
                    }

                    implicitHeight: root.windowHeight

                    color: "transparent"
                    exclusionMode: ExclusionMode.Ignore
                    aboveWindows: true
                    focusable: screenScope.dockVisible

                    WlrLayershell.layer: WlrLayer.Overlay
                    WlrLayershell.namespace: "shnx-utility-dock"

                    mask: Region {
                        x: Math.round(dockSurface.x)
                        y: Math.round(dockSurface.y)
                        width: Math.round(dockSurface.width)
                        height: Math.round(dockSurface.height)
                    }

                    FocusScope {
                        id: dockFocus

                        anchors.fill: parent
                        focus: screenScope.dockVisible

                        UtilityDockSurface {
                            id: dockSurface

                            anchors {
                                horizontalCenter: parent.horizontalCenter
                                bottom: parent.bottom
                                bottomMargin: root.bottomMargin
                            }

                            expanded: screenScope.dockVisible
                        }

                        Repeater {
                            id: dockRepeater

                            parent: dockSurface.contentItem
                            model: Core.UtilityDockController.items

                            delegate: UtilityDockItem {
                                required property var modelData
                                required property int index

                                route: modelData.route
                                label: modelData.label
                                iconName: modelData.icon

                                selected:
                                    Core.UtilityDockController.selectedIndex
                                    === index

                                active: false

                                onHovered: {
                                    Core.UtilityDockController.select(index)
                                }

                                onActivated: function(anchorItem) {
                                    Core.UtilityDockController.select(index)

                                    if (modelData.route === "wallpaper") {
                                        Core.UtilityDockController.hide()
                                        Core.PanelController.openWallpaper()
                                        return
                                    }

                                    if (modelData.route === "appearance") {
                                        Core.UtilityDockController.hide()
                                        Core.PanelController.openAppearance()
                                        return
                                    }

                                    if (modelData.route === "appLauncher") {
                                        Core.UtilityDockController.hide()
                                        Core.PanelController.openAppLauncher()
                                        return
                                    }

                                    Core.UtilityDockController.activateSelected()
                                }

                            }
                        }

                        Keys.onPressed: function(event) {
                            if (!screenScope.dockVisible)
                                return

                            switch (event.key) {
                            case Qt.Key_Left:
                                Core.UtilityDockController.movePrevious()
                                event.accepted = true
                                break

                            case Qt.Key_Right:
                                Core.UtilityDockController.moveNext()
                                event.accepted = true
                                break

                            case Qt.Key_Home:
                                Core.UtilityDockController.selectFirst()
                                event.accepted = true
                                break

                            case Qt.Key_End:
                                Core.UtilityDockController.selectLast()
                                event.accepted = true
                                break

                            case Qt.Key_Return:
                            case Qt.Key_Enter:
                            case Qt.Key_Space:
                                Core.UtilityDockController.activateSelected()
                                event.accepted = true
                                break

                            case Qt.Key_Escape:
                                Core.UtilityDockController.hide()
                                event.accepted = true
                                break
                            }
                        }
                    }






                    onVisibleChanged: {
                        if (visible) {
                            Qt.callLater(function() {
                                dockFocus.forceActiveFocus()
                            })
                        }
                    }
                }

                /*
                 * Outside-click dismissal remains temporarily disabled while
                 * confirming the rebuilt dock visuals and interaction.
                 */
                HyprlandFocusGrab {
                    id: dockFocusGrab

                    active: screenScope.dockVisible
                    windows: [dockWindow]

                    onCleared: {
                        if (Core.UtilityDockController.open)
                            Core.UtilityDockController.hide()
                    }
                }

                Component.onDestruction: {
                    dockFocusGrab.active = false
                }
            }
        }
    }
}
