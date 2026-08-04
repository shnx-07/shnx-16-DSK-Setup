import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Item {
    id: root

    implicitWidth: metricsRow.implicitWidth
    implicitHeight: 108

    property real cpuUsage: 0
    property real ramUsage: 0
    property real diskUsage: 0

    property real previousCpuTotal: 0
    property real previousCpuIdle: 0

    RowLayout {
        id: metricsRow

        anchors.fill: parent
        spacing: 8

        CircularMetric {
            Layout.fillWidth: true

            title: "CPU"
            iconText: ""
            value: root.cpuUsage
        }

        CircularMetric {
            Layout.fillWidth: true

            title: "RAM"
            iconText: ""
            value: root.ramUsage
        }

        CircularMetric {
            Layout.fillWidth: true

            title: "Disk"
            iconText: "󰋊"
            value: root.diskUsage
        }
    }

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
                const message = text.trim()

                if (message.length > 0) {
                    console.warn(
                        "[SystemMetricsSection]",
                        message
                    )
                }
            }
        }
    }

    function parseMetrics(output) {
        let cpuTotal = 0
        let cpuIdle = 0
        let ram = 0
        let disk = 0

        const lines = output.split("\n")

        for (let index = 0; index < lines.length; index++) {
            const line = lines[index]
            const separatorIndex = line.indexOf("=")

            if (separatorIndex < 0)
                continue

            const key =
                line.substring(0, separatorIndex)

            const value =
                Number(
                    line.substring(separatorIndex + 1).trim()
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

        if (previousCpuTotal > 0) {
            const totalDelta =
                cpuTotal - previousCpuTotal

            const idleDelta =
                cpuIdle - previousCpuIdle

            if (totalDelta > 0) {
                cpuUsage =
                    Math.max(
                        0,
                        Math.min(
                            100,
                            (
                                1
                                - idleDelta / totalDelta
                            ) * 100
                        )
                    )
            }
        }

        previousCpuTotal = cpuTotal
        previousCpuIdle = cpuIdle

        ramUsage =
            Math.max(
                0,
                Math.min(100, ram)
            )

        diskUsage =
            Math.max(
                0,
                Math.min(100, disk)
            )
    }

    component CircularMetric: Item {
        id: metricRoot

        property string title: ""
        property string iconText: ""
        property real value: 0

        implicitWidth: 76
        implicitHeight: 108

        Column {
            anchors.centerIn: parent
            spacing: 5

            Item {
                anchors.horizontalCenter: parent.horizontalCenter

                width: 62
                height: 62

                Canvas {
                    id: metricCanvas

                    anchors.fill: parent

                    property real progress:
                        Math.max(
                            0,
                            Math.min(
                                1,
                                metricRoot.value / 100
                            )
                        )

                    onProgressChanged: requestPaint()

                    Component.onCompleted: requestPaint()

                    onPaint: {
                        const ctx = getContext("2d")

                        ctx.reset()

                        const centerX = width / 2
                        const centerY = height / 2
                        const radius =
                            Math.min(width, height) / 2 - 5

                        ctx.lineWidth = 5
                        ctx.lineCap = "round"

                        ctx.beginPath()
                        ctx.strokeStyle = "#29333e"
                        ctx.arc(
                            centerX,
                            centerY,
                            radius,
                            0,
                            Math.PI * 2
                        )
                        ctx.stroke()

                        ctx.beginPath()
                        ctx.strokeStyle = "#e1e8f0"
                        ctx.arc(
                            centerX,
                            centerY,
                            radius,
                            -Math.PI / 2,
                            -Math.PI / 2
                                + Math.PI
                                * 2
                                * progress
                        )
                        ctx.stroke()
                    }
                }

                Text {
                    anchors.centerIn: parent

                    text: metricRoot.iconText
                    color: "#eef2f6"

                    font.pixelSize: 18
                    font.family:
                        "JetBrainsMono Nerd Font"
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter

                text:
                    Math.round(metricRoot.value) + "%"

                color: "#eef2f6"

                font.pixelSize: 12
                font.weight: Font.DemiBold
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter

                text: metricRoot.title
                color: "#7f8b9b"

                font.pixelSize: 9
                font.weight: Font.Medium
            }
        }
    }
}
