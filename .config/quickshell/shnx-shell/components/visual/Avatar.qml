import QtQuick

import "../../theme" as ShellTheme

Item {
    id: root

    property url source: ""
    property real avatarSize: 40

    property color fallbackColor:
        ShellTheme.Theme.colors.surfaceContainerHigh

    property color fallbackTextColor:
        ShellTheme.Theme.colors.on_surface

    property string fallbackText: ""

    implicitWidth:
        avatarSize

    implicitHeight:
        avatarSize

    Rectangle {
        anchors.fill: parent

        radius:
            ShellTheme.Theme.radius.circle

        color:
            root.fallbackColor

        clip:
            true

        Image {
            anchors.fill: parent

            visible:
                root.source.toString().length > 0

            source:
                root.source

            fillMode:
                Image.PreserveAspectCrop

            smooth:
                true

            mipmap:
                true
        }

        Text {
            anchors.centerIn: parent

            visible:
                root.source.toString().length === 0
                && root.fallbackText.length > 0

            text:
                root.fallbackText

            color:
                root.fallbackTextColor

            font.family:
                ShellTheme.Theme.typography.fontFamily

            font.pixelSize:
                root.avatarSize * 0.38

            font.weight:
                Font.DemiBold
        }
    }
}
