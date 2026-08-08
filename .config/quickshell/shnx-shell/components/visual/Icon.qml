import QtQuick

import "../../theme" as ShellTheme

Item {
    id: root

    property string source: ""
    property string glyph: ""

    property color color:
    ShellTheme.Theme.colors.on_surface

property color disabledColor:
    ShellTheme.Theme.colors.on_surface_variant

    property real iconSize: 20

    property bool disabled: false

    readonly property color effectiveColor:
        disabled ? disabledColor : color

    implicitWidth:
        iconSize

    implicitHeight:
        iconSize

    /*
     * Font-glyph renderer.
     *
     * Use this for Nerd Font / symbol glyphs.
     */
    Text {
        anchors.centerIn: parent

        visible:
            root.glyph.length > 0

        text:
            root.glyph

        color:
            root.effectiveColor

        font.family:
            ShellTheme.Theme.typography.iconFontFamily

        font.pixelSize:
            root.iconSize

        horizontalAlignment:
            Text.AlignHCenter

        verticalAlignment:
            Text.AlignVCenter
    }

    /*
     * Image / SVG renderer.
     *
     * Used when an explicit source path or URL is supplied.
     */
    Image {
        anchors.centerIn: parent

        width:
            root.iconSize

        height:
            root.iconSize

        visible:
            root.glyph.length === 0
            && root.source.length > 0

        source:
            root.source

        fillMode:
            Image.PreserveAspectFit

        smooth:
            true

        mipmap:
            true
    }
}
