import Quickshell
import Quickshell.Hyprland
import QtQuick
import qs.core as Core

import "../bar" as Bar
import "../dock" as Dock
import "../panels/profile" as Profile
import "../panels/quicksettings" as QuickSettings
import "../panels/notifications" as Notifications
import "../panels/power" as Power
import "../panels/launcher" as Launcher
import "../panels/appearance" as Appearance

Scope {
    id: root

    Bar.Bar {}

    Dock.UtilityDock {}

    GlobalShortcut {
        appid: "shnx-shell"
        name: "utility-dock"
        description: "Toggle the SHNX Utility Dock"

        onPressed: {
            Core.UtilityDockController.toggle()

            console.log(
                "[UtilityDock] shortcut received, open:",
                Core.UtilityDockController.open
            )
        }
    }

    Appearance.AppearancePanel {
        id: appearancePanel
    }

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
