#!/usr/bin/env python3
"""Offline source-only audit of Rothko Weaver probe. No Android checkout required."""
from pathlib import Path
import re
import sys

root = Path(__file__).resolve().parents[2]
bp = (root / "experiments/weaver-aidl/Android.bp").read_text()
src = (root / "experiments/weaver-aidl/WeaverAidl.cpp").read_text()
link = (root / "experiments/weaver-aidl/LinkProbe.cpp").read_text()
patch = (root / "experiments/weaver-aidl/validation-workspace.patch").read_text()
checks = {
    "probe binary declared": bool(re.search(r'cc_binary\s*\{[^}]*name:\s*"rothko_weaver_aidl_link_probe"', bp, re.S)),
    "weaver v2 ndk declared": '"android.hardware.weaver-V2-ndk"' in bp,
    "binder ndk declared": '"libbinder_ndk"' in bp,
    "recovery variant declared": bp.count("recovery_available: true") >= 2,
    "probe noninstallable": "installable: false" in bp,
    "AIDL interface referenced": "#include <aidl/android/hardware/weaver/IWeaver.h>" in src,
    "Binder service nonblocking lookup": "AServiceManager_checkService" in src,
    "Verify retained reference": "const VerifyMethod verify_reference" in link and "__attribute__((used, retain))" in link,
    "patch requires strict dependencies": "+ALLOW_MISSING_DEPENDENCIES := false" in patch,
    "patch requests recovery AIDL": "+    recovery_available: true" in patch,
    "patch selects ap2a": "+    twrp_rothko-ap2a-eng" in patch,
}
for name, ok in checks.items():
    print(f'{"PASS" if ok else "FAIL"}: {name}')
print("NOTE: Static source checks only; no transitive graph, compilation or link validated.")
sys.exit(0 if all(checks.values()) else 1)
