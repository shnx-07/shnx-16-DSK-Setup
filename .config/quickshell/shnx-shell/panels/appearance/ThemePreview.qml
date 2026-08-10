import QtQuick
import QtQuick.Layouts

import qs.theme as ShellTheme

Item {
    id: root

    implicitWidth: 680
    implicitHeight: 126

    Rectangle {
        anchors.fill: parent

        radius:
            ShellTheme.Theme.radius.large

        color:
            ShellTheme.Theme.colors.surfaceContainerLow

        border.width: 1

        border.color:
            ShellTheme.Theme.colors.outlineVariant

        RowLayout {
            anchors {
                fill: parent

                margins:
                    ShellTheme.Theme.spacing.medium
            }

            spacing:
                ShellTheme.Theme.spacing.large

            /*
             * INFORMATION
             */
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true

                spacing:
                    ShellTheme.Theme.spacing.small

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Theme Preview"

                        color:
                            ShellTheme.Theme.colors.on_surface

                        font.family:
                            ShellTheme.Theme.typography.fontFamily

                        font.pixelSize:
                            ShellTheme.Theme.typography.titleMedium

                        font.weight:
                            Font.DemiBold
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30

                        radius:
                            ShellTheme.Theme.radius.circle

                        color:
                            ShellTheme.Theme.colors.primaryContainer

                        Text {
                            anchors.centerIn: parent

                            text: "A"

                            color:
                                ShellTheme.Theme.colors.on_primary_container

                            font.family:
                                ShellTheme.Theme.typography.fontFamily

                            font.pixelSize:
                                ShellTheme.Theme.typography.labelMedium

                            font.weight:
                                Font.DemiBold
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true

                    text:
                        "Live preview of the active shell theme."

                    color:
                        ShellTheme.Theme.colors.on_surface_variant

                    font.family:
                        ShellTheme.Theme.typography.fontFamily

                    font.pixelSize:
                        ShellTheme.Theme.typography.labelMedium
                }

                Item {
                    Layout.fillHeight: true
                }
            }

            /*
             * MINI UI PREVIEW
             */
            ColumnLayout {
                Layout.preferredWidth: 280

                spacing:
                    ShellTheme.Theme.spacing.small

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42

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
                            ShellTheme.Theme.typography.labelMedium

                        font.weight:
                            Font.Medium
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42

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
                            ShellTheme.Theme.typography.labelMedium

                        font.weight:
                            Font.Medium
                    }
                }
            }
        }
    }
}
