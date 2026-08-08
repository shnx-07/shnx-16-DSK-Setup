import QtQuick

import "../../theme" as ShellTheme
import "../../motion" as Motion
import "../buttons" as Buttons

BaseCard {
    id: root

    signal playRequested()
    signal deleteRequested()

    property string title: ""
    property string subtitle: ""
    property string duration: ""

    property bool playing: false
    property bool enabled: true

    property string playGlyph:
        root.playing ? "󰏤" : "󰐊"

    property string deleteGlyph:
        "󰆴"

    implicitWidth: 320
    implicitHeight: 72

    opacity:
        root.enabled ? 1.0 : 0.45

    Behavior on opacity {
        NumberAnimation {
            duration:
                Motion.MotionTokens.quick

            easing.type:
                Motion.Easing.standard
        }
    }

    Row {
        anchors {
            fill: parent
            margins:
                ShellTheme.Theme.spacing.medium
        }

        spacing:
            ShellTheme.Theme.spacing.medium

        Buttons.IconButton {
            anchors.verticalCenter:
                parent.verticalCenter

            glyph:
                root.playGlyph

            enabled:
                root.enabled

            tooltipText:
                root.playing
                    ? "Pause"
                    : "Play"

            onClicked:
                root.playRequested()
        }

        Column {
            anchors.verticalCenter:
                parent.verticalCenter

            width:
                Math.max(
                    0,
                    parent.width
                    - ShellTheme.Theme.spacing.medium * 2
                    - 72
                )

            spacing:
                ShellTheme.Theme.spacing.xSmall

            Text {
                width:
                    parent.width

                text:
                    root.title

                color:
                    ShellTheme.Theme.colors.onSurface

                font.family:
                    ShellTheme.Theme.typography.fontFamily

                font.pixelSize:
                    ShellTheme.Theme.typography.bodyLarge

                font.weight:
                    Font.Medium

                elide:
                    Text.ElideRight
            }

            Text {
                width:
                    parent.width

                visible:
                    root.subtitle.length > 0

                text:
                    root.subtitle

                color:
                    ShellTheme.Theme.colors.onSurfaceVariant

                font.family:
                    ShellTheme.Theme.typography.fontFamily

                font.pixelSize:
                    ShellTheme.Theme.typography.bodySmall

                elide:
                    Text.ElideRight
            }
        }

        Text {
            anchors.verticalCenter:
                parent.verticalCenter

            visible:
                root.duration.length > 0

            text:
                root.duration

            color:
                ShellTheme.Theme.colors.onSurfaceVariant

            font.family:
                ShellTheme.Theme.typography.fontFamily

            font.pixelSize:
                ShellTheme.Theme.typography.labelMedium
        }

        Buttons.IconButton {
            anchors.verticalCenter:
                parent.verticalCenter

            glyph:
                root.deleteGlyph

            enabled:
                root.enabled

            tooltipText:
                "Delete"

            onClicked:
                root.deleteRequested()
        }
    }
}
