import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property bool ready: false
    property string errorMessage: ""

    property string username: ""
    property string displayName: ""
    property string hostname: ""
    property string distribution: ""
    property string kernelVersion: ""
    property string sessionName: ""
    property string uptime: ""
    property string avatarPath: ""

    readonly property string usernameLabel:
        username.length > 0
            ? "@" + username
            : "@user"

    readonly property string displayNameLabel:
        displayName.length > 0
            ? displayName
            : username.length > 0
                ? username
                : "User"

    readonly property string hostnameLabel:
        hostname.length > 0
            ? hostname
            : "Unknown host"

    readonly property string distributionLabel:
        distribution.length > 0
            ? distribution
            : "Linux"

    readonly property string sessionLabel:
        sessionName.length > 0
            ? sessionName
            : "Wayland"

    readonly property string kernelLabel:
        kernelVersion.length > 0
            ? kernelVersion
            : "Unknown kernel"

    readonly property string uptimeLabel:
        uptime.length > 0
            ? uptime
            : "Uptime unavailable"

    readonly property bool hasCustomAvatar:
        avatarPath.length > 0

    /*
     * All owner/system information is collected in one process.
     * Visual files must not execute shell commands themselves.
     */
    property Process identityProcess: Process {
        id: identityProcess

        command: [
            "sh",
            "-c",
            `
            username="$(id -un 2>/dev/null)"
            display_name="$(getent passwd "$username" 2>/dev/null | cut -d: -f5 | cut -d, -f1)"
            hostname_value="$(hostname 2>/dev/null)"

            if [ -r /etc/os-release ]; then
                distribution_value="$(
                    . /etc/os-release
                    printf '%s' "\${PRETTY_NAME:-\${NAME:-Linux}}"
                )"
            else
                distribution_value="Linux"
            fi

            kernel_value="$(uname -r 2>/dev/null)"

            session_value="\${XDG_CURRENT_DESKTOP:-\${XDG_SESSION_DESKTOP:-\${DESKTOP_SESSION:-Wayland}}}"

            uptime_value="$(uptime -p 2>/dev/null | sed 's/^up //')"

            avatar_value=""

            if [ -f "$HOME/.face" ]; then
                avatar_value="$HOME/.face"
            elif [ -f "$HOME/.face.icon" ]; then
                avatar_value="$HOME/.face.icon"
            fi

            printf 'username=%s\\n' "$username"
            printf 'displayName=%s\\n' "$display_name"
            printf 'hostname=%s\\n' "$hostname_value"
            printf 'distribution=%s\\n' "$distribution_value"
            printf 'kernelVersion=%s\\n' "$kernel_value"
            printf 'sessionName=%s\\n' "$session_value"
            printf 'uptime=%s\\n' "$uptime_value"
            printf 'avatarPath=%s\\n' "$avatar_value"
            `
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                root.applyIdentityOutput(text)
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                const message = text.trim()

                if (message.length > 0) {
                    root.errorMessage = message

                    console.warn(
                        "[ProfileService]",
                        message
                    )
                }
            }
        }
    }

    function applyIdentityOutput(output) {
        const lines = output.split("\n")

        for (let index = 0; index < lines.length; index++) {
            const line = lines[index]
            const separatorIndex = line.indexOf("=")

            if (separatorIndex < 0)
                continue

            const key =
                line.substring(0, separatorIndex)

            const value =
                line.substring(separatorIndex + 1).trim()

            switch (key) {
            case "username":
                username = value
                break

            case "displayName":
                displayName = value
                break

            case "hostname":
                hostname = value
                break

            case "distribution":
                distribution = value
                break

            case "kernelVersion":
                kernelVersion = value
                break

            case "sessionName":
                sessionName = normalizeSession(value)
                break

            case "uptime":
                uptime = value
                break

            case "avatarPath":
                avatarPath = value
                break
            }
        }

        ready = true
        errorMessage = ""

        console.log(
            "[ProfileService] Loaded profile for",
            username
        )
    }

    function normalizeSession(value) {
        if (!value || value.length === 0)
            return "Wayland"

        const parts = value.split(":")

        for (let index = 0; index < parts.length; index++) {
            const part = parts[index].trim()

            if (part.toLowerCase().indexOf("hyprland") >= 0)
                return "Hyprland"
        }

        return parts[0]
    }

    function refresh() {
        if (identityProcess.running)
            return

        ready = false
        errorMessage = ""
        identityProcess.running = true
    }

    /*
     * Avatar-changing actions are reserved here so visual components
     * can delegate to ProfileService. File selection is added next.
     */
    function selectAvatar() {
        console.log(
            "[ProfileService] Avatar selection requested"
        )
    }

    function resetAvatar() {
        console.log(
            "[ProfileService] Avatar reset requested"
        )
    }
}
