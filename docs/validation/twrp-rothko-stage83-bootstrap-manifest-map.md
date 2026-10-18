# Rothko stage 83 — pinned bootstrap paths versus frozen manifest

Seven source references from the pinned `build/soong/soong_ui.bash` and `build/soong/scripts/microfactory.bash` were cross-checked against the 658-project frozen manifest.

| Bootstrap reference | Frozen manifest mapping | Result |
| --- | --- | --- |
| `build/make` | exact project | FOUND |
| `build/soong` | exact project | FOUND |
| `build/blueprint` | exact project | FOUND |
| `prebuilts/go/linux-x86` | exact project | FOUND |
| `prebuilts/bazel/common/proto` | parent project `prebuilts/bazel/common` | PARENT FOUND; subdirectory contents not verified |
| `external/golang-protobuf` | exact project | FOUND |
| `external/starlark-go` | exact project | FOUND |

Six direct projects and one parent-project mapping. This is **manifest coverage**, not proof that the `proto` subdirectory exists at the pinned commit, nor proof of a complete Soong graph, build, or storage feasibility. Next validate the subdirectory against pinned contents and investigate remaining bootstrap imports before a selective sync.

No workflow runs, sync, compilation, new PR, merge or flash. PR #2 remains Draft/HOLD.
