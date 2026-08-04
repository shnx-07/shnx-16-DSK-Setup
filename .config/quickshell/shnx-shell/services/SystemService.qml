import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property bool busy: false
    property string activeAction: ""
    property string lastError: ""

    readonly property bool lockAvailable: true
    readonly property bool suspendAvailable: true
    readonly property bool logoutAvailable:
        Quickshell.env("XDG_SESSION_ID").length > 0

    readonly property bool rebootAvailable: true
    readonly property bool shutdownAvailable: true

    signal actionStarted(string action)
    signal actionFinished(string action)
    signal actionFailed(string action, string message)

    function lock() {
        runAction(
            "lock",
            ["loginctl", "lock-session"]
        )
    }

    function suspend() {
        runAction(
            "suspend",
            ["systemctl", "suspend"]
        )
    }

    function logout() {
        const sessionId =
            Quickshell.env("XDG_SESSION_ID")

        if (!sessionId || sessionId.length === 0) {
            fail(
                "logout",
                "XDG_SESSION_ID is unavailable."
            )
            return
        }

        runAction(
            "logout",
            [
                "loginctl",
                "terminate-session",
                sessionId
            ]
        )
    }

    function reboot() {
        runAction(
            "reboot",
            ["systemctl", "reboot"]
        )
    }

    function shutdown() {
        runAction(
            "shutdown",
            ["systemctl", "poweroff"]
        )
    }

    function runAction(action, command) {
        if (busy)
            return false

        busy = true
        activeAction = action
        lastError = ""

        actionStarted(action)
        actionProcess.exec(command)

        return true
    }

    function fail(action, message) {
        busy = false
        activeAction = ""
        lastError = message

        actionFailed(action, message)
    }

    property Process actionProcess: Process {
        stderr: StdioCollector {
            id: errorCollector
        }

        onExited: (exitCode, exitStatus) => {
            const completedAction =
                root.activeAction

            const errorText =
                errorCollector.text.trim()

            root.busy = false
            root.activeAction = ""

            if (exitCode === 0) {
                root.lastError = ""
                root.actionFinished(completedAction)
                return
            }

            root.lastError =
                errorText.length > 0
                    ? errorText
                    : "Action failed with exit code "
                        + exitCode

            root.actionFailed(
                completedAction,
                root.lastError
            )
        }
    }
}
