import os
import tempfile
import unittest
from unittest.mock import MagicMock, patch

from PySide6.QtCore import QCoreApplication

from truongngochoa.desktop.video_split_controller import VideoSplitController


class VideoSplitControllerTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        if QCoreApplication.instance() is None:
            cls.app = QCoreApplication([])
        else:
            cls.app = QCoreApplication.instance()

    def setUp(self):
        self.mock_host = MagicMock()
        self.controller = VideoSplitController(self.mock_host)

    def test_initial_state(self):
        self.assertFalse(self.controller.hasSource)
        self.assertEqual(self.controller.sourceDuration, 0.0)
        self.assertEqual(self.controller.splitPercent, 50.0)
        self.assertFalse(self.controller.busy)
        self.assertFalse(self.controller.splitCompleted)

    @patch("truongngochoa.desktop.video_split_controller.probe_split_video")
    def test_set_source_video(self, mock_probe):
        with tempfile.NamedTemporaryFile(suffix=".mp4", delete=False) as f:
            f.write(b"data")
            temp_path = f.name
        try:
            mock_probe.return_value = {
                "path": temp_path,
                "name": "test.mp4",
                "stem": "test",
                "extension": ".mp4",
                "directory": os.path.dirname(temp_path),
                "duration": 200.0,
                "duration_formatted": "03:20",
                "resolution": "1920×1080",
                "file_size_formatted": "10.0 MB",
                "part1_filename": "test_Part1.mp4",
                "part2_filename": "test_Part2.mp4",
            }

            success = self.controller.setSourceVideo(temp_path)
            self.assertTrue(success)
            self.assertTrue(self.controller.hasSource)
            self.assertEqual(self.controller.sourceName, "test.mp4")
            self.assertEqual(self.controller.sourceDuration, 200.0)
            self.assertEqual(self.controller.splitPoint, 100.0)
            self.assertEqual(self.controller.part1DurationFormatted, "01:40")
            self.assertEqual(self.controller.part2DurationFormatted, "01:40")

            # Test changing split percent
            self.controller.setSplitPercent(25.0)
            self.assertEqual(self.controller.splitPoint, 50.0)
            self.assertEqual(self.controller.part1DurationFormatted, "00:50")
            self.assertEqual(self.controller.part2DurationFormatted, "02:30")
        finally:
            if os.path.exists(temp_path):
                os.remove(temp_path)

    def test_reset(self):
        self.controller._source_path = "some/file.mp4"
        self.controller._completed = True
        self.controller.reset()
        self.assertFalse(self.controller.hasSource)
        self.assertFalse(self.controller.splitCompleted)


if __name__ == "__main__":
    unittest.main()
