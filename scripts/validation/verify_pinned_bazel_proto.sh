#!/usr/bin/env bash
# Read-only remote Git-tree verification for one pinned AOSP project.
# No Android repo sync, build, image, or checkout.
set -euo pipefail
REV=412a875da5a1632c7fadcc1eb91abba4cf650356
REMOTE=https://android.googlesource.com/platform/prebuilts/bazel/common
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
git -C "$TMP" init -q
git -C "$TMP" remote add origin "$REMOTE"
# Request only the pinned commit; blob contents are not needed for a tree listing.
git -C "$TMP" -c protocol.version=2 fetch --no-tags --depth=1 --filter=blob:none origin "$REV"
ACTUAL="$(git -C "$TMP" rev-parse FETCH_HEAD^{commit})"
test "$ACTUAL" = "$REV" || { echo "FAIL: revision mismatch"; exit 1; }
ENTRY="$(git -C "$TMP" ls-tree "$REV" proto)"
printf 'Pinned commit: %s\nGit tree entry: %s\n' "$REV" "$ENTRY"
[[ "$ENTRY" == 040000\ tree\ *$'\t'proto ]] || { echo "FAIL: proto directory not proven"; exit 1; }
echo "PASS: proto directory exists in the exact pinned commit"
