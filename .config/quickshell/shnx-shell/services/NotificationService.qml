import QtQuick
import Quickshell.Services.Notifications

QtObject {
    id: root

    property bool doNotDisturb: false
    property int unreadCount: 0

    readonly property var notifications:
        notificationServer.trackedNotifications

    readonly property int notificationCount:
        notifications
        && notifications.values
            ? notifications.values.length
            : 0

    readonly property bool hasUnread:
        unreadCount > 0

    readonly property string badgeText:
        unreadCount > 99
            ? "99+"
            : unreadCount.toString()

    readonly property NotificationServer notificationServer:
        NotificationServer {
            keepOnReload: true

            bodySupported: true
            bodyMarkupSupported: false
            actionsSupported: true
            imageSupported: true
            persistenceSupported: true

            onNotification: notification => {
                notification.tracked = true

                if (!root.doNotDisturb)
                    root.unreadCount += 1

                console.log(
                    "Notification received:",
                    notification.appName,
                    notification.summary
                )
            }
        }

    function markAllRead() {
        unreadCount = 0
    }

    function clearAll() {
        if (!notifications)
            return

        const currentNotifications = notifications.values.slice()

        for (let index = 0;
                index < currentNotifications.length;
                index++) {
            const notification = currentNotifications[index]

            if (notification)
                notification.dismiss()
        }

        unreadCount = 0
    }

    function setDoNotDisturb(enabled) {
        doNotDisturb = enabled
    }

    function toggleDoNotDisturb() {
        doNotDisturb = !doNotDisturb
    }
}
