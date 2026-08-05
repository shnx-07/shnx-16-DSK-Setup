import QtQuick
import "../../../core" as Core

Item {
    id: root

    signal triggered()

    implicitWidth: 150
    implicitHeight: 34

    Text {
        id: clockText

        anchors.centerIn: parent

        text: Core.ServiceRegistry.clock.compactTime

        color: "#ffffff"
        font.pixelSize: 14
        font.weight: Font.Medium
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton

        onTapped:
            root.triggered()
    }
}
