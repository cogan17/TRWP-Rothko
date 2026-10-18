# Stage 38 — recovery overlay and vendor_boot source audit

Date: 2026-10-18. Device-tree revision: `5df0af40b9c0978feb5da959b22196cb20f95f77`
on `fix/metadata-f2fs`. Draft PR #2 remains **HOLD**.

The inspected TeamWin rules already copy this device's `recovery/root` overlay.
No extra copy mapping, service-start command, file-mode change, or module removal
is justified by this audit. These are source-level findings, not a successful
build, a validated ramdisk, or evidence of Android 16 decryption.

## Revisions inspected

| Source | Branch/tag | Revision |
| --- | --- | --- |
| [TWRP manifest](https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp/tree/cb31ddec08f495d3f70631b22140642d0045ba0d) | `twrp-14.1` | `cb31ddec08f495d3f70631b22140642d0045ba0d` |
| [TeamWin build](https://github.com/TeamWin/android_build/tree/506df226dd003a364916b6b3ee1eb3bf9064f97f) | `android-14.1` | `506df226dd003a364916b6b3ee1eb3bf9064f97f` |
| [TeamWin recovery](https://github.com/TeamWin/android_bootable_recovery/tree/426b747737e7ce9e9e17da5b4d2ba883f296aec7) | `android-14.1` | `426b747737e7ce9e9e17da5b4d2ba883f296aec7` |
| [TeamWin system/core](https://github.com/TeamWin/android_system_core/tree/ab2f1a4834dd01c2aa17989b887b1e794c3d342d) | `android-14.1` | `ab2f1a4834dd01c2aa17989b887b1e794c3d342d` |
| [AOSP libvintf](https://android.googlesource.com/platform/system/libvintf/+/refs/tags/android-14.0.0_r67/) | `android-14.0.0_r67` | Manifest default tag |

The manifest's `twrp-default.xml` selects the three TeamWin branches above;
`system/libvintf` uses the AOSP default. These pinned snapshots are an audit
reference, not a complete locked build manifest or a confirmed Android 16 source
environment. A future build must record its own resolved revisions and variables.

## Overlay installation

1. [core/board_config.mk](https://github.com/TeamWin/android_build/blob/506df226dd003a364916b6b3ee1eb3bf9064f97f/core/board_config.mk#L216-L238)
   derives `TARGET_DEVICE_DIR` from the selected `BoardConfig.mk`. With this tree
   installed at `device/xiaomi/rothko`, that is the device directory.
2. [core/Makefile, lines 2550–2558](https://github.com/TeamWin/android_build/blob/506df226dd003a364916b6b3ee1eb3bf9064f97f/core/Makefile#L2550-L2558)
   uses `$(TARGET_DEVICE_DIR)/recovery/root` by default and tracks its regular files
   in `recovery_root_deps`. The optional override is **`TARGET_RECOVERY_DEVICE_DIRS`**
   (plural); neither the singular spelling in the old checkpoint nor a new
   `PRODUCT_COPY_FILES` mapping is required for this default path.
3. [The recovery staging recipe](https://github.com/TeamWin/android_build/blob/506df226dd003a364916b6b3ee1eb3bf9064f97f/core/Makefile#L2725-L2772)
   copies baseline ramdisk contents first, then runs
   `cp -rf $(item) $(TARGET_RECOVERY_OUT)/` for each private `recovery/root`.
   This overlays the files under the recovery staging root. It then copies
   `TARGET_RECOVERY_FSTAB` to `system/etc/recovery.fstab`; this device selects the
   same fstab already present in its overlay.
4. [Recovery resource selection](https://github.com/TeamWin/android_build/blob/506df226dd003a364916b6b3ee1eb3bf9064f97f/core/board_config.mk#L492-L508)
   enables recovery staging for `BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT=true`
   when `PRODUCT_BUILD_RECOVERY_IMAGE` is unset, even with this tree's
   `TARGET_NO_KERNEL=true` and `TARGET_NO_RECOVERY=true`. An explicit product
   override still matters and must be checked in the resolved build configuration.
5. [Vendor ramdisk assembly](https://github.com/TeamWin/android_build/blob/506df226dd003a364916b6b3ee1eb3bf9064f97f/core/Makefile#L1591-L1603)
   depends on the recovery staging timestamp and passes `TARGET_RECOVERY_ROOT_OUT`
   as an additional `mkbootfs` input when recovery resources move to vendor_boot
   and `BOARD_INCLUDE_RECOVERY_RAMDISK_IN_VENDOR_BOOT` is not true. This device
   does not set that separate-fragment flag.

Thus the inspected rules provide the missing copy path. Final inclusion,
overwrites by other build inputs, and archive contents still require an actual
build and inspection; adding duplicate mappings would not establish those facts.

## Init discovery and service paths

- Recovery [Android.bp](https://github.com/TeamWin/android_bootable_recovery/blob/426b747737e7ce9e9e17da5b4d2ba883f296aec7/Android.bp#L134-L140)
  installs `etc/init.rc` as `system/etc/init/hw/init.rc` in recovery.
- [LoadBootScripts](https://github.com/TeamWin/android_system_core/blob/ab2f1a4834dd01c2aa17989b887b1e794c3d342d/init/init.cpp#L337-L361)
  parses that main script plus `/system/etc/init` and `/vendor/etc/init` when
  `ro.boot.init_rc` is empty. The device's three system service rc files and four
  vendor service rc files are in these scanned directories. An override of
  `ro.boot.init_rc` changes this path and remains a device/runtime check.
- Recovery [etc/init.rc](https://github.com/TeamWin/android_bootable_recovery/blob/426b747737e7ce9e9e17da5b4d2ba883f296aec7/etc/init.rc#L1-L6)
  imports `/init.recovery.usb.rc` and `/init.recovery.${ro.hardware}.rc`.
  The overlay supplies both USB and `init.recovery.mt6989.rc`; the latter requires
  `ro.hardware=mt6989`. `TARGET_BOARD_PLATFORM` alone is not proof of that runtime
  property: init [maps `ro.boot.hardware` to `ro.hardware`](https://github.com/TeamWin/android_system_core/blob/ab2f1a4834dd01c2aa17989b887b1e794c3d342d/init/property_service.cpp#L1313-L1334).
  `TW_EXCLUDE_DEFAULT_USB_INIT=true` suppresses the upstream USB module via
  [etc/Android.mk](https://github.com/TeamWin/android_bootable_recovery/blob/426b747737e7ce9e9e17da5b4d2ba883f296aec7/etc/Android.mk#L17-L32).

| Service | Executable | Source-tree provider |
| --- | --- | --- |
| `vendor.keymint-mitee` | `/vendor/bin/hw/android.hardware.security.keymint@3.0-service.mitee` | Present in overlay |
| `vendor.gatekeeper_mitee` | `/vendor/bin/hw/android.hardware.gatekeeper-service.mitee` | Present in overlay |
| `tee-supplicant` | `/vendor/bin/tee-supplicant` | Present in overlay |
| `mitee-helper` | `/system/bin/mitee_helper` | Present in overlay |
| `vendor-watchdog` | `/system/bin/vendor_watchdog` | Present in overlay |
| `vibratorfeature-hal-service` | `/vendor/bin/hw/vendor.xiaomi.hardware.vibratorfeature.service` | Present in overlay |
| `mtk.plpath.utils.link` | `/system/bin/mtk_plpath_utils` | Source module with `recovery_available: true`; `device.mk` requests `.recovery` variant |

Presence and parsing do not establish startup or readiness. The KeyMint,
Gatekeeper, and tee-supplicant definitions use `class none`; the inspected
recovery init script starts `default` and `hal`, not `none`. This does not rule
out startup elsewhere in TWRP/vold or the prebuilt helpers. No explicit start
commands were added. The asynchronous `start mitee-helper` followed by
`setprop vendor.teefs_state ready` still does not demonstrate TEE readiness.

All 350 overlay blobs have Git mode `100644`, including executables. This is not
by itself evidence of a non-executable final ramdisk:
[mkbootfs `fix_stat`](https://github.com/TeamWin/android_system_core/blob/ab2f1a4834dd01c2aa17989b887b1e794c3d342d/mkbootfs/mkbootfs.c#L42-L75)
uses `fs_config`, whose [default rules](https://github.com/TeamWin/android_system_core/blob/ab2f1a4834dd01c2aa17989b887b1e794c3d342d/libcutils/fs_config.cpp#L220-L229)
give `system/bin/*` and `vendor/bin/*` mode `0755`. Generated filesystem config
can override defaults. Verify final cpio modes, ELF interpreter/library resolution,
and SELinux labels during build validation; do not infer these from Git modes.

## VINTF placement

The overlay has `/vendor/etc/vintf/manifest.xml` and seven fragments under
`/vendor/etc/vintf/manifest/`, including Gatekeeper AIDL v1, KeyMint AIDL v3,
SecureClock and SharedSecret. It also has `/system/etc/vintf/manifest.xml`.
AOSP [VintfObject.cpp](https://android.googlesource.com/platform/system/libvintf/+/refs/tags/android-14.0.0_r67/VintfObject.cpp#322)
loads the vendor manifest and merges vendor fragments when that manifest loads
successfully. These are appropriate source locations for that path.

All nine overlay XML files parse as XML. This check does **not** validate VINTF
schema/merge compatibility, runtime service registration, or AIDL version support
in the selected build. Those checks remain open.

## Payload inventory

Sizes below are the sum of Git blob bytes at the pinned device-tree revision,
counted once per path, and cross-checked against all 350 checked-out files.
One MiB is 1,048,576 bytes. These are **uncompressed source bytes**, not cpio or
vendor_boot sizes.

| Overlay directory/group | Files | Bytes | MiB |
| --- | ---: | ---: | ---: |
| `lib/modules` (237 `.ko` plus 5 metadata files) | 242 | 45,930,567 | 43.803 |
| `vendor/firmware` | 61 | 3,617,574 | 3.450 |
| `system/bin` | 3 | 2,155,312 | 2.055 |
| `vendor/mitee` | 2 | 1,646,104 | 1.570 |
| `vendor/lib64` | 10 | 766,880 | 0.731 |
| `vendor/bin` | 4 | 352,160 | 0.336 |
| Remaining configuration, init, fstab, and manifests | 28 | 119,161 | 0.114 |
| **Total `recovery/root`** | **350** | **54,587,758** | **52.059** |

The separate DTB is 444,463 bytes. Overlay plus DTB is 55,032,221 bytes
(52.483 MiB), before considering build-generated content. The largest blobs are
`ufs-mediatek-mod-ise.ko` (18,412,528 bytes), `mediatek-drm.ko` (6,081,912),
`system/bin/busybox` (2,143,584), and `mtk-mml.ko` (1,889,544).

`BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE` is 67,108,864 bytes (64 MiB).
The inspected build selects [legacy LZ4, `-l -12 --favor-decSpeed`](https://github.com/TeamWin/android_build/blob/506df226dd003a364916b6b3ee1eb3bf9064f97f/core/Makefile#L1201-L1205).
The final image also includes generated recovery binaries/libraries/resources,
cpio records, vendor ramdisk inputs, boot header/table/bootconfig, DTB alignment,
and AVB metadata/padding. Therefore the arithmetic difference between raw source
bytes and 64 MiB is **not usable image headroom** and does not prove fit or overflow.

[The vendor_boot recipe](https://github.com/TeamWin/android_build/blob/506df226dd003a364916b6b3ee1eb3bf9064f97f/core/Makefile#L1695-L1713)
checks image size before adding the AVB hash footer. Both packaging and footer
generation must succeed. Final padded file size alone is not the available
payload budget; inspect the compressed ramdisk and AVB information as well.
No module or firmware was stripped or removed to estimate savings.

Reproduce the source inventory without building:

```sh
git ls-tree -r -l 5df0af40b9c0978feb5da959b22196cb20f95f77 recovery/root
git ls-tree -r -l 5df0af40b9c0978feb5da959b22196cb20f95f77 prebuilt/dtb
```

## Verification and next checkpoint

Completed: pinned source inspection; all overlay sizes matched Git metadata;
seven service executable paths traced to six prebuilts and one source module;
nine XML files parsed. No Android compilation, image generation, Actions run,
device command, flashing, merge, or squash was performed.

Stage 39 should trace the actual KeyMint/Gatekeeper/tee-supplicant startup path
in the manifest-selected TWRP/vold sources and available helper evidence. Record
the exact start triggers and readiness checks, or leave the gap explicit. Do not
add speculative starts. A later owner-authorized build must inspect the resolved
configuration, final cpio paths/modes, VINTF merge, ELF dependency closure,
compressed payload and AVB size, followed by the existing runtime gates.
