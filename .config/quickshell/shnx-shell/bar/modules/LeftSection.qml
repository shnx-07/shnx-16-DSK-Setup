import QtQuick

Item {
    id: root

    implicitWidth: contentRow.implicitWidth
    implicitHeight: 32

    Row {
        id: contentRow

        anchors.fill: parent
        spacing: 8

        ArchButton {
            onClicked: {
                console.log("Arch button clicked")
            }
        }

        WorkspaceIndicator {}

        ActiveWindowIndicator {}
    }
}
