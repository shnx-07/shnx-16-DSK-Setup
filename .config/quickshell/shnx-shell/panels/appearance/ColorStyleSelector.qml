import QtQuick
import QtQuick.Layouts

import qs.core as Core
import qs.theme as ShellTheme

Item {
    id: root

    implicitWidth: 680
    implicitHeight: 46

    readonly property string currentStyle:
        Core.ServiceRegistry.theme.colorStyle

    readonly property var styles: [
        {
            style: "preset",
            label: "Preset"
        },
        {
            style: "wallpaperAccents",
            label: "Wallpaper Accents"
        },
        {
            style: "wallpaperFull",
            label: "Wallpaper Full"
        }
    ]

    RowLayout {
        anchors.fill: parent

        spacing:
            ShellTheme.Theme.spacing.small

        Repeater {
            model:
                root.styles

            delegate: Rectangle {
                id: styleButton

                required property var modelData

                Layout.fillWidth: true
                Layout.fillHeight: true

                radius:
                    ShellTheme.Theme.radius.control

                readonly property bool selected:
                    root.currentStyle === modelData.style

                readonly property bool hovered:
                    mouseArea.containsMouse

                color: {
                    if (selected)
                        return ShellTheme.Theme.colors.primaryContainer

                    if (hovered)
                        return ShellTheme.Theme.colors.surfaceContainerHigh

                    return ShellTheme.Theme.colors.surfaceContainerLow
                }

                border.width:
                    selected ? 1 : 0

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

                    text:
                        styleButton.modelData.label

                    color:
                        styleButton.selected
                            ? ShellTheme.Theme.colors.on_primary_container
                            : ShellTheme.Theme.colors.on_surface

                    font.family:
                        ShellTheme.Theme.typography.fontFamily

                    font.pixelSize:
                        ShellTheme.Theme.typography.labelMedium

                    font.weight:
                        styleButton.selected
                            ? Font.DemiBold
                            : Font.Medium
                }

                MouseArea {
                    id: mouseArea

                    anchors.fill: parent

                    hoverEnabled: true

                    cursorShape:
                        Qt.PointingHandCursor

                    onClicked: {
                        if (styleButton.selected)
                            return

                        Core.ServiceRegistry.theme.setColorStyle(
                            styleButton.modelData.style
                        )
                    }
                }
            }
        }
    }
}
