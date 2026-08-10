import QtQuick
import QtQuick.Layouts

import qs.core as Core
import qs.theme as ShellTheme

Item {
    id: root

    implicitWidth: 448
    implicitHeight: 320

    /*
     * ------------------------------------------------------------
     * SERVICES
     * ------------------------------------------------------------
     */

    readonly property var network:
        Core.ServiceRegistry.network

    readonly property var bluetooth:
        Core.ServiceRegistry.bluetooth

    readonly property var battery:
    Core.ServiceRegistry.battery

    readonly property var notifications:
    Core.ServiceRegistry.notifications

    readonly property var audio:
        Core.ServiceRegistry.audio

    readonly property var nightLight:
        Core.ServiceRegistry.nightLight

    readonly property var vpn:
        Core.ServiceRegistry.vpn

    readonly property bool airplaneModeActive:
        root.network && root.bluetooth
            ? (!root.network.wifiEnabled && !root.bluetooth.enabled)
            : false

    function toggleAirplaneMode() {
        if (!root.network || !root.bluetooth)
            return

        const enableRadios = airplaneModeActive
        root.network.setWifiEnabled(enableRadios)
        root.bluetooth.setEnabled(enableRadios)
    }

    ColumnLayout {
        anchors.fill: parent

        spacing:
            ShellTheme.Theme.spacing.medium

        /*
         * --------------------------------------------------------
         * SECTION HEADER
         * --------------------------------------------------------
         */

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 22

            Text {
                text:
                    "QUICK SETTINGS"

                color:
                    ShellTheme.Theme.colors.on_surface_variant

                font.family:
                    ShellTheme.Theme.typography.fontFamily

                font.pixelSize:
                    ShellTheme.Theme.typography.labelSmall

                font.weight:
                    Font.DemiBold

                font.letterSpacing:
                    1.2
            }

            Item {
                Layout.fillWidth: true
            }

            Text {
                text:
                    "8 controls"

                color:
                    ShellTheme.Theme.colors.on_surface_variant

                font.family:
                    ShellTheme.Theme.typography.fontFamily

                font.pixelSize:
                    ShellTheme.Theme.typography.labelSmall
            }
        }

        /*
         * --------------------------------------------------------
         * QUICK SETTINGS GRID
         * --------------------------------------------------------
         */

        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            columns: 2

            columnSpacing:
                ShellTheme.Theme.spacing.small

            rowSpacing:
                ShellTheme.Theme.spacing.small

            /*
             * Wi-Fi
             */
            QuickSettingTile {
                Layout.fillWidth: true
                Layout.fillHeight: true

                iconText:
                    root.network.icon

                title:
                    "Wi-Fi"

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
                    Boolean(root.network && root.network.available && root.network.wifiEnabled)

                available:
                    Boolean(root.network && root.network.available && root.network.wifiHardwareEnabled)

                showDetailButton: true

                onToggled: {
                    if (root.network)
                        root.network.toggleWifi()
                }

                onDetailRequested: {
                    Core.PanelController.openQuickSettings(
                        "wifi",
                        Core.PanelController.anchorItem
                    )
                }
            }

            /*
             * Bluetooth
             */
            QuickSettingTile {
                Layout.fillWidth: true
                Layout.fillHeight: true

                iconText:
                    root.bluetooth ? root.bluetooth.icon : ""

                title:
                    "Bluetooth"

                subtitle: {
                    if (!root.bluetooth || !root.bluetooth.available)
                        return "Unavailable"

                    if (!root.bluetooth.enabled)
                        return "Off"

                    if (
                        root.bluetooth.connectedDeviceCount > 0
                    ) {
                        return root.bluetooth
                            .connectedDeviceCount
                            + " connected"
                    }

                    return root.bluetooth.stateName
                }

                active:
                    Boolean(root.bluetooth && root.bluetooth.available && root.bluetooth.enabled)

                available:
                    Boolean(root.bluetooth && root.bluetooth.available)

                showDetailButton: true

                onToggled: {
                    if (root.bluetooth)
                        root.bluetooth.toggleEnabled()
                }

                onDetailRequested: {
                    Core.PanelController.openQuickSettings(
                        "bluetooth",
                        Core.PanelController.anchorItem
                    )
                }
            }

            /*
             * Do Not Disturb
             */
            QuickSettingTile {
                Layout.fillWidth: true
                Layout.fillHeight: true

                iconText:
                    root.notifications && root.notifications.doNotDisturb
                        ? "󰂛"
                        : "󰂚"

                title:
                    "Do Not Disturb"

                subtitle:
                    root.notifications && root.notifications.doNotDisturb
                        ? "Enabled"
                        : "Off"

                active:
                    Boolean(root.notifications && root.notifications.doNotDisturb)

                onToggled: {
                    if (root.notifications)
                        root.notifications.toggleDoNotDisturb()
                }
            }

            /*
             * Night Light
             */
            QuickSettingTile {
                  Layout.fillWidth: true
                  Layout.fillHeight: true

                  iconText:
                      "󰖔"

                  title:
                      "Night Light"

                  subtitle:
                      root.nightLight && root.nightLight.enabled
                          ? "Enabled"
                          : "Off"

                  active:
                      Boolean(root.nightLight && root.nightLight.enabled)

                  onToggled: {
                      if (root.nightLight)
                          root.nightLight.toggle()
                  }
              }

            /*
             * VPN
             */
            QuickSettingTile {
                  Layout.fillWidth: true
                  Layout.fillHeight: true

                  iconText:
                      "󰖂"

                  title:
                      "VPN"

                  subtitle: {
                      if (!root.vpn || !root.vpn.hasProfile)
                          return "No profile"

                      if (root.vpn.isConnected)
                          return root.vpn.connectionName && root.vpn.connectionName.length > 0
                              ? root.vpn.connectionName
                              : "Connected"

                      return "Disconnected"
                  }

                  active:
                      Boolean(root.vpn && root.vpn.isConnected)

                  available:
                      Boolean(root.vpn && root.vpn.hasProfile)

                  onToggled: {
                      if (root.vpn)
                          root.vpn.toggle()
                  }
              }

            /*
             * Airplane Mode
             */
            QuickSettingTile {
                Layout.fillWidth: true
                Layout.fillHeight: true

                iconText:
                    "󰀝"

                title:
                    "Airplane Mode"

                subtitle:
                    root.airplaneModeActive
                        ? "Enabled"
                        : "Off"

                active:
                    Boolean(root.airplaneModeActive)

                onToggled: {
                    root.toggleAirplaneMode()
                }
            }

            /*
             * Microphone
             */
            QuickSettingTile {
                Layout.fillWidth: true
                Layout.fillHeight: true

                iconText:
                    root.audio && root.audio.microphoneMuted
                        ? "󰍭"
                        : "󰍬"

                title:
                    "Microphone"

                subtitle:
                    root.audio && root.audio.microphoneMuted
                        ? "Muted"
                        : "Active"

                active:
                    Boolean(root.audio && root.audio.microphoneMuted)

                available:
                    Boolean(root.audio && root.audio.sourceAvailable)

                onToggled: {
                    if (root.audio)
                        root.audio.toggleMicrophoneMute()
                }
            }

            /*
             * Battery Saver
             */
            QuickSettingTile {
                Layout.fillWidth: true
                Layout.fillHeight: true

                iconText:
                    root.battery.powerSaverEnabled
                        ? "󰌪"
                        : "󰁹"

                title:
                    "Battery Saver"

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

