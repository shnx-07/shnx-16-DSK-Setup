import QtQuick
import qs.core as Core
import qs.theme as ShellTheme

Rectangle {
    id: root

    readonly property string windowTitle:
        Core.ServiceRegistry.hyprland.activeWindowTitle

    readonly property bool hasActiveWindow:
        windowTitle.length > 0

    readonly property int horizontalPadding: 12
    readonly property int maximumWidth: 320

    visible: hasActiveWindow

    implicitWidth: hasActiveWindow
        ? Math.min(titleMetrics.advanceWidth + horizontalPadding * 2, maximumWidth)
        : 0

    implicitHeight: 32

    radius: ShellTheme.Theme.radius.button
    color: ShellTheme.Theme.colors.surfaceContainer

    border.width: 1
    border.color: ShellTheme.Theme.colors.outlineVariant

    TextMetrics {
        id: titleMetrics

        text: root.windowTitle
        font: titleText.font
    }

    Text {
        id: titleText

        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: root.horizontalPadding
            rightMargin: root.horizontalPadding
        }

        text: root.windowTitle
        color: ShellTheme.Theme.colors.on_surface_variant

        font.pixelSize: ShellTheme.Theme.typography.labelMedium
        font.weight: Font.Medium

        elide: Text.ElideRight
        maximumLineCount: 1
        wrapMode: Text.NoWrap
    }
}
