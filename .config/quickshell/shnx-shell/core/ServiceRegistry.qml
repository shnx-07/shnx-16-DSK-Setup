pragma Singleton

import QtQuick
import "../services" as Services

QtObject {
    id: root

    readonly property Services.HyprlandService hyprland:
        Services.HyprlandService {}

    readonly property Services.BatteryService battery:
        Services.BatteryService {}

    readonly property Services.NetworkService network:
        Services.NetworkService {}

    readonly property Services.BluetoothService bluetooth:
        Services.BluetoothService {}

    readonly property Services.NotificationService notifications:
        Services.NotificationService {}

    readonly property Services.WeatherService weather:
        Services.WeatherService {}

    readonly property Services.SystemService system:
        Services.SystemService {}

    readonly property Services.BackendService backend:
        Services.BackendService {
            id: backendService
        }
}
