import QtQuick

import "../../motion" as Motion

Item {
    id: root

    default property alias content:
        contentRow.data

    property int currentIndex: 0

    property int pageCount:
        contentRow.children.length

    property bool enabled: true

    property real swipeThreshold: width * 0.18
    property real velocityThreshold: 700

    signal pageChanged(int index)

    clip: true

    function clampIndex(index) {
        if (root.pageCount <= 0)
            return 0

        return Math.max(
            0,
            Math.min(
                root.pageCount - 1,
                index
            )
        )
    }

    function goToPage(index) {
        const nextIndex =
            root.clampIndex(index)

        if (nextIndex === root.currentIndex)
            return

        root.currentIndex =
            nextIndex

        root.pageChanged(
            nextIndex
        )
    }

    function nextPage() {
        goToPage(
            root.currentIndex + 1
        )
    }

    function previousPage() {
        goToPage(
            root.currentIndex - 1
        )
    }

    Item {
        id: viewport

        anchors.fill: parent

        Row {
            id: contentRow

            height:
                parent.height

            x:
                -root.currentIndex * root.width
                + dragOffset

            property real dragOffset: 0

            Behavior on x {
                enabled:
                    !dragHandler.active

                NumberAnimation {
                    duration:
                        Motion.MotionTokens.spatial

                    easing.type:
                        Motion.Easing.emphasized
                }
            }
        }
    }

    DragHandler {
        id: dragHandler

        enabled:
            root.enabled
            && root.pageCount > 1

        target: null

        xAxis.enabled: true
        yAxis.enabled: false

        onActiveChanged: {
            if (active)
                return

            const distance =
                contentRow.dragOffset

            const velocity =
                centroid.velocity.x

            let nextIndex =
                root.currentIndex

            if (
                distance <= -root.swipeThreshold
                || velocity <= -root.velocityThreshold
            ) {
                nextIndex++
            } else if (
                distance >= root.swipeThreshold
                || velocity >= root.velocityThreshold
            ) {
                nextIndex--
            }

            contentRow.dragOffset = 0

            root.goToPage(
                nextIndex
            )
        }

        onTranslationChanged: {
            let offset =
                translation.x

            /*
             * Add resistance at the first/last page
             * rather than allowing unrestricted dragging.
             */
            if (
                root.currentIndex === 0
                && offset > 0
            ) {
                offset *= 0.25
            }

            if (
                root.currentIndex
                    === root.pageCount - 1
                && offset < 0
            ) {
                offset *= 0.25
            }

            contentRow.dragOffset =
                offset
        }
    }

    onCurrentIndexChanged: {
        const correctedIndex =
            clampIndex(currentIndex)

        if (correctedIndex !== currentIndex) {
            currentIndex =
                correctedIndex
        }
    }
}
