# Rothko stage 80 — bootstrap candidates from pinned manifest (HOLD)

Inspected the frozen `experiments/weaver-aidl/validation-manifest.xml` (658 projects) without a source checkout or GitHub Actions run.

## Manifest-confirmed candidate paths

Build bootstrap: `build/make`, `build/soong`, `build/blueprint`, `build/bazel`, `build/bazel_common_rules`, `build/release`, `prebuilts/build-tools`, `prebuilts/go/linux-x86`.

Compilation and target context: `prebuilts/clang/host/linux-x86`, `bionic`, `libcore`, `libnativehelper`, `frameworks/native`, `system/tools/aidl`, `hardware/interfaces`, `device/xiaomi/rothko`.

Manifest also contains `prebuilts/jdk/jdk8`, `jdk11`, `jdk17`, `jdk21` and `prebuilts/rust`. Their presence does **not** establish that all versions are needed for this probe.

These paths are **candidate starting points only**, not a complete, tested Soong bootstrap set, dependency closure or approved selective-sync list. Missing build inputs must not be hidden with `ALLOW_MISSING_DEPENDENCIES`.

## Practical decision

Do not launch a speculative selective sync yet: Git object sizes, generated build outputs, and exact bootstrap dependencies remain unmeasured. Existing free runner capacity was 85.80 GiB available. First inspect the pinned build/Soong bootstrap requirements and estimate peak disk use; only then propose a bounded experiment with a hard capacity stop.

The previous manifest inventory's 'other single-root projects' bucket equals nine, as confirmed by summing all listed buckets to 658.

No workflow, PR, build, production change, merge or flash. PR #2 stays Draft/HOLD.
