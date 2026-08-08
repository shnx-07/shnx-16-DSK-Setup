import QtQuick
import QtQuick.Layouts
import qs.core as Core
import qs.theme as ShellTheme

Rectangle {
    id: root

    implicitWidth: 448
    implicitHeight: 68

    radius: ShellTheme.Theme.radius.large
    color: ShellTheme.Theme.colors.surfaceContainerLow

    border.width: 1
    border.color: ShellTheme.Theme.colors.outlineVariant

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

        radius: ShellTheme.Theme.radius.control

        opacity:
            enabled
                ? 1.0
                : 0.42

        color:
            !enabled
                ? ShellTheme.Theme.colors.surfaceContainerLowest
                : actionMouseArea.pressed
                    ? ShellTheme.Theme.colors.pressedOverlay
                    : actionMouseArea.containsMouse
                        ? ShellTheme.Theme.colors.hoverOverlay
                        : ShellTheme.Theme.colors.surfaceContainer

        border.width: 1
        border.color:
            enabled
            && actionMouseArea.containsMouse
                ? ShellTheme.Theme.colors.outline
                : ShellTheme.Theme.colors.outlineVariant

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
                color: ShellTheme.Theme.colors.on_surface

                font.pixelSize: ShellTheme.Theme.typography.titleSmall
                font.family: "JetBrainsMono Nerd Font"
            }

            Text {
                text: actionButton.labelText
                color: ShellTheme.Theme.colors.on_surface_variant

                font.pixelSize: ShellTheme.Theme.typography.labelMedium
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
