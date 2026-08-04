pragma Singleton

import QtQuick

QtObject {
    id: root

    property string openPanel: ""
    property string selectedSection: ""
    property var anchorItem: null

    readonly property bool quickSettingsOpen:
        openPanel === "quickSettings"

    readonly property bool notificationsOpen:
        openPanel === "notifications"

    readonly property bool batteryPanelOpen:
        quickSettingsOpen
        && selectedSection === "battery"

    readonly property bool wifiPanelOpen:
        quickSettingsOpen
        && selectedSection === "wifi"

    readonly property bool bluetoothPanelOpen:
        quickSettingsOpen
        && selectedSection === "bluetooth"

    readonly property bool overviewPanelOpen:
        quickSettingsOpen
        && selectedSection === "overview"

    function toggleQuickSettings(section, item) {
        const requestedSection =
            section && section.length > 0
                ? section
                : "overview"

        const samePanel =
            openPanel === "quickSettings"
            && selectedSection === requestedSection

        const sameAnchor =
            anchorItem === item

        if (samePanel && sameAnchor) {
            close()
            return
        }

        anchorItem = item
        selectedSection = requestedSection
        openPanel = "quickSettings"
    }

    function openQuickSettings(section, item) {
        anchorItem = item

        selectedSection =
            section && section.length > 0
                ? section
                : "overview"

        openPanel = "quickSettings"
    }

    function toggleBattery(item) {
        toggleQuickSettings("battery", item)
    }

    function toggleWifi(item) {
        toggleQuickSettings("wifi", item)
    }

    function toggleBluetooth(item) {
        toggleQuickSettings("bluetooth", item)
    }

    function toggleNotifications(item) {
        const samePanel =
            openPanel === "notifications"

        const sameAnchor =
            anchorItem === item

        if (samePanel && sameAnchor) {
            close()
            return
        }

        anchorItem = item
        selectedSection = ""
        openPanel = "notifications"
    }

    function openNotifications(item) {
        anchorItem = item
        selectedSection = ""
        openPanel = "notifications"
    }

    readonly property bool powerPanelOpen:
    openPanel === "power"


    function togglePower(item) {
        const samePanel =
            openPanel === "power"

        const sameAnchor =
            anchorItem === item

        if (samePanel && sameAnchor) {
            close()
            return
        }

        anchorItem = item
        selectedSection = ""
        openPanel = "power"
    }

    function openPower(item) {
        anchorItem = item
        selectedSection = ""
        openPanel = "power"
    }

    function close() {
        openPanel = ""
        selectedSection = ""
    }
}
