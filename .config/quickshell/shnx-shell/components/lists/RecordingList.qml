import QtQuick

import "../../theme" as ShellTheme
import "../cards" as Cards

Item {
    id: root

    property var model: []

    property string emptyText:
        "No recordings yet"

    property real cardSpacing:
        ShellTheme.Theme.spacing.small

    property real contentMargin:
        ShellTheme.Theme.spacing.small

    signal playRequested(int index, var item)
    signal deleteRequested(int index, var item)

    readonly property int itemCount:
        root.model ? root.model.length : 0

    Flickable {
        id: flickable

        anchors.fill: parent

        clip: true

        contentWidth:
            width

        contentHeight:
            contentColumn.implicitHeight
            + root.contentMargin * 2

        boundsBehavior:
            Flickable.StopAtBounds

        Column {
            id: contentColumn

            x:
                root.contentMargin

            y:
                root.contentMargin

            width:
                Math.max(
                    0,
                    flickable.width
                    - root.contentMargin * 2
                )

            spacing:
                root.cardSpacing

            Repeater {
                model:
                    root.model

                delegate: Cards.RecordingCard {
                    required property int index
                    required property var modelData

                    width:
                        contentColumn.width

                    title:
                        modelData && modelData.title !== undefined
                            ? String(modelData.title)
                            : ""

                    subtitle:
                        modelData && modelData.subtitle !== undefined
                            ? String(modelData.subtitle)
                            : ""

                    duration:
                        modelData && modelData.duration !== undefined
                            ? String(modelData.duration)
                            : ""

                    playing:
                        modelData && modelData.playing === true

                    enabled:
                        !modelData
                        || modelData.enabled === undefined
                        || modelData.enabled === true

                    onPlayRequested:
                        root.playRequested(
                            index,
                            modelData
                        )

                    onDeleteRequested:
                        root.deleteRequested(
                            index,
                            modelData
                        )
                }
            }
        }
    }

    Text {
        anchors.centerIn: parent

        visible:
            root.itemCount === 0

        text:
            root.emptyText

        color:
            ShellTheme.Theme.colors.onSurfaceVariant

        font.family:
            ShellTheme.Theme.typography.fontFamily

        font.pixelSize:
            ShellTheme.Theme.typography.bodyMedium

        horizontalAlignment:
            Text.AlignHCenter

        verticalAlignment:
            Text.AlignVCenter
    }
}
