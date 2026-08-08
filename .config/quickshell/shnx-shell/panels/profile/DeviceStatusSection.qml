import QtQuick
import QtQuick.Layouts

import qs.core as Core
import qs.theme as ShellTheme

import "../../components/visual" as Visual

Item {
    id: root

    implicitWidth: 448

    implicitHeight:
        root.hasActiveStatus
            ? statusColumn.implicitHeight
            : 0

    visible:
        root.hasActiveStatus

    /*
     * ------------------------------------------------------------
     * SERVICES
     * ------------------------------------------------------------
     */

    readonly property var audio:
        Core.ServiceRegistry.audio

    readonly property var bluetooth:
        Core.ServiceRegistry.bluetooth

    readonly property var network:
        Core.ServiceRegistry.network

    /*
     * ------------------------------------------------------------
     * ACTIVE STATE
     * ------------------------------------------------------------
     */

    readonly property bool hasBluetoothDevice:
        root.bluetooth
        && root.bluetooth.available
        && root.bluetooth.connectedDeviceCount > 0

    readonly property bool hasAudioOutput:
        root.audio
        && root.audio.available

    readonly property bool hasNetworkConnection:
        root.network
        && root.network.connected

    readonly property int activeCount:
        (root.hasAudioOutput ? 1 : 0)
        + (root.hasBluetoothDevice ? 1 : 0)
        + (root.hasNetworkConnection ? 1 : 0)

    readonly property bool hasActiveStatus:
        root.activeCount > 0

    /*
     * ------------------------------------------------------------
     * CONTENT
     * ------------------------------------------------------------
     */

    ColumnLayout {
        id: statusColumn

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        spacing:
            ShellTheme.Theme.spacing.small

        /*
         * SECTION HEADER
         */
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 22

            Text {
                text:
                    "DEVICE STATUS"

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
                    root.activeCount + " active"

                color:
                    ShellTheme.Theme.colors.on_surface_variant

                font.family:
                    ShellTheme.Theme.typography.fontFamily

                font.pixelSize:
                    ShellTheme.Theme.typography.labelSmall
            }
        }

        /*
         * BLUETOOTH DEVICE
         */
        StatusRow {
            visible:
                root.hasBluetoothDevice

            glyph:
                root.bluetooth.icon

            title:
                root.bluetooth.primaryDeviceName.length > 0
                    ? root.bluetooth.primaryDeviceName
                    : "Bluetooth device"

            value:
                root.bluetooth.primaryDeviceBattery >= 0
                    ? root.bluetooth.primaryDeviceBattery + "%"
                    : "Connected"
        }

        /*
         * AUDIO OUTPUT
         */
        StatusRow {
            visible:
                root.hasAudioOutput

            glyph:
                root.audio.icon

            title:
                "Audio output"

            value:
                root.audio.sinkName
        }

        /*
         * NETWORK
         */
        StatusRow {
            visible:
                root.hasNetworkConnection

            glyph:
                root.network.icon

            title:
                "Network"

            value:
                root.network.ssid.length > 0
                    ? root.network.ssid
                    : root.network.stateName
        }
    }

    /*
     * ------------------------------------------------------------
     * STATUS ROW
     * ------------------------------------------------------------
     */

    component StatusRow: Rectangle {
        id: statusRow

        property string glyph: ""
        property string title: ""
        property string value: ""

        Layout.fillWidth: true
        Layout.preferredHeight: 46

        radius:
            ShellTheme.Theme.radius.control

        color:
            ShellTheme.Theme.colors.surfaceContainer

        border.width: 1

        border.color:
            ShellTheme.Theme.colors.outlineVariant

        RowLayout {
            anchors {
                fill: parent

                leftMargin:
                    ShellTheme.Theme.spacing.medium

                rightMargin:
                    ShellTheme.Theme.spacing.medium
            }

            spacing:
                ShellTheme.Theme.spacing.medium

            /*
             * ICON
             */
            Rectangle {
                Layout.preferredWidth: 30
                Layout.preferredHeight: 30
                Layout.alignment: Qt.AlignVCenter

                radius:
                    ShellTheme.Theme.radius.circle

                color:
                    ShellTheme.Theme.colors.surfaceContainerHigh

                Visual.Icon {
                    anchors.centerIn:
                        parent

                    glyph:
                        statusRow.glyph

                    iconSize: 16

                    color:
                        ShellTheme.Theme.colors.on_surface
                }
            }

            /*
             * TITLE
             */
            Text {
                Layout.fillWidth: true

                text:
                    statusRow.title

                color:
                    ShellTheme.Theme.colors.on_surface

                font.family:
                    ShellTheme.Theme.typography.fontFamily

                font.pixelSize:
                    ShellTheme.Theme.typography.labelMedium

                font.weight:
                    Font.Medium

                elide:
                    Text.ElideRight
            }

            /*
             * VALUE
             */
            Text {
                Layout.maximumWidth: 190

                text:
                    statusRow.value

                color:
                    ShellTheme.Theme.colors.on_surface_variant

                font.family:
                    ShellTheme.Theme.typography.fontFamily

                font.pixelSize:
                    ShellTheme.Theme.typography.labelSmall

                elide:
                    Text.ElideRight

                horizontalAlignment:
                    Text.AlignRight
            }
        }
    }
}
