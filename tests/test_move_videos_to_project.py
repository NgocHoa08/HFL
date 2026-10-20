import os
import shutil
import tempfile
import unittest
from pathlib import Path
from unittest.mock import Mock, patch

from truongngochoa.desktop.presenters import build_project_summaries
from truongngochoa.desktop.project_commands_controller import ProjectCommandsController
from truongngochoa.desktop.qml_controller import TruongNgocHoaController
from truongngochoa.schemas.video import VideoConfig
from truongngochoa.services import project_store, video_store
from truongngochoa.services.desktop_videos import create_desktop_video


class MoveVideosToProjectTests(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.root = Path(self.temp_dir.name)
        self.original_project_index = project_store.PROJECT_INDEX_PATH
        self.original_workspaces = video_store.LEGACY_VIDEO_WORKSPACES_DIR
        project_store.PROJECT_INDEX_PATH = str(self.root / "runtime" / "projects.json")
        video_store.LEGACY_VIDEO_WORKSPACES_DIR = str(self.root / "workspaces")
        video_store._VIDEO_DIR_CACHE.clear()
        video_store._VIDEO_METADATA_CACHE.clear()

        self.projects_dir = str(self.root / "projects")
        os.makedirs(self.projects_dir, exist_ok=True)

        # Create dummy sample video file
        self.sample_video = self.root / "clip.mp4"
        self.sample_video.write_bytes(b"dummy mp4 content")

    def tearDown(self):
        project_store.PROJECT_INDEX_PATH = self.original_project_index
        video_store.LEGACY_VIDEO_WORKSPACES_DIR = self.original_workspaces
        video_store._VIDEO_DIR_CACHE.clear()
        video_store._VIDEO_METADATA_CACHE.clear()
        self.temp_dir.cleanup()

    def test_move_single_video_into_existing_batch_project(self):
        # 1. Create a batch project
        batch_proj = project_store.create_project("Campaign A", self.projects_dir, "batch")

        # 2. Create a single video project
        single_video = create_desktop_video(
            str(self.sample_video),
            VideoConfig(project_type="single"),
            project_name="Solo Clip",
            project_directory=self.projects_dir,
        )
        old_key = single_video.project_key
        old_workspace = video_store.get_video_dir(single_video.video_id)
        self.assertTrue(os.path.isdir(old_workspace))

        # Initially, 2 projects exist in summaries
        summaries = build_project_summaries(video_store.list_videos(), project_store.list_projects())
        self.assertEqual(len(summaries), 2)

        # 3. Move the video into the batch project
        host = SimpleNamespaceMock(
            _selected_project_key=old_key,
            _project_directory=self.projects_dir,
        )
        commands = ProjectCommandsController(host)

        success = commands.move_videos_to_batch_project(
            target_project_key=batch_proj["key"],
            video_ids=[single_video.video_id],
        )
        self.assertTrue(success)

        # 4. Verify video metadata updated
        updated_video = video_store.get_video(single_video.video_id)
        self.assertEqual(updated_video.project_key, batch_proj["key"])
        self.assertEqual(updated_video.project_name, "Campaign A")
        self.assertEqual(updated_video.project_type, "batch")
        self.assertEqual(updated_video.batch_import_order, 1)

        # Workspace directory moved to target project videos dir
        new_workspace = video_store.get_video_dir(single_video.video_id)
        self.assertTrue(os.path.isdir(new_workspace))
        target_videos_dir = project_store.project_videos_dir_for_key(batch_proj["key"])
        self.assertTrue(Path(new_workspace).is_relative_to(Path(target_videos_dir)))
        self.assertFalse(os.path.exists(old_workspace))

        # Files in metadata are relocated
        video_input = updated_video.files.get("video_input")
        self.assertTrue(Path(video_input).is_relative_to(Path(new_workspace)))

        # Old single project record is cleaned up
        self.assertIsNone(project_store.get_project(old_key))

        # Presentation summaries now group the video into the batch card
        summaries = build_project_summaries(video_store.list_videos(), project_store.list_projects())
        self.assertEqual(len(summaries), 1)
        self.assertEqual(summaries[0]["project_name"], "Campaign A")
        self.assertEqual(summaries[0]["video_count"], 1)
        self.assertEqual(summaries[0]["videos"][0].video_id, single_video.video_id)

    def test_move_multiple_videos_into_new_batch_project(self):
        # Create 2 single video projects
        first_video = create_desktop_video(
            str(self.sample_video),
            VideoConfig(project_type="single"),
            project_name="Video One",
            project_directory=self.projects_dir,
        )
        second_video = create_desktop_video(
            str(self.sample_video),
            VideoConfig(project_type="single"),
            project_name="Video Two",
            project_directory=self.projects_dir,
        )

        host = SimpleNamespaceMock(
            _selected_project_key=first_video.project_key,
            _project_directory=self.projects_dir,
        )
        commands = ProjectCommandsController(host)

        # Move both videos into a newly created batch project
        success = commands.move_videos_to_batch_project(
            target_project_key="",
            video_ids=[first_video.video_id, second_video.video_id],
            new_project_name="Merged Batch",
        )
        self.assertTrue(success)

        # Verify new batch project created
        all_projects = project_store.list_projects()
        batch_project = next((p for p in all_projects if p["project_name"] == "Merged Batch"), None)
        self.assertIsNotNone(batch_project)
        self.assertEqual(batch_project["project_type"], "batch")

        # Verify both videos belong to the new batch project in sequential order
        v1 = video_store.get_video(first_video.video_id)
        v2 = video_store.get_video(second_video.video_id)
        self.assertEqual(v1.project_key, batch_project["key"])
        self.assertEqual(v2.project_key, batch_project["key"])
        self.assertEqual(v1.batch_import_order, 1)
        self.assertEqual(v2.batch_import_order, 2)

        # Summaries reflect 1 batch project with 2 videos
        summaries = build_project_summaries(video_store.list_videos(), project_store.list_projects())
        self.assertEqual(len(summaries), 1)
        self.assertEqual(summaries[0]["project_name"], "Merged Batch")
        self.assertEqual(summaries[0]["video_count"], 2)

    def test_cannot_move_processing_video(self):
        batch_proj = project_store.create_project("Batch X", self.projects_dir, "batch")
        video = create_desktop_video(
            str(self.sample_video),
            VideoConfig(project_type="single"),
            project_name="Processing Video",
            project_directory=self.projects_dir,
        )
        video_store.update_video(video.video_id, status="processing")

        host = SimpleNamespaceMock(
            _selected_project_key=video.project_key,
            _project_directory=self.projects_dir,
        )
        commands = ProjectCommandsController(host)

        commands.move_videos_to_batch_project(
            target_project_key=batch_proj["key"],
            video_ids=[video.video_id],
        )

        # Video remains unchanged
        unchanged = video_store.get_video(video.video_id)
        self.assertNotEqual(unchanged.project_key, batch_proj["key"])
        self.assertEqual(unchanged.status, "processing")

    def test_controller_target_and_candidate_queries(self):
        # Create a batch project and two single projects
        batch_proj = project_store.create_project("Batch Main", self.projects_dir, "batch")
        video1 = create_desktop_video(
            str(self.sample_video),
            VideoConfig(project_type="single"),
            project_name="Clip 1",
            project_directory=self.projects_dir,
        )
        video2 = create_desktop_video(
            str(self.sample_video),
            VideoConfig(project_type="single"),
            project_name="Clip 2",
            project_directory=self.projects_dir,
        )

        controller = TruongNgocHoaController()
        # Test targets query
        targets = controller.getMoveTargetProjects(video1.project_key)
        self.assertEqual(len(targets), 1)
        self.assertEqual(targets[0]["name"], "Batch Main")
        self.assertEqual(targets[0]["key"], batch_proj["key"])

        # Test candidate videos query
        candidates = controller.getMoveCandidateVideos(video1.project_key)
        self.assertEqual(len(candidates), 2)
        # video1 is source, so selected=True and isSource=True
        source_candidate = next((c for c in candidates if c["videoId"] == video1.video_id), None)
        other_candidate = next((c for c in candidates if c["videoId"] == video2.video_id), None)
        self.assertIsNotNone(source_candidate)
        self.assertIsNotNone(other_candidate)
        self.assertTrue(source_candidate["selected"])
        self.assertTrue(source_candidate["isSource"])
        self.assertFalse(other_candidate["selected"])
        self.assertFalse(other_candidate["isSource"])


class SimpleNamespaceMock:
    def __init__(self, **kwargs):
        self._selected_project_key = kwargs.get("_selected_project_key", "")
        self._project_name = kwargs.get("_project_name", "")
        self._project_type = kwargs.get("_project_type", "single")
        self._project_directory = kwargs.get("_project_directory", "")
        self.appAlertRequested = Mock()
        self.appAlertRequested.emit = Mock()
        self.refreshVideos = Mock()
        self.projectSetupChanged = Mock()
        self.projectSetupChanged.emit = Mock()
        self.batchChanged = Mock()
        self.batchChanged.emit = Mock()
        self.selectedVideoChanged = Mock()
        self.selectedVideoChanged.emit = Mock()
        self.videoDeleted = Mock()
        self.videoDeleted.emit = Mock()

    def _video_project_key(self, video):
        return TruongNgocHoaController._video_project_key(video)


if __name__ == "__main__":
    unittest.main()
