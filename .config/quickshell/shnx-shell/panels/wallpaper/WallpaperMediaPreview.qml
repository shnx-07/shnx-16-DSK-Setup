import QtQuick

import qs.theme as ShellTheme

Item {
    id: root

    property var wallpaper: null

    readonly property string previewSource:
        wallpaper
        && wallpaper.preview
            ? "file://" + wallpaper.preview
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
            mipmap: true

            Component.onDestruction: {
                /*
                 * Cancel any in-progress async image decode before
                 * the item is freed. Setting asynchronous = false
                 * first tells Qt to abandon the background thread
                 * load synchronously, so no statusChanged notification
                 * is queued after destruction that could dereference
                 * the freed QQuickItem.
                 */
                asynchronous = false
                source = ""
            }
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

