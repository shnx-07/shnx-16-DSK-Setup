import QtQuick

Rectangle {
    id: root

    implicitWidth: 180
    implicitHeight: 34

    radius: height / 2
    color: "#050608"
    border.width: 1
    border.color: "#343944"

    Text {
        anchors.centerIn: parent

        text: "CENTER"
        color: "#f2f3f5"

        font.pixelSize: 12
        font.weight: Font.DemiBold
        font.letterSpacing: 1
    }
}
