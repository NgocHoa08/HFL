import os
import tempfile
import threading
import unittest
from unittest.mock import MagicMock, patch

from truongngochoa.services.video_splitter import (
    format_bytes,
    format_time_display,
    probe_split_video,
    split_video_two_parts,
)


class VideoSplitterTests(unittest.TestCase):
    def test_format_time_display(self):
        self.assertEqual(format_time_display(0), "00:00")
        self.assertEqual(format_time_display(65), "01:05")
        self.assertEqual(format_time_display(600), "10:00")
        self.assertEqual(format_time_display(3665), "01:01:05")

    def test_format_bytes(self):
        self.assertEqual(format_bytes(500), "500 B")
        self.assertEqual(format_bytes(2048), "2 KB")
        self.assertEqual(format_bytes(1024 * 1024 * 50), "50.0 MB")
        self.assertEqual(format_bytes(1024 * 1024 * 1024 * 2), "2.0 GB")

    def test_probe_split_video_not_found(self):
        with self.assertRaises(FileNotFoundError):
            probe_split_video("non_existent_file.mp4")

    def test_probe_split_video_empty(self):
        with tempfile.NamedTemporaryFile(suffix=".mp4", delete=False) as f:
            temp_path = f.name
        try:
            with self.assertRaises(ValueError):
                probe_split_video(temp_path)
        finally:
            if os.path.exists(temp_path):
                os.remove(temp_path)

    @patch("truongngochoa.services.video_splitter.get_video_duration")
    @patch("truongngochoa.services.video_splitter.get_video_dimensions")
    def test_probe_split_video_success(self, mock_dim, mock_dur):
        mock_dur.return_value = 120.0
        mock_dim.return_value = (1920, 1080)

        with tempfile.NamedTemporaryFile(suffix=".mp4", delete=False) as f:
            f.write(b"dummy video content")
            temp_path = f.name
        try:
            info = probe_split_video(temp_path)
            self.assertEqual(info["duration"], 120.0)
            self.assertEqual(info["duration_formatted"], "02:00")
            self.assertEqual(info["split_point"], 60.0)
            self.assertEqual(info["split_point_formatted"], "01:00")
            self.assertEqual(info["part1_duration_formatted"], "01:00")
            self.assertEqual(info["part2_duration_formatted"], "01:00")
            self.assertTrue(info["part1_filename"].endswith("_Part1.mp4"))
            self.assertTrue(info["part2_filename"].endswith("_Part2.mp4"))
        finally:
            if os.path.exists(temp_path):
                os.remove(temp_path)

    @patch("truongngochoa.services.video_splitter.probe_split_video")
    @patch("subprocess.Popen")
    def test_split_video_two_parts_success(self, mock_popen, mock_probe):
        with tempfile.TemporaryDirectory() as out_dir:
            source = os.path.join(out_dir, "original.mp4")
            with open(source, "wb") as f:
                f.write(b"data")

            mock_probe.return_value = {
                "path": source,
                "name": "original.mp4",
                "stem": "original",
                "extension": ".mp4",
                "directory": out_dir,
                "duration": 600.0,
            }

            p1 = os.path.join(out_dir, "original_Part1.mp4")
            p2 = os.path.join(out_dir, "original_Part2.mp4")

            # Mock popen to simulate creating the files
            def fake_popen(args, **kwargs):
                out_target = args[-1]
                with open(out_target, "wb") as f_out:
                    f_out.write(b"part data")
                proc = MagicMock()
                proc.poll.return_value = 0
                proc.returncode = 0
                proc.communicate.return_value = (b"", b"")
                return proc

            mock_popen.side_effect = fake_popen

            reports = []
            res1, res2 = split_video_two_parts(
                source,
                out_dir,
                split_point=300.0,
                progress_callback=lambda p, msg: reports.append((p, msg)),
            )

            self.assertEqual(res1, p1)
            self.assertEqual(res2, p2)
            self.assertTrue(os.path.exists(p1))
            self.assertTrue(os.path.exists(p2))
            self.assertTrue(any(r[0] == 100 for r in reports))


if __name__ == "__main__":
    unittest.main()
