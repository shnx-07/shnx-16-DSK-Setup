import QtQuick
import Quickshell
import qs.core as Core
import "." as Sections

PopupWindow {
    id: root

    implicitWidth: 411
    implicitHeight: 586

    color: "transparent"
    grabFocus: true

    property int horizontalOffset: -28
    property int verticalOffset: 15

    anchor.item: Core.PanelController.anchorItem
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Left

    anchor.rect.x:
        Core.PanelController.anchorItem
            ? Core.PanelController.anchorItem.width
                + horizontalOffset
            : horizontalOffset

    anchor.rect.y:
        Core.PanelController.anchorItem
            ? Core.PanelController.anchorItem.height
                + verticalOffset
            : verticalOffset

    anchor.adjustment:
        PopupAdjustment.Flip
        | PopupAdjustment.Slide

    visible:
        Core.PanelController.quickSettingsOpen
        && Core.PanelController.anchorItem !== null

    Sections.BatterySection {
        anchors.fill: parent

        visible:
            Core.PanelController.selectedSection
                === "battery"

        onCloseRequested:
            Core.PanelController.close()
    }

    Sections.WifiSection {
        anchors.fill: parent

        visible:
            Core.PanelController.selectedSection
                === "wifi"

        onCloseRequested:
            Core.PanelController.close()
    }

    Sections.BluetoothSection {
        anchors.fill: parent

        visible:
            Core.PanelController.selectedSection
                === "bluetooth"

        onCloseRequested:
            Core.PanelController.close()
    }

    onVisibleChanged: {
        if (!visible
                && Core.PanelController.quickSettingsOpen) {
            Core.PanelController.close()
        }
    }
}
