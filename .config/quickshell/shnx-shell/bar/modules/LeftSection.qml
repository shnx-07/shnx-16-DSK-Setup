import QtQuick
import qs.core as Core

Item {
    id: root

    implicitWidth: contentRow.implicitWidth
    implicitHeight: 32

    Row {
        id: contentRow

        anchors.fill: parent
        spacing: 8

        ArchButton {
            id: archButton

            onClicked: {
                Core.PanelController.toggleProfileHub(
                    archButton
                )
            }
        }

        WorkspaceIndicator {}

        ActiveWindowIndicator {}
    }
}
