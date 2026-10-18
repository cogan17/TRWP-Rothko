# Rothko stage 75 — free GitHub Actions feasibility (HOLD)

Decision: GitHub-hosted standard runner only; no paid larger runner, no external VPS.
Measured capacity preflight #1: 144.26 GiB total, 85.80 GiB free, 15 GiB RAM, 3 GiB swap. The successful job is **not** proof that a 658-project Android checkout or probe build fits.

## Smallest useful source target

The opt-in `experiments/weaver-aidl/Android.bp` defines `rothko_weaver_aidl_link_probe` with `recovery_available: true`, `installable: false`, and shared libraries `android.hardware.weaver-V2-ndk` and `libbinder_ndk`. The intended generated target is `rothko_weaver_aidl_link_probe.recovery`. The graph and transitive dependencies remain **unverified**; do not guess a minimal list of projects or call a partial sync build-ready.

## Safe next gate

1. Preserve the 658-revision frozen manifest as the source-of-truth input. Do not alter its pins or apply the 12-pin overlay twice.
2. Determine the full Soong graph dependencies and prebuilt requirements *without* claiming a successful compile. A partial checkout is allowed only as a separate, explicitly authorized experiment with its own evidence; missing-dependency placeholders are forbidden.
3. Before any large sync, require a capacity budget based on actual selected projects, Git objects, intermediate output, and toolchains. The raw three-prebuilt lower bound is 33.958 GiB, **not** the total requirement.
4. If no defensible budget fits 85.80 GiB free, stop. Do not rerun the already-green capacity preflight or trigger a knowingly-failing 250 GiB storage gate.
5. Preserve Draft/HOLD PR #2, no merge/flash/image generation, no production vold changes. The separate approval for the single compile/link probe remains required.

The 250 GiB threshold in the manual storage gate is a planning placeholder, not a measured minimum. This checkpoint makes no assertion that GitHub-hosted free runners can complete the build.
