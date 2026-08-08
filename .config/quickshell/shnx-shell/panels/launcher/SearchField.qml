import QtQuick
import qs.theme as ShellTheme

Rectangle {
  id: root

  signal moveLeftRequested()
  signal moveRightRequested()

    property alias text: searchInput.text
    property alias placeholderText: searchInput.placeholderText

    signal submitted(string query)
    signal cleared()

    implicitWidth: 560
    implicitHeight: 52

    radius: ShellTheme.Theme.radius.card

    color:
        searchInput.activeFocus
            ? ShellTheme.Theme.colors.surfaceContainerHigh
            : ShellTheme.Theme.colors.surfaceContainer

    border.width: 1
    border.color:
        searchInput.activeFocus
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

    Row {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 12

        spacing: 11

        Text {
            anchors.verticalCenter: parent.verticalCenter

            text: "󰍉"
            color:
                searchInput.activeFocus
                    ? ShellTheme.Theme.colors.on_surface
                    : ShellTheme.Theme.colors.on_surface_variant

            font.pixelSize: ShellTheme.Theme.typography.titleSmall
            font.family: "JetBrainsMono Nerd Font"
        }

        TextInput {
            id: searchInput

            width:
                parent.width
                - clearButton.width
                - 42

            height: parent.height

            color: ShellTheme.Theme.colors.on_surface
            selectionColor: ShellTheme.Theme.colors.primary
            selectedTextColor: ShellTheme.Theme.colors.on_primary

            font.pixelSize: ShellTheme.Theme.typography.bodySmall

            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Left) {
                    root.moveLeftRequested()
                    event.accepted = true
                    return
                }

                if (event.key === Qt.Key_Right) {
                    root.moveRightRequested()
                    event.accepted = true
                }
            }

            verticalAlignment: TextInput.AlignVCenter

            clip: true
            focus: false

            property string placeholderText:
                "Search applications"

            Text {
                anchors.fill: parent

                visible:
                    searchInput.text.length === 0
                    && !searchInput.activeFocus

                text: searchInput.placeholderText
                color: ShellTheme.Theme.colors.disabled

                font.pixelSize: ShellTheme.Theme.typography.bodySmall
                verticalAlignment: Text.AlignVCenter
            }

            Keys.onReturnPressed: {
                root.submitted(text)
            }

            Keys.onEnterPressed: {
                root.submitted(text)
            }

            Keys.onEscapePressed: {
                if (text.length > 0) {
                    text = ""
                    root.cleared()
                }
            }
        }

        Item {
            id: clearButton

            anchors.verticalCenter: parent.verticalCenter

            width: 30
            height: 30

            visible:
                searchInput.text.length > 0

            Rectangle {
                anchors.fill: parent

                radius: width / 2

                color:
                    clearMouseArea.pressed
                        ? ShellTheme.Theme.colors.pressedOverlay
                        : clearMouseArea.containsMouse
                            ? ShellTheme.Theme.colors.hoverOverlay
                            : "transparent"
            }

            Text {
                anchors.centerIn: parent

                text: "󰅖"
                color: ShellTheme.Theme.colors.on_surface_variant

                font.pixelSize: ShellTheme.Theme.typography.bodySmall
                font.family: "JetBrainsMono Nerd Font"
            }

            MouseArea {
                id: clearMouseArea

                anchors.fill: parent

                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    searchInput.text = ""
                    searchInput.forceActiveFocus()
                    root.cleared()
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        z: -1

        onClicked: {
            searchInput.forceActiveFocus()
        }
    }

    function activate() {
        searchInput.forceActiveFocus()
        searchInput.selectAll()
    }

    function clear() {
        searchInput.text = ""
        root.cleared()
    }
}
