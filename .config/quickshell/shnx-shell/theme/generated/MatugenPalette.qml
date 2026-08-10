pragma Singleton

import QtQuick

QtObject {
    readonly property QtObject darkPalette: QtObject {
        readonly property color primary: "#ffb4aa"
        readonly property color on_primary: "#561e19"
        readonly property color primaryContainer: "#73342d"
        readonly property color on_primary_container: "#ffdad5"

        readonly property color secondary: "#e7bdb7"
        readonly property color on_secondary: "#442926"
        readonly property color secondaryContainer: "#5d3f3b"
        readonly property color on_secondary_container: "#ffdad5"

        readonly property color tertiary: "#dfc38c"
        readonly property color on_tertiary: "#3f2e04"
        readonly property color tertiaryContainer: "#574419"
        readonly property color on_tertiary_container: "#fddfa6"

        readonly property color background: "#1a1110"
        readonly property color on_background: "#f1dedc"

        readonly property color surface: "#1a1110"
        readonly property color surfaceDim: "#1a1110"
        readonly property color surfaceBright: "#423735"
        readonly property color surfaceContainerLowest: "#140c0b"
        readonly property color surfaceContainerLow: "#231918"
        readonly property color surfaceContainer: "#271d1c"
        readonly property color surfaceContainerHigh: "#322826"
        readonly property color surfaceContainerHighest: "#3d3231"

        readonly property color on_surface: "#f1dedc"
        readonly property color on_surface_variant: "#d8c2bf"

        readonly property color inverseSurface: "#f1dedc"
        readonly property color inverse_on_surface: "#392e2d"
        readonly property color inversePrimary: "#904a42"

        readonly property color outline: "#a08c8a"
        readonly property color outlineVariant: "#534341"
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
        readonly property color primary: "#904a42"
        readonly property color on_primary: "#ffffff"
        readonly property color primaryContainer: "#ffdad5"
        readonly property color on_primary_container: "#3b0906"

        readonly property color secondary: "#775652"
        readonly property color on_secondary: "#ffffff"
        readonly property color secondaryContainer: "#ffdad5"
        readonly property color on_secondary_container: "#2c1512"

        readonly property color tertiary: "#715b2e"
        readonly property color on_tertiary: "#ffffff"
        readonly property color tertiaryContainer: "#fddfa6"
        readonly property color on_tertiary_container: "#261a00"

        readonly property color background: "#fff8f7"
        readonly property color on_background: "#231918"

        readonly property color surface: "#fff8f7"
        readonly property color surfaceDim: "#e8d6d4"
        readonly property color surfaceBright: "#fff8f7"
        readonly property color surfaceContainerLowest: "#ffffff"
        readonly property color surfaceContainerLow: "#fff0ee"
        readonly property color surfaceContainer: "#fceae7"
        readonly property color surfaceContainerHigh: "#f6e4e2"
        readonly property color surfaceContainerHighest: "#f1dedc"

        readonly property color on_surface: "#231918"
        readonly property color on_surface_variant: "#534341"

        readonly property color inverseSurface: "#392e2d"
        readonly property color inverse_on_surface: "#ffedea"
        readonly property color inversePrimary: "#ffb4aa"

        readonly property color outline: "#857370"
        readonly property color outlineVariant: "#d8c2bf"
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
