import QtQuick

Item {
    id: root

    property var results: []
    property var filesystemResults: []
    property int selectedIndex: -1
    property string query: ""
    property string mode: "universal"

    signal resultActivated(int index, var result)
    signal selectionRequested(int index)

    readonly property int resultCount:
        root.combinedResults.length

    Flickable {
        id: flickable

        anchors.fill: parent
        clip: true
        contentWidth: width
        contentHeight: resultsColumn.implicitHeight
        boundsBehavior: Flickable.StopAtBounds

        visible:
            root.resultCount > 0

        Column {
            id: resultsColumn

            width: flickable.width
            spacing: 3

            Repeater {
                model: root.combinedResults
                delegate: SearchResultDelegate {
                    required property int index
                    required property var modelData

                    width: resultsColumn.width
                    result: modelData
                    resultIndex: index
                    selected: index === root.selectedIndex

                    onActivated: function(resultIndex, resultData) {
                        root.resultActivated(resultIndex, resultData)
                    }

                    onHovered: function(resultIndex) {
                        root.selectionRequested(resultIndex)
                    }
                }
            }
        }
    }


    readonly property var combinedResults: {
        const combined = []

        const apps =
            root.results || []

        const files =
            root.filesystemResults || []

        for (let index = 0; index < apps.length; index++) {
            combined.push(apps[index])
        }

        for (let index = 0; index < files.length; index++) {
            const item = files[index]

            combined.push({
                type: item.type,
                name: item.name || "",
                path: item.path || "",
                comment:
                    item.type === "folder"
                        ? item.path || ""
                        : item.path || "",
                icon:
                    item.type === "folder"
                        ? "folder"
                        : "text-x-generic"
            })
        }

        return combined
    }

    EmptySearchResults {
        anchors.fill: parent
        visible: root.resultCount === 0
        query: root.query
        mode: root.mode
    }

    function ensureSelectedVisible() {
        if (root.selectedIndex < 0)
            return

        const item = resultsColumn.children[root.selectedIndex]
        if (!item)
            return

        const itemTop = item.y
        const itemBottom = item.y + item.height

        if (itemTop < flickable.contentY)
            flickable.contentY = itemTop
        else if (itemBottom > flickable.contentY + flickable.height)
            flickable.contentY = itemBottom - flickable.height
    }

    onSelectedIndexChanged:
        Qt.callLater(ensureSelectedVisible)
}
