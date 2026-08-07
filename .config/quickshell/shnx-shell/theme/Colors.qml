import QtQuick

QtObject {
    id: root

    /*
     * Theme.qml replaces this reference only after a complete palette
     * has been selected and validated.
     *
     * Swapping one palette object keeps the visible theme update atomic.
     */
    property QtObject palette: null

    // Primary
    readonly property color primary:
        palette ? palette.primary : "#d0bcff"

    readonly property color on_primary:
        palette ? palette.on_primary : "#381e72"

    readonly property color primaryContainer:
        palette ? palette.primaryContainer : "#4f378b"

    readonly property color on_primary_container:
        palette ? palette.on_primary_container : "#eaddff"


    // Secondary
    readonly property color secondary:
        palette ? palette.secondary : "#ccc2dc"

    readonly property color on_secondary:
        palette ? palette.on_secondary : "#332d41"

    readonly property color secondaryContainer:
        palette ? palette.secondaryContainer : "#4a4458"

    readonly property color on_secondary_container:
        palette ? palette.on_secondary_container : "#e8def8"


    // Tertiary
    readonly property color tertiary:
        palette ? palette.tertiary : "#efb8c8"

    readonly property color on_tertiary:
        palette ? palette.on_tertiary : "#492532"

    readonly property color tertiaryContainer:
        palette ? palette.tertiaryContainer : "#633b48"

    readonly property color on_tertiary_container:
        palette ? palette.on_tertiary_container : "#ffd8e4"


    // Background
    readonly property color background:
        palette ? palette.background : "#141218"

    readonly property color on_background:
        palette ? palette.on_background : "#e6e0e9"


    // Surface hierarchy
    readonly property color surface:
        palette ? palette.surface : "#141218"

    readonly property color surfaceDim:
        palette ? palette.surfaceDim : "#141218"

    readonly property color surfaceBright:
        palette ? palette.surfaceBright : "#3b383e"

    readonly property color surfaceContainerLowest:
        palette ? palette.surfaceContainerLowest : "#0f0d13"

    readonly property color surfaceContainerLow:
        palette ? palette.surfaceContainerLow : "#1d1b20"

    readonly property color surfaceContainer:
        palette ? palette.surfaceContainer : "#211f26"

    readonly property color surfaceContainerHigh:
        palette ? palette.surfaceContainerHigh : "#2b2930"

    readonly property color surfaceContainerHighest:
        palette ? palette.surfaceContainerHighest : "#36343b"


    // Surface content
    readonly property color on_surface:
        palette ? palette.on_surface : "#e6e0e9"

    readonly property color on_surface_variant:
        palette ? palette.on_surface_variant : "#cac4d0"

    readonly property color inverseSurface:
        palette ? palette.inverseSurface : "#e6e0e9"

    readonly property color inverse_on_surface:
        palette ? palette.inverse_on_surface : "#322f35"

    readonly property color inversePrimary:
        palette ? palette.inversePrimary : "#6750a4"


    // Outline and overlays
    readonly property color outline:
        palette ? palette.outline : "#938f99"

    readonly property color outlineVariant:
        palette ? palette.outlineVariant : "#49454f"

    readonly property color shadow:
        palette ? palette.shadow : "#000000"

    readonly property color scrim:
        palette ? palette.scrim : "#000000"


    // Error
    readonly property color error:
        palette ? palette.error : "#f2b8b5"

    readonly property color on_error:
        palette ? palette.on_error : "#601410"

    readonly property color errorContainer:
        palette ? palette.errorContainer : "#8c1d18"

    readonly property color on_error_container:
        palette ? palette.on_error_container : "#f9dedc"


    // Semantic status roles
    readonly property color success:
        palette ? palette.success : "#81c995"

    readonly property color on_success:
        palette ? palette.on_success : "#0b3d20"

    readonly property color successContainer:
        palette ? palette.successContainer : "#155d35"

    readonly property color on_success_container:
        palette ? palette.on_success_container : "#a8f0bd"

    readonly property color warning:
        palette ? palette.warning : "#f9c74f"

    readonly property color on_warning:
        palette ? palette.on_warning : "#3f2e00"

    readonly property color warningContainer:
        palette ? palette.warningContainer : "#5d4300"

    readonly property color on_warning_container:
        palette ? palette.on_warning_container : "#ffe08a"

    readonly property color info:
        palette ? palette.info : "#8ab4f8"

    readonly property color on_info:
        palette ? palette.on_info : "#002f65"

    readonly property color infoContainer:
        palette ? palette.infoContainer : "#174f8f"

    readonly property color on_info_container:
        palette ? palette.on_info_container : "#d4e3ff"


    /*
     * Intentional fixed exception from the blueprint.
     * Power and destructive shell actions stay red in every theme.
     */
    readonly property color destructive: "#ff453a"
    readonly property color on_destructive: "#ffffff"
    readonly property color destructiveContainer: "#5c1614"
    readonly property color on_destructive_container: "#ffd8d4"


    // Common interaction roles
    readonly property color disabled:
        Qt.rgba(on_surface.r, on_surface.g, on_surface.b, 0.38)

    readonly property color disabledContainer:
        Qt.rgba(on_surface.r, on_surface.g, on_surface.b, 0.12)

    readonly property color hoverOverlay:
        Qt.rgba(on_surface.r, on_surface.g, on_surface.b, 0.08)

    readonly property color pressedOverlay:
        Qt.rgba(on_surface.r, on_surface.g, on_surface.b, 0.12)

    readonly property color focusOverlay:
        Qt.rgba(primary.r, primary.g, primary.b, 0.16)

    readonly property color selectedOverlay:
        Qt.rgba(primary.r, primary.g, primary.b, 0.20)
}
