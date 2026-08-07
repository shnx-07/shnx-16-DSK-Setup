import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland

import qs.core as Core
import qs.theme as ShellTheme

import "." as AppearanceParts

PanelWindow {
    id: root

    visible:
        Core.PanelController.appearancePanelOpen

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"

    exclusionMode:
        ExclusionMode.Ignore

    aboveWindows: true
    focusable: true

    Rectangle {
        id: panel

        width: 760
        height: 680

        anchors.centerIn: parent

        radius:
            ShellTheme.Theme.radius.panel

        color:
            ShellTheme.Theme.colors.surfaceContainer

        border.width: 1

        border.color:
            ShellTheme.Theme.colors.outlineVariant

        ColumnLayout {
            anchors {
                fill: parent
                margins:
                    ShellTheme.Theme.spacing.panelPadding
            }

            spacing:
                ShellTheme.Theme.spacing.large

            Text {
                text: "Appearance"

                color:
                    ShellTheme.Theme.colors.on_surface

                font.family:
                    ShellTheme.Theme.typography.fontFamily

                font.pixelSize:
                    ShellTheme.Theme.typography.titleLarge

                font.weight:
                    Font.DemiBold
            }

            Text {
                text:
                    "Choose your base appearance"

                color:
                    ShellTheme.Theme.colors.on_surface_variant

                font.family:
                    ShellTheme.Theme.typography.fontFamily

                font.pixelSize:
                    ShellTheme.Theme.typography.bodyMedium
            }

            AppearanceParts.AppearanceSelector {
                Layout.alignment:
                    Qt.AlignHCenter
            }

            Text {
                text: "Color style"

                color:
                    ShellTheme.Theme.colors.on_surface_variant

                font.family:
                    ShellTheme.Theme.typography.fontFamily

                font.pixelSize:
                    ShellTheme.Theme.typography.bodyMedium
            }

            AppearanceParts.ColorStyleSelector {
                Layout.alignment:
                    Qt.AlignHCenter
            }

            Text {
                text: "Palette preview"

                color:
                    ShellTheme.Theme.colors.on_surface_variant

                font.family:
                    ShellTheme.Theme.typography.fontFamily

                font.pixelSize:
                    ShellTheme.Theme.typography.bodyMedium
            }

            AppearanceParts.PalettePreview {
                Layout.alignment:
                    Qt.AlignHCenter
            }

            Text {
                text: "Theme preview"

                color:
                    ShellTheme.Theme.colors.on_surface_variant

                font.family:
                    ShellTheme.Theme.typography.fontFamily

                font.pixelSize:
                    ShellTheme.Theme.typography.bodyMedium
            }

            AppearanceParts.ThemePreview {
                Layout.alignment:
                    Qt.AlignHCenter
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }

    Shortcut {
        sequence: "Escape"

        context:
            Qt.WindowShortcut

        enabled: root.visible

        onActivated: {
            Core.PanelController.close()
        }
    }
}
