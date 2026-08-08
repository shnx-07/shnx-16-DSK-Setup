import QtQuick
import qs.theme as ShellTheme

Item {
    id: root

    required property QtObject clockService

    Column {
        id: content

        anchors.centerIn: parent

        width: parent.width
        spacing: 10

         Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 5

            Text {
                text: root.clockService.hourMinuteText

                color: ShellTheme.Theme.colors.on_surface
                font.pixelSize: 52
                font.weight: Font.Medium

                font.features: {
                    "tnum": 1
                }
            }

            Column {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 7

                spacing: 1

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: root.clockService.secondText

                    color: ShellTheme.Theme.colors.on_surface_variant
                    font.pixelSize: ShellTheme.Theme.typography.titleSmall
                    font.weight: Font.Medium

                    font.features: {
                        "tnum": 1
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: root.clockService.periodText

                    color: ShellTheme.Theme.colors.on_surface_variant
                    font.pixelSize: ShellTheme.Theme.typography.labelSmall
                    font.weight: Font.Medium
                }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter

            text: root.clockService.weekdayText

            color: ShellTheme.Theme.colors.on_surface

            font.pixelSize: ShellTheme.Theme.typography.titleSmall
            font.weight: Font.Medium
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter

            text: root.clockService.fullDateText

            color: ShellTheme.Theme.colors.on_surface_variant

            font.pixelSize: ShellTheme.Theme.typography.bodySmall
            font.weight: Font.Normal
        }
    }
}
