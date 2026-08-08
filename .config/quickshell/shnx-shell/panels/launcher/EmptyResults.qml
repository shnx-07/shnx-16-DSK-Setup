import QtQuick
import qs.theme as ShellTheme

Column {
    id: root

    property string query: ""
    property string category: "All"

    spacing: 10

    Text {
        anchors.horizontalCenter: parent.horizontalCenter

        text: "󰅖"
        color: ShellTheme.Theme.colors.on_surface_variant

        font.pixelSize: ShellTheme.Theme.typography.displayMedium
        font.family: "JetBrainsMono Nerd Font"
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter

        text: "No applications found"
        color: ShellTheme.Theme.colors.on_surface

        font.pixelSize: ShellTheme.Theme.typography.bodySmall
        font.weight: Font.DemiBold
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter

        text: {
            if (root.query.length > 0)
                return "No results for “" + root.query + "”"

            if (root.category !== "All")
                return "No applications in " + root.category

            return "No installed applications are available"
        }

        color: ShellTheme.Theme.colors.on_surface_variant
        font.pixelSize: ShellTheme.Theme.typography.labelSmall
    }
}
