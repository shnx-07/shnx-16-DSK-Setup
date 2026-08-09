import QtQuick

import qs.theme as ShellTheme

import "../../../components/controls" as Controls

Item {
    id: root

    required property var monitor

    signal refreshRateSelected(
        real refreshRate
    )

    readonly property var refreshRates: {
        const modes =
            root.monitor
            && root.monitor.availableModes
                ? root.monitor.availableModes
                : []

        const resolution =
            root.monitor
                ? root.monitor.resolution
                : ""

        const result = []

        for (
            let index = 0;
            index < modes.length;
            ++index
        ) {
            const mode =
                modes[index]

            if (
                mode.resolution
                !== resolution
            ) {
                continue
            }

            const hz =
                Number(mode.hz)

            if (
                Number.isFinite(hz)
                && result.indexOf(hz) === -1
            ) {
                result.push(hz)
            }
        }

        result.sort(
            (a, b) => a - b
        )

        return result
    }


    readonly property var labels:
        root.refreshRates.map(
            hz =>
                Number(hz).toFixed(
                    Number(hz) % 1 === 0
                        ? 0
                        : 2
                )
                + " Hz"
        )


    readonly property int selectedIndex: {
        const current =
            Number(
                root.monitor
                    ? root.monitor.refreshRate
                    : 0
            )

        let result = 0
        let difference = Infinity

        for (
            let index = 0;
            index < root.refreshRates.length;
            ++index
        ) {
            const currentDifference =
                Math.abs(
                    root.refreshRates[index]
                    - current
                )

            if (
                currentDifference
                < difference
            ) {
                difference =
                    currentDifference

                result =
                    index
            }
        }

        return result
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
                    "Refresh rate"

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
                    "Screen frequency"

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
                root.labels

            currentIndex:
                root.selectedIndex

            enabled:
                root.monitor
                && root.monitor.enabled

            onSelected: (
                index,
                value
            ) => {
                if (
                    index >= 0
                    && index
                        < root.refreshRates.length
                ) {
                    root.refreshRateSelected(
                        root.refreshRates[index]
                    )
                }
            }
        }
    }
}
