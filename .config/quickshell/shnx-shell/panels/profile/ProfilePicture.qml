import QtQuick
import Quickshell
import qs.core as Core

Item {
    id: root

    implicitWidth: 112
    implicitHeight: 68

    readonly property var profile:
        Core.ServiceRegistry.profile

    signal clicked()

    Rectangle {
        id: outerRing

        anchors.fill: parent

        radius: width / 2
        color: "#252c35"

        border.width: 1
        border.color:
            avatarMouseArea.containsMouse
                ? "#71839a"
                : "#465364"

        Behavior on border.color {
            ColorAnimation {
                duration: 140
            }
        }

        Rectangle {
            id: avatarMask

            anchors.centerIn: parent

            width: 98
            height: 98

            radius: width / 2
            clip: true

            color: "#303844"

            Image {
                id: avatarImage

                anchors.fill: parent

                visible:
                    root.profile.hasAvatar
                    && status !== Image.Error

                source:
                    root.profile.hasAvatar
                        ? "file://" + root.profile.avatarPath
                        : ""

                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: false
                smooth: true
            }

            Text {
                anchors.centerIn: parent

                visible:
                    !root.profile.hasAvatar
                    || avatarImage.status === Image.Error

                text: ""

                color: "#e8edf4"

                font.pixelSize: 38
                font.family: "JetBrainsMono Nerd Font"
            }

            
        }
    }

    

    MouseArea {
        id: avatarMouseArea

        anchors.fill: parent

        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            root.clicked()
            root.profile.selectAvatar()
        }
    }

    scale:
        avatarMouseArea.pressed
            ? 0.97
            : 1.0

    Behavior on scale {
        NumberAnimation {
            duration: 100
        }
    }
}
