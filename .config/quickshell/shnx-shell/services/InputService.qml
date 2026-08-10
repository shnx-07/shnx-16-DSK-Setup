import QtQuick

QtObject {
    id: root

    /*
     * Shared BackendService instance.
     */
    property var backend: null

    /*
     * Live Hyprland input state
     */
    property real sensitivity: 0.0
    property string accelProfile: "adaptive"
    property int followMouse: 1

    /*
     * Persistent SHNX preferences
     */
    property var savedMouse: ({})

    /*
     * Status
     */
    property bool ready: false
    property bool busy: false
    property string lastError: ""

    signal changed()

    function _applyInputState(input) {
        if (!input)
            return

        const mouse =
            input.mouse || {}

        sensitivity =
            Number(
                mouse.sensitivity ?? 0.0
            )

        accelProfile =
            mouse.accelProfile
            || "adaptive"

        followMouse =
            Number(
                mouse.followMouse ?? 1
            )

        ready = true
        lastError = ""

        changed()
    }

    function _applySavedState(saved) {
        if (!saved)
            return

        const input =
            saved.input || {}

        savedMouse =
            input.mouse || {}
    }

    function refresh() {
        if (!backend || !backend.online)
            return ""

        busy = true

        return backend.sendCommand(
            "system.settings.get",
            {}
        )
    }

    function setMouse(
        newSensitivity,
        newAccelProfile
    ) {
        if (!backend || !backend.online) {
            lastError =
                "Backend is offline."

            return ""
        }

        const payload = {}

        if (
            newSensitivity !== undefined
            && newSensitivity !== null
        ) {
            payload.sensitivity =
                Number(newSensitivity)
        }

        if (
            newAccelProfile !== undefined
            && newAccelProfile !== null
            && newAccelProfile !== ""
        ) {
            payload.accel_profile =
                newAccelProfile
        }

        if (
            payload.sensitivity === undefined
            && payload.accel_profile === undefined
        ) {
            return ""
        }

        busy = true
        lastError = ""

        return backend.sendCommand(
            "input.set",
            payload
        )
    }

    function setSensitivity(value) {
        return setMouse(
            value,
            undefined
        )
    }

    function setAccelProfile(profile) {
        return setMouse(
            undefined,
            profile
        )
    }

    property Connections backendConnections: Connections {
          target: root.backend

        function onOnlineChanged() {
            if (
                root.backend
                && root.backend.online
            ) {
                root.refresh()
            } else {
                root.ready = false
            }
        }

        function onResponseReceived(
            command,
            requestId,
            payload
        ) {
            if (
                command
                === "system.settings.get"
            ) {
                root.busy = false

                root._applyInputState(
                    payload.input
                )

                root._applySavedState(
                    payload.saved
                )

                return
            }

            if (
                command
                === "input.set"
            ) {
                root.busy = false

                root._applyInputState(
                    payload.input
                )

                root._applySavedState(
                    payload.saved
                )
            }
        }
    }

    Component.onCompleted: {
        if (
            backend
            && backend.online
        ) {
            refresh()
        }
    }
}
