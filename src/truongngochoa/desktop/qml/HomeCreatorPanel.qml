import QtQuick
import QtQuick.Layouts
import "."

AppSurface {
    id: root

    padding: Theme.space16
    spacing: Theme.space8

    Text {
        Layout.fillWidth: true
        text: qsTr("Phát triển bởi")
        color: Theme.textSubtle
        font.family: Theme.fontFamily
        font.pixelSize: TypeScale.metadata
        font.weight: Font.DemiBold
        textFormat: Text.PlainText
    }

    Text {
        Layout.fillWidth: true
        text: "Trương Ngọc Hoà"
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: TypeScale.section
        font.weight: Font.DemiBold
        textFormat: Text.PlainText
        elide: Text.ElideRight
    }

    Text {
        Layout.fillWidth: true
        text: qsTr("Ứng dụng Trương Ngọc Hoà - Tải, dịch phụ đề và lồng tiếng video trên máy tính Windows.")
        color: Theme.textMuted
        font.family: Theme.fontFamily
        font.pixelSize: TypeScale.label
        textFormat: Text.PlainText
        wrapMode: Text.WordWrap
        lineHeight: 1.3
        maximumLineCount: 2
        elide: Text.ElideRight
    }
}
