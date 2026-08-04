import QtQuick

Rectangle {
    id: root

    signal clicked()

    implicitWidth: 38
    implicitHeight: 32

    radius: 10

    color: mouseArea.pressed
        ? "#a8333e"
        : mouseArea.containsMouse
            ? "#c94752"
            : "#b83b46"

    border.width: 1
    border.color: mouseArea.containsMouse
        ? "#ff8a92"
        : "#d85c66"

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

        text: "󰐥"
        color: "#ffffff"

        font.pixelSize: 17
        font.weight: Font.DemiBold
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: root.clicked()
    }
}
