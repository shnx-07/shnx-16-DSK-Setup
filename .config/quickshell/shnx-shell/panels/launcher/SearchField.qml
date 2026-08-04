import QtQuick

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

    radius: 16

    color:
        searchInput.activeFocus
            ? "#29323d"
            : "#222932"

    border.width: 1
    border.color:
        searchInput.activeFocus
            ? "#59697b"
            : "#303b48"

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
                    ? "#dce4ec"
                    : "#8793a3"

            font.pixelSize: 17
            font.family: "JetBrainsMono Nerd Font"
        }

        TextInput {
            id: searchInput

            width:
                parent.width
                - clearButton.width
                - 42

            height: parent.height

            color: "#edf1f5"
            selectionColor: "#53667a"
            selectedTextColor: "#ffffff"

            font.pixelSize: 13

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
                color: "#737f8e"

                font.pixelSize: 13
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
                        ? "#3d4856"
                        : clearMouseArea.containsMouse
                            ? "#343f4c"
                            : "transparent"
            }

            Text {
                anchors.centerIn: parent

                text: "󰅖"
                color: "#aeb8c5"

                font.pixelSize: 13
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
