import QtQuick
import "../../theme" as ThemeSystem

Rectangle {
    id: root

    signal clicked()

    implicitWidth: 38
    implicitHeight: 32

    radius: ThemeSystem.Theme.radius.button

    color: mouseArea.pressed
        ? ThemeSystem.Theme.colors.pressedOverlay
        : mouseArea.containsMouse
            ? ThemeSystem.Theme.colors.hoverOverlay
            : ThemeSystem.Theme.colors.surfaceContainer

    border.width: 1
    border.color: mouseArea.containsMouse
        ? ThemeSystem.Theme.colors.outline
        : ThemeSystem.Theme.colors.outlineVariant

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

        text: "󰣇"
        color: ThemeSystem.Theme.colors.on_surface

        font.pixelSize: 18
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: root.clicked()
    }
}
