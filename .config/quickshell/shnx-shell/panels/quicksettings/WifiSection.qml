import QtQuick
import QtQuick.Layouts
import qs.core as Core
import QtQuick.Controls
import Quickshell.Networking
import qs.theme as ShellTheme

Item {
  id: root

  property var selectedNetwork: null
  property var forgetNetwork: null

  property bool passwordPromptVisible: false
  property bool passwordVisible: false
  property bool connectingWithPassword: false
  property bool forgetPromptVisible: false

  property string connectionError: ""

    signal closeRequested()

    readonly property var network:
        Core.ServiceRegistry.network

    readonly property var availableNetworks: {
        if (!network.networks || !network.networks.values)
            return []

        const values = network.networks.values.slice()

        values.sort(function(a, b) {
            const aConnected =
                a && a.connected === true

            const bConnected =
                b && b.connected === true

            // Always keep the connected network first.
            if (aConnected !== bConnected)
                return aConnected ? -1 : 1

            const aStrength =
                a && a.signalStrength !== undefined
                    ? a.signalStrength
                    : 0

            const bStrength =
                b && b.signalStrength !== undefined
                    ? b.signalStrength
                    : 0

            return bStrength - aStrength
        })

        return values
    }

    property bool refreshing: false

    

    function signalIcon(strength) {
        if (strength >= 0.75)
            return "󰤨"

        if (strength >= 0.50)
            return "󰤥"

        if (strength >= 0.25)
            return "󰤢"

        return "󰤟"
    }

    function signalPercentage(strength) {
        if (strength === undefined
                || strength === null) {
            return 0
        }

        return Math.round(strength * 100)
    }

    function beginScanning() {
        if (!network.available
                || !network.wifiEnabled) {
            return
        }

        network.enableScanning(true)
    }

    function stopScanning() {
        network.enableScanning(false)
        refreshing = false
    }

    function refreshNetworks() {
      if (!network.available
              || !network.wifiEnabled
              || refreshing) {
          return
      }

      refreshing = true

      network.enableScanning(false)
      refreshDelay.restart()
    }


    function networkErrorMessage(reason) {
        if (reason === undefined
                || reason === null
                || String(reason).length === 0) {
            return "Unable to connect to this network."
        }

        return "Connection failed: " + String(reason)
    }

    function resetPasswordPrompt() {
        passwordPromptVisible = false
        passwordVisible = false
        connectingWithPassword = false
        connectionError = ""
        selectedNetwork = null

        passwordField.text = ""
    }

    function requestForget(networkObject) {
        if (!networkObject
                || (!networkObject.known && !networkObject.connected)
                || networkObject.stateChanging) {
            return
        }

        forgetNetwork = networkObject
        forgetPromptVisible = true
    }

    function cancelForget() {
        forgetPromptVisible = false
        forgetNetwork = null
    }

    function confirmForget() {
        if (!forgetNetwork)
            return

        if (forgetNetwork.connected) {
            forgetNetwork.disconnect()
        }

        forgetNetwork.forget()
        cancelForget()
    }


    function selectNetwork(networkObject) {
        if (!networkObject || networkObject.stateChanging)
            return

        connectionError = ""
        selectedNetwork = networkObject

        if (networkObject.connected) {
            networkObject.disconnect()
            return
        }

        if (networkObject.known) {
            networkObject.connect()
            return
        }

        if (networkObject.security === WifiSecurityType.Open) {
            networkObject.connect()
            return
        }

        passwordPromptVisible = true

        Qt.callLater(function() {
            passwordField.forceActiveFocus()
        })
    }


    onVisibleChanged: {
        if (visible)
            beginScanning()
        else
            stopScanning()
    }

    Component.onDestruction:
        stopScanning()

    Timer {
        id: refreshDelay

        interval: 250
        repeat: false

        onTriggered: {
            network.enableScanning(true)
            refreshFinished.restart()
        }
    }

    Timer {
        id: refreshFinished

        interval: 1100
        repeat: false

        onTriggered:
            root.refreshing = false
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

              spacing: 12

              ColumnLayout {
                  Layout.fillWidth: true
                  spacing: 2

                  Text {
                      text: "Wi-Fi"
                      color: ShellTheme.Theme.colors.on_surface
                      font.pixelSize: ShellTheme.Theme.typography.headlineSmall
                      font.weight: Font.DemiBold
                  }

                  Text {
                      text: network.stateName
                      color: ShellTheme.Theme.colors.on_surface_variant
                      font.pixelSize: ShellTheme.Theme.typography.labelSmall
                  }
              }

              Rectangle {
                  id: wifiSwitch

                  Layout.preferredWidth: 44
                  Layout.preferredHeight: 24
                  Layout.rightMargin: 36

                  radius: height / 2

                  color: network.wifiEnabled
                      ? ShellTheme.Theme.colors.primary
                      : ShellTheme.Theme.colors.surfaceContainerHighest

                  opacity:
                      network.available
                      && network.wifiHardwareEnabled
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

                      x: network.wifiEnabled
                          ? parent.width - width - 2
                          : 2

                      radius: width / 2
                      color: ShellTheme.Theme.colors.on_primary

                      Behavior on x {
                          NumberAnimation {
                              duration: 150
                              easing.type: Easing.OutCubic
                          }
                      }
                  }

                    MouseArea {
                        anchors.fill: parent

                        enabled:
                            network.available
                            && network.wifiHardwareEnabled

                        cursorShape:
                            enabled
                                ? Qt.PointingHandCursor
                                : Qt.ArrowCursor

                        onClicked:
                            network.toggleWifi()
                    }
                }
            }

            // Wi-Fi unavailable state
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 92

                visible: !network.available

                radius: ShellTheme.Theme.radius.card
                color: ShellTheme.Theme.colors.surfaceContainer

                border.width: 1
                border.color: ShellTheme.Theme.colors.outlineVariant

                RowLayout {
                    anchors {
                        fill: parent
                        margins: 16
                    }

                    spacing: 14

                    Rectangle {
                        Layout.preferredWidth: 46
                        Layout.preferredHeight: 46

                        radius: ShellTheme.Theme.radius.control
                        color: ShellTheme.Theme.colors.surfaceContainerHigh

                        Text {
                            anchors.centerIn: parent

                            text: "󰤭"
                            color: ShellTheme.Theme.colors.on_surface_variant
                            font.pixelSize: ShellTheme.Theme.typography.headlineMedium
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3

                        Text {
                            text: "Wi-Fi unavailable"
                            color: ShellTheme.Theme.colors.on_surface

                            font.pixelSize: ShellTheme.Theme.typography.bodyMedium
                            font.weight:
                                Font.DemiBold
                        }

                        Text {
                            Layout.fillWidth: true

                            text:
                                "No wireless network device was detected."

                            color: ShellTheme.Theme.colors.on_surface_variant
                            font.pixelSize: ShellTheme.Theme.typography.labelSmall
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }

            // Hardware disabled state
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 92

                visible:
                    network.available
                    && !network.wifiHardwareEnabled

                radius: ShellTheme.Theme.radius.card
                color: ShellTheme.Theme.colors.surfaceContainer

                border.width: 1
                border.color: ShellTheme.Theme.colors.outlineVariant

                RowLayout {
                    anchors {
                        fill: parent
                        margins: 16
                    }

                    spacing: 14

                    Rectangle {
                        Layout.preferredWidth: 46
                        Layout.preferredHeight: 46

                        radius: ShellTheme.Theme.radius.control
                        color: ShellTheme.Theme.colors.surfaceContainerHigh

                        Text {
                            anchors.centerIn: parent

                            text: "󰤭"
                            color: ShellTheme.Theme.colors.warning
                            font.pixelSize: ShellTheme.Theme.typography.headlineMedium
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3

                        Text {
                            text:
                                "Wireless hardware disabled"

                            color: ShellTheme.Theme.colors.on_surface

                            font.pixelSize: ShellTheme.Theme.typography.bodyMedium
                            font.weight:
                                Font.DemiBold
                        }

                        Text {
                            Layout.fillWidth: true

                            text:
                                "Enable the wireless device before turning on Wi-Fi."

                            color: ShellTheme.Theme.colors.on_surface_variant
                            font.pixelSize: ShellTheme.Theme.typography.labelSmall
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }

            // Wi-Fi off state
            Rectangle {
                  Layout.fillWidth: true
                  Layout.fillHeight: true

                  visible:
                      network.available
                      && network.wifiHardwareEnabled
                      && !network.wifiEnabled

                  radius: ShellTheme.Theme.radius.large
                  color: ShellTheme.Theme.colors.surfaceContainer

                  border.width: 1
                  border.color: ShellTheme.Theme.colors.outlineVariant

                  ColumnLayout {
                      anchors {
                          centerIn: parent
                      }

                      width: Math.min(parent.width - 40, 290)
                      spacing: 14

                  Rectangle {
                        Layout.alignment: Qt.AlignHCenter

                        Layout.preferredWidth: 64
                        Layout.preferredHeight: 64

                        radius: ShellTheme.Theme.radius.panel
                        color: ShellTheme.Theme.colors.surfaceContainerHigh

                        Text {
                            anchors.centerIn: parent

                            text: "󰤭"
                            color: ShellTheme.Theme.colors.on_surface_variant
                            font.pixelSize: ShellTheme.Theme.typography.displaySmall
                        }
                    }

                    Text {
                        Layout.fillWidth: true

                        text: "Wi-Fi is Off"
                        color: ShellTheme.Theme.colors.on_surface

                        horizontalAlignment: Text.AlignHCenter

                        font.pixelSize: ShellTheme.Theme.typography.titleSmall
                        font.weight: Font.DemiBold
                    }

                    Text {
                        Layout.fillWidth: true

                        text:
                            "Turn on Wi-Fi to discover and connect to nearby networks."

                        color: ShellTheme.Theme.colors.on_surface_variant

                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap

                        font.pixelSize: ShellTheme.Theme.typography.labelSmall
                        lineHeight: 1.25
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        Layout.topMargin: 4

                        radius: ShellTheme.Theme.radius.button

                        color: enableMouse.containsMouse
                            ? ShellTheme.Theme.colors.primaryHover
                            : ShellTheme.Theme.colors.primary

                        Text {
                            anchors.centerIn: parent

                            text: "Turn Wi-Fi On"
                            color: ShellTheme.Theme.colors.on_primary

                            font.pixelSize: ShellTheme.Theme.typography.labelMedium
                            font.weight: Font.DemiBold
                        }

                        MouseArea {
                            id: enableMouse

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked:
                                network.setWifiEnabled(true)
                        }
                    }
                }
            }

            // Connected network
            ColumnLayout {
                Layout.fillWidth: true

                visible:
                    network.available
                    && network.wifiEnabled
                    && network.connected

                spacing: 7

                Text {
                    text: "Connected"

                    color: ShellTheme.Theme.colors.on_surface_variant

                    font.pixelSize: ShellTheme.Theme.typography.labelSmall
                    font.weight: Font.DemiBold
                    font.capitalization:
                        Font.AllUppercase
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 86

                    radius: ShellTheme.Theme.radius.card
                    color: ShellTheme.Theme.colors.surfaceContainerHigh

                    border.width: 1
                    border.color: ShellTheme.Theme.colors.outlineVariant

                    RowLayout {
                        anchors {
                            fill: parent
                            margins: 14
                        }

                        spacing: 13

                        Rectangle {
                            Layout.preferredWidth: 50
                            Layout.preferredHeight: 50

                            radius: ShellTheme.Theme.radius.medium
                            color: ShellTheme.Theme.colors.primary

                            Text {
                                anchors.centerIn: parent

                                text:
                                    root.signalIcon(
                                        network.signalStrength
                                    )

                                color: ShellTheme.Theme.colors.on_primary
                                font.pixelSize: ShellTheme.Theme.typography.displaySmall
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                Layout.fillWidth: true

                                text:
                                    network.ssid.length > 0
                                        ? network.ssid
                                        : "Connected network"

                                color: ShellTheme.Theme.colors.on_surface

                                font.pixelSize: ShellTheme.Theme.typography.titleSmall
                                font.weight:
                                    Font.DemiBold

                                elide: Text.ElideRight
                            }

                            Text {
                                text:
                                    network.signalPercentage
                                    + "% signal"

                                color: ShellTheme.Theme.colors.on_surface_variant
                                font.pixelSize: ShellTheme.Theme.typography.labelSmall
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 8
                            Layout.preferredHeight: 8

                            radius: 4
                            color: ShellTheme.Theme.colors.success
                        }

                        Rectangle {
                            Layout.preferredWidth: 28
                            Layout.preferredHeight: 28

                            radius: ShellTheme.Theme.radius.button

                            color: connectedMenuMouse.containsMouse
                                ? ShellTheme.Theme.colors.hoverOverlay
                                : "transparent"

                            Text {
                                anchors.centerIn: parent

                                text: "•••"
                                color: ShellTheme.Theme.colors.on_surface_variant
                                font.pixelSize: ShellTheme.Theme.typography.labelMedium
                                font.weight: Font.DemiBold
                            }

                            MouseArea {
                                id: connectedMenuMouse

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onClicked: function(mouse) {
                                    mouse.accepted = true
                                    root.requestForget(network.connectedNetwork)
                                }
                            }
                        }
                    }
                }
            }

            // Disconnected notice
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 62

                visible:
                    network.available
                    && network.wifiEnabled
                    && !network.connected

                radius: ShellTheme.Theme.radius.control
                color: ShellTheme.Theme.colors.surfaceContainer

                border.width: 1
                border.color: ShellTheme.Theme.colors.outlineVariant

                RowLayout {
                    anchors {
                        fill: parent
                        margins: 13
                    }

                    spacing: 12

                    Rectangle {
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36

                        radius: ShellTheme.Theme.radius.button
                        color: ShellTheme.Theme.colors.surfaceContainerHigh

                        Text {
                            anchors.centerIn: parent

                            text: "󰤯"
                            color: ShellTheme.Theme.colors.warning
                            font.pixelSize: ShellTheme.Theme.typography.headlineSmall
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: "Not connected"
                            color: ShellTheme.Theme.colors.on_surface

                            font.pixelSize: ShellTheme.Theme.typography.bodySmall
                            font.weight:
                                Font.DemiBold
                        }

                        Text {
                            text:
                                "Choose a network below"

                            color: ShellTheme.Theme.colors.on_surface_variant
                            font.pixelSize: ShellTheme.Theme.typography.labelSmall
                        }
                    }
                }
            }

            // Available networks header
            RowLayout {
                Layout.fillWidth: true

                visible:
                    network.available
                    && network.wifiEnabled

                spacing: 8

                Text {
                    Layout.fillWidth: true

                    text: "Other Networks"

                    color: ShellTheme.Theme.colors.on_surface_variant

                    font.pixelSize: ShellTheme.Theme.typography.labelSmall
                    font.weight: Font.DemiBold
                    font.capitalization:
                        Font.AllUppercase
                }

                Rectangle {
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30

                    radius: ShellTheme.Theme.radius.button

                    color: refreshMouse.containsMouse
                        ? ShellTheme.Theme.colors.hoverOverlay
                        : ShellTheme.Theme.colors.surfaceContainer

                    opacity:
                        root.refreshing
                            ? 0.65
                            : 1

                    Text {
                        anchors.centerIn: parent

                        text: "󰑓"
                        color: ShellTheme.Theme.colors.on_surface
                        font.pixelSize: ShellTheme.Theme.typography.titleSmall

                        RotationAnimation on rotation {
                            running: root.refreshing

                            from: 0
                            to: 360

                            duration: 850
                            loops:
                                Animation.Infinite
                        }
                    }

                    MouseArea {
                        id: refreshMouse

                        anchors.fill: parent
                        hoverEnabled: true

                        enabled: !root.refreshing

                        cursorShape:
                            enabled
                                ? Qt.PointingHandCursor
                                : Qt.ArrowCursor

                        onClicked:
                            root.refreshNetworks()
                    }
                }
            }

            // Network list
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true

                visible:
                    network.available
                    && network.wifiEnabled

                radius: ShellTheme.Theme.radius.card
                color: ShellTheme.Theme.colors.surfaceContainer

                border.width: 1
                border.color: ShellTheme.Theme.colors.outlineVariant

                clip: true

                ListView {
                    id: networkList

                    anchors {
                        fill: parent
                        margins: 6
                    }

                    spacing: 3
                    clip: true

                    boundsBehavior:
                        Flickable.StopAtBounds

                    model: root.availableNetworks

                    delegate: Rectangle {
                        id: networkDelegate

                        required property var modelData

                        width: networkList.width
                        height: 54

                        radius: ShellTheme.Theme.radius.button

                        color:
                            networkMouse.pressed
                                ? ShellTheme.Theme.colors.pressedOverlay
                                : networkMouse.containsMouse
                                    ? ShellTheme.Theme.colors.hoverOverlay
                                    : "transparent"

                        readonly property real strength:
                            modelData
                                && modelData.signalStrength
                                    !== undefined
                                ? modelData.signalStrength
                                : 0

                        readonly property bool isConnected:
                            modelData
                                && modelData.connected
                                === true

                        readonly property bool isChanging:
                            modelData
                            && modelData.stateChanging === true

                        readonly property bool isKnown:
                            modelData
                            && modelData.known === true

                        RowLayout {
                            anchors {
                                fill: parent
                                leftMargin: 11
                                rightMargin: 11
                            }

                            spacing: 12

                            Rectangle {
                                Layout.preferredWidth: 36
                                Layout.preferredHeight: 36

                                radius: ShellTheme.Theme.radius.button

                                color:
                                    networkDelegate.isConnected
                                        ? ShellTheme.Theme.colors.primary
                                        : ShellTheme.Theme.colors.surfaceContainerHigh

                                Text {
                                    anchors.centerIn: parent

                                    text:
                                        root.signalIcon(
                                            networkDelegate.strength
                                        )

                                    color:
                                        networkDelegate.isConnected
                                            ? ShellTheme.Theme.colors.on_primary
                                            : ShellTheme.Theme.colors.on_surface

                                    font.pixelSize: ShellTheme.Theme.typography.bodyMedium
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    Layout.fillWidth: true

                                    text:
                                        modelData
                                        && modelData.name
                                            ? modelData.name
                                            : "Hidden network"

                                    color: ShellTheme.Theme.colors.on_surface

                                    font.pixelSize: ShellTheme.Theme.typography.bodySmall
                                    font.weight:
                                        networkDelegate.isConnected
                                            ? Font.DemiBold
                                            : Font.Medium

                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: {
                                        if (networkDelegate.isChanging)
                                            return networkDelegate.isConnected
                                                ? "Disconnecting…"
                                                : "Connecting…"

                                        if (networkDelegate.isConnected)
                                            return "Connected"

                                        if (modelData.known)
                                            return "Saved network"

                                        return root.signalPercentage(
                                            networkDelegate.strength
                                        ) + "% signal"
                                    }

                                    color:
                                        networkDelegate.isConnected
                                            ? ShellTheme.Theme.colors.success
                                            : ShellTheme.Theme.colors.on_surface_variant

                                    font.pixelSize: ShellTheme.Theme.typography.labelSmall
                                }
                            }

                            Text {
                                visible:
                                  networkDelegate.isConnected
                                  && !networkDelegate.isChanging

                                text: "✓"
                                color: ShellTheme.Theme.colors.success

                                font.pixelSize: ShellTheme.Theme.typography.titleSmall
                                font.weight: Font.Bold
                            }

                            Rectangle {
                              Layout.preferredWidth: 28
                              Layout.preferredHeight: 28

                              visible:
                                  (networkDelegate.isKnown || networkDelegate.isConnected)
                                  && !networkDelegate.isChanging

                              z: 5
                              radius: ShellTheme.Theme.radius.button

                              color:
                                  networkMenuMouse.containsMouse
                                      ? ShellTheme.Theme.colors.hoverOverlay
                                      : "transparent"

                              Text {
                                  anchors.centerIn: parent

                                  text: "•••"
                                  color: ShellTheme.Theme.colors.on_surface_variant
                                  font.pixelSize: ShellTheme.Theme.typography.labelMedium
                                  font.weight: Font.DemiBold
                              }

                              MouseArea {
                                  id: networkMenuMouse

                                  anchors.fill: parent
                                  hoverEnabled: true
                                  cursorShape: Qt.PointingHandCursor

                                  onClicked: function(mouse) {
                                      mouse.accepted = true
                                      root.requestForget(modelData)
                                  }
                              }
                          }

                          Text {
                              visible:
                                  !networkDelegate.isKnown
                                  && !networkDelegate.isConnected
                                  && !networkDelegate.isChanging

                              text: "›"
                              color: ShellTheme.Theme.colors.on_surface_variant
                              font.pixelSize: ShellTheme.Theme.typography.headlineSmall
                          }

                            Text {
                                visible: networkDelegate.isChanging

                                text: "󰑓"
                                color: ShellTheme.Theme.colors.primary
                                font.pixelSize: ShellTheme.Theme.typography.titleSmall

                                RotationAnimation on rotation {
                                    running: networkDelegate.isChanging
                                    from: 0
                                    to: 360
                                    duration: 850
                                    loops: Animation.Infinite
                                }
                            }
                        }

                        MouseArea {
                          id: networkMouse

                          anchors.fill: parent
                          z: 1

                          hoverEnabled: true
                          cursorShape: Qt.PointingHandCursor

                          onClicked:
                              root.selectNetwork(modelData)
                      }
                    }

                    ScrollBar.vertical:
                        ScrollBar {}
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 8

                    visible:
                        root.availableNetworks.length === 0

                    Text {
                        anchors.horizontalCenter:
                            parent.horizontalCenter

                        text:
                            root.refreshing
                                ? "󰑓"
                                : "󰤯"

                        color: ShellTheme.Theme.colors.on_surface_variant
                        font.pixelSize: ShellTheme.Theme.typography.headlineMedium

                        RotationAnimation on rotation {
                            running: root.refreshing

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
                            root.refreshing
                                ? "Looking for networks…"
                                : "No networks found"

                        color: ShellTheme.Theme.colors.on_surface_variant
                        font.pixelSize: ShellTheme.Theme.typography.labelSmall
                    }
                }
            }

            // Footer
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 24

                visible:
                    network.available
                    && network.wifiEnabled

                Text {
                    Layout.fillWidth: true

                    text:
                        root.availableNetworks.length
                        + (
                            root.availableNetworks.length === 1
                                ? " network"
                                : " networks"
                        )

                    color: ShellTheme.Theme.colors.on_surface_variant
                    font.pixelSize: ShellTheme.Theme.typography.labelSmall
                }

                Text {
                    text:
                        root.refreshing
                            ? "Scanning…"
                            : "Scanning while open"

                    color: ShellTheme.Theme.colors.on_surface_variant
                    font.pixelSize: ShellTheme.Theme.typography.labelSmall
                }
            }
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

            z: 10
            radius: ShellTheme.Theme.radius.button

            color: closeMouse.containsMouse
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
                cursorShape: Qt.PointingHandCursor

                onClicked:
                    root.closeRequested()
            }
          }
        

        // Password prompt overlay
        Rectangle {
                    anchors.fill: parent
                    z: 50

                    visible: root.passwordPromptVisible

                    radius: panelSurface.radius
                    color: ShellTheme.Theme.colors.scrim

                    MouseArea {
                        anchors.fill: parent
                    }

                    Rectangle {
                        anchors.centerIn: parent

                        width: parent.width - 40
                        height: 245

                        radius: ShellTheme.Theme.radius.panel
                        color: ShellTheme.Theme.colors.surfaceContainerHigh

                        border.width: 1
                        border.color: ShellTheme.Theme.colors.outlineVariant

                        ColumnLayout {
                            anchors {
                                fill: parent
                                margins: 20
                            }

                            spacing: 13

                            RowLayout {
                                Layout.fillWidth: true

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 3

                                    Text {
                                        text: "Enter Wi-Fi Password"
                                        color: ShellTheme.Theme.colors.on_surface

                                        font.pixelSize: ShellTheme.Theme.typography.titleSmall
                                        font.weight: Font.DemiBold
                                    }

                                    Text {
                                        Layout.fillWidth: true

                                        text:
                                            root.selectedNetwork
                                                ? root.selectedNetwork.name
                                                : ""

                                        color: ShellTheme.Theme.colors.on_surface_variant
                                        font.pixelSize: ShellTheme.Theme.typography.labelSmall
                                        elide: Text.ElideRight
                                    }
                                }

                                Rectangle {
                                    Layout.preferredWidth: 28
                                    Layout.preferredHeight: 28

                                    radius: ShellTheme.Theme.radius.button

                                    color: passwordCloseMouse.containsMouse
                                        ? ShellTheme.Theme.colors.hoverOverlay
                                        : ShellTheme.Theme.colors.surfaceContainer

                                    Text {
                                        anchors.centerIn: parent

                                        text: "×"
                                        color: ShellTheme.Theme.colors.on_surface
                                        font.pixelSize: ShellTheme.Theme.typography.titleSmall
                                    }

                                    MouseArea {
                                        id: passwordCloseMouse

                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor

                                        onClicked:
                                          root.resetPasswordPrompt()
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 42

                                radius: ShellTheme.Theme.radius.button

                                color: ShellTheme.Theme.colors.surfaceContainerLowest

                                border.width: passwordField.activeFocus || root.connectionError.length > 0
                                    ? 1
                                    : 0

                                border.color: root.connectionError.length > 0
                                    ? ShellTheme.Theme.colors.error
                                    : ShellTheme.Theme.colors.primary

                                TextInput {
                                    id: passwordField

                                    anchors {
                                        fill: parent
                                        leftMargin: 13
                                        rightMargin: 44
                                    }

                                    verticalAlignment:
                                        TextInput.AlignVCenter

                                    color: ShellTheme.Theme.colors.on_surface
                                    selectionColor: ShellTheme.Theme.colors.primary

                                    font.pixelSize: ShellTheme.Theme.typography.bodySmall

                                    echoMode:
                                        root.passwordVisible
                                            ? TextInput.Normal
                                            : TextInput.Password

                                    clip: true

                                    onAccepted: {
                                      if (connectButton.enabled)
                                          connectButton.connectSelectedNetwork()
                                  }
                                }

                                Text {
                                    anchors {
                                        left: passwordField.left
                                        verticalCenter:
                                            parent.verticalCenter
                                    }

                                    visible: passwordField.text.length === 0

                                    text: "Password"
                                    color: ShellTheme.Theme.colors.disabled
                                    font.pixelSize: ShellTheme.Theme.typography.bodySmall
                                }

                                Text {
                                    anchors {
                                        right: parent.right
                                        rightMargin: 13
                                        verticalCenter:
                                            parent.verticalCenter
                                    }

                                    text:
                                        root.passwordVisible
                                            ? "󰈈"
                                            : "󰈉"

                                    color: ShellTheme.Theme.colors.on_surface_variant
                                    font.pixelSize: ShellTheme.Theme.typography.titleSmall

                                    MouseArea {
                                        anchors.fill: parent

                                        anchors.margins: -8

                                        cursorShape:
                                            Qt.PointingHandCursor

                                        onClicked:
                                            root.passwordVisible =
                                                !root.passwordVisible
                                    }
                                }
                            }

                            Text {
                                Layout.fillWidth: true

                                visible: root.connectionError.length > 0

                                text: root.connectionError
                                color: ShellTheme.Theme.colors.error

                                font.pixelSize: ShellTheme.Theme.typography.labelSmall
                                wrapMode: Text.WordWrap
                            }

                            Item {
                                Layout.fillHeight: true
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 36

                                    radius: ShellTheme.Theme.radius.button
                                    color: cancelMouse.containsMouse
                                        ? ShellTheme.Theme.colors.hoverOverlay
                                        : ShellTheme.Theme.colors.surfaceContainer

                                    Text {
                                        anchors.centerIn: parent

                                        text: "Cancel"
                                        color: ShellTheme.Theme.colors.on_surface

                                        font.pixelSize: ShellTheme.Theme.typography.labelMedium
                                        font.weight: Font.DemiBold
                                    }

                                    MouseArea {
                                        id: cancelMouse

                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape:
                                            Qt.PointingHandCursor

                                        onClicked:
                                            root.resetPasswordPrompt()
                                    }
                                }

                                Rectangle {
                                      id: connectButton

                                              Layout.fillWidth: true
                                              Layout.preferredHeight: 36

                                              radius: ShellTheme.Theme.radius.button

                                              enabled:
                                                  passwordField.text.length >= 8
                                                  && !root.connectingWithPassword

                                        opacity: enabled ? 1 : 0.45

                                        color:
                                            connectMouse.containsMouse
                                            && connectButton.enabled
                                                ? ShellTheme.Theme.colors.primaryHover
                                                : ShellTheme.Theme.colors.primary

                                        function connectSelectedNetwork() {
                                            if (!connectButton.enabled
                                                    || !root.selectedNetwork) {
                                                return
                                            }

                                            root.connectionError = ""
                                            root.connectingWithPassword = true

                                            root.selectedNetwork.connectWithPsk(
                                                passwordField.text
                                            )
                                        }

                                        Text {
                                            anchors.centerIn: parent

                                            text:
                                                root.connectingWithPassword
                                                    ? "Connecting…"
                                                      : "Connect"

                                              color: ShellTheme.Theme.colors.on_primary

                                              font.pixelSize: ShellTheme.Theme.typography.labelMedium
                                              font.weight: Font.DemiBold
                                          }

                                          MouseArea {
                                              id: connectMouse

                                anchors.fill: parent
                                hoverEnabled: true

                                enabled: connectButton.enabled

                                cursorShape:
                                    enabled
                                        ? Qt.PointingHandCursor
                                        : Qt.ArrowCursor

                                onClicked:
                                    connectButton.connectSelectedNetwork()
                        }
                    } 
                            }
                        }
                    }
                  }


        // Forget network overlay
        Rectangle {
                anchors.fill: parent
                z: 60

                visible: root.forgetPromptVisible

                radius: panelSurface.radius
                color: ShellTheme.Theme.colors.scrim

                MouseArea {
                    anchors.fill: parent
                }

                Rectangle {
                    anchors.centerIn: parent

                    width: parent.width - 52
                    height: 205

                    radius: ShellTheme.Theme.radius.panel
                    color: ShellTheme.Theme.colors.surfaceContainerHigh

                    border.width: 1
                    border.color: ShellTheme.Theme.colors.outlineVariant

                    ColumnLayout {
                        anchors {
                            fill: parent
                            margins: 20
                        }

                        spacing: 10

                        Text {
                            Layout.fillWidth: true

                            text: "Forget This Network?"
                            color: ShellTheme.Theme.colors.on_surface

                            horizontalAlignment: Text.AlignHCenter

                            font.pixelSize: ShellTheme.Theme.typography.titleSmall
                            font.weight: Font.DemiBold
                        }

                        Text {
                            Layout.fillWidth: true

                            text:
                                root.forgetNetwork
                                    ? root.forgetNetwork.name
                                    : ""

                            color: ShellTheme.Theme.colors.on_surface_variant

                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight

                            font.pixelSize: ShellTheme.Theme.typography.bodySmall
                            font.weight: Font.Medium
                        }

                        Text {
                            Layout.fillWidth: true

                            text:
                                "The saved password and connection settings will be removed."

                            color: ShellTheme.Theme.colors.on_surface_variant

                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap

                            font.pixelSize: ShellTheme.Theme.typography.labelSmall
                        }

                        Item {
                            Layout.fillHeight: true
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 36

                                radius: ShellTheme.Theme.radius.button

                                color:
                                    forgetCancelMouse.containsMouse
                                        ? ShellTheme.Theme.colors.hoverOverlay
                                        : ShellTheme.Theme.colors.surfaceContainer

                                Text {
                                    anchors.centerIn: parent

                                    text: "Cancel"
                                    color: ShellTheme.Theme.colors.on_surface

                                    font.pixelSize: ShellTheme.Theme.typography.labelMedium
                                    font.weight: Font.DemiBold
                                }

                                MouseArea {
                                    id: forgetCancelMouse

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor

                                    onClicked:
                                        root.cancelForget()
                                }
                            }

                          Rectangle {
                              Layout.fillWidth: true
                              Layout.preferredHeight: 36

                              radius: ShellTheme.Theme.radius.button

                                          color:
                                              forgetConfirmMouse.containsMouse
                                                  ? ShellTheme.Theme.colors.errorHover
                                                  : ShellTheme.Theme.colors.error

                                          Text {
                                              anchors.centerIn: parent

                                              text: "Forget"
                                              color: ShellTheme.Theme.colors.on_error

                                          font.pixelSize: ShellTheme.Theme.typography.labelMedium
                                          font.weight: Font.DemiBold
                                      }

                                      MouseArea {
                                          id: forgetConfirmMouse

                                          anchors.fill: parent
                                          hoverEnabled: true
                                          cursorShape: Qt.PointingHandCursor

                                          onClicked:
                                              root.confirmForget()
                                      }
                                  }
                              }
                          }
                      }
                  }


              }


              Connections {
                target: root.selectedNetwork
                enabled: root.selectedNetwork !== null

                ignoreUnknownSignals: true

                function onConnectionFailed(reason) {
                    root.connectingWithPassword = false
                    root.connectionError =
                        root.networkErrorMessage(reason)

                    if (root.selectedNetwork
                            && !root.selectedNetwork.known
                            && root.selectedNetwork.security
                                !== WifiSecurityType.Open) {
                        root.passwordPromptVisible = true

                        Qt.callLater(function() {
                            passwordField.selectAll()
                            passwordField.forceActiveFocus()
                        })
                    }
                }

                function onConnectedChanged() {
                    if (!root.selectedNetwork)
                        return

                    if (root.selectedNetwork.connected) {
                        root.resetPasswordPrompt()
                        return
                    }

                    if (!root.selectedNetwork.stateChanging
                            && !root.passwordPromptVisible) {
                        root.selectedNetwork = null
                    }
                }

                function onStateChangingChanged() {
                    if (!root.selectedNetwork)
                        return

                    if (root.selectedNetwork.stateChanging)
                        return

                    root.connectingWithPassword = false

                    if (!root.selectedNetwork.connected
                            && root.passwordPromptVisible
                            && root.connectionError.length === 0) {
                        root.connectionError = "Incorrect password or authentication failed. Please try again."
                        Qt.callLater(function() {
                            passwordField.selectAll()
                            passwordField.forceActiveFocus()
                        })
                    }

                    if (!root.selectedNetwork.connected
                            && !root.passwordPromptVisible
                            && root.connectionError.length === 0) {
                        root.selectedNetwork = null
                    }
                }
            }
}

