import QtQuick
import Quickshell
import Quickshell.Io
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

    readonly property string appearanceMode: settings.appearanceMode
    readonly property string colorStyle: settings.colorStyle

    readonly property var validAppearanceModes: [
        "dark",
        "light",
        "gray"
    ]

    readonly property var validColorStyles: [
        "preset",
        "wallpaperAccents",
        "wallpaperFull"
    ]

    property string status: "ready"
    property string errorMessage: ""

    readonly property bool isApplying: status === "applying"
    readonly property bool hasError: errorMessage.length > 0

    property QtObject lastValidPalette: ThemeSystem.Theme.darkPalette

    /*
     * Structural preset selected by appearanceMode.
     */
    readonly property QtObject activePreset:
        presetForMode(appearanceMode)

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
        generatedPaletteForMode(appearanceMode)

    /*
     * Hybrid wallpaper accent mode:
     * - accents come from generated palette
     * - structure/content/status come from selected preset
     */
    readonly property QtObject wallpaperAccentPalette: QtObject {
        // Generated accent roles
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


        // Preset structural roles
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


        // Preset content roles
        readonly property color on_surface:
            root.activePreset.on_surface

        readonly property color on_surface_variant:
            root.activePreset.on_surface_variant

        readonly property color inverseSurface:
            root.activePreset.inverseSurface

        readonly property color inverse_on_surface:
            root.activePreset.inverse_on_surface

        // Accent-related inverse role from generated palette
        readonly property color inversePrimary:
            root.activeGeneratedPalette.inversePrimary


        // Preset outline and overlays
        readonly property color outline:
            root.activePreset.outline

        readonly property color outlineVariant:
            root.activePreset.outlineVariant

        readonly property color shadow:
            root.activePreset.shadow

        readonly property color scrim:
            root.activePreset.scrim


        // Preset error roles
        readonly property color error:
            root.activePreset.error

        readonly property color on_error:
            root.activePreset.on_error

        readonly property color errorContainer:
            root.activePreset.errorContainer

        readonly property color on_error_container:
            root.activePreset.on_error_container


        // Preset success roles
        readonly property color success:
            root.activePreset.success

        readonly property color on_success:
            root.activePreset.on_success

        readonly property color successContainer:
            root.activePreset.successContainer

        readonly property color on_success_container:
            root.activePreset.on_success_container


        // Preset warning roles
        readonly property color warning:
            root.activePreset.warning

        readonly property color on_warning:
            root.activePreset.on_warning

        readonly property color warningContainer:
            root.activePreset.warningContainer

        readonly property color on_warning_container:
            root.activePreset.on_warning_container


        // Preset information roles
        readonly property color info:
            root.activePreset.info

        readonly property color on_info:
            root.activePreset.on_info

        readonly property color infoContainer:
            root.activePreset.infoContainer

        readonly property color on_info_container:
            root.activePreset.on_info_container
    }

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

    signal themeApplied(string appearanceMode, string colorStyle)
    signal themeApplyFailed(string message)

    Component.onCompleted: {
        if (settingsFile.loaded)
            applyCurrentTheme()
    }

    function isValidAppearanceMode(mode) {
        return validAppearanceModes.indexOf(mode) !== -1
    }

    function isValidColorStyle(style) {
        return validColorStyles.indexOf(style) !== -1
    }

    function presetForMode(mode) {
        switch (mode) {
        case "light":
            return ThemeSystem.Theme.lightPalette
        case "gray":
            return ThemeSystem.Theme.grayPalette
        case "dark":
        default:
            return ThemeSystem.Theme.darkPalette
        }
    }

    function generatedPaletteForMode(mode) {
        switch (mode) {
        case "light":
            return Generated.MatugenPalette.lightPalette
        case "gray":
            return Generated.MatugenPalette.darkPalette
        case "dark":
        default:
            return Generated.MatugenPalette.darkPalette
        }
    }

    function paletteForCurrentSelection() {
        switch (colorStyle) {
        case "preset":
            return presetForMode(appearanceMode)

        case "wallpaperAccents":
            return wallpaperAccentPalette

        case "wallpaperFull":
            return activeGeneratedPalette

        default:
            return null
        }
    }

    function validatePalette(candidatePalette) {
        if (!candidatePalette) {
            return {
                valid: false,
                message: "Palette object is missing."
            }
        }

        for (let index = 0; index < requiredColorRoles.length; index++) {
            const role = requiredColorRoles[index]

            if (candidatePalette[role] === undefined
                    || candidatePalette[role] === null) {
                return {
                    valid: false,
                    message: "Palette is missing required role: " + role
                }
            }
        }

        return {
            valid: true,
            message: ""
        }
    }

    function commitPalette(candidatePalette) {
        const validation = validatePalette(candidatePalette)

        if (!validation.valid) {
            status = "error"
            errorMessage = validation.message
            themeApplyFailed(errorMessage)
            return false
        }

        if (!ThemeSystem.Theme.applyPalette(candidatePalette)) {
            status = "error"
            errorMessage = "Theme rejected the candidate palette."
            themeApplyFailed(errorMessage)
            return false
        }

        lastValidPalette = candidatePalette
        status = "ready"
        errorMessage = ""

        themeApplied(appearanceMode, colorStyle)
        return true
    }

    function applyCurrentTheme() {
        status = "applying"
        errorMessage = ""

        if (!isValidAppearanceMode(appearanceMode)) {
            status = "error"
            errorMessage = "Unsupported appearance mode: " + appearanceMode
            themeApplyFailed(errorMessage)
            return false
        }

        if (!isValidColorStyle(colorStyle)) {
            status = "error"
            errorMessage = "Unsupported color style: " + colorStyle
            themeApplyFailed(errorMessage)
            return false
        }

        const candidatePalette = paletteForCurrentSelection()

        if (!candidatePalette) {
            status = "error"
            errorMessage = "No palette is available for the current selection."
            themeApplyFailed(errorMessage)
            return false
        }

        return commitPalette(candidatePalette)
    }

    function setAppearanceMode(mode) {
        if (!isValidAppearanceMode(mode)) {
            errorMessage = "Unsupported appearance mode: " + mode
            themeApplyFailed(errorMessage)
            return false
        }

        const previousMode = settings.appearanceMode
        settings.appearanceMode = mode

        if (!applyCurrentTheme()) {
            settings.appearanceMode = previousMode
            return false
        }

        return true
    }

    function setColorStyle(style) {
        if (!isValidColorStyle(style)) {
            errorMessage = "Unsupported color style: " + style
            themeApplyFailed(errorMessage)
            return false
        }

        const previousStyle = settings.colorStyle
        settings.colorStyle = style

        if (!applyCurrentTheme()) {
            settings.colorStyle = previousStyle
            return false
        }

        return true
    }

    function restoreLastValidPalette() {
        status = "applying"

        if (!lastValidPalette) {
            ThemeSystem.Theme.resetToDefault()
            lastValidPalette = ThemeSystem.Theme.defaultPalette
            settings.appearanceMode = "dark"
            settings.colorStyle = "preset"
            status = "ready"
            errorMessage = ""
            return true
        }

        return commitPalette(lastValidPalette)
    }
}
