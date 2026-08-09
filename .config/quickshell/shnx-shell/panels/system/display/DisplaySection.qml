import QtQuick

import qs.core as Core
import qs.theme as ShellTheme

import "../../../components/layout" as Layout

Item {
    id: root

    readonly property var displayService:
        Core.ServiceRegistry.display

    property string selectedMonitorName: ""

    readonly property var selectedMonitor: {
        if (!root.displayService)
            return null

        if (root.selectedMonitorName) {
            const found =
                root.displayService.monitor(
                    root.selectedMonitorName
                )

            if (found)
                return found
        }

        if (
            root.displayService.monitors
            && root.displayService.monitors.length > 0
        ) {
            return root.displayService.monitors[0]
        }

        return null
    }


    implicitHeight:
        contentColumn.implicitHeight


    function ensureSelection() {
        if (
            root.selectedMonitorName
            && root.displayService.monitor(
                root.selectedMonitorName
            )
        ) {
            return
        }

        if (
            root.displayService.monitors
            && root.displayService.monitors.length > 0
        ) {
            root.selectedMonitorName =
                root.displayService.monitors[0].name
        }
    }


    Column {
        id: contentColumn

        width:
            parent.width

        spacing:
            ShellTheme.Theme.spacing.large


        Column {
                width: parent.width
                spacing: 3

                Text {
                    text: "Display"

                    color:
                        ShellTheme.Theme.colors.on_surface

                    font.family:
                        ShellTheme.Theme.typography.fontFamily

                    font.pixelSize:
                        ShellTheme.Theme.typography.titleMedium

                    font.weight:
                        ShellTheme.Theme.typography.weightSemiBold
                }

                Text {
                    width: parent.width

                    text: {
                        const count =
                            root.displayService.monitorCount

                        return (
                            count === 1
                                ? "1 connected display"
                                : count + " connected displays"
                        )
                        + "  ·  Choose a monitor and adjust its configuration"
                    }

                    color:
                        ShellTheme.Theme.colors.on_surface_variant

                font.family:
                    ShellTheme.Theme.typography.fontFamily

                font.pixelSize:
                    ShellTheme.Theme.typography.bodySmall

                opacity: 0.72

                elide:
                    Text.ElideRight
            }
        }

        Column {
            width:
                parent.width

            spacing:
                ShellTheme.Theme.spacing.small


            Repeater {
                model:
                    root.displayService.monitors


                delegate: MonitorCard {
                    required property var modelData

                    width:
                        contentColumn.width

                    monitor:
                        modelData

                    selected:
                        root.selectedMonitor
                        && root.selectedMonitor.name
                            === modelData.name


                    onSelectedRequested: name => {
                        root.selectedMonitorName =
                            name
                    }


                    onToggleRequested: (
                        name,
                        enabled
                    ) => {
                        root.displayService.setEnabled(
                            name,
                            enabled
                        )
                    }
                }
            }
        }


        Layout.Divider {
            width:
                parent.width

            visible:
                root.selectedMonitor !== null
        }


        Column {
            width:
                parent.width

            visible:
                root.selectedMonitor !== null

            spacing:
                ShellTheme.Theme.spacing.medium


            Row {
                width:
                    parent.width

                height: 28


                Text {
                    width:
                        Math.max(
                            0,
                            parent.width
                            - activeMonitor.implicitWidth
                        )

                    anchors.verticalCenter:
                        parent.verticalCenter

                    text:
                        "Display settings"

                    color:
                        ShellTheme.Theme.colors.on_surface

                    font.family:
                        ShellTheme.Theme.typography.fontFamily

                    font.pixelSize:
                        ShellTheme.Theme.typography.titleSmall

                    font.weight:
                        ShellTheme.Theme.typography.weightSemiBold
                }


                Text {
                    id: activeMonitor

                    anchors.verticalCenter:
                        parent.verticalCenter

                    text:
                        root.selectedMonitor
                            ? root.selectedMonitor.name
                            : ""

                    color:
                        ShellTheme.Theme.colors.primary

                    font.family:
                        ShellTheme.Theme.typography.fontFamily

                    font.pixelSize:
                        ShellTheme.Theme.typography.labelSmall

                    font.weight:
                        ShellTheme.Theme.typography.weightMedium
                }
            }


            ResolutionSelector {
                width:
                    parent.width

                monitor:
                    root.selectedMonitor

                onResolutionSelected: resolution => {
                    root.displayService.setMode(
                        root.selectedMonitor.name,
                        resolution,
                        Number(
                            root.selectedMonitor.refreshRate
                        )
                    )
                }
            }


            RefreshRateSelector {
                width:
                    parent.width

                monitor:
                    root.selectedMonitor

                onRefreshRateSelected: refreshRate => {
                    root.displayService.setMode(
                        root.selectedMonitor.name,
                        root.selectedMonitor.resolution,
                        refreshRate
                    )
                }
            }


            Layout.Divider {
                width:
                    parent.width
            }


            ScaleSelector {
                width:
                    parent.width

                monitor:
                    root.selectedMonitor

                onScaleSelected: scale => {
                    root.displayService.setScale(
                        root.selectedMonitor.name,
                        scale
                    )
                }
            }


            PositionControl {
                width:
                    parent.width

                monitor:
                    root.selectedMonitor

                onPositionSelected: (
                    x,
                    y
                ) => {
                    root.displayService.setPosition(
                        root.selectedMonitor.name,
                        x,
                        y
                    )
                }
            }
        }
    }


    property Connections displayConnections: Connections {
        target:
            root.displayService

        function onChanged() {
            root.ensureSelection()
        }
    }


    Component.onCompleted: {
        root.ensureSelection()
    }
}
