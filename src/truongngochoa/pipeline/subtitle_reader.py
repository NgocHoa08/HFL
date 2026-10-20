"""Read burned-in video subtitles with OCR and return timed source segments.

The output has the same shape as the speech recogniser (``start``, ``end``,
``text``, ``language``) so the existing translation and dubbing stages can use
it unchanged.
"""

from __future__ import annotations

import json
import re
import subprocess
import tempfile
from collections import Counter
from dataclasses import dataclass
from difflib import SequenceMatcher
from pathlib import Path
from typing import Callable

from truongngochoa.pipeline.process_registry import check_cancellation, communicate_process
from truongngochoa.pipeline.subtitle_ocr import MIN_CONFIDENCE, _ocr_engine, detect_original_subtitle_region
from truongngochoa.services.video_store import log_to_video
from truongngochoa.utils.ffmpeg import get_video_dimensions, get_video_duration

TARGET_FPS = 2.0
MIN_FPS = 1.0
MAX_FRAMES = 3000
CROP_MAX_WIDTH = 720
SIMILARITY = 0.78
MAX_GAP_FRAMES = 1
MIN_FRAMES = 2
CACHE_VERSION = 1


@dataclass
class _Run:
    first: int
    last: int
    texts: list[str]


def guess_language(text: str, fallback: str = "en") -> str:
    """Cheap script-based language guess for OCR text."""
    if re.search(r"[\u3040-\u30ff]", text):
        return "ja"
    if re.search(r"[\uac00-\ud7af]", text):
        return "ko"
    if re.search(r"[\u4e00-\u9fff]", text):
        return "zh"
    if re.search(r"[ăâđêôơưĂÂĐÊÔƠƯạảấầẩẫậắằẳẵặẹẻẽếềểễệỉịọỏốồổỗộớờởỡợụủứừửữựỳỵỷỹ]", text):
        return "vi"
    if re.search(r"[\u0400-\u04ff]", text):
        return "ru"
    return fallback


def _clean(text: str) -> str:
    return re.sub(r"\s+", " ", text).strip()


def group_frame_texts(texts: list[str], fps: float) -> list[dict]:
    """Merge per-frame OCR text into timed segments (pure function)."""
    runs: list[_Run] = []
    current: _Run | None = None
    for index, text in enumerate(texts):
        text = _clean(text)
        if not text:
            continue
        if current and index - current.last - 1 <= MAX_GAP_FRAMES and SequenceMatcher(
            None, current.texts[-1], text,
        ).ratio() >= SIMILARITY:
            current.last = index
            current.texts.append(text)
            continue
        current = _Run(index, index, [text])
        runs.append(current)
    step = 1 / fps
    segments = []
    for run in runs:
        if run.last - run.first + 1 < MIN_FRAMES:
            continue
        counts = Counter(run.texts)
        best = max(counts, key=lambda value: (counts[value], len(value)))
        if len(best.strip()) < 2 and run.last == run.first:
            continue
        segments.append({
            "start": round(run.first * step, 3),
            "end": round((run.last + 1) * step, 3),
            "text": best,
        })
    # Never overlap: captions replace each other on screen.
    for left, right in zip(segments, segments[1:]):
        if left["end"] > right["start"]:
            left["end"] = right["start"]
    return [segment for segment in segments if segment["end"] - segment["start"] >= 0.2]


