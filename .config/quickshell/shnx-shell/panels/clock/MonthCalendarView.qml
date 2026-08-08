import QtQuick
import qs.theme as ShellTheme

Item {
    id: root

    required property int displayedMonth
    required property int displayedYear

    required property int currentDay
    required property int currentMonth
    required property int currentYear

    readonly property int firstWeekday:
        new Date(displayedYear, displayedMonth, 1).getDay()

    readonly property int daysInMonth:
        new Date(displayedYear, displayedMonth + 1, 0).getDate()

    readonly property var weekdayLabels: [
        "Sun",
        "Mon",
        "Tue",
        "Wed",
        "Thu",
        "Fri",
        "Sat"
    ]

    readonly property int totalCells: 42

    Column {
        anchors.fill: parent
        spacing: 8

        Grid {
            id: weekdayHeader

            width: parent.width
            columns: 7
            columnSpacing: 0
            rowSpacing: 0

            Repeater {
                model: root.weekdayLabels

                delegate: Item {
                    required property var modelData

                    width: weekdayHeader.width / 7
                    height: 22

                    Text {
                        anchors.centerIn: parent

                        text: modelData

                        color: ShellTheme.Theme.colors.on_surface_variant
                        font.pixelSize: ShellTheme.Theme.typography.labelSmall
                        font.weight: Font.Medium
                    }
                }
            }
        }

        Grid {
            id: monthGrid

            width: parent.width
            height: parent.height
                    - weekdayHeader.height
                    - parent.spacing

            columns: 7
            rows: 6

            columnSpacing: 0
            rowSpacing: 0

            Repeater {
                model: root.totalCells

                delegate: Item {
                    id: dayCell

                    required property int index

                    readonly property int dayNumber:
                        index - root.firstWeekday + 1

                    readonly property bool validDay:
                        dayNumber >= 1
                        && dayNumber <= root.daysInMonth

                    readonly property bool isToday:
                        validDay
                        && root.displayedYear === root.currentYear
                        && root.displayedMonth === root.currentMonth
                        && dayNumber === root.currentDay

                    width: monthGrid.width / 7
                    height: monthGrid.height / 6

                    Rectangle {
                        anchors.centerIn: parent

                        width: 28
                        height: 28
                        radius: ShellTheme.Theme.radius.button

                        visible: dayCell.isToday

                        color: ShellTheme.Theme.colors.primary
                    }

                    Text {
                        anchors.centerIn: parent

                        visible: dayCell.validDay

                        text: dayCell.dayNumber

                        color: dayCell.isToday
                               ? ShellTheme.Theme.colors.on_primary
                               : ShellTheme.Theme.colors.on_surface_variant

                        font.pixelSize: ShellTheme.Theme.typography.labelMedium
                        font.weight: dayCell.isToday
                                     ? Font.Medium
                                     : Font.Normal

                        font.features: {
                            "tnum": 1
                        }
                    }
                }
            }
        }
    }
}
