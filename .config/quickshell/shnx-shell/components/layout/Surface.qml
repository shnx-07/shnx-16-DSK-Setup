import QtQuick

import "../../theme" as ShellTheme
import "../visual" as Visual

Item {
    id: root

    default property alias content:
        contentItem.data

    property color backgroundColor:
        ShellTheme.Theme.colors.surfaceContainer

    property color borderColor:
        ShellTheme.Theme.colors.outlineVariant

    property real borderWidth: 1

    property real radius:
        ShellTheme.Theme.radius.panel

    property int shadowLevel:
        Visual.Shadow.Medium

    property bool clipContent: true

    implicitWidth:
        contentItem.implicitWidth

    implicitHeight:
        contentItem.implicitHeight

    Visual.Shadow {
        anchors.fill: surface

        level:
            root.shadowLevel

        radius:
            root.radius
    }

    Rectangle {
        id: surface

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
