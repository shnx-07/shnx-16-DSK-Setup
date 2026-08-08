pragma Singleton

import QtQuick

QtObject {
    readonly property QtObject darkPalette: QtObject {
        readonly property color primary: "#f2be6e"
        readonly property color on_primary: "#442c00"
        readonly property color primaryContainer: "#614000"
        readonly property color on_primary_container: "#ffddaf"

        readonly property color secondary: "#dcc3a1"
        readonly property color on_secondary: "#3d2e16"
        readonly property color secondaryContainer: "#55442a"
        readonly property color on_secondary_container: "#f9dfbb"

        readonly property color tertiary: "#b6cea3"
        readonly property color on_tertiary: "#233517"
        readonly property color tertiaryContainer: "#384c2b"
        readonly property color on_tertiary_container: "#d2eabd"

        readonly property color background: "#18130b"
        readonly property color on_background: "#ede1d4"

        readonly property color surface: "#18130b"
        readonly property color surfaceDim: "#18130b"
        readonly property color surfaceBright: "#3f382f"
        readonly property color surfaceContainerLowest: "#120d07"
        readonly property color surfaceContainerLow: "#201b13"
        readonly property color surfaceContainer: "#241f17"
        readonly property color surfaceContainerHigh: "#2f2921"
        readonly property color surfaceContainerHighest: "#3a342b"

        readonly property color on_surface: "#ede1d4"
        readonly property color on_surface_variant: "#d2c4b4"

        readonly property color inverseSurface: "#ede1d4"
        readonly property color inverse_on_surface: "#362f27"
        readonly property color inversePrimary: "#7e570e"

        readonly property color outline: "#9b8f80"
        readonly property color outlineVariant: "#4f4539"
        readonly property color shadow: "#000000"
        readonly property color scrim: "#000000"

        readonly property color error: "#ffb4ab"
        readonly property color on_error: "#690005"
        readonly property color errorContainer: "#93000a"
        readonly property color on_error_container: "#ffdad6"

        readonly property color success: "#81c995"
        readonly property color on_success: "#0b3d20"
        readonly property color successContainer: "#155d35"
        readonly property color on_success_container: "#a8f0bd"

        readonly property color warning: "#f9c74f"
        readonly property color on_warning: "#3f2e00"
        readonly property color warningContainer: "#5d4300"
        readonly property color on_warning_container: "#ffe08a"

        readonly property color info: "#8ab4f8"
        readonly property color on_info: "#002f65"
        readonly property color infoContainer: "#174f8f"
        readonly property color on_info_container: "#d4e3ff"
    }

    readonly property QtObject lightPalette: QtObject {
        readonly property color primary: "#7e570e"
        readonly property color on_primary: "#ffffff"
        readonly property color primaryContainer: "#ffddaf"
        readonly property color on_primary_container: "#281800"

        readonly property color secondary: "#6e5b40"
        readonly property color on_secondary: "#ffffff"
        readonly property color secondaryContainer: "#f9dfbb"
        readonly property color on_secondary_container: "#261904"

        readonly property color tertiary: "#4f6441"
        readonly property color on_tertiary: "#ffffff"
        readonly property color tertiaryContainer: "#d2eabd"
        readonly property color on_tertiary_container: "#0e2005"

        readonly property color background: "#fff8f3"
        readonly property color on_background: "#201b13"

        readonly property color surface: "#fff8f3"
        readonly property color surfaceDim: "#e4d8cc"
        readonly property color surfaceBright: "#fff8f3"
        readonly property color surfaceContainerLowest: "#ffffff"
        readonly property color surfaceContainerLow: "#fef2e5"
        readonly property color surfaceContainer: "#f8ecdf"
        readonly property color surfaceContainerHigh: "#f2e6da"
        readonly property color surfaceContainerHighest: "#ede1d4"

        readonly property color on_surface: "#201b13"
        readonly property color on_surface_variant: "#4f4539"

        readonly property color inverseSurface: "#362f27"
        readonly property color inverse_on_surface: "#fbefe2"
        readonly property color inversePrimary: "#f2be6e"

        readonly property color outline: "#817567"
        readonly property color outlineVariant: "#d2c4b4"
        readonly property color shadow: "#000000"
        readonly property color scrim: "#000000"

        readonly property color error: "#ba1a1a"
        readonly property color on_error: "#ffffff"
        readonly property color errorContainer: "#ffdad6"
        readonly property color on_error_container: "#410002"

        readonly property color success: "#2e7d32"
        readonly property color on_success: "#ffffff"
        readonly property color successContainer: "#c8e6c9"
        readonly property color on_success_container: "#0d3b12"

        readonly property color warning: "#9a6700"
        readonly property color on_warning: "#ffffff"
        readonly property color warningContainer: "#ffe08a"
        readonly property color on_warning_container: "#2f2000"

        readonly property color info: "#1967d2"
        readonly property color on_info: "#ffffff"
        readonly property color infoContainer: "#d4e3ff"
        readonly property color on_info_container: "#001b3f"
    }
}
