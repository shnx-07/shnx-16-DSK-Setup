import QtQuick
import QtQuick.Layouts

import qs.theme as ShellTheme
import qs.motion as Motion
import qs.components.visual as Visual

Rectangle {
    id: root

    property string selectedCategory:
        "All"

    signal categorySelected(string category)

    implicitWidth:
        146

    implicitHeight:
        contentColumn.implicitHeight
        + ShellTheme.Theme.spacing.small * 2

    antialiasing:
        false

    radius:
        ShellTheme.Theme.radius.card

    color:
        ShellTheme.Theme.colors.surfaceContainer

    border.width:
        0

    readonly property var categories: [
        {
            name: "All",
            icon: "󰀻"
        },
        {
            name: "Internet",
            icon: "󰖟"
        },
        {
            name: "Development",
            icon: "󰅩"
        },
        {
            name: "Multimedia",
            icon: "󰎈"
        },
        {
            name: "Graphics",
            icon: "󰏘"
        },
        {
            name: "Office",
            icon: "󰈙"
        },
        {
            name: "System",
            icon: "󰒓"
        },
        {
            name: "Utilities",
            icon: "󰘳"
        }
    ]

    ColumnLayout {
        id: contentColumn

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top

            margins:
                ShellTheme.Theme.spacing.small
        }

        spacing:
            ShellTheme.Theme.spacing.xSmall

        Text {
            Layout.fillWidth:
                true

            Layout.leftMargin:
                ShellTheme.Theme.spacing.xSmall

            Layout.preferredHeight:
                24

            text:
                "CATEGORIES"

            color:
                ShellTheme.Theme.colors.on_surface_variant

            font.family:
                ShellTheme.Theme.typography.fontFamily

            font.pixelSize:
                ShellTheme.Theme.typography.labelSmall

            font.weight:
                Font.DemiBold

            font.letterSpacing:
                1.0

            verticalAlignment:
                Text.AlignVCenter
        }

        Repeater {
            model:
                root.categories

            CategoryButton {
                required property var modelData

                Layout.fillWidth:
                    true

                iconText:
                    modelData.icon

                labelText:
                    modelData.name

                selected:
                    root.selectedCategory
                    === modelData.name

                onClicked: {
                    root.selectedCategory =
                        modelData.name

                    root.categorySelected(
                        modelData.name
                    )
                }
            }
        }
    }

    component CategoryButton: Item {
        id: buttonRoot

        property string iconText:
            ""

        property string labelText:
            ""

        property bool selected:
            false

        signal clicked()

        implicitHeight:
            44

        scale:
            buttonMouseArea.pressed
                ? Motion.MotionTokens.compactPressScale
                : buttonMouseArea.containsMouse
                    ? Motion.MotionTokens.hoverScale
                    : 1.0

        Behavior on scale {
            NumberAnimation {
                duration:
                    Motion.MotionTokens.quick

                easing.type:
                    Motion.Easing.standard
            }
        }

        Rectangle {
            anchors.fill:
                parent

            antialiasing:
                false

            radius:
                ShellTheme.Theme.radius.button

            color: {
                if (buttonMouseArea.pressed) {
                    return buttonRoot.selected
                        ? ShellTheme.Theme.colors.primaryHover
                        : ShellTheme.Theme.colors.pressedOverlay
                }

                if (buttonMouseArea.containsMouse) {
                    return buttonRoot.selected
                        ? ShellTheme.Theme.colors.primaryHover
                        : ShellTheme.Theme.colors.hoverOverlay
                }

                return buttonRoot.selected
                    ? ShellTheme.Theme.colors.primary
                    : "transparent"
            }

            border.width:
                0

            Behavior on color {
                ColorAnimation {
                    duration:
                        Motion.MotionTokens.quick

                    easing.type:
                        Motion.Easing.standard
                }
            }
        }

        Row {
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter

                leftMargin:
                    ShellTheme.Theme.spacing.small

                rightMargin:
                    ShellTheme.Theme.spacing.small
            }

            spacing:
                ShellTheme.Theme.spacing.small

            Rectangle {
                anchors.verticalCenter:
                    parent.verticalCenter

                width:
                    30

                height:
                    30

                antialiasing:
                    false

                radius:
                    ShellTheme.Theme.radius.button

                color:
                    buttonRoot.selected
                        ? ShellTheme.Theme.colors.on_primary
                        : ShellTheme.Theme.colors.surfaceContainerHigh

                Visual.Icon {
                    anchors.centerIn:
                        parent

                    glyph:
                        buttonRoot.iconText

                    iconSize:
                        15

                    color:
                        buttonRoot.selected
                            ? ShellTheme.Theme.colors.primary
                            : ShellTheme.Theme.colors.on_surface_variant
                }
            }

            Text {
                anchors.verticalCenter:
                    parent.verticalCenter

                width:
                    Math.max(
                        0,
                        parent.width - 48
                    )

                text:
                    buttonRoot.labelText

                color:
                    buttonRoot.selected
                        ? ShellTheme.Theme.colors.on_primary
                        : ShellTheme.Theme.colors.on_surface

                font.family:
                    ShellTheme.Theme.typography.fontFamily

                font.pixelSize:
                    ShellTheme.Theme.typography.labelSmall

                font.weight:
                    buttonRoot.selected
                        ? Font.DemiBold
                        : Font.Medium

                elide:
                    Text.ElideRight
            }
        }

        MouseArea {
            id: buttonMouseArea

            anchors.fill:
                parent

            hoverEnabled:
                true

            cursorShape:
                Qt.PointingHandCursor

            onClicked:
                buttonRoot.clicked()
        }
    }
}
