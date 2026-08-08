import QtQuick
import QtQuick.Layouts

import qs.core as Core
import qs.theme as ShellTheme

Item {
    id: root

    implicitWidth: 680
    implicitHeight: selectorGrid.implicitHeight

    readonly property string currentMode:
        Core.ServiceRegistry.theme.appearanceMode

    readonly property var presets: [
        { mode: "dark", label: "Dark", enabled: true },
        { mode: "light", label: "Light", enabled: true },
        { mode: "gray", label: "Gray", enabled: true }, 

        { mode: "catppuccinMocha", label: "Catppuccin Mocha", enabled: true },
        { mode: "catppuccinMacchiato", label: "Catppuccin Macchiato", enabled: true },

        { mode: "gruvboxDark", label: "Gruvbox Dark", enabled: true },
        { mode: "gruvboxLight", label: "Gruvbox Light", enabled: true },

        { mode: "nord", label: "Nord", enabled: true },
        { mode: "dracula", label: "Dracula", enabled: true },
        { mode: "tokyoNight", label: "Tokyo Night", enabled: true },

        { mode: "rosePine", label: "Rose Pine", enabled: true },
        { mode: "rosePineMoon", label: "Rose Pine Moon", enabled: true },

        { mode: "everforestDark", label: "Everforest Dark", enabled: true },
        { mode: "everforestLight", label: "Everforest Light", enabled: true },

        { mode: "kanagawa", label: "Kanagawa", enabled: true },
        { mode: "oneDark", label: "One Dark", enabled: true },

        { mode: "solarizedDark", label: "Solarized Dark", enabled: true },
        { mode: "solarizedLight", label: "Solarized Light", enabled: true },

        { mode: "monokai", label: "Monokai", enabled: true },

        { mode: "materialDark", label: "Material Dark", enabled: true },
        { mode: "materialLight", label: "Material Light", enabled: true },

        { mode: "ocean", label: "Ocean", enabled: true },
        { mode: "forest", label: "Forest", enabled: true },
        { mode: "sunset", label: "Sunset", enabled: true },
        { mode: "amoled", label: "AMOLED", enabled: true }

    ]

    GridLayout {
        id: selectorGrid

        width: root.width

        columns: 3

        columnSpacing:
            ShellTheme.Theme.spacing.small

        rowSpacing:
            ShellTheme.Theme.spacing.small

        Repeater {
            model:
                root.presets

            delegate: Rectangle {
                id: presetButton

                required property var modelData

                Layout.fillWidth: true

                Layout.preferredWidth:
                    (
                        selectorGrid.width
                        - selectorGrid.columnSpacing * 2
                    ) / 3

                Layout.preferredHeight: 42

                radius:
                    ShellTheme.Theme.radius.control

                readonly property bool selected:
                    root.currentMode === modelData.mode

                readonly property bool available:
                    modelData.enabled === true

                readonly property bool hovered:
                    mouseArea.containsMouse

                color: {
                    if (selected)
                        return ShellTheme.Theme.colors.primaryContainer

                    if (hovered && available)
                        return ShellTheme.Theme.colors.surfaceContainerHigh

                    return ShellTheme.Theme.colors.surfaceContainer
                }

                border.width:
                    selected ? 1 : 0

                border.color:
                    selected
                        ? ShellTheme.Theme.colors.primary
                        : "transparent"

                opacity:
                    available ? 1.0 : 0.45

                Behavior on color {
                    ColorAnimation {
                        duration: 140
                    }
                }

                Text {
                    anchors {
                        fill: parent

                        leftMargin:
                            ShellTheme.Theme.spacing.medium

                        rightMargin:
                            ShellTheme.Theme.spacing.medium
                    }

                    verticalAlignment:
                        Text.AlignVCenter

                    horizontalAlignment:
                        Text.AlignHCenter

                    text:
                        presetButton.modelData.label

                    elide:
                        Text.ElideRight

                    color:
                        presetButton.selected
                            ? ShellTheme.Theme.colors.on_primary_container
                            : ShellTheme.Theme.colors.on_surface

                    font.family:
                        ShellTheme.Theme.typography.fontFamily

                    font.pixelSize:
                        ShellTheme.Theme.typography.labelMedium

                    font.weight:
                        presetButton.selected
                            ? Font.DemiBold
                            : Font.Medium
                }

                MouseArea {
                    id: mouseArea

                    anchors.fill: parent

                    enabled:
                        presetButton.available

                    hoverEnabled: true

                    cursorShape:
                        presetButton.available
                            ? Qt.PointingHandCursor
                            : Qt.ArrowCursor

                    onClicked: {
                        if (presetButton.selected)
                            return

                        Core.ServiceRegistry.theme.setAppearanceMode(
                            presetButton.modelData.mode
                        )
                    }
                }
            }
        }
    }
}
