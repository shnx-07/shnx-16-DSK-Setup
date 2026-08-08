import QtQuick

QtObject {
    readonly property string fontFamily: "Inter"
    readonly property string monospaceFamily: "JetBrains Mono"
    readonly property string iconFontFamily:
    "Symbols Nerd Font Mono"

    readonly property int weightLight: Font.Light
    readonly property int weightRegular: Font.Normal
    readonly property int weightMedium: Font.Medium
    readonly property int weightSemiBold: Font.DemiBold
    readonly property int weightBold: Font.Bold

    readonly property int displayLarge: 40
    readonly property int displayMedium: 34
    readonly property int displaySmall: 30

    readonly property int headlineLarge: 26
    readonly property int headlineMedium: 22
    readonly property int headlineSmall: 20

    readonly property int titleLarge: 18
    readonly property int titleMedium: 16
    readonly property int titleSmall: 14

    readonly property int bodyLarge: 16
    readonly property int bodyMedium: 14
    readonly property int bodySmall: 12

    readonly property int labelLarge: 14
    readonly property int labelMedium: 12
    readonly property int labelSmall: 10

    readonly property real lineHeightTight: 1.15
    readonly property real lineHeightNormal: 1.35
    readonly property real lineHeightRelaxed: 1.55

    readonly property real letterSpacingTight: -0.2
    readonly property real letterSpacingNormal: 0.0
    readonly property real letterSpacingWide: 0.3
}
