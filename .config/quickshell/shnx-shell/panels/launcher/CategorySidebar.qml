import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string selectedCategory: "All"

    signal categorySelected(string category)

    implicitWidth: 154
    implicitHeight: 520

    radius: 18
    color: "#a91b2027"

    border.width: 1
    border.color: "#1e2934"

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
            color: "#7f8b9b"

            font.pixelSize: 10
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
        radius: 14

        color: {
            if (buttonMouseArea.pressed)
                return selected
                    ? "#465465"
                    : "#303945"

            if (buttonMouseArea.containsMouse)
                return selected
                    ? "#3d4a5a"
                    : "#29313b"

            return selected
                ? "#354150"
                : "transparent"
        }

        border.width:
            selected
                ? 1
                : 0

        border.color:
            selected
                ? "#596b81"
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
                        ? "#dce5ee"
                        : "#2d3540"

                Text {
                    anchors.centerIn: parent

                    text: buttonRoot.iconText

                    color:
                        buttonRoot.selected
                            ? "#252d36"
                            : "#cbd3dc"

                    font.pixelSize: 14
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
                        ? "#f0f3f6"
                        : "#aeb8c4"

                font.pixelSize: 11
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
