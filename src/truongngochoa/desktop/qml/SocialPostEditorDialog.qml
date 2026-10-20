pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "."

AppDialog {
    id: root

    signal saveRequested(int row, string caption, string hashtags, string scheduledFor)
    signal scheduleRequested(int row, string caption, string hashtags, string scheduledFor)

    property int row: -1
    property string fileName: ""
    property string initialCaption: ""
    property string initialHashtags: ""
    property string initialScheduledFor: ""
    readonly property int postLength: captionInput.text.length
        + (captionInput.text.length > 0 && hashtagInput.text.trim().length > 0 ? 1 : 0)
        + hashtagInput.text.trim().length

    preferredWidth: 620
    maximumWidth: 680
    title: qsTr("Chỉnh nội dung bài đăng")
    subtitle: root.fileName

    function openForItem(itemRow, name, caption, hashtags, itemScheduledFor) {
        row = itemRow
        fileName = name
        initialCaption = caption
        initialHashtags = hashtags
        initialScheduledFor = itemScheduledFor || ""
        captionInput.text = caption
        hashtagInput.text = hashtags
        const hasSched = initialScheduledFor.length > 0
        scheduleCheck.checked = hasSched
        scheduleTimeInput.text = hasSched
            ? (AppController.formatLocalTime(initialScheduledFor) || initialScheduledFor)
            : AppController.getLocalTimePlusHours(1)
        open()
    }

    function savePost() {
        if (root.postLength > 2200)
            return
        root.saveRequested(
            root.row,
            captionInput.text,
            hashtagInput.text,
            scheduleCheck.checked ? scheduleTimeInput.text : ""
        )
        root.close()
    }

    function saveAndScheduleNow() {
        if (root.postLength > 2200)
            return
        root.scheduleRequested(
            root.row,
            captionInput.text,
            hashtagInput.text,
            scheduleCheck.checked ? scheduleTimeInput.text : ""
        )
        root.close()
    }

    onOpened: captionInput.forceActiveFocus()

    RowLayout {
        Layout.fillWidth: true

        SettingLabel {
            Layout.fillWidth: true
            text: qsTr("Nội dung")
        }

        Text {
            text: qsTr("%1 / 2200").arg(root.postLength)
            color: root.postLength > 2200 ? Theme.danger : Theme.textSubtle
            font.family: Theme.fontFamily
            font.pixelSize: TypeScale.metadata
            textFormat: Text.PlainText
        }
    }

    AppTextArea {
        id: captionInput
        Layout.fillWidth: true
        Layout.preferredHeight: 140
        placeholderText: qsTr("Viết nội dung cho video")
        accessibleName: qsTr("Nội dung bài đăng")
        selectByMouse: true
    }

    SettingLabel {
        Layout.fillWidth: true
        text: qsTr("Hashtag")
        helpText: qsTr("Ngăn cách bằng dấu cách hoặc dấu phẩy. Hashtag trùng sẽ được loại bỏ.")
    }

    StudioField {
        id: hashtagInput
        Layout.fillWidth: true
        placeholderText: qsTr("Ví dụ: #review #video #fyp")
        accessibleName: qsTr("Hashtag")
        selectByMouse: true
        Keys.onReturnPressed: root.savePost()
    }

    SettingLabel {
        Layout.fillWidth: true
        text: qsTr("Hẹn giờ đăng")
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.space8

        StudioCheckBox {
            id: scheduleCheck
            text: qsTr("Hẹn giờ đăng cho video này")
        }

        StudioField {
            id: scheduleTimeInput
            Layout.fillWidth: true
            visible: scheduleCheck.checked
            placeholderText: qsTr("YYYY-MM-DD HH:mm (Ví dụ: 2026-10-19 15:30)")
            accessibleName: qsTr("Thời gian hẹn giờ")
            selectByMouse: true
        }
    }

    Flow {
        Layout.fillWidth: true
        visible: scheduleCheck.checked
        spacing: Theme.space6

        StudioButton {
            text: qsTr("+1 giờ")
            variant: "ghost"
            onClicked: scheduleTimeInput.text = AppController.getLocalTimePlusHours(1)
        }
        StudioButton {
            text: qsTr("+2 giờ")
            variant: "ghost"
            onClicked: scheduleTimeInput.text = AppController.getLocalTimePlusHours(2)
        }
        StudioButton {
            text: qsTr("Ngày mai 09:00")
            variant: "ghost"
            onClicked: scheduleTimeInput.text = AppController.getPresetTime(1, 9, 0)
        }
        StudioButton {
            text: qsTr("Ngày mai 19:00")
            variant: "ghost"
            onClicked: scheduleTimeInput.text = AppController.getPresetTime(1, 19, 0)
        }
    }

    Text {
        Layout.fillWidth: true
        visible: scheduleCheck.checked
        text: qsTr("💡 Khi ứng dụng đang mở, video sẽ tự động đăng khi đến giờ hẹn.")
        color: Theme.accent
        font.family: Theme.fontFamily
        font.pixelSize: TypeScale.metadata
        wrapMode: Text.WordWrap
    }

    InlineBanner {
        Layout.fillWidth: true
        visible: root.postLength > 2200
        tone: "danger"
        message: qsTr("Nội dung vượt quá 2.200 ký tự.")
    }

    footerActions: [
        StudioButton {
            text: qsTr("Hủy")
            variant: "ghost"
            onClicked: root.close()
        },
        StudioButton {
            text: scheduleCheck.checked ? qsTr("Lưu hẹn giờ") : qsTr("Lưu")
            variant: scheduleCheck.checked ? "secondary" : "primary"
            enabled: root.postLength <= 2200
            onClicked: root.savePost()
        },
        StudioButton {
            text: qsTr("Đăng lịch hẹn lên Zernio ngay")
            variant: "primary"
            visible: scheduleCheck.checked
            enabled: root.postLength <= 2200 && scheduleTimeInput.text.trim().length > 0
            onClicked: root.saveAndScheduleNow()
        }
    ]
}
