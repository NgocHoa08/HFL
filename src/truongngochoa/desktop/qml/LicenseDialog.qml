pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import "."

AppDialog {
    id: root
    objectName: "licenseDialog"
    title: qsTr("Quản lý bản quyền & Thiết bị")
    subtitle: qsTr("Khóa thiết bị phần cứng & Kiểm soát số lượt sử dụng")
    preferredWidth: 640
    maximumWidth: 680
    maximumHeight: 560
    bodySpacing: Theme.space12

    property var license: AppController.license

    ScrollView {
        id: scroll
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.minimumHeight: 0
        contentWidth: availableWidth
        contentHeight: contentCol.implicitHeight
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        ColumnLayout {
            id: contentCol
            width: scroll.availableWidth
            spacing: Theme.space16

            // 1. HARDWARE ID CARD (MÃ THIẾT BỊ)
            Rectangle {
                Layout.fillWidth: true
                radius: Theme.radiusMedium
                color: Theme.surfaceElevated
                border.width: 1
                border.color: Theme.outline
                implicitHeight: hwidLayout.implicitHeight + Theme.space24

                ColumnLayout {
                    id: hwidLayout
                    anchors.fill: parent
                    anchors.margins: Theme.space12
                    spacing: Theme.space8

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.space8

                        Text {
                            text: qsTr("Mã thiết bị (HWID):")
                            font.family: Theme.fontFamily
                            font.pixelSize: TypeScale.control
                            font.weight: Font.DemiBold
                            color: Theme.text
                        }

                        Item { Layout.fillWidth: true }

                        StudioButton {
                            text: qsTr("Sao chép mã máy")
                            variant: "secondary"
                            onClicked: {
                                if (root.license) {
                                    root.license.copyHwidToClipboard();
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 36
                        radius: Theme.radiusSmall
                        color: Theme.input
                        border.width: 1
                        border.color: Theme.outline

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Theme.space12
                            anchors.rightMargin: Theme.space12

                            Text {
                                text: root.license ? root.license.licenseHwid : "Đang kiểm tra..."
                                font.family: "Consolas"
                                font.pixelSize: 14
                                font.weight: Font.Bold
                                color: Theme.interactive
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: qsTr("Mã máy duy nhất cho máy tính này. Khách hàng gửi mã này cho chủ phần mềm để cấp bản quyền.")
                        font.family: Theme.fontFamily
                        font.pixelSize: TypeScale.meta
                        color: Theme.textSubtle
                        wrapMode: Text.WordWrap
                    }
                }
            }

            // 2. LICENSE STATUS CARD (TRẠNG THÁI HIỆN TẠI)
            Rectangle {
                Layout.fillWidth: true
                radius: Theme.radiusMedium
                color: Theme.surfaceElevated
                border.width: 1
                border.color: root.license && root.license.licenseActive ? Theme.interactiveOutline : Theme.outline
                implicitHeight: statusLayout.implicitHeight + Theme.space24

                ColumnLayout {
                    id: statusLayout
                    anchors.fill: parent
                    anchors.margins: Theme.space12
                    spacing: Theme.space12

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.space12

                        Text {
                            text: qsTr("Trạng thái hiện tại:")
                            font.family: Theme.fontFamily
                            font.pixelSize: TypeScale.control
                            font.weight: Font.DemiBold
                            color: Theme.text
                        }

                        // Badge
                        Rectangle {
                            implicitHeight: 24
                            implicitWidth: badgeText.implicitWidth + Theme.space16
                            radius: 12
                            color: root.license && root.license.licenseActive ? Theme.successMuted : Theme.dangerMuted
                            border.width: 1
                            border.color: root.license && root.license.licenseActive ? Theme.success : Theme.danger

                            Text {
                                id: badgeText
                                anchors.centerIn: parent
                                text: root.license && root.license.licenseActive ? qsTr("ĐÃ KÍCH HOẠT") : qsTr("CHƯA KÍCH HOẠT")
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                color: root.license && root.license.licenseActive ? Theme.success : Theme.danger
                            }
                        }

                        Item { Layout.fillWidth: true }

                        StudioButton {
                            text: qsTr("Làm mới")
                            variant: "ghost"
                            enabled: root.license && root.license.licenseKey !== ""
                            onClicked: {
                                if (root.license) {
                                    root.license.refresh();
                                }
                            }
                        }

                        StudioButton {
                            text: qsTr("Hủy kích hoạt")
                            variant: "ghost"
                            visible: root.license && root.license.licenseActive
                            onClicked: {
                                if (root.license) {
                                    root.license.deactivate();
                                }
                            }
                        }
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        rowSpacing: Theme.space6
                        columnSpacing: Theme.space16

                        Text {
                            text: qsTr("Gói bản quyền:")
                            font.family: Theme.fontFamily
                            font.pixelSize: TypeScale.label
                            color: Theme.textMuted
                        }
                        Text {
                            text: root.license ? root.license.licensePlanType : "Chưa có"
                            font.family: Theme.fontFamily
                            font.pixelSize: TypeScale.label
                            font.weight: Font.DemiBold
                            color: Theme.text
                        }

                        Text {
                            text: qsTr("Chủ sở hữu key:")
                            font.family: Theme.fontFamily
                            font.pixelSize: TypeScale.label
                            color: Theme.textMuted
                            visible: root.license && root.license.licenseCustomerName !== ""
                        }
                        Text {
                            text: root.license ? root.license.licenseCustomerName : ""
                            font.family: Theme.fontFamily
                            font.pixelSize: TypeScale.label
                            color: Theme.text
                            visible: root.license && root.license.licenseCustomerName !== ""
                        }

                        Text {
                            text: qsTr("Hạn sử dụng:")
                            font.family: Theme.fontFamily
                            font.pixelSize: TypeScale.label
                            color: Theme.textMuted
                        }
                        Text {
                            text: root.license ? root.license.licenseExpiresAt : "—"
                            font.family: Theme.fontFamily
                            font.pixelSize: TypeScale.label
                            color: Theme.text
                        }

                        Text {
                            text: qsTr("Số lượt xử lý còn lại:")
                            font.family: Theme.fontFamily
                            font.pixelSize: TypeScale.label
                            color: Theme.textMuted
                        }
                        Text {
                            text: {
                                if (!root.license) return "—";
                                const left = root.license.licenseCreditsRemaining;
                                if (left < 0) return qsTr("Không giới hạn");
                                return qsTr("%1 video / lượt").arg(left);
                            }
                            font.family: Theme.fontFamily
                            font.pixelSize: TypeScale.label
                            font.weight: Font.Bold
                            color: (root.license && root.license.licenseCreditsRemaining === 0) ? Theme.danger : Theme.interactive
                        }

                        Text {
                            text: qsTr("Ghi chú:")
                            font.family: Theme.fontFamily
                            font.pixelSize: TypeScale.label
                            color: Theme.textMuted
                        }
                        Text {
                            Layout.fillWidth: true
                            text: root.license ? root.license.licenseStatusMessage : ""
                            font.family: Theme.fontFamily
                            font.pixelSize: TypeScale.label
                            color: Theme.textSubtle
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }

            // 3. KEY ACTIVATION FORM (KÍCH HOẠT KEY)
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.space8

                Text {
                    text: qsTr("Nhập mã bản quyền:")
                    font.family: Theme.fontFamily
                    font.pixelSize: TypeScale.control
                    font.weight: Font.DemiBold
                    color: Theme.text
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.space8

                    AppTextField {
                        id: keyInputField
                        Layout.fillWidth: true
                        placeholderText: qsTr("Ví dụ: TNH-THANG-VIP01 hoặc TNH-LUOT-50VIDEO")
                        text: root.license ? root.license.licenseKey : ""
                        font.family: "Consolas"
                    }

                    StudioButton {
                        text: qsTr("Kích hoạt ngay")
                        variant: "primary"
                        enabled: keyInputField.text.trim().length > 0
                        onClicked: {
                            if (root.license) {
                                root.license.activate(keyInputField.text.trim());
                            }
                        }
                    }
                }
            }
        }
    }

    footerActions: StudioButton {
        text: qsTr("Đóng")
        variant: "secondary"
        onClicked: root.close()
    }
}
