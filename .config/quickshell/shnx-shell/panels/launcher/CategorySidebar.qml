import QtQuick
import QtQuick.Layouts
import qs.theme as ShellTheme

Rectangle {
    id: root

    property string selectedCategory: "All"

    signal categorySelected(string category)

    implicitWidth: 154
    implicitHeight: 520

    radius: ShellTheme.Theme.radius.card
    color: ShellTheme.Theme.colors.surfaceContainer

    border.width: 1
    border.color: ShellTheme.Theme.colors.outlineVariant

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
        anchors.fill: parent
        anchors.margins: 10

        spacing: 8

        Text {
            Layout.fillWidth: true
            Layout.leftMargin: 6
            Layout.preferredHeight: 22

            text: "CATEGORIES"
            color: ShellTheme.Theme.colors.on_surface_variant

            font.pixelSize: ShellTheme.Theme.typography.labelSmall
            font.weight: Font.DemiBold
            font.letterSpacing: 1.2

            verticalAlignment: Text.AlignVCenter
        }

        Repeater {
            model: root.categories

            CategoryButton {
                required property var modelData

                Layout.fillWidth: true

                iconText: modelData.icon
                labelText: modelData.name

                selected:
                    root.selectedCategory === modelData.name

                onClicked: {
                    root.selectedCategory = modelData.name
                    root.categorySelected(modelData.name)
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }

    component CategoryButton: Rectangle {
        id: buttonRoot

        property string iconText: ""
        property string labelText: ""
        property bool selected: false

        signal clicked()

        implicitHeight: 48
        radius: ShellTheme.Theme.radius.button

        color: {
            if (buttonMouseArea.pressed)
                return selected
                    ? ShellTheme.Theme.colors.primaryHover
                    : ShellTheme.Theme.colors.pressedOverlay

            if (buttonMouseArea.containsMouse)
                return selected
                    ? ShellTheme.Theme.colors.primaryHover
                    : ShellTheme.Theme.colors.hoverOverlay

            return selected
                ? ShellTheme.Theme.colors.primary
                : "transparent"
        }

        border.width:
            selected
                ? 1
                : 0

        border.color:
            selected
                ? ShellTheme.Theme.colors.outline
                : "transparent"

        scale:
            buttonMouseArea.pressed
                ? 0.98
                : 1.0

        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 90
            }
        }

        Row {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 10

            spacing: 10

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter

                width: 30
                height: 30
                radius: width / 2

                color:
                    buttonRoot.selected
                        ? ShellTheme.Theme.colors.on_primary
                        : ShellTheme.Theme.colors.surfaceContainerHigh

                Text {
                    anchors.centerIn: parent

                    text: buttonRoot.iconText

                    color:
                        buttonRoot.selected
                            ? ShellTheme.Theme.colors.primary
                            : ShellTheme.Theme.colors.on_surface_variant

                    font.pixelSize: ShellTheme.Theme.typography.bodySmall
                    font.family:
                        "JetBrainsMono Nerd Font"
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter

                width: parent.width - 52

                text: buttonRoot.labelText

                color:
                    buttonRoot.selected
                        ? ShellTheme.Theme.colors.on_primary
                        : ShellTheme.Theme.colors.on_surface

                font.pixelSize: ShellTheme.Theme.typography.labelSmall
                font.weight:
                    buttonRoot.selected
                        ? Font.DemiBold
                        : Font.Medium

                elide: Text.ElideRight
            }
        }

        MouseArea {
            id: buttonMouseArea

            anchors.fill: parent

            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                buttonRoot.clicked()
            }
        }
    }
}
