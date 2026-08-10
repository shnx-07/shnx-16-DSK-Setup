import QtQuick
import qs.theme as ShellTheme

Rectangle {
    id: root

    signal clicked()

    implicitWidth: 150
    implicitHeight: 108

    radius: ShellTheme.Theme.radius.large

    color:
        mouseArea.pressed
            ? ShellTheme.Theme.colors.pressedOverlay
            : mouseArea.containsMouse
                ? ShellTheme.Theme.colors.hoverOverlay
                : ShellTheme.Theme.colors.surfaceContainer

    border.width: 1
    border.color:
        mouseArea.containsMouse
            ? ShellTheme.Theme.colors.outline
            : ShellTheme.Theme.colors.outlineVariant

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
            color: ShellTheme.Theme.colors.on_surface

            font.pixelSize: 29
            font.family: "JetBrainsMono Nerd Font"
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter

            text: "Applications"
            color: ShellTheme.Theme.colors.on_surface

            font.pixelSize: ShellTheme.Theme.typography.bodySmall
            font.weight: Font.DemiBold
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter

            text: "Open launcher  ›"
            color: ShellTheme.Theme.colors.on_surface_variant

            font.pixelSize: ShellTheme.Theme.typography.labelSmall
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
