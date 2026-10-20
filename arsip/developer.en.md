# 🛠️ Developer Notes & Lessons

[← Back to README](../README.en.md) · <img src="https://flagcdn.com/24x18/id.png" width="22" alt=""> [Bahasa Indonesia](developer.md)

> 📦 **Technical archive** — end users don't need to read this.

For anyone who **builds, maintains, or forks** this tree — **feel free to copy and adapt** it for your own repo.
**Read the Lessons first** — they're mistakes we already made, so you don't repeat them.

---

## Key lessons (read before changing anything)

### 1. vendor_boot MUST have a recovery fragment
Stock vendor_boot v4 has **two** ramdisk fragments: PLATFORM (`type 0x1`) and RECOVERY (`type 0x2`, name `recovery`). The bootloader loads the recovery fragment **only in recovery mode**. If TWRP is packed as a **single** platform fragment, Android still boots but recovery **never reaches the kernel** — on this phone: **a bootloop in both modes**.
- Fix: repack as platform + recovery like stock (`verify-image.yml`: `--ramdisk_type platform` + `--ramdisk_type recovery --ramdisk_name recovery`).
- Symptom if wrong: bootloop in normal boot **and** recovery.

### 2. workflow_run uses the workflow file from the DEFAULT branch
This one cost us a night. A workflow triggered by `workflow_run` takes its definition from the repo's **default branch**, not from the branch/commit that triggered it. So the automatic "Verify" packaged the build with the **old** `verify-image.yml` from the default branch (without the fragment split, Lesson 1) → **a bootlooping package**, even though the build itself was fine.
- Fix: keep the default branch up to date (merge), **or** run verify via `workflow_dispatch` from the working branch.
- Lesson: **don't trust a green `workflow_run` check on a feature branch** — it runs the default branch's stale logic.

### 3. Diagnose with evidence, not conviction (the ccache trap)
When the package bootlooped, we were **too sure** it was ccache and nearly threw away an 80-minute "fix" build. ccache was **innocent**: the pinned source commits matched the default-branch HEAD used by the working build (the TWRP 14.1 branch hadn't changed in a year), so the sources were identical; and the vold changes only affect recovery. The real cause = Lesson 2. **Compare the working and broken artifacts at the structural level before changing code.**

### 4. HyperOS LSKF: Weaver active, Gatekeeper as backup
The active lock-screen protector uses **Weaver** on the NXP eSE, accessed through OMAPI — **impossible in recovery**. HyperOS also stores a **Gatekeeper** protector for the same synthetic password. Recovery decryption must **fall back to the Gatekeeper protector**.
- Gatekeeper on Android 13+ devices is **AIDL only** (`android.hardware.gatekeeper-service.mitee`); there is no HIDL @1.0 path.

### 5. unwrapSyntheticPasswordBlob must use the protector being tried
TWRP's vold re-reads the **active sp-handle** from `locksettings.db` to pick the keystore key, ignoring the handle of the backup protector it is opening — so it decrypts the Gatekeeper protector's blob with the **Weaver protector's key**, and `finish()` fails. **Use the handle you are trying.**

### 6. Touch: Focaltech starts in THP mode
The panel boots in **THP** (raw-frame) mode, meant for a touch HAL that only exists in Android. In recovery: write `0` to `enable_touch_raw` `on boot`, **and** apply it again every time the screen turns on via `postscreenunblank.sh` (turning the screen on resets the chip).

### 7. Libraries left behind by vold
TWRP's relink list carries the **V1** AIDL libs, while vold now links keystore2-**V4** / keymint-**V3**, and the bootstrap servicemanager needs `/system/bin/bootstrap/linker64`. `recovery_deps.py` fills the gaps after the build — and **must FAIL on a readelf error** instead of passing silently.

### 8. Entering recovery
`fastboot reboot recovery` / `reboot recovery` write the **BCB** (boot-recovery) and will **loop a crashing TWRP**. The one-shot hardware path: **Power + Volume Up** from a powered-off phone. With a healthy TWRP, `reboot recovery` is safe (TWRP clears the BCB). That's why `1-PASANG-TWRP.bat` uses a plain `fastboot reboot`.

---

## Commits that mattered

| Commit | Change | Why it matters |
|---|---|---|
| `6a9f539` | split vendor_boot → platform + recovery fragment | **Lesson 1** — without it recovery bootloops |
| `2f71439` | touch fix + metadata decryption | touch (Lesson 6) + mounting /data |
| `5bebf11` | every program in the ramdisk can load | libs + bootstrap linker (Lesson 7) |
| `9ff7a47` | unlock storage via AIDL Gatekeeper | **Lesson 4** |
| `7c5af05` | decrypt a protector's blob with its own key | **Lesson 5** |
| `5459d38` | recovery_deps fails on a readelf error | Lesson 7 (gate robustness) |
| `5320d78` | drop ccache | removed while debugging Lesson 3 — **ccache was actually innocent**, feel free to add it back to speed up builds |
| `0eb8a19` | pinned sources + fast path + ship the dtb | reproducibility + fast builds |

---

## Build flow

| Workflow | Purpose |
|---|---|
| `build-twrp.yml` | sync the TWRP 14.1 manifest (pinned by `twrp-sources.lock.xml`), apply `patches/`, build `vendorbootimage`, run `recovery_deps.py` |
| `verify-image.yml` | repack into a two-fragment vendor_boot like stock, run the structure gate, package the end-user zip, sign it (attestation) and publish the pre-release. **Run it via `workflow_dispatch` from the working branch** (Lesson 2) |
| `update-twrp-sources.yml` | refresh the source pins |

> **New release:** first add a `## vX.Y` section (✨ What's new / 🔧 What's fixed) to `CHANGELOG.md` **and** `CHANGELOG.en.md`. Verify takes the version + release notes from there, and stops if the two files disagree.
| `extract-stock.yml` | download the official ROM & extract the stock blobs (**manual; heavy — 6.3 GB**) |

### Fast path
A new TWRP version or HyperOS firmware that **doesn't change compiled code** can reuse the last build's ramdisk: `verify-image` overlays `recovery/root` + `prebuilt/dtb` (~3 minutes), with no full compile.

### `verify-image` gate (the guard before a package ships)
Fragments match stock · size fits the partition · dtb equals stock · TWRP UI in the recovery fragment · fstab & modules = stock · **every program finds its libraries + linker** (`recovery_deps.py`).

---

> Want to dig deeper into the decryption architecture (synthetic password, protectors, keystore)? Read the comments in `patches/system_vold/*.patch` and `recovery/root/system/bin/postscreenunblank.sh`.
