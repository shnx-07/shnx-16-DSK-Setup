import QtQuick

import qs.core as Core
import qs.theme as ShellTheme

Item {
    id: root

    property var wallpaper: null

    readonly property var wallpaperService:
        Core.ServiceRegistry.wallpaper

    readonly property string previewPath:
        wallpaperService
            ? wallpaperService.previewPathFor(wallpaper)
            : ""

    readonly property string previewSource:
        previewPath.length > 0
            ? "file://" + previewPath
            : ""

    readonly property bool hasPreview:
        previewSource.length > 0

    readonly property string mediaType:
        wallpaper
        && wallpaper.type
            ? wallpaper.type
            : "static"

    clip: true

    Rectangle {
        anchors.fill: parent

        radius:
            ShellTheme.Theme.radius.card

        color:
            ShellTheme.Theme.colors.surfaceContainerLow

        clip: true

        Image {
            id: previewImage

            anchors.fill: parent

            visible:
                root.hasPreview

            source:
                root.previewSource

            fillMode:
                Image.PreserveAspectCrop

            asynchronous: true
            cache: true
            smooth: true
        }

        Rectangle {
            anchors.fill: parent

            visible:
                !root.hasPreview

            radius:
                ShellTheme.Theme.radius.card

            color:
                ShellTheme.Theme.colors.surfaceContainerHigh

            Column {
                anchors.centerIn: parent

                spacing:
                    ShellTheme.Theme.spacing.small

                Text {
                    anchors.horizontalCenter:
                        parent.horizontalCenter

                    text: "󰋩"

                    color:
                        ShellTheme.Theme.colors.on_surface_variant

                    font.pixelSize:
                        ShellTheme.Theme.typography.displaySmall
                }

                Text {
                    anchors.horizontalCenter:
                        parent.horizontalCenter

                    text:
                        "Preview unavailable"

                    color:
                        ShellTheme.Theme.colors.on_surface_variant

                    font.family:
                        ShellTheme.Theme.typography.fontFamily

                    font.pixelSize:
                        ShellTheme.Theme.typography.bodySmall
                }
            }
        }

        Rectangle {
            anchors.fill: parent

            radius:
                ShellTheme.Theme.radius.card

            color: "transparent"

            border.width: 1

            border.color:
                ShellTheme.Theme.colors.outlineVariant
        }
    }
}


