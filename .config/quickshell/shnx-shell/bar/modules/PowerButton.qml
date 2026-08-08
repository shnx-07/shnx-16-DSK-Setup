import QtQuick

import qs.theme as ShellTheme
import qs.motion as Motion

Rectangle {
    id: root

    signal clicked()

    implicitWidth:
        38

    implicitHeight:
        32

    antialiasing:
        false

    radius:
        ShellTheme.Theme.radius.button

    color:
        mouseArea.pressed
            ? ShellTheme.Theme.colors.destructiveContainer
            : mouseArea.containsMouse
                ? ShellTheme.Theme.colors.destructive
                : ShellTheme.Theme.colors.errorContainer

    border.width:
        0

    scale:
        mouseArea.pressed
            ? Motion.MotionTokens.compactPressScale
            : mouseArea.containsMouse
                ? Motion.MotionTokens.hoverScale
                : 1.0

    Behavior on color {
        ColorAnimation {
            duration:
                Motion.MotionTokens.quick

            easing.type:
                Motion.Easing.standard
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration:
                Motion.MotionTokens.quick

            easing.type:
                Motion.Easing.standard
        }
    }

    Text {
        anchors.centerIn:
            parent

        text:
            "󰐥"

        color:
            ShellTheme.Theme.colors.on_destructive

        font.family:
            ShellTheme.Theme.typography.iconFontFamily

        font.pixelSize:
            17

        font.weight:
            Font.DemiBold
    }

    MouseArea {
        id: mouseArea

        anchors.fill:
            parent

        hoverEnabled:
            true

        cursorShape:
            Qt.PointingHandCursor

        onClicked:
            root.clicked()
    }
}
