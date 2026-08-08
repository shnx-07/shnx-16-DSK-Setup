import QtQuick

import "../../theme" as ShellTheme
import "../../motion" as Motion
import "../buttons" as Buttons
import "../visual" as Visual

BaseCard {
    id: root

    required property var notification

    property bool unread: false

    signal dismissRequested(var notification)
    signal actionRequested(var notification, var action)

    readonly property bool hasImage:
        root.notification
        && root.notification.image
        && root.notification.image.length > 0

    readonly property bool hasBody:
        root.notification
        && root.notification.body
        && root.notification.body.length > 0

    readonly property bool hasActions:
        root.notification
        && root.notification.actions
        && root.notification.actions.length > 0

    readonly property bool hovered:
        cardMouseArea.containsMouse

    implicitWidth: 360

    implicitHeight:
        contentColumn.implicitHeight
        + ShellTheme.Theme.spacing.medium * 2

    backgroundColor:
        root.unread
            ? ShellTheme.Theme.colors.surfaceContainerHigh
            : root.hovered
                ? ShellTheme.Theme.colors.hoverOverlay
                : ShellTheme.Theme.colors.surfaceContainer

    borderColor:
        root.unread
            ? ShellTheme.Theme.colors.primary
            : root.hovered
                ? ShellTheme.Theme.colors.outline
                : ShellTheme.Theme.colors.outlineVariant

    borderWidth: 1

    Behavior on backgroundColor {
        ColorAnimation {
            duration:
                Motion.MotionTokens.quick

            easing.type:
                Motion.Easing.standard
        }
    }

    Behavior on borderColor {
        ColorAnimation {
            duration:
                Motion.MotionTokens.quick

            easing.type:
                Motion.Easing.standard
        }
    }

    MouseArea {
        id: cardMouseArea

        anchors.fill: parent

        hoverEnabled: true

        acceptedButtons:
            Qt.NoButton
    }

    Column {
        id: contentColumn

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top

            margins:
                ShellTheme.Theme.spacing.medium
        }

        spacing:
            ShellTheme.Theme.spacing.small

        /*
         * HEADER
         */
        Row {
            width:
                parent.width

            spacing:
                ShellTheme.Theme.spacing.small

            /*
             * APPLICATION ICON
             */
            Rectangle {
                width: 38
                height: 38

                radius:
                    ShellTheme.Theme.radius.button

                color:
                    ShellTheme.Theme.colors.surfaceContainerHigh

                border.width: 1

                border.color:
                    ShellTheme.Theme.colors.outlineVariant

                clip: true

                Image {
                    anchors {
                        fill: parent
                        margins: 5
                    }

                    visible:
                        root.hasImage

                    source:
                        root.hasImage
                            ? root.notification.image
                            : ""

                    fillMode:
                        Image.PreserveAspectCrop

                    asynchronous: true
                    cache: true

                    sourceSize.width: 64
                    sourceSize.height: 64
                }

                Text {
                    anchors.centerIn:
                        parent

                    visible:
                        !root.hasImage

                    text: {
                        const appName =
                            root.notification
                            && root.notification.appName
                                ? String(root.notification.appName)
                                : "?"

                        return appName.length > 0
                            ? appName.charAt(0).toUpperCase()
                            : "?"
                    }

                    color:
                        ShellTheme.Theme.colors.on_surface

                    font.family:
                        ShellTheme.Theme.typography.fontFamily

                    font.pixelSize:
                        ShellTheme.Theme.typography.titleSmall

                    font.weight:
                        Font.Bold
                }
            }

            /*
             * APPLICATION + SUMMARY
             */
            Column {
                width:
                    Math.max(
                        0,
                        parent.width
                        - 38
                        - dismissButton.width
                        - parent.spacing * 2
                    )

                anchors.verticalCenter:
                    parent.verticalCenter

                spacing:
                    ShellTheme.Theme.spacing.xSmall

                Text {
                    width:
                        parent.width

                    text:
                        root.notification
                        && root.notification.appName
                            ? root.notification.appName
                            : "Application"

                    color:
                        ShellTheme.Theme.colors.on_surface_variant

                    elide:
                        Text.ElideRight

                    font.family:
                        ShellTheme.Theme.typography.fontFamily

                    font.pixelSize:
                        ShellTheme.Theme.typography.labelSmall

                    font.weight:
                        Font.DemiBold
                }

                Text {
                    width:
                        parent.width

                    text:
                        root.notification
                        && root.notification.summary
                            ? root.notification.summary
                            : "Notification"

                    color:
                        ShellTheme.Theme.colors.on_surface

                    elide:
                        Text.ElideRight

                    font.family:
                        ShellTheme.Theme.typography.fontFamily

                    font.pixelSize:
                        ShellTheme.Theme.typography.bodySmall

                    font.weight:
                        root.unread
                            ? Font.Bold
                            : Font.DemiBold
                }
            }

            /*
             * DISMISS
             */
            Buttons.IconButton {
                id: dismissButton

                anchors.verticalCenter:
                    parent.verticalCenter

                buttonSize: 30
                iconSize: 15

                glyph:
                    "󰅖"

                iconColor:
                    ShellTheme.Theme.colors.error

                hoverColor:
                    ShellTheme.Theme.colors.errorContainer

                pressedColor:
                    ShellTheme.Theme.colors.errorContainer

                tooltipText:
                    "Dismiss"

                onClicked:
                    root.dismissRequested(
                        root.notification
                    )
            }
        }

        /*
         * BODY
         */
        Text {
            width:
                parent.width

            visible:
                root.hasBody

            text:
                root.notification
                && root.notification.body
                    ? root.notification.body
                    : ""

            color:
                ShellTheme.Theme.colors.on_surface_variant

            wrapMode:
                Text.Wrap

            maximumLineCount: 4

            elide:
                Text.ElideRight

            textFormat:
                Text.PlainText

            font.family:
                ShellTheme.Theme.typography.fontFamily

            font.pixelSize:
                ShellTheme.Theme.typography.labelMedium

            lineHeight: 1.15
        }

        /*
         * ACTIONS
         */
        Flow {
            width:
                parent.width

            visible:
                root.hasActions

            spacing:
                ShellTheme.Theme.spacing.small

            Repeater {
                model:
                    root.hasActions
                        ? root.notification.actions
                        : []

                delegate: Buttons.PillButton {
                    required property var modelData

                    variant:
                        Buttons.PillButton.Primary

                    text:
                        modelData
                        && modelData.text
                            ? modelData.text
                            : "Open"

                    onClicked:
                        root.actionRequested(
                            root.notification,
                            modelData
                        )
                }
            }
        }
    }
}
