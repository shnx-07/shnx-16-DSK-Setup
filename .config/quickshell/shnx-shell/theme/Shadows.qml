import QtQuick

QtObject {
    readonly property color color: "#000000"

    readonly property real noneOpacity: 0.0
    readonly property real lowOpacity: 0.18
    readonly property real mediumOpacity: 0.24
    readonly property real highOpacity: 0.32

    readonly property int noneBlur: 0
    readonly property int lowBlur: 12
    readonly property int mediumBlur: 24
    readonly property int highBlur: 40

    readonly property int noneOffsetX: 0
    readonly property int noneOffsetY: 0

    readonly property int lowOffsetX: 0
    readonly property int lowOffsetY: 4

    readonly property int mediumOffsetX: 0
    readonly property int mediumOffsetY: 8

    readonly property int highOffsetX: 0
    readonly property int highOffsetY: 14
}
