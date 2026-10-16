"""Isolate test imports/QML singleton startup from the user's real runtime.

Some QML component tests instantiate the registered controller while pumping
Qt events. Isolation must be selected before any TruongNgocHoa module is imported,
not only patched inside a test body.
"""

import os
import tempfile
from pathlib import Path

_test_root = Path(__file__).resolve().parents[1] / "build" / "test-runtime"
_test_root.mkdir(parents=True, exist_ok=True)
_test_runtime = tempfile.TemporaryDirectory(prefix="truongngochoa-pytest-runtime-", dir=_test_root, ignore_cleanup_errors=True)
os.environ["TRUONGNGOCHOA_SMOKE_TEST"] = "1"  # .env cannot override the test roots.
os.environ["TRUONGNGOCHOA_HOME"] = _test_runtime.name
os.environ["RUNTIME_DATA_DIR"] = os.path.join(_test_runtime.name, "data")
os.environ["TRUONGNGOCHOA_RESOURCE_ROOT"] = os.path.join(_test_runtime.name, "resources")
os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")
