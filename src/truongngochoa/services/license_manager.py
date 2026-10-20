"""Hardware-bound license verification and usage quota management."""

from __future__ import annotations

import hashlib
import json
import os
import threading
import urllib.error
import urllib.request
import winreg
from datetime import datetime, timezone
from pathlib import Path

from truongngochoa.config import RUNTIME_DATA_DIR

LICENSE_FILE = Path(RUNTIME_DATA_DIR) / "license.json"
SERVER_CONFIG_FILE = Path(RUNTIME_DATA_DIR) / "license-server.json"
_LICENSE_LOCK = threading.RLock()


class LicenseError(Exception):
    """Raised when software execution is blocked due to license constraints."""
    pass


def get_machine_hwid() -> str:
    """Retrieve immutable Windows Hardware ID (MachineGuid + Motherboard hash)."""
    raw_id = ""
    try:
        with winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Microsoft\Cryptography") as key:
            guid, _ = winreg.QueryValueEx(key, "MachineGuid")
            raw_id = str(guid).strip()
    except Exception:
        pass

    if not raw_id:
        try:
            import uuid
            raw_id = f"FALLBACK-{uuid.getnode()}"
        except Exception:
            raw_id = "UNKNOWN-HARDWARE-DEVICE"

    return hashlib.sha256(raw_id.encode("utf-8")).hexdigest()[:20].upper()


DEFAULT_SUPABASE_URL = "https://whjslcwgvdnlkqipzhix.supabase.co"
DEFAULT_SUPABASE_KEY = "sb_publishable_FGiXiftnae6Nl8DrUt5AGQ_90xNXk1k"


def clean_supabase_url(url: str) -> str:
    """Sanitize Supabase URL by trimming slashes and removing redundant /rest/v1 suffixes."""
    url = str(url or "").strip().rstrip("/")
    if url.endswith("/rest/v1"):
        url = url[:-len("/rest/v1")].rstrip("/")
    return url


def load_server_config() -> dict[str, str]:
    """Load Supabase or custom license API endpoints and API keys."""
    config = {
        "supabase_url": clean_supabase_url(os.getenv("TRUONGNGOCHOA_LICENSE_URL", "")) or DEFAULT_SUPABASE_URL,
        "supabase_key": os.getenv("TRUONGNGOCHOA_LICENSE_KEY", "").strip() or DEFAULT_SUPABASE_KEY,
    }
    if SERVER_CONFIG_FILE.is_file():
        try:
            data = json.loads(SERVER_CONFIG_FILE.read_text(encoding="utf-8"))
            if isinstance(data, dict):
                if data.get("supabase_url"):
                    config["supabase_url"] = clean_supabase_url(data["supabase_url"])
                if data.get("supabase_key"):
                    config["supabase_key"] = str(data["supabase_key"]).strip()
        except Exception:
            pass
    return config


def save_server_config(supabase_url: str, supabase_key: str) -> None:
    """Save server connection parameters to license-server.json."""
    SERVER_CONFIG_FILE.parent.mkdir(parents=True, exist_ok=True)
    with _LICENSE_LOCK:
        SERVER_CONFIG_FILE.write_text(
            json.dumps({
                "supabase_url": clean_supabase_url(supabase_url),
                "supabase_key": str(supabase_key).strip(),
            }, indent=2, ensure_ascii=False),
            encoding="utf-8"
        )


def load_local_license() -> dict:
    """Load saved local license state."""
    with _LICENSE_LOCK:
        if LICENSE_FILE.is_file():
            try:
                return json.loads(LICENSE_FILE.read_text(encoding="utf-8"))
            except Exception:
                pass
    return {
        "license_key": "",
        "hwid": get_machine_hwid(),
        "is_active": False,
        "customer_name": "",
        "plan_type": "none",
        "expires_at": None,
        "credits_remaining": None,
        "last_checked_at": None,
        "status_message": "Chưa kích hoạt bản quyền.",
    }


def save_local_license(data: dict) -> None:
    """Save license state locally."""
    LICENSE_FILE.parent.mkdir(parents=True, exist_ok=True)
    with _LICENSE_LOCK:
        LICENSE_FILE.write_text(
            json.dumps(data, indent=2, ensure_ascii=False),
            encoding="utf-8"
        )


def call_rpc(function_name: str, payload: dict) -> dict:
    """Execute a remote procedure call on the license server."""
    cfg = load_server_config()
    url = cfg.get("supabase_url")
    key = cfg.get("supabase_key")
    if not url or not key:
        return {
            "success": False,
            "valid": False,
            "message": "Máy chủ bản quyền chưa được thiết lập (thiếu Supabase URL/Key).",
        }

    endpoint = f"{url}/rest/v1/rpc/{function_name}"
    body = json.dumps(payload).encode("utf-8")
    request = urllib.request.Request(
        endpoint,
        data=body,
        headers={
            "Content-Type": "application/json",
            "apikey": key,
            "Authorization": f"Bearer {key}",
            "User-Agent": "TruongNgocHoa-App/1.0",
        },
        method="POST"
    )

    try:
        with urllib.request.urlopen(request, timeout=12) as response:
            result = json.loads(response.read().decode("utf-8"))
            if isinstance(result, dict):
                return result
            return {"success": True, "valid": True, "data": result}
    except urllib.error.HTTPError as exc:
        try:
            err = json.loads(exc.read().decode("utf-8"))
            msg = err.get("message") or err.get("details") or str(exc)
        except Exception:
            msg = f"HTTP Error {exc.code}: {exc.reason}"
        return {"success": False, "valid": False, "message": msg}
    except urllib.error.URLError as exc:
        return {
            "success": False,
            "valid": False,
            "message": f"Không thể kết nối máy chủ bản quyền: {exc.reason}",
        }
    except Exception as exc:
        return {
            "success": False,
            "valid": False,
            "message": f"Lỗi kiểm tra bản quyền: {exc}",
        }


