import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string appName: ""
    property string appIcon: ""
    property string appComment: ""
    property string desktopId: ""

    property bool selected: false

    signal launched(string desktopId)

    implicitWidth: 132
    implicitHeight: 112

    radius: 18

    color: {
        if (mouseArea.pressed)
            return root.selected
                ? "#465466"
                : "#303946"

        if (mouseArea.containsMouse)
            return root.selected
                ? "#3f4c5d"
                : "#29323d"

        return root.selected
            ? "#374454"
            : "#20262e"
    }

    border.width:
        root.selected
        || mouseArea.containsMouse
            ? 1
            : 0

    border.color:
        root.selected
            ? "#66798f"
            : "#3c4857"

    scale:
        mouseArea.pressed
            ? 0.97
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

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12

        spacing: 8

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 54
            Layout.preferredHeight: 54

            radius: 16
            color: "#2d3641"

            Image {
                id: iconImage

                anchors.fill: parent
                anchors.margins: 8

                visible:
                    root.appIcon.length > 0
                    && status !== Image.Error

                source: root.appIcon
                fillMode: Image.PreserveAspectFit

                asynchronous: true
                smooth: true
            }

            Text {
                anchors.centerIn: parent

                visible:
                    root.appIcon.length === 0
                    || iconImage.status === Image.Error

                text: "󰀻"
                color: "#dce3eb"

                font.pixelSize: 24
                font.family:
                    "JetBrainsMono Nerd Font"
            }
        }

        Text {
            Layout.fillWidth: true

            text: root.appName
            color: "#eef2f6"

            font.pixelSize: 11
            font.weight: Font.DemiBold

            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }

        Text {
            Layout.fillWidth: true

            visible:
                root.appComment.length > 0

            text: root.appComment
            color: "#7f8b99"

            font.pixelSize: 9

            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent

        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            root.launched(root.desktopId)
        }
    }
}
