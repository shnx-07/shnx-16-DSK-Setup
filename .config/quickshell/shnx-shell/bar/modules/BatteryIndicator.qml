import QtQuick
import qs.core as Core

Rectangle {
    id: root

    signal clicked()

    readonly property var battery:
        Core.ServiceRegistry.battery

    implicitWidth: contentRow.implicitWidth + 20
    implicitHeight: 32

    radius: 10

    color: mouseArea.pressed
        ? "#343944"
        : mouseArea.containsMouse
            ? "#2d323c"
            : "#252932"

    border.width: 1

    border.color: {
        if (battery.critical)
            return "#d56a76"

        if (mouseArea.containsMouse)
            return "#596273"

        return "#3b414d"
    }

    Row {
        id: contentRow

        anchors.centerIn: parent
        spacing: 7

        Text {
            text: battery.icon

            color: {
                if (battery.critical)
                    return "#ff7b86"

                if (battery.low)
                    return "#e9b96e"

                if (battery.charging)
                    return "#8bd49c"

                return "#f2f3f5"
            }

            font.pixelSize: 17
        }

        Text {
            text: battery.available
                ? battery.percentage + "%"
                : "--"

            color: "#f2f3f5"

            font.pixelSize: 12
            font.weight: Font.DemiBold
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: root.clicked()
    }
}
