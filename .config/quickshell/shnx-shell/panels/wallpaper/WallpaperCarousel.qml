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


    function moveSelection(direction) {
        if (!root.hasWallpapers)
            return

        if (direction < 0) {
            coverFlow.decrementCurrentIndex()
        } else if (direction > 0) {
            coverFlow.incrementCurrentIndex()
        }
    }


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

        if (coverFlow.currentIndex !== index) {
            coverFlow.currentIndex =
                index
        }

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

        pathItemCount:
            Math.min(
                count,
                9
            )

        cacheItemCount:
            6

        preferredHighlightBegin:
            0.5

        preferredHighlightEnd:
            0.5

        highlightRangeMode:
            PathView.StrictlyEnforceRange

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

            scale:
                PathView.cardScale

            opacity:
                PathView.cardOpacity

            z:
                PathView.cardDepth


            /*
             * Shear (skew) transform — replaces the old 3D Rotation.
             *
             * Produces the flat parallelogram look from the
             * reference image instead of a perspective tilt.
             * Shear pivots around the card's own center, then the
             * item is translated back into place.
             */
            transform: [
                Translate {
                    x: -delegateRoot.width / 2
                    y: -delegateRoot.height / 2
                },
                Matrix4x4 {
                    matrix: Qt.matrix4x4(
                        1, (delegateRoot.PathView.cardShear !== undefined ? delegateRoot.PathView.cardShear : 0), 0, 0,
                        0, 1,                                                                                     0, 0,
                        0, 0,                                                                                     1, 0,
                        0, 0,                                                                                     0, 1
                    )
                },
                Translate {
                    x: delegateRoot.width / 2
                    y: delegateRoot.height / 2
                }
            ]


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


        path: Path {
            startX:
                -root.cardWidth * 0.10
            startY:
                coverFlow.height * 0.50
            PathAttribute {
                name: "cardScale"
                value: 0.90
            }
            PathAttribute {
                name: "cardOpacity"
                value: 0.75
            }
            PathAttribute {
                name: "cardShear"
                value: 0.55
            }
            PathAttribute {
                name: "cardDepth"
                value: 5
            }
            PathLine {
                x:
                    coverFlow.width * 0.20
                y:
                    coverFlow.height * 0.50
            }
            PathAttribute {
                name: "cardScale"
                value: 0.90
            }
            PathAttribute {
                name: "cardOpacity"
                value: 0.90
            }
            PathAttribute {
                name: "cardShear"
                value: 0.42
            }
            PathAttribute {
                name: "cardDepth"
                value: 20
            }
            PathLine {
                x:
                    coverFlow.width * 0.35
                y:
                    coverFlow.height * 0.50
            }
            PathAttribute {
                name: "cardScale"
                value: 0.94
            }
            PathAttribute {
                name: "cardOpacity"
                value: 1.0
            }
            PathAttribute {
                name: "cardShear"
                value: 0.26
            }
            PathAttribute {
                name: "cardDepth"
                value: 50
            }
            PathLine {
                x:
                    coverFlow.width * 0.50
                y:
                    coverFlow.height * 0.50
            }
            PathAttribute {
                name: "cardScale"
                value: 1.15
            }
            PathAttribute {
                name: "cardOpacity"
                value: 1.0
            }
            PathAttribute {
                name: "cardShear"
                value: 0
            }
            PathAttribute {
                name: "cardDepth"
                value: 100
            }
            PathLine {
                x:
                    coverFlow.width * 0.65
                y:
                    coverFlow.height * 0.50
            }
            PathAttribute {
                name: "cardScale"
                value: 0.94
            }
            PathAttribute {
                name: "cardOpacity"
                value: 1.0
            }
            PathAttribute {
                name: "cardShear"
                value: -0.26
            }
            PathAttribute {
                name: "cardDepth"
                value: 50
            }
            PathLine {
                x:
                    coverFlow.width * 0.80
                y:
                    coverFlow.height * 0.50
            }
            PathAttribute {
                name: "cardScale"
                value: 0.90
            }
            PathAttribute {
                name: "cardOpacity"
                value: 0.90
            }
            PathAttribute {
                name: "cardShear"
                value: -0.42
            }
            PathAttribute {
                name: "cardDepth"
                value: 20
            }
            PathLine {
                x:
                    coverFlow.width
                    + root.cardWidth * 0.10
                y:
                    coverFlow.height * 0.50
            }
            PathAttribute {
                name: "cardScale"
                value: 0.90
            }
            PathAttribute {
                name: "cardOpacity"
                value: 0.75
            }
            PathAttribute {
                name: "cardShear"
                value: -0.55
            }
            PathAttribute {
                name: "cardDepth"
                value: 5
            }
        }


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
