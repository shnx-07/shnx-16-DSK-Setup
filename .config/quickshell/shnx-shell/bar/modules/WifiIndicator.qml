import QtQuick
import qs.core as Core

Rectangle {
    id: root

    signal clicked()

    readonly property var network:
        Core.ServiceRegistry.network

    implicitWidth: contentRow.implicitWidth + 20
    implicitHeight: 32

    radius: 10

    color: mouseArea.pressed
        ? "#343944"
        : mouseArea.containsMouse
            ? "#2d323c"
            : "#252932"

    border.width: 1

    border.color: mouseArea.containsMouse
        ? "#596273"
        : "#3b414d"

    Behavior on color {
        ColorAnimation {
            duration: 120
        }
    }

    Behavior on border.color {
        ColorAnimation {
            duration: 120
        }
    }

    Row {
        id: contentRow

        anchors.centerIn: parent
        spacing: 7

        Text {
            text: network.icon

            color: {
                if (!network.available
                        || !network.wifiHardwareEnabled
                        || !network.wifiEnabled) {
                    return "#8b909a"
                }

                if (network.connected)
                    return "#f2f3f5"

                return "#e9b96e"
            }

            font.pixelSize: 17
        }

        Text {
            visible: network.connected

            text: network.ssid

            width: visible
                ? Math.min(implicitWidth, 130)
                : 0

            color: "#f2f3f5"

            font.pixelSize: 12
            font.weight: Font.DemiBold

            elide: Text.ElideRight
            maximumLineCount: 1
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: root.clicked()
    }
}
