"""Service for splitting videos into two parts using FFmpeg stream copy or re-encoding."""

from __future__ import annotations

import os
import shutil
import subprocess
import threading
from pathlib import Path
from typing import Callable

from truongngochoa.utils.ffmpeg import _binary, get_video_dimensions, get_video_duration


def format_time_display(seconds: float) -> str:
    """Format seconds into MM:SS or HH:MM:SS string."""
    total_seconds = max(0, int(round(seconds)))
    hours = total_seconds // 3600
    minutes = (total_seconds % 3600) // 60
    secs = total_seconds % 60
    if hours > 0:
        return f"{hours:02d}:{minutes:02d}:{secs:02d}"
    return f"{minutes:02d}:{secs:02d}"


def format_bytes(num_bytes: int) -> str:
    """Format byte size into human readable string."""
    size = float(max(0, num_bytes))
    for unit in ("B", "KB", "MB", "GB", "TB"):
        if size < 1024.0 or unit == "TB":
            return f"{size:.1f} {unit}" if unit in ("MB", "GB") else f"{int(size)} {unit}"
        size /= 1024.0
    return f"{num_bytes} B"


def probe_split_video(video_path: str) -> dict:
    """Probe video metadata for splitting."""
    resolved_path = os.path.abspath(str(video_path or "").strip())
    if not os.path.isfile(resolved_path):
        raise FileNotFoundError(f"Video file not found: {video_path}")
    
    file_size = os.path.getsize(resolved_path)
    if file_size <= 0:
        raise ValueError("Video file is empty.")

    duration = get_video_duration(resolved_path, timeout_seconds=20.0)
    if duration <= 1.0:
        raise ValueError("Video is too short or duration could not be determined.")

    width = 0
    height = 0
    try:
        width, height = get_video_dimensions(resolved_path, timeout_seconds=15.0)
    except Exception:
        pass

    path_obj = Path(resolved_path)
    stem = path_obj.stem
    ext = path_obj.suffix.lower() or ".mp4"
    parent_dir = str(path_obj.parent)

    half_duration = round(duration / 2.0, 2)

    return {
        "path": resolved_path,
        "name": path_obj.name,
        "stem": stem,
        "extension": ext,
        "directory": parent_dir,
        "file_size": file_size,
        "file_size_formatted": format_bytes(file_size),
        "duration": duration,
        "duration_formatted": format_time_display(duration),
        "width": width,
        "height": height,
        "resolution": f"{width}×{height}" if width and height else "Unknown",
        "split_point": half_duration,
        "split_point_formatted": format_time_display(half_duration),
        "part1_duration": half_duration,
        "part1_duration_formatted": format_time_display(half_duration),
        "part2_duration": max(0.0, round(duration - half_duration, 2)),
        "part2_duration_formatted": format_time_display(max(0.0, duration - half_duration)),
        "part1_filename": f"{stem}_Part1{ext}",
        "part2_filename": f"{stem}_Part2{ext}",
    }


