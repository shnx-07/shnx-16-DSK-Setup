import QtQuick
import QtQuick.Layouts

import qs.core as Core
import qs.theme as ShellTheme

Item {
    id: root

    implicitHeight: selectorRow.implicitHeight
    implicitWidth: selectorRow.implicitWidth

    readonly property string currentMode:
        Core.ServiceRegistry.theme.appearanceMode

    RowLayout {
        id: selectorRow

        anchors.fill: parent
        spacing: ShellTheme.Theme.spacing.medium

        Repeater {
            model: [
                {
                    mode: "dark",
                    label: "Dark"
                },
                {
                    mode: "light",
                    label: "Light"
                },
                {
                    mode: "gray",
                    label: "Gray"
                }
            ]

            delegate: Rectangle {
                id: modeButton

                required property var modelData

                Layout.preferredWidth: 150
                Layout.preferredHeight: 56

                radius: ShellTheme.Theme.radius.control

                readonly property bool selected:
                    root.currentMode === modelData.mode

                readonly property bool hovered:
                    mouseArea.containsMouse

                color: {
                    if (selected)
                        return ShellTheme.Theme.colors.primaryContainer

                    if (hovered)
                        return ShellTheme.Theme.colors.surfaceContainerHigh

                    return ShellTheme.Theme.colors.surfaceContainerLow
                }

                border.width: selected ? 1 : 0

                border.color:
                    selected
                        ? ShellTheme.Theme.colors.primary
                        : "transparent"

                Behavior on color {
                    ColorAnimation {
                        duration: 140
                    }
                }

                Text {
                    anchors.centerIn: parent

                    text: modeButton.modelData.label

                    color:
                        modeButton.selected
                            ? ShellTheme.Theme.colors.on_primary_container
                            : ShellTheme.Theme.colors.on_surface

                    font.family:
                        ShellTheme.Theme.typography.fontFamily

                    font.pixelSize:
                        ShellTheme.Theme.typography.bodyMedium

                    font.weight:
                        modeButton.selected
                            ? Font.DemiBold
                            : Font.Medium
                }

                MouseArea {
                    id: mouseArea

                    anchors.fill: parent

                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        if (modeButton.selected)
                            return

                        Core.ServiceRegistry.theme.setAppearanceMode(
                            modeButton.modelData.mode
                        )
                    }
                }
            }
        }
    }
}
