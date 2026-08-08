import QtQuick

import qs.theme as ShellTheme
import qs.motion as Motion
import qs.components.visual as Visual

Rectangle {
    id: root

    signal clicked()

    implicitWidth: 38
    implicitHeight: 32

    antialiasing: false

    radius:
        ShellTheme.Theme.radius.button

    color:
        mouseArea.pressed
            ? ShellTheme.Theme.colors.pressedOverlay
            : mouseArea.containsMouse
                ? ShellTheme.Theme.colors.hoverOverlay
                : ShellTheme.Theme.colors.surfaceContainer

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

    Visual.Icon {
        anchors.centerIn:
            parent

        anchors.horizontalCenterOffset:
            -2

        glyph:
            "󰣇"

        iconSize:
            18

        color:
            ShellTheme.Theme.colors.on_surface
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
