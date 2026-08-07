pragma Singleton

import QtQuick
import "presets" as Presets

QtObject {
    id: root

    readonly property QtObject darkPalette: Presets.Dark {}
    readonly property QtObject lightPalette: Presets.Light {}
    readonly property QtObject grayPalette: Presets.Gray {}

    readonly property QtObject defaultPalette: darkPalette
    property QtObject activePalette: defaultPalette

    readonly property Colors colors: Colors {
        palette: root.activePalette
    }

    readonly property Typography typography: Typography {}
    readonly property Spacing spacing: Spacing {}
    readonly property Radius radius: Radius {}
    readonly property Shadows shadows: Shadows {}

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
