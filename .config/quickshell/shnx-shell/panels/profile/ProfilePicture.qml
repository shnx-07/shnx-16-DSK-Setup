import QtQuick
import Quickshell
import qs.core as Core
import qs.theme as ShellTheme

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
        color: ShellTheme.Theme.colors.surfaceContainerHigh

        border.width: 1
        border.color:
            avatarMouseArea.containsMouse
                ? ShellTheme.Theme.colors.outline
                : ShellTheme.Theme.colors.outlineVariant

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

            color: ShellTheme.Theme.colors.surfaceContainer

            Image {
                id: avatarImage

                anchors.fill: parent

                visible:
                    Boolean(root.profile && (root.profile.hasCustomAvatar || root.profile.hasAvatar))
                    && status !== Image.Error

                source:
                    (root.profile && (root.profile.hasCustomAvatar || root.profile.hasAvatar))
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
                    !Boolean(root.profile && (root.profile.hasCustomAvatar || root.profile.hasAvatar))
                    || avatarImage.status === Image.Error

                text: ""

                color: ShellTheme.Theme.colors.on_surface

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
