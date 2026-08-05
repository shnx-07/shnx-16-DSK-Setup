import QtQuick

Item {
    id: root

    required property QtObject clockService

    property int displayedMonth: clockService.currentMonth
    property int displayedYear: clockService.currentYear

    readonly property bool showingCurrentMonth:
        displayedMonth === clockService.currentMonth
        && displayedYear === clockService.currentYear

    readonly property string monthTitle: Qt.formatDate(
        new Date(displayedYear, displayedMonth, 1),
        "MMMM yyyy"
    )

    function showPreviousMonth() {
        if (displayedMonth === 0) {
            displayedMonth = 11
            displayedYear -= 1
        } else {
            displayedMonth -= 1
        }
    }

    function showNextMonth() {
        if (displayedMonth === 11) {
            displayedMonth = 0
            displayedYear += 1
        } else {
            displayedMonth += 1
        }
    }

    function showCurrentMonth() {
        displayedMonth = clockService.currentMonth
        displayedYear = clockService.currentYear
    }

    Column {
        anchors.fill: parent
        spacing: 12

        Item {
            id: calendarHeader

            width: parent.width
            height: 30

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                text: root.monthTitle
                color: "#f2f3f5"
                font.pixelSize: 15
                font.weight: Font.Medium
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                Rectangle {
                    width: 26
                    height: 26
                    radius: 8

                    color: previousHover.hovered
                        ? "#292b31"
                        : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "‹"
                        color: "#d7d8dc"
                        font.pixelSize: 20
                    }

                    HoverHandler {
                        id: previousHover
                    }

                    TapHandler {
                        acceptedButtons: Qt.LeftButton
                        onTapped: root.showPreviousMonth()
                    }
                }

                Rectangle {
                    width: 44
                    height: 26
                    radius: 8

                    visible: !root.showingCurrentMonth
                    enabled: visible

                    color: todayHover.hovered
                        ? "#292b31"
                        : "#222329"

                    Text {
                        anchors.centerIn: parent
                        text: "Today"
                        color: "#c8c9ce"
                        font.pixelSize: 10
                        font.weight: Font.Medium
                    }

                    HoverHandler {
                        id: todayHover
                    }

                    TapHandler {
                        acceptedButtons: Qt.LeftButton
                        onTapped: root.showCurrentMonth()
                    }
                }

                Rectangle {
                    width: 26
                    height: 26
                    radius: 8

                    color: nextHover.hovered
                        ? "#292b31"
                        : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "›"
                        color: "#d7d8dc"
                        font.pixelSize: 20
                    }

                    HoverHandler {
                        id: nextHover
                    }

                    TapHandler {
                        acceptedButtons: Qt.LeftButton
                        onTapped: root.showNextMonth()
                    }
                }
            }
        }

        MonthCalendarView {
            width: parent.width
            height: Math.max(
                0,
                parent.height - calendarHeader.height - parent.spacing
            )

            displayedMonth: root.displayedMonth
            displayedYear: root.displayedYear

            currentDay: root.clockService.currentDay
            currentMonth: root.clockService.currentMonth
            currentYear: root.clockService.currentYear
        }
    }
}
