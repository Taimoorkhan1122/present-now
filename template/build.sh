#!/bin/sh
# Stitch shell + slide fragments (sorted by filename) into one self-contained deck.html.
cd "$(dirname "$0")" && cat src/head.html src/slides/*.html src/tail.html > deck.html && echo "built deck.html"
