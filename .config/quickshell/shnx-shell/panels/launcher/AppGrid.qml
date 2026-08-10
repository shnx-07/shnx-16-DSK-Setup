import QtQuick
import QtQuick.Controls
import Quickshell

import qs.core as Core
import qs.theme as ShellTheme
import qs.motion as Motion

Rectangle {
    id: root

    signal applicationLaunched()

    implicitWidth:
        560

    implicitHeight:
        520

    antialiasing:
        false

    radius:
        ShellTheme.Theme.radius.card

    color:
        ShellTheme.Theme.colors.surfaceContainer

    border.width:
        0

    property int selectedIndex:
        0

    readonly property var search:
        Core.ServiceRegistry.search

    readonly property var applications:
        search.filteredApplications

    readonly property int applicationCount:
        applications.length

    ScriptModel {
        id: applicationsModel

        values:
            root.applications

        objectProp:
            "desktopId"
    }

    GridView {
        id: gridView

        anchors.fill:
            parent

        anchors.margins:
            ShellTheme.Theme.spacing.small

        clip:
            true

        boundsBehavior:
            Flickable.StopAtBounds

        interactive:
            true

        readonly property int columnCount:
            3

        cellWidth:
            width / columnCount

        cellHeight:
            120

        model:
            applicationsModel

        currentIndex:
            root.applicationCount > 0
                ? Math.min(
                    root.selectedIndex,
                    root.applicationCount - 1
                )
                : -1

        delegate: AppDelegate {
            required property int index
            required property var modelData

            width:
                gridView.cellWidth
                - ShellTheme.Theme.spacing.small

            height:
                110

            appName:
                modelData.name

            appIcon:
                modelData.icon.length > 0
                    ? "image://icon/" + modelData.icon
                    : ""

            appComment:
                modelData.comment

            desktopId:
                modelData.desktopId

            selected:
                index === gridView.currentIndex

            onLaunched: {
                root.launchIndex(index)
            }
        }

        /*
         * --------------------------------------------------------
         * SMOOTH WHEEL SCROLLING
         * --------------------------------------------------------
         */

         

        NumberAnimation {
            id: smoothScroll

            target:
                gridView

            property:
                "contentY"

            duration:
                Motion.MotionTokens.emphasized

            easing.type:
                Motion.Easing.standard
        }

        /*
         * --------------------------------------------------------
         * SCROLLBAR
         * --------------------------------------------------------
         */

        ScrollBar.vertical: ScrollBar {
            id: verticalScrollBar

            policy:
                ScrollBar.AsNeeded

            width:
                4

            contentItem: Rectangle {
                implicitWidth:
                    4

                radius:
                    2

                color:
                    ShellTheme.Theme.colors.outline

                opacity:
                    verticalScrollBar.active
                        ? 0.7
                        : 0.35

                Behavior on opacity {
                    NumberAnimation {
                        duration:
                            Motion.MotionTokens.quick

                        easing.type:
                            Motion.Easing.standard
                    }
                }
            }

            background:
                Item {
            }
        }
    }

    EmptyResults {
        anchors.centerIn:
            parent

        visible:
            root.applicationCount === 0

        query:
            root.search.query

        category:
            root.search.selectedCategory
    }

    function resetSelection() {
        root.selectedIndex =
            0

        gridView.currentIndex =
            root.applicationCount > 0
                ? 0
                : -1

        if (root.applicationCount > 0) {
            gridView.positionViewAtBeginning()
        }
    }

    function moveSelection(delta) {
        if (root.applicationCount === 0) {
            return
        }

        root.selectedIndex =
            Math.max(
                0,
                Math.min(
                    root.applicationCount - 1,
                    root.selectedIndex + delta
                )
            )

        gridView.currentIndex =
            root.selectedIndex

        gridView.positionViewAtIndex(
            root.selectedIndex,
            GridView.Contain
        )
    }

    function moveSelectionByRow(delta) {
        root.moveSelection(
            delta * gridView.columnCount
        )
    }

    function launchIndex(index) {
        if (index < 0
                || index >= root.applicationCount) {
            return
        }

        const application =
            root.applications[index]

        if (!application
                || !application.entry) {
            return
        }

        root.search.launch(
            application.entry
        )

        Core.PanelController.close()

        root.applicationLaunched()
    }

    function launchSelected() {
        root.launchIndex(
            root.selectedIndex
        )
    }

    Connections {
        target:
            root.search

        function onQueryChanged() {
            root.resetSelection()
        }

        function onSelectedCategoryChanged() {
            root.resetSelection()
        }
    }
}
