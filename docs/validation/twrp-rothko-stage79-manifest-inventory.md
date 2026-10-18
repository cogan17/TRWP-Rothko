# Rothko stage 79 — frozen manifest inventory and free-runner decision

Source: `experiments/weaver-aidl/validation-manifest.xml` on `fix/metadata-f2fs`, blob SHA `2daab98180e2cae95a8ed2f80bd5bdd9b630d7db`. Parsed all 658 explicit `<project>` entries from the manifest; counts are by top-level checkout path, not transitive build dependencies.

| Root | Projects |
| --- | ---: |
| external | 436 |
| system | 48 |
| packages | 42 |
| prebuilts | 38 |
| trusty | 19 |
| tools | 12 |
| hardware | 10 |
| frameworks | 10 |
| kernel | 9 |
| build | 8 |
| test | 7 |
| device | 4 |
| vendor | 4 |
| bootable | 2 |
| other single-root projects | 9 |
| **Total** | **658** |

The inventory confirms that Clang, Rust and SDK prebuilt projects are in the full frozen input. Their combined raw blob lower bound is 33.958 GiB. Previously measured free runner storage: 85.80 GiB. This is insufficient evidence for a full checkout plus Soong output.

**Decision:** Do not delete 436 `external/` projects merely by directory name. The dependency closure is not known. No partial manifest should be labeled build-ready before generated Soong graph and toolchain requirements are validated. No source sync, compilation, workflow runs or new PR in this stage.

**Next evidence gate:** identify which host/build bootstrap components are mandatory before any Soong graph can be generated, and determine a bounded, reversible, read-only experiment within the free-runner disk limit. If the experiment cannot be budgeted conservatively, retain HOLD. No missing-dependency overrides, alternate Clang, production vold changes, image, merge or flash. PR #2 remains Draft/HOLD.
