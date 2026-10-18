# Stage 96 — Boot control handoff checkpoint

Branch: `fix/metadata-f2fs`; PR #2: Draft/HOLD. Do not merge, squash, flash, or run repetitive Actions.

## Verified
- Stage 95 boot-slot safety gate recorded at `docs/validation/twrp-rothko-stage95-boot-slot-safety.md`.
- `bootctrl/BootControl.cpp` calls `impl_.SetActiveBootSlot(slot)` before `implext_.SetBootRegionSlot(slot)`; failure in the second call reports possible inconsistent metadata.
- `bootctrl/boot_region_control.cpp` writes UFS BootLU via ioctl on `/dev/block/sdc` (slot 0 => 1; slot 1 => 2).
- `bootctrl/boot_control_definition.h` defines the A/B metadata structure and declares load/save functions, but does not implement `impl_.SetActiveBootSlot`.
- `bootctrl/Android.bp` builds `BootControl.cpp` and `boot_region_control.cpp` and links static library `libboot_control` with defaults `libboot_control_defaults`. This is the next concrete dependency to inspect.
- Earlier PR audit: GitHub reported `mergeable=false`, `mergeable_state=dirty`, while merge-base equaled base SHA and head was 53 commits ahead, 0 behind. The discrepancy remains unresolved. Zero Check Runs observed at the prior head; do not interpret this as CI success or failure.

## Next step
1. Locate the exact pinned source providing `libboot_control` / `libboot_control_defaults`.
2. Inspect the implementation of `SetActiveBootSlot` and write/rollback behavior, without assuming atomicity.
3. Check the device's UFS mapping with read-only evidence, and only then consider an isolated fix.
4. Keep PR #2 Draft/HOLD until build, runtime, and GitHub merge requirements are satisfied.

No compilation, runtime test, or successful merge is claimed.
