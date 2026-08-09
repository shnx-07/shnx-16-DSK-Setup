import QtQuick

import qs.theme as ShellTheme

import "../../../components/controls" as Controls

Item {
    id: root

    required property var inputService

    readonly property var profiles: [
        "adaptive",
        "flat"
    ]

    readonly property int selectedIndex: {
        const index =
            root.profiles.indexOf(
                root.inputService
                    ? root.inputService.accelProfile
                    : "adaptive"
            )

        return index >= 0
            ? index
            : 0
    }

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
                anchors.verticalCenter:
                    parent.verticalCenter

                spacing: 2

                Text {
                    text:
                        "Acceleration"

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
                        "Pointer response profile"

                    color:
                        ShellTheme.Theme.colors.on_surface_variant

                    font.family:
                        ShellTheme.Theme.typography.fontFamily

                    font.pixelSize:
                        ShellTheme.Theme.typography.labelSmall

                    opacity: 0.68
                }
            }
        }

        Controls.SegmentedControl {
            width:
                parent.width

            enabled:
                root.inputService
                && root.inputService.ready

            options: [
                "Adaptive",
                "Flat"
            ]

            currentIndex:
                root.selectedIndex

            onSelected: index => {
                if (
                    index < 0
                    || index >= root.profiles.length
                ) {
                    return
                }

                root.inputService.setAccelProfile(
                    root.profiles[index]
                )
            }
        }
    }
}
