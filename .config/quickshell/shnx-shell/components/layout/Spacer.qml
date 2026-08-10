import QtQuick

Item {
    id: root

    property bool horizontal: true
    property real size: 0
    property bool expanding: false

    implicitWidth:
        horizontal
            ? (expanding ? 0 : size)
            : 1

    implicitHeight:
        horizontal
            ? 1
            : (expanding ? 0 : size)
}
