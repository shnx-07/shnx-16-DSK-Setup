import QtQuick
import qs.core as Core
import qs.theme as ShellTheme

Rectangle {
    id: root

    readonly property var weather:
        Core.ServiceRegistry.weather

    color: ShellTheme.Theme.colors.background
    radius: ShellTheme.Theme.radius.card

    border.width: 1
    border.color: ShellTheme.Theme.colors.outlineVariant

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

                color: ShellTheme.Theme.colors.on_surface
                elide: Text.ElideRight

                font.pixelSize: ShellTheme.Theme.typography.bodyMedium
                font.weight: Font.DemiBold
            }

            Row {
                spacing: 10

                Text {
                    text: weather.temperatureText
                    color: ShellTheme.Theme.colors.on_surface

                    font.pixelSize: ShellTheme.Theme.typography.displayLarge
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

                        color: ShellTheme.Theme.colors.on_surface
                        font.pixelSize: ShellTheme.Theme.typography.bodySmall
                    }

                    Text {
                        text: weather.highLowText
                        color: ShellTheme.Theme.colors.on_surface_variant
                        font.pixelSize: ShellTheme.Theme.typography.labelSmall
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

                    color: ShellTheme.Theme.colors.on_surface_variant
                    font.pixelSize: ShellTheme.Theme.typography.labelSmall
                }

                Text {
                    text:
                        "󰖌 "
                        + Math.round(
                            weather.humidity
                        )
                        + "%"

                    color: ShellTheme.Theme.colors.on_surface_variant
                    font.pixelSize: ShellTheme.Theme.typography.labelSmall
                }

                Text {
                    text:
                        "󰖝 "
                        + Math.round(
                            weather.windSpeed
                        )
                        + " km/h"

                    color: ShellTheme.Theme.colors.on_surface_variant
                    font.pixelSize: ShellTheme.Theme.typography.labelSmall
                }
            }

            Text {
                width: parent.width

                text: weather.statusText
                color: weather.stale
                    ? ShellTheme.Theme.colors.warning
                    : ShellTheme.Theme.colors.disabled

                elide: Text.ElideRight
                font.pixelSize: ShellTheme.Theme.typography.labelSmall
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
                    ? ShellTheme.Theme.colors.on_surface
                    : ShellTheme.Theme.colors.disabled

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
