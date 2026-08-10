import QtQuick
import Quickshell.Bluetooth

QtObject {
    id: root

    readonly property var adapter:
        Bluetooth.defaultAdapter

    readonly property bool available:
        adapter !== null
        && adapter !== undefined

    readonly property bool enabled:
        available && adapter.enabled === true

    readonly property bool discovering:
        available && adapter.discovering === true

    readonly property var devices:
        Bluetooth.devices

    readonly property var connectedDevices: {
        if (!devices || !devices.values)
            return []

        return devices.values.filter(function(device) {
            return device
                && device.connected === true
        })
    }

    readonly property int connectedDeviceCount:
        connectedDevices.length

    readonly property bool connected:
        connectedDeviceCount > 0

    readonly property var primaryDevice:
        connected
            ? connectedDevices[0]
            : null

    readonly property string primaryDeviceName:
        primaryDevice && primaryDevice.name
            ? primaryDevice.name
            : ""

    readonly property bool primaryDeviceHasBattery:
        primaryDevice !== null
        && primaryDevice !== undefined
        && primaryDevice.batteryAvailable === true

    readonly property int primaryDeviceBattery:
        primaryDeviceHasBattery
            ? Math.round(primaryDevice.battery * 100)
            : -1

    readonly property string stateName: {
        if (!available)
            return "No Bluetooth adapter"

        if (!enabled)
            return "Bluetooth disabled"

        if (connectedDeviceCount === 1)
            return "1 device connected"

        if (connectedDeviceCount > 1)
            return connectedDeviceCount
                + " devices connected"

        return "Not connected"
    }

    readonly property string icon: {
        if (!available || !enabled)
            return "󰂲"

        if (connected)
            return "󰂱"

        return "󰂯"
    }

    function setEnabled(value) {
        if (!available)
            return

        adapter.enabled = value
    }

    function toggleEnabled() {
        setEnabled(!enabled)
    }

    function setDiscovering(value) {
        if (!available || !enabled)
            return

        adapter.discovering = value
    }

    function disconnectDevice(device) {
        if (device && device.connected)
            device.disconnect()
    }

    function connectDevice(device) {
        if (device && !device.connected)
            device.connect()
    }
}
