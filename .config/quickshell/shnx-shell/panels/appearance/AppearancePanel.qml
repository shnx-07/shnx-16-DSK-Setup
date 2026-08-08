import QtQuick
import QtQuick.Layouts

import Quickshell

import qs.core as Core
import qs.theme as ShellTheme

import "." as AppearanceParts

PanelWindow {
    id: root

    visible:
        Core.PanelController.appearancePanelOpen

    color: "transparent"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    focusable: true

    onVisibleChanged: {
        if (visible)
            keyHandler.forceActiveFocus()
    }

    Item {
        id: keyHandler

        anchors.fill: parent

        focus: true

        Keys.onEscapePressed: event => {
            Core.PanelController.close()
            event.accepted = true
        }

        Rectangle {
            id: panelSurface

            width: 761
            height: 681

            anchors.centerIn: parent

            radius:
                ShellTheme.Theme.radius.panel

            color:
                ShellTheme.Theme.colors.surfaceContainer

            border.width: 2

            border.color:
                ShellTheme.Theme.colors.outlineVariant

            ColumnLayout {
                anchors {
                    fill: parent

                    margins:
                        ShellTheme.Theme.spacing.panelPadding
                }

                spacing:
                    ShellTheme.Theme.spacing.medium

                /*
                 * HEADER
                 */
                ColumnLayout {
                    Layout.fillWidth: true

                    spacing:
                        ShellTheme.Theme.spacing.xSmall

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
                            "Customize the look and colors of SHNX"

                        color:
                            ShellTheme.Theme.colors.on_surface_variant

                        font.family:
                            ShellTheme.Theme.typography.fontFamily

                        font.pixelSize:
                            ShellTheme.Theme.typography.bodyMedium
                    }
                }

                /*
                 * PRESETS
                 */
                ColumnLayout {
                    Layout.fillWidth: true

                    spacing:
                        ShellTheme.Theme.spacing.xSmall

                    Text {
                        text: "Presets"

                        color:
                            ShellTheme.Theme.colors.on_surface

                        font.family:
                            ShellTheme.Theme.typography.fontFamily

                        font.pixelSize:
                            ShellTheme.Theme.typography.bodyMedium

                        font.weight:
                            Font.Medium
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 169

                        radius:
                            ShellTheme.Theme.radius.control

                        color:
                            ShellTheme.Theme.colors.surfaceContainerLow

                        border.width: 2

                        border.color:
                            ShellTheme.Theme.colors.outlineVariant

                        clip: true

                        Flickable {
                            id: presetFlickable

                            anchors {
                                fill: parent

                                margins:
                                    ShellTheme.Theme.spacing.small
                            }

                            clip: true

                            contentWidth:
                                width

                            contentHeight:
                                presetSelector.implicitHeight

                            boundsBehavior:
                                Flickable.StopAtBounds

                            AppearanceParts.AppearanceSelector {
                                id: presetSelector

                                width:
                                    presetFlickable.width
                            }
                        }
                    }
                }

                /*
                 * COLOR STYLE
                 */
                ColumnLayout {
                    Layout.fillWidth: true

                    spacing:
                        ShellTheme.Theme.spacing.xSmall

                    Text {
                        text: "Color style"

                        color:
                            ShellTheme.Theme.colors.on_surface

                        font.family:
                            ShellTheme.Theme.typography.fontFamily

                        font.pixelSize:
                            ShellTheme.Theme.typography.bodyMedium

                        font.weight:
                            Font.Medium
                    }

                    AppearanceParts.ColorStyleSelector {
                        Layout.fillWidth: true
                    }
                }

                /*
                 * PALETTE
                 */
                ColumnLayout {
                    Layout.fillWidth: true

                    spacing:
                        ShellTheme.Theme.spacing.xSmall

                    Text {
                        text: "Palette preview"

                        color:
                            ShellTheme.Theme.colors.on_surface

                        font.family:
                            ShellTheme.Theme.typography.fontFamily

                        font.pixelSize:
                            ShellTheme.Theme.typography.bodyMedium

                        font.weight:
                            Font.Medium
                    }

                    AppearanceParts.PalettePreview {
                        Layout.fillWidth: true
                    }
                }

                /*
                 * THEME PREVIEW
                 */
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    spacing:
                        ShellTheme.Theme.spacing.xSmall

                    Text {
                        text: "Theme preview"

                        color:
                            ShellTheme.Theme.colors.on_surface

                        font.family:
                            ShellTheme.Theme.typography.fontFamily

                        font.pixelSize:
                            ShellTheme.Theme.typography.bodyMedium

                        font.weight:
                            Font.Medium
                    }

                    AppearanceParts.ThemePreview {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }
            }
        }
    }
}
