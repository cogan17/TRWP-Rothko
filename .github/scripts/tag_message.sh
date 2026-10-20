#!/bin/bash
# Annotated tag message (what GitHub's Tags page shows): plain text from both changelogs.
# usage (from the repo root): tag_message.sh <version> <firmware>
set -euo pipefail
ver=$1 fw=$2
plain() { awk -v v="$ver" '/^## v/{p = ($2 == v); next} p' "$1" | sed -e 's/^### //' -e 's/\*\*//g' -e '/./,$!d' | cat -s; }
id=$(plain CHANGELOG.md)
en=$(plain CHANGELOG.en.md)
if [ -z "$id" ] || [ -z "$en" ]; then
  echo "::error title=CHANGELOG::no '## $ver' section in both CHANGELOG.md and CHANGELOG.en.md" >&2
  exit 1
fi
printf 'TWRP rothko %s · firmware %s\n\n%s\n\nEnglish\n\n%s\n' "$ver" "$fw" "$id" "$en"
