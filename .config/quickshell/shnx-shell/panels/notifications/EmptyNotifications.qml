import QtQuick

Item {
    id: root

    implicitHeight: 230

    Column {
        anchors.centerIn: parent
        spacing: 12

        Text {
            anchors.horizontalCenter:
                parent.horizontalCenter

            text: "󰂜"
            color: "#8e949e"

            font.pixelSize: 42
        }

        Text {
            anchors.horizontalCenter:
                parent.horizontalCenter

            text: "No notifications"
            color: "#f2f3f5"

            font.pixelSize: 16
            font.weight: Font.DemiBold
        }

        Text {
            anchors.horizontalCenter:
                parent.horizontalCenter

            text: "New notifications will appear here"
            color: "#8e949e"

            font.pixelSize: 12
        }
    }
}
