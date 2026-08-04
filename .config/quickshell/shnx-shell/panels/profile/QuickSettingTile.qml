import QtQuick

Rectangle {
    id: root

    property string iconText: ""
    property string title: ""
    property string subtitle: ""

    property bool active: false
    property bool available: true
    property bool showDetailButton: false

    signal toggled()
    signal detailRequested()

    implicitWidth: 200
    implicitHeight: 74

    radius: 16

    color: {
        if (!available)
            return "#171b21"

        if (mouseArea.pressed)
            return active
                ? "#4b596b"
                : "#303945"

        if (mouseArea.containsMouse)
            return active
                ? "#414e5f"
                : "#2a323d"

        return active
            ? "#374352"
            : "#222932"
    }

    border.width: 1

    border.color: {
        if (!available)
            return "#1c222a"

        if (active)
            return "#607187"

        return mouseArea.containsMouse
            ? "#465464"
            : "#303a46"
    }

    opacity:
        available
            ? 1.0
            : 0.48

    Behavior on color {
        ColorAnimation {
            duration: 130
        }
    }

    Behavior on border.color {
        ColorAnimation {
            duration: 130
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: 90
        }
    }

    scale:
        mouseArea.pressed
            ? 0.98
            : 1.0

    Row {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 10

        spacing: 11

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter

            width: 42
            height: 42
            radius: width / 2

            color:
                root.active
                    ? "#dbe4ee"
                    : "#303945"

            Text {
                anchors.centerIn: parent

                text: root.iconText

                color:
                    root.active
                        ? "#222a33"
                        : "#d9e0e8"

                font.pixelSize: 19
                font.family: "JetBrainsMono Nerd Font"
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter

            width:
                parent.width
                - 42
                - detailButton.width
                - parent.spacing * 2
                - 24

            spacing: 4

            Text {
                width: parent.width

                text: root.title
                color: "#edf1f5"

                font.pixelSize: 13
                font.weight: Font.DemiBold

                elide: Text.ElideRight
            }

            Text {
                width: parent.width

                text: root.subtitle
                color: "#929eac"

                font.pixelSize: 10

                elide: Text.ElideRight
            }
        }

        Item {
          id: detailButton
            
            z:2

            anchors.verticalCenter: parent.verticalCenter

            width:
                root.showDetailButton
                    ? 26
                    : 0

            height: 32
            visible: root.showDetailButton

            Text {
                anchors.centerIn: parent

                text: "›"
                color: "#aeb8c5"

                font.pixelSize: 19
                font.weight: Font.Medium
            }

            MouseArea {
              anchors.fill: parent

                z: 2

                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: function(mouse) {
                    mouse.accepted = true
                    root.detailRequested()
                }
            }
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent

        z:0

        enabled: root.available
        hoverEnabled: true

        cursorShape:
            enabled
                ? Qt.PointingHandCursor
                : Qt.ArrowCursor

        onClicked: {
            root.toggled()
        }
    }
}
