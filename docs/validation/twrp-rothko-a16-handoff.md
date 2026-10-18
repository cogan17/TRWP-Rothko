# TWRP Rothko Android 16 — development handoff

Checkpoint: 2026-10-18, stage 65. Branch: `fix/metadata-f2fs`; base: `twrp-14.1_a16`.

Resumed from stage-64 commit `c471f27f7811c0e96bca5a824f7281dd1a4fdabe`.
**Current result:** [stage 65 build-validation plan](twrp-rothko-stage65-build-plan.md),
eleven selective source pins, and a validation-only workspace patch. XML structure
and patch applicability checked locally. Stage 64's **18/18** source checks and
three regression scenarios remain the last adapter audit; they were not repeated.
Compiler prebuilt availability, compilation, optimized-link retention, recovery
dependency resolution, and FBE remain unverified. Draft PR #2 stays **HOLD**.
**Resume:** the stage-66 task at the end of this file. Earlier sections are
historical evidence; their old "next task" instructions are superseded.
Packaging background: [stage 38 packaging, init, and size evidence](twrp-rothko-stage38-packaging.md).

## Tracking
- Issue: https://github.com/cogan17/TRWP-Rothko/issues/1
- Draft PR (HOLD): https://github.com/cogan17/TRWP-Rothko/pull/2
- Last adapter code/audit commit: `c471f27f7811c0e96bca5a824f7281dd1a4fdabe`. The original F2FS/boot-control source audit used `3f1d281acc7636e0a2d71d3ee4144b21ebaecdca`.
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


## Checkpoint update — stage 39–56 (2026-10-18)

**This section supersedes the older "Next task — stage 39" above.** Resume from stage 57. Do not repeat successful source discovery or rooted-device checks.

### Security/FBE investigation (stages 39–47)
- Manifest-selected upstream: TeamWin `android_system_vold`, `android_bootable_recovery`, `android_system_core` at `android-14.1`; TeamWin `android_hardware_interfaces` at `android-14.1`.
- TWRP vold `Decrypt.cpp` detects `.weaver` synthetic-password records and calls HIDL `android.hardware.weaver@1.0` via `Weaver1.cpp`; its Gatekeeper paths also use HIDL 1.0. Keystore2 code waits for its AIDL service. Android 16 compatibility is NOT established.
- Actual rooted Rothko Android registers **AIDL** Weaver `android.hardware.weaver.IWeaver/default`, Gatekeeper `android.hardware.gatekeeper.IGatekeeper/default`, KeyMint `android.hardware.security.keymint.IKeyMintDevice/default`, and Keystore2. Vendor manifest names Weaver NXP and Gatekeeper/KeyMint MiTEE services; relevant Android processes were running.
- User's read-only Termux screenshot shows both `*.weaver` and `*.secdis` under user 0's `spblob`; active credential handle/path remains unknown. Do not request or publish secret handles, PINs or credential data.
- Weaver NXP HAL and dependencies have **not** been proven present/startable in recovery. Do not invent `.rc` start triggers or assume Android service availability transfers to recovery.

### Weaver AIDL source prototype (stages 48–56)
- TeamWin `android_hardware_interfaces` branch `android-14.1` contains frozen Weaver AIDL v2, with `IWeaver.getConfig/read/write` and `WeaverReadResponse.status/timeout/value`.
- Existing TeamWin `android_system_vold/Android.bp` compiles `Weaver1.cpp` and links HIDL `android.hardware.weaver@1.0`, **not** Weaver AIDL. No vold integration has been committed.
- Added isolated `experiments/weaver-aidl/WeaverAidl.cpp` (read-only Binder adapter; service lookup, config/key/slot checks, response/error mapping, throttle handling); **not** compiled, installed, linked, or runtime tested.
- Added opt-in `experiments/weaver-aidl/Android.bp` static probe target `rothko_weaver_aidl_probe`, depends on `android.hardware.weaver-V2-ndk` and `libbinder_ndk`; not in `PRODUCT_PACKAGES`. Actual Soong resolution/C++ compile still unverified.
- Added `experiments/weaver-aidl/audit_source.py`, initially 12 source guardrails; stage 56 added positive-timeout hard-stop guardrail (13 total). Prior assistant evaluated the original 12 source predicates as 12/12 true from fetched text, **not** a Python script execution; the 13-check revision has not been run.
- Added `experiments/weaver-aidl/README.md` with HOLD gates. `BoardConfig.mk` sets `ALLOW_MISSING_DEPENDENCIES := true`: beware false confidence from a superficially green build.
- Source changes/commits, chronological: `714a7ece` adapter; `ef72db8d` README; `bbf4dfc9` null Binder guard; `4db058c6` reconnect reset/timeout clamp; `f32e7913` audit doc; `47d386a0` opt-in Android.bp; `83d8181e` README; `19a42124` audit script; `b8d01b63` README; `e72b3cd0` positive-timeout throttle; `cca142c9` audit guardrail. All on `fix/metadata-f2fs`, no production/default branch modifications.
- **Important limitation:** source-level checks and isolated commits do not establish that AIDL-generated C++ headers/constants are correct, that the NXP HAL runs in recovery, or that FBE decrypts. Do not claim build/test success.

