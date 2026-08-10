import QtQuick
import qs.theme as ShellTheme

Item {
    id: root

    required property QtObject clockService

    Row {
        id: panelRow

        anchors.fill: parent
        spacing: 18

        ClockSection {
            width: Math.floor(
                (panelRow.width - panelRow.spacing - divider.width) * 0.42
            )

            height: panelRow.height
            clockService: root.clockService
        }

        Rectangle {
            id: divider

            width: 1
            height: panelRow.height - 28

            anchors.verticalCenter: parent.verticalCenter

            radius: 1
            color: ShellTheme.Theme.colors.outlineVariant
        }

        CalendarSection {
            width: panelRow.width
                   - panelRow.spacing
                   - divider.width
                   - Math.floor(
                       (panelRow.width - panelRow.spacing - divider.width) * 0.42
                   )

            height: panelRow.height
            clockService: root.clockService
        }
    }
}
