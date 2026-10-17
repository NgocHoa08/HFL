pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import "."

Rectangle {
    id: root

    property bool compact: false
    property string currentSection: "home"
    signal sectionRequested(string section)
    signal licenseRequested

    implicitWidth: compact ? UiMetrics.navigationCompact : UiMetrics.navigationExpanded
    color: Theme.sidebar

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.space12
        spacing: Theme.space8

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            Layout.bottomMargin: Theme.space4
            visible: root.compact
            radius: 10
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: Theme.interactive }
                GradientStop { position: 1.0; color: Theme.accentPurple }
            }
            Text {
                anchors.centerIn: parent
                text: "▶"
                color: "#FFFFFF"
                font.pixelSize: 14
                font.bold: true
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            visible: !root.compact
            spacing: Theme.space8

            Rectangle {
                Layout.preferredWidth: 34
                Layout.preferredHeight: 34
                radius: 10
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: Theme.interactive }
                    GradientStop { position: 1.0; color: Theme.accentPurple }
                }
                Text {
                    anchors.centerIn: parent
                    text: "▶"
                    color: "#FFFFFF"
                    font.pixelSize: 13
                    font.bold: true
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1
                RowLayout {
                    spacing: 4
                    Text {
                        text: "HFL"
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: TypeScale.section
                        font.weight: Font.Bold
                        textFormat: Text.PlainText
                    }
                    Rectangle {
                        Layout.preferredWidth: 26
                        Layout.preferredHeight: 14
                        radius: 3
                        color: Theme.interactiveMuted
                        border.width: 1
                        border.color: Theme.interactiveOutline
                        Text {
                            anchors.centerIn: parent
                            text: "AI"
                            color: Theme.interactive
                            font.pixelSize: 9
                            font.weight: Font.Bold
                        }
                    }
                }
                Text {
                    text: "Trương Ngọc Hoà"
                    color: Theme.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: TypeScale.metadata
                    textFormat: Text.PlainText
                    elide: Text.ElideRight
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            Layout.bottomMargin: Theme.space8
            color: Theme.divider
        }

        Repeater {
            model: [
                { key: "home", label: qsTr("Trang chủ"), icon: "home" },
                { key: "single", label: qsTr("Tự động"), icon: "play" },
                { key: "manual", label: qsTr("Thủ công"), icon: "edit" },
                { key: "batch", label: qsTr("Hàng loạt"), icon: "projects" },
                { key: "downloads", label: qsTr("Tải xuống"), icon: "download" },
                { key: "social", label: qsTr("Đăng mạng xã hội"), icon: "share" }
            ]

            delegate: Control {
                id: navItem
                objectName: "workspaceNav_" + modelData.key
                required property var modelData
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                focusPolicy: Qt.TabFocus
                padding: 0
                background: Rectangle {
                    objectName: "workspaceNavigationBackground"
                    radius: Theme.radiusTiny
                    color: root.currentSection === navItem.modelData.key ? Theme.sidebarSelected
                        : navHover.hovered ? Theme.sidebarHover : "transparent"
                    border.width: navItem.visualFocus ? 2 : 0
                    border.color: Theme.controlFocus
                }
                Accessible.role: Accessible.Button
                Accessible.name: modelData.label

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.topMargin: 7
                    anchors.bottomMargin: 7
                    width: 2
                    radius: 1
                    visible: root.currentSection === navItem.modelData.key
                    color: Theme.interactive
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: root.compact ? 0 : Theme.space12
                    anchors.rightMargin: root.compact ? 0 : Theme.space12
                    spacing: Theme.space12

                    FluentIcon {
                        visible: root.compact
                        Layout.preferredWidth: root.compact ? parent.width : 18
                        Layout.preferredHeight: 18
                        name: navItem.modelData.icon
                        iconColor: root.currentSection === navItem.modelData.key ? Theme.text : Theme.textMuted
                        iconSize: 17
                    }
                    Text {
                        Layout.fillWidth: true
                        visible: !root.compact
                        text: navItem.modelData.label
                        color: root.currentSection === navItem.modelData.key ? Theme.text : Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: TypeScale.control
                        font.weight: root.currentSection === navItem.modelData.key ? Font.DemiBold : Font.Normal
                        textFormat: Text.PlainText
                        elide: Text.ElideRight
                    }
                }

                HoverHandler { id: navHover; cursorShape: Qt.PointingHandCursor }
                TapHandler {
                    onTapped: {
                        navItem.focus = false;
                        navItem.forceActiveFocus(Qt.MouseFocusReason);
                        root.sectionRequested(navItem.modelData.key);
                    }
                }
                Keys.onReturnPressed: root.sectionRequested(navItem.modelData.key)
                Keys.onSpacePressed: root.sectionRequested(navItem.modelData.key)
            }
        }

        Item { Layout.fillHeight: true }

        Rectangle {
            id: proCard
            visible: !root.compact
            Layout.fillWidth: true
            Layout.preferredHeight: 116
            radius: Theme.radius
            color: Theme.surfaceElevated
            border.width: 1
            border.color: Theme.outline

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.space12
                spacing: Theme.space8

                RowLayout {
                    spacing: Theme.space8
                    Rectangle {
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20
                        radius: 5
                        color: Theme.interactiveMuted
                        border.width: 1
                        border.color: Theme.interactiveOutline
                        Text {
                            anchors.centerIn: parent
                            text: "✦"
                            color: Theme.interactive
                            font.pixelSize: 11
                        }
                    }
                    Text {
                        text: "HFL Pro AI"
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: TypeScale.label
                        font.weight: Font.Bold
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: qsTr("Xuất 4K 60fps & giọng đọc không giới hạn.")
                    color: Theme.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: TypeScale.metadata
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 28
                    radius: Theme.radiusSmall
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: Theme.interactive }
                        GradientStop { position: 1.0; color: Theme.accentPurple }
                    }
                    Text {
                        anchors.centerIn: parent
                        text: qsTr("Nâng cấp ngay")
                        color: Theme.textOnAccent
                        font.family: Theme.fontFamily
                        font.pixelSize: TypeScale.metadata
                        font.weight: Font.DemiBold
                    }
                    HoverHandler { cursorShape: Qt.PointingHandCursor }
                    TapHandler {
                        onTapped: root.licenseRequested()
                    }
                }
            }
        }
    }

    Rectangle {
        anchors.right: parent.right
        height: parent.height
        width: 1
        color: Theme.divider
    }
}
