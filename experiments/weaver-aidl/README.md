# Weaver AIDL prototype (HOLD)

This directory is an isolated source prototype for Rothko Android 16. It is **not** part of the recovery build: an opt-in `Android.bp` compile-probe target (not selected by product), no changes to upstream `system/vold`, and no runtime testing.

**Current checkpoint: stage 67.** See the [pinned validation plan](../../docs/validation/twrp-rothko-stage65-build-plan.md),
selective [source overlay](validation-pins.xml), and unapplied
[workspace patch](validation-workspace.patch). The last adapter source audit
(stage 64) passed **18/18**, with three isolation regressions; it was not rerun.
Stage 66 verified Clang `r510928` / declared `18.0.0` in the official AOSP source,
added its commit as the twelfth selective pin, and recorded
[toolchain evidence](../../docs/validation/twrp-rothko-stage66-toolchain.json).
Full workspace preparation, host execution, C++ compilation, final optimized
linking, recovery dependencies and FBE remain unverified. Earlier sections are historical.

Stage 67 initialized a manifest-only workspace and prepared
[validation-manifest.xml](validation-manifest.xml), with all **658 project
revisions pinned** and accepted by the official Repo parser. The twelve earlier
pins and copy/link rules are preserved. Use this full manifest as the main
manifest for a new runner; do not stack `validation-pins.xml` on top of it.
[Workspace evidence](../../docs/validation/twrp-rothko-stage67-workspace.json)
records the capacity blocker: three required prebuilts alone contain 33.958 GiB
of raw blob content, exceeding this session's entire 31.451 GiB volume. A larger
runner is required for full source checkout. No full sync, post-checkout
`repo manifest -r`, bootstrap, compilation or Actions run has occurred.

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


## Stage 61 — static archive vs link validation

**Finding:** `rothko_weaver_aidl_probe` is a `cc_library_static`, not an executable or shared library. Building this module can compile `WeaverAidl.cpp` into an object and archive it, but **cannot by itself demonstrate a successful final link** against `android.hardware.weaver-V2-ndk` and `libbinder_ndk`. Its `shared_libs` declarations express dependencies but do not make the static archive a linked executable. Previous documentation calling this a compile-and-link proof was too strong.

The `recovery_available: true` property requests a recovery variant, but a plain `m rothko_weaver_aidl_probe` is **not proof that the recovery variant** was selected or built. The module is not installed and is not part of the TWRP image.

Before a production integration, with owner approval and a matching Soong checkout:
1. Confirm the generated NDK interface library and Binder dependencies resolve to actual recovery variants (including transitive dependencies).
2. Inspect the build graph and command output to establish that the **recovery variant** of the probe was compiled; do not rely on a default/system archive.
3. Add a separate opt-in recovery **link target** only after dependency availability is established; ensure it links real Weaver/Binder libraries and references the adapter so that dead-code elimination cannot conceal missing symbols. This is a distinct gate from the current static compile probe.
4. Keep `ALLOW_MISSING_DEPENDENCIES := true` from masking unresolved dependencies; inspect missing-dependency diagnostics, compiler invocation and final link command.
5. Even a linked target cannot prove that NXP Weaver starts in recovery or that FBE decrypts.

**Stage 62 next:** design an isolated, no-install link probe or audit upstream recovery variant support before introducing it. Do not modify production vold or claim runtime readiness. Draft PR #2 HOLD; no Actions/build/flash/merge.

## Stage 62 — opt-in link probe (unbuilt)

Added `LinkProbe.cpp` and a second Soong target, `rothko_weaver_aidl_link_probe` (`cc_binary`, `recovery_available: true`, `installable: false`). Its translation unit includes the experimental `WeaverAidl.cpp` directly to force the Binder/AIDL methods into the link graph without duplicating a compiled object. This is temporary probe-only structure, **not** an integration pattern for production. The program must not be run on a phone or installed into recovery; `main()` references `Connect()` and `GetConfig()` only for linker coverage.

