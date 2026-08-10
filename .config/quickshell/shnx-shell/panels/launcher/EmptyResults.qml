import QtQuick

import qs.theme as ShellTheme
import qs.components.visual as Visual

Column {
    id: root

    property string query:
        ""

    property string category:
        "All"

    spacing:
        ShellTheme.Theme.spacing.small

    Visual.Icon {
        anchors.horizontalCenter:
            parent.horizontalCenter

        glyph:
            "󰅖"

        iconSize:
            32

        color:
            ShellTheme.Theme.colors.on_surface_variant
    }

    Text {
        anchors.horizontalCenter:
            parent.horizontalCenter

        text:
            "No applications found"

        color:
            ShellTheme.Theme.colors.on_surface

        font.family:
            ShellTheme.Theme.typography.fontFamily

        font.pixelSize:
            ShellTheme.Theme.typography.bodySmall

        font.weight:
            Font.DemiBold
    }

    Text {
        anchors.horizontalCenter:
            parent.horizontalCenter

        text: {
            if (root.query.length > 0) {
                return "No results for “"
                    + root.query
                    + "”"
            }

            if (root.category !== "All") {
                return "No applications in "
                    + root.category
            }

            return "No installed applications are available"
        }

        color:
            ShellTheme.Theme.colors.on_surface_variant

        font.family:
            ShellTheme.Theme.typography.fontFamily

        font.pixelSize:
            ShellTheme.Theme.typography.labelSmall
    }
}
