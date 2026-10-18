# Rothko stage 78 — offline source assertions

Date: 2026-10-18. Source snapshot: `09998aa089b0dc3fec5c216c8706326d1e906330`.

Eleven source assertions equivalent to `scripts/validation/check_weaver_probe_static.py` were executed against the five GitHub file contents using an independent JavaScript checker: **11 passed, 0 failed**. The Python script itself was **not** executed in GitHub Actions or an Android checkout. No compile, link, Soong graph or Android recovery runtime was tested.

Passed checks: probe binary declared; Weaver V2 NDK and Binder NDK listed; two recovery declarations; probe not installable; AIDL IWeaver header referenced; nonblocking service lookup; retained Verify reference; strict missing-dependency patch; recovery AIDL patch; ap2a lunch patch.

This does **not** establish that the transitive Soong graph fits a free runner (previously measured 85.80 GiB free), that generated NDK interfaces match, or that a recovery executable links. No full sync or known-failing storage gate should be started without a defensible budget.

PR #2 Draft/HOLD; no workflow runs, merges, images, or flashing. Next work should be substantive graph/storage feasibility rather than rerunning the same static assertions.
