import QtQuick
import qs.core as Core

Rectangle {
    id: root

    signal clicked()

    readonly property var notificationService:
        Core.ServiceRegistry.notifications

    implicitWidth: 38
    implicitHeight: 32

    radius: 10

    color: mouseArea.pressed
        ? "#343944"
        : mouseArea.containsMouse
            ? "#2d323c"
            : "#252932"

    border.width: 1
    border.color: mouseArea.containsMouse
        ? "#596273"
        : "#3b414d"

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

    Text {
        anchors.centerIn: parent

        text: notificationService.doNotDisturb
            ? "󰂛"
            : notificationService.hasUnread
                ? "󰂚"
                : "󰂜"

        color: notificationService.hasUnread
            ? "#f2f3f5"
            : "#c9cdd4"

        font.pixelSize: 17
        font.weight: Font.DemiBold
    }

    Rectangle {
        visible: notificationService.hasUnread

        anchors.top: parent.top
        anchors.right: parent.right

        anchors.topMargin: -4
        anchors.rightMargin: -5

        implicitWidth: Math.max(
            16,
            badgeLabel.implicitWidth + 8
        )

        implicitHeight: 16

        radius: 8

        color: "#d64d59"

        border.width: 1
        border.color: "#ff8a92"

        Text {
            id: badgeLabel

            anchors.centerIn: parent

            text: notificationService.badgeText
            color: "#ffffff"

            font.pixelSize: 9
            font.weight: Font.Bold
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: root.clicked()
    }
}
