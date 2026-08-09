import QtQuick
import QtQuick.Controls as QQC

import qs.theme as ShellTheme

Item {
    id: root

    property var options: []
    property int currentIndex: 0
    property bool enabled: true
    property string placeholder: "Select"

    signal selected(
        int index,
        var value
    )

    readonly property bool opened:
        popup.opened

    readonly property string currentText: {
        if (
            !root.options
            || root.options.length === 0
            || root.currentIndex < 0
            || root.currentIndex >= root.options.length
        ) {
            return root.placeholder
        }

        return String(
            root.options[root.currentIndex]
        )
    }

    implicitWidth: 200
    implicitHeight: 40


    Rectangle {
        id: field

        anchors.fill: parent

        radius:
            ShellTheme.Theme.radius.button

        color: {
            if (!root.enabled)
                return ShellTheme.Theme.colors.surfaceContainerLow

            if (root.opened)
                return ShellTheme.Theme.colors.surfaceContainerHigh

            if (mouseArea.containsMouse)
                return ShellTheme.Theme.colors.hoverOverlay

            return ShellTheme.Theme.colors.surfaceContainerLow
        }

        border.width:
            root.opened ? 1 : 0

        border.color:
            ShellTheme.Theme.colors.primary

        opacity:
            root.enabled ? 1.0 : 0.45


        Row {
            anchors {
                fill: parent

                leftMargin:
                    ShellTheme.Theme.spacing.medium

                rightMargin:
                    ShellTheme.Theme.spacing.medium
            }

            spacing:
                ShellTheme.Theme.spacing.small


            Text {
                width:
                    Math.max(
                        0,
                        parent.width
                        - arrow.width
                        - parent.spacing
                    )

                anchors.verticalCenter:
                    parent.verticalCenter

                text:
                    root.currentText

                color:
                    ShellTheme.Theme.colors.on_surface

                font.family:
                    ShellTheme.Theme.typography.fontFamily

                font.pixelSize:
                    ShellTheme.Theme.typography.bodySmall

                font.weight:
                    ShellTheme.Theme.typography.weightMedium

                elide:
                    Text.ElideRight
            }


            Text {
                id: arrow

                anchors.verticalCenter:
                    parent.verticalCenter

                text:
                    root.opened
                        ? "󰅀"
                        : "󰅂"

                color:
                    root.opened
                        ? ShellTheme.Theme.colors.primary
                        : ShellTheme.Theme.colors.on_surface_variant

                font.family:
                    ShellTheme.Theme.typography.iconFontFamily

                font.pixelSize: 13
            }
        }


        MouseArea {
            id: mouseArea

            anchors.fill: parent

            enabled:
                root.enabled

            hoverEnabled: true

            cursorShape:
                Qt.PointingHandCursor

            onClicked: {
                if (popup.opened)
                    popup.close()
                else
                    popup.open()
            }
        }
    }


    QQC.Popup {
        id: popup

        parent:
            QQC.Overlay.overlay

        width:
            root.width

        height:
            Math.min(
                optionColumn.implicitHeight
                    + ShellTheme.Theme.spacing.small,
                250
            )

        padding:
            ShellTheme.Theme.spacing.xxSmall

        modal: false
        focus: true

        closePolicy:
            QQC.Popup.CloseOnEscape
            | QQC.Popup.CloseOnPressOutside


        x: {
            if (!QQC.Overlay.overlay)
                return 0

            const point =
                root.mapToItem(
                    QQC.Overlay.overlay,
                    0,
                    0
                )

            return Math.min(
                Math.max(
                    ShellTheme.Theme.spacing.small,
                    point.x
                ),
                QQC.Overlay.overlay.width
                    - popup.width
                    - ShellTheme.Theme.spacing.small
            )
        }


        y: {
            if (!QQC.Overlay.overlay)
                return 0

            const point =
                root.mapToItem(
                    QQC.Overlay.overlay,
                    0,
                    root.height
                        + ShellTheme.Theme.spacing.xxSmall
                )

            const wantedY =
                point.y

            const bottomLimit =
                QQC.Overlay.overlay.height
                - popup.height
                - ShellTheme.Theme.spacing.small

            /*
             * If there isn't enough room below,
             * open above the field.
             */
            if (wantedY > bottomLimit) {
                const above =
                    root.mapToItem(
                        QQC.Overlay.overlay,
                        0,
                        -popup.height
                            - ShellTheme.Theme.spacing.xxSmall
                    )

                return Math.max(
                    ShellTheme.Theme.spacing.small,
                    above.y
                )
            }

            return wantedY
        }


        background: Rectangle {
            radius:
                ShellTheme.Theme.radius.control

            color:
                ShellTheme.Theme.colors.surfaceContainerHigh

            border.width: 1

            border.color:
                ShellTheme.Theme.colors.outlineVariant
        }


        contentItem: Flickable {
            id: menuFlickable

            implicitWidth:
                root.width

            implicitHeight:
                Math.min(
                    optionColumn.implicitHeight,
                    240
                )

            contentWidth:
                width

            contentHeight:
                optionColumn.implicitHeight

            clip: true

            boundsBehavior:
                Flickable.StopAtBounds


            Column {
                id: optionColumn

                width:
                    menuFlickable.width

                spacing:
                    ShellTheme.Theme.spacing.xxxSmall


                Repeater {
                    model:
                        root.options


                    delegate: Rectangle {
                        required property int index
                        required property var modelData

                        width:
                            optionColumn.width

                        height: 36

                        radius:
                            ShellTheme.Theme.radius.button

                        color: {
                            if (
                                index
                                === root.currentIndex
                            ) {
                                return ShellTheme.Theme.colors.selectedOverlay
                            }

                            if (
                                optionMouse.containsMouse
                            ) {
                                return ShellTheme.Theme.colors.hoverOverlay
                            }

                            return "transparent"
                        }


                        Text {
                            anchors {
                                fill: parent

                                leftMargin:
                                    ShellTheme.Theme.spacing.medium

                                rightMargin:
                                    ShellTheme.Theme.spacing.medium
                            }

                            verticalAlignment:
                                Text.AlignVCenter

                            text:
                                String(modelData)

                            color:
                                index === root.currentIndex
                                    ? ShellTheme.Theme.colors.primary
                                    : ShellTheme.Theme.colors.on_surface

                            font.family:
                                ShellTheme.Theme.typography.fontFamily

                            font.pixelSize:
                                ShellTheme.Theme.typography.bodySmall

                            font.weight:
                                index === root.currentIndex
                                    ? ShellTheme.Theme.typography.weightSemiBold
                                    : ShellTheme.Theme.typography.weightRegular

                            elide:
                                Text.ElideRight
                        }


                        MouseArea {
                            id: optionMouse

                            anchors.fill: parent

                            hoverEnabled: true

                            cursorShape:
                                Qt.PointingHandCursor

                            onClicked: {
                                root.currentIndex =
                                    index

                                root.selected(
                                    index,
                                    modelData
                                )

                                popup.close()
                            }
                        }
                    }
                }
            }
        }
    }
}
