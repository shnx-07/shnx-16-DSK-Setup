
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    readonly property int protocolVersion: 1

    readonly property string runtimeDirectory: {
        const runtimeDir = Quickshell.env("XDG_RUNTIME_DIR")

        if (runtimeDir && runtimeDir.length > 0)
            return runtimeDir

        return "/tmp/shnx-shell-" + Quickshell.env("UID")
    }

    readonly property string socketPath:
        runtimeDirectory + "/shnx-shell/backend.sock"

    property bool online: false
    property bool handshakeComplete: false

    property string backendVersion: ""
    property string lastError: ""

    property int reconnectAttempt: 0
    property int nextRequestNumber: 0

    readonly property int reconnectDelay: Math.min(
        30000,
        1000 * Math.pow(
            2,
            Math.min(reconnectAttempt, 5)
        )
    )

    signal responseReceived(
        string command,
        string requestId,
        var payload
    )

    signal eventReceived(
        string eventName,
        var payload
    )

    function createRequestId() {
        nextRequestNumber += 1

        return "qml-"
            + Date.now()
            + "-"
            + nextRequestNumber
    }

    function sendCommand(command, payload) {
        if (!backendSocket.connected) {
            lastError =
                "Backend is offline; command was not sent."

            return ""
        }

        const requestId = createRequestId()

        const message = {
            protocol_version: protocolVersion,
            type: "command",
            request_id: requestId,
            command: command,
            payload: payload || {}
        }

        backendSocket.write(
            JSON.stringify(message) + "\n"
        )

        backendSocket.flush()

        return requestId
    }

    function beginHandshake() {
        handshakeComplete = false
        online = false
        lastError = ""

        sendCommand("hello", {})
    }

    function scheduleReconnect() {
        if (reconnectTimer.running)
            return

        reconnectAttempt += 1
        reconnectTimer.interval = reconnectDelay
        reconnectTimer.restart()
    }

    function handleIncomingMessage(rawMessage) {
        if (!rawMessage || rawMessage.length === 0)
            return

        let message

        try {
            message = JSON.parse(rawMessage)
        } catch (error) {
            lastError =
                "Backend sent invalid JSON: " + error

            return
        }

        if (
            message.protocol_version
            !== protocolVersion
        ) {
            lastError =
                "Backend protocol mismatch. Expected "
                + protocolVersion
                + ", received "
                + message.protocol_version
                + "."

            online = false
            handshakeComplete = false
            backendSocket.connected = false

            return
        }

        if (message.type === "error") {
            const backendError =
                message.error || {}

            lastError =
                backendError.message
                || "Unknown backend error."

            return
        }

        if (message.type === "event") {
            eventReceived(
                message.event || "",
                message.payload || {}
            )

            return
        }

        if (message.type !== "response")
            return

        const command = message.command || ""
        const requestId = message.request_id || ""
        const payload = message.payload || {}

        if (command === "hello") {
            if (
                payload.protocol_version
                !== protocolVersion
            ) {
                lastError =
                    "Handshake protocol mismatch."

                online = false
                handshakeComplete = false
                backendSocket.connected = false

                return
            }

            backendVersion =
                payload.backend_version || ""

            reconnectAttempt = 0
            handshakeComplete = true
            online = true
            lastError = ""
        }

        responseReceived(
            command,
            requestId,
            payload
        )
    }

    function ping() {
        return sendCommand("ping", {})
    }

    property Socket backendSocket: Socket {
        path: root.socketPath
        connected: true

        parser: SplitParser {
            splitMarker: "\n"

            onRead: data => {
                root.handleIncomingMessage(data)
            }
        }

        onConnectedChanged: {
            if (connected) {
                root.beginHandshake()
                return
            }

            root.online = false
            root.handshakeComplete = false
            root.scheduleReconnect()
        }

        onError: error => {
            root.online = false
            root.handshakeComplete = false
            root.lastError =
                "Backend socket error: " + error

            root.scheduleReconnect()
        }
    }

    property Timer reconnectTimer: Timer {
        repeat: false
        interval: root.reconnectDelay

        onTriggered: {
            if (backendSocket.connected)
                return

            backendSocket.connected = true
        }
    }

    property Timer heartbeatTimer: Timer {
        interval: 30000
        repeat: true
        running: root.online

        onTriggered: root.ping()
    }
}
