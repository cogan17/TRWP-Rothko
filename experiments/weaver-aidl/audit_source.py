#!/usr/bin/env python3
"""Read-only, source-level guardrails; NOT a compiler or runtime test."""
from pathlib import Path
import re
import sys

base = Path(__file__).resolve().parent
src = (base / "WeaverAidl.cpp").read_text()
bp = (base / "Android.bp").read_text()
probe = (base / "LinkProbe.cpp").read_text()
probe_targets = ("rothko_weaver_aidl_probe", "rothko_weaver_aidl_link_probe")
# Inspect this device tree's Make inputs, not explanatory Android.bp comments.
# This is a conservative text scan, not evaluation of inherited product files.
make_sources = "\n".join(
    re.sub(r"(?m)#.*$", "", path.read_text())
    for path in sorted(base.parents[1].rglob("*.mk"))
)
checks = {
    "AIDL v2 Soong dependency": '"android.hardware.weaver-V2-ndk"' in bp,
    "NDK Binder dependency": '"libbinder_ndk"' in bp,
    "opt-in static library": 'name: "rothko_weaver_aidl_probe"' in bp and "cc_library_static" in bp,
    "no probe references in device makefiles": not any(
        re.search(rf"\b{re.escape(target)}\b", make_sources)
        for target in probe_targets
    ),
    "no Weaver write call": "service_->write(" not in src,
    "nonblocking service discovery": "AServiceManager_checkService(" in src,
    "null binder guard": "if (!binder.get()) return false;" in src,
    "slot range validation": "slot < 0 || slot >= config.slots" in src,
    "key length validation": "key.size() != static_cast<size_t>(config.keySize)" in src,
    "AIDL signed byte conversion": "std::vector<int8_t> aidl_key(key.begin(), key.end())" in src and "service_->read(slot, aidl_key, &response)" in src,
    "throttle status handled": "WeaverReadStatus::THROTTLE" in src,
    "positive timeout hard stop": "if (result.timeout_ms > 0)" in src,
    "incorrect key handled": "WeaverReadStatus::INCORRECT_KEY" in src,
    "opt-in non-installable link probe": 'name: "rothko_weaver_aidl_link_probe"' in bp and "installable: false" in bp,
    "Verify symbol referenced without invocation": "&rothko::crypto::WeaverAidl::Verify" in probe and "adapter.Verify(" not in probe and "verify_reference" in probe,
    "Verify reference emitted and retained": "__attribute__((used, retain))" in probe and "const VerifyMethod verify_reference = &rothko::crypto::WeaverAidl::Verify;" in probe and probe.index("const VerifyMethod verify_reference") < probe.index("int main()"),
    "unsupported retain attribute rejected": "#if !__has_attribute(retain)" in probe and '#error "The link probe requires compiler support for the retain attribute."' in probe,
    "payload length checked": "response.value.size() == static_cast<size_t>(config.valueSize)" in src,
}
for label, ok in checks.items():
    print(f"{'PASS' if ok else 'FAIL'}: {label}")
if not all(checks.values()):
    sys.exit(1)
print("PASS: source guardrails only; compilation and runtime remain UNVERIFIED")
