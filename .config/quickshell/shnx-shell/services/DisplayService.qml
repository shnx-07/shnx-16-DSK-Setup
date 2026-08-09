import QtQuick

QtObject {
    id: root

    /*
     * Shared BackendService instance.
     *
     * Injected by ServiceRegistry so this service does not
     * create another backend socket.
     */
    property var backend: null

    /*
     * Live Hyprland state
     */
    property var monitors: []
    property var enabledMonitors: []

    property int monitorCount: 0
    property int enabledMonitorCount: 0

    /*
     * Persistent SHNX monitor preferences.
     */
    property var savedMonitors: ({})

    /*
     * Status
     */
    property bool ready: false
    property bool busy: false
    property string lastError: ""

    signal changed()
    signal monitorAdded(
        string name,
        var monitor,
        bool restored
    )
    signal monitorRemoved(
        string name
    )

    function _applyDisplayState(display) {
        if (!display)
            return

        monitors =
            display.monitors || []

        enabledMonitors =
            display.enabledMonitors || []

        monitorCount =
            display.monitorCount
            ?? monitors.length

        enabledMonitorCount =
            display.enabledMonitorCount
            ?? enabledMonitors.length

        ready = true
        lastError = ""

        changed()
    }

    function _applySavedState(saved) {
        if (!saved)
            return

        const display =
            saved.display || {}

        savedMonitors =
            display.monitors || {}
    }

    function monitor(name) {
        if (!name)
            return null

        for (
            let index = 0;
            index < monitors.length;
            ++index
        ) {
            const item = monitors[index]

            if (item.name === name)
                return item
        }

        return null
    }

    function isEnabled(name) {
        const item = monitor(name)

        return item
            ? item.enabled === true
            : false
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

    function setMonitor(
        name,
        resolution,
        refreshRate,
        scale,
        enabled,
        position
    ) {
        if (!backend || !backend.online) {
            lastError =
                "Backend is offline."

            return ""
        }

        if (!name || name.length === 0) {
            lastError =
                "Monitor name is required."

            return ""
        }

        const payload = {
            name: name
        }

        if (
            resolution !== undefined
            && resolution !== null
            && resolution !== ""
        ) {
            payload.resolution =
                resolution
        }

        if (
            refreshRate !== undefined
            && refreshRate !== null
        ) {
            payload.refresh_rate =
                refreshRate
        }

        if (
            scale !== undefined
            && scale !== null
        ) {
            payload.scale =
                scale
        }

        if (
            enabled !== undefined
            && enabled !== null
        ) {
            payload.enabled =
                enabled
        }

        if (
            position !== undefined
            && position !== null
            && position !== ""
        ) {
            payload.position =
                position
        }

        busy = true
        lastError = ""

        return backend.sendCommand(
            "display.set",
            payload
        )
    }

    function setEnabled(
        name,
        enabled
    ) {
        const current =
            monitor(name)

        if (!current)
            return ""

        return setMonitor(
            name,
            current.resolution,
            current.refreshRate,
            current.scale,
            enabled,
            current.x + "x" + current.y
        )
    }

    function setMode(
        name,
        resolution,
        refreshRate
    ) {
        const current =
            monitor(name)

        if (!current)
            return ""

        return setMonitor(
            name,
            resolution,
            refreshRate,
            current.scale,
            true,
            current.x + "x" + current.y
        )
    }

    function setScale(
        name,
        scale
    ) {
        const current =
            monitor(name)

        if (!current)
            return ""

        return setMonitor(
            name,
            current.resolution,
            current.refreshRate,
            scale,
            true,
            current.x + "x" + current.y
        )
    }

    function setPosition(
        name,
        x,
        y
    ) {
        const current =
            monitor(name)

        if (!current)
            return ""

        return setMonitor(
            name,
            current.resolution,
            current.refreshRate,
            current.scale,
            true,
            x + "x" + y
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

                root._applyDisplayState(
                    payload.display
                )

                root._applySavedState(
                    payload.saved
                )

                return
            }

            if (
                command
                === "display.set"
            ) {
                root.busy = false

                root._applyDisplayState(
                    payload.display
                )

                root._applySavedState(
                    payload.saved
                )
            }
        }

        function onEventReceived(
            eventName,
            payload
        ) {
            if (
                eventName
                === "display.changed"
            ) {
                root._applyDisplayState(
                    payload
                )

                return
            }

            if (
                eventName
                === "display.monitorAdded"
            ) {
                root.monitorAdded(
                    payload.name || "",
                    payload.monitor || null,
                    payload.restored === true
                )

                return
            }

            if (
                eventName
                === "display.monitorRemoved"
            ) {
                root.monitorRemoved(
                    payload.name || ""
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
