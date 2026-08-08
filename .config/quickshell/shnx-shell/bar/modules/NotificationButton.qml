import QtQuick

import qs.core as Core
import qs.theme as ShellTheme
import qs.motion as Motion

Rectangle {
    id: root

    signal clicked()

    readonly property var notificationService:
        Core.ServiceRegistry.notifications

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

    Text {
        anchors.centerIn:
            parent

        text:
            notificationService.doNotDisturb
                ? "󰂛"
                : notificationService.hasUnread
                    ? "󰂚"
                    : "󰂜"

        color:
            notificationService.hasUnread
                ? ShellTheme.Theme.colors.on_surface
                : ShellTheme.Theme.colors.on_surface_variant

        font.family:
            ShellTheme.Theme.typography.iconFontFamily

        font.pixelSize:
            17

        font.weight:
            Font.DemiBold
    }

    Rectangle {
        visible:
            notificationService.hasUnread

        anchors {
            top:
                parent.top

            right:
                parent.right

            topMargin:
                -4

            rightMargin:
                -5
        }

        implicitWidth:
            Math.max(
                16,
                badgeLabel.implicitWidth + 8
            )

        implicitHeight:
            16

        antialiasing:
            false

        radius:
            ShellTheme.Theme.radius.pill

        color:
            ShellTheme.Theme.colors.error

        border.width:
            0

        Text {
            id: badgeLabel

            anchors.centerIn:
                parent

            text:
                notificationService.badgeText

            color:
                ShellTheme.Theme.colors.on_error

            font.pixelSize:
                9

            font.weight:
                Font.Bold
        }
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
