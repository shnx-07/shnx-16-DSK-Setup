import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.core as Core
import qs.theme as ShellTheme

Item {
    id: root

    signal closeRequested()

    readonly property var bluetooth:
        Core.ServiceRegistry.bluetooth

    readonly property var allDevices: {
        if (!bluetooth.devices
                || !bluetooth.devices.values) {
            return []
        }

        const values =
            bluetooth.devices.values.slice()

        values.sort(function(a, b) {
            const aConnected =
                a && a.connected === true

            const bConnected =
                b && b.connected === true

            if (aConnected !== bConnected)
                return aConnected ? -1 : 1

            const aPaired =
                a && a.paired === true

            const bPaired =
                b && b.paired === true

            if (aPaired !== bPaired)
                return aPaired ? -1 : 1

            const aName =
                a && a.name
                    ? a.name.toLowerCase()
                    : ""

            const bName =
                b && b.name
                    ? b.name.toLowerCase()
                    : ""

            return aName.localeCompare(bName)
        })

        return values
    }

    property var selectedDevice: null
    property bool actionInProgress: false
    property string actionError: ""

    function deviceName(device) {
        if (!device)
            return "Unknown Device"

        if (device.name && device.name.length > 0)
            return device.name

        if (device.address
                && device.address.length > 0) {
            return device.address
        }

        return "Unknown Device"
    }

    function deviceIcon(device) {
        if (!device)
            return "󰂯"

        const iconName =
            device.icon
                ? String(device.icon).toLowerCase()
                : ""

        const name =
            device.name
                ? String(device.name).toLowerCase()
                : ""

        if (iconName.indexOf("audio") >= 0
                || iconName.indexOf("head") >= 0
                || name.indexOf("head") >= 0
                || name.indexOf("buds") >= 0
                || name.indexOf("airpod") >= 0) {
            return "󰋋"
        }

        if (iconName.indexOf("mouse") >= 0
                || name.indexOf("mouse") >= 0) {
            return "󰍽"
        }

        if (iconName.indexOf("keyboard") >= 0
                || name.indexOf("keyboard") >= 0) {
            return "󰌌"
        }

        if (iconName.indexOf("phone") >= 0
                || name.indexOf("phone") >= 0) {
            return "󰄜"
        }

        if (iconName.indexOf("computer") >= 0
                || iconName.indexOf("laptop") >= 0) {
            return "󰌢"
        }

        return "󰂯"
    }

    function batteryPercentage(device) {
        if (!device
                || device.batteryAvailable
                    !== true) {
            return -1
        }

        return Math.round(device.battery * 100)
    }

    function deviceSubtitle(device) {
        if (!device)
            return ""

        if (device.connected === true) {
            const battery =
                batteryPercentage(device)

            if (battery >= 0)
                return "Connected · " + battery + "%"

            return "Connected"
        }

        if (device.stateChanging === true)
            return "Connecting…"

        if (device.paired === true)
            return "Paired"

        if (device.trusted === true)
            return "Trusted device"

        return "Available"
    }

    function selectDevice(device) {
        if (!device
                || device.stateChanging === true) {
            return
        }

        actionError = ""
        selectedDevice = device

        if (device.connected === true) {
            bluetooth.disconnectDevice(device)
            return
        }

        bluetooth.connectDevice(device)
    }

    function startDiscovery() {
        if (bluetooth.available
                && bluetooth.enabled) {
            bluetooth.setDiscovering(true)
        }
    }

    function stopDiscovery() {
        if (bluetooth.available) {
            bluetooth.setDiscovering(false)
        }
    }

    onVisibleChanged: {
        if (visible)
            startDiscovery()
        else
            stopDiscovery()
    }

    Component.onDestruction:
        stopDiscovery()

    Connections {
        target: root.selectedDevice
        enabled: root.selectedDevice !== null

        ignoreUnknownSignals: true

        function onConnectedChanged() {
            if (!root.selectedDevice)
                return

            root.actionInProgress =
                root.selectedDevice.stateChanging
                    === true
        }

        function onStateChangingChanged() {
            if (!root.selectedDevice)
                return

            root.actionInProgress =
                root.selectedDevice.stateChanging
                    === true

            if (!root.actionInProgress)
                root.selectedDevice = null
        }

        function onConnectionFailed(reason) {
            root.actionInProgress = false

            if (reason === undefined
                    || reason === null) {
                root.actionError =
                    "Unable to connect to this device."
            } else {
                root.actionError =
                    "Connection failed: "
                    + String(reason)
            }
        }
    }

    Rectangle {
        id: panelSurface

        anchors.fill: parent

        radius: ShellTheme.Theme.radius.island
        color: ShellTheme.Theme.colors.background

        border.width: 1
        border.color: ShellTheme.Theme.colors.outlineVariant

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1

            radius: ShellTheme.Theme.radius.island - 1
            color: "transparent"

            border.width: 1
            border.color: ShellTheme.Theme.colors.surfaceContainerLowest
        }

        Rectangle {
            id: closeButton

            anchors {
                top: parent.top
                right: parent.right
                topMargin: 14
                rightMargin: 14
            }

            width: 30
            height: 30

            z: 20
            radius: ShellTheme.Theme.radius.button

            color:
                closeMouse.containsMouse
                    ? ShellTheme.Theme.colors.hoverOverlay
                    : ShellTheme.Theme.colors.surfaceContainer

            Text {
                anchors.centerIn: parent

                text: "×"
                color: ShellTheme.Theme.colors.on_surface

                font.pixelSize: ShellTheme.Theme.typography.headlineSmall
                font.weight: Font.Medium
            }

            MouseArea {
                id: closeMouse

                anchors.fill: parent
                hoverEnabled: true
                cursorShape:
                    Qt.PointingHandCursor

                onClicked:
                    root.closeRequested()
            }
        }

        ColumnLayout {
            anchors {
                fill: parent
                margins: 20
            }

            spacing: 14

            // Header
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 38
                Layout.rightMargin: 40

                spacing: 12

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: "Bluetooth"
                        color: ShellTheme.Theme.colors.on_surface

                        font.pixelSize: ShellTheme.Theme.typography.headlineSmall
                        font.weight:
                            Font.DemiBold
                    }

                    Text {
                        text: bluetooth.stateName
                        color: ShellTheme.Theme.colors.on_surface_variant
                        font.pixelSize: ShellTheme.Theme.typography.labelSmall
                    }
                }

                Rectangle {
                    id: bluetoothSwitch

                    Layout.preferredWidth: 44
                    Layout.preferredHeight: 24

                    radius: height / 2

                    color:
                        bluetooth.enabled
                            ? ShellTheme.Theme.colors.primary
                            : ShellTheme.Theme.colors.surfaceContainerHighest

                    opacity:
                        bluetooth.available
                            ? 1
                            : 0.45

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    Rectangle {
                        width: 20
                        height: 20
                        y: 2

                        x:
                            bluetooth.enabled
                                ? parent.width
                                    - width - 2
                                : 2

                        radius: width / 2
                        color: ShellTheme.Theme.colors.on_primary

                        Behavior on x {
                            NumberAnimation {
                                duration: 150
                                easing.type:
                                    Easing.OutCubic
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent

                        enabled:
                            bluetooth.available

                        cursorShape:
                            enabled
                                ? Qt.PointingHandCursor
                                : Qt.ArrowCursor

                        onClicked:
                            bluetooth.toggleEnabled()
                    }
                }
            }

            // Bluetooth unavailable state
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true

                visible: !bluetooth.available

                radius: ShellTheme.Theme.radius.large
                color: ShellTheme.Theme.colors.surfaceContainer

                border.width: 1
                border.color: ShellTheme.Theme.colors.outlineVariant

                ColumnLayout {
                    anchors.centerIn: parent

                    width:
                        Math.min(
                            parent.width - 40,
                            290
                        )

                    spacing: 14

                    Rectangle {
                        Layout.alignment:
                            Qt.AlignHCenter

                        Layout.preferredWidth: 64
                        Layout.preferredHeight: 64

                        radius: ShellTheme.Theme.radius.panel
                        color: ShellTheme.Theme.colors.surfaceContainerHigh

                        Text {
                            anchors.centerIn: parent

                            text: "󰂲"
                            color: ShellTheme.Theme.colors.on_surface_variant
                            font.pixelSize: ShellTheme.Theme.typography.displaySmall
                        }
                    }

                    Text {
                        Layout.fillWidth: true

                        text:
                            "Bluetooth Unavailable"

                        color: ShellTheme.Theme.colors.on_surface

                        horizontalAlignment:
                            Text.AlignHCenter

                        font.pixelSize: ShellTheme.Theme.typography.titleSmall
                        font.weight:
                            Font.DemiBold
                    }

                    Text {
                        Layout.fillWidth: true

                        text:
                            "No Bluetooth adapter was detected."

                        color: ShellTheme.Theme.colors.on_surface_variant

                        horizontalAlignment:
                            Text.AlignHCenter

                        wrapMode:
                            Text.WordWrap

                        font.pixelSize: ShellTheme.Theme.typography.labelSmall
                    }
                }
            }

            // Bluetooth off state
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true

                visible:
                    bluetooth.available
                    && !bluetooth.enabled

                radius: ShellTheme.Theme.radius.large
                color: ShellTheme.Theme.colors.surfaceContainer

                border.width: 1
                border.color: ShellTheme.Theme.colors.outlineVariant

                ColumnLayout {
                    anchors.centerIn: parent

                    width:
                        Math.min(
                            parent.width - 40,
                            290
                        )

                    spacing: 14

                    Rectangle {
                        Layout.alignment:
                            Qt.AlignHCenter

                        Layout.preferredWidth: 64
                        Layout.preferredHeight: 64

                        radius: ShellTheme.Theme.radius.panel
                        color: ShellTheme.Theme.colors.surfaceContainerHigh

                        Text {
                            anchors.centerIn: parent

                            text: "󰂲"
                            color: ShellTheme.Theme.colors.on_surface_variant
                            font.pixelSize: ShellTheme.Theme.typography.displaySmall
                        }
                    }

                    Text {
                        Layout.fillWidth: true

                        text: "Bluetooth is Off"
                        color: ShellTheme.Theme.colors.on_surface

                        horizontalAlignment:
                            Text.AlignHCenter

                        font.pixelSize: ShellTheme.Theme.typography.titleSmall
                        font.weight:
                            Font.DemiBold
                    }

                    Text {
                        Layout.fillWidth: true

                        text:
                            "Turn on Bluetooth to connect accessories and nearby devices."

                        color: ShellTheme.Theme.colors.on_surface_variant

                        horizontalAlignment:
                            Text.AlignHCenter

                        wrapMode:
                            Text.WordWrap

                        font.pixelSize: ShellTheme.Theme.typography.labelSmall
                        lineHeight: 1.25
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        Layout.topMargin: 4

                        radius: ShellTheme.Theme.radius.button

                        color:
                            enableMouse.containsMouse
                                ? ShellTheme.Theme.colors.primaryHover
                                : ShellTheme.Theme.colors.primary

                        Text {
                            anchors.centerIn: parent

                            text:
                                "Turn Bluetooth On"

                            color: ShellTheme.Theme.colors.on_primary

                            font.pixelSize: ShellTheme.Theme.typography.labelMedium
                            font.weight:
                                Font.DemiBold
                        }

                        MouseArea {
                            id: enableMouse

                            anchors.fill: parent
                            hoverEnabled: true

                            cursorShape:
                                Qt.PointingHandCursor

                            onClicked:
                                bluetooth.setEnabled(
                                    true
                                )
                        }
                    }
                }
            }

            // Devices header row
            RowLayout {
                Layout.fillWidth: true

                visible:
                    bluetooth.available
                    && bluetooth.enabled

                spacing: 8

                Text {
                    Layout.fillWidth: true

                    text:
                        bluetooth.connected
                            ? "Devices"
                            : "Nearby Devices"

                    color: ShellTheme.Theme.colors.on_surface_variant

                    font.pixelSize: ShellTheme.Theme.typography.labelSmall
                    font.weight:
                        Font.DemiBold

                    font.capitalization:
                        Font.AllUppercase
                }

                Rectangle {
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30

                    radius: ShellTheme.Theme.radius.button

                    color:
                        discoveryMouse.containsMouse
                            ? ShellTheme.Theme.colors.hoverOverlay
                            : ShellTheme.Theme.colors.surfaceContainer

                    Text {
                        anchors.centerIn: parent

                        text: "󰑓"
                        color: ShellTheme.Theme.colors.on_surface
                        font.pixelSize: ShellTheme.Theme.typography.titleSmall

                        RotationAnimation on rotation {
                            running:
                                bluetooth.discovering

                            from: 0
                            to: 360
                            duration: 850

                            loops:
                                Animation.Infinite
                        }
                    }

                    MouseArea {
                        id: discoveryMouse

                        anchors.fill: parent
                        hoverEnabled: true

                        cursorShape:
                            Qt.PointingHandCursor

                        onClicked: {
                            if (bluetooth.discovering)
                                bluetooth.setDiscovering(
                                    false
                                )
                            else
                                bluetooth.setDiscovering(
                                    true
                                )
                        }
                    }
                }
            }

            // Error message
            Text {
                Layout.fillWidth: true

                visible:
                    root.actionError.length > 0

                text: root.actionError
                color: ShellTheme.Theme.colors.error

                font.pixelSize: ShellTheme.Theme.typography.labelSmall
                wrapMode: Text.WordWrap
            }

            // Device list
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true

                visible:
                    bluetooth.available
                    && bluetooth.enabled

                radius: ShellTheme.Theme.radius.card
                color: ShellTheme.Theme.colors.surfaceContainer

                border.width: 1
                border.color: ShellTheme.Theme.colors.outlineVariant

                clip: true

                ListView {
                    id: deviceList

                    anchors {
                        fill: parent
                        margins: 6
                    }

                    clip: true
                    spacing: 3

                    boundsBehavior:
                        Flickable.StopAtBounds

                    model: root.allDevices

                    delegate: Rectangle {
                        id: deviceDelegate

                        required property var modelData

                        width: deviceList.width
                        height: 58

                        radius: ShellTheme.Theme.radius.button

                        readonly property bool connected:
                            modelData
                            && modelData.connected
                                === true

                        readonly property bool changing:
                            modelData
                            && modelData.stateChanging
                                === true

                        color:
                            deviceMouse.pressed
                                ? ShellTheme.Theme.colors.pressedOverlay
                                : deviceMouse.containsMouse
                                    ? ShellTheme.Theme.colors.hoverOverlay
                                    : "transparent"

                        RowLayout {
                            anchors {
                                fill: parent
                                leftMargin: 11
                                rightMargin: 11
                            }

                            spacing: 12

                            Rectangle {
                                Layout.preferredWidth: 38
                                Layout.preferredHeight: 38

                                radius: ShellTheme.Theme.radius.medium

                                color:
                                    deviceDelegate.connected
                                        ? ShellTheme.Theme.colors.primary
                                        : ShellTheme.Theme.colors.surfaceContainerHigh

                                Text {
                                    anchors.centerIn:
                                        parent

                                    text:
                                        root.deviceIcon(
                                            modelData
                                        )

                                    color:
                                        deviceDelegate.connected
                                            ? ShellTheme.Theme.colors.on_primary
                                            : ShellTheme.Theme.colors.on_surface

                                    font.pixelSize: ShellTheme.Theme.typography.headlineSmall
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    Layout.fillWidth: true

                                    text:
                                        root.deviceName(
                                            modelData
                                        )

                                    color: ShellTheme.Theme.colors.on_surface

                                    font.pixelSize: ShellTheme.Theme.typography.bodySmall
                                    font.weight:
                                        deviceDelegate.connected
                                            ? Font.DemiBold
                                            : Font.Medium

                                    elide:
                                        Text.ElideRight
                                }

                                Text {
                                    text:
                                        root.deviceSubtitle(
                                            modelData
                                        )

                                    color:
                                        deviceDelegate.connected
                                            ? ShellTheme.Theme.colors.success
                                            : ShellTheme.Theme.colors.on_surface_variant

                                    font.pixelSize: ShellTheme.Theme.typography.labelSmall
                                }
                            }

                            Text {
                                visible:
                                    deviceDelegate.connected
                                    && !deviceDelegate.changing

                                text: "✓"
                                color: ShellTheme.Theme.colors.success

                                font.pixelSize: ShellTheme.Theme.typography.titleSmall
                                font.weight: Font.Bold
                            }

                            Text {
                                visible:
                                    !deviceDelegate.connected
                                    && !deviceDelegate.changing

                                text: "›"
                                color: ShellTheme.Theme.colors.on_surface_variant
                                font.pixelSize: ShellTheme.Theme.typography.headlineSmall
                            }

                            Text {
                                visible:
                                    deviceDelegate.changing

                                text: "󰑓"
                                color: ShellTheme.Theme.colors.primary
                                font.pixelSize: ShellTheme.Theme.typography.titleSmall

                                RotationAnimation on rotation {
                                    running:
                                        deviceDelegate.changing

                                    from: 0
                                    to: 360
                                    duration: 850

                                    loops:
                                        Animation.Infinite
                                }
                            }
                        }

                        MouseArea {
                            id: deviceMouse

                            anchors.fill: parent
                            hoverEnabled: true

                            cursorShape:
                                Qt.PointingHandCursor

                            onClicked:
                                root.selectDevice(
                                    modelData
                                )
                        }
                    }

                    ScrollBar.vertical:
                        ScrollBar {}
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 8

                    visible:
                        root.allDevices.length === 0

                    Text {
                        anchors.horizontalCenter:
                            parent.horizontalCenter

                        text:
                            bluetooth.discovering
                                ? "󰑓"
                                : "󰂯"

                        color: ShellTheme.Theme.colors.on_surface_variant
                        font.pixelSize: ShellTheme.Theme.typography.displaySmall

                        RotationAnimation on rotation {
                            running:
                                bluetooth.discovering

                            from: 0
                            to: 360
                            duration: 850

                            loops:
                                Animation.Infinite
                        }
                    }

                    Text {
                        anchors.horizontalCenter:
                            parent.horizontalCenter

                        text:
                            bluetooth.discovering
                                ? "Looking for devices…"
                                : "No devices found"

                        color: ShellTheme.Theme.colors.on_surface_variant
                        font.pixelSize: ShellTheme.Theme.typography.labelSmall
                    }
                }
            }

            // Footer
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 22

                visible:
                    bluetooth.available
                    && bluetooth.enabled

                Text {
                    Layout.fillWidth: true

                    text:
                        root.allDevices.length
                        + (
                            root.allDevices.length === 1
                                ? " device"
                                : " devices"
                        )

                    color: ShellTheme.Theme.colors.on_surface_variant
                    font.pixelSize: ShellTheme.Theme.typography.labelSmall
                }

                Text {
                    text:
                        bluetooth.discovering
                            ? "Discovering…"
                            : "Discovery paused"

                    color: ShellTheme.Theme.colors.on_surface_variant
                    font.pixelSize: ShellTheme.Theme.typography.labelSmall
                }
            }
        }
    }
}
