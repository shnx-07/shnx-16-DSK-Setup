import QtQuick
import qs.theme as ShellTheme

Item {
    id: root

    property string query: ""
    property string mode: "universal"

    Column {
        anchors.centerIn: parent
        spacing: ShellTheme.Theme.spacing.small

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.mode === "command" ? "󰆍" : "󰍉"
            color: ShellTheme.Theme.colors.on_surface_variant
            font.pixelSize: 24
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter

            text:
                root.query.length > 0
                    ? "No results"
                    : root.mode === "command"
                        ? "Start typing a command"
                        : "Start typing to search"

            color: ShellTheme.Theme.colors.on_surface_variant
            font.pixelSize: ShellTheme.Theme.typography.bodySmall
        }
    }
}

