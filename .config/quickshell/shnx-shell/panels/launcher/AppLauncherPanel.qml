import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.core as Core
import Quickshell.Wayland
import qs.theme as ShellTheme

PanelWindow {
    id: root

    implicitWidth: 760
    implicitHeight: 680

    color: "transparent"

    visible: Core.PanelController.appLauncherOpen

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    exclusionMode: ExclusionMode.Ignore
    aboveWindows: true
    focusable: true

    onVisibleChanged: {
        if (visible) {
            Core.ServiceRegistry.search.setQuery("")
            Core.ServiceRegistry.search.setCategory("All")

            searchField.clear()
            categorySidebar.selectedCategory = "All"
            appGrid.resetSelection()

            Qt.callLater(function() {
                searchField.activate()
            })
        } else if (Core.PanelController.appLauncherOpen) {
            Core.PanelController.close()
        }
      }


    Shortcut {
        sequence: "Escape"
        context: Qt.WindowShortcut
        enabled: root.visible

        onActivated: {
            Core.PanelController.close()
        }
    }

    Shortcut {
        sequence: "Left"
        context: Qt.WindowShortcut
        enabled:
            root.visible
            && appGrid.applicationCount > 0

        onActivated: {
            appGrid.moveSelection(-1)
        }
    }

    Shortcut {
        sequence: "Right"
        context: Qt.WindowShortcut
        enabled:
            root.visible
            && appGrid.applicationCount > 0

        onActivated: {
            appGrid.moveSelection(1)
        }
    }

    Shortcut {
        sequence: "Up"
        context: Qt.WindowShortcut
        enabled:
            root.visible
            && appGrid.applicationCount > 0

        onActivated: {
            appGrid.moveSelectionByRow(-1)
        }
    }

    Shortcut {
        sequence: "Down"
        context: Qt.WindowShortcut
        enabled:
            root.visible
            && appGrid.applicationCount > 0

        onActivated: {
            appGrid.moveSelectionByRow(1)
        }
    }

    Rectangle {
        width: 760
        height: 680
        anchors.centerIn: parent
        radius: ShellTheme.Theme.radius.panel
        color: ShellTheme.Theme.colors.background

        border.width: 1
        border.color: ShellTheme.Theme.colors.outlineVariant

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18

            spacing: 14

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 42

                Text {
                    text: "Applications"
                    color: ShellTheme.Theme.colors.on_surface

                    font.pixelSize: ShellTheme.Theme.typography.headlineMedium
                    font.weight: Font.DemiBold
                }

                Item {
                    Layout.fillWidth: true
                }

                Rectangle {
                    Layout.preferredWidth: 34
                    Layout.preferredHeight: 34

                    radius: width / 2

                    color:
                        closeMouseArea.pressed
                            ? ShellTheme.Theme.colors.pressedOverlay
                            : closeMouseArea.containsMouse
                                ? ShellTheme.Theme.colors.hoverOverlay
                                : ShellTheme.Theme.colors.surfaceContainer

                    border.width: 1
                    border.color: ShellTheme.Theme.colors.outlineVariant

                    Text {
                        anchors.centerIn: parent

                        text: "󰅖"
                        color: ShellTheme.Theme.colors.on_surface

                        font.pixelSize: ShellTheme.Theme.typography.titleSmall
                        font.family:
                            "JetBrainsMono Nerd Font"
                    }

                    MouseArea {
                        id: closeMouseArea

                        anchors.fill: parent

                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            Core.PanelController.close()
                        }
                    }
                }
            }

            SearchField {
                id: searchField

                Layout.fillWidth: true

                onTextChanged: {
                    if (text.trim().length > 0
                            && Core.ServiceRegistry.search.selectedCategory !== "All") {
                        Core.ServiceRegistry.search.setCategory("All")
                        categorySidebar.selectedCategory = "All"
                    }

                    Core.ServiceRegistry.search.setQuery(text)
                }

                onSubmitted: {
                    appGrid.launchSelected()
                }

                onCleared: {
                    Core.ServiceRegistry.search.setQuery("")
                }

                onMoveLeftRequested: {
                    appGrid.moveSelection(-1)
                }

                onMoveRightRequested: {
                    appGrid.moveSelection(1)
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true

                spacing: 12

                CategorySidebar {
                    id: categorySidebar

                    Layout.preferredWidth: 154
                    Layout.fillHeight: true

                    onCategorySelected: function(category) {
                        Core.ServiceRegistry.search.setCategory(
                            category
                        )

                        searchField.activate()
                    }
                }

                AppGrid {
                    id: appGrid

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }
    }
}
