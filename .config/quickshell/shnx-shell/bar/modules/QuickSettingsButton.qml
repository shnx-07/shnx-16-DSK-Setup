import QtQuick
import qs.theme as ShellTheme

Rectangle {
    id: root

    signal clicked()

    implicitWidth: 38
    implicitHeight: 32

    radius: ShellTheme.Theme.radius.button
    antialiasing: false
    color: mouseArea.pressed
        ? ShellTheme.Theme.colors.pressedOverlay
        : mouseArea.containsMouse
            ? ShellTheme.Theme.colors.hoverOverlay
            : ShellTheme.Theme.colors.surfaceContainer

    border.width: 0

    border.color:
        mouseArea.containsMouse
            ? ShellTheme.Theme.colors.outline
            : ShellTheme.Theme.colors.outlineVariant

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
        color: ShellTheme.Theme.colors.on_surface

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
