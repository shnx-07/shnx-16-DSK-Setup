import QtQuick
import QtQuick.Layouts

import qs.core as Core
import qs.theme as ShellTheme

import "../../components/buttons" as Buttons

Item {
    id: root

    implicitWidth: 448
    implicitHeight: 44

    readonly property var system:
        Core.ServiceRegistry.system

    RowLayout {
        anchors.fill:
            parent

        spacing:
            ShellTheme.Theme.spacing.small

        /*
         * LOCK
         */
        Buttons.PillButton {
            Layout.fillWidth: true
            Layout.fillHeight: true

            text:
                "Lock"

            glyph:
                "󰌾"

            variant:
                Buttons.PillButton.Secondary

            enabled:
                root.system
                && root.system.lockAvailable
                && !root.system.busy

            onClicked: {
                Core.PanelController.close()

                root.system.lock()
            }
        }

        /*
         * LOGOUT
         */
        Buttons.PillButton {
            Layout.fillWidth: true
            Layout.fillHeight: true

            text:
                "Logout"

            glyph:
                "󰍃"

            variant:
                Buttons.PillButton.Secondary

            enabled:
                root.system
                && root.system.logoutAvailable
                && !root.system.busy

            onClicked: {
                Core.PanelController.close()

                root.system.logout()
            }
        }
    }

    Connections {
        target:
            root.system

        function onActionFailed(action, message) {
            console.warn(
                "[ProfileActions]",
                action,
                message
            )
        }
    }
}
