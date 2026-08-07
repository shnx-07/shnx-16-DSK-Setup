import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property bool enabled: false

    // Temperature in Kelvin when enabled (warm = lower value)
    property int temperature: 4000

    function enable(): void {
        enabled = true
        _applyProcess.command = ["gammastep", "-O", String(temperature)]
        _applyProcess.running = true
    }

    function disable(): void {
        enabled = false
        _resetProcess.command = ["gammastep", "-x"]
        _resetProcess.running = true
    }

    function toggle(): void {
        if (enabled)
            disable()
        else
            enable()
    }

    property Process _applyProcess: Process {
        command: ["gammastep", "-O", "4000"]
        running: false
        onExited: function(code, status) {
            if (code !== 0)
                console.warn("[NightLightService] gammastep enable failed, code:", code)
        }
    }

    property Process _resetProcess: Process {
        command: ["gammastep", "-x"]
        running: false
        onExited: function(code, status) {
            if (code !== 0)
                console.warn("[NightLightService] gammastep reset failed, code:", code)
        }
    }
}
