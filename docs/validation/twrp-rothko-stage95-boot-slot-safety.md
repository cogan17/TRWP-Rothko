# Stage 95 — Boot-slot transition safety gate (source audit)

Status: HOLD; no merge, flash, build, or production changes.

## Evidence (fix/metadata-f2fs, stage 94)
- `BootControl::setActiveBootSlot` first calls `impl_.SetActiveBootSlot(slot)`, then `implext_.SetBootRegionSlot(slot)`.
- If the second operation fails, the function returns an error, but the already-updated bootloader metadata is not rolled back.
- `BootControlExt::SetBootRegionSlot` maps slot 0 to UFS BootLU 1, slot 1 to BootLU 2, and opens `/dev/block/sdc` with `O_RDWR`.
- UFS ioctl failure is reported; no atomic transaction is demonstrated.
- `/dev/block/sdc` mapping must be validated against the actual target device; do not infer it from the path alone.

## Acceptance gates before any ready-for-review or squash merge
1. Confirm the correct UFS control block device and BootLU mapping for rothko with read-only device evidence.
2. Verify what `impl_.SetActiveBootSlot` writes, including whether any internal rollback exists; inspect its implementation.
3. Define and test safe behavior when metadata update succeeds but UFS ioctl fails; do not introduce speculative automatic rollback that could further damage boot state.
4. Validate metadata F2FS, recovery module loading, and the recovery image through a controlled build and device test.
5. Resolve GitHub PR #2 `mergeable_state=dirty` discrepancy and required checks/reviews independently.

This document is an audit checkpoint, not a successful runtime validation. PR #2 remains Draft/HOLD.
