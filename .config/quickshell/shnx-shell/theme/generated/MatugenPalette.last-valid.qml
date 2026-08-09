pragma Singleton

import QtQuick

QtObject {
    readonly property QtObject darkPalette: QtObject {
        readonly property color primary: "#e5b6f2"
        readonly property color on_primary: "#452253"
        readonly property color primaryContainer: "#5d386b"
        readonly property color on_primary_container: "#f8d8ff"

        readonly property color secondary: "#d4c0d7"
        readonly property color on_secondary: "#392c3d"
        readonly property color secondaryContainer: "#514254"
        readonly property color on_secondary_container: "#f1dcf4"

        readonly property color tertiary: "#f5b7b4"
        readonly property color on_tertiary: "#4c2524"
        readonly property color tertiaryContainer: "#663b39"
        readonly property color on_tertiary_container: "#ffdad8"

        readonly property color background: "#161217"
        readonly property color on_background: "#e9e0e7"

        readonly property color surface: "#161217"
        readonly property color surfaceDim: "#161217"
        readonly property color surfaceBright: "#3d373d"
        readonly property color surfaceContainerLowest: "#110d12"
        readonly property color surfaceContainerLow: "#1f1a1f"
        readonly property color surfaceContainer: "#231e23"
        readonly property color surfaceContainerHigh: "#2d282e"
        readonly property color surfaceContainerHighest: "#383339"

        readonly property color on_surface: "#e9e0e7"
        readonly property color on_surface_variant: "#cec3cd"

        readonly property color inverseSurface: "#e9e0e7"
        readonly property color inverse_on_surface: "#342f34"
        readonly property color inversePrimary: "#765084"

        readonly property color outline: "#978e97"
        readonly property color outlineVariant: "#4c444d"
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
        readonly property color primary: "#765084"
        readonly property color on_primary: "#ffffff"
        readonly property color primaryContainer: "#f8d8ff"
        readonly property color on_primary_container: "#2e0a3c"

        readonly property color secondary: "#69596d"
        readonly property color on_secondary: "#ffffff"
        readonly property color secondaryContainer: "#f1dcf4"
        readonly property color on_secondary_container: "#231728"

        readonly property color tertiary: "#815250"
        readonly property color on_tertiary: "#ffffff"
        readonly property color tertiaryContainer: "#ffdad8"
        readonly property color on_tertiary_container: "#331110"

        readonly property color background: "#fff7fb"
        readonly property color on_background: "#1f1a1f"

        readonly property color surface: "#fff7fb"
        readonly property color surfaceDim: "#e1d7df"
        readonly property color surfaceBright: "#fff7fb"
        readonly property color surfaceContainerLowest: "#ffffff"
        readonly property color surfaceContainerLow: "#fbf1f8"
        readonly property color surfaceContainer: "#f5ebf2"
        readonly property color surfaceContainerHigh: "#efe5ed"
        readonly property color surfaceContainerHighest: "#e9e0e7"

        readonly property color on_surface: "#1f1a1f"
        readonly property color on_surface_variant: "#4c444d"

        readonly property color inverseSurface: "#342f34"
        readonly property color inverse_on_surface: "#f8eef5"
        readonly property color inversePrimary: "#e5b6f2"

        readonly property color outline: "#7d747d"
        readonly property color outlineVariant: "#cec3cd"
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
