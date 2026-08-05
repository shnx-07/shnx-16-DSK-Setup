import QtQuick

import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

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
        model: Quickshell.screens

        delegate: Component {
            Scope {
                id: screenScope

                required property var modelData

                // =====================================================
                // Main bar window
                // =====================================================

                PanelWindow {
                    id: barWindow

                    screen: screenScope.modelData

                    anchors {
                        top: true
                        left: true
                        right: true
                    }

                    implicitHeight: root.barHeight
                    exclusiveZone: root.barHeight

                    aboveWindows: true
                    focusable: false

                    color: "transparent"

                    Item {
                        anchors.fill: parent

                        anchors.leftMargin: 10
                        anchors.rightMargin: 10

                        Modules.LeftSection {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Modules.RightSection {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                // =====================================================
                // Dynamic Island window
                // =====================================================

                PanelWindow {
                    id: islandWindow

                    screen: screenScope.modelData

                    anchors {
                        top: true
                    }

                    margins {
                        top: Math.round(
                            (root.barHeight - root.islandCompactHeight) / 2
                        )
                    }

                    implicitWidth: root.islandExpandedWidth
                    implicitHeight: root.islandExpandedHeight

                    exclusionMode: ExclusionMode.Ignore

                    aboveWindows: true
                    focusable: island.expanded

                    color: "transparent"

                    WlrLayershell.layer: WlrLayer.Overlay
                    WlrLayershell.namespace: "shnx-dynamic-island"

                    /*
                    * Only the visible, animated island shape accepts input.
                    * Everything outside this region passes through.
                    */
                    mask: Region {
                        x: Math.round(island.inputX)
                        y: Math.round(island.inputY)

                        width: Math.round(island.inputWidth)
                        height: Math.round(island.inputHeight)
                    }

                    Dynamic.DynamicIsland {
                        id: island

                        anchors.fill: parent

                        compactWidth: root.islandCompactWidth
                        compactHeight: root.islandCompactHeight

                        expandedWidth: root.islandExpandedWidth
                        expandedHeight: root.islandExpandedHeight

                        onExpandedChanged: {
                            islandFocusGrab.active = expanded

                            if (expanded) {
                                Qt.callLater(function() {
                                    island.takeKeyboardFocus()
                                })
                            }
                        }
                    }
                }


                // =====================================================
                // Outside-click and focus management
                // =====================================================

                HyprlandFocusGrab {
                    id: islandFocusGrab

                    /*
                     * Clicking either of these windows is considered
                     * an inside click:
                     *
                     * - the regular bar
                     * - the Dynamic Island
                     *
                     * Therefore clicking bar modules does not dismiss
                     * the island.
                     */
                    windows: [
                        barWindow,
                        islandWindow
                    ]

                    onCleared: {
                        /*
                         * The grab is cleared when the user clicks
                         * outside both listed windows.
                         */
                        if (island.expanded)
                            island.closeIsland()
                    }
                }

                Component.onDestruction: {
                    islandFocusGrab.active = false
                }
            }
        }
    }
}
