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

    readonly property var nightLight:
        Core.ServiceRegistry.nightLight

    readonly property var vpn:
        Core.ServiceRegistry.vpn

    /*
     * ------------------------------------------------------------
     * TEMPORARY STATES
     * ------------------------------------------------------------
     *
     * Keep these exactly as local prototype states for now.
     * We will wire real services in a separate pass.
     */

    property bool airplaneModeEnabled: false
    property bool microphoneMuted: false

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

            /*
             * Bluetooth
             */
            QuickSettingTile {
                Layout.fillWidth: true
                Layout.fillHeight: true

                iconText:
                    root.bluetooth.icon

                title:
                    "Bluetooth"

                subtitle: {
                    if (!root.bluetooth.available)
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

            /*
             * Do Not Disturb
             */
            QuickSettingTile {
                Layout.fillWidth: true
                Layout.fillHeight: true

                iconText:
                    root.notifications.doNotDisturb
                        ? "󰂛"
                        : "󰂚"

                title:
                    "Do Not Disturb"

                subtitle:
                    root.notifications.doNotDisturb
                        ? "Enabled"
                        : "Off"

                active:
                    root.notifications.doNotDisturb

                onToggled: {
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
                      root.nightLight.enabled
                          ? "Enabled"
                          : "Off"

                  active:
                      root.nightLight.enabled

                  onToggled: {
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
                      if (!root.vpn.hasProfile)
                          return "No profile"

                      if (root.vpn.isConnected)
                          return root.vpn.connectionName.length > 0
                              ? root.vpn.connectionName
                              : "Connected"

                      return "Disconnected"
                  }

                  active:
                      root.vpn.isConnected

                  available:
                      root.vpn.hasProfile

                  onToggled: {
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

            /*
             * Microphone
             */
            QuickSettingTile {
                Layout.fillWidth: true
                Layout.fillHeight: true

                iconText:
                    root.microphoneMuted
                        ? "󰍭"
                        : "󰍬"

                title:
                    "Microphone"

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
