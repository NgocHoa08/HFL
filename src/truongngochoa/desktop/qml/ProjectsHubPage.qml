pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import "."

Item {
    id: root

    property var projectModel: null
    property string pageTitle: qsTr("Dự án")
    // Home shows only the large (batch) projects; opening one lists its videos
    // together with their social-publishing state.
    property bool homeMode: false
    property var publishCounts: ({})
    property string detailKey: ""
    property string detailName: ""
    property int detailIndex: -1
    property var detailRows: []
    signal requestNewProject(string projectType)
    signal openProject(int index, string projectType)

    function refreshPublishCounts() {
        if (!homeMode || typeof AppController === "undefined")
            return;
        publishCounts = AppController.batchPublishCounts();
        if (detailKey.length > 0)
            detailRows = AppController.projectVideosPublishState(detailKey);
    }

    function showDetail(index, key, name) {
        detailIndex = index;
        detailKey = key;
        detailName = name;
        detailRows = typeof AppController === "undefined" ? [] : AppController.projectVideosPublishState(key);
    }

    function closeDetail() {
        detailKey = "";
        detailRows = [];
        detailIndex = -1;
    }

    function resetFilters() {
        searchField.clear()
        typeFilter.currentIndex = homeMode ? 3 : 0
        sortMode.currentIndex = 0
        if (root.projectModel) {
            root.projectModel.query = ""
            root.projectModel.typeFilter = homeMode ? "batch" : "all"
            root.projectModel.statusFilter = "all"
            root.projectModel.sortMode = "activity"
        }
    }

    function syncFilters() {
        if (!root.projectModel || !searchField || !typeFilter || !sortMode)
            return;
        if (root.homeMode && root.visible)
            root.projectModel.typeFilter = "batch";
        searchField.text = root.projectModel.query || "";
        typeFilter.currentIndex = Math.max(0, ["all", "single", "manual", "batch", "download", "publish"].indexOf(root.projectModel.typeFilter));
        sortMode.currentIndex = root.projectModel.sortMode === "name" ? 1 : 0;
        root.projectModel.statusFilter = "all";
    }

    Component.onCompleted: {
        syncFilters();
        if (visible)
            refreshPublishCounts();
    }
    onVisibleChanged: {
        if (visible) {
            syncFilters();
            refreshPublishCounts();
        } else {
            searchField.deselect();
            searchField.focus = false;
            closeDetail();
            // The browser model is shared with the full project list, so give
            // it back unfiltered when Home is left.
            if (homeMode && root.projectModel)
                root.projectModel.typeFilter = "all";
        }
    }

    MouseArea {
        anchors.fill: parent
        z: 1
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onPressed: function (mouse) {
            const local = searchField.mapFromItem(root, mouse.x, mouse.y);
            if (searchField.activeFocus && !searchField.contains(local)) {
                searchField.deselect();
                searchField.focus = false;
                root.forceActiveFocus(Qt.MouseFocusReason);
            }
            mouse.accepted = false;
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: UiMetrics.pageMargin
        spacing: Theme.space16

        PageHeader {
            Layout.fillWidth: true
            title: root.pageTitle
            subtitle: qsTr("Bấm vào dự án để xem và làm các video bên trong")

            StudioButton {
                id: newProjectButton
                objectName: "newProjectButton"
                variant: "primary"
                text: qsTr("Dự án mới")
                iconName: "add"
                onClicked: newProjectMenu.visible ? newProjectMenu.close() : newProjectMenu.open()

                Menu {
                    id: newProjectMenu
                    objectName: "newProjectMenu"
                    y: newProjectButton.height + Theme.space4
                    width: 240
                    padding: Theme.space4
                    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
                    background: Rectangle {
                        radius: Theme.radiusSmall
                        color: Theme.surfaceElevated
                        border.width: 1
                        border.color: Theme.outlineStrong
                    }
                    AppMenuItem { text: qsTr("Dự án mới (Nhiều video)"); onTriggered: root.requestNewProject("batch") }
                    AppMenuItem { text: qsTr("Dự án thủ công"); onTriggered: root.requestNewProject("manual") }
                    AppMenuItem { text: qsTr("Dự án 1 video nhanh"); onTriggered: root.requestNewProject("single") }
                    MenuSeparator {}
                    AppMenuItem { text: qsTr("Dự án tải xuống"); onTriggered: root.requestNewProject("download") }
                    AppMenuItem { text: qsTr("Dự án đăng mạng xã hội"); onTriggered: root.requestNewProject("publish") }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.space8

            SearchField {
                id: searchField
                objectName: "projectSearchField"
                Layout.fillWidth: true
                Layout.maximumWidth: 440
                placeholderText: qsTr("Tìm dự án")
                Accessible.name: qsTr("Tìm dự án")
                onTextEdited: if (root.projectModel) root.projectModel.query = text
            }

            AppComboBox {
                id: typeFilter
                visible: !root.homeMode
                Layout.preferredWidth: 190
                model: [qsTr("Mọi loại"), qsTr("Tự động"), qsTr("Thủ công"), qsTr("Hàng loạt"), qsTr("Tải xuống"), qsTr("Đăng mạng xã hội")]
                onActivated: if (root.projectModel)
                    root.projectModel.typeFilter = ["all", "single", "manual", "batch", "download", "publish"][currentIndex]
                Accessible.name: qsTr("Loại dự án")
            }

            AppComboBox {
                id: sortMode
                Layout.preferredWidth: 166
                model: [qsTr("Hoạt động gần đây"), qsTr("Tên")]
                onActivated: if (root.projectModel)
                    root.projectModel.sortMode = currentIndex === 0 ? "activity" : "name"
                Accessible.name: qsTr("Sắp xếp dự án")
            }
        }

        GridView {
            id: projectGrid
            readonly property int columnCount: Math.max(1, Math.floor((width + Theme.space20) / (224 + Theme.space20)))
            readonly property real cellContentWidth: Math.floor(width / columnCount)
            readonly property real cardWidth: Math.max(1, cellContentWidth - Theme.space20)
            readonly property real cardHeight: Math.round(cardWidth * 0.56 + 64 + (root.homeMode ? 22 : 0))

            Layout.fillWidth: true
            Layout.fillHeight: true
            model: root.projectModel
            cellWidth: cellContentWidth
            cellHeight: cardHeight + Theme.space20
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            reuseItems: true
            keyNavigationEnabled: true

            delegate: ProjectCard {
                width: projectGrid.cardWidth
                height: projectGrid.cardHeight
                publishCounts: root.homeMode ? (root.publishCounts[projectKey] || null) : null
                onActivated: {
                    if (root.homeMode)
                        root.showDetail(index, projectKey, projectName);
                    else
                        root.openProject(index, projectType);
                }
                onOpenRequested: root.openProject(index, projectType)
                onProjectFolderRequested: {
                    if (AppController.selectProjectFromBrowser(index))
                        AppController.openProjectFolder()
                }
                onDeleteRequested: AppController.deleteProjectFromBrowser(index)
                onRenameRequested: key => AppController.requestProjectRename(key)
                onMoveToProjectRequested: key => AppController.requestMoveToProject(key)
            }

            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            EmptyState {
                anchors.centerIn: parent
                visible: projectGrid.count === 0
                title: searchField.text.length > 0 ? qsTr("Không tìm thấy dự án") : qsTr("Chưa có dự án nào")
                message: searchField.text.length > 0
                    ? qsTr("Thử từ khóa hoặc bộ lọc khác.")
                    : qsTr("Tạo dự án mới để gom nhóm và làm các video bên trong.")
                StudioButton {
                    visible: searchField.text.length > 0
                    text: qsTr("Xóa bộ lọc")
                    onClicked: root.resetFilters()
                }
                StudioButton {
                    visible: searchField.text.length === 0
                    variant: "primary"
                    iconName: "add"
                    text: qsTr("Tạo dự án mới")
                    onClicked: root.requestNewProject("batch")
                }
            }
        }
    }

    ProjectPublishDetail {
        id: publishDetail

        objectName: "homeProjectDetail"
        anchors.fill: parent
        z: 2
        visible: root.homeMode && root.detailKey.length > 0
        projectKey: root.detailKey
        projectName: root.detailName
        rows: root.detailRows
        onCloseRequested: root.closeDetail()
        onOpenProjectRequested: {
            const index = root.detailIndex;
            root.closeDetail();
            root.openProject(index, "batch");
        }

        Rectangle {
            anchors.fill: parent
            z: -1
            color: Theme.window
        }
    }
}
