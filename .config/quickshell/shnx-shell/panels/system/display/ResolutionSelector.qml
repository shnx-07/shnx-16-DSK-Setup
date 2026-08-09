import QtQuick

import qs.theme as ShellTheme

import "../../../components/controls" as Controls

Item {
    id: root

    required property var monitor

    signal resolutionSelected(
        string resolution
    )

    readonly property var resolutions: {
        const modes =
            root.monitor
            && root.monitor.availableModes
                ? root.monitor.availableModes
                : []

        const result = []

        for (
            let index = 0;
            index < modes.length;
            ++index
        ) {
            const resolution =
                modes[index].resolution

            if (
                resolution
                && result.indexOf(resolution) === -1
            ) {
                result.push(resolution)
            }
        }

        return result
    }

    readonly property int selectedIndex: {
        if (!root.monitor)
            return 0

        const index =
            root.resolutions.indexOf(
                root.monitor.resolution
            )

        return index >= 0
            ? index
            : 0
    }

    implicitHeight: 48


    Row {
        anchors.fill: parent

        spacing:
            ShellTheme.Theme.spacing.large


        Column {
            width:
                Math.max(
                    150,
                    parent.width * 0.40
                )

            anchors.verticalCenter:
                parent.verticalCenter

            spacing: 2


            Text {
                text:
                    "Resolution"

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
                    "Display dimensions"

                color:
                    ShellTheme.Theme.colors.on_surface_variant

                font.family:
                    ShellTheme.Theme.typography.fontFamily

                font.pixelSize:
                    ShellTheme.Theme.typography.labelSmall

                opacity: 0.68
            }
        }


        Controls.SelectField {
            width:
                Math.max(
                    190,
                    parent.width
                    - parent.children[0].width
                    - parent.spacing
                )

            anchors.verticalCenter:
                parent.verticalCenter

            options:
                root.resolutions

            currentIndex:
                root.selectedIndex

            enabled:
                root.monitor
                && root.monitor.enabled

            onSelected: (
                index,
                value
            ) => {
                root.resolutionSelected(
                    String(value)
                )
            }
        }
    }
}
