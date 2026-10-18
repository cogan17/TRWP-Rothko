# Weaver AIDL prototype (HOLD)

This directory is an isolated source prototype for Rothko Android 16. It is **not** part of the recovery build: an opt-in `Android.bp` compile-probe target (not selected by product), no changes to upstream `system/vold`, and no runtime testing.

Device evidence: Android registers `android.hardware.weaver.IWeaver/default` and the active user's synthetic-password directory contains both `.weaver` and `.secdis` files. Neither observation establishes which credential handle is active in recovery or guarantees a service will start in recovery.

## Validation gates before integration

1. Confirm `android.hardware.weaver-V2-ndk` exists in the exact TeamWin build graph and validate C++ compilation (especially generated AIDL enum/constant types and binder status APIs).
2. Check device HAL interface version and service lifecycle in recovery, not only Android runtime.
3. Review handling of incorrect keys, throttling, timeout and binder service-specific errors. Do not automatically retry credentials or log secrets.
4. Add isolated unit tests with a fake AIDL service; preserve existing HIDL path until tested.
5. Independently audit Gatekeeper AIDL and Keystore2 initialization.
6. Require approved build, image inspection, and on-device recovery validation before merge/flash.

PR #2 remains Draft/HOLD. Do not run Actions, build, merge or flash on this prototype alone.

## Source audit — stage 53

- Confirmed TeamWin `android_system_vold/Android.bp`: `libvold` compiles `Weaver1.cpp` and links `android.hardware.weaver@1.0`; it does **not** yet link `android.hardware.weaver-V2-ndk`.
- Confirmed TeamWin `android_hardware_interfaces` branch `android-14.1` contains frozen Weaver AIDL v2. Generated NDK module name must still be validated by an actual Soong build.
- The standalone adapter now has an opt-in `rothko_weaver_aidl_probe` Android.bp target, but no build has run, so C++ API compatibility is **unverified**. Do not claim compilation success.
- Android runtime evidence of AIDL Weaver does not prove the NXP HAL binary and dependencies are present or startable in recovery.
- Before integrating, verify Binder error mapping, AIDL v2 header types, read response validation, service lifecycle and credential throttling. No automatic retries.
- Integration requires changing the selected TeamWin vold source/build graph or carrying a carefully isolated override; merely placing a .cpp file in the device tree does not activate it.

Status: SOURCE PROTOTYPE ONLY. Draft PR #2 HOLD. No build, Actions, flashing or merge.

## Stage 54 compile probe

The isolated `Android.bp` target depends on `android.hardware.weaver-V2-ndk` and `libbinder_ndk`. Its module is **not** installed into recovery or referenced by product packages. It will only be useful when the experimental directory is available to Soong in the build workspace; the current device repository alone does not establish that. In a correctly configured build environment, invoke `m rothko_weaver_aidl_probe` only after owner approval. This is not a substitute for recovery runtime HAL verification.

## Stage 55 — source guardrails

Run `python3 experiments/weaver-aidl/audit_source.py` from the repository checkout for a read-only source contract check. This script is intentionally **not** a compiler, Soong dependency resolver, unit test, or runtime proof. **Important:** `BoardConfig.mk` sets `ALLOW_MISSING_DEPENDENCIES := true`; do not interpret a green overall build as proof that Weaver AIDL was compiled and linked. Verify the probe's compile and link actions and ensure missing dependencies are not silently accepted. No Actions or flashing authorized.


## Stage 58 — AIDL response and Binder audit (source-only)

- NDK AIDL `byte[]` uses `std::vector<int8_t>`. Stage 57 converts the caller's unsigned key bytes to a signed AIDL vector before `read`. The response `value` can be copied into the unsigned output vector using iterator-based `assign` (integer conversion preserves the low eight bits); no additional conversion is necessary.
- `getExceptionCode() == EX_SERVICE_SPECIFIC` is checked before `getServiceSpecificError()`; known `STATUS_INCORRECT_KEY` and `STATUS_THROTTLE` are handled. Unknown service-specific and transport errors remain `kFailed`, a conservative failure. Actual generated constant names and binder status API compatibility still require compilation.
- A positive response timeout is treated as `kThrottled` even with an OK status. A negative timeout cannot yield success because the OK branch requires `response.timeout == 0`. The adapter performs no automatic retries and never calls `write`.
- Do not mistake string-based source checks for behavioral unit tests. The current 14-check audit script has not been executed in a checked-out tree; generated AIDL header compatibility and service startup in recovery remain unverified.

