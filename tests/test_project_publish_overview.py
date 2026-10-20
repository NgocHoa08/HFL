import json
import os
import tempfile
import unittest
from types import SimpleNamespace
from unittest import mock

from truongngochoa.desktop import project_publish_overview as overview


def _video(video_id, project_key="p1"):
    return SimpleNamespace(video_id=video_id, project_type="batch", project_key=project_key)


class ProjectPublishOverviewTests(unittest.TestCase):
    def test_item_statuses_are_classified(self):
        self.assertEqual(overview.classify_item_status("published"), overview.PUBLISHED)
        self.assertEqual(overview.classify_item_status("posted"), overview.PUBLISHED)
        for status in ("ready", "uploading", "publishing", "scheduled", "draft"):
            self.assertEqual(overview.classify_item_status(status), overview.PENDING)
        for status in ("failed", "missing", "partial"):
            self.assertEqual(overview.classify_item_status(status), overview.FAILED)
        self.assertEqual(overview.classify_item_status(""), overview.UNPUBLISHED)

    def test_counts_group_batch_videos_by_project_and_state(self):
        outputs = {"a": "/r/a.mp4", "b": "/r/b.mp4", "c": "/r/c.mp4", "d": ""}
        states = {
            overview._normalize("/r/a.mp4"): overview.PUBLISHED,
            overview._normalize("/r/b.mp4"): overview.PENDING,
        }
        videos = [_video("a"), _video("b"), _video("c"), _video("d"), _video("e", "p2")]
        videos.append(SimpleNamespace(video_id="x", project_type="single", project_key="p1"))
        counts = overview.counts_by_project(
            videos,
            lambda video: video.project_key,
            lambda video: outputs.get(video.video_id, ""),
            states,
        )
        self.assertEqual(
            counts["p1"],
            {"total": 4, "published": 1, "pending": 1, "failed": 0, "unpublished": 2},
        )
        self.assertEqual(counts["p2"]["unpublished"], 1)

    def test_collect_reads_publish_project_queues_and_keeps_best_state(self):
        with tempfile.TemporaryDirectory() as root:
            def write_state(name, items):
                directory = os.path.join(root, name)
                os.makedirs(directory)
                with open(os.path.join(directory, ".truongngochoa-social-publish.json"), "w", encoding="utf-8") as handle:
                    json.dump({"schema_version": 5, "items": items}, handle)
                return directory

            first = write_state("one", [{"id": "1", "source_path": "/r/a.mp4", "status": "ready"}])
            second = write_state("two", [{"id": "2", "source_path": "/r/a.mp4", "status": "published"}])
            roots = {"k1": first, "k2": second}
            projects = [
                {"key": "k1", "project_type": "publish"},
                {"key": "k2", "project_type": "publish"},
                {"key": "k3", "project_type": "batch"},
            ]
            with mock.patch.object(overview.project_store, "list_projects", return_value=projects), \
                    mock.patch.object(overview.project_store, "project_root_for_key", side_effect=lambda key: roots[key]):
                states = overview.collect_publish_states()
        self.assertEqual(states[overview._normalize("/r/a.mp4")], overview.PUBLISHED)

    def test_project_publish_detail_qml_loads(self):
        from pathlib import Path
        from PySide6.QtCore import QUrl
        from PySide6.QtGui import QGuiApplication
        from PySide6.QtQml import QQmlComponent, QQmlEngine

        app = QGuiApplication.instance() or QGuiApplication([])
        engine = QQmlEngine()
        qml_dir = Path(__file__).resolve().parent.parent / "src" / "truongngochoa" / "desktop" / "qml"
        engine.addImportPath(str(qml_dir))
        component = QQmlComponent(engine, QUrl.fromLocalFile(str(qml_dir / "ProjectPublishDetail.qml")))
        self.assertTrue(component.isReady(), "\n".join(e.toString() for e in component.errors()))
        item = component.create()
        self.assertIsNotNone(item)
        item.setProperty("projectName", "Dự án mẫu")
        item.setProperty("rows", [
            {"videoId": "v1", "title": "Video 1", "filename": "v1.mp4", "publishState": "published", "status": "done"},
            {"videoId": "v2", "title": "Video 2", "filename": "v2.mp4", "publishState": "pending", "status": "done"},
            {"videoId": "v3", "title": "Video 3", "filename": "v3.mp4", "publishState": "unpublished", "status": "pending"},
        ])
        def row_count(obj):
            val = obj.property("visibleRows")
            if hasattr(val, "toVariant"):
                return len(val.toVariant())
            return len(val)

        self.assertEqual(row_count(item), 3)
        item.setProperty("filter", "published")
        self.assertEqual(row_count(item), 1)
        item.deleteLater()
        engine.deleteLater()


if __name__ == "__main__":
    unittest.main()

