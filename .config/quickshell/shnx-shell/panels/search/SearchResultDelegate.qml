import QtQuick
import Quickshell
import qs.components.visual as Visual

Item {
    id: root

    required property var result
    property bool selected: false
    property int resultIndex: -1

    signal activated(int index, var result)
    signal hovered(int index)

    implicitHeight: 54

    Rectangle {
        anchors.fill: parent
        radius: 12
        color:
            root.selected
                ? "#292929"
                : mouseArea.containsMouse
                    ? "#202020"
                    : "transparent"
    }

    Row {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 12

        Item {
            width: 34
            height: 34
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                anchors.fill: parent
                radius: 9
                color: "#242424"
            }

            Visual.Icon {
                anchors.centerIn: parent
                iconSize: 20

                source:
                  root.result && root.result.icon
                      ? Quickshell.iconPath(String(root.result.icon))
                      : "" 
                glyph:
                    root.result && root.result.icon
                        ? ""
                        : root.fallbackGlyph()

                color: "#f2f2f2"
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter

            width:
                Math.max(
                    0,
                    parent.width - 34 - typeLabel.width - 36
                )

            spacing: 2

            Text {
                width: parent.width
                text:
                    root.result && root.result.name !== undefined
                        ? String(root.result.name)
                        : root.result && root.result.title !== undefined
                            ? String(root.result.title)
                            : ""

                color: "#f5f5f5"
                font.pixelSize: 14
                font.weight: root.selected ? Font.DemiBold : Font.Medium
                elide: Text.ElideRight
            }

            Text {
                width: parent.width
                visible: text.length > 0

                text:
                    root.result && root.result.comment !== undefined
                        ? String(root.result.comment)
                        : root.result && root.result.subtitle !== undefined
                            ? String(root.result.subtitle)
                            : ""

                color: "#969696"
                font.pixelSize: 11
                elide: Text.ElideRight
            }
        }

        Text {
            id: typeLabel
            anchors.verticalCenter: parent.verticalCenter

            text: root.typeText()
            color: root.selected ? "#d4d4d4" : "#777777"
            font.pixelSize: 10
            font.weight: Font.DemiBold
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onEntered:
            root.hovered(root.resultIndex)

        onClicked:
            root.activated(root.resultIndex, root.result)
    }

    function resultType() {
        if (!root.result)
            return "application"

        if (root.result.type !== undefined)
            return String(root.result.type)

        return "application"
    }

    function typeText() {
        switch (resultType()) {
        case "folder": return "FOLDER"
        case "file": return "FILE"
        case "image": return "IMAGE"
        case "command": return "COMMAND"
        default: return "APP"
        }
    }

    function fallbackGlyph() {
        switch (resultType()) {
        case "folder": return "󰉋"
        case "file": return "󰈔"
        case "image": return "󰋩"
        case "command": return "󰆍"
        default: return "󰀻"
        }
    }
}
