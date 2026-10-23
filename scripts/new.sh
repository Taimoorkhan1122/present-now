#!/bin/sh
# usage: new.sh <out-dir> "<deck title>" "<footer text>" [theme]
# Copies the deck template into <out-dir>, fills the title/footer placeholders, and applies a
# theme from themes/ (default: editorial, which is built into the template).
set -e
[ $# -eq 3 ] || [ $# -eq 4 ] || { echo "usage: new.sh <out-dir> \"<deck title>\" \"<footer text>\" [theme]" >&2; exit 2; }
OUT=$1
THEME=${4:-editorial}
SKILL=$(cd "$(dirname "$0")/.." && pwd)
CSS="$SKILL/themes/$THEME.css"
case $THEME in *[!a-z0-9-]*) CSS=/nonexistent ;; esac
[ "$THEME" = editorial ] || [ -f "$CSS" ] || {
  echo "unknown theme '$THEME'; pick one of: editorial $(cd "$SKILL/themes" && ls *.css | sed 's/\.css$//' | tr '\n' ' ')" >&2; exit 2; }
[ -e "$OUT/src/slides" ] && { echo "refusing: $OUT/src/slides already exists" >&2; exit 1; }
mkdir -p "$OUT"
cp -R "$SKILL/template/." "$OUT/"
mkdir -p "$OUT/src/slides"
# HTML-escape user text, then escape sed replacement specials
esc() { printf '%s' "$1" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's/[&|\\]/\\&/g'; }
sed -i.bak "s|__TITLE__|$(esc "$2")|" "$OUT/src/head.html" && rm "$OUT/src/head.html.bak"
sed -i.bak "s|__FOOTER__|$(esc "$3")|" "$OUT/src/tail.html" && rm "$OUT/src/tail.html.bak"
# A theme is an override block placed just before </style>, so its rules win.
if [ "$THEME" != editorial ]; then
  awk -v css="$CSS" '/^<\/style>/ { while ((getline l < css) > 0) print l } { print }' \
    "$OUT/src/head.html" > "$OUT/src/head.html.tmp" && mv "$OUT/src/head.html.tmp" "$OUT/src/head.html"
fi
chmod +x "$OUT/build.sh"
echo "scaffolded $OUT (theme: $THEME) — next: fill the __PLACEHOLDERS__ in $OUT/AUTHORING.md"
