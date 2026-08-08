pragma Singleton

import QtQuick
import "presets" as Presets

QtObject {
    id: root

    /*
     * BASE PRESETS
     */
    readonly property QtObject darkPalette:
        Presets.Dark {}

    readonly property QtObject lightPalette:
        Presets.Light {}

    readonly property QtObject grayPalette:
        Presets.Gray {}

    /*
     * CATPPUCCIN
     */
    readonly property QtObject catppuccinMochaPalette:
        Presets.CatppuccinMocha {}

    readonly property QtObject catppuccinMacchiatoPalette:
        Presets.CatppuccinMacchiato {}

    /*
     * GRUVBOX
     */
    readonly property QtObject gruvboxDarkPalette:
        Presets.GruvboxDark {}

    readonly property QtObject gruvboxLightPalette:
        Presets.GruvboxLight {}

    /*
     * POPULAR DARK THEMES
     */
    readonly property QtObject nordPalette:
        Presets.Nord {}

    readonly property QtObject draculaPalette:
        Presets.Dracula {}

    readonly property QtObject tokyoNightPalette:
        Presets.TokyoNight {}

    /*
     * ROSE PINE
     */
    readonly property QtObject rosePinePalette:
        Presets.RosePine {}

    readonly property QtObject rosePineMoonPalette:
        Presets.RosePineMoon {}

    /*
     * EVERFOREST
     */
    readonly property QtObject everforestDarkPalette:
        Presets.EverforestDark {}

    readonly property QtObject everforestLightPalette:
        Presets.EverforestLight {}

    /*
     * OTHER PRESETS
     */
    readonly property QtObject kanagawaPalette:
        Presets.Kanagawa {}

    readonly property QtObject oneDarkPalette:
        Presets.OneDark {}

    readonly property QtObject solarizedDarkPalette:
        Presets.SolarizedDark {}

    readonly property QtObject solarizedLightPalette:
        Presets.SolarizedLight {}

    readonly property QtObject monokaiPalette:
        Presets.Monokai {}

    /*
     * MATERIAL
     */
    readonly property QtObject materialDarkPalette:
        Presets.MaterialDark {}

    readonly property QtObject materialLightPalette:
        Presets.MaterialLight {}

    /*
     * CUSTOM PRESETS
     */
    readonly property QtObject oceanPalette:
        Presets.Ocean {}

    readonly property QtObject forestPalette:
        Presets.Forest {}

    readonly property QtObject sunsetPalette:
        Presets.Sunset {}

    /*
     * AMOLED
     *
     * IMPORTANT:
     * Your screenshot showed the file as AM0LED.qml
     * with a ZERO.
     *
     * If that is still the real filename, keep:
     *
     *     Presets.AM0LED {}
     *
     * If you renamed the file to Amoled.qml,
     * change this to:
     *
     *     Presets.Amoled {}
     */
    readonly property QtObject amoledPalette:
    Presets.AMOLED {}

    /*
     * ACTIVE PALETTE
     */
    readonly property QtObject defaultPalette:
        darkPalette

    property QtObject activePalette:
        defaultPalette

    /*
     * GLOBAL THEME TOKENS
     */
    readonly property Colors colors: Colors {
        palette: root.activePalette
    }

    readonly property Typography typography:
        Typography {}

    readonly property Spacing spacing:
        Spacing {}

    readonly property Radius radius:
        Radius {}

    readonly property Shadows shadows:
        Shadows {}

    /*
     * PALETTE CONTROL
     */
    function applyPalette(candidatePalette) {
        if (!candidatePalette)
            return false

        activePalette = candidatePalette
        return true
    }

    function resetToDefault() {
        activePalette = defaultPalette
    }
}
