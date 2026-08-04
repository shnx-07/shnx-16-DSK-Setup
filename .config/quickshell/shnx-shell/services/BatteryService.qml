import QtQuick
import Quickshell.Services.UPower

QtObject {
    id: root

    readonly property var device: UPower.displayDevice

    // Battery history belongs to this persistent service, not to the panel UI.
    // Samples survive Control Center close/open cycles for this Quickshell session.
    property var usageSamples: []

    readonly property int sampleIntervalMs: 60000
    readonly property int maximumSamples: 180

    readonly property bool ready:
        device !== null
        && device !== undefined
        && device.ready

    readonly property bool available:
        ready && device.isPresent

    readonly property int percentage:
        available
            ? Math.round(device.percentage * 100)
            : 0

    readonly property int state:
        ready
            ? device.state
            : UPowerDeviceState.Unknown

    readonly property bool charging:
        state === UPowerDeviceState.Charging
        || state === UPowerDeviceState.PendingCharge

    readonly property bool discharging:
        state === UPowerDeviceState.Discharging
        || state === UPowerDeviceState.PendingDischarge

    readonly property bool fullyCharged:
        state === UPowerDeviceState.FullyCharged

    readonly property bool low:
        available && percentage <= 20

    readonly property bool critical:
        available && percentage <= 10

    readonly property real energy:
        ready && device.energy !== undefined
            ? device.energy
            : 0

    readonly property real energyCapacity:
        ready && device.energyCapacity !== undefined
            ? device.energyCapacity
            : 0

    readonly property real powerUsage:
        ready && device.changeRate !== undefined
            ? Math.abs(device.changeRate)
            : 0

    readonly property real timeToEmpty:
        ready && device.timeToEmpty !== undefined
            ? device.timeToEmpty
            : 0

    readonly property real timeToFull:
        ready && device.timeToFull !== undefined
            ? device.timeToFull
            : 0

    readonly property bool healthAvailable:
        ready
        && device.healthSupported === true
        && device.healthPercentage !== undefined

    readonly property real healthPercentage:
        healthAvailable
            ? device.healthPercentage * 100
            : -1

    readonly property bool powerSaverEnabled:
        PowerProfiles.profile === PowerProfile.PowerSaver

    readonly property string stateName: {
        if (!ready)
            return "Unavailable"

        if (fullyCharged)
            return "Fully charged"

        if (charging)
            return "Charging"

        if (discharging)
            return "On battery"

        if (state === UPowerDeviceState.Empty)
            return "Empty"

        return "Unknown"
    }

    readonly property string icon: {
        if (!available)
            return "󰂑"

        if (charging)
            return "󰂄"

        if (percentage >= 90)
            return "󰁹"

        if (percentage >= 80)
            return "󰂂"

        if (percentage >= 70)
            return "󰂁"

        if (percentage >= 60)
            return "󰂀"

        if (percentage >= 50)
            return "󰁿"

        if (percentage >= 40)
            return "󰁾"

        if (percentage >= 30)
            return "󰁽"

        if (percentage >= 20)
            return "󰁼"

        if (percentage >= 10)
            return "󰁻"

        return "󰂎"
    }

    readonly property string remainingTime: {
        if (charging)
            return formatDuration(timeToFull)

        if (discharging)
            return formatDuration(timeToEmpty)

        return ""
    }


    function addUsageSample() {
        if (!available)
            return

        const nextSamples = usageSamples.slice()

        nextSamples.push({
            timestamp: Date.now(),
            percentage: percentage,
            watts: powerUsage,
            charging: charging
        })

        while (nextSamples.length > maximumSamples)
            nextSamples.shift()

        // Assign a new array so QML emits usageSamplesChanged.
        usageSamples = nextSamples
    }

    Component.onCompleted: {
        addUsageSample()
    }

    onAvailableChanged: {
        if (available && usageSamples.length === 0)
            addUsageSample()
    }

    property Timer sampleTimer: Timer {
        interval: root.sampleIntervalMs
        repeat: true
        running: root.available

        onTriggered: root.addUsageSample()
    }

    function formatDuration(seconds) {
        if (!seconds || seconds <= 0)
            return ""

        const totalMinutes = Math.floor(seconds / 60)
        const hours = Math.floor(totalMinutes / 60)
        const minutes = totalMinutes % 60

        if (hours > 0)
            return hours + "h " + minutes + "m"

        return minutes + "m"
    }

    function formatWatts(value) {
        if (!value || value <= 0)
            return "—"

        return value.toFixed(1) + " W"
    }

    function setPowerSaver(enabled) {
        PowerProfiles.profile = enabled
            ? PowerProfile.PowerSaver
            : PowerProfile.Balanced
    }

    function togglePowerSaver() {
        setPowerSaver(!powerSaverEnabled)
    }
}