### Next task — stage 57
1. Audit source-only C++ API and Binder error handling in `experiments/weaver-aidl/WeaverAidl.cpp`, especially AIDL service-specific error mapping, timeout and value-size validation. Fix only provable defects.
2. Run the 13-check local source audit if a local checkout is available, clearly distinguish this from compiling.
3. Determine minimal safe integration path into manifest-selected TeamWin vold, including licensing and build ownership; preserve HIDL and never write Weaver slots.
4. Before any real build, explicitly verify Soong dependency resolution despite `ALLOW_MISSING_DEPENDENCIES`. A build, Actions, flashing, PR merge or squash require owner authorization.

### State and guardrails
- Repo: `https://github.com/cogan17/TRWP-Rothko`; dev branch `fix/metadata-f2fs`; default `twrp-14.1_a16` untouched.
- Draft PR #2 `https://github.com/cogan17/TRWP-Rothko/pull/2` **HOLD**, Issue #1 remains tracking.
- No Actions, TWRP image build, flashing, merge or runtime validation performed in stages 39–56.
- One checkpoint, no duplicate PRs or needless workflow reruns. Continue with user command **"Lanjutkan"**.


## Checkpoint update — stage 57 (2026-10-18)

**Resume from stage 58.** Stage 57 found a concrete NDK AIDL C++ type mismatch: AIDL `byte[]` maps to `std::vector<int8_t>`, whereas the prototype passed `std::vector<uint8_t>` to `IWeaver::read`. Added a local `std::vector<int8_t> aidl_key(key.begin(), key.end())` conversion before the call. This is source-only; no build was run.

- Commit `640957367dfbb901e35ac49e1a6cf13432765401`: fix signed-byte conversion in `experiments/weaver-aidl/WeaverAidl.cpp`.
- Commit `28f3fdf2791a18608e0bc6eeb19b41a1fad8ada1`: add signed-byte conversion check to `experiments/weaver-aidl/audit_source.py`. Source checks now number **14**; updated script has not been executed.
- The isolated `rothko_weaver_aidl_probe` remains opt-in and uncompiled. Adapter is not linked into TeamWin `libvold`; Weaver NXP HAL availability in recovery remains unverified.
- No Actions, real build, runtime validation, flashing, PR merge or squash. Draft PR #2 stays **HOLD**. Default branch untouched.

### Next task — stage 58
Inspect generated NDK AIDL API signatures and Binder exception/status mapping for further source-level defects, particularly response `std::vector<int8_t>` conversion, exception constants, and correct service-specific error codes. Apply only provable minimal fixes, update source guardrails, and keep the prototype isolated. Do not repeat device diagnostics or previous audit. Any compilation/Actions/flashing requires separate owner authorization under established guardrails.


## Checkpoint update — stages 58–62 (2026-10-18)

**Resume at stage 63.** This section supersedes the older stage 58 task. No previously completed stage needs repeating.

