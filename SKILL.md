---
name: present-now
description: Build a talk-ready interactive HTML slide deck (one self-contained file with clicker-safe navigation, step reveals, tabs, speaker notes, and a presenter window) by interviewing the user, writing slides with parallel subagents, and QA-ing every slide in a real browser. Use when the user wants a presentation, slides, a deck, or a talk or workshop to present, as HTML rather than PowerPoint.
---

# Present now

Turn a subject (a repo, documents, an idea) into a deck the user can present today: one
`deck.html` on a fixed 1600×900 canvas that scales to any screen, light editorial look by default.
You own the interview, the plan, the scaffold, and QA; subagents write the slides in parallel.

Skill files (paths relative to this skill's directory, written `<skill>/` below):

- `template/`: the deck shell. `src/head.html` holds all CSS (colors are `:root` tokens),
  `src/tail.html` the engine, `build.sh` stitches `src/slides/*.html` between them, and
  `AUTHORING.md` is the contract every slide writer follows.
- `scripts/new.sh`: scaffolds a deck from the template.
- `scripts/qa.sh`: screenshots every slide, reports content-box overflow for every click state,
  and lists console errors.
- `themes/`: override blocks for the non-default themes.
- `references/themes.md`: the theme picker and brand colors.

## 1. Interview

Ask with `AskUserQuestion`: at most two rounds of up to four questions, your recommended option
first. Round one:

- **Audience**: who is in the room, and how familiar they are with the subject.
- **Takeaway**: the one thing they should do or believe afterwards. Every slide serves it.
- **Must-show** (multi-select): the parts of the subject that have to be on screen.
- **Format**: slides with interactive pieces; slides plus a live-demo cue slide (what to show goes
  in its notes); or slides plus a recorded demo (`<video>` with a local file beside `deck.html`).

Round two settles what round one left open, plus logistics:

- Any **tension**, e.g. the takeaway leans on something they did not pick as must-show: ask how
  it should appear (one payoff slide, a mention, or left out).
- **Timebox** in minutes, if not given yet.
- **Location**: default `~/presentations/<slug>/`, outside any repo so the repo's checks never
  see it.
- **Look**: one of five themes, or a brand color. Build the question from the picker in
  `references/themes.md`.

Notes (`N`), presenter window (`P`), and progress bar are built in.

Done when audience, takeaway, must-show list, format, timebox, location, and look are known. The
moment the user says to go ahead, stop asking: take the defaults for anything still open, name
them in one line, and continue.

## 2. Recon

Read the subject just enough to plan: for a repo, its README, `AGENTS.md`/`CLAUDE.md`, the
`docs/` index, and the top-level layout; for documents, their headings. Done when, for every
must-show item, you can name the files or sections that prove it. Deep reading is the subagents'
legwork.

## 3. Plan

About one slide per minute. Follow this **arc**, and cut any slide that does not serve the
takeaway:

hook (title) → problem → idea (doubles as the agenda) → one section per pillar (a concept slide,
then a concrete or interactive one) → payoff → what changes for them → close (next-step
checklist, Q&A).

Per slide, decide: file `NN-slug.html`, id `s-slug`, kicker (`01 · Section` inside numbered
sections), a headline with one `<em>` accent phrase, the content, at most one interaction, and a
notes time. Pick the interaction by purpose:

- **Tabs**: compare, before/after, categories.
- **Step reveal**: sequences, agendas.
- **Explore**: a map, hub, or grid where a click shows a detail panel.
- **Simulator**: pick a cause, watch its effect.

Notes times sum to the timebox. Show the plan as a compact table (slide, interaction, time,
total) and build on the user's OK; when they already said go, show it and continue.

## 4. Scaffold

```sh
<skill>/scripts/new.sh <out-dir> "<deck title>" "<footer text>" <theme>
```

For a brand color, append its override to `<out-dir>/src/head.html` (`references/themes.md`,
§ Brand). Fill every
placeholder in `<out-dir>/AUTHORING.md`: event, minutes, slide count, audience, takeaway, sources,
and one plan row per slide. Done when `rg '__[A-Z_]+__' <out-dir>` finds nothing.

## 5. Dispatch

Group the slides into 3–5 **chunks** of 2–3 consecutive slides that share a source area, so each
subagent researches one area. Launch one subagent per chunk, all in a single message (they run
in the background). Default to `model: haiku` with `effort: high`; a model the user names wins.
Each brief takes this shape:

```
You are writing slide fragments for an HTML deck. Work autonomously; do not ask questions.
FIRST read fully: <out-dir>/AUTHORING.md (the contract; follow it exactly) and
<out-dir>/src/head.html (every available class). Then research, read-only: <the specific
paths/sections for this chunk>. Every fact on your slides comes from those sources.

Write exactly these files in <out-dir>/src/slides/ and nothing else:
1. `NN-slug.html`: id `s-slug`, data-title "<title>", kicker `<kicker>`.
   - h2: `<headline with one <em>accent</em> phrase>`
   - <content; the interaction and its default state on slide:enter>
   - notes (~m:ss): <what to say; the transition into the next slide>
2. ...

When done, re-read each file: valid nesting, unique ids, notes present, script scoped, tallest
state fits 1360×716. Reply with the files written and any fact you could not verify.
```

Done when every subagent has reported and every planned file exists. Keep each one's "could not
verify" list for the hand-off.

## 6. Build and QA

```sh
<out-dir>/build.sh && <skill>/scripts/qa.sh <out-dir>/deck.html
```

`qa.sh` prints one line per slide (`ok`, or the elements leaving the content box and the click
that caused it), saves `/tmp/present-now-qa/slide-N.png` with all steps revealed, and lists console
errors. Run it while nothing else drives the browser. View every screenshot, plus one clicked
state per interactive slide. Fix in `src/slides/` yourself (the fixes are small), rebuild, rerun.

Done when every slide reports `ok`, the console is clean, and every screenshot reads cleanly at a
glance: no overlaps, empty boxes, invisible text, or cramped wraps.

Failure modes seen before:

| Symptom | Cause | Fix |
|---|---|---|
| Content overlaps the element below it | a grid with `fr` rows in an auto-height container grows to its content | give the grid a definite `height`; push trailing content down with `.mt-auto` |
| Inline `code` unreadable on a selected control | a slide-specific active style the shell's `code` override misses | scope `code { background: rgba(255,255,255,.16); color: inherit }` under that active selector |
| A box holding only a label | a `.card` wrapping a lone chip or heading | drop the card, keep the label |
| A symbol missing from code (`!`) | the agent stretched the prose rule into code | restore the real symbol |
| Steps hidden in a manual screenshot | revealed in the same tick as a hash change; the `hashchange` handler resets steps | navigate in one call, reveal in the next |
| Screenshots at an odd size | something else drove the shared browser | rerun `qa.sh` alone (it resizes to 1600×900) |

## 7. Hand-off

Run `open <out-dir>/deck.html`, then report:

- the path, and that it is one self-contained file;
- the slide list with interactions and times, and the total against the timebox (name the slide
  to cut if it runs long);
- keys: ←/→/Space/PageUp/PageDown (clicker-safe), Home/End, `N` notes (hide them when the screen
  is mirrored), `P` presenter window, `F` fullscreen; the URL hash keeps the slide across reloads;
- editing: change `src/slides/NN-*.html`, then run `./build.sh`;
- what was not verified: the subagents' unverified facts, and browsers or fonts not tested (the
  macOS serifs fall back to Georgia elsewhere).
