import QtQuick
import QtQuick.Layouts

import qs.theme as ShellTheme

Item {
    id: root

    implicitWidth: 520
    implicitHeight: 190

    Rectangle {
        id: previewCard

        anchors.fill: parent

        radius: ShellTheme.Theme.radius.large
        color: ShellTheme.Theme.colors.surfaceContainerLow

        border.width: 1
        border.color: ShellTheme.Theme.colors.outlineVariant

        ColumnLayout {
            anchors {
                fill: parent
                margins: ShellTheme.Theme.spacing.large
            }

            spacing: ShellTheme.Theme.spacing.medium

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Theme Preview"

                    color: ShellTheme.Theme.colors.on_surface

                    font.family:
                        ShellTheme.Theme.typography.fontFamily

                    font.pixelSize:
                        ShellTheme.Theme.typography.titleMedium

                    font.weight: Font.DemiBold
                }

                Item {
                    Layout.fillWidth: true
                }

                Rectangle {
                    Layout.preferredWidth: 34
                    Layout.preferredHeight: 34

                    radius: ShellTheme.Theme.radius.circle
                    color: ShellTheme.Theme.colors.primaryContainer

                    Text {
                        anchors.centerIn: parent

                        text: "A"

                        color:
                            ShellTheme.Theme.colors.on_primary_container

                        font.family:
                            ShellTheme.Theme.typography.fontFamily

                        font.weight: Font.DemiBold
                    }
                }
            }

            Text {
                text:
                    "This preview follows the active appearance and color style."

                color:
                    ShellTheme.Theme.colors.on_surface_variant

                font.family:
                    ShellTheme.Theme.typography.fontFamily

                font.pixelSize:
                    ShellTheme.Theme.typography.bodyMedium
            }

            RowLayout {
                Layout.fillWidth: true

                spacing:
                    ShellTheme.Theme.spacing.medium

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 52

                    radius:
                        ShellTheme.Theme.radius.control

                    color:
                        ShellTheme.Theme.colors.primaryContainer

                    Text {
                        anchors.centerIn: parent

                        text: "Primary"

                        color:
                            ShellTheme.Theme.colors.on_primary_container

                        font.family:
                            ShellTheme.Theme.typography.fontFamily

                        font.pixelSize:
                            ShellTheme.Theme.typography.bodyMedium

                        font.weight: Font.Medium
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 52

                    radius:
                        ShellTheme.Theme.radius.control

                    color:
                        ShellTheme.Theme.colors.surfaceContainerHigh

                    Text {
                        anchors.centerIn: parent

                        text: "Surface"

                        color:
                            ShellTheme.Theme.colors.on_surface

                        font.family:
                            ShellTheme.Theme.typography.fontFamily

                        font.pixelSize:
                            ShellTheme.Theme.typography.bodyMedium

                        font.weight: Font.Medium
                    }
                }
            }
        }
    }
}