def split_video_two_parts(
    video_path: str,
    output_dir: str,
    split_point: float,
    *,
    mode: str = "fast",
    progress_callback: Callable[[int, str], None] | None = None,
    cancel_event: threading.Event | None = None,
) -> tuple[str, str]:
    """Split a video into two parts at split_point seconds.
    
    Returns (part1_path, part2_path).
    Raises FileNotFoundError, ValueError, RuntimeError, or InterruptedError.
    """
    metadata = probe_split_video(video_path)
    resolved_video = metadata["path"]
    total_duration = metadata["duration"]

    if split_point <= 0.5 or split_point >= total_duration - 0.5:
        raise ValueError("Điểm cắt phải nằm trong khoảng thời lượng hợp lệ của video.")

    os.makedirs(output_dir, exist_ok=True)
    ext = metadata["extension"]
    stem = metadata["stem"]

    part1_path = os.path.join(output_dir, f"{stem}_Part1{ext}")
    part2_path = os.path.join(output_dir, f"{stem}_Part2{ext}")

    # Avoid overwriting original file if output_dir contains the source
    if os.path.abspath(part1_path) == os.path.abspath(resolved_video) or os.path.abspath(part2_path) == os.path.abspath(resolved_video):
        part1_path = os.path.join(output_dir, f"{stem}_Split_Part1{ext}")
        part2_path = os.path.join(output_dir, f"{stem}_Split_Part2{ext}")

    def report(percent: int, msg: str):
        if progress_callback:
            progress_callback(percent, msg)

    report(5, "Đang chuẩn bị cắt phần 1...")

    def cleanup_on_error():
        for path in (part1_path, part2_path):
            try:
                if os.path.exists(path):
                    os.remove(path)
            except OSError:
                pass

    ffmpeg_bin = _binary("ffmpeg")

    def run_cut_command(args: list[str]) -> None:
        creation_flags = getattr(subprocess, "CREATE_NO_WINDOW", 0)
        proc = subprocess.Popen(
            args,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            creationflags=creation_flags,
        )

        while proc.poll() is None:
            if cancel_event and cancel_event.is_set():
                proc.kill()
                proc.communicate()
                cleanup_on_error()
                raise InterruptedError("Tiến trình cắt video đã bị hủy.")
            if cancel_event:
                cancel_event.wait(0.2)
            else:
                threading.Event().wait(0.2)

        _stdout, stderr = proc.communicate()
        if proc.returncode != 0:
            err_msg = stderr.decode("utf-8", errors="replace")[-500:] if stderr else "Lỗi không xác định từ FFmpeg."
            raise RuntimeError(f"FFmpeg thất bại (code {proc.returncode}): {err_msg}")

    # PART 1: 0 to split_point
    if cancel_event and cancel_event.is_set():
        raise InterruptedError("Tiến trình đã bị hủy.")

    report(10, f"Đang cắt Phần 1 (00:00 → {format_time_display(split_point)})...")

    part1_fast_args = [
        ffmpeg_bin, "-y",
        "-ss", "0",
        "-i", resolved_video,
        "-t", f"{split_point:.3f}",
        "-c", "copy",
        "-avoid_negative_ts", "make_zero",
        part1_path,
    ]

    part1_reencode_args = [
        ffmpeg_bin, "-y",
        "-ss", "0",
        "-i", resolved_video,
        "-t", f"{split_point:.3f}",
        "-c:v", "libx264", "-preset", "veryfast", "-crf", "20",
        "-c:a", "aac", "-b:a", "192k",
        part1_path,
    ]

    try:
        if mode == "fast":
            try:
                run_cut_command(part1_fast_args)
            except RuntimeError:
                # Fallback to re-encode if fast stream copy fails
                run_cut_command(part1_reencode_args)
        else:
            run_cut_command(part1_reencode_args)
    except Exception:
        cleanup_on_error()
        raise

    if not os.path.isfile(part1_path) or os.path.getsize(part1_path) <= 0:
        cleanup_on_error()
        raise RuntimeError("Không thể tạo tệp Phần 1.")

    report(50, "Đã hoàn thành Phần 1. Đang cắt Phần 2...")

    # PART 2: split_point to end
    if cancel_event and cancel_event.is_set():
        cleanup_on_error()
        raise InterruptedError("Tiến trình đã bị hủy.")

    report(55, f"Đang cắt Phần 2 ({format_time_display(split_point)} → {format_time_display(total_duration)})...")

    part2_fast_args = [
        ffmpeg_bin, "-y",
        "-ss", f"{split_point:.3f}",
        "-i", resolved_video,
        "-c", "copy",
        "-avoid_negative_ts", "make_zero",
        part2_path,
    ]

    part2_reencode_args = [
        ffmpeg_bin, "-y",
        "-ss", f"{split_point:.3f}",
        "-i", resolved_video,
        "-c:v", "libx264", "-preset", "veryfast", "-crf", "20",
        "-c:a", "aac", "-b:a", "192k",
        part2_path,
    ]

    try:
        if mode == "fast":
            try:
                run_cut_command(part2_fast_args)
            except RuntimeError:
                run_cut_command(part2_reencode_args)
        else:
            run_cut_command(part2_reencode_args)
    except Exception:
        cleanup_on_error()
        raise

    if not os.path.isfile(part2_path) or os.path.getsize(part2_path) <= 0:
        cleanup_on_error()
        raise RuntimeError("Không thể tạo tệp Phần 2.")

    report(100, "Hoàn tất! Đã chia video thành 2 phần thành công.")
    return part1_path, part2_path