**Stage 59 next:** check whether the selected Weaver AIDL interface and generated NDK library can produce a recovery-compatible variant, and review exact `Android.bp` dependency linkage. Preserve isolation and Draft PR #2 HOLD; no Actions/build/flash/merge without approval.


## Stage 59 — recovery Soong variant audit (source-only)

Inspected exact upstream `TeamWin/android_hardware_interfaces` branch `android-14.1`, `weaver/aidl/Android.bp` and `IWeaver.aidl`:

- `aidl_interface { name: "android.hardware.weaver", vendor_available: true, versions_with_info: ["1", "2"], frozen: true }`. The NDK backend is not explicitly disabled, but actual generated module `android.hardware.weaver-V2-ndk` and its availability in the selected Soong graph are **not yet verified**.
- Crucially, upstream Weaver `aidl_interface` does **not** explicitly set `recovery_available: true`. `vendor_available: true` does **not** prove that the generated NDK library has a recovery variant. The probe currently requests `recovery_available: true`; this is a **potential variant/dependency mismatch**, not a proven compile failure.
- Do **not** silently remove the probe's recovery variant or force dependency allowances to green: the eventual adapter must actually work in recovery. Check the generated dependency variants and their transitive dependencies in a real, authorized Soong compile before changing integration.
- `IWeaver.aidl` defines `STATUS_FAILED=1`, `STATUS_INCORRECT_KEY=2`, `STATUS_THROTTLE=3`, with `read(in int slotId, in byte[] key)`. The adapter's named exception cases align with source; generated C++ header symbols remain uncompiled.
- Existing `ALLOW_MISSING_DEPENDENCIES := true` makes build success insufficient by itself; require evidence that the probe was actually compiled and linked.

**Stage 60 next:** investigate source-level recovery variant strategies (upstream interface support vs correctly scoped build-only probe) without changing production vold or adding a fake-success fallback. Draft PR #2 HOLD; no build/Actions/flash/merge.


## Stage 60 — recovery variant decision (source-only)

Decision: **keep the prototype isolated and keep `recovery_available: true` on the opt-in probe**. Do not mask an unresolved recovery dependency by changing it to a system-only probe and claiming the recovery target is supported.

Verified upstream `weaver/aidl/Android.bp` only declares `vendor_available: true` and frozen versions 1/2; it does **not** explicitly declare `recovery_available: true`. This is an unresolved compatibility gate, not proof of failure: the generated NDK module's actual variants must be inspected in the exact Soong tree. Upstream `WeaverReadResponse.aidl` confirms `long timeout`, `byte[] value`, and `WeaverReadStatus status`; the documented timeout range is nonnegative and less than INT_MAX. Our adapter conservatively refuses success for any nonzero timeout, including negative values.

### Required evidence before production integration

1. In an approved, matching TWRP source checkout, inspect generated Soong module variants for `android.hardware.weaver-V2-ndk` and `libbinder_ndk`, including recovery availability and transitive dependencies.
2. Build **only the explicitly opted-in probe** when approved, inspect its compile command, and fail on any missing or stubbed dependency despite `ALLOW_MISSING_DEPENDENCIES := true`.
3. If a recovery variant is absent, consider an isolated, reviewed upstream interface build change or a compatible recovery-specific build path; do not invent an NDK HAL binary or enable blanket missing dependencies as a workaround.
4. Independently establish NXP Weaver service registration, executable/library presence and init lifecycle in the *built recovery ramdisk* before integrating with vold.
5. Preserve the existing HIDL implementation until an AIDL replacement is compiled and runtime-validated. No Weaver slot writes, no credential retries, no log secrets.

**Stage 61 next:** inspect whether the probe's current `cc_library_static` shared-library declarations are appropriate for an opt-in compile-only target, and document the precise compile/link evidence required. No Actions/build/flash/merge; Draft PR #2 HOLD.
