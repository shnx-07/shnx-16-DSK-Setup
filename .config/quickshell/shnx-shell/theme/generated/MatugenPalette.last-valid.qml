pragma Singleton

import QtQuick

QtObject {
    readonly property QtObject darkPalette: QtObject {
        readonly property color primary: "#eab5ed"
        readonly property color on_primary: "#48204e"
        readonly property color primaryContainer: "#613766"
        readonly property color on_primary_container: "#ffd5ff"

        readonly property color secondary: "#d7bfd5"
        readonly property color on_secondary: "#3b2b3c"
        readonly property color secondaryContainer: "#524153"
        readonly property color on_secondary_container: "#f4dbf1"

        readonly property color tertiary: "#f6b8ae"
        readonly property color on_tertiary: "#4c2520"
        readonly property color tertiaryContainer: "#673b34"
        readonly property color on_tertiary_container: "#ffdad5"

        readonly property color background: "#171217"
        readonly property color on_background: "#eadfe6"

        readonly property color surface: "#171217"
        readonly property color surfaceDim: "#171217"
        readonly property color surfaceBright: "#3e373d"
        readonly property color surfaceContainerLowest: "#110d11"
        readonly property color surfaceContainerLow: "#1f1a1f"
        readonly property color surfaceContainer: "#231e23"
        readonly property color surfaceContainerHigh: "#2e282d"
        readonly property color surfaceContainerHighest: "#393338"

        readonly property color on_surface: "#eadfe6"
        readonly property color on_surface_variant: "#d0c3cc"

        readonly property color inverseSurface: "#eadfe6"
        readonly property color inverse_on_surface: "#352f34"
        readonly property color inversePrimary: "#7b4e80"

        readonly property color outline: "#998d96"
        readonly property color outlineVariant: "#4d444c"
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
        readonly property color primary: "#7b4e80"
        readonly property color on_primary: "#ffffff"
        readonly property color primaryContainer: "#ffd5ff"
        readonly property color on_primary_container: "#310938"

        readonly property color secondary: "#6b586b"
        readonly property color on_secondary: "#ffffff"
        readonly property color secondaryContainer: "#f4dbf1"
        readonly property color on_secondary_container: "#251726"

        readonly property color tertiary: "#82524b"
        readonly property color on_tertiary: "#ffffff"
        readonly property color tertiaryContainer: "#ffdad5"
        readonly property color on_tertiary_container: "#33110c"

        readonly property color background: "#fff7fa"
        readonly property color on_background: "#1f1a1f"

        readonly property color surface: "#fff7fa"
        readonly property color surfaceDim: "#e2d7de"
        readonly property color surfaceBright: "#fff7fa"
        readonly property color surfaceContainerLowest: "#ffffff"
        readonly property color surfaceContainerLow: "#fcf0f8"
        readonly property color surfaceContainer: "#f6ebf2"
        readonly property color surfaceContainerHigh: "#f0e5ec"
        readonly property color surfaceContainerHighest: "#eadfe6"

        readonly property color on_surface: "#1f1a1f"
        readonly property color on_surface_variant: "#4d444c"

        readonly property color inverseSurface: "#352f34"
        readonly property color inverse_on_surface: "#f9eef5"
        readonly property color inversePrimary: "#eab5ed"

        readonly property color outline: "#7e747d"
        readonly property color outlineVariant: "#d0c3cc"
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
