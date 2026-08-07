import QtQuick
import QtQuick.Layouts

import qs.theme as ShellTheme

Item {
    id: root

    implicitWidth: paletteRow.implicitWidth
    implicitHeight: paletteRow.implicitHeight

    RowLayout {
        id: paletteRow

        anchors.fill: parent
        spacing: ShellTheme.Theme.spacing.medium

        Repeater {
            model: [
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

            delegate: ColumnLayout {
                id: swatchItem

                required property var modelData

                spacing: ShellTheme.Theme.spacing.xSmall

                Rectangle {
                    Layout.preferredWidth: 92
                    Layout.preferredHeight: 72

                    radius: ShellTheme.Theme.radius.large
                    color: swatchItem.modelData.colorValue

                    border.width: 1
                    border.color: ShellTheme.Theme.colors.outlineVariant
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter

                    text: swatchItem.modelData.label

                    color: ShellTheme.Theme.colors.on_surface_variant

                    font.family:
                        ShellTheme.Theme.typography.fontFamily

                    font.pixelSize:
                        ShellTheme.Theme.typography.labelMedium
                }
            }
        }
    }
}