def _crop_filter(region: dict, width: int, height: int) -> str:
    pad_x, pad_y = 2.0, max(1.5, region["height_percent"] * 0.25)
    x = max(0.0, region["x_percent"] - pad_x)
    y = max(0.0, region["y_percent"] - pad_y)
    w = min(100.0 - x, region["width_percent"] + 2 * pad_x)
    h = min(100.0 - y, region["height_percent"] + 2 * pad_y)
    crop_w = max(16, int(width * w / 100) // 2 * 2)
    crop_h = max(16, int(height * h / 100) // 2 * 2)
    out_w = min(crop_w, CROP_MAX_WIDTH) // 2 * 2
    return (f"crop={crop_w}:{crop_h}:{int(width * x / 100)}:{int(height * y / 100)},"
            f"scale={out_w}:-2")


def _frame_text(frame_path: Path) -> str:
    import cv2
    import numpy as np

    data = np.fromfile(str(frame_path), dtype=np.uint8)
    if not len(data):
        return ""
    img = cv2.imdecode(data, cv2.IMREAD_COLOR)
    if img is None:
        return ""
    output = _ocr_engine()(img)
    boxes = getattr(output, "boxes", None)
    texts = getattr(output, "txts", None)
    scores = getattr(output, "scores", None)
    if boxes is None or texts is None or scores is None:
        return ""
    rows = []
    for box, text, score in zip(boxes, texts, scores):
        if float(score) < MIN_CONFIDENCE or sum(c.isalnum() for c in str(text)) < 1:
            continue
        rows.append((min(float(p[1]) for p in box), min(float(p[0]) for p in box), str(text)))
    rows.sort()
    return " ".join(text for _y, _x, text in rows)


def read_subtitles(
    video_path: str,
    output_json_path: str,
    video_id: str,
    temp_dir: str,
    *,
    region_override: dict | None = None,
    source_language: str = "auto",
    progress_callback: Callable[[int, int], None] | None = None,
) -> tuple[list[dict], str]:
    """OCR the subtitle area over the whole video; returns (segments, language)."""
    region = region_override or detect_original_subtitle_region(video_path, temp_dir, video_id)
    if not region:
        raise RuntimeError("Không tìm thấy phụ đề trên video (No burned-in subtitles were detected).")
    duration = get_video_duration(video_path)
    width, height = get_video_dimensions(video_path)
    if duration <= 0 or width <= 0 or height <= 0:
        raise RuntimeError("Unable to inspect the source video for subtitle reading.")
    fps = max(MIN_FPS, min(TARGET_FPS, MAX_FRAMES / duration))
    Path(temp_dir).mkdir(parents=True, exist_ok=True)
    log_to_video(video_id, f"Reading on-screen subtitles with OCR at {fps:.2f} fps.")
    with tempfile.TemporaryDirectory(prefix="subtitle-read-", dir=temp_dir) as frame_dir:
        command = ["ffmpeg", "-y", "-loglevel", "error", "-i", video_path, "-an",
                   "-vf", f"fps={fps:.6f},{_crop_filter(region, width, height)}", "-q:v", "3",
                   str(Path(frame_dir) / "f-%06d.jpg")]
        check_cancellation(video_id)
        process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True,
                                   creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0))
        _out, stderr = communicate_process(video_id, process, label="Subtitle frame extraction",
                                           timeout_seconds=3600)
        if process.returncode != 0:
            raise RuntimeError(f"Unable to extract subtitle frames: {stderr[-500:]}")
        frames = sorted(Path(frame_dir).glob("f-*.jpg"))
        texts: list[str] = []
        last_text, last_signature = "", None
        for index, frame in enumerate(frames, 1):
            check_cancellation(video_id)
            signature = frame.stat().st_size
            # Identical-size consecutive JPEGs are almost always identical frames.
            if signature == last_signature:
                texts.append(last_text)
            else:
                last_text = _frame_text(frame)
                last_signature = signature
                texts.append(last_text)
            if progress_callback and (index == len(frames) or index % 20 == 0):
                progress_callback(index, len(frames))
    segments = group_frame_texts(texts, fps)
    if not segments:
        raise RuntimeError("Không đọc được phụ đề trên video (OCR returned no readable subtitle text).")
    fallback = source_language if source_language not in {"", "auto"} else "en"
    language = Counter(guess_language(s["text"], fallback) for s in segments).most_common(1)[0][0]
    for segment in segments:
        segment["language"] = guess_language(segment["text"], language)
        segment["language_confidence"] = 1.0
    Path(output_json_path).parent.mkdir(parents=True, exist_ok=True)
    Path(output_json_path).write_text(json.dumps(segments, ensure_ascii=False, indent=2), encoding="utf-8")
    log_to_video(video_id, f"Read {len(segments)} subtitle sentences (language: {language}).")
    return segments, language
