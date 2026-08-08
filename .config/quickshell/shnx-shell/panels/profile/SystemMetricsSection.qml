import QtQuick
import QtQuick.Layouts
import Quickshell.Io

import qs.theme as ShellTheme

import "../../components/visual" as Visual
import "../../motion" as Motion

Item {
    id: root

    implicitWidth:
        metricsRow.implicitWidth

    implicitHeight: 104

    property real cpuUsage: 0
    property real ramUsage: 0
    property real diskUsage: 0

    property real previousCpuTotal: 0
    property real previousCpuIdle: 0

    /*
     * ------------------------------------------------------------
     * METRIC STRIP
     * ------------------------------------------------------------
     */

    RowLayout {
        id: metricsRow

        anchors.fill:
            parent

        spacing:
            ShellTheme.Theme.spacing.small

        MetricItem {
            Layout.fillWidth: true
            Layout.fillHeight: true

            title:
                "CPU"

            glyph:
                ""

            value:
                root.cpuUsage
        }

        MetricItem {
            Layout.fillWidth: true
            Layout.fillHeight: true

            title:
                "RAM"

            glyph:
                ""

            value:
                root.ramUsage
        }

        MetricItem {
            Layout.fillWidth: true
            Layout.fillHeight: true

            title:
                "Disk"

            glyph:
                "󰋊"

            value:
                root.diskUsage
        }
    }

    /*
     * ------------------------------------------------------------
     * EXISTING METRICS COLLECTION
     * ------------------------------------------------------------
     *
     * Keep this logic unchanged for now.
     * Backend ownership can be moved into a service later,
     * after the visual Profile redesign is stable.
     */

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            if (!metricsProcess.running)
                metricsProcess.running = true
        }
    }

    Process {
        id: metricsProcess

        command: [
            "sh",
            "-c",
            `
            read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat

            total=$((user + nice + system + idle + iowait + irq + softirq + steal))
            idle_all=$((idle + iowait))

            awk '
                /^MemTotal:/ { total=$2 }
                /^MemAvailable:/ { available=$2 }
                END {
                    if (total > 0)
                        printf "%.2f", ((total - available) / total) * 100
                    else
                        printf "0"
                }
            ' /proc/meminfo > /tmp/shnx_ram_usage

            disk_usage="$(
                df -P / \
                    | awk 'NR==2 { gsub("%", "", $5); print $5 }'
            )"

            printf 'cpuTotal=%s\\n' "$total"
            printf 'cpuIdle=%s\\n' "$idle_all"
            printf 'ramUsage=%s\\n' "$(cat /tmp/shnx_ram_usage)"
            printf 'diskUsage=%s\\n' "$disk_usage"
            `
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                root.parseMetrics(text)
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                const message =
                    text.trim()

                if (message.length > 0) {
                    console.warn(
                        "[SystemMetricsSection]",
                        message
                    )
                }
            }
        }
    }

    /*
     * ------------------------------------------------------------
     * METRICS PARSER
     * ------------------------------------------------------------
     */

    function parseMetrics(output) {
        let cpuTotal = 0
        let cpuIdle = 0
        let ram = 0
        let disk = 0

        const lines =
            output.split("\n")

        for (
            let index = 0;
            index < lines.length;
            index++
        ) {
            const line =
                lines[index]

            const separatorIndex =
                line.indexOf("=")

            if (separatorIndex < 0)
                continue

            const key =
                line.substring(
                    0,
                    separatorIndex
                )

            const value =
                Number(
                    line
                        .substring(
                            separatorIndex + 1
                        )
                        .trim()
                )

            switch (key) {
            case "cpuTotal":
                cpuTotal = value
                break

            case "cpuIdle":
                cpuIdle = value
                break

            case "ramUsage":
                ram = value
                break

            case "diskUsage":
                disk = value
                break
            }
        }

        if (root.previousCpuTotal > 0) {
            const totalDelta =
                cpuTotal
                - root.previousCpuTotal

            const idleDelta =
                cpuIdle
                - root.previousCpuIdle

            if (totalDelta > 0) {
                root.cpuUsage =
                    Math.max(
                        0,
                        Math.min(
                            100,
                            (
                                1
                                - idleDelta
                                    / totalDelta
                            ) * 100
                        )
                    )
            }
        }

        root.previousCpuTotal =
            cpuTotal

        root.previousCpuIdle =
            cpuIdle

        root.ramUsage =
            Math.max(
                0,
                Math.min(
                    100,
                    ram
                )
            )

        root.diskUsage =
            Math.max(
                0,
                Math.min(
                    100,
                    disk
                )
            )
    }

    /*
     * ------------------------------------------------------------
     * METRIC ITEM
     * ------------------------------------------------------------
     */

    component MetricItem: Item {
        id: metricRoot

        property string title: ""
        property string glyph: ""
        property real value: 0

        readonly property real progress:
            Math.max(
                0,
                Math.min(
                    1,
                    metricRoot.value / 100
                )
            )

        implicitWidth: 92
        implicitHeight: 104

        Column {
            anchors.centerIn:
                parent

            spacing:
                ShellTheme.Theme.spacing.xSmall

            /*
             * Circular progress indicator
             */
            Item {
                anchors.horizontalCenter:
                    parent.horizontalCenter

                width: 58
                height: 58

                Canvas {
                    id: metricCanvas

                    anchors.fill:
                        parent

                    property real animatedProgress:
                        metricRoot.progress

                    onAnimatedProgressChanged:
                        requestPaint()

                    onWidthChanged:
                        requestPaint()

                    onHeightChanged:
                        requestPaint()

                    Component.onCompleted:
                        requestPaint()

                    Behavior on animatedProgress {
                        NumberAnimation {
                            duration:
                                Motion.MotionTokens.standard

                            easing.type:
                                Motion.Easing.standard
                        }
                    }

                    onPaint: {
                        const ctx =
                            getContext("2d")

                        ctx.reset()

                        const centerX =
                            width / 2

                        const centerY =
                            height / 2

                        const radius =
                            Math.min(
                                width,
                                height
                            ) / 2 - 5

                        /*
                         * Background ring
                         */
                        ctx.lineWidth = 5
                        ctx.lineCap = "round"

                        ctx.beginPath()

                        ctx.strokeStyle =
                            ShellTheme.Theme.colors
                                .surfaceContainerHighest
                                .toString()

                        ctx.arc(
                            centerX,
                            centerY,
                            radius,
                            0,
                            Math.PI * 2
                        )

                        ctx.stroke()

                        /*
                         * Active ring
                         */
                        ctx.beginPath()

                        ctx.strokeStyle =
                            ShellTheme.Theme.colors
                                .primary
                                .toString()

                        ctx.arc(
                            centerX,
                            centerY,
                            radius,
                            -Math.PI / 2,
                            -Math.PI / 2
                                + Math.PI
                                * 2
                                * animatedProgress
                        )

                        ctx.stroke()
                    }
                }

                Visual.Icon {
                    anchors.centerIn:
                        parent

                    glyph:
                        metricRoot.glyph

                    iconSize:
                        ShellTheme.Theme.typography.titleSmall

                    color:
                        ShellTheme.Theme.colors.on_surface
                }
            }

            /*
             * Percentage
             */
            Text {
                anchors.horizontalCenter:
                    parent.horizontalCenter

                text:
                    Math.round(
                        metricRoot.value
                    ) + "%"

                color:
                    ShellTheme.Theme.colors.on_surface

                font.family:
                    ShellTheme.Theme.typography.fontFamily

                font.pixelSize:
                    ShellTheme.Theme.typography.labelMedium

                font.weight:
                    Font.DemiBold
            }

            /*
             * Label
             */
            Text {
                anchors.horizontalCenter:
                    parent.horizontalCenter

                text:
                    metricRoot.title

                color:
                    ShellTheme.Theme.colors.on_surface_variant

                font.family:
                    ShellTheme.Theme.typography.fontFamily

                font.pixelSize:
                    ShellTheme.Theme.typography.labelSmall

                font.weight:
                    Font.Medium
            }
        }
    }
}
