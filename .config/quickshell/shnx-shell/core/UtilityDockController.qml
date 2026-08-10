pragma Singleton

import QtQuick
import qs.core as Core

QtObject {
    id: root

    property bool open: false
    property int selectedIndex: 0
    property var targetScreen: null
    property bool activationLocked: false

    property var items: [
        {
            route: "wallpaper",
            label: "Wallpaper",
            glyph: "󰋩",
            shortcutKey: "wallpaper"
        },
        {
            route: "appearance",
            label: "Appearance",
            glyph: "󰏘",
            shortcutKey: "appearance"
        },
        {
            route: "appLauncher",
            label: "Apps",
            glyph: "󰀻",
            shortcutKey: "appLauncher"
        },
        {
            route: "clipboard",
            label: "Clipboard",
            glyph: "󰅇",
            shortcutKey: "clipboard"
        }
    ]

    readonly property int itemCount: items.length

    readonly property var selectedItem:
        itemCount > 0
            ? items[selectedIndex]
            : null

    readonly property string selectedRoute:
        selectedItem
            ? selectedItem.route
            : ""

    readonly property string selectedLabel:
        selectedItem
            ? selectedItem.label
            : ""

    signal routeRequested(string route)
    signal opened()
    signal closed()
    signal selectionChanged(int index, string route)

    function show(screen) {
        if (screen !== undefined && screen !== null) {
            targetScreen = screen
        } else {
            targetScreen = Core.ServiceRegistry.hyprland.focusedScreen
        }

        selectedIndex = normalizedIndex(selectedIndex)
        activationLocked = false

        if (!open) {
            open = true
            opened()
        }
    }

    function hide() {
        if (!open)
            return

        open = false
        activationLocked = false
        closed()
    }

    function toggle(screen) {
        if (open) {
            hide()
            return
        }

        show(screen)
    }

    function normalizedIndex(index) {
        if (itemCount <= 0)
            return 0

        return ((index % itemCount) + itemCount) % itemCount
    }

    function select(index) {
        if (itemCount <= 0)
            return

        const nextIndex = normalizedIndex(index)

        if (selectedIndex === nextIndex)
            return

        selectedIndex = nextIndex
        selectionChanged(selectedIndex, selectedRoute)
    }

    function selectRoute(route) {
        if (!route || itemCount <= 0)
            return false

        for (let index = 0; index < itemCount; index++) {
            if (items[index].route === route) {
                select(index)
                return true
            }
        }

        return false
    }

    function movePrevious() {
        select(selectedIndex - 1)
    }

    function moveNext() {
        select(selectedIndex + 1)
    }

    function moveBy(step) {
        if (!step)
            return

        select(selectedIndex + step)
    }

    function selectFirst() {
        select(0)
    }

    function selectLast() {
        select(itemCount - 1)
    }

    function activateSelected() {
        return activateRoute(selectedRoute)
    }

    function activateIndex(index) {
        if (itemCount <= 0)
            return false

        select(index)
        return activateSelected()
    }

    function activateRoute(route) {
        if (!open || activationLocked || !route)
            return false

        if (!containsRoute(route))
            return false

        activationLocked = true
        open = false
        closed()

        routeRequested(route)
        return true
    }

    function containsRoute(route) {
        for (let index = 0; index < itemCount; index++) {
            if (items[index].route === route)
                return true
        }

        return false
    }

    function finishActivation() {
        activationLocked = false
    }

    function reset() {
        open = false
        selectedIndex = 0
        targetScreen = null
        activationLocked = false
    }
}
