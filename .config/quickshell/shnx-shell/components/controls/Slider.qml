import QtQuick

import "../../theme" as ShellTheme
import "../../motion" as Motion

Item {
    id: root

    signal moved(real value)
    signal valueCommitted(real value)

    property real value: 0.0
    property real from: 0.0
    property real to: 1.0

    property real stepSize: 0.0

    property bool enabled: true

    property real trackHeight: 6
    property real handleSize: 18

    property color trackColor:
        ShellTheme.Theme.colors.surfaceContainerHigh

    property color fillColor:
        ShellTheme.Theme.colors.primary

    property color handleColor:
        ShellTheme.Theme.colors.onPrimary

    readonly property bool pressed:
        dragArea.pressed

    readonly property bool hovered:
        dragArea.containsMouse

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

    implicitWidth: 180

    implicitHeight:
        Math.max(
            root.trackHeight,
            root.handleSize
        )

    opacity:
        root.enabled ? 1.0 : 0.45

    Behavior on opacity {
        NumberAnimation {
            duration:
                Motion.MotionTokens.quick

            easing.type:
                Motion.Easing.standard
        }
    }

    /*
     * TRACK
     */
    Rectangle {
        id: track

        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }

        height:
            root.trackHeight

        radius:
            ShellTheme.Theme.radius.pill

        color:
            root.trackColor
    }

    /*
     * ACTIVE FILL
     */
    Rectangle {
        anchors {
            left: track.left
            top: track.top
            bottom: track.bottom
        }

        width:
            track.width * root.normalizedValue

        radius:
            ShellTheme.Theme.radius.pill

        color:
            root.fillColor
    }

    /*
     * HANDLE
     */
    Rectangle {
        id: handle

        width:
            root.handleSize

        height:
            root.handleSize

        radius:
            ShellTheme.Theme.radius.circle

        color:
            root.fillColor

        x:
            root.normalizedValue
            * Math.max(0, root.width - width)

        anchors.verticalCenter:
            parent.verticalCenter

        scale:
            root.pressed
                ? Motion.MotionTokens.compactPressScale
                : root.hovered
                    ? Motion.MotionTokens.hoverScale
                    : 1.0

        Behavior on scale {
            NumberAnimation {
                duration:
                    Motion.MotionTokens.quick

                easing.type:
                    Motion.Easing.standard
            }
        }

        Behavior on x {
            enabled:
                !root.pressed

            NumberAnimation {
                duration:
                    Motion.MotionTokens.standard

                easing.type:
                    Motion.Easing.standard
            }
        }

        Rectangle {
            anchors.centerIn: parent

            width:
                parent.width * 0.45

            height:
                width

            radius:
                ShellTheme.Theme.radius.circle

            color:
                root.handleColor
        }
    }

    MouseArea {
        id: dragArea

        anchors.fill: parent

        enabled:
            root.enabled

        hoverEnabled:
            true

        cursorShape:
            root.enabled
                ? Qt.PointingHandCursor
                : Qt.ArrowCursor

        function updateValue(mouseX) {
            const usableWidth =
                Math.max(1, root.width)

            let normalized =
                mouseX / usableWidth

            normalized =
                Math.max(
                    0,
                    Math.min(1, normalized)
                )

            let newValue =
                root.from
                + normalized
                * (root.to - root.from)

            /*
             * Optional stepping.
             */
            if (root.stepSize > 0) {
                newValue =
                    Math.round(
                        (newValue - root.from)
                        / root.stepSize
                    )
                    * root.stepSize
                    + root.from
            }

            newValue =
                Math.max(
                    root.from,
                    Math.min(root.to, newValue)
                )

            root.value = newValue
            root.moved(newValue)
        }

        onPressed:
            updateValue(mouse.x)

        onPositionChanged: {
            if (pressed)
                updateValue(mouse.x)
        }

        onReleased:
            root.valueCommitted(root.value)
    }
}
