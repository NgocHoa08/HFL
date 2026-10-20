import QtQuick
import QtQuick.Layouts
import "."

AppSurface {
    id: root

    signal requestUrlImport
    signal requestDownloadProjectImport
    signal requestReviewTranslation

    property bool dropActive: false
    property bool compact: false
    property string activeView: AppController.hasSelectedOutput ? "output" : "input"

    Connections {
        target: AppController
        function onSelectedVideoChanged() {
            root.activeView = AppController.hasSelectedOutput ? "output" : "input";
        }
        function onVideoExportCompleted(videoId, path) {
            root.activeView = "output";
        }
    }

    padding: Theme.space12
    spacing: Theme.space12

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.space8

        SectionHeader {
            Layout.fillWidth: true
            title: AppController.hasSelectedOutput ? qsTr("Trình phát video") : qsTr("Video nguồn")
        }

        Rectangle {
            visible: AppController.hasSelectedOutput
            Layout.preferredHeight: 28
            Layout.preferredWidth: 180
            radius: Theme.radiusSmall
            color: Theme.surfaceMuted
            border.width: 1
            border.color: Theme.outline

            RowLayout {
                anchors.fill: parent
                spacing: 2
                anchors.margins: 2

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: Theme.radiusSmall - 1
                    color: root.activeView === "input" ? Theme.surfaceElevated : "transparent"
                    border.width: root.activeView === "input" ? 1 : 0
                    border.color: Theme.outlineStrong

                    Text {
                        anchors.centerIn: parent
                        text: qsTr("Bản gốc")
                        color: root.activeView === "input" ? Theme.text : Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: TypeScale.metadata
                        font.weight: root.activeView === "input" ? Font.DemiBold : Font.Normal
                    }

                    TapHandler {
                        onTapped: root.activeView = "input"
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: Theme.radiusSmall - 1
                    color: root.activeView === "output" ? Theme.focus : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: qsTr("Bản đã sửa")
                        color: root.activeView === "output" ? Theme.textOnAccent : Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: TypeScale.metadata
                        font.weight: root.activeView === "output" ? Font.DemiBold : Font.Normal
                    }

                    TapHandler {
                        onTapped: root.activeView = "output"
                    }
                }
            }
        }
    }

    Rectangle {
        id: videoFrame

        Layout.fillWidth: true
        Layout.preferredHeight: root.compact ? Math.max(218, Math.min(276, width * 9 / 16 + 48)) : Math.max(278, Math.min(348, width * 9 / 16 + 48))
        radius: Theme.radius
        color: root.dropActive ? Theme.interactiveMuted : Theme.video
        border.width: root.dropActive || AppController.videoPath.length > 0 ? 2 : 1
        border.color: root.dropActive ? Theme.focus : AppController.videoPath.length > 0 ? Theme.outlineStrong : Theme.outline
        clip: true

        SourceVideoPlayer {
            id: sourcePlayer
            anchors.fill: parent
            anchors.margins: 2
            source: (root.activeView === "output" && AppController.hasSelectedOutput)
                ? AppController.selectedOutputSource
                : AppController.selectedInputSource
            thumbnailSource: AppController.videoThumbnailSource
            visible: AppController.videoPath.length > 0
        }

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: Theme.space8
            visible: AppController.hasSelectedOutput && AppController.videoPath.length > 0
            radius: Theme.radiusSmall
            color: root.activeView === "output" ? Theme.focus : Theme.surfaceElevated
            opacity: 0.92
            implicitHeight: 24
            implicitWidth: badgeText.implicitWidth + Theme.space16

            Text {
                id: badgeText
                anchors.centerIn: parent
                text: root.activeView === "output" ? qsTr("Đang xem: Bản đã sửa") : qsTr("Đang xem: Video gốc")
                color: root.activeView === "output" ? Theme.textOnAccent : Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: TypeScale.metadata
                font.weight: Font.Medium
            }
        }

        Column {
            anchors.centerIn: parent
            width: Math.min(330, parent.width - 40)
            spacing: Theme.space8
            visible: AppController.videoPath.length === 0

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: root.compact ? 38 : 46
                height: width
                radius: width / 2
                color: root.dropActive ? Theme.interactive : Theme.surfaceElevated
                border.width: root.dropActive ? 0 : 1
                border.color: Theme.outlineStrong

                AppIcon {
                    anchors.centerIn: parent
                    width: root.compact ? 18 : 22
                    height: width
                    glyph: root.dropActive ? "\uE898" : "\uE710"
                    iconColor: root.dropActive ? Theme.textOnAccent : Theme.interactive
                    iconSize: Theme.iconLarge
                }
            }

            Text {
                width: parent.width
                text: root.dropActive ? qsTr("Thả video để nhập") : qsTr("Chọn video nguồn")
                color: Theme.text
                font.pixelSize: Theme.bodyLarge
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignHCenter
                textFormat: Text.PlainText
            }

            Text {
                width: parent.width
                text: root.dropActive ? qsTr("Thả để thêm video nguồn") : qsTr("MP4, MOV or MKV")
                color: Theme.textMuted
                font.pixelSize: Theme.caption
                horizontalAlignment: Text.AlignHCenter
                textFormat: Text.PlainText
            }
        }

        DropArea {
            id: sourceDropArea
            anchors.fill: parent
            keys: ["text/uri-list"]
            enabled: AppController.canEditSelectedVideo

            onEntered: function (drag) {
                if (drag.hasUrls) {
                    root.dropActive = true;
                    drag.accept();
                }
            }
            onExited: root.dropActive = false
            onDropped: function (drop) {
                root.dropActive = false;
                if (!drop.urls || drop.urls.length === 0)
                    return;
                if (AppController.hasSelectedVideo)
                    AppController.replaceSelectedVideoVideo(String(drop.urls[0]));
                else
                    AppController.importVideo(String(drop.urls[0]));
            }
        }

        HoverHandler {
            cursorShape: AppController.videoPath.length === 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
        }

        TapHandler {
            enabled: AppController.videoPath.length === 0 && AppController.canEditSelectedVideo
            onTapped: sourceImportButton.openMenu()
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.space12

        ColumnLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: AppController.videoPath.length > 0 ? qsTr("Đã nhập video nguồn") : qsTr("Chưa chọn video nguồn")
                color: Theme.text
                font.pixelSize: Theme.caption
                font.weight: Font.DemiBold
                textFormat: Text.PlainText
            }

            Text {
                Layout.fillWidth: true
                text: AppController.videoPath || qsTr("Chọn một tệp để bắt đầu")
                color: Theme.textMuted
                font.pixelSize: Theme.caption
                textFormat: Text.PlainText
                elide: Text.ElideMiddle
            }
        }

        MediaSourceImportButton {
            id: sourceImportButton

            visible: AppController.videoPath.length === 0
            Layout.preferredWidth: 132
            enabled: AppController.canEditSelectedVideo
            onFileRequested: AppController.browseVideo()
            onLinkRequested: root.requestUrlImport()
            onDownloadProjectRequested: root.requestDownloadProjectImport()
        }

        StudioButton {
            visible: AppController.reviewSegments.length > 0
            text: qsTr("Sửa phụ đề từng đoạn")
            iconGlyph: "\uE70F"
            variant: "secondary"
            onClicked: root.requestReviewTranslation()
        }

        MediaSourceImportButton {
            visible: AppController.videoPath.length > 0
            text: qsTr("Thay thế")
            iconGlyph: "\uE8B7"
            enabled: AppController.canEditSelectedVideo
            onFileRequested: AppController.browseVideo()
            onLinkRequested: root.requestUrlImport()
            onDownloadProjectRequested: root.requestDownloadProjectImport()
        }
    }
}
