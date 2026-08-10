import QtQuick
import "../../components/controls" as Controls

Item {
    id: root

    required property QtObject clockService

    property int selectedClockMode: 0

    Column {
        anchors.fill: parent

        spacing: 14

        Controls.SegmentedControl {
            id: modeSelector

            anchors.horizontalCenter: parent.horizontalCenter

            options: [
                "Digital",
                "Analog"
            ]

            currentIndex: root.selectedClockMode

            onSelected: index => {
                root.selectedClockMode = index
            }
        }

        Item {
            id: clockViewContainer

            width: parent.width
            height: parent.height
                    - modeSelector.height
                    - parent.spacing

            DigitalClockView {
                anchors.fill: parent

                clockService: root.clockService

                visible: root.selectedClockMode === 0
                enabled: visible

                opacity: visible ? 1 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 140
                        easing.type: Easing.OutCubic
                    }
                }
            }

            AnalogClockView {
                anchors.fill: parent

                clockService: root.clockService

                visible: root.selectedClockMode === 1
                enabled: visible

                opacity: visible ? 1 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 140
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }
}
