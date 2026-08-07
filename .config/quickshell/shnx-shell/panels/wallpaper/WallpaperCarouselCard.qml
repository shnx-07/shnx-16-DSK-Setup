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
     * Local interaction motion only
     * ------------------------------------------------------------
     *
     * Large positioning / depth motion belongs to WallpaperCarousel.
     */

    scale:
        pressed
            ? Motion.MotionTokens.pressScale
            : hovered && interactive
                ? Motion.MotionTokens.hoverScale
                : 1.0

    Motion.ScaleTransition on scale {
        duration:
            Motion.MotionTokens.standard

        easingType:
            Motion.Easing.standard
    }


    Rectangle {
        id: cardSurface

        anchors.fill: parent

        radius:
            ShellTheme.Theme.radius.xLarge

        clip: true

        color:
            root.selected
                ? ShellTheme.Theme.colors.surfaceContainerHigh
                : ShellTheme.Theme.colors.surfaceContainerLow

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


        Behavior on color {
            ColorAnimation {
                duration:
                    Motion.MotionTokens.standard

                easing.type:
                    Motion.Easing.standard
            }
        }


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
         * Poster preview
         * --------------------------------------------------------
         */

        WallpaperParts.WallpaperMediaPreview {
            id: mediaPreview

            anchors.fill: parent

            wallpaper:
                root.wallpaper
        }


        /*
         * --------------------------------------------------------
         * Selected emphasis
         * --------------------------------------------------------
         *
         * Very subtle themed wash only.
         * The carousel itself provides the real visual emphasis.
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
                        0.045
                    )
                    : "transparent"

            Behavior on color {
                ColorAnimation {
                    duration:
                        Motion.MotionTokens.standard

                    easing.type:
                        Motion.Easing.standard
                }
            }
        }


        /*
         * --------------------------------------------------------
         * Hover layer
         * --------------------------------------------------------
         */

        Rectangle {
            anchors.fill: parent

            radius:
                cardSurface.radius

            color:
                root.hovered && root.interactive
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
         * Bottom information surface
         * --------------------------------------------------------
         */

        Rectangle {
            id: infoSurface

            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }

            height: 56

            color:
                Qt.rgba(
                    ShellTheme.Theme.colors.surface.r,
                    ShellTheme.Theme.colors.surface.g,
                    ShellTheme.Theme.colors.surface.b,
                    0.86
                )


            Row {
                anchors {
                    fill: parent

                    leftMargin:
                        ShellTheme.Theme.spacing.medium

                    rightMargin:
                        ShellTheme.Theme.spacing.medium
                }

                spacing:
                    ShellTheme.Theme.spacing.small


                Column {
                    anchors.verticalCenter:
                        parent.verticalCenter

                    width:
                        Math.max(
                            0,
                            parent.width
                            - typeBadge.width
                            - parent.spacing
                        )

                    spacing:
                        ShellTheme.Theme.spacing.xxxSmall


                    Text {
                        width:
                            parent.width

                        text:
                            root.wallpaper
                            && root.wallpaper.name
                                ? root.wallpaper.name
                                : "Wallpaper"

                        elide:
                            Text.ElideRight

                        color:
                            ShellTheme.Theme.colors.on_surface

                        font.family:
                            ShellTheme.Theme.typography.fontFamily

                        font.pixelSize:
                            ShellTheme.Theme.typography.bodySmall

                        font.weight:
                            ShellTheme.Theme.typography.weightSemiBold
                    }


                    Text {
                        width:
                            parent.width

                        visible:
                            root.wallpaper
                            && root.wallpaper.path

                        text:
                            root.wallpaper
                            && root.wallpaper.path
                                ? root.wallpaper.path
                                : ""

                        elide:
                            Text.ElideLeft

                        color:
                            ShellTheme.Theme.colors.on_surface_variant

                        font.family:
                            ShellTheme.Theme.typography.fontFamily

                        font.pixelSize:
                            ShellTheme.Theme.typography.labelSmall
                    }
                }


                WallpaperParts.WallpaperTypeBadge {
                    id: typeBadge

                    anchors.verticalCenter:
                        parent.verticalCenter

                    mediaType:
                        root.mediaType
                }
            }
        }


        /*
         * --------------------------------------------------------
         * Current wallpaper indicator
         * --------------------------------------------------------
         */

        Rectangle {
            id: currentBadge

            anchors {
                top: parent.top
                left: parent.left

                topMargin:
                    ShellTheme.Theme.spacing.medium

                leftMargin:
                    ShellTheme.Theme.spacing.medium
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


            Text {
                id: currentLabel

                anchors.centerIn:
                    parent

                text:
                    "CURRENT"

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
         * Applying overlay
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
                        24
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
     * Pointer handling
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
