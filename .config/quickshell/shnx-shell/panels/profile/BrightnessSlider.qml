import QtQuick
import qs.core as Core

Item {
    id: root

    implicitWidth: 420
    implicitHeight: 62

    readonly property var brightness:
        Core.ServiceRegistry.brightness

    Column {
        anchors.fill: parent
        spacing: 9

        Row {
            width: parent.width
            height: 20

            spacing: 8

            Text {
                id: brightnessIcon

                width: 22
                height: parent.height

                text: root.brightness.icon

                color:
                    root.brightness.available
                        ? "#e7ebf0"
                        : "#66717f"

                font.pixelSize: 16
                font.family: "JetBrainsMono Nerd Font"

                verticalAlignment: Text.AlignVCenter
            }

            Text {
                text: "Brightness"

                color:
                    root.brightness.available
                        ? "#e7ebf0"
                        : "#66717f"

                font.pixelSize: 13
                font.weight: Font.Medium

                verticalAlignment: Text.AlignVCenter
            }

            Item {
                width:
                    parent.width
                    - brightnessIcon.width
                    - brightnessValue.width
                    - 84

                height: 1
            }

            Text {
                id: brightnessValue

                text:
                    root.brightness.available
                        ? root.brightness.brightnessPercentage + "%"
                        : "--"

                color:
                    root.brightness.available
                        ? "#aab4c1"
                        : "#66717f"

                font.pixelSize: 12
                verticalAlignment: Text.AlignVCenter
            }
        }

        Item {
            id: sliderArea

            width: parent.width
            height: 32

            Rectangle {
                id: sliderTrack

                anchors.verticalCenter: parent.verticalCenter

                width: parent.width
                height: 8

                radius: height / 2
                color: "#303a46"

                opacity:
                    root.brightness.available
                        ? 1.0
                        : 0.45

                Rectangle {
                    width:
                        sliderTrack.width
                        * root.brightness.brightness

                    height: parent.height

                    radius: height / 2
                    color: "#d9e2ec"

                    Behavior on width {
                        NumberAnimation {
                            duration:
                                sliderMouseArea.pressed
                                    ? 0
                                    : 100
                        }
                    }
                }

                Rectangle {
                    x:
                        Math.max(
                            0,
                            Math.min(
                                sliderTrack.width - width,
                                sliderTrack.width
                                * root.brightness.brightness
                                - width / 2
                            )
                        )

                    anchors.verticalCenter:
                        parent.verticalCenter

                    width: 16
                    height: 16
                    radius: width / 2

                    visible:
                        root.brightness.available

                    color: "#f4f6f8"

                    border.width: 2
                    border.color: "#566577"

                    Behavior on x {
                        NumberAnimation {
                            duration:
                                sliderMouseArea.pressed
                                    ? 0
                                    : 90
                        }
                    }
                }
            }

            MouseArea {
                id: sliderMouseArea

                anchors.fill: parent

                enabled:
                    root.brightness.available

                hoverEnabled: true

                cursorShape:
                    enabled
                        ? Qt.PointingHandCursor
                        : Qt.ArrowCursor

                onPressed: function(mouse) {
                    root.setBrightnessFromPosition(mouse.x)
                }

                onPositionChanged: function(mouse) {
                    if (pressed)
                        root.setBrightnessFromPosition(mouse.x)
                }

                onWheel: function(wheel) {
                    if (!root.brightness.available)
                        return

                    if (wheel.angleDelta.y > 0)
                        root.brightness.increaseBrightness(0.03)
                    else
                        root.brightness.decreaseBrightness(0.03)

                    wheel.accepted = true
                }
            }
        }
    }

    function setBrightnessFromPosition(positionX) {
        if (!brightness.available)
            return

        const normalized =
            Math.max(
                0.01,
                Math.min(
                    1,
                    positionX / sliderArea.width
                )
            )

        brightness.setBrightness(normalized)
    }
}
