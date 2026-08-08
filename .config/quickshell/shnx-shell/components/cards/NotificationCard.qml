import QtQuick
import qs.core as Core
import "../../theme" as ShellTheme

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

    radius: ShellTheme.Theme.radius.card

    color: unread
        ? ShellTheme.Theme.colors.surfaceContainerHigh
        : cardMouseArea.containsMouse
            ? ShellTheme.Theme.colors.hoverOverlay
            : ShellTheme.Theme.colors.surfaceContainer

    border.width: 1
    border.color: unread
        ? ShellTheme.Theme.colors.primary
        : cardMouseArea.containsMouse
            ? ShellTheme.Theme.colors.outline
            : ShellTheme.Theme.colors.outlineVariant

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

                radius: ShellTheme.Theme.radius.button

                color: ShellTheme.Theme.colors.surfaceContainerHigh

                border.width: 1
                border.color: ShellTheme.Theme.colors.outlineVariant

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

                    color: ShellTheme.Theme.colors.on_surface

                    font.pixelSize: ShellTheme.Theme.typography.titleSmall
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

                    color: ShellTheme.Theme.colors.on_surface_variant
                    elide: Text.ElideRight

                    font.pixelSize: ShellTheme.Theme.typography.labelSmall
                    font.weight: Font.DemiBold
                }

                Text {
                    width: parent.width

                    text:
                        root.notification.summary
                        || "Notification"

                    color: ShellTheme.Theme.colors.on_surface
                    elide: Text.ElideRight

                    font.pixelSize: ShellTheme.Theme.typography.bodySmall
                    font.weight: Font.DemiBold
                }
            }

            Rectangle {
                id: dismissButton

                width: 30
                height: 30

                anchors.verticalCenter:
                    parent.verticalCenter

                radius: ShellTheme.Theme.radius.button

                color: dismissMouseArea.pressed
                    ? ShellTheme.Theme.colors.errorContainer
                    : dismissMouseArea.containsMouse
                        ? ShellTheme.Theme.colors.errorContainer
                        : "transparent"

                border.width:
                    dismissMouseArea.containsMouse
                        ? 1
                        : 0

                border.color: ShellTheme.Theme.colors.error

                Text {
                    anchors.centerIn: parent

                    text: "󰅖"
                    color: ShellTheme.Theme.colors.error

                    font.pixelSize: ShellTheme.Theme.typography.bodySmall
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

            color: ShellTheme.Theme.colors.on_surface_variant

            wrapMode: Text.Wrap
            maximumLineCount: 4
            elide: Text.ElideRight

            // The service does not advertise markup support,
            // so render notification bodies as plain text.
            textFormat: Text.PlainText

            font.pixelSize: ShellTheme.Theme.typography.labelMedium
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

                    radius: ShellTheme.Theme.radius.button

                    color: actionMouseArea.pressed
                        ? ShellTheme.Theme.colors.primaryHover
                        : actionMouseArea.containsMouse
                            ? ShellTheme.Theme.colors.primaryHover
                            : ShellTheme.Theme.colors.primary

                    border.width: 1
                    border.color:
                        actionMouseArea.containsMouse
                            ? ShellTheme.Theme.colors.outline
                            : ShellTheme.Theme.colors.outlineVariant

                    Text {
                        id: actionLabel

                        anchors.centerIn: parent

                        text:
                            actionButton.modelData.text
                            || "Open"

                        color: ShellTheme.Theme.colors.on_primary

                        font.pixelSize: ShellTheme.Theme.typography.labelSmall
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
