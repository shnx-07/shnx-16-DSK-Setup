import QtQuick

import "../../../panels/search" as Search

Item {
    id: root

    property var searchService: null
    property string mode: "universal"

    signal closeRequested()
    signal resultLaunched(var result)

    Search.SearchPanel {
        id: searchPanel
        anchors.fill: parent

        searchService: root.searchService
        mode: root.mode

        onCloseRequested:
            root.closeRequested()

        onResultLaunched: function(result) {
            root.resultLaunched(result)
        }
    }

    function activate() {
        searchPanel.activate()
    }

    function clear() {
        searchPanel.clear()
    }
}