- Stage 58: reviewed Weaver AIDL NDK response conversion, service-specific Binder errors, timeout handling, and fail-closed behavior. Signed `byte[]` response can be copied into unsigned result bytes via iterator `assign`; no code change required. Documentation commit `f6cb2c64a19ebf0b2d84e805b18510dcd03681d1`.
- Stage 59: confirmed TeamWin `android_hardware_interfaces` `android-14.1` Weaver AIDL `Android.bp` has frozen versions 1/2 and `vendor_available: true` but no explicit `recovery_available: true`. Recovery NDK library variant **unverified**. Documentation commit `646885b5c9a04472f7c9f52ca1703949e6a165fa`.
- Stage 60: decided to preserve the opt-in prototype's recovery variant requirement, not silently substitute a system-only build. Actual Soong dependency graph and HAL availability remain open. Documentation commit `90fce05d418e6f3f7a97031832c1d1cf4f16acfd`.
- Stage 61: clarified `cc_library_static` compile/archive cannot establish successful final link, and a default module build may not select the recovery variant. Documentation commit `7edee9c5eb9f7dfb51a45ac6532beb8b8ee1d7ec`.
- Stage 62: added `experiments/weaver-aidl/LinkProbe.cpp` with non-executed entry point that references `Connect()` and `GetConfig()`, commit `aeb735e54ec2b93093f76bce76b2b5815198b270`. Added `cc_binary` opt-in `rothko_weaver_aidl_link_probe` with `recovery_available: true`, `installable: false` and Weaver/Binder shared dependencies, commit `c65f3183e275aa358ec23214dc559b03605ef036`. Documented limitations in commit `a7ed3faec6961468c027754b094b75cbbfaca346`.
- **Limitations:** link probe currently references `Connect` and `GetConfig`, not `Verify`; the latter read-path linker coverage is unproven. Including the adapter `.cpp` directly is temporary probe-only organization. No code is integrated with production `libvold`.
- The 14-check source audit script has not been executed in a checked-out workspace. No TWRP build, link probe build, Actions, image inspection, recovery runtime test, flash, merge or squash has occurred. `ALLOW_MISSING_DEPENDENCIES := true` remains a concern: no false-green claims.
- Repo `https://github.com/cogan17/TRWP-Rothko`, dev branch `fix/metadata-f2fs`, default `twrp-14.1_a16` untouched. Draft PR #2 **HOLD**, Issue #1 tracking.

### Next task — stage 63
Audit the link probe for real linker coverage of the `Verify()` read path without executing credential operations, and add minimal static checks. Avoid production integration, duplicate PRs or speculative HAL startup modifications. Confirm source changes before reporting success; do not build or trigger Actions without explicit authorization.


## Checkpoint update — stage 63 (2026-10-18)

**Resume at stage 64.** The prior checkpoint through stage 62 is retained; do not repeat completed steps.

- Stage 63 changed `experiments/weaver-aidl/LinkProbe.cpp` to retain a pointer-to-member reference to `WeaverAidl::Verify` without calling `Verify` or accessing credentials. Commit `7b13dfd3736372c6ffbfbebe5f49739641c52693`.
- Added two textual predicates to `experiments/weaver-aidl/audit_source.py`, for the non-installable opt-in link probe and non-invoked `Verify` reference. Total **16 source predicates**; not executed in a checkout. Commit `067a54c296d947303c98db56bd153f47eb9a4239`.
- Updated `experiments/weaver-aidl/README.md` documenting scope and limitations. Commit `30d8f91e829cb35915401ab5cb49d4ba5142ac60`.
- The pointer-to-member reference is **not yet proof** that the final optimized link retains the entire `Verify` read path. Compile, symbol inspection, linker map, and recovery dependency resolution remain unverified.
- No Actions, build, linking, runtime tests, flashing, merge, squash, or production `libvold` integration. Default `twrp-14.1_a16` untouched; Draft PR #2 **HOLD**.

### Next task — stage 64
Audit optimization and linker retention semantics of the opt-in link probe, including the volatile pointer-to-member reference. Make only minimal, provable source changes and update source checks as needed. Do not run or install the probe; do not trigger Actions or compilation without explicit owner authorization. Preserve the isolation and production safeguards.

## Checkpoint update — stage 64 (2026-10-18)

- Replaced the local volatile Verify pointer with a namespace-scope constant
  pointer-to-member marked `__attribute__((used, retain))` in `LinkProbe.cpp`.
  `used` requests compiler emission; `retain` requests ELF section retention
  during linker garbage collection. A compiler lacking `retain` is rejected
  explicitly. This is a stronger, documented retention contract; it is **not**
  evidence that the previous volatile implementation actually failed.
