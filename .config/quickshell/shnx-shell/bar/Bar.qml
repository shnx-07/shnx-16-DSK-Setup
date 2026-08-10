import QtQuick

import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

import "../core" as Core
import "modules" as Modules
import "dynamic" as Dynamic

Scope {
    id: root

    readonly property int barHeight: 44

    readonly property int islandCompactWidth: 150
    readonly property int islandCompactHeight: 34

    readonly property int islandExpandedWidth: 700
    readonly property int islandExpandedHeight: 380

    Variants {
        model:
            Quickshell.screens

        delegate: Component {
            Scope {
                id: screenScope

                required property var modelData

                readonly property var hyprlandMonitor:
                    Core.ServiceRegistry.hyprland.monitorForScreen(
                        screenScope.modelData
                    )

                readonly property var activeWorkspace:
                    screenScope.hyprlandMonitor
                        ? screenScope.hyprlandMonitor.activeWorkspace
                        : null

                readonly property bool hasFullscreenWindow:
                    screenScope.activeWorkspace
                        ? screenScope.activeWorkspace.hasFullscreen
                        : false

                /*
                 * ----------------------------------------------------
                 * TOP BAR
                 * ----------------------------------------------------
                 */

                PanelWindow {
                      id: barWindow

                      visible:
                          !screenScope.hasFullscreenWindow

                      screen:
                          screenScope.modelData

                      anchors {
                          top: true
                          left: true
                          right: true
                      }

                      implicitHeight:
                          root.barHeight

                      exclusiveZone:
                          root.barHeight

                      aboveWindows:
                          true

                      focusable:
                          false

                      color:
                          Qt.rgba(0, 0, 0, 0)

                      WlrLayershell.layer:
                          WlrLayer.Top

                      WlrLayershell.namespace:
                          "shnx-bar"

                      Item {
                          anchors {
                              fill: parent
                              leftMargin: 10
                              rightMargin: 10
                          }

                          Modules.LeftSection {
                              anchors {
                                  left: parent.left
                                  verticalCenter: parent.verticalCenter
                              }
                          }

                          Modules.RightSection {
                              anchors {
                                  right: parent.right
                                  verticalCenter: parent.verticalCenter
                              }
                          }
                      }
                  }                /*
                 * ----------------------------------------------------
                 * DYNAMIC ISLAND
                 * ----------------------------------------------------
                 */

                PanelWindow {
                    id: islandWindow

                    screen:
                        screenScope.modelData

                    visible:
                        !screenScope.hasFullscreenWindow

                    anchors {
                        top: true
                    }

                    margins {
                        top:
                            Math.round(
                                (
                                    root.barHeight
                                    - root.islandCompactHeight
                                ) / 2
                            )
                    }

                    implicitWidth:
                        root.islandExpandedWidth

                    implicitHeight:
                        root.islandExpandedHeight

                    exclusionMode:
                        ExclusionMode.Ignore

                    aboveWindows: true

                    focusable:
                        island.expanded

                    color:
                        "transparent"

                    WlrLayershell.layer:
                        WlrLayer.Overlay

                    WlrLayershell.namespace:
                        "shnx-dynamic-island"

                    /*
                     * Only the visible island geometry accepts input.
                     * Everything outside the animated shape passes
                     * through to windows below.
                     */
                    mask: Region {
                        x:
                            Math.round(
                                island.inputX
                            )

                        y:
                            Math.round(
                                island.inputY
                            )

                        width:
                            Math.round(
                                island.inputWidth
                            )

                        height:
                            Math.round(
                                island.inputHeight
                            )
                    }

                    Dynamic.DynamicIsland {
                        id: island

                        anchors.fill: parent

                        screen:
                            screenScope.modelData

                        compactWidth:
                            root.islandCompactWidth

                        compactHeight:
                            root.islandCompactHeight

                        expandedWidth:
                            root.islandExpandedWidth

                        expandedHeight:
                            root.islandExpandedHeight

                        onExpandedChanged: {
                            islandFocusGrab.active =
                                expanded

                            if (expanded) {
                                Qt.callLater(
                                    function() {
                                        island.takeKeyboardFocus()
                                    }
                                )
                            }
                        }
                    }
                }

                /*
                 * ----------------------------------------------------
                 * FOCUS / OUTSIDE CLICK
                 * ----------------------------------------------------
                 */

                HyprlandFocusGrab {
                    id: islandFocusGrab

                    windows: [
                        barWindow,
                        islandWindow
                    ]

                    onCleared: {
                        if (island.expanded) {
                            island.closeIsland()
                        }
                    }
                }

                /*
                 * ----------------------------------------------------
                 * FULLSCREEN
                 * ----------------------------------------------------
                 */

                Connections {
                    target:
                        screenScope

                    function onHasFullscreenWindowChanged() {
                        if (
                            !screenScope.hasFullscreenWindow
                        ) {
                            return
                        }

                        islandFocusGrab.active =
                            false

                        if (island.expanded) {
                            island.closeIsland()
                        }
                    }
                }

                Component.onDestruction: {
                    islandFocusGrab.active =
                        false
                }
            }
        }
    }
}
