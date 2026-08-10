import QtQuick

import qs.core as Core
import qs.theme as ShellTheme

import "../../components/visual" as Visual
import "../../motion" as Motion

Item {
    id: root

    implicitWidth: 420
    implicitHeight: 42

    readonly property var brightness:
        Core.ServiceRegistry.brightness

    readonly property real visualLevel:
        root.brightness
        && root.brightness.available
            ? Math.max(
                0.01,
                Math.min(
                    1,
                    root.brightness.brightness
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
         * BRIGHTNESS ICON
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
                    root.brightness
                        ? root.brightness.icon
                        : "󰃠"

                iconSize: 17

                color:
                    root.brightness
                    && root.brightness.available
                        ? ShellTheme.Theme.colors.on_surface
                        : ShellTheme.Theme.colors.disabled
            }
        }

        /*
         * ACTUAL SERVICE PROPERTY:
         * brightnessPercentage
         */
        Text {
            id: brightnessValue

            anchors {
                right: parent.right

                rightMargin:
                    ShellTheme.Theme.spacing.medium

                verticalCenter:
                    parent.verticalCenter
            }

            width: 42

            text:
                root.brightness
                && root.brightness.available
                    ? root.brightness.brightnessPercentage + "%"
                    : "--"

            color:
                root.brightness
                && root.brightness.available
                    ? ShellTheme.Theme.colors.on_surface
                    : ShellTheme.Theme.colors.disabled

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
                left:
                    iconArea.right

                leftMargin:
                    ShellTheme.Theme.spacing.xSmall

                right:
                    brightnessValue.left

                rightMargin:
                    ShellTheme.Theme.spacing.medium

                verticalCenter:
                    parent.verticalCenter
            }

            height: 30

            opacity:
                root.brightness
                && root.brightness.available
                    ? 1.0
                    : 0.45

            Rectangle {
                anchors.fill:
                    parent

                radius:
                    height / 2

                color:
                    ShellTheme.Theme.colors.surfaceContainerHighest
            }

            /*
             * CURRENT BRIGHTNESS
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
             * MouseArea belongs to the track itself.
             */
            MouseArea {
                id: sliderMouseArea

                anchors.fill:
                    parent

                enabled:
                    root.brightness
                    && root.brightness.available

                hoverEnabled: true

                cursorShape:
                    enabled
                        ? Qt.PointingHandCursor
                        : Qt.ArrowCursor

                onPressed: function(mouse) {
                    root.setBrightnessFromPosition(
                        mouse.x
                    )
                }

                onPositionChanged: function(mouse) {
                    if (pressed) {
                        root.setBrightnessFromPosition(
                            mouse.x
                        )
                    }
                }

                onWheel: function(wheel) {
                    if (!root.brightness.available)
                        return

                    if (wheel.angleDelta.y > 0) {
                        root.brightness.increaseBrightness(
                            0.03
                        )
                    } else {
                        root.brightness.decreaseBrightness(
                            0.03
                        )
                    }

                    wheel.accepted = true
                }
            }
        }
    }

    function setBrightnessFromPosition(positionX) {
        if (
            !root.brightness
            || !root.brightness.available
            || sliderTrack.width <= 0
        ) {
            return
        }

        /*
         * Preserve original minimum brightness of 1%.
         */
        const normalized =
            Math.max(
                0.01,
                Math.min(
                    1,
                    positionX
                    / sliderTrack.width
                )
            )

        root.brightness.setBrightness(
            normalized
        )
    }
}
