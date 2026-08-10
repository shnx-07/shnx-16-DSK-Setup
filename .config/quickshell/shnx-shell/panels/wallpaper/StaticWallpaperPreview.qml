import QtQuick

import "." as WallpaperParts

Item {
    id: root

    property var wallpaper: null

    WallpaperParts.WallpaperMediaPreview {
        anchors.fill: parent

        wallpaper:
            root.wallpaper
    }
}
