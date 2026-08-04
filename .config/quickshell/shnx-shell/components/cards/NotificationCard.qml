import QtQuick
import qs.core as Core

Rectangle {
    id: root

    required property var notification

    readonly property var notificationService:
        Core.ServiceRegistry.notifications

    readonly property bool unread:
        notification
        && notificationService.isUnread(
            notification.id
        )

    readonly property bool hasImage:
        notification
        && notification.image
        && notification.image.length > 0

    readonly property bool hasBody:
        notification
        && notification.body
        && notification.body.length > 0

    readonly property bool hasActions:
        notification
        && notification.actions
        && notification.actions.length > 0

    implicitHeight: contentColumn.implicitHeight + 28

    radius: 14

    color: unread
        ? "#252d3a"
        : cardMouseArea.containsMouse
            ? "#23272f"
            : "#1f232a"

    border.width: 1
    border.color: unread
        ? "#566b8d"
        : cardMouseArea.containsMouse
            ? "#4d5563"
            : "#343a45"

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

    MouseArea {
        id: cardMouseArea

        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }

    Column {
        id: contentColumn

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        anchors.margins: 14
        spacing: 11

        Row {
            width: parent.width
            spacing: 11

            Rectangle {
                width: 38
                height: 38

                radius: 11

                color: "#2d323c"

                border.width: 1
                border.color: "#414855"

                Image {
                    anchors.fill: parent
                    anchors.margins: 5

                    visible: root.hasImage

                    source: root.hasImage
                        ? root.notification.image
                        : ""

                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: true

                    sourceSize.width: 64
                    sourceSize.height: 64
                }

                Text {
                    anchors.centerIn: parent

                    visible: !root.hasImage

                    text: {
                        const appName =
                            root.notification
                                .appName || "?"

                        return appName.length > 0
                            ? appName
                                .charAt(0)
                                .toUpperCase()
                            : "?"
                    }

                    color: "#f2f3f5"

                    font.pixelSize: 15
                    font.weight: Font.Bold
                }
            }

            Column {
                width:
                    parent.width
                    - 38
                    - dismissButton.width
                    - parent.spacing * 2

                anchors.verticalCenter:
                    parent.verticalCenter

                spacing: 3

                Text {
                    width: parent.width

                    text:
                        root.notification.appName
                        || "Application"

                    color: "#9da4af"
                    elide: Text.ElideRight

                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                }

                Text {
                    width: parent.width

                    text:
                        root.notification.summary
                        || "Notification"

                    color: "#f2f3f5"
                    elide: Text.ElideRight

                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                }
            }

            Rectangle {
                id: dismissButton

                width: 30
                height: 30

                anchors.verticalCenter:
                    parent.verticalCenter

                radius: 9

                color: dismissMouseArea.pressed
                    ? "#493039"
                    : dismissMouseArea.containsMouse
                        ? "#382b31"
                        : "transparent"

                border.width:
                    dismissMouseArea.containsMouse
                        ? 1
                        : 0

                border.color: "#6b4650"

                Text {
                    anchors.centerIn: parent

                    text: "󰅖"
                    color: "#d6a0aa"

                    font.pixelSize: 14
                }

                MouseArea {
                    id: dismissMouseArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        root.notificationService.dismiss(
                            root.notification
                        )
                    }
                }
            }
        }

        Text {
            width: parent.width

            visible: root.hasBody

            text: root.notification.body || ""

            color: "#c3c8d0"

            wrapMode: Text.Wrap
            maximumLineCount: 4
            elide: Text.ElideRight

            // The service does not advertise markup support,
            // so render notification bodies as plain text.
            textFormat: Text.PlainText

            font.pixelSize: 12
            lineHeight: 1.15
        }

        Flow {
            width: parent.width

            visible: root.hasActions

            spacing: 7

            Repeater {
                model: root.hasActions
                    ? root.notification.actions
                    : []

                delegate: Rectangle {
                    id: actionButton

                    required property var modelData

                    implicitWidth:
                        actionLabel.implicitWidth + 20

                    implicitHeight: 30

                    radius: 9

                    color: actionMouseArea.pressed
                        ? "#3c4656"
                        : actionMouseArea.containsMouse
                            ? "#343d4b"
                            : "#2b323d"

                    border.width: 1
                    border.color:
                        actionMouseArea.containsMouse
                            ? "#68778d"
                            : "#46505f"

                    Text {
                        id: actionLabel

                        anchors.centerIn: parent

                        text:
                            actionButton.modelData.text
                            || "Open"

                        color: "#e3e6eb"

                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                    }

                    MouseArea {
                        id: actionMouseArea

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape:
                            Qt.PointingHandCursor

                        onClicked: {
                            actionButton
                                .modelData
                                .invoke()
                        }
                    }
                }
            }
        }
    }
}
