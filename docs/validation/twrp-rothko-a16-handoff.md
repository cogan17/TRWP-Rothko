# TWRP Rothko Android 16 — development handoff

Checkpoint: 2026-10-18, stage 38. Branch: `fix/metadata-f2fs`; base: `twrp-14.1_a16`.

Resumed from stage-37 commit `5df0af40b9c0978feb5da959b22196cb20f95f77`.
Detailed latest audit: [stage 38 packaging, init, and size evidence](twrp-rothko-stage38-packaging.md).

## Tracking
- Issue: https://github.com/cogan17/TRWP-Rothko/issues/1
- Draft PR (HOLD): https://github.com/cogan17/TRWP-Rothko/pull/2
- Last audited code commit: `3f1d281acc7636e0a2d71d3ee4144b21ebaecdca` (8 commits ahead of base, 6 changed files before this documentation commit).
- PR remains open and draft; mergeability is not a build or runtime validation result. Do not squash merge yet.

## Completed source changes
1. `/metadata` ext4 -> f2fs in recovery.fstab and twrp.flags.
2. Removed duplicate `mtk_dramc.ko` from modules.load and modules.load.recovery.
3. Corrected init_boot label; removed flashimg option from sensitive partition flags.
4. BootControl slot validation and clearer partial-failure/UFS ioctl diagnostics.
5. Read-only module-list audit: 214 and 231 entries, respectively; no duplicate or missing .ko files in lists; runtime dependencies unverified.

## Stage 29–32 audit
- `AndroidProducts.mk` declares `twrp_rothko-{user,userdebug,eng}`; `twrp_rothko.mk` inherits device.mk.
- `device.mk` inherits `vendor/twrp/config/common.mk`; `BoardConfig.mk` selects recovery resources in vendor_boot, no separate recovery partition.
- KeyMint AIDL v3, Gatekeeper AIDL v1, SecureClock and SharedSecret manifest fragments exist. Prebuilt KeyMint/Gatekeeper/tee-supplicant, MiTEE helper, two .ta files exist in recovery/root.
- Service .rc files declare `class none` for KeyMint, Gatekeeper, tee-supplicant. No explicit `start` found in device-tree .rc; `mitee-helper` starts on fs. Framework/TWRP startup behavior not yet audited, so do NOT add speculative service start commands.
- `setprop vendor.teefs_state ready` is present in init.recovery.mt6989.rc, but real readiness not verified.
- README asserts Android 16 decryption works; not verified for the changes in this branch.
- No .github/workflows found in branch; no associated PR-triggered workflow runs or commit statuses. No real build completed.

## Previously planned task — stage 33 (audited)
Audit how `recovery/root` is packaged into vendor_boot (ramdisk placement, .rc import, manifest fragments, service executable paths) and whether TWRP core starts security HALs. Cross-check module loading and FBE prerequisites. Make minimal source-only fix only if provably needed; otherwise record unresolved verification gates. Then arrange a real TWRP Android 16 build in an appropriate source tree, only with owner's authorization.

## Guardrails
- Keep default branch untouched; one Draft PR #2; no duplicate PRs/Actions.
- No build, flash, merge or squash without explicit approval and successful validation. No forced-green CI.
- UFS disk /dev/block/sdc mapped on actual device, but ioctl and partial-failure safety unverified; never perform live slot writes for diagnosis.
- Preserve changes; avoid repeated checks and unnecessary workflow reruns.

## Stage 33–37 follow-up (2026-10-18)
- Stage 33: device tree alone does not prove `recovery/root` files are installed into the final vendor_boot; inspect built ramdisk.
- Stage 34: upstream `TeamWin/android_bootable_recovery` and `TeamWin/android_build` have `android-14.1` branches; `minimal-manifest-twrp/platform_manifest_twrp_aosp` has `twrp-14.1`.
- Stage 35: `twrp-14.1` manifest defaults to AOSP `android-14.0.0_r67`; README specifies `mka vendorbootimage` for vendor_boot recovery. Android 16 FBE compatibility remains unproven.
- Stage 36: upstream `TeamWin/android_build` `android-14.1`, `core/Makefile` lines ~1593–1603, includes `TARGET_RECOVERY_ROOT_OUT` in vendor ramdisk when `BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT=true` and separate recovery fragment not enabled. Lines ~338–345 describe separate fragment when enabled. Build output still needed to verify prebuilt paths and init imports.
- Stage 37: same upstream `core/Makefile` lines ~273–287 does not produce standalone recovery.img when resources move to vendor_boot. Branch has ~350 blobs under `recovery/root`, including 237 .ko. `BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE=67108864` (64 MiB); final compressed image size unknown.

## Previously planned task — stage 38 (audited)
Trace exact `recovery/root` file installation into `TARGET_RECOVERY_ROOT_OUT` in TeamWin/AOSP build rules; confirm whether a `TARGET_RECOVERY_DEVICE_DIR`/PRODUCT_COPY_FILES mapping is required, and inspect service .rc import/manifest placement. If available, estimate vendor_boot payload size from Git blob metadata without conflating raw and compressed sizes. No speculative code changes; real build and inspection only with owner approval.

## Stage 38 follow-up (2026-10-18)
- Pinned TeamWin build rules select `$(TARGET_DEVICE_DIR)/recovery/root` automatically and copy it into recovery staging before vendor ramdisk assembly. The optional override is `TARGET_RECOVERY_DEVICE_DIRS` (plural). No extra copy mapping is justified for this tree.
- Recovery's main init script installs at `/system/etc/init/hw/init.rc`. The inspected init scans `/system/etc/init` and `/vendor/etc/init` when `ro.boot.init_rc` is empty. The hardware import requires runtime `ro.hardware=mt6989`; that value remains unverified.
- Six service executables are present in the overlay; `mtk_plpath_utils` is supplied by a requested recovery source module. Git mode 100644 alone does not prove bad final executable modes because mkbootfs applies fs_config. Final cpio modes and ELF dependency resolution remain open.
- Vendor manifest/fragments are in the expected libvintf paths; all nine XML files parse. VINTF semantic validation and service registration have not been performed.
- Exactly 350 overlay files total 54,587,758 raw bytes (52.059 MiB), including 237 kernel modules. Separate DTB: 444,463 bytes. Raw overlay plus DTB is 52.483 MiB; this is not compressed image size or usable headroom against the 64 MiB partition. Generated recovery content and AVB overhead remain unmeasured.
- Service discovery is traced, but startup/readiness of the `class none` security services remains unresolved. No speculative start commands, mode changes, or module pruning were made.

## Next task — stage 39
Trace actual KeyMint, Gatekeeper, and tee-supplicant startup/readiness in the manifest-selected TWRP/vold sources and available prebuilt helper evidence. Record exact triggers or unresolved gaps before proposing any service-start change. Preserve HOLD; a real build, final ramdisk/VINTF/ELF/size inspection, and device validation remain separate gates requiring the existing authorization process.

## State after this checkpoint
Draft PR #2 and Issue #1 remain the single tracking artifacts; HOLD merge and squash until real build/runtime verification. No Actions, builds or flashing executed in stages 33–38. Stage 38 changes only this handoff and its supporting audit document.
