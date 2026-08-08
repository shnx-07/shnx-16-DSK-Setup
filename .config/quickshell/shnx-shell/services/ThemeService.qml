import QtQuick
import Quickshell
import Quickshell.Io

import qs.core as Core

import "../theme" as ThemeSystem
import "../theme/generated" as Generated

QtObject {
    id: root

    readonly property Timer settingsReloadTimer: Timer {
        interval: 150
        repeat: false

        onTriggered: {
            settingsFile.reload()
        }
    }

    readonly property FileView settingsFile: FileView {
        path: Qt.resolvedUrl("../config/settings.json")

        preload: true
        blockLoading: true
        atomicWrites: true
        watchChanges: true

        adapter: JsonAdapter {
            id: settings

            property string appearanceMode: "dark"
            property string colorStyle: "preset"

            onAppearanceModeChanged: {
                Qt.callLater(root.applyCurrentTheme)
            }

            onColorStyleChanged: {
                Qt.callLater(root.applyCurrentTheme)
            }
        }

        onLoaded: {
            root.applyCurrentTheme()
        }

        onFileChanged: {
            root.settingsReloadTimer.restart()
        }

        onAdapterUpdated: {
            writeAdapter()
        }
    }

    readonly property string appearanceMode:
        settings.appearanceMode

    readonly property string colorStyle:
        settings.colorStyle


    /*
     * ------------------------------------------------------------
     * Matugen generation state
     * ------------------------------------------------------------
     */

    property string pendingThemeGenerateRequestId: ""
    property var pendingThemeWallpaper: null

    readonly property bool generatingWallpaperTheme:
        pendingThemeGenerateRequestId.length > 0


    /*
     * ------------------------------------------------------------
     * Supported modes
     * ------------------------------------------------------------
     */

    readonly property var validAppearanceModes: [
      "dark",
      "light",
      "gray",

      "catppuccinMocha",
      "catppuccinMacchiato",

      "gruvboxDark",
      "gruvboxLight",

      "nord",
      "dracula",
      "tokyoNight",

      "rosePine",
      "rosePineMoon",

      "everforestDark",
      "everforestLight",

      "kanagawa",
      "oneDark",

      "solarizedDark",
      "solarizedLight",

      "monokai",

      "materialDark",
      "materialLight",

      "ocean",
      "forest",
      "sunset",

      "amoled"
  ]

    readonly property var validColorStyles: [
        "preset",
        "wallpaperAccents",
        "wallpaperFull"
    ]


    /*
     * ------------------------------------------------------------
     * Theme state
     * ------------------------------------------------------------
     */

    property string status: "ready"
    property string errorMessage: ""

    readonly property bool isApplying:
        status === "applying"

    readonly property bool hasError:
        errorMessage.length > 0

    property QtObject lastValidPalette:
        ThemeSystem.Theme.darkPalette


    /*
     * Structural preset selected by appearanceMode.
     */

    readonly property QtObject activePreset:
        presetForMode(
            appearanceMode
        )


    /*
     * Generated palette selected by appearanceMode.
     *
     * dark  -> generated dark palette
     * light -> generated light palette
     * gray  -> generated dark palette
     *
     * Gray remains a darker structural mode for now.
     */

    readonly property QtObject activeGeneratedPalette:
        generatedPaletteForMode(
            appearanceMode
        )


    /*
     * Hybrid wallpaper accent mode:
     *
     * accents
     *     -> generated Matugen palette
     *
     * structure/content/status
     *     -> selected Dark / Light / Gray preset
     */

    readonly property QtObject wallpaperAccentPalette: QtObject {

        /*
         * Generated accent roles
         */

        readonly property color primary:
            root.activeGeneratedPalette.primary

        readonly property color on_primary:
            root.activeGeneratedPalette.on_primary

        readonly property color primaryContainer:
            root.activeGeneratedPalette.primaryContainer

        readonly property color on_primary_container:
            root.activeGeneratedPalette.on_primary_container


        readonly property color secondary:
            root.activeGeneratedPalette.secondary

        readonly property color on_secondary:
            root.activeGeneratedPalette.on_secondary

        readonly property color secondaryContainer:
            root.activeGeneratedPalette.secondaryContainer

        readonly property color on_secondary_container:
            root.activeGeneratedPalette.on_secondary_container


        readonly property color tertiary:
            root.activeGeneratedPalette.tertiary

        readonly property color on_tertiary:
            root.activeGeneratedPalette.on_tertiary

        readonly property color tertiaryContainer:
            root.activeGeneratedPalette.tertiaryContainer

        readonly property color on_tertiary_container:
            root.activeGeneratedPalette.on_tertiary_container


        /*
         * Preset structural roles
         */

        readonly property color background:
            root.activePreset.background

        readonly property color on_background:
            root.activePreset.on_background


        readonly property color surface:
            root.activePreset.surface

        readonly property color surfaceDim:
            root.activePreset.surfaceDim

        readonly property color surfaceBright:
            root.activePreset.surfaceBright

        readonly property color surfaceContainerLowest:
            root.activePreset.surfaceContainerLowest

        readonly property color surfaceContainerLow:
            root.activePreset.surfaceContainerLow

        readonly property color surfaceContainer:
            root.activePreset.surfaceContainer

        readonly property color surfaceContainerHigh:
            root.activePreset.surfaceContainerHigh

        readonly property color surfaceContainerHighest:
            root.activePreset.surfaceContainerHighest


        /*
         * Preset content roles
         */

        readonly property color on_surface:
            root.activePreset.on_surface

        readonly property color on_surface_variant:
            root.activePreset.on_surface_variant

        readonly property color inverseSurface:
            root.activePreset.inverseSurface

        readonly property color inverse_on_surface:
            root.activePreset.inverse_on_surface


        /*
         * Accent-related inverse role
         */

        readonly property color inversePrimary:
            root.activeGeneratedPalette.inversePrimary


        /*
         * Preset outlines / overlays
         */

        readonly property color outline:
            root.activePreset.outline

        readonly property color outlineVariant:
            root.activePreset.outlineVariant

        readonly property color shadow:
            root.activePreset.shadow

        readonly property color scrim:
            root.activePreset.scrim


        /*
         * Preset error roles
         */

        readonly property color error:
            root.activePreset.error

        readonly property color on_error:
            root.activePreset.on_error

        readonly property color errorContainer:
            root.activePreset.errorContainer

        readonly property color on_error_container:
            root.activePreset.on_error_container


        /*
         * Preset success roles
         */

        readonly property color success:
            root.activePreset.success

        readonly property color on_success:
            root.activePreset.on_success

        readonly property color successContainer:
            root.activePreset.successContainer

        readonly property color on_success_container:
            root.activePreset.on_success_container


        /*
         * Preset warning roles
         */

        readonly property color warning:
            root.activePreset.warning

        readonly property color on_warning:
            root.activePreset.on_warning

        readonly property color warningContainer:
            root.activePreset.warningContainer

        readonly property color on_warning_container:
            root.activePreset.on_warning_container


        /*
         * Preset information roles
         */

        readonly property color info:
            root.activePreset.info

        readonly property color on_info:
            root.activePreset.on_info

        readonly property color infoContainer:
            root.activePreset.infoContainer

        readonly property color on_info_container:
            root.activePreset.on_info_container
    }


    /*
     * ------------------------------------------------------------
     * Palette validation
     * ------------------------------------------------------------
     */

    readonly property var requiredColorRoles: [
        "primary",
        "on_primary",
        "primaryContainer",
        "on_primary_container",

        "secondary",
        "on_secondary",
        "secondaryContainer",
        "on_secondary_container",

        "tertiary",
        "on_tertiary",
        "tertiaryContainer",
        "on_tertiary_container",

        "background",
        "on_background",

        "surface",
        "surfaceDim",
        "surfaceBright",
        "surfaceContainerLowest",
        "surfaceContainerLow",
        "surfaceContainer",
        "surfaceContainerHigh",
        "surfaceContainerHighest",

        "on_surface",
        "on_surface_variant",

        "inverseSurface",
        "inverse_on_surface",
        "inversePrimary",

        "outline",
        "outlineVariant",
        "shadow",
        "scrim",

        "error",
        "on_error",
        "errorContainer",
        "on_error_container",

        "success",
        "on_success",
        "successContainer",
        "on_success_container",

        "warning",
        "on_warning",
        "warningContainer",
        "on_warning_container",

        "info",
        "on_info",
        "infoContainer",
        "on_info_container"
    ]


    /*
     * ------------------------------------------------------------
     * Signals
     * ------------------------------------------------------------
     */

    signal themeApplied(
        string appearanceMode,
        string colorStyle
    )

    signal themeApplyFailed(
        string message
    )

    signal wallpaperThemeGenerationStarted(
        var wallpaper
    )

    signal wallpaperThemeGenerationSucceeded(
        var wallpaper,
        string source
    )

    signal wallpaperThemeGenerationFailed(
        var wallpaper,
        string message
    )


    /*
     * ------------------------------------------------------------
     * Wallpaper -> Matugen connection
     * ------------------------------------------------------------
     */

    property Connections wallpaperConnections: Connections {
        target: Core.ServiceRegistry.wallpaper

        function onWallpaperApplied(
            wallpaper
        ) {
            if (!wallpaper)
                return

            /*
            * Preset mode intentionally ignores wallpaper colors.
            */
            if (
                root.colorStyle !== "wallpaperAccents"
                && root.colorStyle !== "wallpaperFull"
            ) {
                return
            }

            root.generateThemeFromWallpaper(
                wallpaper
            )
        }
    }


    /*
     * ------------------------------------------------------------
     * Backend Matugen response
     * ------------------------------------------------------------
     */
    
    property Connections backendConnections: Connections {
        target: Core.ServiceRegistry.backend

        function onResponseReceived(
            command,
            requestId,
            payload
        ) {
            if (command !== "theme.generate")
                return

            if (
                requestId
                !== root.pendingThemeGenerateRequestId
            ) {
                return
            }

            const generatedWallpaper =
                root.pendingThemeWallpaper

            root.pendingThemeGenerateRequestId = ""
            root.pendingThemeWallpaper = null

            if (!payload) {
                const message =
                    "theme.generate returned no payload."

                console.warn(
                    "[ThemeService]",
                    message
                )

                root.wallpaperThemeGenerationFailed(
                    generatedWallpaper,
                    message
                )

                return
            }

            if (payload.success !== true) {
                const message =
                    payload.error !== undefined
                        ? String(payload.error)
                        : "Matugen palette generation failed."

                console.warn(
                    "[ThemeService]",
                    message
                )

                root.wallpaperThemeGenerationFailed(
                    generatedWallpaper,
                    message
                )

                return
            }

            console.log(
                "[ThemeService] Matugen palette generated successfully:",
                payload.source
            )

            root.wallpaperThemeGenerationSucceeded(
                generatedWallpaper,
                payload.source !== undefined
                    ? String(payload.source)
                    : ""
            )
        }
    }


    /*
     * ------------------------------------------------------------
     * Startup
     * ------------------------------------------------------------
     */

    Component.onCompleted: {
        if (settingsFile.loaded)
            applyCurrentTheme()
    }


    /*
     * ------------------------------------------------------------
     * Mode helpers
     * ------------------------------------------------------------
     */

    function isValidAppearanceMode(
        mode
    ) {
        return (
            validAppearanceModes.indexOf(
                mode
            ) !== -1
        )
    }


    function isValidColorStyle(
        style
    ) {
        return (
            validColorStyles.indexOf(
                style
            ) !== -1
        )
    }


    function presetForMode(
        mode
    ) {
        switch (mode) {

        case "light":
            return ThemeSystem.Theme.lightPalette

        case "gray":
            return ThemeSystem.Theme.grayPalette


        /*
        * Catppuccin
        */

        case "catppuccinMocha":
            return ThemeSystem.Theme.catppuccinMochaPalette

        case "catppuccinMacchiato":
            return ThemeSystem.Theme.catppuccinMacchiatoPalette


        /*
        * Gruvbox
        */

        case "gruvboxDark":
            return ThemeSystem.Theme.gruvboxDarkPalette

        case "gruvboxLight":
            return ThemeSystem.Theme.gruvboxLightPalette


        /*
        * Popular presets
        */

        case "nord":
            return ThemeSystem.Theme.nordPalette

        case "dracula":
            return ThemeSystem.Theme.draculaPalette

        case "tokyoNight":
            return ThemeSystem.Theme.tokyoNightPalette


        /*
        * Rose Pine
        */

        case "rosePine":
            return ThemeSystem.Theme.rosePinePalette

        case "rosePineMoon":
            return ThemeSystem.Theme.rosePineMoonPalette


        /*
        * Everforest
        */

        case "everforestDark":
            return ThemeSystem.Theme.everforestDarkPalette

        case "everforestLight":
            return ThemeSystem.Theme.everforestLightPalette


        /*
        * Other presets
        */

        case "kanagawa":
            return ThemeSystem.Theme.kanagawaPalette

        case "oneDark":
            return ThemeSystem.Theme.oneDarkPalette

        case "solarizedDark":
            return ThemeSystem.Theme.solarizedDarkPalette

        case "solarizedLight":
            return ThemeSystem.Theme.solarizedLightPalette

        case "monokai":
            return ThemeSystem.Theme.monokaiPalette


        /*
        * Material
        */

        case "materialDark":
            return ThemeSystem.Theme.materialDarkPalette

        case "materialLight":
            return ThemeSystem.Theme.materialLightPalette


        /*
        * Custom
        */

        case "ocean":
            return ThemeSystem.Theme.oceanPalette

        case "forest":
            return ThemeSystem.Theme.forestPalette

        case "sunset":
            return ThemeSystem.Theme.sunsetPalette

        case "amoled":
            return ThemeSystem.Theme.amoledPalette


        /*
        * Default
        */

        case "dark":
        default:
            return ThemeSystem.Theme.darkPalette
        }
    }


    function appearanceFamilyForMode(
        mode
    ) {
        switch (mode) {

        /*
        * --------------------------------------------------------
        * LIGHT FAMILY
        * --------------------------------------------------------
        */

        case "light":

        case "gruvboxLight":

        case "everforestLight":

        case "solarizedLight":

        case "materialLight":
            return "light"


        /*
        * --------------------------------------------------------
        * DARK FAMILY
        * --------------------------------------------------------
        *
        * Gray intentionally remains in the dark Matugen family.
        */

        case "gray":

        case "catppuccinMocha":
        case "catppuccinMacchiato":

        case "gruvboxDark":

        case "nord":
        case "dracula":
        case "tokyoNight":

        case "rosePine":
        case "rosePineMoon":

        case "everforestDark":

        case "kanagawa":
        case "oneDark":

        case "solarizedDark":

        case "monokai":

        case "materialDark":

        case "ocean":
        case "forest":
        case "sunset":

        case "amoled":

        case "dark":
        default:
            return "dark"
        }
    }


    function generatedPaletteForMode(
        mode
    ) {
        const family =
            appearanceFamilyForMode(
                mode
            )

        switch (family) {
        case "light":
            return Generated.MatugenPalette.lightPalette

        case "dark":
        default:
            return Generated.MatugenPalette.darkPalette
        }
    }


    /*
     * ------------------------------------------------------------
     * Current palette selection
     * ------------------------------------------------------------
     */

    function paletteForCurrentSelection() {
        switch (colorStyle) {
        case "preset":
            return presetForMode(
                appearanceMode
            )

        case "wallpaperAccents":
            return wallpaperAccentPalette

        case "wallpaperFull":
            return activeGeneratedPalette

        default:
            return null
        }
    }


    /*
     * ------------------------------------------------------------
     * Palette validation
     * ------------------------------------------------------------
     */

    function validatePalette(
        candidatePalette
    ) {
        if (!candidatePalette) {
            return {
                valid: false,
                message: "Palette object is missing."
            }
        }

        for (
            let index = 0;
            index < requiredColorRoles.length;
            index++
        ) {
            const role =
                requiredColorRoles[index]

            if (
                candidatePalette[role] === undefined
                || candidatePalette[role] === null
            ) {
                return {
                    valid: false,
                    message:
                        "Palette is missing required role: "
                        + role
                }
            }
        }

        return {
            valid: true,
            message: ""
        }
    }


    /*
     * ------------------------------------------------------------
     * Commit palette
     * ------------------------------------------------------------
     */

    function commitPalette(
        candidatePalette
    ) {
        const validation =
            validatePalette(
                candidatePalette
            )

        if (!validation.valid) {
            status = "error"
            errorMessage =
                validation.message

            themeApplyFailed(
                errorMessage
            )

            return false
        }

        if (
            !ThemeSystem.Theme.applyPalette(
                candidatePalette
            )
        ) {
            status = "error"

            errorMessage =
                "Theme rejected the candidate palette."

            themeApplyFailed(
                errorMessage
            )

            return false
        }

        lastValidPalette =
            candidatePalette

        status = "ready"
        errorMessage = ""

        themeApplied(
            appearanceMode,
            colorStyle
        )

        return true
    }


    /*
     * ------------------------------------------------------------
     * Apply active mode/style
     * ------------------------------------------------------------
     */

    function applyCurrentTheme() {
        status = "applying"
        errorMessage = ""

        if (
            !isValidAppearanceMode(
                appearanceMode
            )
        ) {
            status = "error"

            errorMessage =
                "Unsupported appearance mode: "
                + appearanceMode

            themeApplyFailed(
                errorMessage
            )

            return false
        }

        if (
            !isValidColorStyle(
                colorStyle
            )
        ) {
            status = "error"

            errorMessage =
                "Unsupported color style: "
                + colorStyle

            themeApplyFailed(
                errorMessage
            )

            return false
        }

        const candidatePalette =
            paletteForCurrentSelection()

        if (!candidatePalette) {
            status = "error"

            errorMessage =
                "No palette is available for the current selection."

            themeApplyFailed(
                errorMessage
            )

            return false
        }

        return commitPalette(
            candidatePalette
        )
    }


    /*
     * ------------------------------------------------------------
     * Appearance selection
     * ------------------------------------------------------------
     */

    function setAppearanceMode(
        mode
    ) {
        if (!isValidAppearanceMode(mode)) {
            errorMessage =
                "Unsupported appearance mode: "
                + mode

            themeApplyFailed(
                errorMessage
            )

            return false
        }

        const previousMode =
            settings.appearanceMode

        settings.appearanceMode =
            mode

        if (!applyCurrentTheme()) {
            settings.appearanceMode =
                previousMode

            return false
        }

        return true
    }


    function setColorStyle(
        style
    ) {
        if (!isValidColorStyle(style)) {
            errorMessage =
                "Unsupported color style: "
                + style

            themeApplyFailed(
                errorMessage
            )

            return false
        }

        const previousStyle =
            settings.colorStyle

        settings.colorStyle =
            style

        if (!applyCurrentTheme()) {
            settings.colorStyle =
                previousStyle

            return false
        }

        return true
    }


    /*
     * ------------------------------------------------------------
     * Wallpaper -> Matugen generation
     * ------------------------------------------------------------
     */

    function generateThemeFromWallpaper(
        wallpaper
    ) {
        if (!wallpaper)
            return false

        /*
         * Avoid multiple simultaneous Matugen jobs.
         */

        if (generatingWallpaperTheme) {
            console.warn(
                "[ThemeService] Matugen generation is already running"
            )

            return false
        }

        if (
            !Core.ServiceRegistry.backend
            || !Core.ServiceRegistry.backend.online
        ) {
            console.warn(
                "[ThemeService] Backend unavailable for Matugen generation"
            )

            return false
        }

        const path =
            wallpaper.path !== undefined
                ? wallpaper.path
                : ""

        const mediaType =
            wallpaper.type !== undefined
                ? wallpaper.type
                : null

        if (!path || path.length === 0) {
            console.warn(
                "[ThemeService] Wallpaper has no valid path"
            )

            return false
        }

        pendingThemeWallpaper =
            wallpaper

        pendingThemeGenerateRequestId =
            Core.ServiceRegistry.backend.sendCommand(
                "theme.generate",
                {
                    path: path,
                    type: mediaType
                }
            )

        if (
            !pendingThemeGenerateRequestId
            || pendingThemeGenerateRequestId.length === 0
        ) {
            pendingThemeWallpaper = null

            console.warn(
                "[ThemeService] Could not send theme.generate request"
            )

            return false
        }

        console.log(
            "[ThemeService] Generating Matugen palette from:",
            path
        )

        wallpaperThemeGenerationStarted(
            wallpaper
        )

        return true
    }


    /*
     * ------------------------------------------------------------
     * Recovery
     * ------------------------------------------------------------
     */

    function restoreLastValidPalette() {
        status = "applying"

        if (!lastValidPalette) {
            ThemeSystem.Theme.resetToDefault()

            lastValidPalette =
                ThemeSystem.Theme.defaultPalette

            settings.appearanceMode =
                "dark"

            settings.colorStyle =
                "preset"

            status = "ready"
            errorMessage = ""

            return true
        }

        return commitPalette(
            lastValidPalette
        )
    }
}
