import Quickshell
import qs.core as Core
import "../bar" as Bar
import "../panels/profile" as Profile
import "../panels/quicksettings" as QuickSettings
import "../panels/notifications" as Notifications
import "../panels/power" as Power
import "../panels/launcher" as Launcher

Scope {
    id: root

    Bar.Bar {}

    Profile.ProfileHubPanel {
        id: profileHubPanel
    }

    QuickSettings.QuickSettingsDetailPanel {
        id: quickSettingsDetailPanel
    }

    Notifications.NotificationPanel {
        id: notificationPanel
      }

      Launcher.AppLauncherPanel {
          id: appLauncherPanel
      }

    Power.PowerMenuPanel {
        id: powerMenuPanel
    }
}
