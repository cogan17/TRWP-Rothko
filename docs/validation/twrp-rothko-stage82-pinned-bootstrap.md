# Rothko stage 82 — pinned Soong bootstrap evidence (HOLD)

Pinned Soong revision `fed50f11f6d8dd08dd157e5450e938e2d11dbbb3`: `soong_ui.bash` and `scripts/microfactory.bash` were retrieved from TeamWin `android_build_soong` at that exact revision. Pinned Make revision `506df226dd003a364916b6b3ee1eb3bf9064f97f`: `shell_utils.sh` retrieved from TeamWin `android_build` at that exact revision.

Confirmed bootstrap flow: `soong_ui.bash` sources `build/make/shell_utils.sh`, then `build/soong/scripts/microfactory.bash`, then invokes `soong_build_go` for `soong_ui`, `mk2rbc`, and `rbcrun`. Microfactory exports Linux `GOROOT=prebuilts/go/linux-x86`, `BLUEPRINTDIR=build/blueprint`, and Go package mappings to `prebuilts/bazel/common/proto`, `build/make/tools/rbcrun`, `external/golang-protobuf`, and `external/starlark-go`, then sources `build/blueprint/microfactory/microfactory.bash`.

These are **direct bootstrap source references**, not proof of a complete minimal checkout, Soong graph, successful host build, or fit within the free runner's measured 85.80 GiB available storage. Do not launch speculative sync or weaken missing-dependency gates. Next: cross-check each referenced project against frozen manifest and size before any bounded experiment.

PR #2 remains Draft/HOLD. No workflow, compile, merge or flash.
