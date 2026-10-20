pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import "."

AppDialog {
    id: root

    property var controller: AppController
    property string sourceProjectKey: ""
    property var targetProjects: []
    property var candidateVideos: []
    property var selectedVideoIds: []
    property bool isCreatingNew: false

    title: qsTr("Chuyển video vào dự án")
    subtitle: qsTr("Gom các video vào dự án đã tạo để trang chủ gọn gàng hơn")
    preferredWidth: 600
    preferredHeight: 580

    readonly property int selectedCount: selectedVideoIds.length
    readonly property bool canSubmit: {
        if (selectedCount === 0)
            return false;
        if (isCreatingNew)
            return newProjectNameField.text.trim().length > 0;
        return targetCombo.currentIndex >= 0 && targetCombo.currentIndex < targetProjects.length;
    }

    function isVideoSelected(id) {
        return selectedVideoIds.indexOf(id) !== -1;
    }

    function toggleVideo(id) {
        let list = selectedVideoIds.slice();
        let idx = list.indexOf(id);
        if (idx !== -1) {
            list.splice(idx, 1);
        } else {
            list.push(id);
        }
        selectedVideoIds = list;
    }

    function selectAll(checked) {
        if (checked) {
            let list = [];
            for (let i = 0; i < candidateVideos.length; i++) {
                list.push(candidateVideos[i].videoId);
            }
            selectedVideoIds = list;
        } else {
            selectedVideoIds = [];
        }
    }

    function openForProject(key) {
        sourceProjectKey = key || "";
        let targets = controller.getMoveTargetProjects(sourceProjectKey);
        targetProjects = targets;

        let options = [];
        for (let i = 0; i < targets.length; i++) {
            options.push(targets[i].displayText);
        }
        options.push(qsTr("+ Tạo dự án mới..."));
        targetCombo.model = options;

        if (targets.length > 0) {
            targetCombo.currentIndex = 0;
            isCreatingNew = false;
        } else {
            targetCombo.currentIndex = 0;
            isCreatingNew = true;
        }

        newProjectNameField.text = "";

        let candidates = controller.getMoveCandidateVideos(sourceProjectKey);
        candidateVideos = candidates;

        let selected = [];
        for (let j = 0; j < candidates.length; j++) {
            if (candidates[j].selected)
                selected.push(candidates[j].videoId);
        }
        if (selected.length === 0 && candidates.length > 0)
            selected.push(candidates[0].videoId);

        selectedVideoIds = selected;
        open();
    }

    function submit() {
        if (!canSubmit)
            return;
        let targetKey = "";
        let newName = "";
        if (isCreatingNew) {
            newName = newProjectNameField.text.trim();
        } else if (targetCombo.currentIndex >= 0 && targetCombo.currentIndex < targetProjects.length) {
            targetKey = targetProjects[targetCombo.currentIndex].key;
        }
        if (controller.moveVideosToProject(targetKey, selectedVideoIds, newName)) {
            close();
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: Theme.space12

        // Destination Project Section
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.space4

            Text {
                text: qsTr("Dự án đích:")
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: TypeScale.control
                font.weight: Font.DemiBold
            }

            AppComboBox {
                id: targetCombo
                objectName: "moveTargetCombo"
                Layout.fillWidth: true
                Accessible.name: qsTr("Chọn dự án đích")
                onActivated: {
                    root.isCreatingNew = (currentIndex === root.targetProjects.length);
                    if (root.isCreatingNew)
                        newProjectNameField.forceActiveFocus();
                }
            }

            StudioField {
                id: newProjectNameField
                objectName: "newProjectNameField"
                Layout.fillWidth: true
                visible: root.isCreatingNew
                placeholderText: qsTr("Nhập tên dự án mới...")
                accessibleName: qsTr("Tên dự án mới")
                maximumLength: 120
                Keys.onReturnPressed: root.submit()
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.outline
        }

        // Candidate Videos Section
        RowLayout {
            Layout.fillWidth: true

            Text {
                Layout.fillWidth: true
                text: qsTr("Chọn các video cần gom nhóm:")
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: TypeScale.control
                font.weight: Font.DemiBold
            }

            AppCheckBox {
                id: selectAllBox
                objectName: "selectAllVideosBox"
                text: qsTr("Chọn tất cả (%1)").arg(root.candidateVideos.length)
                checked: root.candidateVideos.length > 0 && root.selectedCount === root.candidateVideos.length
                onToggled: root.selectAll(checked)
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
                id: videoListView
                objectName: "candidateVideoList"
                anchors.fill: parent
                anchors.margins: 4
                spacing: 4
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                model: root.candidateVideos

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }

                delegate: Rectangle {
                    id: rowItem
                    required property int index
                    required property var modelData
                    readonly property var itemData: modelData || ({})
                    readonly property string videoId: (itemData && itemData.videoId) ? String(itemData.videoId) : ""
                    readonly property bool isChecked: root.isVideoSelected(videoId)
                    readonly property bool isHovered: rowHover.hovered

                    width: videoListView.width - 8
                    height: 52
                    radius: Theme.radiusTiny
                    color: isChecked ? Theme.surfaceStrong : isHovered ? Theme.surfaceMuted : "transparent"
                    border.width: 1
                    border.color: isChecked ? Theme.interactive : isHovered ? Theme.outlineStrong : "transparent"

                    HoverHandler {
                        id: rowHover
                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        onTapped: if (rowItem.videoId.length > 0) root.toggleVideo(rowItem.videoId)
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.space8
                        anchors.rightMargin: Theme.space8
                        spacing: Theme.space8

                        AppCheckBox {
                            checked: rowItem.isChecked
                            onToggled: if (rowItem.videoId.length > 0) root.toggleVideo(rowItem.videoId)
                        }

                        Rectangle {
                            Layout.preferredWidth: 54
                            Layout.preferredHeight: 36
                            radius: Theme.radiusTiny
                            color: Theme.video
                            clip: true

                            MediaThumbnail {
                                anchors.fill: parent
                                source: (rowItem.itemData && rowItem.itemData.thumbnailSource) ? String(rowItem.itemData.thumbnailSource) : ""
                                fallbackIcon: "video"
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                Layout.fillWidth: true
                                text: (rowItem.itemData && rowItem.itemData.title) ? String(rowItem.itemData.title) : ""
                                color: Theme.text
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.body
                                font.weight: Font.DemiBold
                                textFormat: Text.PlainText
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                text: {
                                    if (!rowItem.itemData) return "";
                                    let parts = [];
                                    if (rowItem.itemData.projectName && rowItem.itemData.projectName !== rowItem.itemData.title)
                                        parts.push(rowItem.itemData.projectName);
                                    if (rowItem.itemData.videoSize)
                                        parts.push(rowItem.itemData.videoSize);
                                    if (rowItem.itemData.filename)
                                        parts.push(rowItem.itemData.filename);
                                    return parts.join(" • ");
                                }
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.caption
                                textFormat: Text.PlainText
                                elide: Text.ElideRight
                            }
                        }

                        StatusPill {
                            readonly property string pillStatus: (rowItem.itemData && rowItem.itemData.status) ? String(rowItem.itemData.status) : ""
                            status: pillStatus
                            label: I18n.taskStateLabel(pillStatus)
                        }
                    }
                }

                EmptyState {
                    anchors.centerIn: parent
                    visible: root.candidateVideos.length === 0
                    title: qsTr("Không có video khả dụng")
                    message: qsTr("Tất cả video đã ở trong các dự án hoặc đang xử lý.")
                }
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
            objectName: "confirmMoveVideosButton"
            text: root.selectedCount > 0 ? qsTr("Chuyển %1 video").arg(root.selectedCount) : qsTr("Chuyển vào dự án")
            variant: "primary"
            enabled: root.canSubmit
            onClicked: root.submit()
        }
    ]
}
