import QtQuick

Item {
    id: root

    property string query: ""
    property string mode: "universal"

    Column {
        anchors.centerIn: parent
        spacing: 8

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.mode === "command" ? "󰆍" : "󰍉"
            color: "#777777"
            font.pixelSize: 24
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter

            text:
                root.query.length > 0
                    ? "No results"
                    : root.mode === "command"
                        ? "Start typing a command"
                        : "Start typing to search"

            color: "#a0a0a0"
            font.pixelSize: 12
        }
    }
}
