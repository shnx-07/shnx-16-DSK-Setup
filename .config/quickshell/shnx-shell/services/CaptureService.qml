import QtQuick

QtObject {
    id: root

    // =============================================================
    // Dependencies
    // =============================================================

    property var backend: null

    // =============================================================
    // Recorder state
    // =============================================================

    property bool recordingActive: false
    property bool recordingPaused: false

    property int recordingElapsed: 0
    property string recordingPath: ""

    // =============================================================
    // Screenshots
    // =============================================================

    function fullScreenshot(outputName) {
        if (!root.backend)
            return

        root.backend.sendCommand(
            "screenshot.full",
            {
                output: outputName
            }
        )
    }

    function snipScreenshot(geometry) {
        if (!root.backend)
            return

        root.backend.sendCommand(
            "screenshot.region",
            {
                geometry: geometry
            }
        )
    }

    // =============================================================
    // Screen recording commands
    // =============================================================

    function startRecording(outputName) {
        if (!root.backend)
            return

        if (!outputName || outputName === "")
            return

        root.backend.sendCommand(
            "screen.start",
            {
                output: outputName
            }
        )
    }

    function pauseRecording() {
        if (!root.backend)
            return

        if (!root.recordingActive)
            return

        if (root.recordingPaused)
            return

        root.backend.sendCommand(
            "screen.pause",
            {}
        )
    }

    function resumeRecording() {
        if (!root.backend)
            return

        if (!root.recordingActive)
            return

        if (!root.recordingPaused)
            return

        root.backend.sendCommand(
            "screen.resume",
            {}
        )
    }

    function stopRecording() {
        if (!root.backend)
            return

        if (!root.recordingActive)
            return

        root.backend.sendCommand(
            "screen.stop",
            {}
        )
    }

    function refreshRecordingStatus() {
        if (!root.backend)
            return

        root.backend.sendCommand(
            "screen.status",
            {}
        )
    }

    // =============================================================
    // Recorder state synchronization
    // =============================================================

    function applyRecordingState(payload) {
        if (!payload)
            return

        const wasActive =
            root.recordingActive

        root.recordingActive =
            payload.active === true

        root.recordingPaused =
            payload.paused === true

        root.recordingPath =
            payload.path || ""

        if (
            payload.elapsed !== undefined
            && payload.elapsed !== null
        ) {
            root.recordingElapsed =
                Math.max(
                    0,
                    Math.floor(
                        Number(payload.elapsed) || 0
                    )
                )
        }

        if (!root.recordingActive) {
            root.recordingPaused = false

            if (wasActive)
                root.recordingElapsed = 0
        }
    }

    // =============================================================
    // Local elapsed clock
    //
    // Python/backend owns authoritative recorder timing.
    // This only keeps the displayed timer moving smoothly.
    // =============================================================

    property Timer recordingClock: Timer {
        interval: 1000

        repeat: true

        running:
            root.recordingActive
            && !root.recordingPaused

        onTriggered: {
            root.recordingElapsed += 1
        }
    }

    // =============================================================
    // Backend events and responses
    // =============================================================

    property Connections backendConnections: Connections {
        target: root.backend

        enabled:
            root.backend !== null

        function onEventReceived(
            eventName,
            payload
        ) {
            console.log(
                "[CaptureService] EVENT:",
                eventName
            )

            if (
                eventName
                !== "screen.recordingState"
            ) {
                return
            }

            root.applyRecordingState(
                payload
            )

            console.log(
                "[CaptureService] recorder event",
                "active:",
                root.recordingActive,
                "paused:",
                root.recordingPaused,
                "elapsed:",
                root.recordingElapsed
            )
        }

        function onResponseReceived(
            command,
            requestId,
            payload
        ) {
            console.log(
                "[CaptureService] RESPONSE:",
                command
            )

            // -----------------------------------------------------
            // Initial / recovery synchronization
            // -----------------------------------------------------

            if (
                command
                === "screen.status"
            ) {
                root.applyRecordingState(
                    payload
                )

                console.log(
                    "[CaptureService] status",
                    "active:",
                    root.recordingActive,
                    "paused:",
                    root.recordingPaused,
                    "elapsed:",
                    root.recordingElapsed
                )

                return
            }

            // -----------------------------------------------------
            // Commands issued directly by QML
            // -----------------------------------------------------

            if (
                command === "screen.start"
                || command === "screen.pause"
                || command === "screen.resume"
                || command === "screen.stop"
            ) {
                root.applyRecordingState(
                    payload
                )

                return
            }

            // -----------------------------------------------------
            // Backend connection/reconnection
            // -----------------------------------------------------

            if (
                command
                === "hello"
            ) {
                console.log(
                    "[CaptureService] backend ready"
                )

                root.refreshRecordingStatus()
            }
        }
    }

    // =============================================================
    // Backend availability
    // =============================================================

    onBackendChanged: {
        if (
            root.backend
            && root.backend.online
        ) {
            root.refreshRecordingStatus()
        }
    }

    Component.onCompleted: {
        if (
            root.backend
            && root.backend.online
        ) {
            root.refreshRecordingStatus()
        }
    }
}
