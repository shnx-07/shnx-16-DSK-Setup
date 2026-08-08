pragma Singleton

import QtQuick

QtObject {
    readonly property QtObject darkPalette: QtObject {
        readonly property color primary: "#cfbdfe"
        readonly property color on_primary: "#35275d"
        readonly property color primaryContainer: "#4c3e75"
        readonly property color on_primary_container: "#e8ddff"

        readonly property color secondary: "#cbc2dc"
        readonly property color on_secondary: "#332d41"
        readonly property color secondaryContainer: "#494458"
        readonly property color on_secondary_container: "#e8def8"

        readonly property color tertiary: "#efb8c8"
        readonly property color on_tertiary: "#492532"
        readonly property color tertiaryContainer: "#633b49"
        readonly property color on_tertiary_container: "#ffd9e3"

        readonly property color background: "#141218"
        readonly property color on_background: "#e6e1e9"

        readonly property color surface: "#141218"
        readonly property color surfaceDim: "#141218"
        readonly property color surfaceBright: "#3b383e"
        readonly property color surfaceContainerLowest: "#0f0d13"
        readonly property color surfaceContainerLow: "#1d1b20"
        readonly property color surfaceContainer: "#211f24"
        readonly property color surfaceContainerHigh: "#2b292f"
        readonly property color surfaceContainerHighest: "#36343a"

        readonly property color on_surface: "#e6e1e9"
        readonly property color on_surface_variant: "#cac4cf"

        readonly property color inverseSurface: "#e6e1e9"
        readonly property color inverse_on_surface: "#322f35"
        readonly property color inversePrimary: "#64558f"

        readonly property color outline: "#948f99"
        readonly property color outlineVariant: "#49454e"
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
        readonly property color primary: "#64558f"
        readonly property color on_primary: "#ffffff"
        readonly property color primaryContainer: "#e8ddff"
        readonly property color on_primary_container: "#201047"

        readonly property color secondary: "#615b71"
        readonly property color on_secondary: "#ffffff"
        readonly property color secondaryContainer: "#e8def8"
        readonly property color on_secondary_container: "#1e192b"

        readonly property color tertiary: "#7d5260"
        readonly property color on_tertiary: "#ffffff"
        readonly property color tertiaryContainer: "#ffd9e3"
        readonly property color on_tertiary_container: "#31101d"

        readonly property color background: "#fdf7ff"
        readonly property color on_background: "#1d1b20"

        readonly property color surface: "#fdf7ff"
        readonly property color surfaceDim: "#ded8e0"
        readonly property color surfaceBright: "#fdf7ff"
        readonly property color surfaceContainerLowest: "#ffffff"
        readonly property color surfaceContainerLow: "#f8f2fa"
        readonly property color surfaceContainer: "#f2ecf4"
        readonly property color surfaceContainerHigh: "#ece6ee"
        readonly property color surfaceContainerHighest: "#e6e1e9"

        readonly property color on_surface: "#1d1b20"
        readonly property color on_surface_variant: "#49454e"

        readonly property color inverseSurface: "#322f35"
        readonly property color inverse_on_surface: "#f5eff7"
        readonly property color inversePrimary: "#cfbdfe"

        readonly property color outline: "#7a757f"
        readonly property color outlineVariant: "#cac4cf"
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
