import QtQuick

import "../../theme" as ShellTheme
import "../../motion" as Motion
import "../visual" as Visual

Item {
    id: root

    enum Variant {
        Primary,
        Secondary,
        Destructive
    }

    signal clicked()

    property int variant:
        PillButton.Primary

    property string text: ""
    property string glyph: ""
    property string iconSource: ""

    property real iconSize: 18

    property bool enabled: true

    property real horizontalPadding:
        ShellTheme.Theme.spacing.medium

    property real verticalPadding:
        ShellTheme.Theme.spacing.small

    property real spacing:
        ShellTheme.Theme.spacing.small

    readonly property bool hovered:
        mouseArea.containsMouse

    readonly property bool pressed:
        mouseArea.pressed

    readonly property color backgroundColor: {
        if (!root.enabled)
            return ShellTheme.Theme.colors.surfaceContainer

        if (root.variant === PillButton.Destructive)
            return ShellTheme.Theme.colors.error

        if (root.variant === PillButton.Secondary)
            return ShellTheme.Theme.colors.surfaceContainerHigh

        return ShellTheme.Theme.colors.primary
    }

    readonly property color foregroundColor: {
        if (!root.enabled)
            return ShellTheme.Theme.colors.onSurfaceVariant

        if (root.variant === PillButton.Destructive)
            return ShellTheme.Theme.colors.onError

        if (root.variant === PillButton.Secondary)
            return ShellTheme.Theme.colors.onSurface

        return ShellTheme.Theme.colors.onPrimary
    }

    implicitWidth:
        contentRow.implicitWidth
        + root.horizontalPadding * 2

    implicitHeight:
        contentRow.implicitHeight
        + root.verticalPadding * 2

    scale:
        root.pressed
            ? Motion.MotionTokens.pressScale
            : root.hovered
                ? Motion.MotionTokens.hoverScale
                : 1.0

    opacity:
        root.enabled ? 1.0 : 0.45

    Behavior on scale {
        NumberAnimation {
            duration:
                Motion.MotionTokens.quick

            easing.type:
                Motion.Easing.standard
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration:
                Motion.MotionTokens.quick

            easing.type:
                Motion.Easing.standard
        }
    }

    Rectangle {
        anchors.fill: parent

        radius:
            ShellTheme.Theme.radius.pill

        color:
            root.backgroundColor

        opacity:
            root.pressed
                ? 0.82
                : root.hovered
                    ? 0.92
                    : 1.0

        Behavior on opacity {
            NumberAnimation {
                duration:
                    Motion.MotionTokens.quick

                easing.type:
                    Motion.Easing.standard
            }
        }
    }

    Row {
        id: contentRow

        anchors.centerIn: parent

        spacing:
            root.spacing

        Visual.Icon {
            visible:
                root.glyph.length > 0
                || root.iconSource.length > 0

            glyph:
                root.glyph

            source:
                root.iconSource

            iconSize:
                root.iconSize

            color:
                root.foregroundColor

            disabled:
                !root.enabled
        }

        Text {
            visible:
                root.text.length > 0

            text:
                root.text

            color:
                root.foregroundColor

            font.family:
                ShellTheme.Theme.typography.fontFamily

            font.pixelSize:
                ShellTheme.Theme.typography.labelLarge

            font.weight:
                Font.DemiBold

            verticalAlignment:
                Text.AlignVCenter
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent

        enabled:
            root.enabled

        hoverEnabled:
            true

        cursorShape:
            root.enabled
                ? Qt.PointingHandCursor
                : Qt.ArrowCursor

        onClicked:
            root.clicked()
    }
}
