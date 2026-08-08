import QtQuick
import qs.core as Core
import QtQuick.Controls
import QtQuick.Layouts
import qs.theme as ShellTheme

import "../../components/cards" as Cards

Rectangle {
    id: root

    signal closeRequested()

    readonly property var notificationService:
        Core.ServiceRegistry.notifications

    color: ShellTheme.Theme.colors.background
    radius: ShellTheme.Theme.radius.card

    border.width: 1
    border.color: ShellTheme.Theme.colors.outlineVariant

    Item {
        id: header

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        anchors.leftMargin: 16
        anchors.rightMargin: 16
        anchors.topMargin: 14

        height: 34

        RowLayout {
          anchors.fill: parent
          spacing: 8

          Text {
              text: "Notifications"
              color: ShellTheme.Theme.colors.on_surface

              font.pixelSize: ShellTheme.Theme.typography.titleMedium
              font.weight: Font.DemiBold
          }

          Rectangle {
              visible:
                  notificationService.notificationCount > 0

              implicitWidth:
                  countLabel.implicitWidth + 12

              implicitHeight: 20

              radius: ShellTheme.Theme.radius.button
              color: ShellTheme.Theme.colors.surfaceContainerHigh

              border.width: 1
              border.color: ShellTheme.Theme.colors.outlineVariant

              Text {
                  id: countLabel

                  anchors.centerIn: parent

                  text:
                      notificationService.notificationCount

                  color: ShellTheme.Theme.colors.on_surface_variant

                  font.pixelSize: ShellTheme.Theme.typography.labelSmall
                  font.weight: Font.DemiBold
              }
          }

          Item {
              Layout.fillWidth: true
          }

          Rectangle {
              id: dndButton

              implicitWidth: 32
              implicitHeight: 30

              radius: ShellTheme.Theme.radius.button

              color:
                  notificationService.doNotDisturb
                  ? ShellTheme.Theme.colors.primary
                  : dndMouseArea.pressed
                      ? ShellTheme.Theme.colors.pressedOverlay
                      : dndMouseArea.containsMouse
                          ? ShellTheme.Theme.colors.hoverOverlay
                          : ShellTheme.Theme.colors.surfaceContainer

              border.width: 1

              border.color:
                  notificationService.doNotDisturb
                  ? ShellTheme.Theme.colors.outline
                  : ShellTheme.Theme.colors.outlineVariant

              Text {
                  anchors.centerIn: parent

                  text:
                      notificationService.doNotDisturb
                      ? "󰂛"
                      : "󰂚"

                  color:
                      notificationService.doNotDisturb
                      ? ShellTheme.Theme.colors.on_primary
                      : ShellTheme.Theme.colors.on_surface
                  font.pixelSize: ShellTheme.Theme.typography.titleSmall
              }

              MouseArea {
                  id: dndMouseArea

                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor

                  onClicked:
                      notificationService
                          .toggleDoNotDisturb()
              }
          }

          Rectangle {
              id: clearButton

              implicitWidth: 32
              implicitHeight: 30

              enabled:
                  notificationService
                      .notificationCount > 0

              opacity: enabled ? 1 : 0.35
              radius: ShellTheme.Theme.radius.button

              color: clearMouseArea.pressed
                  ? ShellTheme.Theme.colors.pressedOverlay
                  : clearMouseArea.containsMouse
                      ? ShellTheme.Theme.colors.hoverOverlay
                      : ShellTheme.Theme.colors.surfaceContainer

              border.width: 1
              border.color: ShellTheme.Theme.colors.outlineVariant

              Text {
                  anchors.centerIn: parent

                  text: "󰆴"
                  color: ShellTheme.Theme.colors.on_surface

                  font.pixelSize: ShellTheme.Theme.typography.titleSmall
              }

              MouseArea {
                  id: clearMouseArea

                  anchors.fill: parent
                  enabled: clearButton.enabled
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor

                  onClicked:
                      notificationService.clearAll()
              }
          }

          Rectangle {
              id: closeButton

              implicitWidth: 32
              implicitHeight: 30

              radius: ShellTheme.Theme.radius.button

              color: closeMouseArea.pressed
                  ? ShellTheme.Theme.colors.pressedOverlay
                  : closeMouseArea.containsMouse
                      ? ShellTheme.Theme.colors.hoverOverlay
                      : ShellTheme.Theme.colors.surfaceContainer

              border.width: 1
              border.color: ShellTheme.Theme.colors.outlineVariant

              Text {
                  anchors.centerIn: parent

                  text: "󰅖"
                  color: ShellTheme.Theme.colors.on_surface

                  font.pixelSize: ShellTheme.Theme.typography.titleSmall
              }

              MouseArea {
                  id: closeMouseArea

                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor

                  onClicked:
                      root.closeRequested()
              }
          }
      } 
    }

    Rectangle {
        id: divider

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: header.bottom

        anchors.leftMargin: 16
        anchors.rightMargin: 16
        anchors.topMargin: 10

        height: 1
        color: ShellTheme.Theme.colors.outlineVariant
    }

    EmptyNotifications {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: divider.bottom
        anchors.bottom: parent.bottom

        visible:
            notificationService
                .notificationCount === 0
    }

    ListView {
        id: notificationList

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: divider.bottom
        anchors.bottom: parent.bottom

        anchors.leftMargin: 12
        anchors.rightMargin: 12
        anchors.topMargin: 12
        anchors.bottomMargin: 12

        visible:
            notificationService
                .notificationCount > 0

        clip: true
        spacing: 9

        model:
            notificationService.notifications

        boundsBehavior:
            Flickable.StopAtBounds

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
        }

        delegate: Cards.NotificationCard {
            required property var modelData

            width: notificationList.width

            notification: modelData
        }
    }
}
