#!/bin/bash
# Release notes for one version, from CHANGELOG.md (Indonesian) + CHANGELOG.en.md (English).
# usage (from the repo root): release_notes.sh <version> <firmware> <twrp image sha256> <owner/repo>
set -euo pipefail
ver=$1 fw=$2 sha=$3 repo=$4
sec() { awk -v v="$ver" '/^## v/{p = ($2 == v)} p' "$1"; }
id=$(sec CHANGELOG.md)
en=$(sec CHANGELOG.en.md)
if [ -z "$id" ] || [ -z "$en" ]; then
  echo "::error title=CHANGELOG::no '## $ver' section in both CHANGELOG.md and CHANGELOG.en.md" >&2
  exit 1
fi
cat <<EOF
**$ver** · firmware \`$fw\` · Xiaomi 14T Pro (rothko)

$id

**Pasang:** ekstrak zip ke folder \`platform-tools\`, jalankan \`1-PASANG-TWRP.bat\`. Sudah punya TWRP atau mau update? Lihat [panduan](https://github.com/$repo/blob/HEAD/docs/pasang.md).

<details><summary>English</summary>

$en

**Install:** extract the zip into \`platform-tools\`, run \`1-PASANG-TWRP.bat\`. Already have TWRP or updating? See the [guide](https://github.com/$repo/blob/HEAD/docs/pasang.en.md).

</details>

---
TWRP image sha256 \`$sha\` · Cek keaslian / authenticity: https://github.com/$repo/attestations

⚠️ Pra-rilis — backup data dulu. / Pre-release — back up your data first.
EOF
