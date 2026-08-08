import QtQuick
import "../../theme" as ShellTheme

Item {
    id: root

    required property var options
    property int currentIndex: 0

    signal selected(int index)

    implicitWidth: 176
    implicitHeight: 30

    Rectangle {
        anchors.fill: parent

        radius: height / 2
        color: ShellTheme.Theme.colors.surfaceContainerLowest

        Rectangle {
            id: selectionBackground

            width: root.width / Math.max(1, root.options.length)
            height: parent.height - 4

            x: 2 + root.currentIndex * width
            y: 2

            radius: height / 2
            color: ShellTheme.Theme.colors.surfaceContainerHigh

            Behavior on x {
                NumberAnimation {
                    duration: 160
                    easing.type: Easing.OutCubic
                }
            }
        }

        Row {
            anchors.fill: parent

            Repeater {
                model: root.options

                delegate: Item {
                    required property int index
                    required property var modelData

                    width: root.width / Math.max(1, root.options.length)
                    height: root.height

                    Text {
                        anchors.centerIn: parent

                        text: modelData

                        color: index === root.currentIndex
                               ? ShellTheme.Theme.colors.on_surface
                               : ShellTheme.Theme.colors.on_surface_variant

                        font.pixelSize: ShellTheme.Theme.typography.labelMedium
                        font.weight: index === root.currentIndex
                                     ? Font.Medium
                                     : Font.Normal

                        Behavior on color {
                            ColorAnimation {
                                duration: 120
                            }
                        }
                    }

                    TapHandler {
                        acceptedButtons: Qt.LeftButton

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
