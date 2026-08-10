import QtQuick

import qs.core as Core
import qs.theme as ShellTheme
import qs.motion as Motion

Rectangle {
    id: root

    signal clicked()

    readonly property var battery:
        Core.ServiceRegistry.battery

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
        battery.critical
            ? 1
            : 0

    border.color:
        battery.critical
            ? ShellTheme.Theme.colors.error
            : "transparent"

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
                battery.icon

            color: {
                if (battery.critical)
                    return ShellTheme.Theme.colors.error

                if (battery.low)
                    return ShellTheme.Theme.colors.warning

                if (battery.charging)
                    return ShellTheme.Theme.colors.success

                return ShellTheme.Theme.colors.on_surface
            }

            font.pixelSize:
                17
        }

        Text {
            text:
                battery.available
                    ? battery.percentage + "%"
                    : "--"

            color:
                ShellTheme.Theme.colors.on_surface

            font.pixelSize:
                ShellTheme.Theme.typography.labelMedium

            font.weight:
                Font.DemiBold
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
