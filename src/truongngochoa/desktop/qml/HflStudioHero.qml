pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import "."

Item {
    id: root

    implicitHeight: 375
    Layout.fillWidth: true
    Layout.preferredHeight: 375

    signal requestCreate(string mode, string prompt)
    signal requestManualStudio
    signal requestDownload

    property string activeTab: "text"
    property bool isPlaying: false
    property real playbackProgress: 0.37
    property string activeThumbnail: Qt.resolvedUrl("../assets/showcase/hero_fashion_sunrise.jpg")
    property string selectedVoice: "Minh Trí (Hà Nội - Trầm ấm)"
    property string selectedRatio: "16:9"
    property string selectedStyle: "Cinematic"

    RowLayout {
        anchors.fill: parent
        spacing: Theme.space16

        // ==========================================
        // LEFT CARD: AI VIDEO CREATOR STUDIO
        // ==========================================
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 620
            radius: Theme.radius
            color: Theme.surface
            border.width: 1
            border.color: Theme.outline

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.space16
                spacing: Theme.space12

                // Header with AI Studio badge
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.space8

                    Rectangle {
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                        radius: 8
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: Theme.interactive }
                            GradientStop { position: 1.0; color: Theme.accentPurple }
                        }
                        Text {
                            anchors.centerIn: parent
                            text: "✦"
                            color: "#FFFFFF"
                            font.pixelSize: 13
                            font.bold: true
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text {
                            text: qsTr("Trình tạo video AI (HFL Studio)")
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: TypeScale.section
                            font.weight: Font.Bold
                        }
                        Text {
                            text: qsTr("Tự động tạo video, phụ đề và lồng tiếng từ kịch bản hoặc hình ảnh.")
                            color: Theme.textMuted
                            font.family: Theme.fontFamily
                            font.pixelSize: TypeScale.metadata
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 72
                        Layout.preferredHeight: 22
                        radius: Theme.radiusSmall
                        color: Theme.interactiveMuted
                        border.width: 1
                        border.color: Theme.interactiveOutline

                        Text {
                            anchors.centerIn: parent
                            text: "PRO AI v2.5"
                            color: Theme.interactive
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            font.weight: Font.Bold
                        }
                    }
                }

                // 4 Input Mode Tabs
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    radius: Theme.radiusSmall
                    color: Theme.input
                    border.width: 1
                    border.color: Theme.outline

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 3
                        spacing: 4

                        Repeater {
                            model: [
                                { key: "text", label: qsTr("Văn bản"), icon: "✎" },
                                { key: "image", label: qsTr("Hình ảnh"), icon: "📷" },
                                { key: "link", label: qsTr("Đường dẫn"), icon: "🔗" },
                                { key: "file", label: qsTr("Tệp tin"), icon: "📁" }
                            ]

                            delegate: Rectangle {
                                id: tabButton
                                required property var modelData
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: Theme.radiusSmall - 1
                                color: root.activeTab === modelData.key ? Theme.surfaceElevated : "transparent"
                                border.width: root.activeTab === modelData.key ? 1 : 0
                                border.color: Theme.outlineStrong

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 6
                                    Text {
                                        text: tabButton.modelData.icon
                                        color: root.activeTab === tabButton.modelData.key ? Theme.interactive : Theme.textMuted
                                        font.pixelSize: 12
                                    }
                                    Text {
                                        text: tabButton.modelData.label
                                        color: root.activeTab === tabButton.modelData.key ? Theme.text : Theme.textMuted
                                        font.family: Theme.fontFamily
                                        font.pixelSize: TypeScale.control
                                        font.weight: root.activeTab === tabButton.modelData.key ? Font.DemiBold : Font.Normal
                                    }
                                }

                                HoverHandler { cursorShape: Qt.PointingHandCursor }
                                TapHandler { onTapped: root.activeTab = tabButton.modelData.key }
                            }
                        }
                    }
                }

                // Prompt Input Box
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: Theme.radiusSmall
                    color: Theme.input
                    border.width: 1
                    border.color: promptArea.activeFocus ? Theme.interactive : Theme.outline

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.space8
                        spacing: Theme.space4

                        Flickable {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            TextArea {
                                id: promptArea
                                width: parent.width
                                wrapMode: TextEdit.Wrap
                                color: Theme.text
                                font.family: Theme.fontFamily
                                font.pixelSize: TypeScale.control
                                text: qsTr("Video cinematic giới thiệu bộ sưu tập áo thun streetwear, người mẫu ngắm bình minh trên đỉnh núi mây bay bồng bềnh, phong cách điện ảnh 4K 60fps.")
                                placeholderText: qsTr("Mô tả video bạn muốn tạo (kịch bản, nhân vật, bối cảnh, góc quay, hiệu ứng điện ảnh)...")
                                placeholderTextColor: Theme.textDisabled
                                background: null
                                padding: 0
                            }
                        }

                        // Quick suggestion prompt chips
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Theme.space4

                            Text {
                                text: qsTr("Gợi ý:")
                                color: Theme.textSubtle
                                font.family: Theme.fontFamily
                                font.pixelSize: TypeScale.metadata
                            }

                            Repeater {
                                model: [qsTr("Áo thun streetwear"), qsTr("Thiên nhiên Đà Lạt"), qsTr("Công nghệ AI")]
                                delegate: Rectangle {
                                    id: chip
                                    required property string modelData
                                    Layout.preferredHeight: 20
                                    implicitWidth: chipText.implicitWidth + 12
                                    radius: 10
                                    color: Theme.surfaceElevated
                                    border.width: 1
                                    border.color: Theme.outline

                                    Text {
                                        id: chipText
                                        anchors.centerIn: parent
                                        text: chip.modelData
                                        color: Theme.textMuted
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 11
                                    }

                                    HoverHandler { cursorShape: Qt.PointingHandCursor }
                                    TapHandler {
                                        onTapped: promptArea.text = qsTr("Video phong cách ") + chip.modelData + qsTr(", chất lượng 4K Ultra HD.")
                                    }
                                }
                            }
                        }
                    }
                }

                // Settings Row: Voice, Ratio, Style
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.space8

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text {
                            text: qsTr("Giọng đọc AI")
                            color: Theme.textMuted
                            font.family: Theme.fontFamily
                            font.pixelSize: TypeScale.metadata
                        }
                        AppComboBox {
                            Layout.fillWidth: true
                            model: [qsTr("Minh Trí (Hà Nội)"), qsTr("Lan Hương (Sài Gòn)"), qsTr("Hoài Nam (Miền Tây)")]
                            currentIndex: 0
                        }
                    }

                    ColumnLayout {
                        Layout.preferredWidth: 100
                        spacing: 2
                        Text {
                            text: qsTr("Tỷ lệ")
                            color: Theme.textMuted
                            font.family: Theme.fontFamily
                            font.pixelSize: TypeScale.metadata
                        }
                        AppComboBox {
                            Layout.fillWidth: true
                            model: ["16:9", "9:16", "1:1"]
                            currentIndex: 0
                        }
                    }

                    ColumnLayout {
                        Layout.preferredWidth: 130
                        spacing: 2
                        Text {
                            text: qsTr("Phong cách")
                            color: Theme.textMuted
                            font.family: Theme.fontFamily
                            font.pixelSize: TypeScale.metadata
                        }
                        AppComboBox {
                            Layout.fillWidth: true
                            model: [qsTr("Điện ảnh 4K"), qsTr("Anime"), qsTr("Chân thực")]
                            currentIndex: 0
                        }
                    }
                }

                // Big Gradient Generate Button
                Rectangle {
                    id: generateButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    radius: Theme.radius
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: Theme.interactive }
                        GradientStop { position: 1.0; color: Theme.accentPurple }
                    }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: Theme.space8

                        Text {
                            text: "▶"
                            color: "#FFFFFF"
                            font.pixelSize: 14
                            font.bold: true
                        }

                        Text {
                            text: qsTr("Tạo video bằng AI (Generate Video)")
                            color: Theme.textOnAccent
                            font.family: Theme.fontFamily
                            font.pixelSize: TypeScale.control
                            font.weight: Font.Bold
                        }
                    }

                    HoverHandler { id: genHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler {
                        onTapped: root.requestCreate(root.activeTab, promptArea.text)
                    }

                    opacity: genHover.hovered ? 0.92 : 1.0
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                }
            }
        }

        // ==========================================
        // RIGHT CARD: VIDEO PREVIEW PLAYER
        // ==========================================
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 500
            radius: Theme.radius
            color: Theme.surface
            border.width: 1
            border.color: Theme.outline

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.space16
                spacing: Theme.space8

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.space8

                    Text {
                        text: qsTr("Khung xem trước video")
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: TypeScale.section
                        font.weight: Font.Bold
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        Layout.preferredWidth: 88
                        Layout.preferredHeight: 22
                        radius: Theme.radiusSmall
                        color: Theme.successMuted
                        border.width: 1
                        border.color: Theme.success

                        Text {
                            anchors.centerIn: parent
                            text: "● AI Rendered"
                            color: Theme.success
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            font.weight: Font.Bold
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 64
                        Layout.preferredHeight: 22
                        radius: Theme.radiusSmall
                        color: Theme.interactiveMuted
                        border.width: 1
                        border.color: Theme.interactiveOutline

                        Text {
                            anchors.centerIn: parent
                            text: "4K 60fps"
                            color: Theme.interactive
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            font.weight: Font.Bold
                        }
                    }
                }

                // 16:9 Video Player Surface
                Rectangle {
                    id: playerSurface
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: Theme.radiusSmall
                    color: Theme.video
                    clip: true
                    border.width: 1
                    border.color: Theme.outlineStrong

                    Image {
                        anchors.fill: parent
                        source: root.activeThumbnail
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                    }

                    // Cinematic subtle top/bottom gradient overlay
                    Rectangle {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 50
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#A0071225" }
                            GradientStop { position: 1.0; color: "transparent" }
                        }
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 60
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 1.0; color: "#D0071225" }
                        }
                    }

                    // Watermark badge in corner
                    Text {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.margins: Theme.space8
                        text: "HFL AI STUDIO"
                        color: "#B0F1F5FF"
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        font.weight: Font.Bold
                    }

                    // Center Play / Pause button
                    Rectangle {
                        anchors.centerIn: parent
                        width: 56
                        height: 56
                        radius: 28
                        color: playHover.hovered ? Theme.interactive : "#90081326"
                        border.width: 2
                        border.color: "#FFFFFF"

                        Text {
                            anchors.centerIn: parent
                            text: root.isPlaying ? "❚❚" : "▶"
                            color: "#FFFFFF"
                            font.pixelSize: 18
                            font.bold: true
                        }

                        HoverHandler { id: playHover; cursorShape: Qt.PointingHandCursor }
                        TapHandler { onTapped: root.isPlaying = !root.isPlaying }
                    }
                }

                // Playback Scrubber and Timecode
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: root.isPlaying ? "01:24" : "00:00"
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: TypeScale.metadata
                            font.weight: Font.DemiBold
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: "03:45"
                            color: Theme.textMuted
                            font.family: Theme.fontFamily
                            font.pixelSize: TypeScale.metadata
                        }
                    }

                    // Scrubber Bar
                    Rectangle {
                        id: scrubberBar
                        Layout.fillWidth: true
                        Layout.preferredHeight: 6
                        radius: 3
                        color: Theme.surfaceElevated

                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: parent.width * root.playbackProgress
                            radius: 3
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: Theme.interactive }
                                GradientStop { position: 1.0; color: Theme.accentPurple }
                            }
                        }

                        // Scrubber handle
                        Rectangle {
                            x: Math.max(0, Math.min(scrubberBar.width - width, (scrubberBar.width * root.playbackProgress) - 6))
                            anchors.verticalCenter: parent.verticalCenter
                            width: 12
                            height: 12
                            radius: 6
                            color: "#FFFFFF"
                            border.width: 2
                            border.color: Theme.interactive
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: function (mouse) {
                                root.playbackProgress = Math.max(0, Math.min(1, mouse.x / width));
                            }
                        }
                    }
                }

                // Bottom Action Buttons
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.space8

                    StudioButton {
                        Layout.fillWidth: true
                        variant: "primary"
                        text: qsTr("Xuất video")
                        iconName: "share"
                        onClicked: root.requestManualStudio()
                    }

                    StudioButton {
                        Layout.fillWidth: true
                        variant: "secondary"
                        text: qsTr("Mở Studio")
                        iconName: "edit"
                        onClicked: root.requestManualStudio()
                    }

                    StudioButton {
                        Layout.preferredWidth: 40
                        variant: "ghost"
                        iconName: "download"
                        toolTipText: qsTr("Tải video về máy")
                        onClicked: root.requestDownload()
                    }
                }
            }
        }
    }
}
