import json
import pytest
from unittest.mock import patch, MagicMock

from truongngochoa.services import license_manager
from truongngochoa.desktop.license_controller import LicenseController


def test_hwid_generation():
    hwid = license_manager.get_machine_hwid()
    assert isinstance(hwid, str)
    assert len(hwid) == 20
    assert hwid.isupper()
    # Ensure idempotency
    assert license_manager.get_machine_hwid() == hwid


def test_local_license_persistence(tmp_path, monkeypatch):
    test_license_file = tmp_path / "license.json"
    monkeypatch.setattr(license_manager, "LICENSE_FILE", test_license_file)

    initial = license_manager.load_local_license()
    assert initial["is_active"] is False
    assert initial["license_key"] == ""

    initial["license_key"] = "TEST-KEY-123"
    initial["is_active"] = True
    initial["credits_remaining"] = 42
    license_manager.save_local_license(initial)

    loaded = license_manager.load_local_license()
    assert loaded["license_key"] == "TEST-KEY-123"
    assert loaded["is_active"] is True
    assert loaded["credits_remaining"] == 42

    license_manager.deactivate_license()
    deactivated = license_manager.load_local_license()
    assert deactivated["is_active"] is False
    assert deactivated["license_key"] == ""


def test_server_config_persistence(tmp_path, monkeypatch):
    test_cfg_file = tmp_path / "license-server.json"
    monkeypatch.setattr(license_manager, "SERVER_CONFIG_FILE", test_cfg_file)

    license_manager.save_server_config("https://sample.supabase.co/", "anon-key-abc")
    cfg = license_manager.load_server_config()
    assert cfg["supabase_url"] == "https://sample.supabase.co"
    assert cfg["supabase_key"] == "anon-key-abc"


def test_activate_license_mocked_success(tmp_path, monkeypatch):
    monkeypatch.setattr(license_manager, "LICENSE_FILE", tmp_path / "license.json")
    monkeypatch.setattr(license_manager, "SERVER_CONFIG_FILE", tmp_path / "license-server.json")

    mock_resp = {
        "valid": True,
        "customer_name": "Test User",
        "plan_type": "monthly",
        "expires_at": "2026-12-31T23:59:59Z",
        "credits_remaining": None,
    }

    with patch.object(license_manager, "call_rpc", return_value=mock_resp):
        res = license_manager.activate_license("TNH-VALID-KEY")
        assert res["valid"] is True
        assert res["state"]["is_active"] is True
        assert res["state"]["customer_name"] == "Test User"
        assert res["state"]["plan_type"] == "monthly"


def test_consume_usage_credit(tmp_path, monkeypatch):
    monkeypatch.setattr(license_manager, "LICENSE_FILE", tmp_path / "license.json")
    monkeypatch.setattr(license_manager, "SERVER_CONFIG_FILE", tmp_path / "license-server.json")

    # When server config is not set, allow execution (fallback for dev)
    allowed, msg = license_manager.consume_usage_credit()
    assert allowed is True

    # When server config is configured
    license_manager.save_server_config("https://sample.supabase.co", "key-123")

    # Without active license
    allowed, msg = license_manager.consume_usage_credit()
    assert allowed is False

    # Activate a key with credits
    active_state = {
        "license_key": "TNH-CREDIT-KEY",
        "hwid": license_manager.get_machine_hwid(),
        "is_active": True,
        "credits_remaining": 10,
        "plan_type": "credits",
    }
    license_manager.save_local_license(active_state)

    with patch.object(license_manager, "call_rpc", return_value={"success": True, "credits_left": 9}):
        allowed, msg = license_manager.consume_usage_credit()
        assert allowed is True
        current = license_manager.load_local_license()
        assert current["credits_remaining"] == 9


def test_license_controller_bindings(tmp_path, monkeypatch):
    monkeypatch.setattr(license_manager, "LICENSE_FILE", tmp_path / "license.json")
    monkeypatch.setattr(license_manager, "SERVER_CONFIG_FILE", tmp_path / "license-server.json")

    mock_host = MagicMock()
    ctrl = LicenseController(mock_host)

    assert ctrl.licenseActive is False
    assert len(ctrl.licenseHwid) == 20

    ctrl.saveServerConfig("https://example.supabase.co", "anon-key")
    assert ctrl.serverConfigured is True
    assert ctrl.supabaseUrl == "https://example.supabase.co"
    assert ctrl.supabaseKey == "anon-key"
