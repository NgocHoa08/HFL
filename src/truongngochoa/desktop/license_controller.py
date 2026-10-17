"""QML controller for license activation, server config, and hardware quota."""

from __future__ import annotations

from PySide6.QtCore import Property, QObject, Signal, Slot
from PySide6.QtGui import QGuiApplication

from truongngochoa.services import license_manager


class LicenseController(QObject):
    licenseChanged = Signal()

    def __init__(self, host=None):
        parent = host if isinstance(host, QObject) else None
        super().__init__(parent)
        self._host = host
        self._state = license_manager.load_local_license()

    @Property(bool, notify=licenseChanged)
    def licenseActive(self) -> bool:
        return bool(self._state.get("is_active", False))

    @Property(str, notify=licenseChanged)
    def licenseKey(self) -> str:
        return str(self._state.get("license_key", ""))

    @Property(str, notify=licenseChanged)
    def licenseHwid(self) -> str:
        return str(self._state.get("hwid") or license_manager.get_machine_hwid())

    @Property(str, notify=licenseChanged)
    def licenseCustomerName(self) -> str:
        return str(self._state.get("customer_name", ""))

    @Property(str, notify=licenseChanged)
    def licensePlanType(self) -> str:
        plan = str(self._state.get("plan_type", "none"))
        labels = {
            "monthly": "Gói theo tháng",
            "credits": "Gói theo số lượt",
            "lifetime": "Bản quyền vĩnh viễn",
            "trial": "Gói dùng thử",
            "none": "Chưa có gói",
        }
        return labels.get(plan, plan)

    @Property(str, notify=licenseChanged)
    def licenseExpiresAt(self) -> str:
        exp = self._state.get("expires_at")
        if not exp:
            return "Không giới hạn"
        try:
            # Format to friendly string if ISO
            return str(exp).replace("T", " ")[:16]
        except Exception:
            return str(exp)

    @Property(int, notify=licenseChanged)
    def licenseCreditsRemaining(self) -> int:
        credits_left = self._state.get("credits_remaining")
        return -1 if credits_left is None else int(credits_left)

    @Property(str, notify=licenseChanged)
    def licenseStatusMessage(self) -> str:
        return str(self._state.get("status_message", ""))

    @Property(bool, notify=licenseChanged)
    def serverConfigured(self) -> bool:
        cfg = license_manager.load_server_config()
        return bool(cfg.get("supabase_url") and cfg.get("supabase_key"))

    @Property(str, notify=licenseChanged)
    def supabaseUrl(self) -> str:
        return str(license_manager.load_server_config().get("supabase_url", ""))

    @Property(str, notify=licenseChanged)
    def supabaseKey(self) -> str:
        return str(license_manager.load_server_config().get("supabase_key", ""))

    @Slot(str, result=bool)
    def activate(self, key: str) -> bool:
        res = license_manager.activate_license(key)
        self._state = license_manager.load_local_license()
        self.licenseChanged.emit()
        if res.get("valid"):
            self._host.appAlertRequested.emit("Kích hoạt thành công", "Bản quyền phần mềm đã được kích hoạt.", "info")
            return True
        self._host.appAlertRequested.emit("Kích hoạt không thành công", res.get("message", "Mã không hợp lệ."), "warning")
        return False

    @Slot(result=bool)
    def refresh(self) -> bool:
        res = license_manager.refresh_license_status()
        self._state = license_manager.load_local_license()
        self.licenseChanged.emit()
        if res.get("valid"):
            self._host.appAlertRequested.emit("Đã làm mới", "Thông tin bản quyền đã được cập nhật từ máy chủ.", "info")
            return True
        self._host.appAlertRequested.emit("Làm mới thất bại", res.get("message", "Không thể cập nhật."), "warning")
        return False

    @Slot()
    def deactivate(self) -> None:
        license_manager.deactivate_license()
        self._state = license_manager.load_local_license()
        self.licenseChanged.emit()
        self._host.appAlertRequested.emit("Đã hủy", "Đã xóa mã kích hoạt khỏi máy tính này.", "info")

    @Slot(str, str, result=bool)
    def saveServerConfig(self, url: str, key: str) -> bool:
        license_manager.save_server_config(url, key)
        self.licenseChanged.emit()
        self._host.appAlertRequested.emit("Đã lưu máy chủ", "Cấu hình kết nối máy chủ Supabase đã được lưu.", "info")
        return True

    @Slot()
    def copyHwidToClipboard(self) -> None:
        clipboard = QGuiApplication.clipboard()
        if clipboard:
            clipboard.setText(self.licenseHwid)
            self._host.appAlertRequested.emit("Đã sao chép", f"Đã sao chép mã máy: {self.licenseHwid}", "info")

    @Slot(result=bool)
    def canProcess(self) -> bool:
        allowed, msg = license_manager.consume_usage_credit()
        self._state = license_manager.load_local_license()
        self.licenseChanged.emit()
        if not allowed:
            self._host.appAlertRequested.emit("Bản quyền yêu cầu", msg, "warning")
            if hasattr(self._host, "licenseDialogRequested"):
                self._host.licenseDialogRequested.emit()
            return False
        return True

