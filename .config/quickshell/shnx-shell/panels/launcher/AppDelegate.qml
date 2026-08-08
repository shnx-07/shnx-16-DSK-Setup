import QtQuick
import QtQuick.Layouts
import qs.theme as ShellTheme

Rectangle {
    id: root

    property string appName: ""
    property string appIcon: ""
    property string appComment: ""
    property string desktopId: ""

    property bool selected: false

    signal launched(string desktopId)

    implicitWidth: 132
    implicitHeight: 112

    radius: ShellTheme.Theme.radius.card

    color: {
        if (mouseArea.pressed)
            return root.selected
                ? ShellTheme.Theme.colors.primaryHover
                : ShellTheme.Theme.colors.pressedOverlay

        if (mouseArea.containsMouse)
            return root.selected
                ? ShellTheme.Theme.colors.primaryHover
                : ShellTheme.Theme.colors.hoverOverlay

        return root.selected
            ? ShellTheme.Theme.colors.primary
            : ShellTheme.Theme.colors.surfaceContainer
    }

    border.width:
        root.selected
        || mouseArea.containsMouse
            ? 1
            : 0

    border.color:
        root.selected
            ? ShellTheme.Theme.colors.outline
            : ShellTheme.Theme.colors.outlineVariant

    scale:
        mouseArea.pressed
            ? 0.97
            : 1.0

    Behavior on color {
        ColorAnimation {
            duration: 120
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: 90
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12

        spacing: 8

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 54
            Layout.preferredHeight: 54

            radius: ShellTheme.Theme.radius.button
            color: ShellTheme.Theme.colors.surfaceContainerHigh

            Image {
                id: iconImage

                anchors.fill: parent
                anchors.margins: 8

                visible:
                    root.appIcon.length > 0
                    && status !== Image.Error

                source: root.appIcon
                fillMode: Image.PreserveAspectFit

                asynchronous: true
                smooth: true
            }

            Text {
                anchors.centerIn: parent

                visible:
                    root.appIcon.length === 0
                    || iconImage.status === Image.Error

                text: "󰀻"
                color: ShellTheme.Theme.colors.on_surface

                font.pixelSize: ShellTheme.Theme.typography.headlineMedium
                font.family:
                    "JetBrainsMono Nerd Font"
            }
        }

        Text {
            Layout.fillWidth: true

            text: root.appName
            color: ShellTheme.Theme.colors.on_surface

            font.pixelSize: ShellTheme.Theme.typography.labelSmall
            font.weight: Font.DemiBold

            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }

        Text {
            Layout.fillWidth: true

            visible:
                root.appComment.length > 0

            text: root.appComment
            color: ShellTheme.Theme.colors.on_surface_variant

            font.pixelSize: ShellTheme.Theme.typography.labelSmall

            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent

        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            root.launched(root.desktopId)
        }
    }
}
