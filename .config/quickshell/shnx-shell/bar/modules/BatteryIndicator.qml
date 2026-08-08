import QtQuick
import qs.core as Core
import qs.theme as ShellTheme

Rectangle {
    id: root

    signal clicked()

    readonly property var battery:
        Core.ServiceRegistry.battery

    implicitWidth: contentRow.implicitWidth + 20
    implicitHeight: 32

    radius: ShellTheme.Theme.radius.button

    color: mouseArea.pressed
        ? ShellTheme.Theme.colors.pressedOverlay
        : mouseArea.containsMouse
            ? ShellTheme.Theme.colors.hoverOverlay
            : ShellTheme.Theme.colors.surfaceContainer

    border.width: 1

    border.color: {
        if (battery.critical)
            return ShellTheme.Theme.colors.error

        if (mouseArea.containsMouse)
            return ShellTheme.Theme.colors.outline

        return ShellTheme.Theme.colors.outlineVariant
    }

    Row {
        id: contentRow

        anchors.centerIn: parent
        spacing: 7

        Text {
            text: battery.icon

            color: {
                if (battery.critical)
                    return ShellTheme.Theme.colors.error

                if (battery.low)
                    return ShellTheme.Theme.colors.warning

                if (battery.charging)
                    return ShellTheme.Theme.colors.success

                return ShellTheme.Theme.colors.on_surface
            }

            font.pixelSize: 17
        }

        Text {
            text: battery.available
                ? battery.percentage + "%"
                : "--"

            color: ShellTheme.Theme.colors.on_surface

            font.pixelSize: ShellTheme.Theme.typography.labelMedium
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
