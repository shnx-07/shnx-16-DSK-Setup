import QtQuick
import qs.core as Core

Item {
    id: root

    implicitWidth: 420
    implicitHeight: 72

    readonly property var audio:
        Core.ServiceRegistry.audio

    property int barCount: 42

    Column {
        anchors.fill: parent
        spacing: 8

        Row {
            width: parent.width
            height: 20

            spacing: 8

            Text {
                id: volumeIcon

                width: 22
                height: parent.height

                text: root.audio.icon
                color: "#e7ebf0"

                font.pixelSize: 16
                font.family: "JetBrainsMono Nerd Font"

                verticalAlignment: Text.AlignVCenter

                MouseArea {
                    anchors.fill: parent

                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        root.audio.toggleMute()
                    }
                }
            }

            Text {
                text: "Volume"
                color: "#e7ebf0"

                font.pixelSize: 13
                font.weight: Font.Medium

                verticalAlignment: Text.AlignVCenter
            }

            Item {
                width:
                    parent.width
                    - volumeIcon.width
                    - volumeValue.width
                    - 68

                height: 1
            }

            Text {
                id: volumeValue

                text:
                    root.audio.available
                        ? root.audio.volumePercentage + "%"
                        : "--"

                color: "#aab4c1"
                font.pixelSize: 12

                verticalAlignment: Text.AlignVCenter
            }
        }

        Item {
            id: waveformSlider

            width: parent.width
            height: 42

            property real visualLevel:
                root.audio.muted
                    ? 0
                    : root.audio.volume

            Row {
                id: waveformRow

                anchors.fill: parent
                spacing: 3

                Repeater {
                    model: root.barCount

                    Rectangle {
                        required property int index

                        width:
                            (
                                waveformRow.width
                                - waveformRow.spacing
                                * (root.barCount - 1)
                            ) / root.barCount

                        height: {
                            if (root.audio.muted)
                                return 3

                            const baseWave =
                                (
                                    Math.sin(index * 0.82)
                                    + Math.sin(index * 1.71) * 0.45
                                    + 1.6
                                ) / 3.05

                            const movement =
                                waveformTimer.phase

                            const animatedWave =
                                (
                                    Math.sin(
                                        index * 0.68
                                        + movement
                                    )
                                    + 1
                                ) / 2

                            return 5
                                + (
                                    baseWave * 0.62
                                    + animatedWave * 0.38
                                ) * 28
                        }

                        anchors.verticalCenter:
                            parent.verticalCenter

                        radius:
                            Math.min(width, height) / 2

                        color: {
                            const barProgress =
                                (index + 1) / root.barCount

                            return barProgress
                                <= waveformSlider.visualLevel
                                    ? "#e0e7ef"
                                    : "#35404c"
                        }

                        Behavior on height {
                            NumberAnimation {
                                duration: 110
                            }
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 100
                            }
                        }
                    }
                }
            }

            MouseArea {
                id: sliderMouseArea

                anchors.fill: parent

                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onPressed: function(mouse) {
                    root.setVolumeFromPosition(mouse.x)
                }

                onPositionChanged: function(mouse) {
                    if (pressed)
                        root.setVolumeFromPosition(mouse.x)
                }

                onWheel: function(wheel) {
                    if (wheel.angleDelta.y > 0)
                        root.audio.increaseVolume(0.03)
                    else
                        root.audio.decreaseVolume(0.03)

                    wheel.accepted = true
                }
            }

            Rectangle {
                x:
                    Math.max(
                        0,
                        Math.min(
                            parent.width - width,
                            parent.width
                            * waveformSlider.visualLevel
                            - width / 2
                        )
                    )

                anchors.verticalCenter:
                    parent.verticalCenter

                width: 13
                height: 13
                radius: width / 2

                visible:
                    root.audio.available
                    && !root.audio.muted

                color: "#f4f6f8"

                border.width: 2
                border.color: "#59697b"

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
    }

    Timer {
        id: waveformTimer

        property real phase: 0

        interval: 90
        repeat: true
        running:
            root.visible
            && root.audio.available
            && !root.audio.muted
            && root.audio.volumePercentage > 0

        onTriggered: {
            phase += 0.5
        }
    }

    function setVolumeFromPosition(positionX) {
        if (!audio.available)
            return

        const normalized =
            Math.max(
                0,
                Math.min(
                    1,
                    positionX / waveformSlider.width
                )
            )

        audio.setVolume(normalized)

        if (audio.muted && normalized > 0)
            audio.setMuted(false)
    }
}
