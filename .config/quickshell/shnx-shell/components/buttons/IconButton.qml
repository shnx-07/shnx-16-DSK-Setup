import QtQuick
import QtQuick.Controls

import "../../theme" as ShellTheme
import "../../motion" as Motion
import "../visual" as Visual

Item {
    id: root

    signal clicked()

    property string iconSource: ""
    property string glyph: ""

    property real buttonSize: 36
    property real iconSize: 18

    property bool enabled: true

    property string tooltipText: ""

    property color iconColor:
        ShellTheme.Theme.colors.on_surface

    property color hoverColor:
        ShellTheme.Theme.colors.surfaceContainerHigh

    property color pressedColor:
        ShellTheme.Theme.colors.surfaceContainerHighest

    property color focusColor:
        ShellTheme.Theme.colors.primary

    readonly property bool hovered:
        mouseArea.containsMouse

    readonly property bool pressed:
        mouseArea.pressed

    implicitWidth:
        buttonSize

    implicitHeight:
        buttonSize

    scale:
        pressed
            ? Motion.MotionTokens.compactPressScale
            : hovered
                ? Motion.MotionTokens.hoverScale
                : 1.0

    opacity:
        enabled ? 1.0 : 0.45

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
            ShellTheme.Theme.radius.button

        color: {
            if (root.pressed)
                return root.pressedColor

            if (root.hovered)
                return root.hoverColor

            return "transparent"
        }

        border.width:
            root.activeFocus ? 1 : 0

        border.color:
            root.focusColor

        Behavior on color {
            ColorAnimation {
                duration:
                    Motion.MotionTokens.quick

                easing.type:
                    Motion.Easing.standard
            }
        }
    }

    Visual.Icon {
        anchors.centerIn: parent

        source:
            root.iconSource

        glyph:
            root.glyph

        iconSize:
            root.iconSize

        color:
            root.iconColor

        disabled:
            !root.enabled
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

        onClicked:
            root.clicked()
    }

    ToolTip {
        visible:
            root.tooltipText.length > 0
            && root.hovered

        text:
            root.tooltipText

        delay:
            500
    }
}
