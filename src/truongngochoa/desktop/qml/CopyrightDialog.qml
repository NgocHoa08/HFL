pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import "."

AppDialog {
    id: root
    objectName: "copyrightDialog"
    title: qsTr("Bản quyền")
    subtitle: "Trương Ngọc Hoà"
    preferredWidth: 650
    preferredHeight: Math.ceil(content.implicitHeight + headerHeight + footerHeight + Theme.space20 * 2 + 4)
    maximumWidth: 680
    maximumHeight: 620

    ScrollView {
        id: scroll
        objectName: "copyrightScroll"
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.minimumHeight: 0
        contentWidth: availableWidth
        contentHeight: content.implicitHeight
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AsNeeded
        ColumnLayout {
            id: content
            objectName: "copyrightTextContent"
            width: scroll.availableWidth
            spacing: Theme.space16
            Text {
                Layout.fillWidth: true
                text: qsTr("© 2026 Trương Ngọc Hoà\nTác giả và chủ sở hữu Trương Ngọc Hoà.")
                font.family: Theme.fontFamily
                font.pixelSize: TypeScale.body
                color: Theme.text
                wrapMode: Text.WordWrap
                textFormat: Text.PlainText
                lineHeight: 1.4
            }
            Text {
                Layout.fillWidth: true
                text: qsTr("Ứng dụng Trương Ngọc Hoà được phát triển và sở hữu bởi Trương Ngọc Hoà. Người sử dụng có thể sử dụng, chỉnh sửa và khai thác theo các điều khoản được quy định trong tệp giấy phép LICENSE.")
                font.family: Theme.fontFamily
                font.pixelSize: TypeScale.control
                color: Theme.textMuted
                wrapMode: Text.WordWrap
                textFormat: Text.PlainText
                lineHeight: 1.4
            }
            AboutLinkRow {
                label: qsTr("Giấy phép")
                value: "LICENSE"
                destination: "LICENSE"
                copyValue: destination
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Theme.divider
            }
            Text {
                Layout.fillWidth: true
                text: qsTr("Thư viện, mô hình và tài nguyên đi kèm tuân theo giấy phép riêng. Người dùng có trách nhiệm bảo đảm quyền sử dụng video, âm nhạc và mẫu giọng nói.")
                font.family: Theme.fontFamily
                font.pixelSize: TypeScale.control
                color: Theme.textMuted
                wrapMode: Text.WordWrap
                textFormat: Text.PlainText
                lineHeight: 1.4
            }
            AboutLinkRow {
                label: qsTr("Thành phần")
                value: qsTr("Giấy phép và thông báo")
                destination: "https://github.com/NgocHoa08/HFL/blob/main/THIRD_PARTY_NOTICES.md"
                copyValue: destination
            }
        }
    }
    footerActions: StudioButton {
        text: qsTr("Đóng")
        variant: "primary"
        onClicked: root.close()
    }
}
