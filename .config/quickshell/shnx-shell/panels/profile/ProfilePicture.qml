import QtQuick

import qs.core as Core
import qs.theme as ShellTheme

import "../../components/visual" as Visual
import "../../motion" as Motion

Item {
    id: root

    implicitWidth: 112
    implicitHeight: 112

    readonly property var profile:
        Core.ServiceRegistry.profile

    readonly property bool hasAvatar:
        Boolean(
            root.profile
            && (
                root.profile.hasCustomAvatar
                || root.profile.hasAvatar
            )
        )

    signal clicked()

    /*
     * ------------------------------------------------------------
     * OUTER INTERACTION RING
     * ------------------------------------------------------------
     */

    Rectangle {
        id: outerRing

        anchors.fill: parent

        radius:
            ShellTheme.Theme.radius.circle

        color:
            ShellTheme.Theme.colors.surfaceContainerHigh

        border.width: 1

        border.color:
            avatarMouseArea.containsMouse
                ? ShellTheme.Theme.colors.outline
                : ShellTheme.Theme.colors.outlineVariant

        Behavior on border.color {
            ColorAnimation {
                duration:
                    Motion.MotionTokens.quick

                easing.type:
                    Motion.Easing.standard
            }
        }

        /*
         * --------------------------------------------------------
         * SHARED AVATAR RENDERER
         * --------------------------------------------------------
         */

        Visual.Avatar {
            anchors.centerIn:
                parent

            avatarSize: 98

            source:
                root.hasAvatar
                    ? "file://" + root.profile.avatarPath
                    : ""

            fallbackColor:
                ShellTheme.Theme.colors.surfaceContainer

            fallbackText:
                ""
        }
    }

    /*
     * ------------------------------------------------------------
     * PROFILE ACTION
     * ------------------------------------------------------------
     */

    MouseArea {
        id: avatarMouseArea

        anchors.fill: parent

        hoverEnabled: true

        cursorShape:
            Qt.PointingHandCursor

        onClicked: {
            root.clicked()

            if (root.profile)
                root.profile.selectAvatar()
        }
    }

    /*
     * ------------------------------------------------------------
     * PRESS FEEDBACK
     * ------------------------------------------------------------
     */

    scale:
        avatarMouseArea.pressed
            ? Motion.MotionTokens.pressScale
            : 1.0

    Behavior on scale {
        NumberAnimation {
            duration:
                Motion.MotionTokens.quick

            easing.type:
                Motion.Easing.standard
        }
    }
}
