import QtQuick
import qs.core as Core

Rectangle {
    id: root

    implicitWidth: workspaceRow.implicitWidth + 8
    implicitHeight: 32

    radius: 10

    color: "#252932"

    border.width: 1
    border.color: "#3b414d"

    Row {
        id: workspaceRow

        anchors.centerIn: parent
        spacing: 2

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

                width: visible ? 30 : 0
                height: 26

                radius: 8

                color: {
                    if (urgent)
                        return "#8c3b46"

                    if (selected)
                        return "#596273"

                    if (workspaceMouse.containsMouse)
                        return "#343a45"

                    return "transparent"
                }

                border.width:
                    selected || urgent
                        ? 1
                        : 0

                border.color: {
                    if (urgent)
                        return "#d56a76"

                    if (selected)
                        return "#aeb8ca"

                    return "transparent"
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 120
                    }
                }

                Behavior on border.color {
                    ColorAnimation {
                        duration: 120
                    }
                }

                Text {
                    anchors.centerIn: parent

                    text: workspaceButton.modelData
                        ? workspaceButton.modelData.name
                        : ""

                    color: workspaceButton.selected
                        ? "#ffffff"
                        : "#c8cdd5"

                    font.pixelSize: 12

                    font.weight:
                        workspaceButton.selected
                            ? Font.Bold
                            : Font.DemiBold
                }

                MouseArea {
                    id: workspaceMouse

                    anchors.fill: parent

                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        Core.ServiceRegistry.hyprland
                            .activateWorkspace(
                                workspaceButton.modelData
                            )
                    }
                }
            }
        }
    }
}
