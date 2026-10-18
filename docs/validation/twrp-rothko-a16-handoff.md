# TWRP Rothko Android 16 — development handoff

Checkpoint: 2026-10-18, stage 32. Branch: `fix/metadata-f2fs`; base: `twrp-14.1_a16`.

## Tracking
- Issue: https://github.com/cogan17/TRWP-Rothko/issues/1
- Draft PR (HOLD): https://github.com/cogan17/TRWP-Rothko/pull/2
- Last audited code commit: `3f1d281acc7636e0a2d71d3ee4144b21ebaecdca` (8 commits ahead of base, 6 changed files before this documentation commit).
- GitHub reports PR mergeable/clean, but no successful CI/build or runtime validation. Do not squash merge yet.

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

## Next task — stage 33
Audit how `recovery/root` is packaged into vendor_boot (ramdisk placement, .rc import, manifest fragments, service executable paths) and whether TWRP core starts security HALs. Cross-check module loading and FBE prerequisites. Make minimal source-only fix only if provably needed; otherwise record unresolved verification gates. Then arrange a real TWRP Android 16 build in an appropriate source tree, only with owner's authorization.

## Guardrails
- Keep default branch untouched; one Draft PR #2; no duplicate PRs/Actions.
- No build, flash, merge or squash without explicit approval and successful validation. No forced-green CI.
- UFS disk /dev/block/sdc mapped on actual device, but ioctl and partial-failure safety unverified; never perform live slot writes for diagnosis.
- Preserve changes; avoid repeated checks and unnecessary workflow reruns.
