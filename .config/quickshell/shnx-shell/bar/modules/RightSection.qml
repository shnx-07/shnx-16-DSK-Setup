import QtQuick
import qs.core as Core

Item {
    id: root

    implicitWidth: contentRow.implicitWidth
    implicitHeight: 32

    Row {
        id: contentRow

        anchors.fill: parent
        spacing: 8

        BatteryIndicator {
            id: batteryButton

            onClicked: {
                Core.PanelController.toggleBattery(
                    batteryButton
                )
            }
        }

        WifiIndicator {
            id: wifiButton

            onClicked: {
                Core.PanelController.toggleWifi(
                    wifiButton
                )
            }
        }

        BluetoothIndicator {
            id: bluetoothButton

            onClicked: {
                Core.PanelController.toggleBluetooth(
                    bluetoothButton
                )
            }
        }

        QuickSettingsButton {
            id: quickSettingsButton

            onClicked: {
                Core.PanelController.toggleQuickSettings(
                    "overview",
                    quickSettingsButton
                )
            }
        }

        PowerButton {
            onClicked:
                console.log("Power menu later")
        }
    }
}
