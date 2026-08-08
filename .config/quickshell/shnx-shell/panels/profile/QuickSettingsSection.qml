import QtQuick
import QtQuick.Layouts
import qs.core as Core
import qs.theme as ShellTheme

Rectangle {
    id: root

    implicitWidth: 448
    implicitHeight: 340

    radius: ShellTheme.Theme.radius.panel
    color: ShellTheme.Theme.colors.surfaceContainerLow

    border.width: 1
    border.color: ShellTheme.Theme.colors.outlineVariant

    readonly property var network:
        Core.ServiceRegistry.network

    readonly property var bluetooth:
        Core.ServiceRegistry.bluetooth

    readonly property var battery:
        Core.ServiceRegistry.battery

    /*
     * Temporary prototype states.
     * These will later move into their appropriate services.
     */
    property bool dndEnabled: false
    property bool nightLightEnabled: false
    property bool vpnEnabled: false
    property bool airplaneModeEnabled: false
    property bool microphoneMuted: false

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14

        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 22

            Text {
                text: "QUICK SETTINGS"

                color: ShellTheme.Theme.colors.on_surface_variant

                font.pixelSize: ShellTheme.Theme.typography.labelSmall
                font.weight: Font.DemiBold
                font.letterSpacing: 1.2
            }

            Item {
                Layout.fillWidth: true
            }

            Text {
                text: "8 controls"

                color: ShellTheme.Theme.colors.on_surface_variant
                font.pixelSize: ShellTheme.Theme.typography.labelSmall
            }
        }

        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            columns: 2
            columnSpacing: 10
            rowSpacing: 10

            QuickSettingTile {
                Layout.fillWidth: true
                Layout.fillHeight: true

                iconText: root.network.icon
                title: "Wi-Fi"

                subtitle: {
                    if (!root.network.available)
                        return "Unavailable"

                    if (!root.network.wifiEnabled)
                        return "Off"

                    if (root.network.connected)
                        return root.network.ssid

                    return root.network.stateName
                }

                active:
                    root.network.available
                    && root.network.wifiEnabled

                available:
                    root.network.available
                    && root.network.wifiHardwareEnabled

                showDetailButton: true

                onToggled: {
                    root.network.toggleWifi()
                }

                onDetailRequested: {
                    Core.PanelController.openQuickSettings(
                        "wifi",
                        Core.PanelController.anchorItem
                    )
                }
            }

            QuickSettingTile {
                Layout.fillWidth: true
                Layout.fillHeight: true

                iconText: root.bluetooth.icon
                title: "Bluetooth"

                subtitle: {
                    if (!root.bluetooth.available)
                        return "Unavailable"

                    if (!root.bluetooth.enabled)
                        return "Off"

                    if (root.bluetooth.connectedDeviceCount > 0) {
                        return root.bluetooth.connectedDeviceCount
                            + (
                                root.bluetooth.connectedDeviceCount === 1
                                    ? " connected"
                                    : " connected"
                            )
                    }

                    return root.bluetooth.stateName
                }

                active:
                    root.bluetooth.available
                    && root.bluetooth.enabled

                available:
                    root.bluetooth.available

                showDetailButton: true

                onToggled: {
                    root.bluetooth.toggleEnabled()
                }

                onDetailRequested: {
                    Core.PanelController.openQuickSettings(
                        "bluetooth",
                        Core.PanelController.anchorItem
                    )
                }
            }

            QuickSettingTile {
                Layout.fillWidth: true
                Layout.fillHeight: true

                iconText:
                    root.dndEnabled
                        ? "󰂛"
                        : "󰂚"

                title: "Do Not Disturb"

                subtitle:
                    root.dndEnabled
                        ? "Enabled"
                        : "Off"

                active: root.dndEnabled

                onToggled: {
                    root.dndEnabled =
                        !root.dndEnabled
                }
            }

            QuickSettingTile {
                Layout.fillWidth: true
                Layout.fillHeight: true

                iconText: "󰖔"
                title: "Night Light"

                subtitle:
                    root.nightLightEnabled
                        ? "Enabled"
                        : "Off"

                active:
                    root.nightLightEnabled

                onToggled: {
                    root.nightLightEnabled =
                        !root.nightLightEnabled
                }
            }

            QuickSettingTile {
                Layout.fillWidth: true
                Layout.fillHeight: true

                iconText: "󰖂"
                title: "VPN"

                subtitle:
                    root.vpnEnabled
                        ? "Connected"
                        : "Disconnected"

                active:
                    root.vpnEnabled

                onToggled: {
                    root.vpnEnabled =
                        !root.vpnEnabled
                }
            }

            QuickSettingTile {
                Layout.fillWidth: true
                Layout.fillHeight: true

                iconText: "󰀝"
                title: "Airplane Mode"

                subtitle:
                    root.airplaneModeEnabled
                        ? "Enabled"
                        : "Off"

                active:
                    root.airplaneModeEnabled

                onToggled: {
                    root.airplaneModeEnabled =
                        !root.airplaneModeEnabled
                }
            }

            QuickSettingTile {
                Layout.fillWidth: true
                Layout.fillHeight: true

                iconText:
                    root.microphoneMuted
                        ? "󰍭"
                        : "󰍬"

                title: "Microphone"

                subtitle:
                    root.microphoneMuted
                        ? "Muted"
                        : "Active"

                active:
                    root.microphoneMuted

                onToggled: {
                    root.microphoneMuted =
                        !root.microphoneMuted
                }
            }

            QuickSettingTile {
                Layout.fillWidth: true
                Layout.fillHeight: true

                iconText:
                    root.battery.powerSaverEnabled
                        ? "󰌪"
                        : "󰁹"

                title: "Battery Saver"

                subtitle:
                    root.battery.powerSaverEnabled
                        ? "Enabled"
                        : "Off"

                active:
                    root.battery.powerSaverEnabled

                available:
                    root.battery.available

                onToggled: {
                    root.battery.togglePowerSaver()
                }
            }
        }
    }
}
