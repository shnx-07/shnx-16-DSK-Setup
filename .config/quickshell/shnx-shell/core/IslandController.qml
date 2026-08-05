pragma Singleton

import QtQuick

QtObject {
    id: root

    /*
     * Empty string means no expanded panel is active.
     * For the current clock implementation, the only valid value is "clock".
     */
    readonly property string clockPanel: "clock"

    property string activePanel: ""
    property bool expanded: false

    readonly property bool clockActive:
        expanded && activePanel === clockPanel

    function openClock(): void {
        activePanel = clockPanel
        expanded = true
    }

    function closeIsland(): void {
        expanded = false
        activePanel = ""
    }

    function toggleClock(): void {
        if (clockActive)
            closeIsland()
        else
            openClock()
    }
}
