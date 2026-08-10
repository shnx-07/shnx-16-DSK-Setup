import QtQuick

import qs.core as Core
import qs.theme as ShellTheme

Item {
    id: root

    implicitWidth:
        contentRow.implicitWidth

    implicitHeight:
        32

    Row {
        id: contentRow

        anchors.fill:
            parent

        spacing:
            ShellTheme.Theme.spacing.small

        ArchButton {
            id: archButton

            onClicked: {
                Core.PanelController.toggleProfileHub(
                    archButton
                )
            }
        }

        WorkspaceIndicator {
        }

        ActiveWindowIndicator {
        }
    }
}
