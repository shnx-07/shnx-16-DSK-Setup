import QtQuick

import Quickshell
import Quickshell.Widgets

import qs.theme as ShellTheme

Item {
    id: root

    property string route: ""
    property string label: ""
    property string iconName: ""

    property bool selected: false
    property bool active: false

    signal hovered()
    signal activated()
    implicitWidth: 58
    implicitHeight: 58

    readonly property bool containsMouse: mouseArea.containsMouse
    readonly property bool highlighted: selected || containsMouse

    scale: mouseArea.pressed
        ? 0.92
        : highlighted
            ? 1.08
            : 1.0

    y: highlighted ? -3 : 0

    Behavior on scale {
        NumberAnimation {
            duration: 140
            easing.type: Easing.OutCubic
        }
    }

    Behavior on y {
        NumberAnimation {
            duration: 140
            easing.type: Easing.OutCubic
        }
    }

    Rectangle {
        anchors.centerIn: parent

        width: 48
        height: 48
        radius: ShellTheme.Theme.radius.large

        color: {
            if (root.selected)
                return ShellTheme.Theme.colors.primaryContainer

            if (root.containsMouse)
                return ShellTheme.Theme.colors.surfaceContainerHigh

            return "transparent"
        }

        opacity: root.highlighted ? 1.0 : 0.0

        border.width: root.active ? 1 : 0
        border.color: ShellTheme.Theme.colors.primary

        Behavior on color {
            ColorAnimation {
                duration: 140
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 120
            }
        }
    }

    IconImage {
        anchors.centerIn: parent

        width: 27
        height: 27

        source: Quickshell.iconPath(root.iconName, true)

        asynchronous: true
        smooth: true

        opacity: root.enabled ? 1.0 : 0.38
    }

    Rectangle {
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 1
        }

        width: 4
        height: 4
        radius: ShellTheme.Theme.radius.circle

        color: ShellTheme.Theme.colors.primary
        visible: root.active
    }

    Rectangle {
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.top
            bottomMargin: 10
        }

        width: tooltipText.implicitWidth + 18
        height: 30
        radius: ShellTheme.Theme.radius.small

        color: ShellTheme.Theme.colors.surfaceContainerHighest

        border.width: 1
        border.color: ShellTheme.Theme.colors.outlineVariant

        visible: root.containsMouse
        opacity: root.containsMouse ? 1.0 : 0.0
        scale: root.containsMouse ? 1.0 : 0.94

        Behavior on opacity {
            NumberAnimation {
                duration: 120
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutCubic
            }
        }

        Text {
            id: tooltipText

            anchors.centerIn: parent

            text: root.label

            color: ShellTheme.Theme.colors.on_surface

            font.family: ShellTheme.Theme.typography.fontFamily
            font.pixelSize: ShellTheme.Theme.typography.labelSmall
            font.weight: Font.Medium
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent

        enabled: root.enabled
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onEntered: root.hovered()
        onClicked: {
            Qt.callLater(function() {
                root.activated()
            })
        }
    }
}
