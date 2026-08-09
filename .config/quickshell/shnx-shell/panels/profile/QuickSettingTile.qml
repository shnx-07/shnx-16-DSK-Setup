import QtQuick

import qs.theme as ShellTheme

import "../../components/buttons" as Buttons
import "../../components/visual" as Visual
import "../../motion" as Motion

Item {
    id: root

    signal toggled()
    signal detailRequested()

    property string iconText: ""
    property string title: ""
    property string subtitle: ""

    property bool active: false
    property bool available: true
    property bool showDetailButton: false

    implicitWidth: 210
    implicitHeight: 66

    readonly property bool hovered:
        tileMouseArea.containsMouse

    opacity:
        root.available
            ? 1.0
            : 0.42

    Behavior on opacity {
        NumberAnimation {
            duration:
                Motion.MotionTokens.quick

            easing.type:
                Motion.Easing.standard
        }
    }

    Rectangle {
        id: background

        anchors.fill: parent

        radius:
            ShellTheme.Theme.radius.control

        color: {
            if (!root.available)
                return ShellTheme.Theme.colors.surfaceContainerLowest

            if (root.active)
                return ShellTheme.Theme.colors.primaryContainer

            if (root.hovered)
                return ShellTheme.Theme.colors.surfaceContainerHigh

            return ShellTheme.Theme.colors.surfaceContainer
        }

        border.width: 1

        border.color: {
            if (root.active)
                return ShellTheme.Theme.colors.primary

            if (root.hovered)
                return ShellTheme.Theme.colors.outline

            return ShellTheme.Theme.colors.outlineVariant
        }

        Behavior on color {
            ColorAnimation {
                duration:
                    Motion.MotionTokens.quick

                easing.type:
                    Motion.Easing.standard
            }
        }

        Behavior on border.color {
            ColorAnimation {
                duration:
                    Motion.MotionTokens.quick

                easing.type:
                    Motion.Easing.standard
            }
        }

        Row {
            anchors {
                fill: parent
                margins:
                    ShellTheme.Theme.spacing.medium
            }

            spacing:
                ShellTheme.Theme.spacing.medium

            Visual.Icon {
                id: icon

                anchors.verticalCenter:
                    parent.verticalCenter

                glyph:
                    root.iconText

                iconSize: 21

                color:
                    root.active
                        ? ShellTheme.Theme.colors.on_primary_container
                        : ShellTheme.Theme.colors.on_surface
            }

            Column {
                width:
                    Math.max(
                        0,
                        parent.width
                        - icon.width
                        - detailButton.width
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
                        root.title

                    color:
                        root.active
                            ? ShellTheme.Theme.colors.on_primary_container
                            : ShellTheme.Theme.colors.on_surface

                    font.family:
                        ShellTheme.Theme.typography.fontFamily

                    font.pixelSize:
                        ShellTheme.Theme.typography.bodySmall

                    font.weight:
                        Font.DemiBold

                    elide:
                        Text.ElideRight
                }

                Text {
                    width:
                        parent.width

                    visible:
                        root.subtitle.length > 0

                    text:
                        root.subtitle

                    color:
                        root.active
                            ? ShellTheme.Theme.colors.on_primary_container
                            : ShellTheme.Theme.colors.on_surface_variant

                    font.family:
                        ShellTheme.Theme.typography.fontFamily

                    font.pixelSize:
                        ShellTheme.Theme.typography.labelSmall

                    elide:
                        Text.ElideRight
                }
            }

            Buttons.IconButton {
                id: detailButton

                anchors.verticalCenter:
                    parent.verticalCenter

                visible:
                    root.showDetailButton

                buttonSize: 28
                iconSize: 14

                glyph:
                    "󰅂"

                iconColor:
                    root.active
                        ? ShellTheme.Theme.colors.on_primary_container
                        : ShellTheme.Theme.colors.on_surface_variant

                tooltipText:
                    "Details"

                onClicked:
                    root.detailRequested()
            }
        }
    }

    MouseArea {
        id: tileMouseArea

        anchors.fill: parent

        enabled:
            root.available

        hoverEnabled: true

        acceptedButtons:
            Qt.LeftButton

        cursorShape:
            root.available
                ? Qt.PointingHandCursor
                : Qt.ArrowCursor

        onClicked: {
            root.toggled()
        }
    }
}
