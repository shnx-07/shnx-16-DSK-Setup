import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property bool available: false
    property bool ready: false
    property bool changing: false

    property real brightness: 0
    property string deviceName: ""
    property string errorMessage: ""

    readonly property int brightnessPercentage:
        Math.round(brightness * 100)

    readonly property string icon:
        brightnessPercentage < 25
            ? "󰃞"
            : brightnessPercentage < 60
                ? "󰃟"
                : "󰃠"

    /*
     * Reads the active backlight device and current percentage.
     */
    property Process readProcess: Process {
        id: readProcess

        command: [
            "sh",
            "-c",
            `
            if ! command -v brightnessctl >/dev/null 2>&1; then
                printf 'available=0\\n'
                exit 0
            fi

            device_value="$(
                brightnessctl -m 2>/dev/null \
                    | head -n1 \
                    | cut -d, -f1
            )"

            percentage_value="$(
                brightnessctl -m 2>/dev/null \
                    | head -n1 \
                    | cut -d, -f4 \
                    | tr -d '%'
            )"

            if [ -n "$device_value" ] && [ -n "$percentage_value" ]; then
                printf 'available=1\\n'
                printf 'deviceName=%s\\n' "$device_value"
                printf 'percentage=%s\\n' "$percentage_value"
            else
                printf 'available=0\\n'
            fi
            `
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                root.parseReadOutput(text)
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                const message = text.trim()

                if (message.length > 0) {
                    root.errorMessage = message

                    console.warn(
                        "[BrightnessService]",
                        message
                    )
                }
            }
        }
    }

    /*
     * Reused for slider writes.
     */
    property Process writeProcess: Process {
        id: writeProcess

        onRunningChanged: {
            if (!running && root.changing) {
                root.changing = false
                root.refresh()
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                const message = text.trim()

                if (message.length > 0) {
                    root.errorMessage = message

                    console.warn(
                        "[BrightnessService]",
                        message
                    )
                }
            }
        }
    }

    function parseReadOutput(output) {
        const lines = output.split("\n")

        let detectedAvailable = false
        let detectedPercentage = 0
        let detectedDevice = ""

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
            case "available":
                detectedAvailable = value === "1"
                break

            case "deviceName":
                detectedDevice = value
                break

            case "percentage":
                detectedPercentage = Number(value)
                break
            }
        }

        available = detectedAvailable
        deviceName = detectedDevice

        brightness =
            detectedAvailable
                ? Math.max(
                    0,
                    Math.min(
                        1,
                        detectedPercentage / 100
                    )
                )
                : 0

        ready = true
        errorMessage = ""

        console.log(
            "[BrightnessService]",
            available
                ? "Loaded " + brightnessPercentage + "%"
                : "No controllable backlight found"
        )
    }

    function setBrightness(value) {
        if (!available || writeProcess.running)
            return

        const normalized =
            Math.max(
                0.01,
                Math.min(1, value)
            )

        const percentage =
            Math.round(normalized * 100)

        /*
         * Update immediately so dragging feels responsive.
         * The service refreshes from the device after the command ends.
         */
        brightness = normalized
        changing = true

        writeProcess.command = [
            "brightnessctl",
            "set",
            percentage + "%"
        ]

        writeProcess.running = true
    }

    function setBrightnessPercentage(value) {
        setBrightness(value / 100)
    }

    function increaseBrightness(step) {
        const amount =
            step === undefined
                ? 0.05
                : step

        setBrightness(brightness + amount)
    }

    function decreaseBrightness(step) {
        const amount =
            step === undefined
                ? 0.05
                : step

        setBrightness(brightness - amount)
    }

    function refresh() {
        if (readProcess.running)
            return

        readProcess.running = true
    }
}
