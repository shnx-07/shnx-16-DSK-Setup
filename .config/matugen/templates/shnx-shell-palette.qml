pragma Singleton

import QtQuick

QtObject {
    readonly property QtObject darkPalette: QtObject {
        readonly property color primary: "{{ colors.primary.dark.hex }}"
        readonly property color on_primary: "{{ colors.on_primary.dark.hex }}"
        readonly property color primaryContainer: "{{ colors.primary_container.dark.hex }}"
        readonly property color on_primary_container: "{{ colors.on_primary_container.dark.hex }}"

        readonly property color secondary: "{{ colors.secondary.dark.hex }}"
        readonly property color on_secondary: "{{ colors.on_secondary.dark.hex }}"
        readonly property color secondaryContainer: "{{ colors.secondary_container.dark.hex }}"
        readonly property color on_secondary_container: "{{ colors.on_secondary_container.dark.hex }}"

        readonly property color tertiary: "{{ colors.tertiary.dark.hex }}"
        readonly property color on_tertiary: "{{ colors.on_tertiary.dark.hex }}"
        readonly property color tertiaryContainer: "{{ colors.tertiary_container.dark.hex }}"
        readonly property color on_tertiary_container: "{{ colors.on_tertiary_container.dark.hex }}"

        readonly property color background: "{{ colors.background.dark.hex }}"
        readonly property color on_background: "{{ colors.on_background.dark.hex }}"

        readonly property color surface: "{{ colors.surface.dark.hex }}"
        readonly property color surfaceDim: "{{ colors.surface_dim.dark.hex }}"
        readonly property color surfaceBright: "{{ colors.surface_bright.dark.hex }}"
        readonly property color surfaceContainerLowest: "{{ colors.surface_container_lowest.dark.hex }}"
        readonly property color surfaceContainerLow: "{{ colors.surface_container_low.dark.hex }}"
        readonly property color surfaceContainer: "{{ colors.surface_container.dark.hex }}"
        readonly property color surfaceContainerHigh: "{{ colors.surface_container_high.dark.hex }}"
        readonly property color surfaceContainerHighest: "{{ colors.surface_container_highest.dark.hex }}"

        readonly property color on_surface: "{{ colors.on_surface.dark.hex }}"
        readonly property color on_surface_variant: "{{ colors.on_surface_variant.dark.hex }}"

        readonly property color inverseSurface: "{{ colors.inverse_surface.dark.hex }}"
        readonly property color inverse_on_surface: "{{ colors.inverse_on_surface.dark.hex }}"
        readonly property color inversePrimary: "{{ colors.inverse_primary.dark.hex }}"

        readonly property color outline: "{{ colors.outline.dark.hex }}"
        readonly property color outlineVariant: "{{ colors.outline_variant.dark.hex }}"
        readonly property color shadow: "{{ colors.shadow.dark.hex }}"
        readonly property color scrim: "{{ colors.scrim.dark.hex }}"

        readonly property color error: "{{ colors.error.dark.hex }}"
        readonly property color on_error: "{{ colors.on_error.dark.hex }}"
        readonly property color errorContainer: "{{ colors.error_container.dark.hex }}"
        readonly property color on_error_container: "{{ colors.on_error_container.dark.hex }}"

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
        readonly property color primary: "{{ colors.primary.light.hex }}"
        readonly property color on_primary: "{{ colors.on_primary.light.hex }}"
        readonly property color primaryContainer: "{{ colors.primary_container.light.hex }}"
        readonly property color on_primary_container: "{{ colors.on_primary_container.light.hex }}"

        readonly property color secondary: "{{ colors.secondary.light.hex }}"
        readonly property color on_secondary: "{{ colors.on_secondary.light.hex }}"
        readonly property color secondaryContainer: "{{ colors.secondary_container.light.hex }}"
        readonly property color on_secondary_container: "{{ colors.on_secondary_container.light.hex }}"

        readonly property color tertiary: "{{ colors.tertiary.light.hex }}"
        readonly property color on_tertiary: "{{ colors.on_tertiary.light.hex }}"
        readonly property color tertiaryContainer: "{{ colors.tertiary_container.light.hex }}"
        readonly property color on_tertiary_container: "{{ colors.on_tertiary_container.light.hex }}"

        readonly property color background: "{{ colors.background.light.hex }}"
        readonly property color on_background: "{{ colors.on_background.light.hex }}"

        readonly property color surface: "{{ colors.surface.light.hex }}"
        readonly property color surfaceDim: "{{ colors.surface_dim.light.hex }}"
        readonly property color surfaceBright: "{{ colors.surface_bright.light.hex }}"
        readonly property color surfaceContainerLowest: "{{ colors.surface_container_lowest.light.hex }}"
        readonly property color surfaceContainerLow: "{{ colors.surface_container_low.light.hex }}"
        readonly property color surfaceContainer: "{{ colors.surface_container.light.hex }}"
        readonly property color surfaceContainerHigh: "{{ colors.surface_container_high.light.hex }}"
        readonly property color surfaceContainerHighest: "{{ colors.surface_container_highest.light.hex }}"

        readonly property color on_surface: "{{ colors.on_surface.light.hex }}"
        readonly property color on_surface_variant: "{{ colors.on_surface_variant.light.hex }}"

        readonly property color inverseSurface: "{{ colors.inverse_surface.light.hex }}"
        readonly property color inverse_on_surface: "{{ colors.inverse_on_surface.light.hex }}"
        readonly property color inversePrimary: "{{ colors.inverse_primary.light.hex }}"

        readonly property color outline: "{{ colors.outline.light.hex }}"
        readonly property color outlineVariant: "{{ colors.outline_variant.light.hex }}"
        readonly property color shadow: "{{ colors.shadow.light.hex }}"
        readonly property color scrim: "{{ colors.scrim.light.hex }}"

        readonly property color error: "{{ colors.error.light.hex }}"
        readonly property color on_error: "{{ colors.on_error.light.hex }}"
        readonly property color errorContainer: "{{ colors.error_container.light.hex }}"
        readonly property color on_error_container: "{{ colors.on_error_container.light.hex }}"

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
