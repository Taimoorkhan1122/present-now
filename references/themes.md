# Themes

`template/src/head.html` ships the **light editorial** theme (warm off-white paper, serif
headlines, one burnt-orange accent). Every color is a `:root` token, so a theme is an override
block pasted just before `</style>` in the deck's `src/head.html`. Later rules win.

## Dark, terminal-flavored

```css
/* theme: dark */
:root {
  --paper: #141413; --paper-2: #242320; --card: #1c1b19;
  --ink: #f3efe7; --ink-2: #d9d3c8; --muted: #958e83; --rule: #34322e;
  --accent: #ff8f5a; --accent-soft: #3d261b;
  --ok: #8fd19b; --ok-soft: #1f3324; --bad: #ff8a7e; --bad-soft: #3d201d;
}
h1, h2 { font-family: var(--sans); font-weight: 600; letter-spacing: -.02em; }
.tok-k { color: #d3a6ff; } .tok-s { color: #9fd8a6; } .tok-f { color: #8ab8ff; }
.btn.is-active code, .btn[aria-pressed="true"] code, [aria-selected="true"] code { background: rgba(0,0,0,.14); }
.notes-panel { background: #2a2926; color: var(--ink); }
```

## Brand

Keep the light (or dark) block and replace only `--accent` (the brand color) and `--accent-soft`
(the same hue at ~15% strength over `--paper`). When the subject is a repo with design tokens
(a Tailwind `@theme` block, CSS custom properties, a tokens file), lift its primary/brand color
from there. Check the accent against `--paper` for ≥ 4.5:1 contrast on kicker-sized text.
