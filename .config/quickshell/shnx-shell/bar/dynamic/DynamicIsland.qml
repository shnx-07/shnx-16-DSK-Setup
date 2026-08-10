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

    property int recordingCompactWidth: 190
    property int recordingHoverWidth: 245

    readonly property int effectiveCompactWidth: {
        if (!root.recordingActive)
            return root.compactWidth

        if (recordingContent.hovered)
            return root.recordingHoverWidth

        return root.recordingCompactWidth
    }

    property var screen: null

    property int expandedWidth: 700
    property int expandedHeight: 380

    /*
     * New optional service reference. Leave null until ServiceRegistry
     * wiring is known. Existing clock behavior does not depend on it.
     */
    property var searchService:
        Core.ServiceRegistry.search



    property var captureService:
        Core.ServiceRegistry.capture

    readonly property bool recordingActive:
        captureService
        && captureService.recordingActive

    readonly property bool recordingPaused:
        captureService
        && captureService.recordingPaused

    readonly property int recordingSeconds:
        captureService
        ? captureService.recordingElapsed
        : 0

    function recordingTimeText() {
        const minutes = Math.floor(
            recordingSeconds / 60
        )

        const seconds =
            recordingSeconds % 60

        return String(minutes).padStart(2, "0")
            + ":"
            + String(seconds).padStart(2, "0")
    }

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
            : root.effectiveCompactWidth

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

            opacity:
                root.expanded
                ? 0
                : 1

            Behavior on opacity {
                NumberAnimation {
                    duration:
                        root.expanded
                        ? 90
                        : 170

                    easing.type:
                        Easing.OutCubic
                }
            }

            // =========================================================
            // Normal island content
            // =========================================================

            IslandTriggerRow {
                anchors.fill: parent

                visible:
                    !root.recordingActive
                    && recordingContent.opacity <= 0.01

                enabled:
                    visible
            }

            // =========================================================
            // Active screen recording
            // =========================================================

            Item {
                id: recordingContent

                anchors.fill: parent

                visible:
                  opacity > 0

                enabled:
                  root.recordingActive

                property bool hovered: false

                opacity:
                    root.recordingActive
                    ? 1
                    : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 160
                        easing.type: Easing.OutCubic
                    }
                }



                Row {
                    anchors.centerIn: parent

                    spacing: 9

                    // -------------------------------------------------
                    // Recording indicator
                    // -------------------------------------------------

                    Rectangle {
                        id: recordingDot

                        width: 8
                        height: 8
                        radius: 4

                        anchors.verticalCenter:
                            parent.verticalCenter

                        color:
                            ShellTheme.Theme.colors.error

                        opacity:
                            root.recordingPaused
                            ? 0.45
                            : 1

                        scale:
                            root.recordingPaused
                            ? 0.8
                            : 1

                        Behavior on scale {
                            NumberAnimation {
                                duration: 160
                                easing.type: Easing.OutCubic
                            }
                        }

                        SequentialAnimation on opacity {
                            running:
                                root.recordingActive
                                && !root.recordingPaused
                                && !recordingContent.hovered

                            loops:
                                Animation.Infinite

                            NumberAnimation {
                                to: 0.35
                                duration: 700
                                easing.type:
                                    Easing.InOutSine
                            }

                            NumberAnimation {
                                to: 1
                                duration: 700
                                easing.type:
                                    Easing.InOutSine
                            }
                        }
                    }

                    // -------------------------------------------------
                    // Timer
                    // -------------------------------------------------

                    Text {
                        anchors.verticalCenter:
                            parent.verticalCenter

                        text:
                            root.recordingTimeText()

                        color:
                          root.recordingPaused
                          ? ShellTheme.Theme.colors.secondaryText
                          : ShellTheme.Theme.colors.text

                        font.pixelSize: 13
                        font.weight: Font.Medium
                    }

                    // -------------------------------------------------
                    // Hover controls
                    // -------------------------------------------------

                    Row {
                        spacing: 5

                        anchors.verticalCenter:
                            parent.verticalCenter

                        opacity:
                            recordingContent.hovered
                            ? 1
                            : 0

                        scale:
                            recordingContent.hovered
                            ? 1
                            : 0.92

                        enabled:
                            recordingContent.hovered

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 140
                                easing.type: Easing.OutCubic
                            }
                        }

                        Behavior on scale {
                            NumberAnimation {
                                duration: 160
                                easing.type: Easing.OutCubic
                            }
                        }

                        Rectangle {
                            width: 25
                            height: 25
                            radius: 13

                            color:
                                pauseMouse.containsMouse
                                ? ShellTheme.Theme.colors.elevatedSurface
                                : "transparent"

                            Text {
                                anchors.centerIn: parent

                                text:
                                    root.recordingPaused
                                    ? "▶"
                                    : "Ⅱ"

                                color:
                                    ShellTheme.Theme.colors.text

                                font.pixelSize: 11
                            }

                            MouseArea {
                                id: pauseMouse

                                anchors.fill: parent
                                hoverEnabled: true

                                onClicked: {
                                    if (
                                        root.recordingPaused
                                    ) {
                                        root.captureService
                                            .resumeRecording()
                                    } else {
                                        root.captureService
                                            .pauseRecording()
                                    }
                                }
                            }
                        }

                        Rectangle {
                            width: 25
                            height: 25
                            radius: 13

                            color:
                                stopMouse.containsMouse
                                ? ShellTheme.Theme.colors.elevatedSurface
                                : "transparent"

                            Text {
                                anchors.centerIn: parent

                                text: "■"

                                color:
                                    ShellTheme.Theme.colors.error

                                font.pixelSize: 10
                            }

                            MouseArea {
                                id: stopMouse

                                anchors.fill: parent
                                hoverEnabled: true

                                onClicked:
                                    root.captureService
                                        .stopRecording()
                            }
                        }
                    }
                }

                HoverHandler {
                    onHoveredChanged:
                        recordingContent.hovered =
                            hovered
                }
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

