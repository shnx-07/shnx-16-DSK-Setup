import QtQuick
import qs.theme as ShellTheme

Rectangle {
    id: root

    property string iconText: ""
    property string title: ""
    property string subtitle: ""

    property bool active: false
    property bool available: true
    property bool showDetailButton: false

    signal toggled()
    signal detailRequested()

    implicitWidth: 200
    implicitHeight: 74

    radius: ShellTheme.Theme.radius.card

    color: {
        if (!available)
            return ShellTheme.Theme.colors.surfaceContainerLowest

        if (mouseArea.pressed)
            return active
                ? ShellTheme.Theme.colors.primaryContainer
                : ShellTheme.Theme.colors.surfaceContainerHigh

        if (mouseArea.containsMouse)
            return active
                ? ShellTheme.Theme.colors.primaryContainer
                : ShellTheme.Theme.colors.surfaceContainer

        return active
            ? ShellTheme.Theme.colors.primaryContainer
            : ShellTheme.Theme.colors.surfaceContainerLow
    }

    border.width: 1

    border.color: {
        if (!available)
            return ShellTheme.Theme.colors.outlineVariant

        if (active)
            return ShellTheme.Theme.colors.primary

        return mouseArea.containsMouse
            ? ShellTheme.Theme.colors.outline
            : ShellTheme.Theme.colors.outlineVariant
    }

    opacity:
        available
            ? 1.0
            : 0.48

    Behavior on color {
        ColorAnimation {
            duration: 130
        }
    }

    Behavior on border.color {
        ColorAnimation {
            duration: 130
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: 90
        }
    }

    scale:
        mouseArea.pressed
            ? 0.98
            : 1.0

    Row {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 10

        spacing: 11

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter

            width: 42
            height: 42
            radius: width / 2

            color:
                root.active
                    ? ShellTheme.Theme.colors.on_primary_container
                    : ShellTheme.Theme.colors.surfaceContainerHighest

            Text {
                anchors.centerIn: parent

                text: root.iconText

                color:
                    root.active
                        ? ShellTheme.Theme.colors.primaryContainer
                        : ShellTheme.Theme.colors.on_surface

                font.pixelSize: 19
                font.family: "JetBrainsMono Nerd Font"
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter

            width:
                parent.width
                - 42
                - detailButton.width
                - parent.spacing * 2
                - 24

            spacing: 4

            Text {
                width: parent.width

                text: root.title
                color: ShellTheme.Theme.colors.on_surface

                font.pixelSize: ShellTheme.Theme.typography.bodySmall
                font.weight: Font.DemiBold

                elide: Text.ElideRight
            }

            Text {
                width: parent.width

                text: root.subtitle
                color: ShellTheme.Theme.colors.on_surface_variant

                font.pixelSize: ShellTheme.Theme.typography.labelSmall

                elide: Text.ElideRight
            }
        }

        Item {
          id: detailButton
            
            z:2

            anchors.verticalCenter: parent.verticalCenter

            width:
                root.showDetailButton
                    ? 26
                    : 0

            height: 32
            visible: root.showDetailButton

            Text {
                anchors.centerIn: parent

                text: "›"
                color: ShellTheme.Theme.colors.on_surface_variant

                font.pixelSize: 19
                font.weight: Font.Medium
            }

            MouseArea {
              anchors.fill: parent

                z: 2

                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: function(mouse) {
                    mouse.accepted = true
                    root.detailRequested()
                }
            }
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent

        z:0

        enabled: root.available
        hoverEnabled: true

        cursorShape:
            enabled
                ? Qt.PointingHandCursor
                : Qt.ArrowCursor

        onClicked: {
            root.toggled()
        }
    }
}
