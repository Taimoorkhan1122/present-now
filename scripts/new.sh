#!/bin/sh
# usage: new.sh <out-dir> "<deck title>" "<footer text>"
# Copies the deck template into <out-dir> and fills the title/footer placeholders.
set -e
[ $# -eq 3 ] || { echo "usage: new.sh <out-dir> \"<deck title>\" \"<footer text>\"" >&2; exit 2; }
OUT=$1
[ -e "$OUT/src/slides" ] && { echo "refusing: $OUT/src/slides already exists" >&2; exit 1; }
SKILL=$(cd "$(dirname "$0")/.." && pwd)
mkdir -p "$OUT"
cp -R "$SKILL/template/." "$OUT/"
mkdir -p "$OUT/src/slides"
# HTML-escape user text, then escape sed replacement specials
esc() { printf '%s' "$1" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's/[&|\\]/\\&/g'; }
sed -i.bak "s|__TITLE__|$(esc "$2")|" "$OUT/src/head.html" && rm "$OUT/src/head.html.bak"
sed -i.bak "s|__FOOTER__|$(esc "$3")|" "$OUT/src/tail.html" && rm "$OUT/src/tail.html.bak"
chmod +x "$OUT/build.sh"
echo "scaffolded $OUT — next: fill the __PLACEHOLDERS__ in $OUT/AUTHORING.md"
