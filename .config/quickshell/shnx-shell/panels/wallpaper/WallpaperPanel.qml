import QtQuick

import Quickshell
import Quickshell.Wayland

import qs.core as Core
import qs.theme as ShellTheme

import "." as WallpaperParts


PanelWindow {
    id: root

    readonly property var wallpaperService:
        Core.ServiceRegistry.wallpaper

    visible:
        Core.PanelController.wallpaperPanelOpen

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color:
        "transparent"

    exclusionMode:
        ExclusionMode.Ignore

    aboveWindows: true
    focusable: true


    /*
     * ------------------------------------------------------------
     * Minimal header
     * ------------------------------------------------------------
     *
     * The wallpaper selector itself no longer lives inside a visible
     * card/panel. The desktop remains visible behind everything.
     */

    Column {
        anchors {
            top: parent.top
            left: parent.left

            topMargin:
                ShellTheme.Theme.spacing.xxxLarge * 2

            leftMargin:
                ShellTheme.Theme.spacing.xxxLarge
        }

        spacing:
            ShellTheme.Theme.spacing.xSmall


        Text {
            text:
                "Wallpaper"

            color:
                ShellTheme.Theme.colors.on_surface

            font.family:
                ShellTheme.Theme.typography.fontFamily

            font.pixelSize:
                ShellTheme.Theme.typography.titleLarge

            font.weight:
                ShellTheme.Theme.typography.weightSemiBold
        }


        Text {
            readonly property int wallpaperCount:
                root.wallpaperService
                    ? root.wallpaperService.wallpaperCount
                    : 0

            text:
                wallpaperCount
                + (
                    wallpaperCount === 1
                        ? " wallpaper"
                        : " wallpapers"
                )

            color:
                ShellTheme.Theme.colors.on_surface_variant

            font.family:
                ShellTheme.Theme.typography.fontFamily

            font.pixelSize:
                ShellTheme.Theme.typography.bodyMedium
        }
    }


    /*
     * ------------------------------------------------------------
     * Full-width invisible selector stage
     * ------------------------------------------------------------
     *
     * THIS is the important structural change.
     *
     * The carousel now receives almost the entire screen width instead
     * of being constrained by a 980px Rectangle / ColumnLayout.
     */

    Item {
        id: selectorStage

        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }

        height:
            Math.min(
                parent.height * 0.62,
                560
            )


        WallpaperParts.WallpaperCarousel {
            id: wallpaperCarousel

            anchors.fill:
                parent
        }
    }


    /*
     * ------------------------------------------------------------
     * Navigation hint
     * ------------------------------------------------------------
     */

    Text {
        anchors {
            horizontalCenter:
                parent.horizontalCenter

            bottom:
                parent.bottom

            bottomMargin:
                ShellTheme.Theme.spacing.xxxLarge
        }

        text:
            "←  →  Browse     Enter  Apply     Mouse wheel / drag"

        color:
            ShellTheme.Theme.colors.on_surface_variant

        font.family:
            ShellTheme.Theme.typography.fontFamily

        font.pixelSize:
            ShellTheme.Theme.typography.labelMedium
    }


    /*
     * ------------------------------------------------------------
     * Wallpaper loading
     * ------------------------------------------------------------
     */

    onVisibleChanged: {
        const service = root.wallpaperService

        if (!visible) {
            if (service)
                service.endSession()

            return
        }

        /*
         * Wallpaper is session-driven.
         *
         * Every CLOSED -> OPEN transition performs one fresh scan so newly
         * added files are discovered without restarting Quickshell.
         *
         * The service publishes one stable library snapshot; preview results
         * update separately and never replace the carousel model.
         */
        Qt.callLater(function() {
            if (!root || !root.visible)
                return

            if (service)
                service.beginSession()

            if (root.visible && wallpaperCarousel)
                wallpaperCarousel.forceActiveFocus()
        })
    }


    /*
     * ------------------------------------------------------------
     * Close
     * ------------------------------------------------------------
     */

    Shortcut {
        sequence:
            "Escape"

        context:
            Qt.WindowShortcut

        enabled:
            root.visible

        onActivated: {
            Core.PanelController.close()
        }
    }
}


