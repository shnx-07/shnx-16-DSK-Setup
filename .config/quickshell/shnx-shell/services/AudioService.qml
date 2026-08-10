import QtQuick
import Quickshell.Services.Pipewire

QtObject {
    id: root

    readonly property var sink:
        Pipewire.defaultAudioSink

    readonly property var source:
        Pipewire.defaultAudioSource

    property PwObjectTracker sinkTracker: PwObjectTracker {
        objects: [
            root.sink,
            root.source
        ]
    }

    readonly property bool available:
        sink !== null
        && sink.audio !== null

    readonly property bool sourceAvailable:
        source !== null
        && source.audio !== null

    readonly property bool microphoneMuted:
        sourceAvailable
            ? source.audio.muted
            : false

    readonly property real volume:
        available
            ? sink.audio.volume
            : 0

    readonly property int volumePercentage:
        Math.round(volume * 100)

    readonly property bool muted:
        available
            ? sink.audio.muted
            : false

    readonly property string sinkName:
        sink !== null
        && sink.description
        && sink.description.length > 0
            ? sink.description
            : "Audio output unavailable"

    readonly property string icon:
        muted || volumePercentage === 0
            ? "󰖁"
            : volumePercentage < 34
                ? "󰕿"
                : volumePercentage < 67
                    ? "󰖀"
                    : "󰕾"

    function setVolume(value) {
        if (!available)
            return

        sink.audio.volume =
            Math.max(
                0,
                Math.min(1, value)
            )
    }

    function setVolumePercentage(value) {
        setVolume(value / 100)
    }

    function toggleMute() {
        if (!available)
            return

        sink.audio.muted =
            !sink.audio.muted
    }

    function setMuted(value) {
        if (!available)
            return

        sink.audio.muted = value
    }

    function increaseVolume(step) {
        const amount =
            step === undefined
                ? 0.05
                : step

        setVolume(volume + amount)
    }

    function decreaseVolume(step) {
        const amount =
            step === undefined
                ? 0.05
                : step

        setVolume(volume - amount)
    }

    function toggleMicrophoneMute() {
        if (!sourceAvailable)
            return

        source.audio.muted =
            !source.audio.muted
    }

    function setMicrophoneMuted(value) {
        if (!sourceAvailable)
            return

        source.audio.muted = value
    }
}

