import QtQuick
import qs.core as Core

Rectangle {
    id: root

    readonly property var weather:
        Core.ServiceRegistry.weather

    color: "#181b21"
    radius: 16

    border.width: 1
    border.color: "#343a45"

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked:
            weather.refresh(true)
    }

    Row {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 16

        Column {
            width: parent.width - 106
            anchors.verticalCenter:
                parent.verticalCenter

            spacing: 5

            Text {
                width: parent.width

                text: weather.location.length > 0
                    ? weather.location
                    : weather.locationQuery

                color: "#f2f3f5"
                elide: Text.ElideRight

                font.pixelSize: 14
                font.weight: Font.DemiBold
            }

            Row {
                spacing: 10

                Text {
                    text: weather.temperatureText
                    color: "#f2f3f5"

                    font.pixelSize: 40
                    font.weight: Font.Light
                }

                Column {
                    anchors.verticalCenter:
                        parent.verticalCenter
                    spacing: 3

                    Text {
                        text: weather.available
                            ? weather.condition
                            : "Weather unavailable"

                        color: "#d7dae0"
                        font.pixelSize: 13
                    }

                    Text {
                        text: weather.highLowText
                        color: "#9299a4"
                        font.pixelSize: 11
                    }
                }
            }

            Row {
                spacing: 13

                Text {
                    text:
                        "󰖎 "
                        + Math.round(
                            weather
                                .precipitationProbability
                        )
                        + "%"

                    color: "#aab0ba"
                    font.pixelSize: 11
                }

                Text {
                    text:
                        "󰖌 "
                        + Math.round(
                            weather.humidity
                        )
                        + "%"

                    color: "#aab0ba"
                    font.pixelSize: 11
                }

                Text {
                    text:
                        "󰖝 "
                        + Math.round(
                            weather.windSpeed
                        )
                        + " km/h"

                    color: "#aab0ba"
                    font.pixelSize: 11
                }
            }

            Text {
                width: parent.width

                text: weather.statusText
                color: weather.stale
                    ? "#d8ae62"
                    : "#747b86"

                elide: Text.ElideRight
                font.pixelSize: 10
            }
        }

        Item {
            width: 72
            height: parent.height

            Text {
                anchors.centerIn: parent

                text: weather.loading
                    ? "󰑐"
                    : weather.conditionIcon

                color: weather.available
                    ? "#e5e7eb"
                    : "#747b86"

                font.pixelSize: 48

                RotationAnimation on rotation {
                    running: weather.loading
                    from: 0
                    to: 360

                    duration: 900
                    loops:
                        Animation.Infinite
                }
            }
        }
    }
}
