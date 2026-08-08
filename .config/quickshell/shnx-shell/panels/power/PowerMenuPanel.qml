import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.core as Core
import qs.theme as ShellTheme

PanelWindow {
    id: root


    property string pendingAction: ""
    property string pendingLabel: ""

    readonly property bool confirming:
        pendingAction.length > 0

    readonly property var systemService:
        Core.ServiceRegistry.system

    function requestConfirmation(action, label) {
        pendingAction = action
        pendingLabel = label
    }

    function cancelConfirmation() {
        pendingAction = ""
        pendingLabel = ""
    }

    function executePendingAction() {
        const action = pendingAction

        cancelConfirmation()
        Core.PanelController.close()

        switch (action) {
        case "logout":
            systemService.logout()
            break
        case "reboot":
            systemService.reboot()
            break
        case "shutdown":
            systemService.shutdown()
            break
        }
    }

    onVisibleChanged: {
        if (!visible)
            cancelConfirmation()
    }

    visible: Core.PanelController.powerPanelOpen

    color: "transparent"
    aboveWindows: true
    focusable: true

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    WlrLayershell.namespace: "shnx-power-menu"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus:
        WlrKeyboardFocus.Exclusive

    Item {
        id: modalRoot

        anchors.fill: parent
        focus: root.visible

        Keys.onEscapePressed: {
            if (root.confirming) {
                root.cancelConfirmation()
                return
            }

            Core.PanelController.close()
        }

        Rectangle {
            id: backdrop

            anchors.fill: parent
            color: ShellTheme.Theme.colors.scrim

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    if (root.confirming) {
                        root.cancelConfirmation()
                        return
                    }

                    Core.PanelController.close()
                }
            }
        }

        Item {
            id: powerContent

            anchors.centerIn: parent

            width: actionLayout.implicitWidth
            height: actionLayout.implicitHeight

            scale: root.visible ? 1 : 0.92
            opacity: root.visible ? 1 : 0

            Behavior on scale {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 140
                }
            }

            // Stops clicks in the space between action tiles
            // from closing the menu.
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.AllButtons

                onClicked: mouse => {
                    mouse.accepted = true
                }
            }

            Column {
                id: actionLayout

                anchors.centerIn: parent
                spacing: 18

                visible: !root.confirming

                Row {
                    anchors.horizontalCenter:
                        parent.horizontalCenter

                    spacing: 18

                    PowerAction {
                        icon: "󰌾"
                        label: "Lock"

                        onClicked: {
                            Core.PanelController.close()
                            root.systemService.lock()
                        }
                    }

                    PowerAction {
                        icon: "󰒲"
                        label: "Suspend"

                        onClicked: {
                            Core.PanelController.close()
                            root.systemService.suspend()
                        }
                    }

                    PowerAction {
                        icon: "󰍃"
                        label: "Logout"

                        onClicked:
                            root.requestConfirmation(
                                "logout",
                                "Log out"
                            )
                    }
                }

                Row {
                    anchors.horizontalCenter:
                        parent.horizontalCenter

                    spacing: 18

                    PowerAction {
                      icon: "󰜉"
                      label: "Reboot"
                      destructive: true

                      onClicked:
                          root.requestConfirmation(
                              "reboot",
                              "Restart the computer"
                          )
                  }

                  PowerAction {
                      icon: "󰐥"
                      label: "Shutdown"
                      destructive: true

                      onClicked:
                          root.requestConfirmation(
                              "shutdown",
                              "Shut down the computer"
                          )
                  }
                }
              }


              Column {
              id: confirmationLayout

              anchors.centerIn: parent
              spacing: 24

              visible: root.confirming

              Text {
                  anchors.horizontalCenter:
                      parent.horizontalCenter

                  text: root.pendingLabel + "?"
                  color: ShellTheme.Theme.colors.on_surface

                  font.pixelSize: ShellTheme.Theme.typography.headlineMedium
                  font.weight: Font.DemiBold
              }

              Text {
                  anchors.horizontalCenter:
                      parent.horizontalCenter

                  text:
                      root.pendingAction === "shutdown"
                          ? "All running applications will be closed."
                          : root.pendingAction === "reboot"
                              ? "The system will restart immediately."
                              : "Your current desktop session will end."

                  color: ShellTheme.Theme.colors.on_surface_variant
                  font.pixelSize: ShellTheme.Theme.typography.labelMedium
              }

              Row {
                  anchors.horizontalCenter:
                      parent.horizontalCenter

                  spacing: 18

                  Rectangle {
                      width: 150
                      height: 72
                      radius: ShellTheme.Theme.radius.panel

                      color: cancelMouse.pressed
                          ? ShellTheme.Theme.colors.pressedOverlay
                          : cancelMouse.containsMouse
                              ? ShellTheme.Theme.colors.hoverOverlay
                              : ShellTheme.Theme.colors.surfaceContainer

                      border.width: 1
                      border.color: ShellTheme.Theme.colors.outline

                      Text {
                          anchors.centerIn: parent

                          text: "Cancel"
                          color: ShellTheme.Theme.colors.on_surface

                          font.pixelSize: ShellTheme.Theme.typography.bodySmall
                          font.weight: Font.DemiBold
                      }

                      MouseArea {
                          id: cancelMouse

                          anchors.fill: parent
                          hoverEnabled: true
                          cursorShape: Qt.PointingHandCursor

                          onClicked:
                              root.cancelConfirmation()
                      }
                  }

                  Rectangle {
                      width: 150
                      height: 72
                      radius: ShellTheme.Theme.radius.panel

                      color: confirmMouse.pressed
                          ? ShellTheme.Theme.colors.errorContainer
                          : confirmMouse.containsMouse
                              ? ShellTheme.Theme.colors.errorContainer
                              : ShellTheme.Theme.colors.errorContainer

                      border.width: 1
                      border.color: confirmMouse.containsMouse
                          ? ShellTheme.Theme.colors.error
                          : ShellTheme.Theme.colors.errorContainer

                      Text {
                          anchors.centerIn: parent

                          text: root.pendingAction === "logout"
                              ? "Log out"
                              : root.pendingAction === "reboot"
                                  ? "Restart"
                                  : "Shut down"

                          color: ShellTheme.Theme.colors.on_error_container

                          font.pixelSize: ShellTheme.Theme.typography.bodySmall
                          font.weight: Font.DemiBold
                      }

                      MouseArea {
                          id: confirmMouse

                          anchors.fill: parent
                          hoverEnabled: true
                          cursorShape: Qt.PointingHandCursor

                          onClicked:
                              root.executePendingAction()
                      }
                  }
              }
          }

        }
    }

    component PowerAction: Rectangle {
        id: actionRoot

        required property string icon
        required property string label

        property bool destructive: false

        signal clicked()

        width: 150
        height: 112

        radius: ShellTheme.Theme.radius.panel

        color:
            actionMouseArea.pressed
            ? (
                destructive
                ? ShellTheme.Theme.colors.errorContainer
                : ShellTheme.Theme.colors.pressedOverlay
            )
            : actionMouseArea.containsMouse
                ? (
                    destructive
                    ? ShellTheme.Theme.colors.errorContainer
                    : ShellTheme.Theme.colors.hoverOverlay
                )
                : ShellTheme.Theme.colors.surfaceContainer

        border.width: 1

        border.color:
            destructive
            ? (
                actionMouseArea.containsMouse
                ? ShellTheme.Theme.colors.error
                : ShellTheme.Theme.colors.errorContainer
            )
            : (
                actionMouseArea.containsMouse
                ? ShellTheme.Theme.colors.outline
                : ShellTheme.Theme.colors.outlineVariant
            )

        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }

        Behavior on border.color {
            ColorAnimation {
                duration: 120
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 100
            }
        }

        scale:
            actionMouseArea.pressed
            ? 0.96
            : actionMouseArea.containsMouse
                ? 1.04
                : 1

        Column {
            anchors.centerIn: parent
            spacing: 10

            Text {
                anchors.horizontalCenter:
                    parent.horizontalCenter

                text: actionRoot.icon

                color:
                    actionRoot.destructive
                    ? ShellTheme.Theme.colors.error
                    : ShellTheme.Theme.colors.on_surface

                font.pixelSize: ShellTheme.Theme.typography.displaySmall
            }

            Text {
                anchors.horizontalCenter:
                    parent.horizontalCenter

                text: actionRoot.label

                color:
                    actionRoot.destructive
                    ? ShellTheme.Theme.colors.on_error_container
                    : ShellTheme.Theme.colors.on_surface

                font.pixelSize: ShellTheme.Theme.typography.bodySmall
                font.weight: Font.DemiBold
            }
        }

        MouseArea {
            id: actionMouseArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: actionRoot.clicked()
        }
    }
}
