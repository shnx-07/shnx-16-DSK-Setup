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
        ShellTheme.Theme.spacing.large

    property real verticalPadding:
        ShellTheme.Theme.spacing.medium

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

            leftMargin:
                root.horizontalPadding

            rightMargin:
                root.horizontalPadding
        }

        spacing:
            ShellTheme.Theme.spacing.medium

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
                    - (
                        root.showBackButton
                            ? 36
                                + parent.spacing
                            : 0
                    )
                    - parent.spacing
                )

            anchors.verticalCenter:
                parent.verticalCenter

            spacing: 3

            Text {
                width:
                    parent.width

                text:
                    root.title

                color:
                    ShellTheme.Theme.colors.on_surface

                font.family:
                    ShellTheme.Theme.typography.fontFamily

                font.pixelSize:
                    ShellTheme.Theme.typography.titleMedium

                font.weight:
                    ShellTheme.Theme.typography.weightSemiBold

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
                    ShellTheme.Theme.colors.on_surface_variant

                font.family:
                    ShellTheme.Theme.typography.fontFamily

                font.pixelSize:
                    ShellTheme.Theme.typography.bodySmall

                opacity: 0.72

                elide:
                    Text.ElideRight
            }
        }

        Row {
            id: actionsRow

            anchors.verticalCenter:
                parent.verticalCenter

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
