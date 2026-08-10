import QtQuick

QtObject {
    id: root

    /*
     * Single real-time date object used by every clock component.
     */
    property date currentDateTime: new Date()

    // Raw time values.
    readonly property int hours:
        currentDateTime.getHours()

    readonly property int minutes:
        currentDateTime.getMinutes()

    readonly property int seconds:
        currentDateTime.getSeconds()

    /*
     * Explicit 12-hour conversion.
     * This avoids locale-dependent Qt time formatting.
     */
    readonly property int hour12:
        hours % 12 === 0 ? 12 : hours % 12

    // Current calendar date values.
    readonly property int currentDay:
        currentDateTime.getDate()

    readonly property int currentMonth:
        currentDateTime.getMonth()

    readonly property int currentYear:
        currentDateTime.getFullYear()

    // Shared formatted time values.
    readonly property string hourMinuteText:
        String(hour12).padStart(2, "0")
        + ":"
        + String(minutes).padStart(2, "0")

    readonly property string secondText:
        String(seconds).padStart(2, "0")

    readonly property string periodText:
        hours >= 12 ? "PM" : "AM"

    /*
     * Compact Dynamic Island time.
     * Both compact and expanded views now use the same values.
     */
    readonly property string compactTime:
        hourMinuteText + " " + periodText

    // Expanded date labels.
    readonly property string weekdayText:
        Qt.formatDate(currentDateTime, "dddd")

    readonly property string fullDateText:
        Qt.formatDate(currentDateTime, "d MMMM yyyy")

    function refresh(): void {
        currentDateTime = new Date()
    }

    property Timer updateTimer: Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered:
            root.refresh()
    }
}
