import QtQuick
import "../../core" as Core
import "panelModules" as PanelModules

Item {
    id: root

    // =============================================================
    // Public state and geometry
    // =============================================================
    
    readonly property bool expanded:
       Core.IslandController.expanded

    property int compactWidth: 150
    property int compactHeight: 34

    property int expandedWidth: 700
    property int expandedHeight: 380

    /*
     * Bar.qml uses these values for the animated input mask.
     * Do not remove or rename them.
     */
    readonly property real inputX: islandSurface.x
    readonly property real inputY: islandSurface.y
    readonly property real inputWidth: islandSurface.width
    readonly property real inputHeight: islandSurface.height

    signal opened()
    signal closed()

    Connections {
        target: Core.IslandController

        function onExpandedChanged() {
            if (Core.IslandController.expanded)
                root.opened()
            else
                root.closed()
        }
    }

    width: expandedWidth
    height: expandedHeight

    focus: false

    // =============================================================
    // Public actions
    // =============================================================

    function openIsland() {
        Core.IslandController.openClock()
    }

    function closeIsland() {
        Core.IslandController.closeIsland()
    }

    function toggleIsland() {
        Core.IslandController.toggleClock()
    }

    function takeKeyboardFocus() {
        root.forceActiveFocus()
    }

    // =============================================================
    // Keyboard dismissal
    // =============================================================

    Keys.onEscapePressed: function(event) {
        if (!root.expanded)
            return

        root.closeIsland()
        event.accepted = true
    }

    Keys.onPressed: function(event) {
        if (!root.expanded)
            return

        if (event.key === Qt.Key_Escape) {
            root.closeIsland()
            event.accepted = true
        }
    }

   

    // =============================================================
    // Visible Dynamic Island surface
    // =============================================================

    Rectangle {
        id: islandSurface

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        width: root.expanded
            ? root.expandedWidth
            : root.compactWidth

        height: root.expanded
            ? root.expandedHeight
            : root.compactHeight

        radius: root.expanded
            ? 28
            : root.compactHeight / 2

        color: "#050608"

        border.width: 0
        clip: true

        Behavior on width {
            NumberAnimation {
                duration: 280
                easing.type: Easing.OutCubic
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: 320
                easing.type: Easing.OutCubic
            }
        }

        Behavior on radius {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }

        

        // =========================================================
        // Compact trigger content
        // =========================================================

        Item {
            id: compactContent

            anchors.fill: parent

            visible: opacity > 0
            enabled: !root.expanded

            opacity: root.expanded ? 0 : 1

            Behavior on opacity {
                NumberAnimation {
                    duration: root.expanded ? 90 : 170
                    easing.type: Easing.OutCubic
                }
            }

            IslandTriggerRow {
                anchors.fill: parent
            }
        }


        // =========================================================
        // Expanded Clock | Calendar content
        // =========================================================

        Item {
            id: expandedContent

            anchors.fill: parent

            visible: opacity > 0
            enabled: root.expanded

            opacity: root.expanded ? 1 : 0
            scale: root.expanded ? 1 : 0.985

            Behavior on opacity {
                NumberAnimation {
                    duration: root.expanded ? 190 : 100
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: root.expanded ? 220 : 110
                    easing.type: Easing.OutCubic
                }
            }

            PanelModules.DynamicPanelClock {
                anchors.fill: parent

                visible: Core.IslandController.clockActive
            }
        }
    }
}
