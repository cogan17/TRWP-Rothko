#!/usr/bin/env python3
"""Read-only, source-level guardrails; NOT a compiler or runtime test."""
from pathlib import Path
import sys

base = Path(__file__).resolve().parent
src = (base / "WeaverAidl.cpp").read_text()
bp = (base / "Android.bp").read_text()
checks = {
    "AIDL v2 Soong dependency": '"android.hardware.weaver-V2-ndk"' in bp,
    "NDK Binder dependency": '"libbinder_ndk"' in bp,
    "opt-in static library": 'name: "rothko_weaver_aidl_probe"' in bp and "cc_library_static" in bp,
    "no product installation": "PRODUCT_PACKAGES" not in bp,
    "no Weaver write call": "service_->write(" not in src,
    "nonblocking service discovery": "AServiceManager_checkService(" in src,
    "null binder guard": "if (!binder.get()) return false;" in src,
    "slot range validation": "slot < 0 || slot >= config.slots" in src,
    "key length validation": "key.size() != static_cast<size_t>(config.keySize)" in src,
    "throttle status handled": "WeaverReadStatus::THROTTLE" in src,
    "positive timeout hard stop": "if (result.timeout_ms > 0)" in src,
    "incorrect key handled": "WeaverReadStatus::INCORRECT_KEY" in src,
    "payload length checked": "response.value.size() == static_cast<size_t>(config.valueSize)" in src,
}
for label, ok in checks.items():
    print(f"{'PASS' if ok else 'FAIL'}: {label}")
if not all(checks.values()):
    sys.exit(1)
print("PASS: source guardrails only; compilation and runtime remain UNVERIFIED")
