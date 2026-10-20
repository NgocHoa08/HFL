import json
import unittest
from pathlib import Path
from unittest.mock import MagicMock, patch

from truongngochoa.desktop.project_commands_controller import ProjectCommandsController
from truongngochoa.services import video_store


class SubtitleReviewAndOutputPreviewTests(unittest.TestCase):
    def test_approve_translation_review_when_video_done_triggers_rerender(self):
        tmp_dir = Path(__file__).resolve().parent / "fixtures" / "scratch_review_test"
        tmp_dir.mkdir(parents=True, exist_ok=True)
        transcript_file = tmp_dir / "transcript.json"

        initial_segments = [
            {"start": 0.0, "end": 2.5, "text": "Xin chào các bạn"},
            {"start": 2.5, "end": 5.0, "text": "Hôm nay chúng ta sẽ học lập trình"}
        ]
        transcript_file.write_text(json.dumps(initial_segments, ensure_ascii=False), encoding="utf-8")

        video_id = "test_video_review_done_1"
        test_video = MagicMock()
        test_video.video_id = video_id
        test_video.status = "done"
        test_video.project_type = "single"
        test_video.files = {"transcript_json": str(transcript_file)}
        test_video.checkpoints = {"translation": "chk_trans"}

        host = MagicMock()
        host._selected_video_id = video_id
        host._enqueue_video = MagicMock()

        controller = ProjectCommandsController(host)

        updated_segments = [
            {"start": 0.0, "end": 2.5, "text": "Chào mừng quý vị"},
            {"start": 2.5, "end": 5.0, "text": "Hôm nay chúng ta sẽ học lập trình"}
        ]
        payload = json.dumps(updated_segments, ensure_ascii=False)

        with patch.object(video_store, "get_video", return_value=test_video):
            with patch.object(video_store, "update_video") as mock_update_video:
                with patch.object(video_store, "log_to_video") as mock_log:
                    success = controller.approve_translation_review(payload)

        self.assertTrue(success)
        # Check transcript file was updated
        saved_data = json.loads(transcript_file.read_text(encoding="utf-8"))
        self.assertEqual(saved_data[0]["text"], "Chào mừng quý vị")

        # Verify video status was set to pending with resume_step = creating_subtitle
        mock_update_video.assert_called_once()
        _, kwargs = mock_update_video.call_args
        self.assertEqual(kwargs.get("status"), "pending")
        self.assertEqual(kwargs.get("resume_step"), "creating_subtitle")

        # Verify enqueued for rendering
        host._enqueue_video.assert_called_once_with(video_id)

        # Clean up
        if transcript_file.exists():
            transcript_file.unlink()
        if tmp_dir.exists():
            tmp_dir.rmdir()

    def test_qml_source_media_panel_has_toggle_and_subtitle_review_button(self):
        source_panel = (
            Path(__file__).resolve().parent.parent
            / "src"
            / "truongngochoa"
            / "desktop"
            / "qml"
            / "SourceMediaPanel.qml"
        ).read_text(encoding="utf-8")

        self.assertIn("activeView", source_panel)
        self.assertIn("Bản gốc", source_panel)
        self.assertIn("Bản đã sửa", source_panel)
        self.assertIn("Đang xem: Bản đã sửa", source_panel)
        self.assertIn("selectedOutputSource", source_panel)
        self.assertIn("Sửa phụ đề từng đoạn", source_panel)
        self.assertIn("requestReviewTranslation", source_panel)

    def test_qml_video_command_bar_allows_review_when_done(self):
        command_bar = (
            Path(__file__).resolve().parent.parent
            / "src"
            / "truongngochoa"
            / "desktop"
            / "qml"
            / "VideoCommandBar.qml"
        ).read_text(encoding="utf-8")

        self.assertIn("canReview", command_bar)
        self.assertIn('"done"', command_bar)
        self.assertIn("Xem & Sửa phụ đề", command_bar)



if __name__ == "__main__":
    unittest.main()
