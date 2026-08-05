import QtQuick
import "../../../core" as Core
import "../../../panels/clock" as ClockPanel

Item {
    id: root

    /*
     * This component adapts the reusable clock panel to the
     * Dynamic Island.
     *
     * Island-specific padding and service connections belong here.
     */

    property int horizontalPadding: 24
    property int verticalPadding: 22

    ClockPanel.ClockCalendarPanel {
        id: clockCalendarPanel

        anchors.fill: parent
        anchors.leftMargin: root.horizontalPadding
        anchors.rightMargin: root.horizontalPadding
        anchors.topMargin: root.verticalPadding
        anchors.bottomMargin: root.verticalPadding

        clockService: Core.ServiceRegistry.clock
    }
}