def activate_license(license_key: str) -> dict:
    """Activate or re-verify a license key with the server."""
    license_key = str(license_key or "").strip()
    if not license_key:
        return {"valid": False, "message": "Vui lòng nhập mã bản quyền."}

    hwid = get_machine_hwid()
    resp = call_rpc("check_license", {"p_key": license_key, "p_hwid": hwid})

    now_iso = datetime.now(timezone.utc).isoformat()
    state = load_local_license()
    state["license_key"] = license_key
    state["hwid"] = hwid
    state["last_checked_at"] = now_iso

    if resp.get("valid"):
        state["is_active"] = True
        state["customer_name"] = str(resp.get("customer_name") or "")
        state["plan_type"] = str(resp.get("plan_type") or "standard")
        state["expires_at"] = resp.get("expires_at")
        state["credits_remaining"] = resp.get("credits_remaining")
        state["status_message"] = "Bản quyền hợp lệ."
    else:
        state["is_active"] = False
        state["status_message"] = resp.get("message") or "Mã bản quyền không hợp lệ."

    save_local_license(state)
    return {
        "valid": state["is_active"],
        "message": state["status_message"],
        "state": state,
    }


def refresh_license_status() -> dict:
    """Refresh the current license status online."""
    current = load_local_license()
    key = current.get("license_key", "")
    if not key:
        return {"valid": False, "message": "Chưa nhập mã bản quyền.", "state": current}
    return activate_license(key)


def deactivate_license() -> None:
    """Clear local license activation."""
    state = {
        "license_key": "",
        "hwid": get_machine_hwid(),
        "is_active": False,
        "customer_name": "",
        "plan_type": "none",
        "expires_at": None,
        "credits_remaining": None,
        "last_checked_at": None,
        "status_message": "Đã hủy kích hoạt bản quyền.",
    }
    save_local_license(state)


def is_license_valid() -> tuple[bool, str]:
    """Check if local license is active and valid without consuming usage credit."""
    cfg = load_server_config()
    if not cfg.get("supabase_url") or not cfg.get("supabase_key"):
        return True, "Chưa bật cấu hình máy chủ kiểm soát."

    current = load_local_license()
    key = current.get("license_key", "").strip()
    if not key or not current.get("is_active"):
        return False, "Vui lòng kích hoạt bản quyền để sử dụng tính năng này."

    expires_at = current.get("expires_at")
    if expires_at:
        try:
            exp_clean = str(expires_at).replace("Z", "+00:00")
            exp_dt = datetime.fromisoformat(exp_clean)
            if exp_dt.tzinfo is None:
                exp_dt = exp_dt.replace(tzinfo=timezone.utc)
            if datetime.now(timezone.utc) > exp_dt:
                current["is_active"] = False
                current["status_message"] = "Bản quyền đã hết hạn."
                save_local_license(current)
                return False, "Bản quyền đã hết hạn. Vui lòng gia hạn thêm."
        except Exception:
            pass

    credits = current.get("credits_remaining")
    if credits is not None and int(credits) <= 0:
        return False, "Bạn đã hết số lượt xử lý video. Vui lòng nạp thêm lượt."

    return True, "Hợp lệ."


def consume_usage_credit() -> tuple[bool, str]:
    """Deduct 1 credit or verify active subscription before heavy video processing.
    
    Returns (allowed: bool, message: str).
    """
    cfg = load_server_config()
    if not cfg.get("supabase_url") or not cfg.get("supabase_key"):
        # If server is not yet configured by the owner, do not block local developer workflows
        return True, "Chưa bật cấu hình máy chủ kiểm soát."

    current = load_local_license()
    key = current.get("license_key", "").strip()
    if not key or not current.get("is_active"):
        return False, "Vui lòng kích hoạt bản quyền trước khi xử lý hoặc xuất video."

    hwid = get_machine_hwid()
    resp = call_rpc("consume_credit", {"p_key": key, "p_hwid": hwid})
    if resp.get("success"):
        new_credits = resp.get("credits_left")
        if new_credits is not None:
            current["credits_remaining"] = new_credits
            save_local_license(current)
        return True, "Hợp lệ."

    err_msg = resp.get("message") or "Không đủ điều kiện bản quyền để thực hiện."
    current["is_active"] = False
    current["status_message"] = err_msg
    save_local_license(current)
    return False, err_msg
