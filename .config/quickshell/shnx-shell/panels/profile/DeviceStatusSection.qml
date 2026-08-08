import QtQuick
import QtQuick.Layouts
import qs.core as Core
import qs.theme as ShellTheme

Rectangle {
    id: root

    implicitWidth: 448
    implicitHeight: statusColumn.implicitHeight + 28

    radius: ShellTheme.Theme.radius.large
    color: ShellTheme.Theme.colors.surfaceContainerLow

    border.width: 1
    border.color: ShellTheme.Theme.colors.outlineVariant

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

                color: ShellTheme.Theme.colors.on_surface_variant

                font.pixelSize: ShellTheme.Theme.typography.labelSmall
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

                color: ShellTheme.Theme.colors.on_surface_variant
                font.pixelSize: ShellTheme.Theme.typography.labelSmall
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
            color: ShellTheme.Theme.colors.on_surface_variant

            font.pixelSize: ShellTheme.Theme.typography.labelMedium

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

        radius: ShellTheme.Theme.radius.medium
        color: ShellTheme.Theme.colors.surfaceContainer

        border.width: 1
        border.color: ShellTheme.Theme.colors.outlineVariant

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
                color: ShellTheme.Theme.colors.surfaceContainerHigh

                Text {
                    anchors.centerIn: parent

                    text: statusRow.iconText
                    color: ShellTheme.Theme.colors.on_surface

                    font.pixelSize: ShellTheme.Theme.typography.titleSmall
                    font.family: "JetBrainsMono Nerd Font"
                }
            }

            Text {
                Layout.fillWidth: true

                text: statusRow.titleText
                color: ShellTheme.Theme.colors.on_surface

                font.pixelSize: ShellTheme.Theme.typography.labelMedium
                font.weight: Font.Medium

                elide: Text.ElideRight
            }

            Text {
                Layout.maximumWidth: 190

                text: statusRow.valueText
                color: ShellTheme.Theme.colors.on_surface_variant

                font.pixelSize: ShellTheme.Theme.typography.labelSmall

                elide: Text.ElideRight
                horizontalAlignment: Text.AlignRight
            }
        }
    }
}
