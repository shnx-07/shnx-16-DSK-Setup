import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.core as Core
import Quickshell.Wayland

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
        radius: 24
        color: "#f016191f"

        border.width: 1
        border.color: "#26313d"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18

            spacing: 14

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 42

                Text {
                    text: "Applications"
                    color: "#f2f4f7"

                    font.pixelSize: 22
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
                            ? "#3b4654"
                            : closeMouseArea.containsMouse
                                ? "#303a46"
                                : "#252d37"

                    border.width: 1
                    border.color: "#394552"

                    Text {
                        anchors.centerIn: parent

                        text: "󰅖"
                        color: "#dce2e9"

                        font.pixelSize: 15
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
