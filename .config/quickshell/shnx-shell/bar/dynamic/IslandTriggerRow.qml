import QtQuick
import "../../core" as Core
import "triggers" as Triggers

Item {
    id: root

    anchors.fill: parent

    Triggers.ClockTrigger {
        anchors.fill: parent

        onTriggered:
            Core.IslandController.toggleClock()
    }
}
