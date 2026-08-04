import QtQuick
import qs.core as Core

QtObject {
    id: root

    // Temporary default until config/settings.json is wired.
    property string locationQuery: "New Delhi"

    property string location: ""
    property string condition: ""
    property string conditionIcon: "󰖐"

    property real temperature: 0
    property real apparentTemperature: 0
    property real high: 0
    property real low: 0
    property real precipitationProbability: 0
    property real precipitation: 0
    property real humidity: 0
    property real windSpeed: 0

    property bool isDay: true
    property bool loading: false
    property bool available: false
    property bool cached: false
    property bool stale: false

    property string provider: ""
    property string observedAt: ""
    property double updatedAt: 0
    property string lastError: ""

    property string activeRequestId: ""

    readonly property bool backendOnline:
        Core.ServiceRegistry.backend.online

    readonly property string temperatureText:
        available
            ? Math.round(temperature) + "°"
            : "--°"

    readonly property string highLowText:
        available
            ? "H "
                + Math.round(high)
                + "°  L "
                + Math.round(low)
                + "°"
            : "H --°  L --°"

    readonly property string statusText: {
        if (loading)
            return "Updating weather…"

        if (stale)
            return "Cached weather"

        if (cached)
            return "Updated from cache"

        if (available)
            return "Updated recently"

        if (!backendOnline)
            return "Weather backend offline"

        return lastError.length > 0
            ? lastError
            : "Weather unavailable"
    }

    function refresh(forceRefresh) {
        if (loading)
            return

        if (!backendOnline) {
            lastError =
                "Weather backend is offline."

            return
        }

        loading = true
        lastError = ""

        activeRequestId =
            Core.ServiceRegistry.backend.sendCommand(
                "weather.get",
                {
                    location: locationQuery,
                    force_refresh:
                        forceRefresh === true
                }
            )

        if (activeRequestId.length === 0) {
            loading = false
            lastError =
                "Could not send weather request."
        }
    }

    function applyWeather(payload) {
        provider = payload.provider || ""
        location = payload.location || locationQuery
        condition = payload.condition || "Unknown"
        conditionIcon =
            payload.condition_icon || "󰖐"

        temperature =
            Number(payload.temperature || 0)

        apparentTemperature =
            Number(
                payload.apparent_temperature || 0
            )

        high = Number(payload.high || 0)
        low = Number(payload.low || 0)

        precipitationProbability =
            Number(
                payload
                    .precipitation_probability
                || 0
            )

        precipitation =
            Number(payload.precipitation || 0)

        humidity =
            Number(payload.humidity || 0)

        windSpeed =
            Number(payload.wind_speed || 0)

        isDay = payload.is_day !== false
        observedAt = payload.observed_at || ""
        updatedAt =
            Number(payload.updated_at || 0)

        cached = payload.cached === true
        stale = payload.stale === true

        available = true
        loading = false
        lastError = ""
    }

    property Connections backendConnections:
        Connections {
            target: Core.ServiceRegistry.backend

            function onOnlineChanged() {
                if (
                    Core.ServiceRegistry
                        .backend.online
                    && !root.available
                ) {
                    root.refresh(false)
                }
            }

            function onResponseReceived(
                command,
                requestId,
                payload
            ) {
                if (
                    command !== "weather.get"
                    || requestId
                        !== root.activeRequestId
                ) {
                    return
                }

                root.activeRequestId = ""
                root.applyWeather(payload)
            }
        }

    property Connections backendErrorConnections:
        Connections {
            target: Core.ServiceRegistry.backend

            function onLastErrorChanged() {
                if (
                    !root.loading
                    || root.activeRequestId
                        .length === 0
                ) {
                    return
                }

                const errorText =
                    Core.ServiceRegistry
                        .backend.lastError

                if (errorText.length === 0)
                    return

                root.loading = false
                root.activeRequestId = ""
                root.lastError = errorText
            }
        }

    property Timer periodicRefreshTimer:
        Timer {
            interval: 30 * 60 * 1000
            repeat: true
            running: root.backendOnline

            onTriggered:
                root.refresh(false)
        }

    Component.onCompleted: {
        if (backendOnline)
            refresh(false)
    }
}
