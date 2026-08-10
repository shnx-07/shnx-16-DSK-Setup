import QtQuick
import QtQuick.Layouts

import qs.theme as ShellTheme

Item {
    id: root

    implicitWidth: 680
    implicitHeight: 68

    readonly property var paletteItems: [
        {
            label: "Primary",
            colorValue: ShellTheme.Theme.colors.primary
        },
        {
            label: "Secondary",
            colorValue: ShellTheme.Theme.colors.secondary
        },
        {
            label: "Tertiary",
            colorValue: ShellTheme.Theme.colors.tertiary
        },
        {
            label: "Surface",
            colorValue: ShellTheme.Theme.colors.surfaceContainerHigh
        }
    ]

    RowLayout {
        anchors.fill: parent

        spacing:
            ShellTheme.Theme.spacing.small

        Repeater {
            model:
                root.paletteItems

            delegate: Rectangle {
                id: swatch

                required property var modelData

                Layout.fillWidth: true
                Layout.fillHeight: true

                radius:
                    ShellTheme.Theme.radius.control

                color:
                    ShellTheme.Theme.colors.surfaceContainerLow

                border.width: 1

                border.color:
                    ShellTheme.Theme.colors.outlineVariant

                RowLayout {
                    anchors {
                        fill: parent

                        margins:
                            ShellTheme.Theme.spacing.small
                    }

                    spacing:
                        ShellTheme.Theme.spacing.small

                    Rectangle {
                        Layout.preferredWidth: 38
                        Layout.preferredHeight: 38

                        radius:
                            ShellTheme.Theme.radius.small

                        color:
                            swatch.modelData.colorValue

                        border.width: 1

                        border.color:
                            ShellTheme.Theme.colors.outlineVariant
                    }

                    Text {
                        Layout.fillWidth: true

                        text:
                            swatch.modelData.label

                        color:
                            ShellTheme.Theme.colors.on_surface

                        font.family:
                            ShellTheme.Theme.typography.fontFamily

                        font.pixelSize:
                            ShellTheme.Theme.typography.labelMedium

                        elide:
                            Text.ElideRight
                    }
                }
            }
        }
    }
}
