import QtQuick
import QtQuick.Layouts

import qs.theme as ShellTheme
import qs.motion as Motion

Rectangle {
    id: root

    property string appName:
        ""

    property string appIcon:
        ""

    property string appComment:
        ""

    property string desktopId:
        ""

    property bool selected:
        false

    signal launched(string desktopId)

    implicitWidth:
        150

    implicitHeight:
        102

    antialiasing:
        false

    radius:
        ShellTheme.Theme.radius.card

    color: {
        if (mouseArea.pressed) {
            return root.selected
                ? ShellTheme.Theme.colors.primaryHover
                : ShellTheme.Theme.colors.pressedOverlay
        }

        if (mouseArea.containsMouse) {
            return root.selected
                ? ShellTheme.Theme.colors.primaryHover
                : ShellTheme.Theme.colors.hoverOverlay
        }

        return root.selected
            ? ShellTheme.Theme.colors.primary
            : ShellTheme.Theme.colors.surfaceContainerHigh
    }

    border.width:
        root.selected
            ? 1
            : 0

    border.color:
        root.selected
            ? ShellTheme.Theme.colors.outline
            : "transparent"

    scale:
        mouseArea.pressed
            ? Motion.MotionTokens.compactPressScale
            : mouseArea.containsMouse
                ? Motion.MotionTokens.hoverScale
                : 1.0

    Behavior on color {
        ColorAnimation {
            duration:
                Motion.MotionTokens.quick

            easing.type:
                Motion.Easing.standard
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration:
                Motion.MotionTokens.quick

            easing.type:
                Motion.Easing.standard
        }
    }

    Behavior on border.color {
        ColorAnimation {
            duration:
                Motion.MotionTokens.quick

            easing.type:
                Motion.Easing.standard
        }
    }

    ColumnLayout {
        anchors {
            fill: parent

            margins:
                ShellTheme.Theme.spacing.small
        }

        spacing:
            ShellTheme.Theme.spacing.xSmall

        Item {
            Layout.fillWidth:
                true

            Layout.preferredHeight:
                48

            Image {
                id: iconImage

                anchors.centerIn:
                    parent

                width:
                    42

                height:
                    42

                visible:
                    root.appIcon.length > 0
                    && status !== Image.Error

                source:
                    root.appIcon

                fillMode:
                    Image.PreserveAspectFit

                asynchronous:
                    true

                smooth:
                    true
            }

            Rectangle {
                anchors.centerIn:
                    parent

                width:
                    42

                height:
                    42

                visible:
                    root.appIcon.length === 0
                    || iconImage.status === Image.Error

                antialiasing:
                    false

                radius:
                    ShellTheme.Theme.radius.button

                color:
                    ShellTheme.Theme.colors.surfaceContainerHighest

                Text {
                    anchors.centerIn:
                        parent

                    text:
                        "󰀻"

                    color:
                        root.selected
                            ? ShellTheme.Theme.colors.primary
                            : ShellTheme.Theme.colors.on_surface_variant

                    font.family:
                        ShellTheme.Theme.typography.iconFontFamily

                    font.pixelSize:
                        20
                }
            }
        }

        Text {
            Layout.fillWidth:
                true

            text:
                root.appName

            color:
                root.selected
                    ? ShellTheme.Theme.colors.on_primary
                    : ShellTheme.Theme.colors.on_surface

            font.family:
                ShellTheme.Theme.typography.fontFamily

            font.pixelSize:
                ShellTheme.Theme.typography.labelSmall

            font.weight:
                Font.DemiBold

            horizontalAlignment:
                Text.AlignHCenter

            elide:
                Text.ElideRight

            maximumLineCount:
                1
        }

        Text {
            Layout.fillWidth:
                true

            visible:
                root.appComment.length > 0

            text:
                root.appComment

            color:
                root.selected
                    ? ShellTheme.Theme.colors.on_primary
                    : ShellTheme.Theme.colors.on_surface_variant

            font.family:
                ShellTheme.Theme.typography.fontFamily

            font.pixelSize:
                ShellTheme.Theme.typography.labelSmall

            horizontalAlignment:
                Text.AlignHCenter

            elide:
                Text.ElideRight

            maximumLineCount:
                1

            opacity:
                0.78
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill:
            parent

        hoverEnabled:
            true

        cursorShape:
            Qt.PointingHandCursor

        onClicked: {
            root.launched(
                root.desktopId
            )
        }
    }
}
