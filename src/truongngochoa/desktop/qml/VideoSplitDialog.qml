pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import "."

AppDialog {
    id: root

    preferredWidth: 620
    maximumWidth: 680
    title: qsTr("Cắt chia đôi video")
    subtitle: qsTr("Chia video dài thành 2 phần độc lập (Phần 1 & Phần 2) để đăng mạng xã hội hoặc lưu trữ")

    function openForFile(path) {
        if (path) {
            AppController.videoSplit.setSourceVideo(path);
        }
        open();
    }

    onOpened: {
        if (!AppController.videoSplit.hasSource) {
            AppController.videoSplit.reset();
        }
    }

    // --- 1. Chọn video nguồn ---
    SettingLabel {
        Layout.fillWidth: true
        text: qsTr("Tệp video nguồn")
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.space8

        AutoSaveTextField {
            id: sourceField
            Layout.fillWidth: true
            readOnly: true
            text: AppController.videoSplit.sourcePath
            placeholderText: qsTr("Chưa chọn video... Bấm 'Chọn video' để mở tệp")
            accessibleName: qsTr("Đường dẫn tệp video nguồn")
        }

        StudioButton {
            text: qsTr("Chọn video")
            iconGlyph: "\uE8E5"
            variant: "secondary"
            enabled: !AppController.videoSplit.busy
            onClicked: AppController.videoSplit.browseSourceVideo()
        }
    }

    // --- 2. Thẻ thông tin video ---
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 68
        visible: AppController.videoSplit.hasSource
        radius: Theme.radiusSmall
        color: Theme.surfaceElevated
        border.width: 1
        border.color: Theme.outline

        RowLayout {
            anchors.fill: parent
            anchors.margins: Theme.space12
            spacing: Theme.space16

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    Layout.fillWidth: true
                    text: AppController.videoSplit.sourceName
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: TypeScale.control
                    font.weight: Font.DemiBold
                    textFormat: Text.PlainText
                    elide: Text.ElideMiddle
                }

                Text {
                    Layout.fillWidth: true
                    text: qsTr("Độ phân giải: %1  ·  Dung lượng: %2")
                        .arg(AppController.videoSplit.sourceResolution)
                        .arg(AppController.videoSplit.sourceFileSize)
                    color: Theme.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: TypeScale.metadata
                    textFormat: Text.PlainText
                }
            }

            Rectangle {
                Layout.preferredHeight: 32
                Layout.preferredWidth: durationText.implicitWidth + Theme.space16
                radius: Theme.radiusSmall
                color: Theme.surfaceMuted

                Text {
                    id: durationText
                    anchors.centerIn: parent
                    text: qsTr("Thời lượng: %1").arg(AppController.videoSplit.sourceDurationFormatted)
                    color: Theme.accent
                    font.family: Theme.fontFamily
                    font.pixelSize: TypeScale.label
                    font.weight: Font.Medium
                    textFormat: Text.PlainText
                }
            }
        }
    }

    // --- 3. Cấu hình chia 2 phần ---
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Theme.space8
        visible: AppController.videoSplit.hasSource

        SettingLabel {
            Layout.fillWidth: true
            text: qsTr("Cấu hình 2 phần video sau khi cắt")
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.space12

            // Card Phần 1
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 74
                radius: Theme.radiusSmall
                color: Theme.surfaceElevated
                border.width: 1
                border.color: Theme.focus

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.space8
                    spacing: 2

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: qsTr("Phần 1")
                            color: Theme.focus
                            font.family: Theme.fontFamily
                            font.pixelSize: TypeScale.label
                            font.weight: Font.Bold
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: qsTr("00:00 → %1 (%2)").arg(AppController.videoSplit.splitPointFormatted).arg(AppController.videoSplit.part1DurationFormatted)
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: TypeScale.metadata
                            font.weight: Font.Medium
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: AppController.videoSplit.part1FileName
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: TypeScale.metadata
                        textFormat: Text.PlainText
                        elide: Text.ElideMiddle
                    }
                }
            }

            // Card Phần 2
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 74
                radius: Theme.radiusSmall
                color: Theme.surfaceElevated
                border.width: 1
                border.color: Theme.focus

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.space8
                    spacing: 2

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: qsTr("Phần 2")
                            color: Theme.focus
                            font.family: Theme.fontFamily
                            font.pixelSize: TypeScale.label
                            font.weight: Font.Bold
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: qsTr("%1 → %2 (%3)").arg(AppController.videoSplit.splitPointFormatted).arg(AppController.videoSplit.sourceDurationFormatted).arg(AppController.videoSplit.part2DurationFormatted)
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: TypeScale.metadata
                            font.weight: Font.Medium
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: AppController.videoSplit.part2FileName
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: TypeScale.metadata
                        textFormat: Text.PlainText
                        elide: Text.ElideMiddle
                    }
                }
            }
        }

        // Thanh điều chỉnh tỷ lệ cắt
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.space8

            Text {
                text: qsTr("Tỷ lệ chia: %1% / %2%")
                    .arg(Math.round(AppController.videoSplit.splitPercent))
                    .arg(100 - Math.round(AppController.videoSplit.splitPercent))
                color: Theme.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: TypeScale.metadata
            }

            Item { Layout.fillWidth: true }

            StudioButton {
                text: qsTr("Chia đều 50/50")
                variant: "ghost"
                visible: Math.round(AppController.videoSplit.splitPercent) !== 50
                enabled: !AppController.videoSplit.busy
                onClicked: AppController.videoSplit.setSplitPercent(50)
            }
        }

        StudioSlider {
            Layout.fillWidth: true
            from: 10
            to: 90
            stepSize: 1
            value: AppController.videoSplit.splitPercent
            enabled: !AppController.videoSplit.busy
            onMoved: AppController.videoSplit.setSplitPercent(value)
        }
    }

    // --- 4. Thư mục lưu ---
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Theme.space4
        visible: AppController.videoSplit.hasSource

        SettingLabel {
            Layout.fillWidth: true
            text: qsTr("Thư mục lưu 2 phần video")
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.space8

            AutoSaveTextField {
                Layout.fillWidth: true
                readOnly: true
                text: AppController.videoSplit.outputDirectory
                accessibleName: qsTr("Thư mục lưu kết quả")
            }

            StudioButton {
                text: qsTr("Đổi thư mục")
                variant: "secondary"
                enabled: !AppController.videoSplit.busy
                onClicked: AppController.videoSplit.browseOutputDirectory()
            }
        }
    }

    // --- 5. Tùy chọn cắt nhanh ---
    RowLayout {
        Layout.fillWidth: true
        visible: AppController.videoSplit.hasSource
        spacing: Theme.space8

        StudioCheckBox {
            text: qsTr("Cắt siêu nhanh (Stream Copy - giữ nguyên 100% chất lượng gốc, chỉ mất vài giây)")
            checked: AppController.videoSplit.splitMode === "fast"
            enabled: !AppController.videoSplit.busy
            onToggled: AppController.videoSplit.setSplitMode(checked ? "fast" : "reencode")
        }
    }

    // --- 6. Tiến trình & thông báo ---
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Theme.space4
        visible: AppController.videoSplit.busy || AppController.videoSplit.statusMessage.length > 0

        AppProgressBar {
            Layout.fillWidth: true
            value: AppController.videoSplit.progress
            visible: AppController.videoSplit.busy
        }

        Text {
            Layout.fillWidth: true
            text: AppController.videoSplit.statusMessage
            color: AppController.videoSplit.errorMessage.length > 0
                ? Theme.danger
                : (AppController.videoSplit.splitCompleted ? Theme.focus : Theme.textMuted)
            font.family: Theme.fontFamily
            font.pixelSize: TypeScale.control
            font.weight: AppController.videoSplit.splitCompleted ? Font.Medium : Font.Normal
            textFormat: Text.PlainText
            wrapMode: Text.WordWrap
        }
    }

    // --- 7. Các hành động sau khi cắt thành công ---
    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.space8
        visible: AppController.videoSplit.splitCompleted

        StudioButton {
            text: qsTr("Mở thư mục chứa 2 video")
            iconGlyph: "\uE8DA"
            variant: "secondary"
            onClicked: AppController.videoSplit.openOutputDirectory()
        }

        StudioButton {
            text: qsTr("Thêm 2 phần vào hàng đợi đăng mạng xã hội")
            iconGlyph: "\uE710"
            variant: "primary"
            onClicked: {
                AppController.videoSplit.addPartsToSocialQueue();
                root.close();
            }
        }
    }

    footerActions: [
        StudioButton {
            text: AppController.videoSplit.busy ? qsTr("Dừng lại") : qsTr("Đóng")
            variant: AppController.videoSplit.busy ? "danger" : "ghost"
            onClicked: {
                if (AppController.videoSplit.busy) {
                    AppController.videoSplit.cancelSplit();
                } else {
                    root.close();
                }
            }
        },
        StudioButton {
            text: qsTr("Bắt đầu cắt chia 2 phần")
            variant: "primary"
            iconGlyph: "\uE7C3"
            enabled: AppController.videoSplit.hasSource && !AppController.videoSplit.busy
            visible: !AppController.videoSplit.splitCompleted
            onClicked: AppController.videoSplit.startSplit()
        }
    ]
}
