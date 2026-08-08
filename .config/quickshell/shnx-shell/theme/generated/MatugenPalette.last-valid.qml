pragma Singleton

import QtQuick

QtObject {
    readonly property QtObject darkPalette: QtObject {
        readonly property color primary: "#92cef5"
        readonly property color on_primary: "#00344b"
        readonly property color primaryContainer: "#004c6b"
        readonly property color on_primary_container: "#c6e7ff"

        readonly property color secondary: "#b6c9d8"
        readonly property color on_secondary: "#21323e"
        readonly property color secondaryContainer: "#374955"
        readonly property color on_secondary_container: "#d2e5f4"

        readonly property color tertiary: "#ccc1e9"
        readonly property color on_tertiary: "#332c4b"
        readonly property color tertiaryContainer: "#4a4263"
        readonly property color on_tertiary_container: "#e8ddff"

        readonly property color background: "#0f1417"
        readonly property color on_background: "#dfe3e7"

        readonly property color surface: "#0f1417"
        readonly property color surfaceDim: "#0f1417"
        readonly property color surfaceBright: "#353a3d"
        readonly property color surfaceContainerLowest: "#0a0f12"
        readonly property color surfaceContainerLow: "#181c1f"
        readonly property color surfaceContainer: "#1c2024"
        readonly property color surfaceContainerHigh: "#262a2e"
        readonly property color surfaceContainerHighest: "#313539"

        readonly property color on_surface: "#dfe3e7"
        readonly property color on_surface_variant: "#c1c7ce"

        readonly property color inverseSurface: "#dfe3e7"
        readonly property color inverse_on_surface: "#2d3135"
        readonly property color inversePrimary: "#216487"

        readonly property color outline: "#8b9198"
        readonly property color outlineVariant: "#41484d"
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
        readonly property color primary: "#216487"
        readonly property color on_primary: "#ffffff"
        readonly property color primaryContainer: "#c6e7ff"
        readonly property color on_primary_container: "#001e2d"

        readonly property color secondary: "#4f616e"
        readonly property color on_secondary: "#ffffff"
        readonly property color secondaryContainer: "#d2e5f4"
        readonly property color on_secondary_container: "#0b1d28"

        readonly property color tertiary: "#62597c"
        readonly property color on_tertiary: "#ffffff"
        readonly property color tertiaryContainer: "#e8ddff"
        readonly property color on_tertiary_container: "#1e1635"

        readonly property color background: "#f6fafe"
        readonly property color on_background: "#181c1f"

        readonly property color surface: "#f6fafe"
        readonly property color surfaceDim: "#d7dadf"
        readonly property color surfaceBright: "#f6fafe"
        readonly property color surfaceContainerLowest: "#ffffff"
        readonly property color surfaceContainerLow: "#f0f4f8"
        readonly property color surfaceContainer: "#ebeef3"
        readonly property color surfaceContainerHigh: "#e5e8ed"
        readonly property color surfaceContainerHighest: "#dfe3e7"

        readonly property color on_surface: "#181c1f"
        readonly property color on_surface_variant: "#41484d"

        readonly property color inverseSurface: "#2d3135"
        readonly property color inverse_on_surface: "#eef1f6"
        readonly property color inversePrimary: "#92cef5"

        readonly property color outline: "#71787e"
        readonly property color outlineVariant: "#c1c7ce"
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
