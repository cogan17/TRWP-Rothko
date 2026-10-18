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
