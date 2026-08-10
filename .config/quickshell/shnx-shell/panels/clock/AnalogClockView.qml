import QtQuick
import qs.theme as ShellTheme

Item {
    id: root

    required property QtObject clockService

    /*
     * The analog view owns only clock presentation.
     * Time continues to come from ClockService.
     */

    readonly property real secondAngle:
        clockService.seconds * 6

    readonly property real minuteAngle:
        clockService.minutes * 6
        + clockService.seconds * 0.1

    readonly property real hourAngle:
        (clockService.hours % 12) * 30
        + clockService.minutes * 0.5

    Canvas {
        id: clockCanvas

        anchors.centerIn: parent

        width: Math.max(
            0,
            Math.min(parent.width, parent.height) - 34
        )

        height: width
        visible: width > 0 && height > 0

        antialiasing: true

        onPaint: {
            const ctx = getContext("2d")
            const centerX = width / 2
            const centerY = height / 2
            const radius = Math.max(
                0,
                Math.min(width, height) / 2
            )

            if (radius <= 2)
                return

            ctx.reset()
            ctx.clearRect(0, 0, width, height)

            // -----------------------------------------------------
            // Outer clock face
            // -----------------------------------------------------

            ctx.beginPath()
            ctx.arc(
                centerX,
                centerY,
                radius - 2,
                0,
                Math.PI * 2
            )

            ctx.fillStyle = ShellTheme.Theme.colors.surfaceContainerLowest.toString()
            ctx.fill()

            ctx.lineWidth = 1
            ctx.strokeStyle = ShellTheme.Theme.colors.outlineVariant.toString()
            ctx.stroke()

            // -----------------------------------------------------
            // Hour and minute marks
            // -----------------------------------------------------

            for (let index = 0; index < 60; index++) {
                const angle =
                    index * Math.PI / 30 - Math.PI / 2

                const isHourMark = index % 5 === 0

                const outerRadius = radius - 12
                const innerRadius = isHourMark
                    ? radius - 23
                    : radius - 17

                const startX =
                    centerX + Math.cos(angle) * innerRadius

                const startY =
                    centerY + Math.sin(angle) * innerRadius

                const endX =
                    centerX + Math.cos(angle) * outerRadius

                const endY =
                    centerY + Math.sin(angle) * outerRadius

                ctx.beginPath()
                ctx.moveTo(startX, startY)
                ctx.lineTo(endX, endY)

                ctx.lineWidth = isHourMark ? 2 : 1
                ctx.strokeStyle = isHourMark
                    ? ShellTheme.Theme.colors.on_surface.toString()
                    : ShellTheme.Theme.colors.outlineVariant.toString()

                ctx.lineCap = "round"
                ctx.stroke()
            }

            // -----------------------------------------------------
            // Clock hands
            // -----------------------------------------------------

            drawHand(
                ctx,
                centerX,
                centerY,
                root.hourAngle,
                radius * 0.48,
                5,
                ShellTheme.Theme.colors.on_surface.toString()
            )

            drawHand(
                ctx,
                centerX,
                centerY,
                root.minuteAngle,
                radius * 0.68,
                3,
                ShellTheme.Theme.colors.on_surface_variant.toString()
            )

            drawHand(
                ctx,
                centerX,
                centerY,
                root.secondAngle,
                radius * 0.75,
                1.5,
                ShellTheme.Theme.colors.on_surface_variant.toString()
            )

            // -----------------------------------------------------
            // Centre point
            // -----------------------------------------------------

            ctx.beginPath()
            ctx.arc(
                centerX,
                centerY,
                4,
                0,
                Math.PI * 2
            )

            ctx.fillStyle = ShellTheme.Theme.colors.on_surface.toString()
            ctx.fill()
        }

        function drawHand(
            ctx,
            centerX,
            centerY,
            angleDegrees,
            length,
            thickness,
            color
        ) {
            const angle =
                angleDegrees * Math.PI / 180 - Math.PI / 2

            const endX =
                centerX + Math.cos(angle) * length

            const endY =
                centerY + Math.sin(angle) * length

            ctx.beginPath()
            ctx.moveTo(centerX, centerY)
            ctx.lineTo(endX, endY)

            ctx.lineWidth = thickness
            ctx.strokeStyle = color
            ctx.lineCap = "round"
            ctx.stroke()
        }
    }

    Connections {
        target: root.clockService

        function onCurrentDateTimeChanged() {
            clockCanvas.requestPaint()
        }
    }

    Component.onCompleted:
        clockCanvas.requestPaint()
}
