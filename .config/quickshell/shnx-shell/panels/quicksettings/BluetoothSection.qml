import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.core as Core

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

        radius: 24
        color: "#16181d"

        border.width: 1
        border.color: "#363a44"

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1

            radius: 23
            color: "transparent"

            border.width: 1
            border.color: "#17191e"
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
            radius: 9

            color:
                closeMouse.containsMouse
                    ? "#343740"
                    : "#25282f"

            Text {
                anchors.centerIn: parent

                text: "×"
                color: "#d8dae0"

                font.pixelSize: 20
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
                        color: "#f5f5f7"

                        font.pixelSize: 22
                        font.weight:
                            Font.DemiBold
                    }

                    Text {
                        text: bluetooth.stateName
                        color: "#8f949f"
                        font.pixelSize: 11
                    }
                }

                Rectangle {
                    id: bluetoothSwitch

                    Layout.preferredWidth: 44
                    Layout.preferredHeight: 24

                    radius: height / 2

                    color:
                        bluetooth.enabled
                            ? "#0a84ff"
                            : "#444852"

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
                        color: "#ffffff"

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

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true

                visible: !bluetooth.available

                radius: 18
                color: "#202329"

                border.width: 1
                border.color: "#30343d"

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

                        radius: 20
                        color: "#2c3038"

                        Text {
                            anchors.centerIn: parent

                            text: "󰂲"
                            color: "#8f949f"
                            font.pixelSize: 31
                        }
                    }

                    Text {
                        Layout.fillWidth: true

                        text:
                            "Bluetooth Unavailable"

                        color: "#f1f2f4"

                        horizontalAlignment:
                            Text.AlignHCenter

                        font.pixelSize: 17
                        font.weight:
                            Font.DemiBold
                    }

                    Text {
                        Layout.fillWidth: true

                        text:
                            "No Bluetooth adapter was detected."

                        color: "#8f949f"

                        horizontalAlignment:
                            Text.AlignHCenter

                        wrapMode:
                            Text.WordWrap

                        font.pixelSize: 11
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true

                visible:
                    bluetooth.available
                    && !bluetooth.enabled

                radius: 18
                color: "#202329"

                border.width: 1
                border.color: "#30343d"

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

                        radius: 20
                        color: "#2c3038"

                        Text {
                            anchors.centerIn: parent

                            text: "󰂲"
                            color: "#8f949f"
                            font.pixelSize: 31
                        }
                    }

                    Text {
                        Layout.fillWidth: true

                        text: "Bluetooth is Off"
                        color: "#f1f2f4"

                        horizontalAlignment:
                            Text.AlignHCenter

                        font.pixelSize: 17
                        font.weight:
                            Font.DemiBold
                    }

                    Text {
                        Layout.fillWidth: true

                        text:
                            "Turn on Bluetooth to connect accessories and nearby devices."

                        color: "#8f949f"

                        horizontalAlignment:
                            Text.AlignHCenter

                        wrapMode:
                            Text.WordWrap

                        font.pixelSize: 11
                        lineHeight: 1.25
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        Layout.topMargin: 4

                        radius: 10

                        color:
                            enableMouse.containsMouse
                                ? "#168cff"
                                : "#0a84ff"

                        Text {
                            anchors.centerIn: parent

                            text:
                                "Turn Bluetooth On"

                            color: "#ffffff"

                            font.pixelSize: 12
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

                    color: "#8f949f"

                    font.pixelSize: 11
                    font.weight:
                        Font.DemiBold

                    font.capitalization:
                        Font.AllUppercase
                }

                Rectangle {
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30

                    radius: 9

                    color:
                        discoveryMouse.containsMouse
                            ? "#343740"
                            : "#25282f"

                    Text {
                        anchors.centerIn: parent

                        text: "󰑓"
                        color: "#d8dae0"
                        font.pixelSize: 15

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

            Text {
                Layout.fillWidth: true

                visible:
                    root.actionError.length > 0

                text: root.actionError
                color: "#ff453a"

                font.pixelSize: 11
                wrapMode: Text.WordWrap
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true

                visible:
                    bluetooth.available
                    && bluetooth.enabled

                radius: 16
                color: "#202329"

                border.width: 1
                border.color: "#30343d"

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

                        radius: 11

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
                                ? "#363a43"
                                : deviceMouse.containsMouse
                                    ? "#2d3038"
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

                                radius: 12

                                color:
                                    deviceDelegate.connected
                                        ? "#0a84ff"
                                        : "#2d3139"

                                Text {
                                    anchors.centerIn:
                                        parent

                                    text:
                                        root.deviceIcon(
                                            modelData
                                        )

                                    color:
                                        deviceDelegate.connected
                                            ? "#ffffff"
                                            : "#d7d9de"

                                    font.pixelSize: 20
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

                                    color: "#f2f3f5"

                                    font.pixelSize: 13
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
                                            ? "#30d158"
                                            : "#858b96"

                                    font.pixelSize: 10
                                }
                            }

                            Text {
                                visible:
                                    deviceDelegate.connected
                                    && !deviceDelegate.changing

                                text: "✓"
                                color: "#30d158"

                                font.pixelSize: 15
                                font.weight: Font.Bold
                            }

                            Text {
                                visible:
                                    !deviceDelegate.connected
                                    && !deviceDelegate.changing

                                text: "›"
                                color: "#777d88"
                                font.pixelSize: 22
                            }

                            Text {
                                visible:
                                    deviceDelegate.changing

                                text: "󰑓"
                                color: "#0a84ff"
                                font.pixelSize: 15

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

                        color: "#777d88"
                        font.pixelSize: 25

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

                        color: "#858b96"
                        font.pixelSize: 11
                    }
                }
            }

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

                    color: "#737984"
                    font.pixelSize: 10
                }

                Text {
                    text:
                        bluetooth.discovering
                            ? "Discovering…"
                            : "Discovery paused"

                    color: "#737984"
                    font.pixelSize: 10
                }
            }
        }
    }
}
