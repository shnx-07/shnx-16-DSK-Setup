import QtQuick

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

                color: "#f4f4f5"
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

                    color: "#8f9198"
                    font.pixelSize: 16
                    font.weight: Font.Medium

                    font.features: {
                        "tnum": 1
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: root.clockService.periodText

                    color: "#9f9198"
                    font.pixelSize: 10
                    font.weight: Font.Medium
                }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter

            text: root.clockService.weekdayText

            color: "#d8d8dc"

            font.pixelSize: 15
            font.weight: Font.Medium
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter

            text: root.clockService.fullDateText

            color: "#9f9198"

            font.pixelSize: 13
            font.weight: Font.Normal
        }
    }
}
