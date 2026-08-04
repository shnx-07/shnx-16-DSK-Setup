import QtQuick

Rectangle {
    id: root

    signal clicked()

    implicitWidth: 38
    implicitHeight: 32

    radius: 10

    color: mouseArea.pressed
        ? "#343944"
        : mouseArea.containsMouse
            ? "#2d323c"
            : "#252932"

    border.width: 1

    border.color:
        mouseArea.containsMouse
            ? "#596273"
            : "#3b414d"

    Behavior on color {
        ColorAnimation {
            duration: 120
        }
    }

    Behavior on border.color {
        ColorAnimation {
            duration: 120
        }
    }

    Text {
        anchors.centerIn: parent

        text: "󰒓"
        color: "#f2f3f5"

        font.pixelSize: 17
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true

        cursorShape:
            Qt.PointingHandCursor

        onClicked:
            root.clicked()
    }
}
