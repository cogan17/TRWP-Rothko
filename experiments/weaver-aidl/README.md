# Weaver AIDL prototype (HOLD)

This directory is an isolated source prototype for Rothko Android 16. It is **not** part of the recovery build: no `Android.bp` integration, no changes to upstream `system/vold`, and no runtime testing.

Device evidence: Android registers `android.hardware.weaver.IWeaver/default` and the active user's synthetic-password directory contains both `.weaver` and `.secdis` files. Neither observation establishes which credential handle is active in recovery or guarantees a service will start in recovery.

## Validation gates before integration

1. Confirm `android.hardware.weaver-V2-ndk` exists in the exact TeamWin build graph and validate C++ compilation (especially generated AIDL enum/constant types and binder status APIs).
2. Check device HAL interface version and service lifecycle in recovery, not only Android runtime.
3. Review handling of incorrect keys, throttling, timeout and binder service-specific errors. Do not automatically retry credentials or log secrets.
4. Add isolated unit tests with a fake AIDL service; preserve existing HIDL path until tested.
5. Independently audit Gatekeeper AIDL and Keystore2 initialization.
6. Require approved build, image inspection, and on-device recovery validation before merge/flash.

PR #2 remains Draft/HOLD. Do not run Actions, build, merge or flash on this prototype alone.
