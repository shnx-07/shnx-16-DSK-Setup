import QtQuick

import qs.core as Core
import qs.theme as ShellTheme

import "." as WallpaperParts


FocusScope {
    id: root

    property var wallpapers:
        Core.ServiceRegistry.wallpaper.library

    readonly property var wallpaperService:
        Core.ServiceRegistry.wallpaper

    property int selectedIndex: -1

    property real dragStartX: 0
    property real dragDistance: 0


    readonly property int itemCount:
        wallpapers
            ? wallpapers.length
            : 0

    readonly property bool hasItems:
        itemCount > 0


    /*
     * ------------------------------------------------------------
     * Gallery geometry
     * ------------------------------------------------------------
     *
     * We keep your working Repeater architecture.
     *
     * Center wallpaper is wide.
     * Side wallpapers become narrow slices.
     *
     * No curved PathView.
     * No different vertical levels.
     * No perspective rotation.
     */

    readonly property real selectedCardWidth:
        Math.min(
            width * 0.48,
            560
        )

    readonly property real selectedCardHeight:
        selectedCardWidth * 0.58

    readonly property real sideCardWidth:
        Math.max(
            118,
            selectedCardWidth * 0.31
        )

    readonly property real sideCardHeight:
        selectedCardHeight * 0.88

    readonly property real cardGap:
        10

    /*
     * Distance between center of selected card and
     * center of first neighbour.
     */
    /*
    * Fixed center-to-center slot distance.
    *
    * This does NOT change during the animation.
    * That is what removes the temporary gap.
    */
    readonly property real slotStep:
        sideCardWidth
        + cardGap


    /*
     * Returns the horizontal center offset for each card.
     *
     * Example:
     *
     * -2       -1          0          +1       +2
     *
     * slice   slice     SELECTED     slice    slice
     */
    function horizontalOffset(relativeIndex) {
        if (relativeIndex === 0)
            return 0

        const direction =
            relativeIndex < 0
                ? -1
                : 1

        const distance =
            Math.abs(relativeIndex)

        /*
        * First neighbour needs extra room because the selected
        * wallpaper is wider.
        *
        * Everything after that uses one fixed slot width.
        */
        const selectedHalf =
            selectedCardWidth / 2

        const sideHalf =
            sideCardWidth / 2

        return direction
            * (
                selectedHalf
                + sideHalf
                + cardGap
                + (distance - 1) * slotStep
            )
    }


    /*
     * ------------------------------------------------------------
     * Selection helpers
     * ------------------------------------------------------------
     */

    function indexForPath(path) {
        if (!path || !wallpapers)
            return -1

        for (
            let index = 0;
            index < wallpapers.length;
            index++
        ) {
            const item =
                wallpapers[index]

            if (
                item
                && item.path === path
            ) {
                return index
            }
        }

        return -1
    }


    function syncSelectionFromService() {
        if (!hasItems) {
            selectedIndex = -1
            return
        }

        const selected =
            wallpaperService.selectedWallpaper

        if (
            selected
            && selected.path
        ) {
            const index =
                indexForPath(
                    selected.path
                )

            if (index >= 0) {
                selectedIndex = index
                return
            }
        }

        selectedIndex = 0

        wallpaperService.selectWallpaper(
            wallpapers[0]
        )
    }


    function normalizeIndex(index) {
        if (!hasItems)
            return -1

        let result =
            index % itemCount

        if (result < 0)
            result += itemCount

        return result
    }


    function selectIndex(index) {
        if (!hasItems)
            return

        const wrappedIndex =
            normalizeIndex(index)

        if (wrappedIndex < 0)
            return

        if (wrappedIndex === selectedIndex)
            return

        selectedIndex =
            wrappedIndex

        wallpaperService.selectWallpaper(
            wallpapers[wrappedIndex]
        )
    }


    function moveSelection(delta) {
        if (!hasItems)
            return

        if (selectedIndex < 0) {
            selectIndex(0)
            return
        }

        selectIndex(
            selectedIndex + delta
        )
    }


    function applySelected() {
        if (
            selectedIndex < 0
            || selectedIndex >= itemCount
            || wallpaperService.applying
        ) {
            return
        }

        wallpaperService.applySelectedWallpaper()
    }


    /*
     * ------------------------------------------------------------
     * Keep carousel aligned with service state
     * ------------------------------------------------------------
     */

    Component.onCompleted:
        syncSelectionFromService()


    onWallpapersChanged:
        Qt.callLater(
            syncSelectionFromService
        )


    Connections {
        target:
            wallpaperService

        function onSelectionChanged(wallpaper) {
            if (!wallpaper || !wallpaper.path)
                return

            const index =
                root.indexForPath(
                    wallpaper.path
                )

            if (index >= 0)
                root.selectedIndex = index
        }
    }


    /*
     * ------------------------------------------------------------
     * Keyboard
     * ------------------------------------------------------------
     */

    Keys.onPressed: function(event) {
        if (!root.hasItems)
            return

        switch (event.key) {
        case Qt.Key_Left:
            root.moveSelection(-1)
            event.accepted = true
            break

        case Qt.Key_Right:
            root.moveSelection(1)
            event.accepted = true
            break

        case Qt.Key_Home:
            root.selectIndex(0)
            event.accepted = true
            break

        case Qt.Key_End:
            root.selectIndex(
                root.itemCount - 1
            )
            event.accepted = true
            break

        case Qt.Key_Return:
        case Qt.Key_Enter:
            root.applySelected()
            event.accepted = true
            break
        }
    }


    /*
     * ------------------------------------------------------------
     * Carousel stage
     * ------------------------------------------------------------
     */

    Item {
        id: stage

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: indicators.top

            bottomMargin:
                ShellTheme.Theme.spacing.medium
        }

        clip: true


        Repeater {
            id: cardRepeater

            model:
                root.wallpapers


            delegate: Item {
              id: delegateRoot

              required property var modelData
              required property int index


              /*
              * ------------------------------------------------------------
              * Circular position
              * ------------------------------------------------------------
              */

              readonly property int relativeIndex: {
                  if (root.itemCount <= 0)
                      return 0

                  let delta =
                      index - root.selectedIndex

                  const half =
                      root.itemCount / 2

                  if (delta > half)
                      delta -= root.itemCount
                  else if (delta < -half)
                      delta += root.itemCount

                  return delta
              }


              readonly property int absoluteOffset:
                  Math.abs(relativeIndex)

              readonly property bool isSelected:
                  relativeIndex === 0


              /*
              * Show more wallpapers on both sides.
              *
              * Change 4 -> 5 later if you want even more.
              */
              readonly property bool isVisibleCard:
                  absoluteOffset <= 4


              readonly property bool isCurrent:
                  root.wallpaperService.currentWallpaper
                  && root.wallpaperService.currentWallpaper.path
                      === modelData.path


              readonly property bool isApplying:
                  root.wallpaperService.applying
                  && root.wallpaperService.selectedWallpaper
                  && root.wallpaperService.selectedWallpaper.path
                      === modelData.path


              /*
              * ------------------------------------------------------------
              * Smooth center positioning
              * ------------------------------------------------------------
              */

              readonly property real targetCenterX:
                  stage.width / 2
                  + root.horizontalOffset(
                      relativeIndex
                  )

              property real animatedCenterX:
                  targetCenterX


              onTargetCenterXChanged: {
                  animatedCenterX =
                      targetCenterX
              }


              /*
              * ------------------------------------------------------------
              * Size
              * ------------------------------------------------------------
              */

              width:
                  isSelected
                      ? root.selectedCardWidth
                      : root.sideCardWidth

              height:
                  isSelected
                      ? root.selectedCardHeight
                      : root.sideCardHeight


              /*
              * Position from the animated CENTER rather than
              * directly animating x.
              *
              * This removes that little temporary gap.
              */
              x:
                  animatedCenterX
                  - width / 2

              y:
                  stage.height / 2
                  - height / 2


              /*
              * ------------------------------------------------------------
              * Fade outward
              * ------------------------------------------------------------
              */

              opacity: {
                  if (!isVisibleCard)
                      return 0.0

                  switch (absoluteOffset) {
                  case 0:
                      return 1.0

                  case 1:
                      return 0.80

                  case 2:
                      return 0.62

                  case 3:
                      return 0.44

                  default:
                      return 0.28
                  }
              }


              visible:
                  opacity > 0.01


              z:
                  20 - absoluteOffset


              /*
              * ------------------------------------------------------------
              * Smooth carousel animation
              * ------------------------------------------------------------
              */

              Behavior on animatedCenterX {
                  NumberAnimation {
                      duration: 300

                      easing.type:
                          Easing.InOutCubic
                  }
              }


              Behavior on width {
                  NumberAnimation {
                      duration: 300

                      easing.type:
                          Easing.InOutCubic
                  }
              }


              Behavior on height {
                  NumberAnimation {
                      duration: 300

                      easing.type:
                          Easing.InOutCubic
                  }
              }


              Behavior on opacity {
                  NumberAnimation {
                      duration: 220

                      easing.type:
                          Easing.InOutCubic
                  }
              }


              /*
              * ------------------------------------------------------------
              * Existing slanted card
              * ------------------------------------------------------------
              */

              Item {
                  id: skewWrapper

                  anchors.fill:
                      parent


                  readonly property real shear:
                      -0.22


                  anchors.horizontalCenterOffset:
                      -height
                      * shear
                      * 0.18


                  transform: Matrix4x4 {
                      matrix:
                          Qt.matrix4x4(
                              1, skewWrapper.shear, 0, 0,
                              0, 1,                 0, 0,
                              0, 0,                 1, 0,
                              0, 0,                 0, 1
                          )
                  }


                  WallpaperParts.WallpaperCarouselCard {
                      anchors.fill:
                          parent

                      wallpaper:
                          delegateRoot.modelData

                      selected:
                          delegateRoot.isSelected

                      current:
                          delegateRoot.isCurrent

                      applying:
                          delegateRoot.isApplying

                      interactive:
                          delegateRoot.isVisibleCard

                      inverseShear:
                          -skewWrapper.shear


                      onClicked: {
                          root.forceActiveFocus()

                          if (
                              delegateRoot.index
                              !== root.selectedIndex
                          ) {
                              root.selectIndex(
                                  delegateRoot.index
                              )

                              return
                          }

                          root.applySelected()
                      }
                  }
              }
          }
        }


        /*
         * --------------------------------------------------------
         * Wheel browsing
         * --------------------------------------------------------
         */

        WheelHandler {
            id: wheelHandler

            target: null

            onWheel: function(event) {
                if (!root.hasItems)
                    return

                if (event.angleDelta.y < 0) {
                    root.moveSelection(1)

                } else if (
                    event.angleDelta.y > 0
                ) {
                    root.moveSelection(-1)
                }

                root.forceActiveFocus()

                event.accepted = true
            }
        }


        /*
         * --------------------------------------------------------
         * Drag / swipe browsing
         * --------------------------------------------------------
         */

        DragHandler {
            id: swipeHandler

            target: null

            xAxis.enabled: true
            yAxis.enabled: false


            onActiveChanged: {
                if (active) {
                    root.dragStartX =
                        centroid.position.x

                    root.dragDistance = 0

                    return
                }

                const threshold =
                    Math.min(
                        90,
                        root.width * 0.08
                    )

                if (
                    Math.abs(
                        root.dragDistance
                    ) < threshold
                ) {
                    root.dragDistance = 0
                    return
                }

                if (root.dragDistance < 0) {
                    root.moveSelection(1)
                } else {
                    root.moveSelection(-1)
                }

                root.dragDistance = 0

                root.forceActiveFocus()
            }


            onCentroidChanged: {
                if (!active)
                    return

                root.dragDistance =
                    centroid.position.x
                    - root.dragStartX
            }
        }
    }


    /*
     * ------------------------------------------------------------
     * Navigation indicators
     * ------------------------------------------------------------
     */

    Row {
        id: indicators

        anchors {
            horizontalCenter:
                parent.horizontalCenter

            bottom:
                parent.bottom
        }

        spacing:
            ShellTheme.Theme.spacing.small

        visible:
            root.itemCount > 1


        Repeater {
            model:
                root.itemCount


            delegate: Rectangle {
              required property int index

              

                width:
                    index === root.selectedIndex
                        ? 18
                        : 6

                height: 6

                radius:
                    ShellTheme.Theme.radius.pill

                color:
                    index === root.selectedIndex
                        ? ShellTheme.Theme.colors.primary
                        : ShellTheme.Theme.colors.outlineVariant

                opacity:
                    index === root.selectedIndex
                        ? 1.0
                        : 0.55


                Behavior on width {
                    NumberAnimation {
                        duration: 180
                        easing.type:
                            Easing.OutCubic
                    }
                }


                Behavior on color {
                    ColorAnimation {
                        duration: 140
                    }
                }


                MouseArea {
                    anchors.fill: parent

                    cursorShape:
                        Qt.PointingHandCursor

                    onClicked:
                        root.selectIndex(
                            index
                        )
                }
            }
        }
    }
}
