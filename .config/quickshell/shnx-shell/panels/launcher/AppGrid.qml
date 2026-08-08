import QtQuick
import QtQuick.Controls
import Quickshell
import qs.core as Core
import qs.theme as ShellTheme

Rectangle {
    id: root

    signal applicationLaunched()

    implicitWidth: 540
    implicitHeight: 520

    radius: ShellTheme.Theme.radius.card
    color: ShellTheme.Theme.colors.surfaceContainer

    border.width: 1
    border.color: ShellTheme.Theme.colors.outlineVariant

    property int selectedIndex: 0

    readonly property var search:
        Core.ServiceRegistry.search

    readonly property var applications:
        search.filteredApplications

    readonly property int applicationCount:
        applications.length

    ScriptModel {
        id: applicationsModel

        values: root.applications
        objectProp: "desktopId"
    }

    GridView {
        id: gridView

        anchors.fill: parent
        anchors.margins: 12

        clip: true
        boundsBehavior: Flickable.StopAtBounds

        cellWidth: 142
        cellHeight: 122

        model: applicationsModel

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

            width: 132
            height: 112

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

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
        }
    }

    EmptyResults {
        anchors.centerIn: parent

        visible:
            root.applicationCount === 0

        query:
            root.search.query

        category:
            root.search.selectedCategory
    }

    function resetSelection() {
        root.selectedIndex = 0

        gridView.currentIndex =
            root.applicationCount > 0
                ? 0
                : -1

        if (root.applicationCount > 0)
            gridView.positionViewAtBeginning()
    }

    function moveSelection(delta) {
        if (root.applicationCount === 0)
            return

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
        const columnCount =
            Math.max(
                1,
                Math.floor(
                    gridView.width
                    / gridView.cellWidth
                )
            )

        root.moveSelection(
            delta * columnCount
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
        target: root.search

        function onQueryChanged() {
            root.resetSelection()
        }

        function onSelectedCategoryChanged() {
            root.resetSelection()
        }
    }
}
