import QtQuick
import Quickshell.Networking

QtObject {
    id: root

    readonly property bool wifiEnabled:
        Networking.wifiEnabled

    readonly property bool wifiHardwareEnabled:
        Networking.wifiHardwareEnabled

    readonly property var devices:
        Networking.devices

    readonly property var wifiDevice: {
        const deviceList = Networking.devices.values

        for (let index = 0; index < deviceList.length; index++) {
            const device = deviceList[index]

            if (device.type === DeviceType.Wifi)
                return device
        }

        return null
    }

    readonly property bool available:
        wifiDevice !== null

    readonly property bool connected:
        available && wifiDevice.connected

    readonly property var networks:
        available
            ? wifiDevice.networks
            : null

    readonly property var connectedNetwork: {
        if (!available || !wifiDevice.networks)
            return null

        const networkList = wifiDevice.networks.values

        for (let index = 0; index < networkList.length; index++) {
            const network = networkList[index]

            if (network.connected)
                return network
        }

        return null
    }

    readonly property string ssid:
        connectedNetwork
            ? connectedNetwork.name
            : ""

    readonly property real signalStrength:
        connectedNetwork
            ? connectedNetwork.signalStrength
            : 0

    readonly property int signalPercentage:
        Math.round(signalStrength * 100)

    readonly property string stateName: {
        if (!available)
            return "No Wi-Fi device"

        if (!wifiHardwareEnabled)
            return "Hardware disabled"

        if (!wifiEnabled)
            return "Wi-Fi disabled"

        if (connected)
            return "Connected"

        return "Disconnected"
    }

    readonly property string icon: {
        if (!available || !wifiHardwareEnabled)
            return "󰤭"

        if (!wifiEnabled)
            return "󰤭"

        if (!connectedNetwork)
            return "󰤯"

        if (signalStrength >= 0.75)
            return "󰤨"

        if (signalStrength >= 0.50)
            return "󰤥"

        if (signalStrength >= 0.25)
            return "󰤢"

        return "󰤟"
    }

    function setWifiEnabled(enabled) {
        if (!wifiHardwareEnabled)
            return

        Networking.wifiEnabled = enabled
    }

    function toggleWifi() {
        setWifiEnabled(!wifiEnabled)
    }

    function enableScanning(enabled) {
        if (!wifiDevice)
            return

        wifiDevice.scannerEnabled = enabled
    }
}
