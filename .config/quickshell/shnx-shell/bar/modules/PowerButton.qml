import QtQuick
import qs.theme as ShellTheme

Rectangle {
    id: root

    signal clicked()

    implicitWidth: 38
    implicitHeight: 32

    radius: ShellTheme.Theme.radius.button

    color: mouseArea.pressed
        ? ShellTheme.Theme.colors.destructiveContainer
        : mouseArea.containsMouse
            ? ShellTheme.Theme.colors.destructive
            : ShellTheme.Theme.colors.errorContainer

    border.width: 1
    border.color: mouseArea.containsMouse
        ? ShellTheme.Theme.colors.on_destructive_container
        : ShellTheme.Theme.colors.error

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
        color: ShellTheme.Theme.colors.on_destructive

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
