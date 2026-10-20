pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import "."

AppDialog {
    id: root

    property int itemRow: -1
    property bool publishAllItems: false
    property string mode: "now"
    readonly property var intervalValues: [15, 30, 60, 120, 240, 1440]

    title: qsTr("Xác nhận đăng")
    subtitle: publishAllItems
        ? (root.mode === "schedule" ? qsTr("Hẹn giờ đăng toàn bộ video đang chờ") : qsTr("Đăng toàn bộ video đang chờ"))
        : (root.mode === "schedule" ? qsTr("Hẹn giờ đăng video đã chọn") : qsTr("Đăng video đã chọn"))
    preferredWidth: 480
    maximumWidth: 540

    function formatLocalDt(d) {
        const pad = n => n < 10 ? "0" + n : n;
        return d.getFullYear() + "-" + pad(d.getMonth() + 1) + "-" + pad(d.getDate()) + " " + pad(d.getHours()) + ":" + pad(d.getMinutes());
    }

    function openForPublish(row, publishAll, initialScheduledFor) {
        itemRow = row
        publishAllItems = publishAll
        const hasSched = initialScheduledFor && initialScheduledFor.length > 0
        mode = hasSched ? "schedule" : "now"
        scheduleTimeInput.text = hasSched
            ? (AppController.formatLocalTime(initialScheduledFor) || initialScheduledFor)
            : AppController.getLocalTimePlusHours(1)
        intervalCombo.currentIndex = 1
        open()
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.space12

        PlatformLogo {
            Layout.preferredWidth: 28
            Layout.preferredHeight: 28
            platform: AppController.zernioSelectedPlatform
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1

            Text {
                Layout.fillWidth: true
                text: AppController.zernioSelectedAccountName
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: TypeScale.control
                font.weight: Font.DemiBold
                textFormat: Text.PlainText
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: qsTr("Video sẽ được gửi qua Zernio tới nền tảng này.")
                color: Theme.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: TypeScale.metadata
                textFormat: Text.PlainText
                wrapMode: Text.WordWrap
            }
        }
    }

    SegmentedControl {
        Layout.fillWidth: true
        options: [
            { label: qsTr("Đăng ngay"), value: "now" },
            { label: qsTr("Hẹn giờ đăng"), value: "schedule" }
        ]
        currentValue: root.mode
        onActivated: function(val) { root.mode = val; }
    }

    ColumnLayout {
        Layout.fillWidth: true
        visible: root.mode === "schedule"
        spacing: Theme.space8

        SettingLabel {
            Layout.fillWidth: true
            text: qsTr("Thời gian bắt đầu đăng")
        }

        StudioField {
            id: scheduleTimeInput
            Layout.fillWidth: true
            placeholderText: qsTr("YYYY-MM-DD HH:mm (Ví dụ: 2026-10-19 15:30)")
            accessibleName: qsTr("Thời gian bắt đầu đăng")
            selectByMouse: true
        }

        Flow {
            Layout.fillWidth: true
            spacing: Theme.space6

            StudioButton {
                text: qsTr("+30 phút")
                variant: "ghost"
                onClicked: {
                    const now = new Date()
                    now.setMinutes(now.getMinutes() + 30)
                    scheduleTimeInput.text = root.formatLocalDt(now)
                }
            }
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

        ColumnLayout {
            Layout.fillWidth: true
            visible: root.publishAllItems
            spacing: Theme.space4

            SettingLabel {
                Layout.fillWidth: true
                text: qsTr("Khoảng cách giữa các bài")
            }

            StudioComboBox {
                id: intervalCombo
                Layout.fillWidth: true
                model: [
                    qsTr("15 phút"),
                    qsTr("30 phút (khuyên dùng)"),
                    qsTr("1 giờ"),
                    qsTr("2 giờ"),
                    qsTr("4 giờ"),
                    qsTr("1 ngày")
                ]
            }

            Text {
                Layout.fillWidth: true
                text: qsTr("Mỗi video sẽ tự động dãn cách theo khoảng thời gian này.")
                color: Theme.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: TypeScale.metadata
                textFormat: Text.PlainText
            }
        }
    }

    footerActions: [
        StudioButton {
            text: qsTr("Hủy")
            variant: "ghost"
            onClicked: root.close()
        },
        StudioButton {
            text: root.mode === "schedule" ? qsTr("Hẹn giờ đăng") : qsTr("Đăng ngay")
            variant: "primary"
            onClicked: {
                AppController.setZernioPublishConsent(true)
                if (root.mode === "schedule") {
                    const chosenInterval = root.intervalValues[intervalCombo.currentIndex] || 30
                    if (root.publishAllItems)
                        AppController.scheduleAndPublishAll(scheduleTimeInput.text, chosenInterval)
                    else
                        AppController.publishTikTokItemScheduled(root.itemRow, scheduleTimeInput.text)
                } else {
                    if (root.publishAllItems)
                        AppController.publishAllTikTokItems()
                    else
                        AppController.publishTikTokItem(root.itemRow)
                }
                root.close()
            }
        }
    ]
}
