import QtQuick
import QtQuick.Layouts
import qs.core as Core
import QtQuick.Controls
import Quickshell.Networking

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
                || !networkObject.known
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
                      color: "#f5f5f7"
                      font.pixelSize: 22
                      font.weight: Font.DemiBold
                  }

                  Text {
                      text: network.stateName
                      color: "#8f949f"
                      font.pixelSize: 11
                  }
              }

              Rectangle {
                  id: wifiSwitch

                  Layout.preferredWidth: 44
                  Layout.preferredHeight: 24
                  Layout.rightMargin: 36

                  radius: height / 2

                  color: network.wifiEnabled
                      ? "#0a84ff"
                      : "#444852"

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
                      color: "#ffffff"

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

                radius: 16
                color: "#202329"

                border.width: 1
                border.color: "#30343d"

                RowLayout {
                    anchors {
                        fill: parent
                        margins: 16
                    }

                    spacing: 14

                    Rectangle {
                        Layout.preferredWidth: 46
                        Layout.preferredHeight: 46

                        radius: 14
                        color: "#2c3038"

                        Text {
                            anchors.centerIn: parent

                            text: "󰤭"
                            color: "#8f949f"
                            font.pixelSize: 24
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3

                        Text {
                            text: "Wi-Fi unavailable"
                            color: "#f1f2f4"

                            font.pixelSize: 14
                            font.weight:
                                Font.DemiBold
                        }

                        Text {
                            Layout.fillWidth: true

                            text:
                                "No wireless network device was detected."

                            color: "#8f949f"
                            font.pixelSize: 11
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

                radius: 16
                color: "#202329"

                border.width: 1
                border.color: "#30343d"

                RowLayout {
                    anchors {
                        fill: parent
                        margins: 16
                    }

                    spacing: 14

                    Rectangle {
                        Layout.preferredWidth: 46
                        Layout.preferredHeight: 46

                        radius: 14
                        color: "#2c3038"

                        Text {
                            anchors.centerIn: parent

                            text: "󰤭"
                            color: "#ff9f0a"
                            font.pixelSize: 24
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3

                        Text {
                            text:
                                "Wireless hardware disabled"

                            color: "#f1f2f4"

                            font.pixelSize: 14
                            font.weight:
                                Font.DemiBold
                        }

                        Text {
                            Layout.fillWidth: true

                            text:
                                "Enable the wireless device before turning on Wi-Fi."

                            color: "#8f949f"
                            font.pixelSize: 11
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

                  radius: 18
                  color: "#202329"

                  border.width: 1
                  border.color: "#30343d"

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

                        radius: 20
                        color: "#2c3038"

                        Text {
                            anchors.centerIn: parent

                            text: "󰤭"
                            color: "#8f949f"
                            font.pixelSize: 31
                        }
                    }

                    Text {
                        Layout.fillWidth: true

                        text: "Wi-Fi is Off"
                        color: "#f1f2f4"

                        horizontalAlignment: Text.AlignHCenter

                        font.pixelSize: 17
                        font.weight: Font.DemiBold
                    }

                    Text {
                        Layout.fillWidth: true

                        text:
                            "Turn on Wi-Fi to discover and connect to nearby networks."

                        color: "#8f949f"

                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap

                        font.pixelSize: 11
                        lineHeight: 1.25
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        Layout.topMargin: 4

                        radius: 10

                        color: enableMouse.containsMouse
                            ? "#168cff"
                            : "#0a84ff"

                        Text {
                            anchors.centerIn: parent

                            text: "Turn Wi-Fi On"
                            color: "#ffffff"

                            font.pixelSize: 12
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

                    color: "#8f949f"

                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    font.capitalization:
                        Font.AllUppercase
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 86

                    radius: 16
                    color: "#22252c"

                    border.width: 1
                    border.color: "#3b404a"

                    RowLayout {
                        anchors {
                            fill: parent
                            margins: 14
                        }

                        spacing: 13

                        Rectangle {
                            Layout.preferredWidth: 50
                            Layout.preferredHeight: 50

                            radius: 15
                            color: "#0a84ff"

                            Text {
                                anchors.centerIn: parent

                                text:
                                    root.signalIcon(
                                        network.signalStrength
                                    )

                                color: "#ffffff"
                                font.pixelSize: 25
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

                                color: "#f5f5f7"

                                font.pixelSize: 15
                                font.weight:
                                    Font.DemiBold

                                elide: Text.ElideRight
                            }

                            Text {
                                text:
                                    network.signalPercentage
                                    + "% signal"

                                color: "#9ba0aa"
                                font.pixelSize: 11
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 8
                            Layout.preferredHeight: 8

                            radius: 4
                            color: "#30d158"
                        }
                    }
                }
            }

            // DispanelSurfaceconnected notice
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 62

                visible:
                    network.available
                    && network.wifiEnabled
                    && !network.connected

                radius: 14
                color: "#202329"

                border.width: 1
                border.color: "#30343d"

                RowLayout {
                    anchors {
                        fill: parent
                        margins: 13
                    }

                    spacing: 12

                    Rectangle {
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36

                        radius: 11
                        color: "#2b2f37"

                        Text {
                            anchors.centerIn: parent

                            text: "󰤯"
                            color: "#ff9f0a"
                            font.pixelSize: 20
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: "Not connected"
                            color: "#f1f2f4"

                            font.pixelSize: 13
                            font.weight:
                                Font.DemiBold
                        }

                        Text {
                            text:
                                "Choose a network below"

                            color: "#8f949f"
                            font.pixelSize: 10
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

                    color: "#8f949f"

                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    font.capitalization:
                        Font.AllUppercase
                }

                Rectangle {
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30

                    radius: 9

                    color: refreshMouse.containsMouse
                        ? "#343740"
                        : "#25282f"

                    opacity:
                        root.refreshing
                            ? 0.65
                            : 1

                    Text {
                        anchors.centerIn: parent

                        text: "󰑓"
                        color: "#d8dae0"
                        font.pixelSize: 15

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

                radius: 16
                color: "#202329"

                border.width: 1
                border.color: "#30343d"

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

                        radius: 11

                        color:
                            networkMouse.pressed
                                ? "#363a43"
                                : networkMouse.containsMouse
                                    ? "#2d3038"
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

                                radius: 11

                                color:
                                    networkDelegate.isConnected
                                        ? "#0a84ff"
                                        : "#2d3139"

                                Text {
                                    anchors.centerIn: parent

                                    text:
                                        root.signalIcon(
                                            networkDelegate.strength
                                        )

                                    color:
                                        networkDelegate.isConnected
                                            ? "#ffffff"
                                            : "#d7d9de"

                                    font.pixelSize: 19
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

                                    color: "#f2f3f5"

                                    font.pixelSize: 13
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
                                            ? "#30d158"
                                            : "#858b96"

                                    font.pixelSize: 10
                                }
                            }

                            Text {
                                visible:
                                  networkDelegate.isConnected
                                  && !networkDelegate.isChanging

                                text: "✓"
                                color: "#30d158"

                                font.pixelSize: 15
                                font.weight: Font.Bold
                            }

                            Rectangle {
                              Layout.preferredWidth: 28
                              Layout.preferredHeight: 28

                              visible:
                                  networkDelegate.isKnown
                                  && !networkDelegate.isConnected
                                  && !networkDelegate.isChanging

                              z: 5
                              radius: 9

                              color:
                                  networkMenuMouse.containsMouse
                                      ? "#424650"
                                      : "transparent"

                              Text {
                                  anchors.centerIn: parent

                                  text: "•••"
                                  color: "#9ca1ac"
                                  font.pixelSize: 12
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
                              color: "#777d88"
                              font.pixelSize: 22
                          }

                            Text {
                                visible: networkDelegate.isChanging

                                text: "󰑓"
                                color: "#0a84ff"
                                font.pixelSize: 15

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

                        color: "#777d88"
                        font.pixelSize: 24

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

                        color: "#858b96"
                        font.pixelSize: 11
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

                    color: "#737984"
                    font.pixelSize: 10
                }

                Text {
                    text:
                        root.refreshing
                            ? "Scanning…"
                            : "Scanning while open"

                    color: "#737984"
                    font.pixelSize: 10
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
            radius: 9

            color: closeMouse.containsMouse
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
                cursorShape: Qt.PointingHandCursor

                onClicked:
                    root.closeRequested()
            }
          }
        


        Rectangle {
                    anchors.fill: parent
                    z: 50

                    visible: root.passwordPromptVisible

                    radius: panelSurface.radius
                    color: "#b8000000"

                    MouseArea {
                        anchors.fill: parent
                    }

                    Rectangle {
                        anchors.centerIn: parent

                        width: parent.width - 40
                        height: 245

                        radius: 20
                        color: "#23262d"

                        border.width: 1
                        border.color: "#3b404a"

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
                                        color: "#f5f5f7"

                                        font.pixelSize: 17
                                        font.weight: Font.DemiBold
                                    }

                                    Text {
                                        Layout.fillWidth: true

                                        text:
                                            root.selectedNetwork
                                                ? root.selectedNetwork.name
                                                : ""

                                        color: "#9ba0aa"
                                        font.pixelSize: 11
                                        elide: Text.ElideRight
                                    }
                                }

                                Rectangle {
                                    Layout.preferredWidth: 28
                                    Layout.preferredHeight: 28

                                    radius: 9

                                    color: passwordCloseMouse.containsMouse
                                        ? "#3b3f48"
                                        : "#30333a"

                                    Text {
                                        anchors.centerIn: parent

                                        text: "×"
                                        color: "#d8dae0"
                                        font.pixelSize: 18
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

                                radius: 11

                                color: "#191b20"

                                border.width: passwordField.activeFocus
                                    ? 1
                                    : 0

                                border.color: "#0a84ff"

                                TextInput {
                                    id: passwordField

                                    anchors {
                                        fill: parent
                                        leftMargin: 13
                                        rightMargin: 44
                                    }

                                    verticalAlignment:
                                        TextInput.AlignVCenter

                                    color: "#f5f5f7"
                                    selectionColor: "#0a84ff"

                                    font.pixelSize: 13

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
                                    color: "#6f7580"
                                    font.pixelSize: 13
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

                                    color: "#a5a9b2"
                                    font.pixelSize: 17

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
                                color: "#ff453a"

                                font.pixelSize: 11
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

                                    radius: 10
                                    color: cancelMouse.containsMouse
                                        ? "#393d46"
                                        : "#30333a"

                                    Text {
                                        anchors.centerIn: parent

                                        text: "Cancel"
                                        color: "#e0e1e4"

                                        font.pixelSize: 12
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

                                              radius: 10

                                              enabled:
                                                  passwordField.text.length >= 8
                                                  && !root.connectingWithPassword

                                        opacity: enabled ? 1 : 0.45

                                        color:
                                            connectMouse.containsMouse
                                            && connectButton.enabled
                                                ? "#168cff"
                                                : "#0a84ff"

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

                                              color: "#ffffff"

                                              font.pixelSize: 12
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


                Rectangle {
                anchors.fill: parent
                z: 60

                visible: root.forgetPromptVisible

                radius: panelSurface.radius
                color: "#b8000000"

                MouseArea {
                    anchors.fill: parent
                }

                Rectangle {
                    anchors.centerIn: parent

                    width: parent.width - 52
                    height: 205

                    radius: 20
                    color: "#23262d"

                    border.width: 1
                    border.color: "#3b404a"

                    ColumnLayout {
                        anchors {
                            fill: parent
                            margins: 20
                        }

                        spacing: 10

                        Text {
                            Layout.fillWidth: true

                            text: "Forget This Network?"
                            color: "#f5f5f7"

                            horizontalAlignment: Text.AlignHCenter

                            font.pixelSize: 17
                            font.weight: Font.DemiBold
                        }

                        Text {
                            Layout.fillWidth: true

                            text:
                                root.forgetNetwork
                                    ? root.forgetNetwork.name
                                    : ""

                            color: "#c3c6cc"

                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight

                            font.pixelSize: 13
                            font.weight: Font.Medium
                        }

                        Text {
                            Layout.fillWidth: true

                            text:
                                "The saved password and connection settings will be removed."

                            color: "#8f949f"

                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap

                            font.pixelSize: 11
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

                                radius: 10

                                color:
                                    forgetCancelMouse.containsMouse
                                        ? "#393d46"
                                        : "#30333a"

                                Text {
                                    anchors.centerIn: parent

                                    text: "Cancel"
                                    color: "#e0e1e4"

                                    font.pixelSize: 12
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

                              radius: 10

                                          color:
                                              forgetConfirmMouse.containsMouse
                                                  ? "#ff5a52"
                                                  : "#ff453a"

                                          Text {
                                              anchors.centerIn: parent

                                              text: "Forget"
                                              color: "#ffffff"

                                          font.pixelSize: 12
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
                            && !root.passwordPromptVisible
                            && root.connectionError.length === 0) {
                        root.selectedNetwork = null
                    }
                }
            }
}
