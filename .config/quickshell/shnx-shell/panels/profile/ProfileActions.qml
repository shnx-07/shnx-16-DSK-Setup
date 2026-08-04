import QtQuick
import QtQuick.Layouts
import qs.core as Core

Rectangle {
    id: root

    implicitWidth: 448
    implicitHeight: 68

    radius: 18
    color: "#a91b2027"

    border.width: 1
    border.color: "#1e2934"

    readonly property var system:
        Core.ServiceRegistry.system

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12

        spacing: 10

        ActionButton {
            Layout.fillWidth: true

            iconText: "󰌾"
            labelText: "Lock"

            enabled:
                root.system.lockAvailable
                && !root.system.busy

            onClicked: {
                Core.PanelController.close()
                root.system.lock()
            }
        }

        ActionButton {
            Layout.fillWidth: true

            iconText: "󰍃"
            labelText: "Logout"

            enabled:
                root.system.logoutAvailable
                && !root.system.busy

            onClicked: {
                Core.PanelController.close()
                root.system.logout()
            }
        }
    }

    Connections {
        target: root.system

        function onActionFailed(action, message) {
            console.warn(
                "[ProfileActions]",
                action,
                message
            )
        }
    }

    component ActionButton: Rectangle {
        id: actionButton

        property string iconText: ""
        property string labelText: ""

        signal clicked()

        implicitHeight: 44

        radius: 14

        opacity:
            enabled
                ? 1.0
                : 0.42

        color:
            !enabled
                ? "#20262d"
                : actionMouseArea.pressed
                    ? "#38424f"
                    : actionMouseArea.containsMouse
                        ? "#303945"
                        : "#242b34"

        border.width: 1
        border.color:
            enabled
            && actionMouseArea.containsMouse
                ? "#4d5b6b"
                : "#303944"

        scale:
            enabled
            && actionMouseArea.pressed
                ? 0.97
                : 1.0

        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 90
            }
        }

        Row {
            anchors.centerIn: parent
            spacing: 8

            Text {
                text: actionButton.iconText
                color: "#e5eaf0"

                font.pixelSize: 16
                font.family: "JetBrainsMono Nerd Font"
            }

            Text {
                text: actionButton.labelText
                color: "#c7ced7"

                font.pixelSize: 11
                font.weight: Font.Medium
            }
        }

        MouseArea {
            id: actionMouseArea

            anchors.fill: parent

            enabled: actionButton.enabled
            hoverEnabled: true

            cursorShape:
                enabled
                    ? Qt.PointingHandCursor
                    : Qt.ArrowCursor

            onClicked: {
                actionButton.clicked()
            }
        }
    }
}
