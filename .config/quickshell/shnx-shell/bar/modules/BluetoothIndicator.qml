import QtQuick

import qs.core as Core
import qs.theme as ShellTheme
import qs.motion as Motion

Rectangle {
    id: root

    signal clicked()

    readonly property var bluetooth:
        Core.ServiceRegistry.bluetooth

    implicitWidth:
        contentRow.implicitWidth + 20

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

    Row {
        id: contentRow

        anchors.centerIn:
            parent

        spacing:
            7

        Text {
            text:
                bluetooth.icon

            color: {
                if (!bluetooth.available || !bluetooth.enabled)
                    return ShellTheme.Theme.colors.disabled

                if (bluetooth.connected)
                    return ShellTheme.Theme.colors.primary

                return ShellTheme.Theme.colors.on_surface
            }

            font.pixelSize:
                17
        }

        Text {
            visible:
                bluetooth.connected

            text: {
                if (bluetooth.connectedDeviceCount > 1)
                    return bluetooth.connectedDeviceCount.toString()

                return bluetooth.primaryDeviceName
            }

            width:
                visible
                    ? Math.min(implicitWidth, 120)
                    : 0

            color:
                ShellTheme.Theme.colors.on_surface

            font.pixelSize:
                ShellTheme.Theme.typography.labelMedium

            font.weight:
                Font.DemiBold

            elide:
                Text.ElideRight

            maximumLineCount:
                1

            wrapMode:
                Text.NoWrap
        }

        Text {
            visible:
                bluetooth.connectedDeviceCount === 1
                && bluetooth.primaryDeviceHasBattery

            text:
                bluetooth.primaryDeviceBattery + "%"

            color:
                ShellTheme.Theme.colors.on_surface_variant

            font.pixelSize:
                ShellTheme.Theme.typography.labelSmall

            font.weight:
                Font.Medium
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
