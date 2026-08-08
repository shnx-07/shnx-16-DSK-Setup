import QtQuick
import "../../core" as Core
import "panelModules" as PanelModules
import "../../theme" as ShellTheme

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
     * New optional service reference. Leave null until ServiceRegistry
     * wiring is known. Existing clock behavior does not depend on it.
     */
    property var searchService:
        Core.ServiceRegistry.search

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

        function onActivePanelChanged() {
            if (Core.IslandController.searchActive)
                Qt.callLater(searchModule.activate)
        }

        function onSearchModeChanged() {
            if (Core.IslandController.searchActive)
                Qt.callLater(searchModule.activate)
        }
    }

    width: expandedWidth
    height: expandedHeight

    focus: false

    // =============================================================
    // Public actions — existing actions preserved
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
    if (Core.IslandController.searchActive) {
        searchModule.activate()
        return
    }

    root.forceActiveFocus()
}

    // New additive actions.
    function openSearch() {
        Core.IslandController.openUniversalSearch()
    }

    function openCommandSearch() {
        Core.IslandController.openCommandSearch()
    }

    function toggleSearch() {
        Core.IslandController.toggleSearch()
    }

    function toggleCommandSearch() {
        Core.IslandController.toggleCommandSearch()
    }

    // =============================================================
    // Keyboard dismissal
    // =============================================================

    Keys.onEscapePressed: function(event) {
        if (!root.expanded)
            return

        /*
         * SearchField owns Escape while it has input focus:
         * first Escape clears text, second Escape requests close.
         * This handler remains as the fallback for clock/other modules.
         */
        if (Core.IslandController.searchActive)
            return

        root.closeIsland()
        event.accepted = true
    }

    Keys.onPressed: function(event) {
        if (!root.expanded)
            return

        if (event.key === Qt.Key_Escape
                && !Core.IslandController.searchActive) {
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
            ? ShellTheme.Theme.radius.island
            : root.compactHeight / 2

        color: ShellTheme.Theme.colors.background
        antialiasing: false
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
        // Expanded content
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

            PanelModules.DynamicPanelSearch {
                id: searchModule
                anchors.fill: parent

                visible: Core.IslandController.searchActive
                enabled: visible

                searchService: root.searchService
                mode: Core.IslandController.searchMode

                onCloseRequested:
                    Core.IslandController.closeIsland()
            }
        }
    }
}

