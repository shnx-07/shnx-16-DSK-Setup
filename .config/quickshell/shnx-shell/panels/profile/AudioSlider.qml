import QtQuick

import qs.core as Core
import qs.theme as ShellTheme

import "../../components/visual" as Visual
import "../../motion" as Motion

Item {
    id: root

    implicitWidth: 420
    implicitHeight: 42

    readonly property var audio:
        Core.ServiceRegistry.audio

    readonly property real visualLevel:
        root.audio
        && root.audio.available
        && !root.audio.muted
            ? Math.max(
                0,
                Math.min(
                    1,
                    root.audio.volume
                )
            )
            : 0

    Rectangle {
        id: background

        anchors.fill: parent

        radius:
            height / 2

        color:
            ShellTheme.Theme.colors.surfaceContainer

        border.width: 1

        border.color:
            sliderMouseArea.containsMouse
            || muteMouseArea.containsMouse
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
         * SPEAKER
         */
        Item {
            id: iconArea

            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }

            width: 44

            Visual.Icon {
                anchors.centerIn: parent

                glyph:
                    root.audio
                        ? root.audio.icon
                        : "󰕿"

                iconSize: 17

                color:
                    root.audio
                    && root.audio.muted
                        ? ShellTheme.Theme.colors.on_surface_variant
                        : ShellTheme.Theme.colors.on_surface
            }

            MouseArea {
                id: muteMouseArea

                anchors.fill: parent

                enabled:
                    root.audio
                    && root.audio.available

                hoverEnabled: true

                cursorShape:
                    enabled
                        ? Qt.PointingHandCursor
                        : Qt.ArrowCursor

                onClicked: {
                    root.audio.toggleMute()
                }
            }
        }

        /*
         * PERCENTAGE
         */
        Text {
            id: volumeValue

            anchors {
                right: parent.right
                rightMargin:
                    ShellTheme.Theme.spacing.medium

                verticalCenter:
                    parent.verticalCenter
            }

            width: 42

            text:
                root.audio
                && root.audio.available
                    ? root.audio.volumePercentage + "%"
                    : "--"

            color:
                ShellTheme.Theme.colors.on_surface

            font.family:
                ShellTheme.Theme.typography.fontFamily

            font.pixelSize:
                ShellTheme.Theme.typography.labelSmall

            font.weight:
                Font.DemiBold

            horizontalAlignment:
                Text.AlignRight

            verticalAlignment:
                Text.AlignVCenter
        }

        /*
         * INTERACTIVE TRACK
         */
        Item {
            id: sliderTrack

            anchors {
                left: iconArea.right

                leftMargin:
                    ShellTheme.Theme.spacing.xSmall

                right:
                    volumeValue.left

                rightMargin:
                    ShellTheme.Theme.spacing.medium

                verticalCenter:
                    parent.verticalCenter
            }

            height: 30

            Rectangle {
                anchors.fill: parent

                radius:
                    height / 2

                color:
                    ShellTheme.Theme.colors.surfaceContainerHighest
            }

            /*
             * CURRENT VOLUME
             */
            Rectangle {
                width:
                    sliderTrack.width
                    * root.visualLevel

                height:
                    sliderTrack.height

                radius:
                    height / 2

                color:
                    ShellTheme.Theme.colors.primary

                Behavior on width {
                    NumberAnimation {
                        duration:
                            sliderMouseArea.pressed
                                ? 0
                                : Motion.MotionTokens.quick

                        easing.type:
                            Motion.Easing.standard
                    }
                }
            }

            /*
             * IMPORTANT:
             * MouseArea now lives INSIDE sliderTrack.
             */
            MouseArea {
                id: sliderMouseArea

                anchors.fill: parent

                enabled:
                    root.audio
                    && root.audio.available

                hoverEnabled: true

                cursorShape:
                    enabled
                        ? Qt.PointingHandCursor
                        : Qt.ArrowCursor

                onPressed: function(mouse) {
                    root.setVolumeFromPosition(
                        mouse.x
                    )
                }

                onPositionChanged: function(mouse) {
                    if (pressed) {
                        root.setVolumeFromPosition(
                            mouse.x
                        )
                    }
                }

                onWheel: function(wheel) {
                    if (wheel.angleDelta.y > 0) {
                        root.audio.increaseVolume(
                            0.03
                        )
                    } else {
                        root.audio.decreaseVolume(
                            0.03
                        )
                    }

                    wheel.accepted = true
                }
            }
        }
    }

    function setVolumeFromPosition(positionX) {
        if (
            !root.audio
            || !root.audio.available
            || sliderTrack.width <= 0
        ) {
            return
        }

        const normalized =
            Math.max(
                0,
                Math.min(
                    1,
                    positionX
                    / sliderTrack.width
                )
            )

        root.audio.setVolume(
            normalized
        )

        if (
            root.audio.muted
            && normalized > 0
        ) {
            root.audio.setMuted(
                false
            )
        }
    }
}
