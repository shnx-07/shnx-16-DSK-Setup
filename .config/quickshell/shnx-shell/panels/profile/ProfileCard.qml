import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    implicitWidth: 448
    implicitHeight: 210

    radius: 20
    color: "#b51d222a"

    border.width: 1
    border.color: "#202b36"

    clip: true

    ProfilePicture {
        id: profilePicture

        width: 124
        height: 124

        anchors.left: parent.left
        anchors.leftMargin: 24

        anchors.verticalCenter: parent.verticalCenter
    }

    UserInfoSection {
        id: userInfo

        anchors.left: parent.horizontalCenter
        anchors.leftMargin: 4

        anchors.right: parent.right
        anchors.rightMargin: 22

        anchors.verticalCenter: parent.verticalCenter
    }
}
