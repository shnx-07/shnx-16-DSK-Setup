import QtQuick

import qs.theme as ShellTheme

import "../../../components/controls" as Controls

Item {
    id: root

    required property var inputService

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

            height: 30

            Column {
                width:
                    Math.max(
                        0,
                        parent.width
                        - valueBadge.width
                        - ShellTheme.Theme.spacing.medium
                    )

                anchors.verticalCenter:
                    parent.verticalCenter

                spacing: 2

                Text {
                    text:
                        "Pointer sensitivity"

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
                        "Pointer movement speed"

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
                id: valueBadge

                width: 58
                height: 28

                anchors.verticalCenter:
                    parent.verticalCenter

                radius:
                    ShellTheme.Theme.radius.button

                color:
                    ShellTheme.Theme.colors.surfaceContainerHigh

                Text {
                    anchors.centerIn:
                        parent

                    text:
                        Number(
                            sensitivitySlider.value
                        ).toFixed(2)

                    color:
                        ShellTheme.Theme.colors.on_surface_variant

                    font.family:
                        ShellTheme.Theme.typography.fontFamily

                    font.pixelSize:
                        ShellTheme.Theme.typography.labelSmall

                    font.weight:
                        ShellTheme.Theme.typography.weightMedium
                }
            }
        }

        Controls.Slider {
            id: sensitivitySlider

            width:
                parent.width

            from: -1.0
            to: 1.0
            stepSize: 0.05

            enabled:
                root.inputService
                && root.inputService.ready

            value:
                root.inputService
                    ? root.inputService.sensitivity
                    : 0.0

            onValueCommitted: value => {
                root.inputService.setSensitivity(
                    value
                )
            }
        }

        Item {
            width:
                parent.width

            height: 14

            Text {
                anchors.left:
                    parent.left

                text:
                    "Slower"

                color:
                    ShellTheme.Theme.colors.on_surface_variant

                font.family:
                    ShellTheme.Theme.typography.fontFamily

                font.pixelSize:
                    ShellTheme.Theme.typography.labelSmall

                opacity: 0.55
            }

            Text {
                anchors.right:
                    parent.right

                text:
                    "Faster"

                color:
                    ShellTheme.Theme.colors.on_surface_variant

                font.family:
                    ShellTheme.Theme.typography.fontFamily

                font.pixelSize:
                    ShellTheme.Theme.typography.labelSmall

                opacity: 0.55
            }
        }
    }
}
