import QtQuick

import "../../theme" as ShellTheme
import "../../motion" as Motion

Item {
    id: root

    property real value: 0.0
    property real from: 0.0
    property real to: 1.0

    property real thickness: 6

    property color trackColor:
        ShellTheme.Theme.colors.surfaceContainerHigh

    property color progressColor:
        ShellTheme.Theme.colors.primary

    property real radius:
        ShellTheme.Theme.radius.pill

    readonly property real normalizedValue: {
        const range = root.to - root.from

        if (range <= 0)
            return 0

        return Math.max(
            0,
            Math.min(
                1,
                (root.value - root.from) / range
            )
        )
    }

    implicitWidth: 160
    implicitHeight: thickness

    Rectangle {
        anchors.fill: parent

        radius:
            root.radius

        color:
            root.trackColor
    }

    Rectangle {
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }

        width:
            parent.width * root.normalizedValue

        radius:
            root.radius

        color:
            root.progressColor

        Behavior on width {
            NumberAnimation {
                duration:
                    Motion.MotionTokens.standard

                easing.type:
                    Motion.Easing.standard
            }
        }
    }
}
