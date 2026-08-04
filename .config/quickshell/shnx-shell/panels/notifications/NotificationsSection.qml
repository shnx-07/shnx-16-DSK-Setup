import QtQuick
import qs.core as Core
import QtQuick.Controls
import QtQuick.Layouts

import "../../components/cards" as Cards

Rectangle {
    id: root

    signal closeRequested()

    readonly property var notificationService:
        Core.ServiceRegistry.notifications

    color: "#181b21"
    radius: 16

    border.width: 1
    border.color: "#343a45"

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
              color: "#f2f3f5"

              font.pixelSize: 17
              font.weight: Font.DemiBold
          }

          Rectangle {
              visible:
                  notificationService.notificationCount > 0

              implicitWidth:
                  countLabel.implicitWidth + 12

              implicitHeight: 20

              radius: 10
              color: "#292f39"

              border.width: 1
              border.color: "#414956"

              Text {
                  id: countLabel

                  anchors.centerIn: parent

                  text:
                      notificationService.notificationCount

                  color: "#aeb4bd"

                  font.pixelSize: 10
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

              radius: 9

              color:
                  notificationService.doNotDisturb
                  ? "#46566f"
                  : dndMouseArea.pressed
                      ? "#343944"
                      : dndMouseArea.containsMouse
                          ? "#2d323c"
                          : "#252932"

              border.width: 1

              border.color:
                  notificationService.doNotDisturb
                  ? "#7184a3"
                  : "#3b414d"

              Text {
                  anchors.centerIn: parent

                  text:
                      notificationService.doNotDisturb
                      ? "󰂛"
                      : "󰂚"

                  color: "#f2f3f5"
                  font.pixelSize: 16
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
              radius: 9

              color: clearMouseArea.pressed
                  ? "#343944"
                  : clearMouseArea.containsMouse
                      ? "#2d323c"
                      : "#252932"

              border.width: 1
              border.color: "#3b414d"

              Text {
                  anchors.centerIn: parent

                  text: "󰆴"
                  color: "#f2f3f5"

                  font.pixelSize: 15
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

              radius: 9

              color: closeMouseArea.pressed
                  ? "#343944"
                  : closeMouseArea.containsMouse
                      ? "#2d323c"
                      : "#252932"

              border.width: 1
              border.color: "#3b414d"

              Text {
                  anchors.centerIn: parent

                  text: "󰅖"
                  color: "#f2f3f5"

                  font.pixelSize: 15
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
        color: "#343a45"
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
