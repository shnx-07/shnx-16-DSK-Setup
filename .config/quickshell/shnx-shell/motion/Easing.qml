pragma Singleton

import QtQuick

QtObject {
    id: root

    /*
     * Standard UI easing.
     *
     * Use for:
     * - hover movement
     * - selection changes
     * - small scale transitions
     * - normal component repositioning
     */
    readonly property int standard:
        Easing.OutCubic


    /*
     * Slightly stronger deceleration.
     *
     * Use for:
     * - carousel movement
     * - panel content shifts
     * - larger spatial movement
     */
    readonly property int emphasized:
        Easing.OutQuart


    /*
     * Smooth acceleration/deceleration.
     *
     * Use where motion should feel balanced in both directions.
     */
    readonly property int smooth:
        Easing.InOutCubic


    /*
     * Fast departure with a gentle landing.
     *
     * Useful for exits and dismissals.
     */
    readonly property int exit:
        Easing.InCubic


    /*
     * Soft arrival.
     *
     * Useful for entrances.
     */
    readonly property int enter:
        Easing.OutCubic
}
