import QtQuick
import qs.core as Core

Rectangle {
    id: root

    signal clicked()

    readonly property var bluetooth:
        Core.ServiceRegistry.bluetooth

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
            text: bluetooth.icon

            color: {
                if (!bluetooth.available || !bluetooth.enabled)
                    return "#8b909a"

                if (bluetooth.connected)
                    return "#86a9ff"

                return "#f2f3f5"
            }

            font.pixelSize: 17
        }

        Text {
            visible: bluetooth.connected

            text: {
                if (bluetooth.connectedDeviceCount > 1)
                    return bluetooth.connectedDeviceCount.toString()

                return bluetooth.primaryDeviceName
            }

            width: visible
                ? Math.min(implicitWidth, 120)
                : 0

            color: "#f2f3f5"

            font.pixelSize: 12
            font.weight: Font.DemiBold

            elide: Text.ElideRight
            maximumLineCount: 1
            wrapMode: Text.NoWrap
        }

        Text {
            visible:
                bluetooth.connectedDeviceCount === 1
                && bluetooth.primaryDeviceHasBattery

            text: bluetooth.primaryDeviceBattery + "%"

            color: "#b8bdc7"

            font.pixelSize: 11
            font.weight: Font.Medium
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
