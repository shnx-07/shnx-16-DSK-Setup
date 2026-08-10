import QtQuick
import Quickshell.Services.Notifications

QtObject {
    id: root

    property bool doNotDisturb: false

    // IDs that arrived since the panel was last opened.
    property var unreadNotificationIds: []

    readonly property var notifications:
        notificationServer.trackedNotifications

    readonly property int notificationCount:
        notifications && notifications.values
            ? notifications.values.length
            : 0

    readonly property int unreadCount:
        unreadNotificationIds.length

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

                if (
                    !root.doNotDisturb
                    && !root.isUnread(notification.id)
                ) {
                    root.unreadNotificationIds =
                        root.unreadNotificationIds.concat(
                            [notification.id]
                        )
                }

                console.log(
                    "[NotificationService] received:",
                    notification.appName,
                    notification.summary
                )
            }
        }

    function isUnread(notificationId) {
        return unreadNotificationIds.indexOf(
            notificationId
        ) !== -1
    }

    function markAllRead() {
        unreadNotificationIds = []
    }

    function dismiss(notification) {
        if (!notification)
            return

        removeUnreadId(notification.id)
        notification.dismiss()
    }

    function removeUnreadId(notificationId) {
        const updatedIds = []

        for (
            let index = 0;
            index < unreadNotificationIds.length;
            index++
        ) {
            const currentId =
                unreadNotificationIds[index]

            if (currentId !== notificationId)
                updatedIds.push(currentId)
        }

        unreadNotificationIds = updatedIds
    }

    function clearAll() {
        if (!notifications || !notifications.values)
            return

        const currentNotifications =
            notifications.values.slice()

        // Clear the unread state before dismissing objects,
        // because notification objects are destroyed on close.
        unreadNotificationIds = []

        for (
            let index = 0;
            index < currentNotifications.length;
            index++
        ) {
            const notification =
                currentNotifications[index]

            if (notification)
                notification.dismiss()
        }
    }

    function setDoNotDisturb(enabled) {
        doNotDisturb = enabled
    }

    function toggleDoNotDisturb() {
        doNotDisturb = !doNotDisturb
    }
}
