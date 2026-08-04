import QtQuick

Rectangle {
    id: root

    signal clicked()

    implicitWidth: 150
    implicitHeight: 108

    radius: 17

    color:
        mouseArea.pressed
            ? "#384454"
            : mouseArea.containsMouse
                ? "#303a48"
                : "#28313d"

    border.width: 1
    border.color:
        mouseArea.containsMouse
            ? "#607086"
            : "#344151"

    Behavior on color {
        ColorAnimation {
            duration: 130
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: 100
        }
    }

    scale:
        mouseArea.pressed
            ? 0.97
            : 1.0

    Column {
        anchors.centerIn: parent
        spacing: 9

        Text {
            anchors.horizontalCenter: parent.horizontalCenter

            text: "󰀻"
            color: "#eef2f7"

            font.pixelSize: 29
            font.family: "JetBrainsMono Nerd Font"
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter

            text: "Applications"
            color: "#eef2f7"

            font.pixelSize: 13
            font.weight: Font.DemiBold
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter

            text: "Open launcher  ›"
            color: "#99a5b5"

            font.pixelSize: 10
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent

        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            root.clicked()
        }
    }
}
