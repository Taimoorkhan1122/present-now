#!/bin/sh
# usage: qa.sh <deck.html> [out-dir]
# For every slide at 1600x900: reveal all steps, screenshot it, then click every button on the
# slide and report any element that leaves the 1360x716 content box. Ends with console errors.
# Needs chrome-devtools-axi. Run it alone: anything else driving the same browser skews results.
set -e
[ -f "$1" ] || { echo "usage: qa.sh <deck.html> [out-dir]" >&2; exit 2; }
DECK="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
OUT=${2:-/tmp/present-now-qa}
mkdir -p "$OUT"
axi=chrome-devtools-axi
first() { head -1 | sed -e 's/^result: //' -e 's/^"\\"//' -e 's/\\""$//'; }

$axi open "file://$DECK?r=$(date +%s)#1" >/dev/null 2>&1
$axi resize 1600 900 >/dev/null 2>&1
N=$($axi eval "() => String(document.querySelectorAll('.deck > .slide').length)" 2>&1 | first | tr -cd '0-9')
[ -n "$N" ] && [ "$N" -gt 0 ] || { echo "no slides found in $DECK" >&2; exit 1; }

AUDIT='() => {
  const s = document.querySelector(".slide.active");
  const d = document.querySelector(".deck").getBoundingClientRect();
  const k = d.width / 1600;
  const out = () => [...s.querySelectorAll("*")].filter((e) => {
    if (e.closest(".notes") || e.closest("style,script")) return false;
    const r = e.getBoundingClientRect();
    if (!r.width || !r.height) return false;
    const x1 = (r.left - d.left) / k, x2 = (r.right - d.left) / k;
    const y1 = (r.top - d.top) / k, y2 = (r.bottom - d.top) / k;
    // inline glyph boxes (italic ascenders/descenders) legitimately poke past the line box
    const pad = getComputedStyle(e).display === "inline" ? 10 : 1;
    return x1 < 119 || x2 > 1481 || y1 < 88 - pad || y2 > 804 + pad;
  }).slice(0, 3).map((e) => e.tagName.toLowerCase() + (typeof e.className === "string" && e.className.trim() ? "." + e.className.trim().split(/\s+/).join(".") : ""));
  const issues = [];
  const base = out();
  if (base.length) issues.push("default: " + base.join(", "));
  s.querySelectorAll("button").forEach((b) => {
    b.click();
    const o = out();
    if (o.length) issues.push("after [" + b.textContent.trim().slice(0, 30) + "]: " + o.join(", "));
  });
  s.dispatchEvent(new CustomEvent("slide:enter"));
  return issues.length ? issues.join(" | ") : "ok";
}'

i=1
while [ "$i" -le "$N" ]; do
  # Separate calls: the hashchange handler resets steps, so reveal only after it has run.
  $axi eval "() => { location.hash = '#$i'; return 1 }" >/dev/null 2>&1
  $axi eval "() => { document.querySelectorAll('.slide.active .step').forEach((s) => s.classList.add('shown')); return 1 }" >/dev/null 2>&1
  $axi screenshot "$OUT/slide-$i.png" >/dev/null 2>&1
  echo "slide $i: $($axi eval "$AUDIT" 2>&1 | first)"
  i=$((i + 1))
done
echo "screenshots: $OUT/slide-1.png … slide-$N.png"
echo "console errors:"
$axi console --type error 2>&1 | sed -n '2,12p'
