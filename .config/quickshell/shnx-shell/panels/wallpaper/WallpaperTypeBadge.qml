import QtQuick

import qs.theme as ShellTheme

Rectangle {
    id: root

    /*
     * Supported values:
     *
     * static
     * gif
     * video
     * slideshow
     */
    property string mediaType: "static"

    readonly property string normalizedType:
        mediaType
            ? mediaType.toLowerCase()
            : "static"

    readonly property string displayText: {
        switch (normalizedType) {
        case "gif":
            return "GIF"

        case "video":
            return "VIDEO"

        case "slideshow":
            return "SLIDESHOW"

        default:
            return "IMAGE"
        }
    }

    readonly property color badgeColor: {
        switch (normalizedType) {
        case "gif":
            return ShellTheme.Theme.colors.tertiaryContainer

        case "video":
            return ShellTheme.Theme.colors.primaryContainer

        case "slideshow":
            return ShellTheme.Theme.colors.secondaryContainer

        default:
            return ShellTheme.Theme.colors.surfaceContainerHighest
        }
    }

    readonly property color badgeTextColor: {
        switch (normalizedType) {
        case "gif":
            return ShellTheme.Theme.colors.on_tertiary_container

        case "video":
            return ShellTheme.Theme.colors.on_primary_container

        case "slideshow":
            return ShellTheme.Theme.colors.on_secondary_container

        default:
            return ShellTheme.Theme.colors.on_surface
        }
    }

    implicitWidth:
        badgeLabel.implicitWidth
        + ShellTheme.Theme.spacing.medium * 2

    implicitHeight:
        badgeLabel.implicitHeight
        + ShellTheme.Theme.spacing.small

    radius:
        ShellTheme.Theme.radius.pill

    color:
        badgeColor

    Text {
        id: badgeLabel

        anchors.centerIn: parent

        text:
            root.displayText

        color:
            root.badgeTextColor

        font.family:
            ShellTheme.Theme.typography.fontFamily

        font.pixelSize:
            ShellTheme.Theme.typography.labelSmall

        font.weight:
            ShellTheme.Theme.typography.weightSemiBold

        font.letterSpacing:
            ShellTheme.Theme.typography.letterSpacingWide
    }
}
