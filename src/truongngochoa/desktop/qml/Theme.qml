pragma Singleton
import QtQuick

QtObject {
    property bool motionEnabled: true

    readonly property string fontFamily: "Segoe UI Variable"

    // HFL Cyber Navy AI SaaS Palette
    // Deep layered dark navy with electric blue and purple accents
    readonly property color window: "#071225"
    readonly property color surface: "#0B172B"
    readonly property color surfaceElevated: "#142441"
    readonly property color surfaceMuted: "#16253D"
    readonly property color surfaceStrong: "#1E3152"
    readonly property color input: "#0D1B32"
    readonly property color sidebar: "#081326"
    readonly property color sidebarHover: "#142441"
    readonly property color sidebarSelected: "#1A2F54"
    readonly property color topBar: "#081326"
    readonly property color windowCaptionHover: "#16253D"
    readonly property color windowCaptionPressed: "#1E3152"
    readonly property color windowCloseHover: "#EF4444"
    readonly property color windowClosePressed: "#DC2626"
    readonly property color outline: "#203455"
    readonly property color outlineStrong: "#2D4875"
    readonly property color divider: "#16253D"

    readonly property color text: "#F1F5FF"
    readonly property color textMuted: "#A5B5D4"
    readonly property color textSubtle: "#748AA8"
    readonly property color textDisabled: "#4B5F7D"
    readonly property color textOnAccent: "#051329"
    readonly property color textOnDark: "#F1F5FF"
    readonly property color textOnDarkMuted: "#A5B5D4"

    readonly property color interactive: "#38BDF8"
    readonly property color interactiveHover: "#60CEFF"
    readonly property color interactivePressed: "#0284C7"
    readonly property color interactiveMuted: "#0C304E"
    readonly property color interactiveOutline: "#1E6B9E"
    readonly property color primaryBlue: "#3867FF"
    readonly property color accentPurple: "#6246F5"
    readonly property color accentPurpleHover: "#755DF7"
    readonly property color focus: "#7DD3FC"
    // Neutral keyboard focus for controls; blue still marks selected content.
    readonly property color controlFocus: "#A5B5D4"

    readonly property color amber: "#F59E0B"
    readonly property color amberMuted: "#3D2E14"
    readonly property color warmSurface: "#142441"
    readonly property color danger: "#EF4444"
    readonly property color dangerMuted: "#3E1E22"
    readonly property color success: "#10B981"
    readonly property color successMuted: "#0E3528"
    readonly property color warning: "#F59E0B"
    readonly property color warningMuted: "#3D2E14"
    readonly property color scrim: "#D0040A17"
    readonly property color video: "#040A14"
    readonly property color codeSurface: "#070E1C"
    readonly property color codeText: "#C7D8EE"
    readonly property color captionOverlay: "#E0071225"
    readonly property color captionText: "#FFFFFF"

    readonly property int radius: 6
    readonly property int radiusSmall: 4
    readonly property int radiusTiny: 4

    readonly property int space4: 4
    readonly property int space8: 8
    readonly property int space12: 12
    readonly property int space16: 16
    readonly property int space20: 20
    readonly property int space24: 24
    readonly property int space32: 32
    readonly property int gap: space16

    readonly property int label: TypeScale.metadata
    readonly property int caption: TypeScale.label
    readonly property int body: TypeScale.control
    readonly property int bodyLarge: TypeScale.body
    readonly property int h3: TypeScale.section
    readonly property int h2: TypeScale.title
    readonly property int h1: TypeScale.pageTitle
    readonly property int display: TypeScale.display

    readonly property int iconSmall: 14
    readonly property int icon: 16
    readonly property int iconLarge: 20
    readonly property string iconFont: "Segoe Fluent Icons"

    readonly property int motionFast: motionEnabled ? Motion.fast : 0
    readonly property int motionStandard: motionEnabled ? Motion.standard : 0
    readonly property int motionSlow: motionEnabled ? Motion.slow : 0
    readonly property int navigationExpanded: UiMetrics.navigationExpanded
    readonly property int navigationCompact: UiMetrics.navigationCompact
    readonly property int commandBarHeight: 48
}
