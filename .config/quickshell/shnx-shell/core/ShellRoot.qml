import Quickshell
import qs.core as Core
import "../bar" as Bar
import "../panels/quicksettings" as QuickSettings
import "../panels/notifications" as Notifications
import "../panels/power" as Power

Scope {
    id: root

    Bar.Bar {}

    QuickSettings.QuickSettingsDetailPanel {
        id: quickSettingsDetailPanel
    }

    Notifications.NotificationPanel {
        id: notificationPanel
    }

    Power.PowerMenuPanel {
        id: powerMenuPanel
    }
}
