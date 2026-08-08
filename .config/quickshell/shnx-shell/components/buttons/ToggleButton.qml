import QtQuick

import "../../theme" as ShellTheme
import "../../motion" as Motion

Item {
    id: root

    signal toggled(bool checked)
    signal clicked()

    property bool checked: false
    property bool enabled: true

    property string text: ""

    property real horizontalPadding:
        ShellTheme.Theme.spacing.medium

    property real verticalPadding:
        ShellTheme.Theme.spacing.small

    readonly property bool hovered:
        mouseArea.containsMouse

    readonly property bool pressed:
        mouseArea.pressed

    readonly property color backgroundColor: {
        if (!root.enabled)
            return ShellTheme.Theme.colors.surfaceContainer

        if (root.checked)
            return ShellTheme.Theme.colors.primary

        if (root.pressed)
            return ShellTheme.Theme.colors.surfaceContainerHighest

        if (root.hovered)
            return ShellTheme.Theme.colors.surfaceContainerHigh

        return ShellTheme.Theme.colors.surfaceContainer
    }

    readonly property color foregroundColor: {
        if (!root.enabled)
            return ShellTheme.Theme.colors.onSurfaceVariant

        if (root.checked)
            return ShellTheme.Theme.colors.onPrimary

        return ShellTheme.Theme.colors.onSurface
    }

    implicitWidth:
        label.implicitWidth
        + root.horizontalPadding * 2

    implicitHeight:
        label.implicitHeight
        + root.verticalPadding * 2

    scale:
        root.pressed
            ? Motion.MotionTokens.pressScale
            : 1.0

    opacity:
        root.enabled ? 1.0 : 0.45

    Behavior on scale {
        NumberAnimation {
            duration:
                Motion.MotionTokens.quick

            easing.type:
                Motion.Easing.standard
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration:
                Motion.MotionTokens.quick

            easing.type:
                Motion.Easing.standard
        }
    }

    Rectangle {
        anchors.fill: parent

        radius:
            ShellTheme.Theme.radius.control

        color:
            root.backgroundColor

        Behavior on color {
            ColorAnimation {
                duration:
                    Motion.MotionTokens.standard

                easing.type:
                    Motion.Easing.standard
            }
        }
    }

    Text {
        id: label

        anchors.centerIn: parent

        text:
            root.text

        color:
            root.foregroundColor

        font.family:
            ShellTheme.Theme.typography.fontFamily

        font.pixelSize:
            ShellTheme.Theme.typography.labelLarge

        font.weight:
            root.checked
                ? Font.DemiBold
                : Font.Medium

        verticalAlignment:
            Text.AlignVCenter
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent

        enabled:
            root.enabled

        hoverEnabled:
            true

        cursorShape:
            root.enabled
                ? Qt.PointingHandCursor
                : Qt.ArrowCursor

        onClicked: {
            root.checked = !root.checked

            root.clicked()
            root.toggled(root.checked)
        }
    }
}
