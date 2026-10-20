pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import "."

// Videos of one big (batch) project with their social-publishing state.
Item {
    id: root

    property string projectKey: ""
    property string projectName: ""
    property var rows: []
    property string filter: "all"

    signal closeRequested
    signal openProjectRequested

    readonly property var visibleRows: {
        if (!rows) return [];
        if (filter === "all") return rows;
        return rows.filter(function (row) {
            return row && row.publishState === filter;
        });
    }

    function countOf(state) {
        if (!rows) return 0;
        let total = 0;
        for (let i = 0; i < rows.length; ++i) {
            if (rows[i] && rows[i].publishState === state)
                ++total;
        }
        return total;
    }

    function stateLabel(state) {
        if (state === "published")
            return qsTr("Đã đăng");
        if (state === "pending")
            return qsTr("Chờ đăng");
        if (state === "failed")
            return qsTr("Lỗi đăng");
        return qsTr("Chưa đăng");
    }

    function pillStatus(state) {
        if (state === "published")
            return "done";
        if (state === "pending")
            return "processing";
        if (state === "failed")
            return "failed";
        return "pending";
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: UiMetrics.pageMargin
        spacing: Theme.space16

        PageHeader {
            Layout.fillWidth: true
            title: root.projectName
            subtitle: qsTr("%1 video · %2 đã đăng · %3 chờ đăng · %4 chưa đăng")
                .arg(root.rows.length)
                .arg(root.countOf("published"))
                .arg(root.countOf("pending"))
                .arg(root.countOf("unpublished") + root.countOf("failed"))

            StudioButton {
                objectName: "homeProjectBackButton"
                text: qsTr("Quay lại")
                variant: "ghost"
                onClicked: root.closeRequested()
            }
            StudioButton {
                objectName: "homeProjectOpenButton"
                text: qsTr("Mở dự án")
                variant: "primary"
                onClicked: root.openProjectRequested()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.space8

            Repeater {
                model: [
                    {key: "all", label: qsTr("Tất cả")},
                    {key: "published", label: qsTr("Đã đăng")},
                    {key: "pending", label: qsTr("Chờ đăng")},
                    {key: "unpublished", label: qsTr("Chưa đăng")},
                    {key: "failed", label: qsTr("Lỗi đăng")}
                ]

                delegate: StudioButton {
                    id: chip

                    required property var modelData

                    objectName: "publishFilter_" + modelData.key
                    text: modelData.label + " (" + (modelData.key === "all" ? root.rows.length : root.countOf(modelData.key)) + ")"
                    variant: root.filter === modelData.key ? "primary" : "ghost"
                    onClicked: root.filter = modelData.key
                }
            }

            Item {
                Layout.fillWidth: true
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Theme.radiusSmall
            color: Theme.input
            border.width: 1
            border.color: Theme.outline
            clip: true

            ListView {
                id: videoList

                objectName: "homeProjectVideoList"
                anchors.fill: parent
                anchors.margins: 4
                spacing: 4
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                model: root.visibleRows

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }

                delegate: Rectangle {
                    id: row

                    required property int index
                    required property var modelData
                    readonly property var itemData: modelData || ({})

                    width: videoList.width - 8
                    height: 60
                    radius: Theme.radiusTiny
                    color: rowHover.hovered ? Theme.surfaceMuted : "transparent"

                    HoverHandler {
                        id: rowHover
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.space8
                        anchors.rightMargin: Theme.space8
                        spacing: Theme.space12

                        Rectangle {
                            Layout.preferredWidth: 64
                            Layout.preferredHeight: 40
                            radius: Theme.radiusTiny
                            color: Theme.video
                            clip: true

                            MediaThumbnail {
                                anchors.fill: parent
                                source: (row.itemData && row.itemData.thumbnailSource) || ""
                                fallbackIcon: "video"
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                Layout.fillWidth: true
                                text: (row.itemData && (row.itemData.filename || row.itemData.title)) || ""
                                color: Theme.text
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.body
                                font.weight: Font.DemiBold
                                textFormat: Text.PlainText
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                text: (row.itemData && row.itemData.videoSize) || ""
                                visible: text.length > 0
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.caption
                                textFormat: Text.PlainText
                                elide: Text.ElideRight
                            }
                        }

                        StatusPill {
                            objectName: "publishStatePill"
                            status: root.pillStatus(row.itemData && row.itemData.publishState)
                            label: root.stateLabel(row.itemData && row.itemData.publishState)
                        }
                    }
                }

                EmptyState {
                    anchors.centerIn: parent
                    visible: root.visibleRows.length === 0
                    title: root.rows.length === 0 ? qsTr("Dự án chưa có video") : qsTr("Không có video ở trạng thái này")
                    message: ""
                }
            }
        }
    }
}
