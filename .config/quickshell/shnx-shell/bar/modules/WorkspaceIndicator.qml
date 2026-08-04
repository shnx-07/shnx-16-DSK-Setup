import QtQuick
import qs.core as Core

Item {
    id: root

    implicitWidth: workspaceRow.implicitWidth
    implicitHeight: 32

    Row {
        id: workspaceRow

        anchors.fill: parent
        spacing: 5

        Repeater {
            model: Core.ServiceRegistry.hyprland.workspaces

            delegate: Rectangle {
                id: workspaceButton

                required property var modelData

                readonly property bool validWorkspace:
                    modelData && modelData.id > 0

                readonly property bool selected:
                    validWorkspace && modelData.focused

                readonly property bool active:
                    validWorkspace && modelData.active

                readonly property bool urgent:
                    validWorkspace && modelData.urgent

                visible: validWorkspace

                width: visible ? 32 : 0
                height: 32

                radius: 9

                color: {
                    if (urgent)
                        return "#8c3b46"

                    if (selected)
                        return "#596273"

                    if (active)
                        return "#3b414d"

                    if (workspaceMouse.containsMouse)
                        return "#2d323c"

                    return "#252932"
                }

                border.width: 1

                border.color: {
                    if (urgent)
                        return "#d56a76"

                    if (selected)
                        return "#aeb8ca"

                    if (workspaceMouse.containsMouse)
                        return "#596273"

                    return "#3b414d"
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 120
                    }
                }

                Text {
                    anchors.centerIn: parent

                    text: workspaceButton.modelData
                        ? workspaceButton.modelData.name
                        : ""

                    color: "#f2f3f5"

                    font.pixelSize: 12
                    font.weight: workspaceButton.selected
                        ? Font.Bold
                        : Font.DemiBold
                }

                MouseArea {
                    id: workspaceMouse

                    anchors.fill: parent

                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        Core.ServiceRegistry.hyprland.activateWorkspace(
                            workspaceButton.modelData
                        )
                    }
                }
            }
        }
    }
}
