pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import "."

AppDialog {
    id: root
    property var controller: AppController
    readonly property bool compactLayout: root.parent && root.parent.height < 800
    readonly property int qrSize: compactLayout ? 136 : 160

    title: qsTr("Giới thiệu")
    subtitle: qsTr("Trương Ngọc Hoà · Phiên bản %1").arg(root.controller.currentAppVersion)
    preferredWidth: 650
    maximumWidth: 680
    maximumHeight: 620
    bodySpacing: Theme.space12

    ScrollView {
        id: aboutScroll
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.minimumHeight: 0
        implicitHeight: aboutContent.implicitHeight
        contentWidth: availableWidth
        contentHeight: aboutContent.implicitHeight
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AlwaysOff

        ColumnLayout {
            id: aboutContent
            width: aboutScroll.availableWidth
            spacing: root.compactLayout ? Theme.space8 : Theme.space12

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.space16

                Image {
                    Layout.preferredWidth: root.compactLayout ? 56 : 68
                    Layout.preferredHeight: root.compactLayout ? 56 : 68
                    source: Qt.resolvedUrl("../assets/branding/truongngochoa-mark.png")
                    sourceSize.width: 176
                    sourceSize.height: 176
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    Accessible.name: qsTr("Biểu tượng Trương Ngọc Hoà")
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.space4

                    Text {
                        Layout.fillWidth: true
                        text: "Trương Ngọc Hoà"
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: TypeScale.title
                        font.weight: Font.DemiBold
                        textFormat: Text.PlainText
                    }

                    Text {
                        Layout.fillWidth: true
                        text: qsTr("Xử lý, dịch và lồng tiếng video trên Windows.")
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: TypeScale.body
                        textFormat: Text.PlainText
                        wrapMode: Text.WordWrap
                    }

                    Text {
                        Layout.fillWidth: true
                        text: qsTr("Bản quyền © 2026 Trương Ngọc Hoà")
                        color: Theme.textSubtle
                        font.family: Theme.fontFamily
                        font.pixelSize: TypeScale.label
                        textFormat: Text.PlainText
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Theme.divider
            }

            Text {
                Layout.fillWidth: true
                text: qsTr("Ứng dụng Trương Ngọc Hoà hỗ trợ tải video đa nền tảng, nhận dạng giọng nói, dịch tự động, tạo phụ đề và lồng tiếng ngay trên máy tính của bạn.")
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: TypeScale.control
                textFormat: Text.PlainText
                wrapMode: Text.WordWrap
                lineHeight: root.compactLayout ? 1.25 : 1.35
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.space4

                AboutLinkRow {
                    label: qsTr("Tác giả / Chủ sở hữu")
                    value: "Trương Ngọc Hoà"
                    copyValue: "Trương Ngọc Hoà"
                    linkEnabled: false
                }

                AboutLinkRow {
                    label: qsTr("Giấy phép")
                    value: "LICENSE"
                    destination: "LICENSE"
                    copyValue: "LICENSE"
                }
            }
        }
    }

    footerActions: StudioButton {
        text: qsTr("Đóng")
        variant: "primary"
        onClicked: root.close()
    }
}
