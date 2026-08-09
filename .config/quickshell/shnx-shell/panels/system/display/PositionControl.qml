import QtQuick

import qs.theme as ShellTheme

import "../../../components/buttons" as Buttons

Item {
    id: root

    required property var monitor

    signal positionSelected(
        int x,
        int y
    )

    implicitHeight:
        contentColumn.implicitHeight


    Column {
        id: contentColumn

        width:
            parent.width

        spacing:
            ShellTheme.Theme.spacing.small


        Row {
            width:
                parent.width

            height: 32


            Column {
                width:
                    Math.max(
                        0,
                        parent.width
                        - coordinates.width
                        - ShellTheme.Theme.spacing.medium
                    )

                anchors.verticalCenter:
                    parent.verticalCenter

                spacing: 2


                Text {
                    text:
                        "Position"

                    color:
                        ShellTheme.Theme.colors.on_surface

                    font.family:
                        ShellTheme.Theme.typography.fontFamily

                    font.pixelSize:
                        ShellTheme.Theme.typography.bodySmall

                    font.weight:
                        ShellTheme.Theme.typography.weightMedium
                }


                Text {
                    text:
                        "Monitor placement"

                    color:
                        ShellTheme.Theme.colors.on_surface_variant

                    font.family:
                        ShellTheme.Theme.typography.fontFamily

                    font.pixelSize:
                        ShellTheme.Theme.typography.labelSmall

                    opacity: 0.68
                }
            }


            Rectangle {
                id: coordinates

                width: coordinateText.implicitWidth + 20
                height: 28

                anchors.verticalCenter:
                    parent.verticalCenter

                radius:
                    ShellTheme.Theme.radius.button

                color:
                    ShellTheme.Theme.colors.surfaceContainerHigh


                Text {
                    id: coordinateText

                    anchors.centerIn:
                        parent

                    text:
                        root.monitor
                            ? Number(root.monitor.x)
                                + ", "
                                + Number(root.monitor.y)
                            : "—"

                    color:
                        ShellTheme.Theme.colors.on_surface_variant

                    font.family:
                        ShellTheme.Theme.typography.fontFamily

                    font.pixelSize:
                        ShellTheme.Theme.typography.labelSmall
                }
            }
        }


        Row {
            width:
                parent.width

            spacing:
                ShellTheme.Theme.spacing.small


            Buttons.PillButton {
                width:
                    (
                        parent.width
                        - parent.spacing * 2
                    ) / 3

                variant:
                    Buttons.PillButton.Secondary

                text:
                    "←  Left"

                enabled:
                    root.monitor
                    && root.monitor.enabled

                onClicked: {
                    root.positionSelected(
                        -root.monitor.width,
                        0
                    )
                }
            }


            Buttons.PillButton {
                width:
                    (
                        parent.width
                        - parent.spacing * 2
                    ) / 3

                variant:
                    Buttons.PillButton.Secondary

                text:
                    "Center"

                enabled:
                    root.monitor
                    && root.monitor.enabled

                onClicked: {
                    root.positionSelected(
                        0,
                        0
                    )
                }
            }


            Buttons.PillButton {
                width:
                    (
                        parent.width
                        - parent.spacing * 2
                    ) / 3

                variant:
                    Buttons.PillButton.Secondary

                text:
                    "Right  →"

                enabled:
                    root.monitor
                    && root.monitor.enabled

                onClicked: {
                    root.positionSelected(
                        root.monitor.width,
                        0
                    )
                }
            }
        }
    }
}
