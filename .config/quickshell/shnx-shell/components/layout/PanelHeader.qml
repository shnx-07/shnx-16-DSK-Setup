import QtQuick

import "../../theme" as ShellTheme
import "../buttons" as Buttons

Item {
    id: root

    signal backRequested()
    signal closeRequested()

    property string title: ""
    property string subtitle: ""

    property bool showBackButton: false
    property bool showCloseButton: true

    property string backGlyph: "󰁍"
    property string closeGlyph: "󰅖"

    property real horizontalPadding:
        ShellTheme.Theme.spacing.medium

    property real verticalPadding:
        ShellTheme.Theme.spacing.small

    implicitWidth:
        headerRow.implicitWidth
        + root.horizontalPadding * 2

    implicitHeight:
        Math.max(
            titleColumn.implicitHeight,
            actionsRow.implicitHeight
        )
        + root.verticalPadding * 2

    Row {
        id: headerRow

        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }

        spacing:
            ShellTheme.Theme.spacing.small

        Buttons.IconButton {
            visible:
                root.showBackButton

            glyph:
                root.backGlyph

            tooltipText:
                "Back"

            onClicked:
                root.backRequested()
        }

        Column {
            id: titleColumn

            width:
                Math.max(
                    0,
                    parent.width
                    - actionsRow.width
                    - (root.showBackButton
                        ? ShellTheme.Theme.spacing.large + 36
                        : 0)
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
                    ShellTheme.Theme.typography.titleLarge

                font.weight:
                    Font.DemiBold

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
                    ShellTheme.Theme.typography.bodyMedium

                elide:
                    Text.ElideRight
            }
        }

        Item {
            width:
                Math.max(
                    0,
                    root.width
                    - titleColumn.width
                    - actionsRow.width
                    - (root.showBackButton ? 36 : 0)
                )

            height:
                1
        }

        Row {
            id: actionsRow

            spacing:
                ShellTheme.Theme.spacing.xSmall

            Buttons.IconButton {
                visible:
                    root.showCloseButton

                glyph:
                    root.closeGlyph

                tooltipText:
                    "Close"

                onClicked:
                    root.closeRequested()
            }
        }
    }
}
