import QtQuick

import qs.theme as Theme

Text {
    id: root

    property string shortcutText: ""

    text: shortcutText
    visible: shortcutText.length > 0

    color: Theme.Theme.colors.on_surface_variant
    font.family: Theme.Theme.typography.fontFamily
    font.pixelSize: Theme.Theme.typography.labelSmall
    font.weight: Font.Medium

    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    opacity: 0.72
}
