import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland

import qs.core as Core
import qs.theme as ShellTheme
import qs.motion as Motion
import qs.components.visual as Visual

PanelWindow {
    id: root

    /*
     * ------------------------------------------------------------
     * WINDOW
     * ------------------------------------------------------------
     */

    implicitWidth:
        780

    implicitHeight:
        680

    color:
        "transparent"

    visible:
        Core.PanelController.appLauncherOpen

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    exclusionMode:
        ExclusionMode.Ignore

    aboveWindows:
        true

    focusable:
        true

    /*
     * ------------------------------------------------------------
     * OPEN / CLOSE STATE
     * ------------------------------------------------------------
     */

    onVisibleChanged: {
        if (visible) {
            Core.ServiceRegistry.search.setQuery("")
            Core.ServiceRegistry.search.setCategory("All")

            searchField.clear()

            categorySidebar.selectedCategory =
                "All"

            appGrid.resetSelection()

            Qt.callLater(function() {
                searchField.activate()
            })
        } else if (Core.PanelController.appLauncherOpen) {
            Core.PanelController.close()
        }
    }

    /*
     * ------------------------------------------------------------
     * KEYBOARD
     * ------------------------------------------------------------
     */

    Shortcut {
        sequence:
            "Escape"

        context:
            Qt.WindowShortcut

        enabled:
            root.visible

        onActivated:
            Core.PanelController.close()
    }

    Shortcut {
        sequence:
            "Left"

        context:
            Qt.WindowShortcut

        enabled:
            root.visible
            && appGrid.applicationCount > 0

        onActivated:
            appGrid.moveSelection(-1)
    }

    Shortcut {
        sequence:
            "Right"

        context:
            Qt.WindowShortcut

        enabled:
            root.visible
            && appGrid.applicationCount > 0

        onActivated:
            appGrid.moveSelection(1)
    }

    Shortcut {
        sequence:
            "Up"

        context:
            Qt.WindowShortcut

        enabled:
            root.visible
            && appGrid.applicationCount > 0

        onActivated:
            appGrid.moveSelectionByRow(-1)
    }

    Shortcut {
        sequence:
            "Down"

        context:
            Qt.WindowShortcut

        enabled:
            root.visible
            && appGrid.applicationCount > 0

        onActivated:
            appGrid.moveSelectionByRow(1)
    }

    /*
     * ------------------------------------------------------------
     * MAIN SURFACE
     * ------------------------------------------------------------
     */

    Rectangle {
        id: panelSurface

        width:
            780

        height:
            680

        anchors.centerIn:
            parent

        antialiasing:
            false

        radius:
            ShellTheme.Theme.radius.panel

        color:
            ShellTheme.Theme.colors.background

        border.width:
            0

        /*
         * --------------------------------------------------------
         * MAIN LAYOUT
         * --------------------------------------------------------
         */

        ColumnLayout {
            anchors {
                fill: parent

                margins:
                    ShellTheme.Theme.spacing.large
            }

            spacing:
                ShellTheme.Theme.spacing.medium

            /*
             * ----------------------------------------------------
             * HEADER
             * ----------------------------------------------------
             */

            RowLayout {
                Layout.fillWidth:
                    true

                Layout.preferredHeight:
                    36

                Text {
                    text:
                        "Applications"

                    color:
                        ShellTheme.Theme.colors.on_surface

                    font.family:
                        ShellTheme.Theme.typography.fontFamily

                    font.pixelSize:
                        ShellTheme.Theme.typography.headlineMedium

                    font.weight:
                        Font.DemiBold
                }

                Item {
                    Layout.fillWidth:
                        true
                }

                Item {
                    id: closeButton

                    Layout.preferredWidth:
                        34

                    Layout.preferredHeight:
                        34

                    scale:
                        closeMouseArea.pressed
                            ? Motion.MotionTokens.compactPressScale
                            : closeMouseArea.containsMouse
                                ? Motion.MotionTokens.hoverScale
                                : 1.0

                    Behavior on scale {
                        NumberAnimation {
                            duration:
                                Motion.MotionTokens.quick

                            easing.type:
                                Motion.Easing.standard
                        }
                    }

                    Rectangle {
                        anchors.fill:
                            parent

                        antialiasing:
                            false

                        radius:
                            ShellTheme.Theme.radius.button

                        color:
                            closeMouseArea.pressed
                                ? ShellTheme.Theme.colors.pressedOverlay
                                : closeMouseArea.containsMouse
                                    ? ShellTheme.Theme.colors.hoverOverlay
                                    : "transparent"

                        Behavior on color {
                            ColorAnimation {
                                duration:
                                    Motion.MotionTokens.quick

                                easing.type:
                                    Motion.Easing.standard
                            }
                        }
                    }

                    Visual.Icon {
                        anchors.centerIn:
                            parent

                        glyph:
                            "󰅖"

                        iconSize:
                            17

                        color:
                            ShellTheme.Theme.colors.on_surface_variant
                    }

                    MouseArea {
                        id: closeMouseArea

                        anchors.fill:
                            parent

                        hoverEnabled:
                            true

                        cursorShape:
                            Qt.PointingHandCursor

                        onClicked:
                            Core.PanelController.close()
                    }
                }
            }

            /*
             * ----------------------------------------------------
             * SEARCH
             * ----------------------------------------------------
             */

            SearchField {
                id: searchField

                Layout.fillWidth:
                    true

                onTextChanged: {
                    if (text.trim().length > 0
                            && Core.ServiceRegistry.search.selectedCategory
                                !== "All") {
                        Core.ServiceRegistry.search.setCategory(
                            "All"
                        )

                        categorySidebar.selectedCategory =
                            "All"
                    }

                    Core.ServiceRegistry.search.setQuery(
                        text
                    )
                }

                onSubmitted:
                    appGrid.launchSelected()

                onCleared:
                    Core.ServiceRegistry.search.setQuery("")

                onMoveLeftRequested:
                    appGrid.moveSelection(-1)

                onMoveRightRequested:
                    appGrid.moveSelection(1)
            }

            /*
             * ----------------------------------------------------
             * CONTENT
             * ----------------------------------------------------
             */

            RowLayout {
                Layout.fillWidth:
                    true

                Layout.fillHeight:
                    true

                spacing:
                    ShellTheme.Theme.spacing.medium

                CategorySidebar {
                    id: categorySidebar

                    Layout.preferredWidth:
                        146

                    Layout.fillHeight:
                        true

                    onCategorySelected: function(category) {
                        Core.ServiceRegistry.search.setCategory(
                            category
                        )

                        searchField.activate()
                    }
                }

                AppGrid {
                    id: appGrid

                    Layout.fillWidth:
                        true

                    Layout.fillHeight:
                        true
                }
            }
        }
    }
}
