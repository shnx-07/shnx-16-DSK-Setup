import QtQuick

import "../../theme" as ShellTheme

Rectangle {
    id: root

    enum Orientation {
        Horizontal,
        Vertical
    }

    property int orientation:
        Divider.Horizontal

    property color dividerColor:
        ShellTheme.Theme.colors.outlineVariant

    property real thickness: 1

    color:
        dividerColor

    implicitWidth:
        orientation === Divider.Horizontal
            ? 1
            : thickness

    implicitHeight:
        orientation === Divider.Horizontal
            ? thickness
            : 1
}
