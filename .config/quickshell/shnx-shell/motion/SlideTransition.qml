import QtQuick

import "." as Motion

Behavior {
    id: root

    property int duration:
        Motion.MotionTokens.emphasized

    property int easingType:
        Motion.Easing.emphasized

    NumberAnimation {
        duration:
            root.duration

        easing.type:
            root.easingType
    }
}
