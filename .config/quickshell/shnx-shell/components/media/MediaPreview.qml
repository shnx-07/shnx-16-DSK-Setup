import QtQuick

import "../media" as Media

Item {
    id: root

    enum MediaType {
        StaticImage,
        AnimatedImage,
        Video
    }

    property int mediaType:
        MediaPreview.StaticImage

    property url source: ""

    property bool playing: true
    property bool muted: true
    property bool loop: true

    property int fillMode:
        Image.PreserveAspectCrop

    implicitWidth: 320
    implicitHeight: 180

    Image {
        anchors.fill: parent

        visible:
            root.mediaType === MediaPreview.StaticImage

        source:
            root.source

        fillMode:
            root.fillMode

        smooth:
            true

        mipmap:
            true

        asynchronous:
            true

        cache:
            true
    }

    Media.AnimatedImagePreview {
        anchors.fill: parent

        visible:
            root.mediaType === MediaPreview.AnimatedImage

        source:
            root.source

        playing:
            root.playing

        fillMode:
            root.fillMode
    }

    Media.VideoPreview {
        anchors.fill: parent

        visible:
            root.mediaType === MediaPreview.Video

        source:
            root.source

        playing:
            root.playing

        muted:
            root.muted

        loop:
            root.loop
    }
}
