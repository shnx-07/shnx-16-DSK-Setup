import QtQuick
import QtQuick.Layouts

import qs.theme as ShellTheme

Item {
    id: root

    property bool expanded: false
    property alias contentItem: contentRow

    implicitWidth: contentRow.implicitWidth
        + (ShellTheme.Theme.spacing.medium * 2)

    implicitHeight: 68

    opacity: expanded ? 1.0 : 0.0
    scale: expanded ? 1.0 : 0.92
    y: expanded ? 0 : 12

    transformOrigin: Item.Bottom

    Behavior on opacity {
        NumberAnimation {
            duration: 160
            easing.type: Easing.OutCubic
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutBack
        }
    }

    Behavior on y {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
        }
    }

    Rectangle {
        id: softShadow

        anchors {
            fill: dockBackground
            margins: -5
        }

        z: -2
        radius: dockBackground.radius + 5

        color: ShellTheme.Theme.shadows.color
        opacity: 0.16
    }

    Rectangle {
        id: dockBackground

        anchors.fill: parent

        radius: ShellTheme.Theme.radius.xLarge

        color: ShellTheme.Theme.colors.surfaceContainer

        border.width: 1
        border.color: Qt.rgba(
            ShellTheme.Theme.colors.outlineVariant.r,
            ShellTheme.Theme.colors.outlineVariant.g,
            ShellTheme.Theme.colors.outlineVariant.b,
            0.45
        )
    }

    Rectangle {
        anchors {
            left: dockBackground.left
            right: dockBackground.right
            top: dockBackground.top
            margins: 1
        }

        height: 1
        radius: 1

        color: ShellTheme.Theme.colors.on_surface
        opacity: 0.08
    }

    RowLayout {
        id: contentRow

        anchors.centerIn: parent

        spacing: ShellTheme.Theme.spacing.xSmall
    }
}
