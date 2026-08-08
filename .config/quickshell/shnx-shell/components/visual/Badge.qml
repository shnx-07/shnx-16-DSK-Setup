import QtQuick

import "../../theme" as ShellTheme

Item {
    id: root

    property string text: ""

    property color backgroundColor:
        ShellTheme.Theme.colors.primary

    property color textColor:
        ShellTheme.Theme.colors.onPrimary

    property real minimumSize: 16

    property real horizontalPadding:
        ShellTheme.Theme.spacing.xSmall

    readonly property bool hasText:
        root.text.length > 0

    implicitWidth:
        Math.max(
            minimumSize,
            label.implicitWidth
                + horizontalPadding * 2
        )

    implicitHeight:
        minimumSize

    Rectangle {
        anchors.fill: parent

        radius:
            ShellTheme.Theme.radius.pill

        color:
            root.backgroundColor
    }

    Text {
        id: label

        anchors.centerIn: parent

        text:
            root.text

        color:
            root.textColor

        font.family:
            ShellTheme.Theme.typography.fontFamily

        font.pixelSize:
            ShellTheme.Theme.typography.labelSmall

        font.weight:
            Font.DemiBold
    }
}
