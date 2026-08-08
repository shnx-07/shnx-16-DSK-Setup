import QtQuick
import qs.core as Core
import qs.theme as ShellTheme

Rectangle {
    id: root

    signal clicked()

    readonly property var network:
        Core.ServiceRegistry.network

    implicitWidth: contentRow.implicitWidth + 20
    implicitHeight: 32

    radius: ShellTheme.Theme.radius.button

    color: mouseArea.pressed
        ? ShellTheme.Theme.colors.pressedOverlay
        : mouseArea.containsMouse
            ? ShellTheme.Theme.colors.hoverOverlay
            : ShellTheme.Theme.colors.surfaceContainer

    border.width: 1

    border.color: mouseArea.containsMouse
        ? ShellTheme.Theme.colors.outline
        : ShellTheme.Theme.colors.outlineVariant

    Behavior on color {
        ColorAnimation {
            duration: 120
        }
    }

    Behavior on border.color {
        ColorAnimation {
            duration: 120
        }
    }

    Row {
        id: contentRow

        anchors.centerIn: parent
        spacing: 7

        Text {
            text: network.icon

            color: {
                if (!network.available
                        || !network.wifiHardwareEnabled
                        || !network.wifiEnabled) {
                    return ShellTheme.Theme.colors.disabled
                }

                if (network.connected)
                    return ShellTheme.Theme.colors.on_surface

                return ShellTheme.Theme.colors.warning
            }

            font.pixelSize: 17
        }

        Text {
            visible: network.connected

            text: network.ssid

            width: visible
                ? Math.min(implicitWidth, 130)
                : 0

            color: ShellTheme.Theme.colors.on_surface

            font.pixelSize: ShellTheme.Theme.typography.labelMedium
            font.weight: Font.DemiBold

            elide: Text.ElideRight
            maximumLineCount: 1
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
