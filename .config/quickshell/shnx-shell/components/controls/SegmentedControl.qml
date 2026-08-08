import QtQuick

import "../../theme" as ShellTheme
import "../../motion" as Motion

Item {
    id: root

    required property var options

    property int currentIndex: 0
    property bool enabled: true

    signal selected(int index)

    implicitWidth: 176
    implicitHeight: 30

    readonly property int optionCount:
        root.options ? root.options.length : 0

    Rectangle {
        anchors.fill: parent

        radius:
            height / 2

        color:
            ShellTheme.Theme.colors.surfaceContainerLowest

        opacity:
            root.enabled ? 1.0 : 0.45

        Behavior on opacity {
            NumberAnimation {
                duration:
                    Motion.MotionTokens.quick

                easing.type:
                    Motion.Easing.standard
            }
        }

        Rectangle {
            id: selectionBackground

            visible:
                root.optionCount > 0

            width:
                root.width / Math.max(1, root.optionCount) - 4

            height:
                parent.height - 4

            x:
                2
                + root.currentIndex
                * (root.width / Math.max(1, root.optionCount))

            y: 2

            radius:
                height / 2

            color:
                ShellTheme.Theme.colors.surfaceContainerHigh

            Behavior on x {
                NumberAnimation {
                    duration:
                        Motion.MotionTokens.standard

                    easing.type:
                        Motion.Easing.standard
                }
            }
        }

        Row {
            anchors.fill: parent

            Repeater {
                model:
                    root.options

                delegate: Item {
                    required property int index
                    required property var modelData

                    width:
                        root.width / Math.max(1, root.optionCount)

                    height:
                        root.height

                    Text {
                        anchors.centerIn: parent

                        text:
                            String(modelData)

                        color:
                            index === root.currentIndex
                                ? ShellTheme.Theme.colors.on_surface
                                : ShellTheme.Theme.colors.on_surface_variant

                        font.family:
                            ShellTheme.Theme.typography.fontFamily

                        font.pixelSize:
                            ShellTheme.Theme.typography.labelMedium

                        font.weight:
                            index === root.currentIndex
                                ? Font.Medium
                                : Font.Normal

                        Behavior on color {
                            ColorAnimation {
                                duration:
                                    Motion.MotionTokens.quick

                                easing.type:
                                    Motion.Easing.standard
                            }
                        }
                    }

                    TapHandler {
                        enabled:
                            root.enabled

                        acceptedButtons:
                            Qt.LeftButton

                        onTapped: {
                            if (root.currentIndex === index)
                                return

                            root.currentIndex = index
                            root.selected(index)
                        }
                    }
                }
            }
        }
    }
}
