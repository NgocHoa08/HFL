pragma Singleton
import QtQuick

QtObject {
    property bool motionEnabled: true

    readonly property string fontFamily: "Segoe UI Variable"

    // Sleek Deep Blue Studio. Neutral surfaces carry cool dark navy hierarchy;
    // electric cyan / sapphire blue is reserved for direct interaction, focus and progress.
    readonly property color window: "#0A0E17"
    readonly property color surface: "#111827"
    readonly property color surfaceElevated: "#182234"
    readonly property color surfaceMuted: "#1F2B42"
    readonly property color surfaceStrong: "#263552"
    readonly property color input: "#0D1322"
    readonly property color sidebar: "#0D121F"
    readonly property color sidebarHover: "#182234"
    readonly property color sidebarSelected: "#1A2E4C"
    readonly property color topBar: "#0D121F"
    readonly property color windowCaptionHover: "#1F2B42"
    readonly property color windowCaptionPressed: "#263552"
    readonly property color windowCloseHover: "#c42b1c"
    readonly property color windowClosePressed: "#a4262c"
    readonly property color outline: "#283957"
    readonly property color outlineStrong: "#3A507A"
    readonly property color divider: "#1F2B42"

    readonly property color text: "#F0F6FC"
    readonly property color textMuted: "#9DB0CE"
    readonly property color textSubtle: "#758AA8"
    readonly property color textDisabled: "#566882"
    readonly property color textOnAccent: "#051329"
    readonly property color textOnDark: "#F0F6FC"
    readonly property color textOnDarkMuted: "#9DB0CE"

    readonly property color interactive: "#38BDF8"
    readonly property color interactiveHover: "#60CEFF"
    readonly property color interactivePressed: "#0284C7"
    readonly property color interactiveMuted: "#0C304E"
    readonly property color interactiveOutline: "#1E6B9E"
    readonly property color focus: "#7DD3FC"
    // Neutral keyboard focus for controls; blue still marks selected content.
    readonly property color controlFocus: "#9DB0CE"

    readonly property color amber: "#38BDF8"
    readonly property color amberMuted: "#0C304E"
    readonly property color warmSurface: "#182234"
    readonly property color danger: "#F87171"
    readonly property color dangerMuted: "#3E1E22"
    readonly property color success: "#34D399"
    readonly property color successMuted: "#103426"
    readonly property color warning: "#FBBF24"
    readonly property color warningMuted: "#3D2E14"
    readonly property color scrim: "#b8000000"
    readonly property color video: "#05080E"
    readonly property color codeSurface: "#090D15"
    readonly property color codeText: "#C7D8EE"
    readonly property color captionOverlay: "#DC0A0E17"
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
