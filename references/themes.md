# Themes

Five themes. `editorial` is built into `template/src/head.html`. Each other theme is an override
block in `<skill>/themes/<name>.css`; `scripts/new.sh` takes the theme name as its 4th argument
and pastes that block just before `</style>` in the deck's `src/head.html`, so its rules win.
Every color is a `:root` token, which is why slides use `var(--…)` colors only.

## Picker

| Theme | Description (copy into the question) | Fits |
|---|---|---|
| `editorial` | Warm off-white paper, serif headlines, burnt-orange accent. Calm and bookish. | most talks; the default |
| `terminal` | Near-black, sans headlines, orange accent. Feels like a code editor. | developer audiences, live coding, dark rooms |
| `swiss` | Pure white, bold sans headlines, cobalt-blue accent. Crisp and modern. | product and engineering reviews, bright rooms, weak projectors |
| `midnight` | Deep navy, serif headlines, gold accent. Polished and quiet. | keynotes, conference stages, evening events |
| `sage` | Soft green-grey paper, serif headlines, deep-teal accent. Gentle and warm. | workshops, onboarding, non-technical audiences |

Ask with one `AskUserQuestion` question; it holds at most four options. Labels are the theme
names capitalized. Put the theme whose **Fits** best matches the audience and room first, marked
`(Recommended)` (Editorial when nothing fits better), then the next three best. Name the left-out
theme and "a brand color (hex)" in the question text, so the user can type either under Other.

## Brand

Pick the closest theme, then append this after it in the deck's `src/head.html` (still before
`</style>`):

```css
/* brand */
:root { --accent: #RRGGBB; --accent-soft: #RRGGBB; }
```

`--accent` is the brand color; `--accent-soft` is the same hue at about 15% strength over
`--paper`. When the subject is a repo with design tokens (a Tailwind `@theme` block, CSS custom
properties, a tokens file), lift its primary/brand color from there. Check `--accent` against
`--paper` for at least 4.5:1 contrast: kickers are small accent-colored text.
