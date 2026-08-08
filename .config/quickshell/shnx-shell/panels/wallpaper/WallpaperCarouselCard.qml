import QtQuick

import qs.theme as ShellTheme

import "../../motion" as Motion
import "." as WallpaperParts


Item {
    id: root

    property var wallpaper: null

    property bool selected: false
    property bool current: false
    property bool applying: false
    property bool interactive: true
    property real inverseShear: 0

    signal clicked()


    readonly property bool hovered:
        pointerArea.containsMouse

    readonly property bool pressed:
        pointerArea.pressed

    readonly property string mediaType:
        wallpaper && wallpaper.type
            ? wallpaper.type
            : "static"


    /*
     * ------------------------------------------------------------
     * Very restrained interaction
     * ------------------------------------------------------------
     */

    scale:
        pressed
            ? Motion.MotionTokens.pressScale
            : 1.0


    Motion.ScaleTransition on scale {
        duration:
            Motion.MotionTokens.standard

        easingType:
            Motion.Easing.standard
    }


    /*
     * ------------------------------------------------------------
     * Wallpaper card
     * ------------------------------------------------------------
     */

    Rectangle {
        id: cardSurface

        anchors.fill: parent

        radius:
            ShellTheme.Theme.radius.large

        clip: true

        color:
            ShellTheme.Theme.colors.surfaceContainerLow


        /*
         * Don't give every card a heavy border.
         */
        border.width:
            root.selected || root.current
                ? 1
                : 0

        border.color:
            root.current
                ? ShellTheme.Theme.colors.primary
                : root.selected
                    ? ShellTheme.Theme.colors.outline
                    : "transparent"


        Behavior on border.color {
            ColorAnimation {
                duration:
                    Motion.MotionTokens.standard

                easing.type:
                    Motion.Easing.standard
            }
        }


        /*
         * --------------------------------------------------------
         * Wallpaper itself
         * --------------------------------------------------------
         */

        Item {
            id: mediaViewport

            anchors.fill: parent

            clip: true


            /*
            * Make the preview wider than the card.
            *
            * Without this extra width, inverse-shearing creates
            * empty triangular gaps on the edges.
            */
            Item {
                id: correctedPreview

                anchors.centerIn: parent

                width:
                    parent.width
                    + parent.height
                      * Math.abs(root.inverseShear)
                    + 48

                height:
                    parent.height


                /*
                * Undo the shear applied by WallpaperCarousel.
                *
                * Card remains slanted.
                * Wallpaper remains visually straight.
                */
                transform: Matrix4x4 {
                    matrix:
                        Qt.matrix4x4(
                            1, root.inverseShear, 0, 0,
                            0, 1,                 0, 0,
                            0, 0,                 1, 0,
                            0, 0,                 0, 1
                        )
                }


                WallpaperParts.WallpaperMediaPreview {
                    id: mediaPreview

                    anchors.fill: parent

                    wallpaper:
                        root.wallpaper
                }
            }
        }


        /*
         * --------------------------------------------------------
         * Side-card dimming
         * --------------------------------------------------------
         */

        Rectangle {
            anchors.fill: parent

            radius:
                cardSurface.radius

            color:
                root.selected
                    ? "transparent"
                    : Qt.rgba(
                        0,
                        0,
                        0,
                        0.18
                    )


            Behavior on color {
                ColorAnimation {
                    duration:
                        Motion.MotionTokens.standard
                }
            }
        }


        /*
         * --------------------------------------------------------
         * Selected tint
         * --------------------------------------------------------
         */

        Rectangle {
            anchors.fill: parent

            radius:
                cardSurface.radius

            color:
                root.selected
                    ? Qt.rgba(
                        ShellTheme.Theme.colors.primary.r,
                        ShellTheme.Theme.colors.primary.g,
                        ShellTheme.Theme.colors.primary.b,
                        0.035
                    )
                    : "transparent"


            Behavior on color {
                ColorAnimation {
                    duration:
                        Motion.MotionTokens.standard
                }
            }
        }


        /*
         * --------------------------------------------------------
         * Hover
         * --------------------------------------------------------
         */

        Rectangle {
            anchors.fill: parent

            radius:
                cardSurface.radius

            color:
                root.hovered
                && root.interactive
                    ? ShellTheme.Theme.colors.hoverOverlay
                    : "transparent"


            Behavior on color {
                ColorAnimation {
                    duration:
                        Motion.MotionTokens.quick

                    easing.type:
                        Motion.Easing.standard
                }
            }
        }


        /*
         * --------------------------------------------------------
         * CURRENT badge
         * --------------------------------------------------------
         */

        Rectangle {
            id: currentBadge

            anchors {
                top: parent.top
                left: parent.left

                topMargin:
                    ShellTheme.Theme.spacing.small

                leftMargin:
                    ShellTheme.Theme.spacing.small
            }

            visible:
                root.current

            implicitWidth:
                currentLabel.implicitWidth
                + ShellTheme.Theme.spacing.medium * 2

            implicitHeight:
                currentLabel.implicitHeight
                + ShellTheme.Theme.spacing.small

            radius:
                ShellTheme.Theme.radius.pill

            color:
                ShellTheme.Theme.colors.primaryContainer


            transform: Matrix4x4 {
                matrix:
                    Qt.matrix4x4(
                        1, root.inverseShear, 0, 0,
                        0, 1,                 0, 0,
                        0, 0,                 1, 0,
                        0, 0,                 0, 1
                    )
            }


            Text {
                id: currentLabel

                anchors.centerIn: parent

                text: "CURRENT"

                color:
                    ShellTheme.Theme.colors.on_primary_container

                font.family:
                    ShellTheme.Theme.typography.fontFamily

                font.pixelSize:
                    ShellTheme.Theme.typography.labelSmall

                font.weight:
                    ShellTheme.Theme.typography.weightSemiBold

                font.letterSpacing:
                    ShellTheme.Theme.typography.letterSpacingWide
            }
        }


        /*
         * --------------------------------------------------------
         * Type badge
         * --------------------------------------------------------
         *
         * Only show useful media information.
         *
         * Normal static wallpapers don't need an IMAGE label.
         */

        WallpaperParts.WallpaperTypeBadge {
            id: typeBadge

            anchors {
                right: parent.right
                bottom: parent.bottom

                rightMargin:
                    ShellTheme.Theme.spacing.small

                bottomMargin:
                    ShellTheme.Theme.spacing.small
            }

            visible:
                root.mediaType !== "static"

            mediaType:
            root.mediaType


            transform: Matrix4x4 {
                matrix:
                    Qt.matrix4x4(
                        1, root.inverseShear, 0, 0,
                        0, 1,                 0, 0,
                        0, 0,                 1, 0,
                        0, 0,                 0, 1
                    )
            }
        }


        /*
         * --------------------------------------------------------
         * Applying
         * --------------------------------------------------------
         */

        Rectangle {
            id: applyingOverlay

            anchors.fill:
                parent

            radius:
                cardSurface.radius

            visible:
                opacity > 0.001

            opacity:
                root.applying
                    ? 1.0
                    : 0.0

            color:
                Qt.rgba(
                    ShellTheme.Theme.colors.scrim.r,
                    ShellTheme.Theme.colors.scrim.g,
                    ShellTheme.Theme.colors.scrim.b,
                    0.52
                )


            Motion.FadeTransition on opacity {
                duration:
                    Motion.MotionTokens.standard

                easingType:
                    Motion.Easing.standard
            }


            Column {
                anchors.centerIn:
                    parent

                spacing:
                    ShellTheme.Theme.spacing.small


                Text {
                    anchors.horizontalCenter:
                        parent.horizontalCenter

                    text:
                        "󰑐"

                    color:
                        ShellTheme.Theme.colors.on_surface

                    font.pixelSize:
                        ShellTheme.Theme.typography.headlineMedium
                }


                Text {
                    anchors.horizontalCenter:
                        parent.horizontalCenter

                    text:
                        "Applying…"

                    color:
                        ShellTheme.Theme.colors.on_surface

                    font.family:
                        ShellTheme.Theme.typography.fontFamily

                    font.pixelSize:
                        ShellTheme.Theme.typography.bodySmall

                    font.weight:
                        ShellTheme.Theme.typography.weightMedium
                }
            }
        }
    }


    /*
     * ------------------------------------------------------------
     * Pointer
     * ------------------------------------------------------------
     */

    MouseArea {
        id: pointerArea

        anchors.fill:
            parent

        enabled:
            root.interactive
            && !root.applying

        hoverEnabled: true

        cursorShape:
            enabled
                ? Qt.PointingHandCursor
                : Qt.ArrowCursor

        onClicked: {
            root.clicked()
        }
    }
}
