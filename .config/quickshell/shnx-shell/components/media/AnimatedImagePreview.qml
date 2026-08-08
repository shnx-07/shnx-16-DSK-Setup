import QtQuick

Item {
    id: root

    property url source: ""

    property bool playing: true
    property bool visiblePlaybackOnly: true

    property int fillMode:
        Image.PreserveAspectCrop

    property bool smooth: true

    implicitWidth: 320
    implicitHeight: 180

    AnimatedImage {
        id: animatedImage

        anchors.fill: parent

        source:
            root.source

        fillMode:
            root.fillMode

        smooth:
            root.smooth

        asynchronous:
            true

        cache:
            true

        playing:
            root.playing
            && (
                !root.visiblePlaybackOnly
                || root.visible
            )
    }
}
