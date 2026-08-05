import QtQuick
import "../dynamic"

Item {
    id: root

    implicitWidth: island.implicitWidth
    implicitHeight: 34

    DynamicIsland {
        id: island

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
    }
}
