pragma Singleton

import QtQuick

QtObject {
    id: root

    /*
     * Empty string means no expanded panel is active.
     * Keep the existing clockPanel property unchanged for compatibility.
     */
    readonly property string clockPanel: "clock"
    readonly property string searchPanel: "search"

    property string activePanel: ""
    property bool expanded: false

    /*
     * Search is one island module with two invocation modes.
     * Existing clock state remains untouched.
     */
    property string searchMode: "universal"

    readonly property bool clockActive:
        expanded && activePanel === clockPanel

    readonly property bool searchActive:
        expanded && activePanel === searchPanel

    readonly property bool universalSearchActive:
        searchActive && searchMode === "universal"

    readonly property bool commandSearchActive:
        searchActive && searchMode === "command"

    function openClock(): void {
        activePanel = clockPanel
        expanded = true
    }

    function openSearch(mode): void {
        searchMode = mode === "command"
            ? "command"
            : "universal"

        activePanel = searchPanel
        expanded = true
    }

    function openUniversalSearch(): void {
        openSearch("universal")
    }

    function openCommandSearch(): void {
        openSearch("command")
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

    function toggleSearch(): void {
        if (universalSearchActive)
            closeIsland()
        else
            openUniversalSearch()
    }

    function toggleCommandSearch(): void {
        if (commandSearchActive)
            closeIsland()
        else
            openCommandSearch()
    }
}