- No Verify invocation was added. Existing Connect/GetConfig calls are unchanged;
  the probe remains non-installable and must not be run on a device.
- Actually ran the previous 16-check Python audit in the checkout: **15 PASS,
  1 FAIL**. The failure was a false positive: the Android.bp explanatory comment
  mentions `PRODUCT_PACKAGES`. Replaced that predicate with a conservative scan
  for the two probe module names in this device tree's `.mk` files after stripping
  Make comments. This does not evaluate inherited products or replace Soong.
- Added two retention predicates. Ran the revised audit: **18/18 PASS**.
  Three temporary-fixture regressions also passed: a commented product example
  is accepted; real product references to either probe produce the expected
  isolation failure. `git diff --check` passed.
- Retention rationale and primary compiler/linker references are in
  `experiments/weaver-aidl/README.md`, stage 64. Exact Android compiler/linker
  support and the emitted ELF relocation/link map remain unverified.
- No C++ compilation, link-probe execution, Actions, TWRP image build, runtime
  credential operation, flash, merge, squash, or production source change.
  Default branch untouched; one Draft PR #2 **HOLD**, Issue #1 tracking.

### Next task — stage 65

Prepare one reproducible, narrowly scoped build-validation plan against pinned
TeamWin source revisions: identify the recovery variants of Weaver NDK/Binder,
the exact non-installable probe target and compiler/linker versions, and the
unstripped ELF/relocation/link-map evidence needed for Verify retention. Resolve
source-level planning gaps before requesting approval; do not keep revising the
probe speculatively. A green archive or system variant is insufficient, especially
with `ALLOW_MISSING_DEPENDENCIES := true`. Real compilation/Actions, device tests,
and merge/flash remain separate gates; keep the current HOLD until authorized
validation establishes them.

## Checkpoint update — stage 65 (2026-10-18)

- Added `docs/validation/twrp-rothko-stage65-build-plan.md` with exact source
  identities, target selection, failure criteria, and required ELF/link evidence.
- Added opt-in `experiments/weaver-aidl/validation-pins.xml`: eleven unique
  source paths at full commit IDs. It is explicitly a selective overlay, not a
  complete workspace lock. Full `repo manifest -r` and local diffs are still
  required after source preparation; no full Android workspace was synced here.
- Pinned Soong selects `clang-r510928` / short version 18. Availability and
  actual compiler/linker versions in the selected AOSP snapshot are unverified.
- Pinned Soong names the recovery variant with `.recovery`. The planned single
  target is `rothko_weaver_aidl_link_probe.recovery`; the core target or archive
  is not a substitute. Verbose Ninja arguments are supported by pinned source.
- Traced AIDL `Recovery_available` propagation into generated native libraries;
  Weaver lacks that declaration, while the pinned Binder NDK declares it.
  Pinned envsetup requires a three-part lunch; AOSP release map provides `ap2a`.
- Prepared `experiments/weaver-aidl/validation-workspace.patch` to enable
  Weaver's recovery declaration, use `ap2a` lunch choices, and make missing
  dependencies fail in a disposable validation checkout. It is **not applied**
  to production files or any real Android build workspace.
- Local checks: XML parses with eleven distinct immutable revision entries;
  `git apply --check` passes against the three exact pinned reference files.
  These checks establish neither full repo manifest resolution nor compilation.
- Direct Gitiles reads failed; AOSP tagged source was inspected via mirror,
  with tag objects resolved to exact commits. Primary-remote identity checks
  remain part of workspace preparation; the build overlay keeps AOSP remotes.
- No build, bootstrap/lunch, Actions, image creation, probe execution, credential
  operations, flash, merge, squash, production integration, or new PR.

### Next task — stage 66

Close the source/workspace preflight: establish whether the manifest-selected
Clang prebuilt contains `clang-r510928`; verify the pinned source identities in
a suitable disposable Android workspace and export a complete resolved manifest.
If the toolchain is missing, prepare an explicit, reviewed source/toolchain pin
correction rather than silently swapping compiler versions. Do not repeat the
Verify audit or add speculative probe code. The reviewed stage-65 procedure is
the concrete scope for the separately authorized single recovery probe build;
no image build, runtime test, merge or flash is included in that scope.
