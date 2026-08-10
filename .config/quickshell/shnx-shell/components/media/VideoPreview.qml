import QtQuick
import QtMultimedia

Item {
    id: root

    property url source: ""

    property bool playing: true
    property bool muted: true
    property bool loop: true
    property bool visiblePlaybackOnly: true

    implicitWidth: 320
    implicitHeight: 180

    MediaPlayer {
        id: player

        source:
            root.source

        audioOutput:
            audioOutput

        videoOutput:
            videoOutput

        loops:
            root.loop
                ? MediaPlayer.Infinite
                : 1

        onSourceChanged: {
            if (
                root.playing
                && (
                    !root.visiblePlaybackOnly
                    || root.visible
                )
            ) {
                play()
            }
        }
    }

    AudioOutput {
        id: audioOutput

        muted:
            root.muted
    }

    VideoOutput {
        id: videoOutput

        anchors.fill: parent

        fillMode:
            VideoOutput.PreserveAspectCrop
    }

    function updatePlayback() {
        if (
            root.playing
            && (
                !root.visiblePlaybackOnly
                || root.visible
            )
        ) {
            player.play()
        } else {
            player.pause()
        }
    }

    onPlayingChanged:
        updatePlayback()

    onVisibleChanged:
        updatePlayback()

    Component.onCompleted:
        updatePlayback()
}
