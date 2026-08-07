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
import "../panels/wallpaper" as Wallpaper


Scope {
    id: root


    /*
     * ------------------------------------------------------------
     * Permanent shell surfaces
     * ------------------------------------------------------------
     */

    Bar.Bar {}

    Dock.UtilityDock {}


    /*
     * ------------------------------------------------------------
     * Utility Dock global shortcut
     * ------------------------------------------------------------
     */

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


    /*
     * ------------------------------------------------------------
     * Floating panels
     * ------------------------------------------------------------
     *
     * These are instantiated directly rather than through Loader /
     * LazyLoader so panel lifetime stays predictable and stable.
     */


    Wallpaper.WallpaperPanel {
        id: wallpaperPanel
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
