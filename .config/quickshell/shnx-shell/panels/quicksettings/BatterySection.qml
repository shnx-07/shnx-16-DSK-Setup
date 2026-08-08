import QtQuick
import QtQuick.Layouts
import qs.core as Core
import qs.theme as ShellTheme

Rectangle {
    id: root

    signal closeRequested()

    readonly property var battery:
        Core.ServiceRegistry.battery

    color: ShellTheme.Theme.colors.background
    radius: ShellTheme.Theme.radius.panel

    border.width: 1
    border.color: ShellTheme.Theme.colors.outlineVariant

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
                    color: ShellTheme.Theme.colors.on_surface

                    font.pixelSize: ShellTheme.Theme.typography.headlineSmall
                    font.weight: Font.DemiBold
                }

                Text {
                    text: battery.stateName
                    color: ShellTheme.Theme.colors.on_surface_variant
                    font.pixelSize: ShellTheme.Theme.typography.labelMedium
                }
            }

            Rectangle {
                anchors {
                    top: parent.top
                    right: parent.right
                }

                width: 32
                height: 32

                radius: ShellTheme.Theme.radius.button

                color: closeMouse.pressed
                    ? ShellTheme.Theme.colors.pressedOverlay
                    : closeMouse.containsMouse
                        ? ShellTheme.Theme.colors.hoverOverlay
                        : ShellTheme.Theme.colors.surfaceContainer

                Text {
                    anchors.centerIn: parent

                    text: "󰅖"
                    color: ShellTheme.Theme.colors.on_surface
                    font.pixelSize: ShellTheme.Theme.typography.titleSmall
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

            radius: ShellTheme.Theme.radius.large
            color: ShellTheme.Theme.colors.surfaceContainer

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
                            return ShellTheme.Theme.colors.error

                        if (battery.low)
                            return ShellTheme.Theme.colors.warning

                        if (battery.charging)
                            return ShellTheme.Theme.colors.success

                        return ShellTheme.Theme.colors.on_surface
                    }

                    font.pixelSize: 38
                }

                ColumnLayout {
                    spacing: 1

                    Text {
                        text: battery.available
                            ? battery.percentage + "%"
                            : "--"

                        color: ShellTheme.Theme.colors.on_surface

                        font.pixelSize: ShellTheme.Theme.typography.displaySmall
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

                        color: ShellTheme.Theme.colors.on_surface_variant
                        font.pixelSize: ShellTheme.Theme.typography.labelMedium
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

                        color: ShellTheme.Theme.colors.on_surface

                        font.pixelSize: ShellTheme.Theme.typography.titleSmall
                        font.weight: Font.DemiBold
                    }

                    Text {
                        Layout.alignment: Qt.AlignRight

                        text: battery.charging
                            ? "Charge rate"
                            : "Power usage"

                        color: ShellTheme.Theme.colors.on_surface_variant
                        font.pixelSize: ShellTheme.Theme.typography.labelSmall
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
                    color: ShellTheme.Theme.colors.on_surface

                    font.pixelSize: ShellTheme.Theme.typography.bodyMedium
                    font.weight: Font.DemiBold
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: battery.usageSamples.length < 2
                        ? "Collecting history"
                        : battery.usageSamples.length + " min"

                    color: ShellTheme.Theme.colors.on_surface_variant
                    font.pixelSize: ShellTheme.Theme.typography.labelSmall
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 175

                radius: ShellTheme.Theme.radius.card
                color: ShellTheme.Theme.colors.surfaceContainerLow

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
                        context.strokeStyle = ShellTheme.Theme.colors.outlineVariant.toString()
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
                                    Qt.rgba(
                                        ShellTheme.Theme.colors.success.r,
                                        ShellTheme.Theme.colors.success.g,
                                        ShellTheme.Theme.colors.success.b,
                                        0.34
                                    ).toString()
                                )

                                fillGradient.addColorStop(
                                    1,
                                    Qt.rgba(
                                        ShellTheme.Theme.colors.success.r,
                                        ShellTheme.Theme.colors.success.g,
                                        ShellTheme.Theme.colors.success.b,
                                        0.02
                                    ).toString()
                                )
                            } else {
                                fillGradient.addColorStop(
                                    0,
                                    Qt.rgba(
                                        ShellTheme.Theme.colors.primary.r,
                                        ShellTheme.Theme.colors.primary.g,
                                        ShellTheme.Theme.colors.primary.b,
                                        0.34
                                    ).toString()
                                )

                                fillGradient.addColorStop(
                                    1,
                                    Qt.rgba(
                                        ShellTheme.Theme.colors.primary.r,
                                        ShellTheme.Theme.colors.primary.g,
                                        ShellTheme.Theme.colors.primary.b,
                                        0.02
                                    ).toString()
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
                            ? ShellTheme.Theme.colors.success.toString()
                            : ShellTheme.Theme.colors.primary.toString()

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
                            ? ShellTheme.Theme.colors.success.toString()
                            : ShellTheme.Theme.colors.primary.toString()

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
                    color: ShellTheme.Theme.colors.on_surface_variant
                    font.pixelSize: ShellTheme.Theme.typography.labelSmall
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

                    color: ShellTheme.Theme.colors.on_surface_variant
                    font.pixelSize: ShellTheme.Theme.typography.labelSmall
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

                    color: ShellTheme.Theme.colors.on_surface_variant
                    font.pixelSize: ShellTheme.Theme.typography.labelSmall
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

                radius: ShellTheme.Theme.radius.medium
                color: ShellTheme.Theme.colors.surfaceContainer

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

                        color: ShellTheme.Theme.colors.on_surface

                        font.pixelSize: ShellTheme.Theme.typography.titleSmall
                        font.weight: Font.DemiBold
                    }

                    Text {
                        text: "Battery health"
                        color: ShellTheme.Theme.colors.on_surface_variant
                        font.pixelSize: ShellTheme.Theme.typography.labelSmall
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 68

                radius: ShellTheme.Theme.radius.medium
                color: ShellTheme.Theme.colors.surfaceContainer

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

                        color: ShellTheme.Theme.colors.on_surface

                        font.pixelSize: ShellTheme.Theme.typography.titleSmall
                        font.weight: Font.DemiBold
                    }

                    Text {
                        text: "Current capacity"
                        color: ShellTheme.Theme.colors.on_surface_variant
                        font.pixelSize: ShellTheme.Theme.typography.labelSmall
                    }
                }
            }
        }

        // Save Battery control
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 58

            radius: ShellTheme.Theme.radius.card

            color: saveBatteryMouse.pressed
                ? battery.powerSaverEnabled
                    ? ShellTheme.Theme.colors.successContainer
                    : ShellTheme.Theme.colors.pressedOverlay
                : saveBatteryMouse.containsMouse
                    ? battery.powerSaverEnabled
                        ? ShellTheme.Theme.colors.successContainer
                        : ShellTheme.Theme.colors.hoverOverlay
                    : battery.powerSaverEnabled
                        ? ShellTheme.Theme.colors.successContainer
                        : ShellTheme.Theme.colors.surfaceContainerLow

            border.width: 1

            border.color: battery.powerSaverEnabled
                ? ShellTheme.Theme.colors.success
                : saveBatteryMouse.containsMouse
                    ? ShellTheme.Theme.colors.outline
                    : ShellTheme.Theme.colors.outlineVariant

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
                        ? ShellTheme.Theme.colors.on_success_container
                        : ShellTheme.Theme.colors.on_surface

                    font.pixelSize: ShellTheme.Theme.typography.headlineSmall
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    Text {
                        text: "Save Battery"
                        color: ShellTheme.Theme.colors.on_surface

                        font.pixelSize: ShellTheme.Theme.typography.bodySmall
                        font.weight: Font.DemiBold
                    }

                    Text {
                        text: battery.powerSaverEnabled
                            ? "Power Saver is active"
                            : "Reduce system power consumption"

                        color: ShellTheme.Theme.colors.on_surface_variant
                        font.pixelSize: ShellTheme.Theme.typography.labelSmall
                    }
                }

                Rectangle {
                    implicitWidth: 42
                    implicitHeight: 24

                    radius: height / 2

                    color: battery.powerSaverEnabled
                        ? ShellTheme.Theme.colors.success
                        : ShellTheme.Theme.colors.surfaceContainerHighest

                    Rectangle {
                        width: 18
                        height: 18

                        radius: width / 2
                        color: ShellTheme.Theme.colors.on_surface

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
