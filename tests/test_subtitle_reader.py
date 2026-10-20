import unittest

from truongngochoa.pipeline.subtitle_reader import group_frame_texts, guess_language


class SubtitleReaderTests(unittest.TestCase):
    def test_groups_repeated_text_into_timed_segments(self):
        texts = ["", "你好世界", "你好世界", "你好世界", "", "", "", "今天天气好", "今天天气好", ""]
        segments = group_frame_texts(texts, fps=2)
        self.assertEqual([s["text"] for s in segments], ["你好世界", "今天天气好"])
        self.assertEqual(segments[0]["start"], 0.5)
        self.assertEqual(segments[0]["end"], 2.0)
        self.assertLessEqual(segments[0]["end"], segments[1]["start"])

    def test_tolerates_ocr_noise_and_single_frame_gap(self):
        texts = ["hello world", "", "hello w0rld", "hello world"]
        self.assertEqual(len(group_frame_texts(texts, fps=2)), 1)

    def test_drops_single_frame_flicker(self):
        self.assertEqual(group_frame_texts(["", "noise", ""], fps=2), [])

    def test_language_guess(self):
        self.assertEqual(guess_language("你好"), "zh")
        self.assertEqual(guess_language("Xin chào các bạn, đây là"), "vi")
        self.assertEqual(guess_language("hello", "en"), "en")


    def test_subtitle_source_effective_choice(self):
        from unittest.mock import Mock, patch
        from truongngochoa.pipeline.process_video import _subtitle_source

        # Explicit per-video setting wins
        v1 = Mock(subtitle_source="ocr")
        self.assertEqual(_subtitle_source(v1), "ocr")

        # Global setting fallback
        v2 = Mock(subtitle_source="audio")
        with patch("truongngochoa.services.desktop_settings.load_settings", return_value={"subtitle_source": "ocr"}):
            self.assertEqual(_subtitle_source(v2), "ocr")


if __name__ == "__main__":
    unittest.main()

