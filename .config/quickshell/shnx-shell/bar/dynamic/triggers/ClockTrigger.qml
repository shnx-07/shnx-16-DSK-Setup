import QtQuick
import "../../../core" as Core
import "../../../theme" as ShellTheme

Item {
    id: root

    signal triggered()

    implicitWidth: 150
    implicitHeight: 34

    Text {
        id: clockText

        anchors.centerIn: parent

        text: Core.ServiceRegistry.clock.compactTime

        color: ShellTheme.Theme.colors.on_surface
        font.pixelSize: ShellTheme.Theme.typography.bodyMedium
        font.weight: Font.Medium
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton

        onTapped:
            root.triggered()
    }
}
