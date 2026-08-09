import QtQuick

import qs.theme as ShellTheme

import "../../../components/cards" as Cards
import "../../../components/buttons" as Buttons
import "../../../components/visual" as Visual

Cards.BaseCard {
    id: root

    required property var monitor

    property bool selected: false

    signal selectedRequested(string name)

    signal toggleRequested(
        string name,
        bool enabled
    )

    implicitHeight: 72

    backgroundColor:
        root.selected
            ? ShellTheme.Theme.colors.surfaceContainerHigh
            : ShellTheme.Theme.colors.surfaceContainerLow

    borderWidth:
        root.selected ? 1 : 0

    borderColor:
        root.selected
            ? ShellTheme.Theme.colors.primary
            : "transparent"


    MouseArea {
        anchors.fill:
            parent

        hoverEnabled: true

        cursorShape:
            Qt.PointingHandCursor

        onClicked:
            root.selectedRequested(
                root.monitor.name
            )
    }


    Row {
        anchors {
            fill: parent

            margins:
                ShellTheme.Theme.spacing.medium
        }

        spacing:
            ShellTheme.Theme.spacing.medium


        Rectangle {
            width: 42
            height: 42

            anchors.verticalCenter:
                parent.verticalCenter

            radius:
                ShellTheme.Theme.radius.button

            color:
                root.selected
                    ? ShellTheme.Theme.colors.selectedOverlay
                    : ShellTheme.Theme.colors.surfaceContainerHigh


            Visual.Icon {
                anchors.centerIn:
                    parent

                glyph:
                    "󰍹"

                iconSize: 19

                color:
                    root.monitor.enabled
                        ? ShellTheme.Theme.colors.primary
                        : ShellTheme.Theme.colors.on_surface_variant
            }
        }


        Column {
            width:
                Math.max(
                    0,
                    parent.width
                    - 42
                    - toggle.width
                    - parent.spacing * 2
                )

            anchors.verticalCenter:
                parent.verticalCenter

            spacing: 3


            Text {
                width:
                    parent.width

                text:
                    root.monitor.description
                    && root.monitor.description.length > 0
                        ? root.monitor.description
                        : root.monitor.name

                color:
                    ShellTheme.Theme.colors.on_surface

                font.family:
                    ShellTheme.Theme.typography.fontFamily

                font.pixelSize:
                    ShellTheme.Theme.typography.bodySmall

                font.weight:
                    ShellTheme.Theme.typography.weightSemiBold

                elide:
                    Text.ElideRight
            }


            Text {
                width:
                    parent.width

                text:
                    root.monitor.name
                    + (
                        root.monitor.enabled
                            ? "  ·  "
                                + root.monitor.resolution
                                + "  ·  "
                                + Number(
                                    root.monitor.refreshRate
                                ).toFixed(0)
                                + " Hz"
                            : "  ·  Disabled"
                    )

                color:
                    ShellTheme.Theme.colors.on_surface_variant

                font.family:
                    ShellTheme.Theme.typography.fontFamily

                font.pixelSize:
                    ShellTheme.Theme.typography.labelSmall

                opacity: 0.72

                elide:
                    Text.ElideRight
            }
        }


        Buttons.ToggleButton {
            id: toggle

            anchors.verticalCenter:
                parent.verticalCenter

            text:
                root.monitor.enabled
                    ? "On"
                    : "Off"

            checked:
                root.monitor.enabled

            onToggled: checked => {
                root.toggleRequested(
                    root.monitor.name,
                    checked
                )
            }
        }
    }
}
