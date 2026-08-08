import QtQuick

import qs.core as Core
import qs.theme as ShellTheme

import "../../motion" as Motion
import "." as WallpaperParts


Item {
    id: root

    readonly property var wallpaperService:
        Core.ServiceRegistry.wallpaper

    property bool syncingSelection: false


    readonly property bool hasWallpapers:
        wallpaperService
        && wallpaperService.library
        && wallpaperService.library.length > 0


    /*
     * Base card size.
     *
     * Side cards stay close to this size.
     * The selected card becomes larger through PathView scale.
     */
    readonly property real cardWidth:
        Math.max(
            240,
            Math.min(
                width * 0.255,
                360
            )
        )

    readonly property real cardHeight:
        cardWidth * 9 / 16


    function wallpaperAt(index) {
        if (!wallpaperService
                || !wallpaperService.library) {
            return null
        }

        if (index < 0
                || index >= wallpaperService.library.length) {
            return null
        }

        return wallpaperService.library[index]
    }


    function wallpaperPath(wallpaper) {
        if (!wallpaper)
            return ""

        if (typeof wallpaper === "string")
            return wallpaper

        if (wallpaper.path !== undefined)
            return wallpaper.path

        return ""
    }


    function sameWallpaper(first, second) {
        const firstPath =
            wallpaperPath(first)

        const secondPath =
            wallpaperPath(second)

        return firstPath.length > 0
            && secondPath.length > 0
            && firstPath === secondPath
    }


    function indexForWallpaper(wallpaper) {
        if (!wallpaperService
                || !wallpaperService.library) {
            return -1
        }

        const targetPath =
            wallpaperPath(wallpaper)

        if (!targetPath)
            return -1

        for (let index = 0;
             index < wallpaperService.library.length;
             index++) {

            if (
                wallpaperPath(
                    wallpaperService.library[index]
                ) === targetPath
            ) {
                return index
            }
        }

        return -1
    }


    function syncSelectionFromService() {
        if (!root.hasWallpapers)
            return

        let index =
            indexForWallpaper(
                wallpaperService.selectedWallpaper
            )

        if (index < 0)
            index = 0

        if (coverFlow.currentIndex === index)
            return

        syncingSelection = true

        coverFlow.currentIndex =
            index

        syncingSelection = false
    }


    /*
     * ------------------------------------------------------------
     * Smooth browsing
     * ------------------------------------------------------------
     */

    function moveSelection(direction) {
        if (!root.hasWallpapers)
            return

        if (direction < 0) {
            if (coverFlow.currentIndex > 0)
                coverFlow.decrementCurrentIndex()

            return
        }

        if (
            direction > 0
            && coverFlow.currentIndex
                < wallpaperService.library.length - 1
        ) {
            coverFlow.incrementCurrentIndex()
        }
    }


    /*
     * Apply a wallpaper selected by index.
     *
     * Selection itself is handled by PathView's
     * onCurrentIndexChanged handler.
     *
     * Keeping selection and application separate avoids
     * duplicate selectionChanged traffic during a click.
     */
    function activateIndex(index) {
        if (!wallpaperService)
            return

        if (wallpaperService.applying)
            return

        if (!wallpaperService.library)
            return

        if (
            index < 0
            || index >= wallpaperService.library.length
        ) {
            return
        }

        const wallpaper =
            wallpaperAt(index)

        if (!wallpaper)
            return

        /*
         * Move the clicked wallpaper into the center.
         *
         * onCurrentIndexChanged owns selectWallpaper().
         */
        if (coverFlow.currentIndex !== index) {
            coverFlow.currentIndex =
                index
        }

        /*
         * Apply only after the index/selection state has
         * been established.
         */
        wallpaperService.applyWallpaper(
            wallpaper
        )
    }


    function applySelected() {
        if (!wallpaperService)
            return

        if (wallpaperService.applying)
            return

        const wallpaper =
            wallpaperAt(
                coverFlow.currentIndex
            )

        if (!wallpaper)
            return

        wallpaperService.applyWallpaper(
            wallpaper
        )
    }


    /*
     * ------------------------------------------------------------
     * Keyboard
     * ------------------------------------------------------------
     */

    focus: true
    activeFocusOnTab: true

    Keys.onLeftPressed: function(event) {
        root.moveSelection(-1)
        event.accepted = true
    }

    Keys.onRightPressed: function(event) {
        root.moveSelection(1)
        event.accepted = true
    }

    Keys.onReturnPressed: function(event) {
        root.applySelected()
        event.accepted = true
    }

    Keys.onEnterPressed: function(event) {
        root.applySelected()
        event.accepted = true
    }


    /*
     * ------------------------------------------------------------
     * Full-width cinematic cover flow
     * ------------------------------------------------------------
     */

    PathView {
        id: coverFlow

        anchors.fill:
            parent

        model:
            root.wallpaperService
                ? root.wallpaperService.library
                : []

        currentIndex:
            -1


        /*
         * Keep enough wallpapers visible to create the continuous
         * horizontal gallery from the reference.
         */
        pathItemCount:
            Math.min(
                count,
                9
            )

        cacheItemCount:
            6


        /*
         * Current wallpaper lives exactly in the middle of the path.
         */
        preferredHighlightBegin:
            0.5

        preferredHighlightEnd:
            0.5

        highlightRangeMode:
            PathView.StrictlyEnforceRange


        /*
         * Important for the smooth selector feel.
         */
        highlightMoveDuration:
            Motion.MotionTokens.spatial

        snapMode:
            PathView.SnapOneItem

        flickDeceleration:
            1350

        maximumFlickVelocity:
            2200

        dragMargin:
            width

        clip:
            false


        delegate: Item {
            id: delegateRoot

            required property int index
            required property var modelData

            width:
                root.cardWidth

            height:
                root.cardHeight


            /*
             * PathView interpolates all four of these while the
             * wallpaper travels toward / away from the center.
             *
             * No Behavior is added here intentionally.
             */
            scale:
                PathView.cardScale

            opacity:
                PathView.cardOpacity

            z:
                PathView.cardDepth


            transform: Rotation {
                origin.x:
                    delegateRoot.width / 2

                origin.y:
                    delegateRoot.height / 2

                axis.x: 0
                axis.y: 1
                axis.z: 0

                angle:
                    PathView.cardAngle !== undefined
                        ? PathView.cardAngle
                        : 0
            }


            WallpaperParts.WallpaperCarouselCard {
                anchors.fill:
                    parent

                wallpaper:
                    delegateRoot.modelData

                selected:
                    PathView.isCurrentItem

                current:
                    root.sameWallpaper(
                        delegateRoot.modelData,
                        root.wallpaperService
                            ? root.wallpaperService.currentWallpaper
                            : null
                    )

                applying:
                    root.wallpaperService
                    && root.wallpaperService.applying
                    && root.sameWallpaper(
                        delegateRoot.modelData,
                        root.wallpaperService.pendingApplyWallpaper
                    )

                interactive:
                    !root.wallpaperService
                    || !root.wallpaperService.applying


                /*
                 * IMPORTANT:
                 *
                 * Do not manipulate PathView/current wallpaper
                 * synchronously from inside the delegate's click
                 * release.
                 *
                 * PathView may be moving/recycling delegates at the
                 * same time. Capture the plain integer index first,
                 * then activate it on the next event-loop turn.
                 */
                onClicked: {
                    const clickedIndex =
                        delegateRoot.index

                    Qt.callLater(function() {
                        if (!root.wallpaperService)
                            return

                        if (root.wallpaperService.applying)
                            return

                        if (
                            clickedIndex < 0
                            || !root.wallpaperService.library
                            || clickedIndex
                                >= root.wallpaperService.library.length
                        ) {
                            return
                        }

                        root.forceActiveFocus()

                        root.activateIndex(
                            clickedIndex
                        )
                    })
                }
            }
        }


        /*
         * --------------------------------------------------------
         * Full-width invisible gallery path
         * --------------------------------------------------------
         *
         * All cards share nearly the same vertical center.
         * The selected card looks taller because it scales UP,
         * rather than side cards shrinking dramatically.
         */

        path: Path {
            /*
             * FAR LEFT
             */
            startX:
                -root.cardWidth * 0.18

            startY:
                coverFlow.height * 0.50


            PathAttribute {
                name: "cardScale"
                value: 0.88
            }

            PathAttribute {
                name: "cardOpacity"
                value: 0.72
            }

            PathAttribute {
                name: "cardAngle"
                value: 32
            }

            PathAttribute {
                name: "cardDepth"
                value: 5
            }


            /*
             * OUTER LEFT
             */
            PathLine {
                x:
                    coverFlow.width * 0.16

                y:
                    coverFlow.height * 0.50
            }

            PathAttribute {
                name: "cardScale"
                value: 0.92
            }

            PathAttribute {
                name: "cardOpacity"
                value: 0.88
            }

            PathAttribute {
                name: "cardAngle"
                value: 23
            }

            PathAttribute {
                name: "cardDepth"
                value: 20
            }


            /*
             * INNER LEFT
             */
            PathLine {
                x:
                    coverFlow.width * 0.325

                y:
                    coverFlow.height * 0.50
            }

            PathAttribute {
                name: "cardScale"
                value: 0.98
            }

            PathAttribute {
                name: "cardOpacity"
                value: 1.0
            }

            PathAttribute {
                name: "cardAngle"
                value: 14
            }

            PathAttribute {
                name: "cardDepth"
                value: 50
            }


            /*
             * CENTER
             *
             * This is intentionally the major visual difference:
             * neighboring cards remain almost normal size while the
             * current wallpaper grows noticeably forward.
             */
            PathLine {
                x:
                    coverFlow.width * 0.50

                y:
                    coverFlow.height * 0.50
            }

            PathAttribute {
                name: "cardScale"
                value: 1.22
            }

            PathAttribute {
                name: "cardOpacity"
                value: 1.0
            }

            PathAttribute {
                name: "cardAngle"
                value: 0
            }

            PathAttribute {
                name: "cardDepth"
                value: 100
            }


            /*
             * INNER RIGHT
             */
            PathLine {
                x:
                    coverFlow.width * 0.675

                y:
                    coverFlow.height * 0.50
            }

            PathAttribute {
                name: "cardScale"
                value: 0.98
            }

            PathAttribute {
                name: "cardOpacity"
                value: 1.0
            }

            PathAttribute {
                name: "cardAngle"
                value: -14
            }

            PathAttribute {
                name: "cardDepth"
                value: 50
            }


            /*
             * OUTER RIGHT
             */
            PathLine {
                x:
                    coverFlow.width * 0.84

                y:
                    coverFlow.height * 0.50
            }

            PathAttribute {
                name: "cardScale"
                value: 0.92
            }

            PathAttribute {
                name: "cardOpacity"
                value: 0.88
            }

            PathAttribute {
                name: "cardAngle"
                value: -23
            }

            PathAttribute {
                name: "cardDepth"
                value: 20
            }


            /*
             * FAR RIGHT
             */
            PathLine {
                x:
                    coverFlow.width
                    + root.cardWidth * 0.18

                y:
                    coverFlow.height * 0.50
            }

            PathAttribute {
                name: "cardScale"
                value: 0.88
            }

            PathAttribute {
                name: "cardOpacity"
                value: 0.72
            }

            PathAttribute {
                name: "cardAngle"
                value: -32
            }

            PathAttribute {
                name: "cardDepth"
                value: 5
            }
        }


        /*
         * Browsing changes selection only.
         *
         * This is the single owner of selectWallpaper()
         * for carousel index changes.
         */
        onCurrentIndexChanged: {
            if (root.syncingSelection)
                return

            if (!root.wallpaperService)
                return

            const wallpaper =
                root.wallpaperAt(
                    currentIndex
                )

            if (!wallpaper)
                return

            root.wallpaperService.selectWallpaper(
                wallpaper
            )
        }


        onCountChanged: {
            Qt.callLater(
                root.syncSelectionFromService
            )
        }
    }


    Timer {
        id: wheelUnlockTimer

        interval:
            Motion.MotionTokens.standard

        repeat:
            false

        onTriggered: {
            wheelHandler.locked = false
        }
    }


    WheelHandler {
        id: wheelHandler

        target:
            null

        property bool locked: false


        onWheel: function(event) {
            root.forceActiveFocus()

            if (locked) {
                event.accepted = true
                return
            }

            if (
                event.angleDelta.y > 0
                || event.angleDelta.x < 0
            ) {
                root.moveSelection(-1)

                locked = true

                wheelUnlockTimer.restart()

            } else if (
                event.angleDelta.y < 0
                || event.angleDelta.x > 0
            ) {
                root.moveSelection(1)

                locked = true

                wheelUnlockTimer.restart()
            }

            event.accepted = true
        }
    }


    /*
     * ------------------------------------------------------------
     * Service synchronization
     * ------------------------------------------------------------
     */

    Connections {
        target:
            root.wallpaperService


        function onSelectionChanged(wallpaper) {
            const index =
                root.indexForWallpaper(
                    wallpaper
                )

            if (
                index < 0
                || index === coverFlow.currentIndex
            ) {
                return
            }

            root.syncingSelection = true

            coverFlow.currentIndex =
                index

            root.syncingSelection = false
        }


        function onLibraryChangedByBackend() {
            Qt.callLater(
                root.syncSelectionFromService
            )
        }


        function onWallpaperApplied(wallpaper) {
            Qt.callLater(
                root.syncSelectionFromService
            )
        }
    }


    Component.onCompleted: {
        Qt.callLater(
            root.syncSelectionFromService
        )
    }
}
