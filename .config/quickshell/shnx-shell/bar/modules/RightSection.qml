import QtQuick

import qs.core as Core
import qs.theme as ShellTheme

Item {
    id: root

    implicitWidth:
        contentRow.implicitWidth

    implicitHeight:
        32

    Row {
        id: contentRow

        anchors.fill:
            parent

        spacing:
            ShellTheme.Theme.spacing.small

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

        NotificationButton {
            id: notificationButton

            onClicked: {
                Core.PanelController.toggleNotifications(
                    notificationButton
                )
            }
        }

        PowerButton {
            id: powerButton

            onClicked: {
                Core.PanelController.togglePower(
                    powerButton
                )
            }
        }
    }
}
