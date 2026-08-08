import QtQuick

import "../../theme" as ShellTheme
import "../visual" as Visual

Item {
    id: root

    default property alias content:
        contentItem.data

    property color backgroundColor:
        ShellTheme.Theme.colors.surfaceContainerHigh

    property color borderColor:
        ShellTheme.Theme.colors.outlineVariant

    property real borderWidth: 1

    property real radius:
        ShellTheme.Theme.radius.card

    property int shadowLevel:
        Visual.Shadow.Low

    property bool clipContent: true

    implicitWidth:
        contentItem.implicitWidth

    implicitHeight:
        contentItem.implicitHeight

    Visual.Shadow {
        anchors.fill: card

        level:
            root.shadowLevel

        radius:
            root.radius
    }

    Rectangle {
        id: card

        anchors.fill: parent

        radius:
            root.radius

        color:
            root.backgroundColor

        border.width:
            root.borderWidth

        border.color:
            root.borderColor

        clip:
            root.clipContent

        Item {
            id: contentItem

            anchors.fill: parent
        }
    }
}
