import QtQuick
import Quickshell.Io

QtObject {
    id: root

    // Whether any VPN connection is currently active
    readonly property bool isConnected: _activeVpnName !== ""
    property string _activeVpnName: ""
    property string connectionName: _activeVpnName

    // Name of the first available (non-active) VPN profile
    property string availableProfileName: ""
    readonly property bool hasProfile: availableProfileName !== "" || isConnected

    function toggle(): void {
        if (isConnected) {
            _disconnectProcess.command = ["nmcli", "connection", "down", _activeVpnName]
            _disconnectProcess.running = true
        } else if (availableProfileName !== "") {
            _connectProcess.command = ["nmcli", "connection", "up", availableProfileName]
            _connectProcess.running = true
        }
    }

    // Poll active connections every 5 seconds
    property Timer _pollTimer: Timer {
        interval: 5000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            _statusProcess.running = false
            _statusProcess.running = true
        }
    }

    // Check active VPN connections
    property Process _statusProcess: Process {
        command: ["nmcli", "-t", "-f", "NAME,TYPE,STATE", "connection", "show", "--active"]
        running: false
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) {
                if (!line || line.trim() === "") return
                // Format: NAME:TYPE:STATE
                const parts = line.split(":")
                if (parts.length >= 2) {
                    const type = parts[1] || ""
                    const name = parts[0] || ""
                    if (type === "vpn" || type === "wireguard") {
                        root._activeVpnName = name
                    }
                }
            }
        }
        onExited: function(code, status) {
            // If we got an exit, and nothing set _activeVpnName, clear it
            // (handled by resetAndPoll)
        }
    }

    // Poll available VPN profiles (not necessarily active)
    property Timer _profilePollTimer: Timer {
        interval: 15000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            _profileProcess.running = false
            _profileProcess.running = true
        }
    }

    property string _firstProfileFound: ""

    property Process _profileProcess: Process {
        command: ["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show"]
        running: false
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) {
                if (!line || line.trim() === "") return
                const parts = line.split(":")
                if (parts.length >= 2) {
                    const type = parts[1] || ""
                    const name = parts[0] || ""
                    if ((type === "vpn" || type === "wireguard") && root.availableProfileName === "") {
                        root.availableProfileName = name
                    }
                }
            }
        }
    }

    property Process _connectProcess: Process {
        command: ["nmcli", "connection", "up", ""]
        running: false
        onExited: function(code, status) {
            if (code !== 0)
                console.warn("[VpnService] VPN connect failed, code:", code)
            // Re-poll status
            _pollTimer.restart()
        }
    }

    property Process _disconnectProcess: Process {
        command: ["nmcli", "connection", "down", ""]
        running: false
        onExited: function(code, status) {
            if (code !== 0)
                console.warn("[VpnService] VPN disconnect failed, code:", code)
            root._activeVpnName = ""
            _pollTimer.restart()
        }
    }
}
