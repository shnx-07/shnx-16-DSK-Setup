pragma Singleton

import QtQuick

QtObject {
    readonly property QtObject darkPalette: QtObject {
        readonly property color primary: "#ffb2b7"
        readonly property color on_primary: "#561d24"
        readonly property color primaryContainer: "#723339"
        readonly property color on_primary_container: "#ffdadb"

        readonly property color secondary: "#e6bdbe"
        readonly property color on_secondary: "#44292b"
        readonly property color secondaryContainer: "#5c3f41"
        readonly property color on_secondary_container: "#ffdadb"

        readonly property color tertiary: "#e7c08e"
        readonly property color on_tertiary: "#432c06"
        readonly property color tertiaryContainer: "#5c421a"
        readonly property color on_tertiary_container: "#ffddb3"

        readonly property color background: "#1a1112"
        readonly property color on_background: "#f0dede"

        readonly property color surface: "#1a1112"
        readonly property color surfaceDim: "#1a1112"
        readonly property color surfaceBright: "#413737"
        readonly property color surfaceContainerLowest: "#140c0c"
        readonly property color surfaceContainerLow: "#22191a"
        readonly property color surfaceContainer: "#271d1e"
        readonly property color surfaceContainerHigh: "#322828"
        readonly property color surfaceContainerHighest: "#3d3232"

        readonly property color on_surface: "#f0dede"
        readonly property color on_surface_variant: "#d7c1c2"

        readonly property color inverseSurface: "#f0dede"
        readonly property color inverse_on_surface: "#382e2e"
        readonly property color inversePrimary: "#8f4a4f"

        readonly property color outline: "#9f8c8d"
        readonly property color outlineVariant: "#524344"
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
        readonly property color primary: "#8f4a4f"
        readonly property color on_primary: "#ffffff"
        readonly property color primaryContainer: "#ffdadb"
        readonly property color on_primary_container: "#3b0810"

        readonly property color secondary: "#765658"
        readonly property color on_secondary: "#ffffff"
        readonly property color secondaryContainer: "#ffdadb"
        readonly property color on_secondary_container: "#2c1517"

        readonly property color tertiary: "#76592f"
        readonly property color on_tertiary: "#ffffff"
        readonly property color tertiaryContainer: "#ffddb3"
        readonly property color on_tertiary_container: "#291800"

        readonly property color background: "#fff8f7"
        readonly property color on_background: "#22191a"

        readonly property color surface: "#fff8f7"
        readonly property color surfaceDim: "#e7d6d6"
        readonly property color surfaceBright: "#fff8f7"
        readonly property color surfaceContainerLowest: "#ffffff"
        readonly property color surfaceContainerLow: "#fff0f0"
        readonly property color surfaceContainer: "#fceaea"
        readonly property color surfaceContainerHigh: "#f6e4e4"
        readonly property color surfaceContainerHighest: "#f0dede"

        readonly property color on_surface: "#22191a"
        readonly property color on_surface_variant: "#524344"

        readonly property color inverseSurface: "#382e2e"
        readonly property color inverse_on_surface: "#ffedec"
        readonly property color inversePrimary: "#ffb2b7"

        readonly property color outline: "#857373"
        readonly property color outlineVariant: "#d7c1c2"
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
