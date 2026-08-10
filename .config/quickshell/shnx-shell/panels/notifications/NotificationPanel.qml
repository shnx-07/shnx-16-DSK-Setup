import QtQuick
import Quickshell
import qs.core as Core
import "." as Sections

PopupWindow {
    id: root

    implicitWidth: 411
    implicitHeight: 620

    color: "transparent"
    grabFocus: true

    property int horizontalOffset: -28
    property int verticalOffset: 15

    anchor.item: Core.PanelController.anchorItem
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Left

    anchor.rect.x: Core.PanelController.anchorItem
        ? Core.PanelController.anchorItem.width + horizontalOffset
        : horizontalOffset

    anchor.rect.y: Core.PanelController.anchorItem
        ? Core.PanelController.anchorItem.height + verticalOffset
        : verticalOffset

    anchor.adjustment:
        PopupAdjustment.Flip
        | PopupAdjustment.Slide

    visible:
        Core.PanelController.notificationsOpen
        && Core.PanelController.anchorItem !== null

    Column {
        anchors.fill: parent
        spacing: 10

        Sections.WeatherSection {
            width: parent.width
            height: 180
        }

        Sections.NotificationsSection {
            width: parent.width
            height: parent.height - 190

            onCloseRequested:
                Core.PanelController.close()
        }
    }

    onVisibleChanged: {
        if (visible) {
            Core.ServiceRegistry.notifications.markAllRead()
            return
        }

        if (Core.PanelController.notificationsOpen)
            Core.PanelController.close()
    }
}
