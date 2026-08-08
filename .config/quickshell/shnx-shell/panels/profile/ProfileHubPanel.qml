import QtQuick
import Quickshell

import qs.core as Core
import qs.theme as ShellTheme

import "../../components/layout" as Layout

PopupWindow {
    id: root

    /*
     * ------------------------------------------------------------
     * Window geometry
     * ------------------------------------------------------------
     */

    implicitWidth: 480
    implicitHeight: 820

    color: "transparent"
    grabFocus: true

    property int horizontalOffset: 14
    property int verticalOffset: 15

    /*
     * ------------------------------------------------------------
     * Popup anchoring
     * ------------------------------------------------------------
     *
     * Preserve the existing stable popup behavior.
     */

    anchor.item:
        Core.PanelController.anchorItem

    anchor.edges:
        Edges.Bottom | Edges.Left

    anchor.gravity:
        Edges.Bottom | Edges.Right

    anchor.rect.x:
        root.horizontalOffset

    anchor.rect.y:
        Core.PanelController.anchorItem
            ? Core.PanelController.anchorItem.height
                + root.verticalOffset
            : root.verticalOffset

    anchor.adjustment:
        PopupAdjustment.Flip
        | PopupAdjustment.Slide

    visible:
        Core.PanelController.profileHubOpen
        && Core.PanelController.anchorItem !== null

    /*
     * ------------------------------------------------------------
     * Main shared panel surface
     * ------------------------------------------------------------
     */

    Layout.Surface {
        id: panelSurface

        anchors.fill: parent

        radius:
            ShellTheme.Theme.radius.island

        backgroundColor:
            ShellTheme.Theme.colors.surfaceContainerLowest

        borderColor:
            ShellTheme.Theme.colors.outlineVariant

        borderWidth: 1

        opacity:
            root.visible
                ? 1.0
                : 0.0

        scale:
            root.visible
                ? 1.0
                : 0.96

        transform: Translate {
            y:
                root.visible
                    ? 0
                    : -10
        }

        Behavior on opacity {
            NumberAnimation {
                duration:
                    Motion.MotionTokens.emphasized

                easing.type:
                    Motion.Easing.enter
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration:
                    Motion.MotionTokens.emphasized

                easing.type:
                    Motion.Easing.emphasized
            }
        }

        Behavior on y {
            NumberAnimation {
                duration:
                    Motion.MotionTokens.emphasized

                easing.type:
                    Motion.Easing.emphasized
            }
        }

        /*
         * --------------------------------------------------------
         * Scrollable profile content
         * --------------------------------------------------------
         */

        Flickable {
            id: panelScroll

            anchors {
                fill: parent

                margins:
                    ShellTheme.Theme.spacing.large
            }

            clip: true

            contentWidth:
                width

            contentHeight:
                contentColumn.implicitHeight

            boundsBehavior:
                Flickable.StopAtBounds

            Column {
                id: contentColumn

                width:
                    panelScroll.width

                spacing:
                    ShellTheme.Theme.spacing.medium

                /*
                 * ------------------------------------------------
                 * PROFILE IDENTITY
                 * ------------------------------------------------
                 *
                 * Main visual anchor of the hub.
                 */

                ProfileCard {
                    width:
                        parent.width
                }

                /*
                 * ------------------------------------------------
                 * SYSTEM METRICS
                 * ------------------------------------------------
                 *
                 * Application Launcher has been deliberately
                 * removed from Profile.
                 *
                 * System metrics now receive the full available
                 * width and remain a lightweight information strip.
                 */

                SystemMetricsSection {
                    width:
                        parent.width

                    height:
                        108
                }

                /*
                 * ------------------------------------------------
                 * PRIMARY CONTROLS
                 * ------------------------------------------------
                 */

                Column {
                    width:
                        parent.width

                    spacing:
                        ShellTheme.Theme.spacing.small

                    Text {
                        text:
                            "CONTROLS"

                        color:
                            ShellTheme.Theme.colors.on_surface_variant

                        font.family:
                            ShellTheme.Theme.typography.fontFamily

                        font.pixelSize:
                            ShellTheme.Theme.typography.labelSmall

                        font.weight:
                            Font.DemiBold

                        font.letterSpacing:
                            1.2
                    }

                    AudioSlider {
                        width: parent.width
                        height: 42
                    }

                    Layout.Divider {
                        width:
                            parent.width
                    }

                    BrightnessSlider {
                        width: parent.width
                        height: 42
                    }
                }

                /*
                 * ------------------------------------------------
                 * QUICK SETTINGS
                 * ------------------------------------------------
                 */

                QuickSettingsSection {
                    width:
                        parent.width

                    height:
                        340
                }

                /*
                 * ------------------------------------------------
                 * DEVICE STATUS
                 * ------------------------------------------------
                 *
                 * DeviceStatusSection itself will later decide
                 * whether meaningful device information exists.
                 */

                DeviceStatusSection {
                    width:
                        parent.width
                }

                /*
                 * ------------------------------------------------
                 * SECTION SEPARATOR
                 * ------------------------------------------------
                 */

                Layout.Divider {
                    width:
                        parent.width
                }

                /*
                 * ------------------------------------------------
                 * PROFILE / SESSION ACTIONS
                 * ------------------------------------------------
                 */

                ProfileActions {
                    width:
                        parent.width
                }

                /*
                 * Bottom breathing room.
                 */

                Item {
                    width:
                        parent.width

                    height:
                        ShellTheme.Theme.spacing.xSmall
                }
            }
        }
    }

    /*
     * ------------------------------------------------------------
     * Popup dismissal
     * ------------------------------------------------------------
     *
     * Keep existing controller synchronization unchanged.
     */

    onVisibleChanged: {
        if (
            !visible
            && Core.PanelController.profileHubOpen
        ) {
            Core.PanelController.close()
        }
    }
}
