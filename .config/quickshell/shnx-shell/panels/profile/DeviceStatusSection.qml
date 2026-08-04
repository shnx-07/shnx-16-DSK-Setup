import QtQuick
import QtQuick.Layouts
import qs.core as Core

Rectangle {
    id: root

    implicitWidth: 448
    implicitHeight: statusColumn.implicitHeight + 28

    radius: 18
    color: "#a91b2027"

    border.width: 1
    border.color: "#1e2934"

    readonly property var audio:
        Core.ServiceRegistry.audio

    readonly property var bluetooth:
        Core.ServiceRegistry.bluetooth

    readonly property var network:
        Core.ServiceRegistry.network

    readonly property bool hasBluetoothDevice:
        bluetooth.available
        && bluetooth.connectedDeviceCount > 0

    ColumnLayout {
        id: statusColumn

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        anchors.margins: 14

        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 20

            Text {
                text: "DEVICE STATUS"

                color: "#7f8b9b"

                font.pixelSize: 10
                font.weight: Font.DemiBold
                font.letterSpacing: 1.2
            }

            Item {
                Layout.fillWidth: true
            }

            Text {
                text: {
                    let count = 0

                    if (root.audio.available)
                        count++

                    if (root.hasBluetoothDevice)
                        count++

                    if (root.network.connected)
                        count++

                    return count + " active"
                }

                color: "#667281"
                font.pixelSize: 9
            }
        }

        StatusRow {
            visible: root.hasBluetoothDevice

            iconText: root.bluetooth.icon

            titleText:
                root.bluetooth.primaryDeviceName.length > 0
                    ? root.bluetooth.primaryDeviceName
                    : "Bluetooth device"

            valueText:
                root.bluetooth.primaryDeviceBattery >= 0
                    ? root.bluetooth.primaryDeviceBattery + "%"
                    : "Connected"
        }

        StatusRow {
            visible: root.audio.available

            iconText: root.audio.icon
            titleText: "Audio output"
            valueText: root.audio.sinkName
        }

        StatusRow {
            visible: root.network.connected

            iconText: root.network.icon
            titleText: "Network"

            valueText:
                root.network.ssid.length > 0
                    ? root.network.ssid
                    : root.network.stateName
        }

        Text {
            Layout.fillWidth: true
            Layout.preferredHeight: 36

            visible:
                !root.audio.available
                && !root.hasBluetoothDevice
                && !root.network.connected

            text: "No active devices or connections"
            color: "#778291"

            font.pixelSize: 11

            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
    }

    component StatusRow: Rectangle {
        id: statusRow

        property string iconText: ""
        property string titleText: ""
        property string valueText: ""

        Layout.fillWidth: true
        Layout.preferredHeight: 48

        radius: 13
        color: "#20262e"

        border.width: 1
        border.color: "#29333e"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12

            spacing: 10

            Rectangle {
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                Layout.alignment: Qt.AlignVCenter

                radius: width / 2
                color: "#2d3641"

                Text {
                    anchors.centerIn: parent

                    text: statusRow.iconText
                    color: "#dce3eb"

                    font.pixelSize: 15
                    font.family: "JetBrainsMono Nerd Font"
                }
            }

            Text {
                Layout.fillWidth: true

                text: statusRow.titleText
                color: "#dfe4ea"

                font.pixelSize: 12
                font.weight: Font.Medium

                elide: Text.ElideRight
            }

            Text {
                Layout.maximumWidth: 190

                text: statusRow.valueText
                color: "#8f9baa"

                font.pixelSize: 10

                elide: Text.ElideRight
                horizontalAlignment: Text.AlignRight
            }
        }
    }
}
