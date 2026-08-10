import QtQuick
import QtQuick.Effects

import "../../theme" as ShellTheme

Item {
    id: root

    enum Level {
        None,
        Low,
        Medium,
        High
    }

    property int level: Shadow.Low

    property real radius:
        ShellTheme.Theme.radius.card

    property bool shadowVisible:
        level !== Shadow.None

    readonly property real shadowOpacity: {
        switch (level) {
        case Shadow.Low:
            return ShellTheme.Theme.shadows.lowOpacity

        case Shadow.Medium:
            return ShellTheme.Theme.shadows.mediumOpacity

        case Shadow.High:
            return ShellTheme.Theme.shadows.highOpacity

        default:
            return ShellTheme.Theme.shadows.noneOpacity
        }
    }

    readonly property real shadowBlur: {
        switch (level) {
        case Shadow.Low:
            return ShellTheme.Theme.shadows.lowBlur

        case Shadow.Medium:
            return ShellTheme.Theme.shadows.mediumBlur

        case Shadow.High:
            return ShellTheme.Theme.shadows.highBlur

        default:
            return ShellTheme.Theme.shadows.noneBlur
        }
    }

    readonly property real shadowOffsetX: {
        switch (level) {
        case Shadow.Low:
            return ShellTheme.Theme.shadows.lowOffsetX

        case Shadow.Medium:
            return ShellTheme.Theme.shadows.mediumOffsetX

        case Shadow.High:
            return ShellTheme.Theme.shadows.highOffsetX

        default:
            return ShellTheme.Theme.shadows.noneOffsetX
        }
    }

    readonly property real shadowOffsetY: {
        switch (level) {
        case Shadow.Low:
            return ShellTheme.Theme.shadows.lowOffsetY

        case Shadow.Medium:
            return ShellTheme.Theme.shadows.mediumOffsetY

        case Shadow.High:
            return ShellTheme.Theme.shadows.highOffsetY

        default:
            return ShellTheme.Theme.shadows.noneOffsetY
        }
    }

    RectangularShadow {
        anchors.fill: parent

        visible:
            root.shadowVisible

        radius:
            root.radius

        blur:
            root.shadowBlur

        offset.x:
            root.shadowOffsetX

        offset.y:
            root.shadowOffsetY

        color:
            Qt.rgba(
                ShellTheme.Theme.shadows.color.r,
                ShellTheme.Theme.shadows.color.g,
                ShellTheme.Theme.shadows.color.b,
                root.shadowOpacity
            )
    }
}
