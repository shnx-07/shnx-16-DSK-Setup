import QtQuick
import QtQuick.Controls

import qs.theme as ShellTheme
import qs.motion as Motion

import qs.components.visual as Visual

Item {
    id: root

    property string route: ""
    property string label: ""
    property string glyph: ""

    property bool selected: false
    property bool active: false

    signal hovered()
    signal activated()

    implicitWidth: 58
    implicitHeight: 58

    readonly property bool containsMouse:
        mouseArea.containsMouse

    readonly property bool highlighted:
        root.selected || root.containsMouse

    /*
     * ------------------------------------------------------------
     * ITEM MOTION
     * ------------------------------------------------------------
     */

    scale:
        mouseArea.pressed
            ? Motion.MotionTokens.compactPressScale
            : root.highlighted
                ? Motion.MotionTokens.emphasizedHoverScale
                : 1.0

    y:
        root.highlighted
            ? -Motion.MotionTokens.smallOffset
            : 0

    Behavior on scale {
        NumberAnimation {
            duration:
                Motion.MotionTokens.quick

            easing.type:
                Motion.Easing.standard
        }
    }

    Behavior on y {
        NumberAnimation {
            duration:
                Motion.MotionTokens.quick

            easing.type:
                Motion.Easing.standard
        }
    }

    /*
     * ------------------------------------------------------------
     * HOVER / SELECTION SURFACE
     * ------------------------------------------------------------
     */

    Rectangle {
        anchors.centerIn:
            parent

        width: 44
        height: 44

        radius:
            ShellTheme.Theme.radius.large

        color: {
            if (root.selected)
                return ShellTheme.Theme.colors.surfaceContainerHigh

            if (root.containsMouse)
                return ShellTheme.Theme.colors.surfaceContainerHigh

            return "transparent"
        }

        opacity:
            root.highlighted
                ? 1.0
                : 0.0

        Behavior on color {
            ColorAnimation {
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
    }

    /*
     * ------------------------------------------------------------
     * ICON
     * ------------------------------------------------------------
     */

    Visual.Icon {
        anchors.centerIn:
            parent

        glyph:
            root.glyph

        iconSize:
            24

        color:
            root.selected || root.active
                ? ShellTheme.Theme.colors.primary
                : ShellTheme.Theme.colors.on_surface

        disabled:
            !root.enabled
    }

    /*
     * ------------------------------------------------------------
     * ACTIVE INDICATOR
     * ------------------------------------------------------------
     */

    Rectangle {
        anchors {
            horizontalCenter:
                parent.horizontalCenter

            bottom:
                parent.bottom

            bottomMargin:
                Motion.MotionTokens.tinyOffset
        }

        width:
            root.active
                ? 12
                : 0

        height: 3

        radius:
            ShellTheme.Theme.radius.pill

        color:
            ShellTheme.Theme.colors.primary

        opacity:
            root.active
                ? 1.0
                : 0.0

        Behavior on width {
            NumberAnimation {
                duration:
                    Motion.MotionTokens.standard

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
    }

    /*
     * ------------------------------------------------------------
     * INTERACTION
     * ------------------------------------------------------------
     */

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

        onEntered:
            root.hovered()

        onClicked: {
            Qt.callLater(function() {
                root.activated()
            })
        }
    }

    /*
     * ------------------------------------------------------------
     * TOOLTIP
     * ------------------------------------------------------------
     */

    ToolTip {
        visible:
            root.containsMouse
            && root.label.length > 0

        text:
            root.label

        delay:
            500
    }
}