**Caveats:** The link probe has not been compiled or linked, and the exact recovery variant is not yet confirmed. `installable: false` prevents intended image installation but does not itself prove Soong generated the right variant. `main()` does not invoke `Verify()`, so full read-path symbol coverage remains a separate gate. Before approving a build, inspect generated recovery variants and confirm both Binder libraries resolve without missing-dependency stubs. Do not trigger Actions or flash.

**Stage 63 next:** audit the link probe's source inclusion, ensure the read path is also referenced without executing credential operations, and strengthen static checks. Draft PR #2 HOLD.

## Stage 63 — Verify read-path link reference (source-only)

The non-installable `LinkProbe.cpp` now takes the address of `WeaverAidl::Verify` into a volatile pointer-to-member and does **not** invoke it. This is intended to retain the method and its Binder `read` references in a future link test, while avoiding credential operations. This is a link-test design, **not verified linker coverage** until compiled and its symbols/link map inspected. `main()` still contains `Connect()` and `GetConfig()` calls and **must not be executed** on a device.

`audit_source.py` now has 16 simple source predicates (two added for non-installable link probe and non-invoked Verify reference). These are textual guards only, not a parser, build, or runtime test. No Actions, compilation, flashing, merge or PR status change.

**Stage 64 next:** review Soong build-target semantics and whether the link probe's method-address retention survives optimized linking; adjust only if demonstrably necessary. Keep recovery variant availability unresolved until a separately approved build.

## Stage 64 — explicit ELF retention and executed source audit

Replaced the local volatile pointer-to-member with a namespace-scope constant
`verify_reference` carrying `__attribute__((used, retain))`. It still takes the
address of `WeaverAidl::Verify` without invoking it. According to the
[Clang attribute documentation](https://clang.llvm.org/docs/AttributeReference.html#retain),
`used` requests emission by the compiler, whereas `retain` prevents ELF section
garbage collection by a supporting linker. The
[LLD ELF documentation](https://lld.llvm.org/ELF/start-stop-gc.html)
also distinguishes compiler retention from linker GC. This gives the probe an
explicit retention rule rather than relying on a local volatile store. It does
**not** prove the previous implementation failed or the current optimized binary
has been inspected.

The compiler must support the `retain` attribute (checked with `__has_attribute`);
the linker must support `SHF_GNU_RETAIN` (LLD 13 or newer per Clang documentation).
Do not remove the attribute or disable warnings to conceal an incompatible
toolchain. This translation unit is compiled directly by the opt-in binary;
the retention design does not rely on extraction from the separate static probe.

The first actual execution of the previous Python audit returned 15/16 PASS:
its `PRODUCT_PACKAGES` test incorrectly matched an Android.bp comment. The
replacement inspects this device tree's `.mk` files for either probe module name
after stripping Make comments. It is a conservative textual isolation guard,
not product inheritance evaluation or proof of the final image contents.
Two additional predicates check the retention declaration and explicit compiler
support requirement. The revised audit returned **18/18 PASS**. Three temporary
fixtures confirmed that a commented product example passes and actual product
references to each probe fail the isolation check. `git diff --check` passed.

For a future approved compile/link validation, inspect the actual recovery
variant, compiler/linker versions and options, the emitted retained data section
and its Verify relocation, and the optimized unstripped ELF/link map. Confirm
that the Verify implementation and its read path remain reachable from the
retained reference. Calls may be indirect or inlined, so absence/presence of a
literal `IWeaver::read` symbol alone is not sufficient evidence. Keep actual
Weaver/Binder dependency resolution independent of this retention check.

No probe execution, C++ compilation, Actions or recovery integration occurred.
`main()` still contains Connect/GetConfig calls and must not be run on a device.
**Next: stage 65**, one pinned, reproducible recovery build-validation plan.
Draft PR #2 remains HOLD.
