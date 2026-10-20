"""Desktop controller for splitting long videos into two parts."""

from __future__ import annotations

import os
import threading
from pathlib import Path

from PySide6.QtCore import Property, QObject, QTimer, Signal, Slot

from truongngochoa.desktop.localization import QFileDialog, QMessageBox, native_media_dialog_directory
from truongngochoa.desktop.media import open_path
from truongngochoa.services.video_splitter import (
    format_time_display,
    probe_split_video,
    split_video_two_parts,
)


class VideoSplitController(QObject):
    stateChanged = Signal()

    def __init__(self, host=None):
        parent = host if isinstance(host, QObject) else None
        super().__init__(parent)
        self._host = host

        self._source_path = ""
        self._source_name = ""
        self._source_duration = 0.0
        self._source_duration_formatted = "00:00"
        self._source_resolution = ""
        self._source_file_size = ""

        self._split_point = 0.0
        self._split_point_formatted = "00:00"
        self._split_percent = 50.0

        self._part1_duration_formatted = "00:00"
        self._part2_duration_formatted = "00:00"
        self._part1_filename = ""
        self._part2_filename = ""

        self._output_dir = ""
        self._split_mode = "fast"  # "fast" or "reencode"

        self._busy = False
        self._progress = 0
        self._status_message = ""
        self._completed = False
        self._part1_path = ""
        self._part2_path = ""
        self._error_message = ""

        self._worker: threading.Thread | None = None
        self._cancel_event = threading.Event()

    # --- Properties ---
    @Property(bool, notify=stateChanged)
    def hasSource(self) -> bool:
        return bool(self._source_path and os.path.isfile(self._source_path))

    @Property(str, notify=stateChanged)
    def sourcePath(self) -> str:
        return self._source_path

    @Property(str, notify=stateChanged)
    def sourceName(self) -> str:
        return self._source_name

    @Property(float, notify=stateChanged)
    def sourceDuration(self) -> float:
        return self._source_duration

    @Property(str, notify=stateChanged)
    def sourceDurationFormatted(self) -> str:
        return self._source_duration_formatted

    @Property(str, notify=stateChanged)
    def sourceResolution(self) -> str:
        return self._source_resolution

    @Property(str, notify=stateChanged)
    def sourceFileSize(self) -> str:
        return self._source_file_size

    @Property(float, notify=stateChanged)
    def splitPoint(self) -> float:
        return self._split_point

    @Property(str, notify=stateChanged)
    def splitPointFormatted(self) -> str:
        return self._split_point_formatted

    @Property(float, notify=stateChanged)
    def splitPercent(self) -> float:
        return self._split_percent

    @Property(str, notify=stateChanged)
    def part1DurationFormatted(self) -> str:
        return self._part1_duration_formatted

    @Property(str, notify=stateChanged)
    def part2DurationFormatted(self) -> str:
        return self._part2_duration_formatted

    @Property(str, notify=stateChanged)
    def part1FileName(self) -> str:
        return self._part1_filename

    @Property(str, notify=stateChanged)
    def part2FileName(self) -> str:
        return self._part2_filename

    @Property(str, notify=stateChanged)
    def outputDirectory(self) -> str:
        return self._output_dir

    @Property(str, notify=stateChanged)
    def splitMode(self) -> str:
        return self._split_mode

    @Property(bool, notify=stateChanged)
    def busy(self) -> bool:
        return self._busy

    @Property(int, notify=stateChanged)
    def progress(self) -> int:
        return self._progress

    @Property(str, notify=stateChanged)
    def statusMessage(self) -> str:
        return self._status_message

    @Property(bool, notify=stateChanged)
    def splitCompleted(self) -> bool:
        return self._completed

    @Property(str, notify=stateChanged)
    def part1Path(self) -> str:
        return self._part1_path

    @Property(str, notify=stateChanged)
    def part2Path(self) -> str:
        return self._part2_path

    @Property(str, notify=stateChanged)
    def errorMessage(self) -> str:
        return self._error_message

    # --- Methods ---
    def _apply_split_calculation(self):
        if self._source_duration <= 0:
            return
        self._split_point = round((self._source_duration * self._split_percent) / 100.0, 2)
        self._split_point = max(1.0, min(self._source_duration - 1.0, self._split_point))
        self._split_point_formatted = format_time_display(self._split_point)
        self._part1_duration_formatted = format_time_display(self._split_point)
        self._part2_duration_formatted = format_time_display(max(0.0, self._source_duration - self._split_point))

    @Slot(str, result=bool)
    def setSourceVideo(self, path: str) -> bool:
        if self._busy:
            return False
        clean_path = str(path or "").strip()
        if not clean_path or not os.path.isfile(clean_path):
            return False
        try:
            info = probe_split_video(clean_path)
            self._source_path = info["path"]
            self._source_name = info["name"]
            self._source_duration = info["duration"]
            self._source_duration_formatted = info["duration_formatted"]
            self._source_resolution = info["resolution"]
            self._source_file_size = info["file_size_formatted"]

            self._split_percent = 50.0
            self._apply_split_calculation()

            self._part1_filename = info["part1_filename"]
            self._part2_filename = info["part2_filename"]

            if not self._output_dir or not os.path.isdir(self._output_dir):
                self._output_dir = info["directory"]

            self._completed = False
            self._part1_path = ""
            self._part2_path = ""
            self._error_message = ""
            self._status_message = "Sẵn sàng cắt video"
            self._progress = 0
            self.stateChanged.emit()
            return True
        except Exception as exc:
            self._error_message = str(exc)
            self.stateChanged.emit()
            return False

    @Slot(result=bool)
    def browseSourceVideo(self) -> bool:
        if self._busy:
            return False
        path, _ = QFileDialog.getOpenFileName(
            None,
            "Chọn video để cắt chia 2 phần",
            self._output_dir or native_media_dialog_directory(),
            "Video files (*.mp4 *.mov *.webm *.mkv *.avi);;All files (*.*)",
        )
        if not path:
            return False
        return self.setSourceVideo(path)

    @Slot(result=bool)
    def browseOutputDirectory(self) -> bool:
        if self._busy:
            return False
        folder = QFileDialog.getExistingDirectory(
            None,
            "Chọn thư mục lưu 2 phần video",
            self._output_dir or native_media_dialog_directory(),
            QFileDialog.Option.ShowDirsOnly,
        )
        if not folder:
            return False
        self._output_dir = folder
        self.stateChanged.emit()
        return True

    @Slot(float)
    def setSplitPercent(self, percent: float):
        if self._busy or self._source_duration <= 0:
            return
        self._split_percent = max(5.0, min(95.0, float(percent)))
        self._apply_split_calculation()
        self.stateChanged.emit()

    @Slot(float)
    def setSplitPoint(self, seconds: float):
        if self._busy or self._source_duration <= 0:
            return
        sec = max(1.0, min(self._source_duration - 1.0, float(seconds)))
        self._split_percent = round((sec / self._source_duration) * 100.0, 1)
        self._apply_split_calculation()
        self.stateChanged.emit()

    @Slot(str)
    def setSplitMode(self, mode: str):
        if self._busy:
            return
        if mode in ("fast", "reencode"):
            self._split_mode = mode
            self.stateChanged.emit()

    @Slot(result=bool)
    def startSplit(self) -> bool:
        if self._busy or not self.hasSource or not self._output_dir:
            return False

        self._busy = True
        self._progress = 0
        self._completed = False
        self._error_message = ""
        self._part1_path = ""
        self._part2_path = ""
        self._cancel_event.clear()
        self._status_message = "Bắt đầu cắt video..."
        self.stateChanged.emit()

        video_path = self._source_path
        out_dir = self._output_dir
        split_pt = self._split_point
        mode = self._split_mode

        def worker_target():
            def on_progress(p: int, msg: str):
                self._progress = p
                self._status_message = msg
                # Emit in main thread via QTimer
                QTimer.singleShot(0, self.stateChanged.emit)

            try:
                p1, p2 = split_video_two_parts(
                    video_path,
                    out_dir,
                    split_pt,
                    mode=mode,
                    progress_callback=on_progress,
                    cancel_event=self._cancel_event,
                )
                self._part1_path = p1
                self._part2_path = p2
                self._completed = True
                self._status_message = "Đã cắt chia 2 phần video thành công!"
                self._progress = 100
            except InterruptedError:
                self._status_message = "Đã hủy tiến trình cắt video."
                self._progress = 0
            except Exception as exc:
                self._error_message = str(exc)
                self._status_message = f"Lỗi: {exc}"
                self._progress = 0
            finally:
                self._busy = False
                QTimer.singleShot(0, self.stateChanged.emit)

        self._worker = threading.Thread(target=worker_target, name="truongngochoa-video-split", daemon=True)
        self._worker.start()
        return True

    @Slot()
    def cancelSplit(self):
        if self._busy:
            self._cancel_event.set()
            self._status_message = "Đang hủy..."
            self.stateChanged.emit()

    @Slot()
    def openOutputDirectory(self):
        target = self._output_dir or (Path(self._source_path).parent if self._source_path else "")
        if target and os.path.exists(target):
            open_path(target)

    @Slot(result=bool)
    def addPartsToSocialQueue(self) -> bool:
        """Add the two generated parts directly to the social publishing queue."""
        if not self._completed or not self._part1_path or not self._part2_path:
            return False
        publisher = getattr(self._host, "_tiktok_publisher", None)
        if publisher and hasattr(publisher, "add_videos"):
            return publisher.add_videos([self._part1_path, self._part2_path])
        return False

    @Slot()
    def reset(self):
        if self._busy:
            return
        self._source_path = ""
        self._source_name = ""
        self._source_duration = 0.0
        self._source_duration_formatted = "00:00"
        self._source_resolution = ""
        self._source_file_size = ""
        self._split_point = 0.0
        self._split_point_formatted = "00:00"
        self._split_percent = 50.0
        self._part1_duration_formatted = "00:00"
        self._part2_duration_formatted = "00:00"
        self._part1_filename = ""
        self._part2_filename = ""
        self._busy = False
        self._progress = 0
        self._status_message = ""
        self._completed = False
        self._part1_path = ""
        self._part2_path = ""
        self._error_message = ""
        self.stateChanged.emit()
