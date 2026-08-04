import QtQuick
import Quickshell
import "modules" as Modules

Scope {
    id: root

    readonly property int barHeight: 44

    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: barWindow

                required property var modelData

                screen: modelData

                anchors {
                    top: true
                    left: true
                    right: true
                }

                implicitHeight: root.barHeight
                exclusiveZone: root.barHeight

                aboveWindows: true
                focusable: false
                color: "#111318"

                Item {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10

                    Modules.LeftSection {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Modules.CenterSection {
                        anchors.centerIn: parent
                    }

                    Modules.RightSection {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }
}
