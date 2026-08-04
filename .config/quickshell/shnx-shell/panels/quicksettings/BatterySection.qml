import QtQuick
import QtQuick.Layouts
import qs.core as Core

Rectangle {
    id: root

    signal closeRequested()

    readonly property var battery:
        Core.ServiceRegistry.battery

    color: "#171a20"
    radius: 20

    border.width: 1
    border.color: "#343944"

    function formatGraphTime(timestamp) {
        const date = new Date(timestamp)

        return Qt.formatTime(date, "hh:mm")
    }


    ColumnLayout {
        anchors {
            fill: parent
            margins: 20
        }

        spacing: 15

        // Header
        Item {
            Layout.fillWidth: true
            implicitHeight: 48

            Column {
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }

                spacing: 2

                Text {
                    text: "Battery"
                    color: "#f4f5f7"

                    font.pixelSize: 21
                    font.weight: Font.DemiBold
                }

                Text {
                    text: battery.stateName
                    color: "#9299a5"
                    font.pixelSize: 12
                }
            }

            Rectangle {
                anchors {
                    top: parent.top
                    right: parent.right
                }

                width: 32
                height: 32

                radius: 10

                color: closeMouse.pressed
                    ? "#3a404b"
                    : closeMouse.containsMouse
                        ? "#30353f"
                        : "#252932"

                Text {
                    anchors.centerIn: parent

                    text: "󰅖"
                    color: "#f4f5f7"
                    font.pixelSize: 15
                }

                MouseArea {
                    id: closeMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: root.closeRequested()
                }
            }
        }
        // Main status card
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 94

            radius: 17
            color: "#22262e"

            RowLayout {
                anchors {
                    fill: parent
                    margins: 17
                }

                spacing: 16

                Text {
                    text: battery.icon

                    color: {
                        if (battery.critical)
                            return "#ff757f"

                        if (battery.low)
                            return "#efb66d"

                        if (battery.charging)
                            return "#72dc91"

                        return "#f4f5f7"
                    }

                    font.pixelSize: 38
                }

                ColumnLayout {
                    spacing: 1

                    Text {
                        text: battery.available
                            ? battery.percentage + "%"
                            : "--"

                        color: "#ffffff"

                        font.pixelSize: 30
                        font.weight: Font.Bold
                    }

                    Text {
                        text: {
                            if (!battery.available)
                                return "Battery unavailable"

                            if (battery.remainingTime.length > 0) {
                                return battery.remainingTime
                                    + (battery.charging
                                        ? " until full"
                                        : " remaining")
                            }

                            return battery.stateName
                        }

                        color: "#a4aab5"
                        font.pixelSize: 12
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                ColumnLayout {
                    spacing: 2

                    Text {
                        Layout.alignment: Qt.AlignRight

                        text: battery.formatWatts(
                            battery.powerUsage
                        )

                        color: "#f4f5f7"

                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                    }

                    Text {
                        Layout.alignment: Qt.AlignRight

                        text: battery.charging
                            ? "Charge rate"
                            : "Power usage"

                        color: "#858c98"
                        font.pixelSize: 11
                    }
                }
            }
        }

        // Usage graph
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Battery level"
                    color: "#f4f5f7"

                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: battery.usageSamples.length < 2
                        ? "Collecting history"
                        : battery.usageSamples.length + " min"

                    color: "#858c98"
                    font.pixelSize: 11
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 175

                radius: 16
                color: "#20242b"

                clip: true

                Canvas {
                    id: graphCanvas

                    anchors {
                        fill: parent
                        margins: 14
                    }

                    antialiasing: true

                    onWidthChanged: requestPaint()
                    onHeightChanged: requestPaint()

                    onPaint: {
                        const context = getContext("2d")
                        const samples = battery.usageSamples

                        const graphWidth = width
                        const graphHeight = height

                        context.clearRect(
                            0,
                            0,
                            graphWidth,
                            graphHeight
                        )

                        // Horizontal grid lines.
                        context.strokeStyle = "#343a45"
                        context.lineWidth = 1

                        for (let row = 0; row <= 4; row++) {
                            const y = row * graphHeight / 4

                            context.beginPath()
                            context.moveTo(0, y)
                            context.lineTo(graphWidth, y)
                            context.stroke()
                        }

                        if (samples.length === 0)
                            return

                        function pointX(index) {
                            if (samples.length === 1)
                                return graphWidth / 2

                            return index
                                * graphWidth
                                / (samples.length - 1)
                        }

                        function pointY(percentage) {
                            const clamped = Math.max(
                                0,
                                Math.min(100, percentage)
                            )

                            return graphHeight
                                - clamped * graphHeight / 100
                        }

                        // Area fill.
                        if (samples.length > 1) {
                            const fillGradient =
                                context.createLinearGradient(
                                    0,
                                    0,
                                    0,
                                    graphHeight
                                )

                            if (battery.charging) {
                                fillGradient.addColorStop(
                                    0,
                                    "rgba(103, 217, 139, 0.34)"
                                )

                                fillGradient.addColorStop(
                                    1,
                                    "rgba(103, 217, 139, 0.02)"
                                )
                            } else {
                                fillGradient.addColorStop(
                                    0,
                                    "rgba(124, 168, 255, 0.34)"
                                )

                                fillGradient.addColorStop(
                                    1,
                                    "rgba(124, 168, 255, 0.02)"
                                )
                            }

                            context.beginPath()

                            context.moveTo(
                                pointX(0),
                                graphHeight
                            )

                            for (let index = 0;
                                    index < samples.length;
                                    index++) {
                                context.lineTo(
                                    pointX(index),
                                    pointY(
                                        samples[index].percentage
                                    )
                                )
                            }

                            context.lineTo(
                                pointX(samples.length - 1),
                                graphHeight
                            )

                            context.closePath()
                            context.fillStyle = fillGradient
                            context.fill()
                        }

                        // Main battery-level line.
                        context.beginPath()

                        context.lineWidth = 3
                        context.lineJoin = "round"
                        context.lineCap = "round"

                        context.strokeStyle = battery.charging
                            ? "#67d98b"
                            : "#7ca8ff"

                        for (let index = 0;
                                index < samples.length;
                                index++) {
                            const x = pointX(index)
                            const y = pointY(
                                samples[index].percentage
                            )

                            if (index === 0)
                                context.moveTo(x, y)
                            else
                                context.lineTo(x, y)
                        }

                        if (samples.length > 1)
                            context.stroke()

                        // Current point.
                        const lastIndex = samples.length - 1
                        const lastX = pointX(lastIndex)
                        const lastY = pointY(
                            samples[lastIndex].percentage
                        )

                        context.beginPath()
                        context.arc(
                            lastX,
                            lastY,
                            4,
                            0,
                            Math.PI * 2
                        )

                        context.fillStyle = battery.charging
                            ? "#78e397"
                            : "#8ab2ff"

                        context.fill()
                    }

                    Connections {
                        target: battery

                        function onUsageSamplesChanged() {
                            graphCanvas.requestPaint()
                        }
                    }

                    Connections {
                        target: battery

                        function onChargingChanged() {
                            graphCanvas.requestPaint()
                        }
                    }
                }

                Text {
                    visible: battery.usageSamples.length < 2

                    anchors.centerIn: parent

                    text: "History will appear as samples are collected"
                    color: "#777e8a"
                    font.pixelSize: 11
                }

                Text {
                    anchors {
                        left: parent.left
                        bottom: parent.bottom
                        leftMargin: 14
                        bottomMargin: 5
                    }

                    visible: battery.usageSamples.length > 0

                    text: {
                        const samples = battery.usageSamples

                        if (!samples
                                || samples.length === 0
                                || !samples[0]) {
                            return ""
                        }

                        return root.formatGraphTime(
                            samples[0].timestamp
                        )
                    }

                    color: "#727986"
                    font.pixelSize: 9
                }

                Text {
                    anchors {
                        right: parent.right
                        bottom: parent.bottom
                        rightMargin: 14
                        bottomMargin: 5
                    }

                    visible: battery.usageSamples.length > 0

                    text: {
                        const samples = battery.usageSamples

                        if (!samples
                                || samples.length === 0) {
                            return ""
                        }

                        const lastSample =
                            samples[samples.length - 1]

                        if (!lastSample)
                            return ""

                        return root.formatGraphTime(
                            lastSample.timestamp
                        )
                    }

                    color: "#727986"
                    font.pixelSize: 9
                } 
            }
        }

        // Detail cards
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 68

                radius: 15
                color: "#22262e"

                Column {
                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                        leftMargin: 15
                    }

                    spacing: 3

                    Text {
                        text: battery.healthAvailable
                            ? Math.round(
                                battery.healthPercentage
                            ) + "%"
                            : "—"

                        color: "#f4f5f7"

                        font.pixelSize: 17
                        font.weight: Font.DemiBold
                    }

                    Text {
                        text: "Battery health"
                        color: "#858c98"
                        font.pixelSize: 11
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 68

                radius: 15
                color: "#22262e"

                Column {
                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                        leftMargin: 15
                    }

                    spacing: 3

                    Text {
                        text: battery.energyCapacity > 0
                            ? battery.energyCapacity.toFixed(1)
                                + " Wh"
                            : "—"

                        color: "#f4f5f7"

                        font.pixelSize: 17
                        font.weight: Font.DemiBold
                    }

                    Text {
                        text: "Current capacity"
                        color: "#858c98"
                        font.pixelSize: 11
                    }
                }
            }
        }

        // Save Battery control
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 58

            radius: 16

            color: saveBatteryMouse.pressed
                ? battery.powerSaverEnabled
                    ? "#315d40"
                    : "#383e48"
                : saveBatteryMouse.containsMouse
                    ? battery.powerSaverEnabled
                        ? "#356746"
                        : "#303640"
                    : battery.powerSaverEnabled
                        ? "#2f593d"
                        : "#292e36"

            border.width: 1

            border.color: battery.powerSaverEnabled
                ? "#66d487"
                : saveBatteryMouse.containsMouse
                    ? "#596273"
                    : "#424955"

            RowLayout {
                anchors {
                    fill: parent
                    leftMargin: 16
                    rightMargin: 16
                }

                spacing: 12

                Text {
                    text: "󰌪"

                    color: battery.powerSaverEnabled
                        ? "#72dd91"
                        : "#e9ebef"

                    font.pixelSize: 20
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    Text {
                        text: "Save Battery"
                        color: "#f5f6f8"

                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                    }

                    Text {
                        text: battery.powerSaverEnabled
                            ? "Power Saver is active"
                            : "Reduce system power consumption"

                        color: "#9ba1ac"
                        font.pixelSize: 10
                    }
                }

                Rectangle {
                    implicitWidth: 42
                    implicitHeight: 24

                    radius: height / 2

                    color: battery.powerSaverEnabled
                        ? "#65d486"
                        : "#555c68"

                    Rectangle {
                        width: 18
                        height: 18

                        radius: width / 2
                        color: "#ffffff"

                        anchors.verticalCenter: parent.verticalCenter

                        x: battery.powerSaverEnabled
                            ? parent.width - width - 3
                            : 3

                        Behavior on x {
                            NumberAnimation {
                                duration: 150
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }
            }

            MouseArea {
                id: saveBatteryMouse

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked:
                    battery.togglePowerSaver()
            }
        }
    }
}

