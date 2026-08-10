import QtQuick
import QtQuick.Layouts

import qs.theme as ShellTheme
import qs.motion as Motion

import qs.components.layout as Layout
import qs.components.visual as Visual

Item {
    id: root

    property bool expanded: false

    property alias contentItem:
        contentRow

    implicitWidth:
        contentRow.implicitWidth
        + ShellTheme.Theme.spacing.medium * 2

    implicitHeight:
        68

    /*
     * ------------------------------------------------------------
     * DOCK ENTRANCE / EXIT
     * ------------------------------------------------------------
     *
     * Keep the dock motion spatial but restrained.
     *
     * No local millisecond values.
     * No arbitrary scale values.
     */

    opacity:
        root.expanded
            ? 1.0
            : 0.0

    y:
        root.expanded
            ? 0
            : Motion.MotionTokens.mediumOffset

    Behavior on opacity {
        NumberAnimation {
            duration:
                Motion.MotionTokens.standard

            easing.type:
                Motion.Easing.standard
        }
    }

    Behavior on y {
        NumberAnimation {
            duration:
                Motion.MotionTokens.spatial

            easing.type:
                Motion.Easing.emphasized
        }
    }

    /*
     * ------------------------------------------------------------
     * DOCK SURFACE
     * ------------------------------------------------------------
     *
     * Generic visual treatment belongs to Layout.Surface.
     *
     * UtilityDockSurface owns only:
     *
     * - dock geometry
     * - dock spacing
     * - entrance / exit motion
     * - dock content placement
     */

    Layout.Surface {
    anchors.fill:
        parent

    backgroundColor:
        ShellTheme.Theme.colors.surfaceContainer

    borderWidth:
        0

    radius:
        ShellTheme.Theme.radius.large

    shadowLevel:
        Visual.Shadow.None

    clipContent:
        false

    RowLayout {
        id: contentRow

        anchors.centerIn:
            parent

        spacing:
            ShellTheme.Theme.spacing.xSmall
    }
}
}
