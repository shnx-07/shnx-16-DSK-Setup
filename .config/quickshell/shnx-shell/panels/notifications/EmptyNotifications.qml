import QtQuick
import qs.theme as ShellTheme

Item {
    id: root

    implicitHeight: 230

    Column {
        anchors.centerIn: parent
        spacing: 12

        Text {
            anchors.horizontalCenter:
                parent.horizontalCenter

            text: "󰂜"
            color: ShellTheme.Theme.colors.on_surface_variant

            font.pixelSize: ShellTheme.Theme.typography.displayLarge
        }

        Text {
            anchors.horizontalCenter:
                parent.horizontalCenter

            text: "No notifications"
            color: ShellTheme.Theme.colors.on_surface

            font.pixelSize: ShellTheme.Theme.typography.titleMedium
            font.weight: Font.DemiBold
        }

        Text {
            anchors.horizontalCenter:
                parent.horizontalCenter

            text: "New notifications will appear here"
            color: ShellTheme.Theme.colors.on_surface_variant

            font.pixelSize: ShellTheme.Theme.typography.labelMedium
        }
    }
}
