pragma Singleton

import QtQuick

QtObject {
    id: root

    /*
     * ------------------------------------------------------------
     * Global SHNX motion timing
     * ------------------------------------------------------------
     *
     * These are semantic timings rather than component-specific
     * timings.
     *
     * Components should choose a timing according to the kind of
     * interaction being performed, not invent local millisecond
     * values.
     */


    /*
     * Immediate feedback:
     * pressed states, tiny opacity changes, very small indicators.
     */
    readonly property int instant: 80


    /*
     * Quick interaction:
     * hover states, button highlights, small icon movement.
     */
    readonly property int quick: 120


    /*
     * Standard shell interaction:
     * selection changes, color transitions, small scale changes.
     */
    readonly property int standard: 160


    /*
     * More visible structural movement:
     * cards changing position, expanding controls, larger transforms.
     */
    readonly property int emphasized: 220


    /*
     * Major spatial transition:
     * carousel movement, panel-content transitions, substantial shifts.
     */
    readonly property int spatial: 280


    /*
     * Full panel / large UI entrance or exit.
     */
    readonly property int panel: 360


    /*
     * ------------------------------------------------------------
     * Shared transform values
     * ------------------------------------------------------------
     */


    /*
     * Normal hover enlargement.
     */
    readonly property real hoverScale: 1.04


    /*
     * Slightly stronger emphasis used for icon-centric controls.
     */
    readonly property real emphasizedHoverScale: 1.08


    /*
     * Press feedback.
     */
    readonly property real pressScale: 0.96


    /*
     * Stronger press feedback for small buttons/icons.
     */
    readonly property real compactPressScale: 0.92


    /*
     * ------------------------------------------------------------
     * Shared movement distances
     * ------------------------------------------------------------
     */

    readonly property int tinyOffset: 2
    readonly property int smallOffset: 4
    readonly property int mediumOffset: 8
    readonly property int largeOffset: 16
}
