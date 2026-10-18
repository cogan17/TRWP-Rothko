# Rothko stage 76 — direct dependency and probe audit (HOLD)

Source-only inspection at branch `fix/metadata-f2fs`; no checkout or compile.

## Direct Soong declarations
- `experiments/weaver-aidl/Android.bp`: `cc_binary` named `rothko_weaver_aidl_link_probe`, `recovery_available: true`, `installable: false`.
- Explicit `shared_libs`: `android.hardware.weaver-V2-ndk` and `libbinder_ndk`.
- `LinkProbe.cpp` includes `WeaverAidl.cpp` directly; its `used, retain` member-function pointer is intended to retain `WeaverAidl::Verify` for link inspection. Its `main()` calls Connect and GetConfig, but the binary is **never** to be executed.
- The opt-in `cc_library_static` is a separate compile-only probe, not evidence that the executable's final link succeeds.

## Workspace-only patch
- `hardware/interfaces/weaver/aidl/Android.bp`: `recovery_available: true` on Weaver AIDL interface.
- `device/xiaomi/rothko/AndroidProducts.mk`: explicit `twrp_rothko-ap2a-eng` lunch choice.
- `device/xiaomi/rothko/BoardConfig.mk`: `ALLOW_MISSING_DEPENDENCIES := false`.
- Patch remains unapplied. No production changes.

## Unproven transitive graph
Direct declarations are not the complete closure. Generated AIDL NDK modules, Binder, libc/libm/libdl, Soong toolchain and host build prerequisites may pull in other modules; exact variants and graph edges must come from Soong on a consistent checkout, not a guessed project list. Do not treat selective `repo sync` as sufficient or a successful parse as a link success.

## Free-runner capacity and next gate
Previously measured 85.80 GiB free on the standard runner. No verified total for the source closure, Git metadata or outputs. Do not sync all 658 projects, trigger the known-insufficient 250 GiB gate, or rerun green capacity preflight. First obtain a defensible storage budget and a reviewed dependency closure; if infeasible, retain HOLD rather than weaken missing-dependency checks.

PR #2 remains Draft/HOLD. No Actions, new PR, image, merge, flash, runtime test or compilation in this stage.
