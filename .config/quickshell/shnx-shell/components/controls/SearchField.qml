import QtQuick

import qs.theme as ShellTheme
import qs.motion as Motion
import qs.components.visual as Visual

Rectangle {
    id: root

    /* Existing launcher-facing signals: preserved. */
    signal moveLeftRequested()
    signal moveRightRequested()

    /* New list-navigation signals for Dynamic Island search. */
    signal moveUpRequested()
    signal moveDownRequested()
    signal escapeRequested()

    property alias text:
        searchInput.text

    property alias placeholderText:
        searchInput.placeholderText

    signal submitted(string query)
    signal cleared()

    /*
     * Compatibility default keeps the old launcher behavior.
     * Dynamic Island sets this false so Left/Right move the text cursor.
     */
    property bool captureHorizontalNavigation: true
    property bool captureVerticalNavigation: false

    property string leadingGlyph: "󰍉"

    implicitWidth: 560
    implicitHeight: 48

    antialiasing: false

    radius:
        ShellTheme.Theme.radius.card

    color:
        searchInput.activeFocus
            ? ShellTheme.Theme.colors.surfaceContainerHigh
            : ShellTheme.Theme.colors.surfaceContainer

    border.width:
        searchInput.activeFocus ? 1 : 0

    border.color:
        ShellTheme.Theme.colors.primary

    Behavior on color {
        ColorAnimation {
            duration: Motion.MotionTokens.quick
            easing.type: Motion.Easing.standard
        }
    }

    Behavior on border.color {
        ColorAnimation {
            duration: Motion.MotionTokens.quick
            easing.type: Motion.Easing.standard
        }
    }

    Row {
        anchors.fill: parent
        anchors.leftMargin: ShellTheme.Theme.spacing.medium
        anchors.rightMargin: ShellTheme.Theme.spacing.small
        spacing: ShellTheme.Theme.spacing.small

        Visual.Icon {
            anchors.verticalCenter: parent.verticalCenter
            glyph: root.leadingGlyph
            iconSize: 17
            color:
                searchInput.activeFocus
                    ? ShellTheme.Theme.colors.on_surface
                    : ShellTheme.Theme.colors.on_surface_variant
        }

        TextInput {
            id: searchInput

            width:
                parent.width
                - clearButton.width
                - 40

            height: parent.height

            color: ShellTheme.Theme.colors.on_surface
            selectionColor: ShellTheme.Theme.colors.primary
            selectedTextColor: ShellTheme.Theme.colors.on_primary

            font.family: ShellTheme.Theme.typography.fontFamily
            font.pixelSize: ShellTheme.Theme.typography.bodySmall

            verticalAlignment: TextInput.AlignVCenter
            clip: true
            focus: false

            property string placeholderText: "Search applications"

            Text {
                anchors.fill: parent

                visible:
                    searchInput.text.length === 0
                    && !searchInput.activeFocus

                text: searchInput.placeholderText
                color: ShellTheme.Theme.colors.disabled
                font.family: ShellTheme.Theme.typography.fontFamily
                font.pixelSize: ShellTheme.Theme.typography.bodySmall
                verticalAlignment: Text.AlignVCenter
            }

            Keys.onPressed: function(event) {
                if (root.captureVerticalNavigation
                        && event.key === Qt.Key_Up) {
                    root.moveUpRequested()
                    event.accepted = true
                    return
                }

                if (root.captureVerticalNavigation
                        && event.key === Qt.Key_Down) {
                    root.moveDownRequested()
                    event.accepted = true
                    return
                }

                if (root.captureHorizontalNavigation
                        && event.key === Qt.Key_Left) {
                    root.moveLeftRequested()
                    event.accepted = true
                    return
                }

                if (root.captureHorizontalNavigation
                        && event.key === Qt.Key_Right) {
                    root.moveRightRequested()
                    event.accepted = true
                }
            }

            Keys.onReturnPressed:
                root.submitted(text)

            Keys.onEnterPressed:
                root.submitted(text)

            Keys.onEscapePressed: {
                if (text.length > 0) {
                    text = ""
                    root.cleared()
                } else {
                    root.escapeRequested()
                }
            }
        }

        Item {
            id: clearButton

            anchors.verticalCenter: parent.verticalCenter
            width: 30
            height: 30

            visible:
                searchInput.text.length > 0

            scale:
                clearMouseArea.pressed
                    ? Motion.MotionTokens.compactPressScale
                    : clearMouseArea.containsMouse
                        ? Motion.MotionTokens.hoverScale
                        : 1.0

            Behavior on scale {
                NumberAnimation {
                    duration: Motion.MotionTokens.quick
                    easing.type: Motion.Easing.standard
                }
            }

            Rectangle {
                anchors.fill: parent
                antialiasing: false
                radius: ShellTheme.Theme.radius.button

                color:
                    clearMouseArea.pressed
                        ? ShellTheme.Theme.colors.pressedOverlay
                        : clearMouseArea.containsMouse
                            ? ShellTheme.Theme.colors.hoverOverlay
                            : "transparent"

                Behavior on color {
                    ColorAnimation {
                        duration: Motion.MotionTokens.quick
                        easing.type: Motion.Easing.standard
                    }
                }
            }

            Visual.Icon {
                anchors.centerIn: parent
                glyph: "󰅖"
                iconSize: 14
                color: ShellTheme.Theme.colors.on_surface_variant
            }

            MouseArea {
                id: clearMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    searchInput.text = ""
                    searchInput.forceActiveFocus()
                    root.cleared()
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        z: -1

        onClicked:
            searchInput.forceActiveFocus()
    }

    function activate() {
        searchInput.forceActiveFocus()
        searchInput.selectAll()
      }

    function forceInputFocus() {
        searchInput.forceActiveFocus()
    }

    function clear() {
        searchInput.text = ""
        root.cleared()
    }
}

