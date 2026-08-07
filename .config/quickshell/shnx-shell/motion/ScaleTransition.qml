import QtQuick

import "." as Motion

Behavior {
    id: root

    property int duration:
        Motion.MotionTokens.standard

    property int easingType:
        Motion.Easing.standard

    NumberAnimation {
        duration:
            root.duration

        easing.type:
            root.easingType
    }
}
