# Authoring contract for slide fragments

The deck is one HTML file stitched by `./build.sh` from `src/head.html` (all CSS) +
`src/slides/*.html` (one file per slide, sorted by filename) + `src/tail.html` (the engine).
Read `src/head.html` once to see every available class.

## The talk

- **Event:** __EVENT__ (__MINUTES__ min total, __SLIDE_COUNT__ slides).
- **Audience:** __AUDIENCE__
- **The one takeaway:** __TAKEAWAY__
- **Subject and sources:** __SOURCES__. Every fact on a slide (path, command, name, number,
  quote) is verified by reading the source. Illustrative examples are fine when labeled
  `Illustrative`.
- **Tone:** calm, confident, few words. A slide is read in seconds; the speaker notes carry the
  detail.

## Slide plan

| File | Slide | Interaction | Time |
|---|---|---|---|
__PLAN_ROWS__

## Fragment shape (exactly this)

```html
<section class="slide" id="s-gate" data-title="The gate says no">
  <p class="kicker">04 · The gate</p>
  <h2>Headline with an <em>accent</em> phrase</h2>
  ... content ...
  <aside class="notes">
    <p><strong>~1:30.</strong> What to say, 3–6 short sentences.</p>
    <p>Transition line into the next slide.</p>
  </aside>
</section>
<style>
  /* Optional. Every selector starts with this slide's id, e.g. #s-gate .lane { ... } */
</style>
<script>
  // Optional. Scoped to this slide only.
  (() => {
    const root = document.getElementById('s-gate');
    // query inside root only
  })();
</script>
```

- `id` = `s-<short-name>`, unique. `data-title` = short title (shown in the presenter window).
- `<aside class="notes">` is required. It is hidden on the slide; the presenter sees it via `N`/`P`.
- `class="slide center"` vertically centers a slide's content (title/close slides).

## Canvas and sizing

- Fixed **1600 × 900** canvas, padding 88px top / 120px sides / 96px bottom: the content box is
  **1360 × 716 px** (x 120–1480, y 88–804). Everything fits inside it with no scrolling, including
  every state of every interactive panel at its tallest.
- Body text ≥ 21px. Code ≥ 19px, ≤ 8 lines per block, ~60 chars wide.
- One idea per slide, ≤ 40 words of visible text (excluding code and interactive data).
- A grid with `fr` rows inside an auto-height container grows to its content. Give such a grid a
  definite `height`, and push trailing content to the bottom with `.mt-auto`.

## Building blocks (from `src/head.html`)

- Type: `.kicker`, `h1`, `h2` (one `<em>` accent phrase), `h3`, `p`, `.lede`, `.small`, `.muted`,
  `.accent`, `.callout`, `.big-number`, inline `<code>`, `ul.clean`.
- Layout: `.grid-2`, `.grid-3`, `.grid-4`, `.row`, `.stack`, `.grow`, `.mt-auto`.
- Boxes: `.card` (optional `<span class="num">01</span>`), `.chip` (+ `.ok`, `.bad`, `.hot`).
- Code: `<pre><code>…</code></pre>`, colored by hand with `<span class="tok-k|tok-s|tok-c|tok-f">`;
  mark a bad/good line with `tok-bad` / `tok-ok`. Escape `<`, `>`, `&` as entities.
- Buttons: `<button type="button" class="btn">`; active state `.is-active` or `aria-pressed="true"`.
- **Tabs / before–after toggle (no JS needed):**
  ```html
  <div class="stack" data-tabs>
    <div class="tab-list" role="tablist">
      <button data-tab="before" aria-selected="true">Before</button>
      <button data-tab="after">After</button>
    </div>
    <div class="tab-panel" data-panel="before">…</div>
    <div class="tab-panel" data-panel="after">…</div>
  </div>
  ```
  The engine wires clicks, `aria-selected`, and `hidden`, and fires `tabs:change`. Tab buttons may
  be restyled (as nodes, grid cells, …) under the slide's id.
- **Step reveal (no JS needed):** `class="step"` on elements. Right-arrow reveals them one at a
  time before moving to the next slide.
- `slide:enter` fires on the `<section>` each time the slide is shown: reset custom interactive
  state there.

## Hard rules

- Write only your own files in `src/slides/`. `src/head.html`, `src/tail.html`, `build.sh`, other
  slides, and the subject's sources stay untouched.
- The orchestrator builds and does all browser QA: leave `build.sh` and the browser alone.
- Self-contained: inline SVG and system fonts only; no CDN, web fonts, or images by URL.
- Styling lives in the slide-scoped `<style>` block, never in `style="…"` attributes.
- Every `<button>` has `type="button"` and visible text or an `aria-label`. Everything clickable
  is a real `<button>`.
- Keyboard shortcuts belong to the engine: never bind global keys or `preventDefault` arrows.
- Prose has no emoji, exclamation marks, or marketing fluff. Code keeps its real symbols
  (`!`, `&&`, …).
