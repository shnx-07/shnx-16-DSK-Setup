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

    property real horizontalPadding: 14
    property real verticalPadding: 7

    readonly property bool hovered:
        mouseArea.containsMouse

    readonly property bool pressed:
        mouseArea.pressed

    readonly property color backgroundColor: {
        if (!root.enabled)
            return ShellTheme.Theme.colors.surfaceContainerLow

        if (root.checked)
            return ShellTheme.Theme.colors.primary

        if (root.pressed)
            return ShellTheme.Theme.colors.selectedOverlay

        if (root.hovered)
            return ShellTheme.Theme.colors.hoverOverlay

        return ShellTheme.Theme.colors.surfaceContainerHigh
    }

    readonly property color foregroundColor: {
        if (!root.enabled)
            return ShellTheme.Theme.colors.on_surface_variant

        if (root.checked)
            return ShellTheme.Theme.colors.on_primary

        return ShellTheme.Theme.colors.on_surface
    }

    implicitWidth:
        Math.max(
            48,
            label.implicitWidth
                + root.horizontalPadding * 2
        )

    implicitHeight:
        Math.max(
            32,
            label.implicitHeight
                + root.verticalPadding * 2
        )

    scale:
        root.pressed
            ? Motion.MotionTokens.pressScale
            : 1.0

    opacity:
        root.enabled
            ? 1.0
            : 0.45

    Rectangle {
        anchors.fill:
            parent

        radius:
            ShellTheme.Theme.radius.pill

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

        anchors.centerIn:
            parent

        text:
            root.text

        color:
            root.foregroundColor

        font.family:
            ShellTheme.Theme.typography.fontFamily

        font.pixelSize:
            ShellTheme.Theme.typography.bodySmall

        font.weight:
            root.checked
                ? ShellTheme.Theme.typography.weightSemiBold
                : ShellTheme.Theme.typography.weightMedium

        verticalAlignment:
            Text.AlignVCenter
    }

    MouseArea {
        id: mouseArea

        anchors.fill:
            parent

        enabled:
            root.enabled

        hoverEnabled:
            true

        cursorShape:
            root.enabled
                ? Qt.PointingHandCursor
                : Qt.ArrowCursor

        onClicked: {
            root.checked =
                !root.checked

            root.clicked()
            root.toggled(root.checked)
        }
    }
}
