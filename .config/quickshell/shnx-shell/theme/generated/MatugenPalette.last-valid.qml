pragma Singleton

import QtQuick

QtObject {
    readonly property QtObject darkPalette: QtObject {
        readonly property color primary: "#aac7ff"
        readonly property color on_primary: "#0b305f"
        readonly property color primaryContainer: "#284777"
        readonly property color on_primary_container: "#d7e3ff"

        readonly property color secondary: "#bec6dc"
        readonly property color on_secondary: "#283141"
        readonly property color secondaryContainer: "#3e4759"
        readonly property color on_secondary_container: "#dae2f9"

        readonly property color tertiary: "#ddbce0"
        readonly property color on_tertiary: "#3f2844"
        readonly property color tertiaryContainer: "#573e5c"
        readonly property color on_tertiary_container: "#fad8fd"

        readonly property color background: "#111318"
        readonly property color on_background: "#e2e2e9"

        readonly property color surface: "#111318"
        readonly property color surfaceDim: "#111318"
        readonly property color surfaceBright: "#37393e"
        readonly property color surfaceContainerLowest: "#0c0e13"
        readonly property color surfaceContainerLow: "#191c20"
        readonly property color surfaceContainer: "#1e2025"
        readonly property color surfaceContainerHigh: "#282a2f"
        readonly property color surfaceContainerHighest: "#33353a"

        readonly property color on_surface: "#e2e2e9"
        readonly property color on_surface_variant: "#c4c6d0"

        readonly property color inverseSurface: "#e2e2e9"
        readonly property color inverse_on_surface: "#2e3036"
        readonly property color inversePrimary: "#415f91"

        readonly property color outline: "#8e9099"
        readonly property color outlineVariant: "#44474e"
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
        readonly property color primary: "#415f91"
        readonly property color on_primary: "#ffffff"
        readonly property color primaryContainer: "#d7e3ff"
        readonly property color on_primary_container: "#001b3e"

        readonly property color secondary: "#565e71"
        readonly property color on_secondary: "#ffffff"
        readonly property color secondaryContainer: "#dae2f9"
        readonly property color on_secondary_container: "#131c2b"

        readonly property color tertiary: "#705575"
        readonly property color on_tertiary: "#ffffff"
        readonly property color tertiaryContainer: "#fad8fd"
        readonly property color on_tertiary_container: "#28132e"

        readonly property color background: "#f9f9ff"
        readonly property color on_background: "#191c20"

        readonly property color surface: "#f9f9ff"
        readonly property color surfaceDim: "#d9d9e0"
        readonly property color surfaceBright: "#f9f9ff"
        readonly property color surfaceContainerLowest: "#ffffff"
        readonly property color surfaceContainerLow: "#f3f3fa"
        readonly property color surfaceContainer: "#ededf4"
        readonly property color surfaceContainerHigh: "#e7e8ee"
        readonly property color surfaceContainerHighest: "#e2e2e9"

        readonly property color on_surface: "#191c20"
        readonly property color on_surface_variant: "#44474e"

        readonly property color inverseSurface: "#2e3036"
        readonly property color inverse_on_surface: "#f0f0f7"
        readonly property color inversePrimary: "#aac7ff"

        readonly property color outline: "#74777f"
        readonly property color outlineVariant: "#c4c6d0"
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
