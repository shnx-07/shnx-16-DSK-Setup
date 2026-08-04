import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.core as Core

PopupWindow {
    id: root

    implicitWidth: 480
    implicitHeight: 820

    color: "transparent"
    grabFocus: true

    property int horizontalOffset: 14
    property int verticalOffset: 15

    anchor.item: Core.PanelController.anchorItem
    anchor.edges: Edges.Bottom | Edges.Left
    anchor.gravity: Edges.Bottom | Edges.Right

    anchor.rect.x: horizontalOffset

    anchor.rect.y:
        Core.PanelController.anchorItem
            ? Core.PanelController.anchorItem.height
                + verticalOffset
            : verticalOffset

    anchor.adjustment:
        PopupAdjustment.Flip
        | PopupAdjustment.Slide

    visible:
        Core.PanelController.profileHubOpen
        && Core.PanelController.anchorItem !== null

    Rectangle {
        id: panelSurface

        anchors.fill: parent

        radius: 24
        color: "#f016191f"

        border.width: 1
        border.color: "#26313d"

        Flickable {
            id: panelScroll

            anchors.fill: parent
            anchors.margins: 16

            clip: true

            contentWidth: width
            contentHeight: contentColumn.implicitHeight

            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: contentColumn

                width: panelScroll.width
                spacing: 12

                /*
                 * Profile identity
                 */
                ProfileCard {
                    width: parent.width
                }

                /*
                 * Applications + CPU/RAM/Disk row
                 */
                Rectangle {
                    id: launcherMetricsContainer

                    width: parent.width
                    height: 132

                    radius: 20
                    color: "#a91b2027"

                    border.width: 1
                    border.color: "#1e2934"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12

                        spacing: 10

                        AppsLauncherButton {
                            id: applicationsButton

                            Layout.preferredWidth: 145
                            Layout.minimumWidth: 145
                            Layout.maximumWidth: 145
                            Layout.fillHeight: true

                            onClicked: {
                                Core.PanelController.openAppLauncher(
                                    Core.PanelController.anchorItem
                                )
                            }
                        }

                        SystemMetricsSection {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }
                    }
                }

                /*
                 * Shared volume and brightness visual section.
                 * AudioSlider and BrightnessSlider remain separate components.
                 */
                Rectangle {
                    id: controlsContainer

                    width: parent.width
                    height: 178

                    radius: 20
                    color: "#a91b2027"

                    border.width: 1
                    border.color: "#1e2934"

                    Column {
                        anchors.fill: parent
                        anchors.margins: 15

                        spacing: 8

                        Text {
                            text: "CONTROLS"

                            color: "#7f8b9b"

                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                            font.letterSpacing: 1.2
                        }

                        AudioSlider {
                            width: parent.width
                            height: 72
                        }

                        Rectangle {
                            width: parent.width
                            height: 1

                            color: "#25303a"
                        }

                        BrightnessSlider {
                            width: parent.width
                            height: 62
                        }
                    }
                }

                /*
                 * Eight quick-setting tiles
                 */
                QuickSettingsSection {
                    width: parent.width
                    height: 340
                }

                /*
                 * Connected devices and active routes
                 */
                DeviceStatusSection {
                    width: parent.width
                }

                /*
                 * Profile and session actions
                 */
                ProfileActions {
                    width: parent.width
                }

                /*
                 * Bottom breathing room so the final card does not sit
                 * directly against the scrolling boundary.
                 */
                Item {
                    width: parent.width
                    height: 4
                }
            }
        }
    }

    onVisibleChanged: {
        if (!visible
                && Core.PanelController.profileHubOpen) {
            Core.PanelController.close()
        }
    }
}
