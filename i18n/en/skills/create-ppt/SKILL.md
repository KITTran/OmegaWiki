---
name: create-ppt
description: Build a polished PowerPoint (.pptx) deck from a paper PDF — embed original figures + rendered equations, with critical analysis, through visual QA; following the rules in docs/ppt-guide.vi.md
argument-hint: "<output-dir-path> [--from <paper.pdf|slug>] [--type seminar|talk|intro]"
---

# /create-ppt

> Build or update a **real PowerPoint `.pptx` file** under `wiki/outputs/<deck-slug>/` from a paper PDF (or another content source), built with **pptxgenjs**.
> Sole rule source: **`docs/ppt-guide.vi.md`** — read it in full before building.
>
> Unlike `/create-slides` (Reveal.js/Markdown on Obsidian): this skill outputs a `.pptx` file that opens in PowerPoint/Keynote, embedding the paper's original figures and equations rendered from LaTeX.

## Invocation

Manual command: `/create-ppt <output-dir-path> [--from <source>] [--type seminar|talk|intro]`

## Inputs

- `<output-dir-path>` (required): the deck directory, e.g. `wiki/outputs/dal-pinn-presentation/`. Every artifact (script, figures, equations, `.pptx`) lives inside it.
- `--from <source>` (optional): content source — a path to `raw/papers/<paper>.pdf`, a wiki page slug, or empty if the user describes the content directly.
- `--type <type>` (optional):
  - `seminar` — deep-technical, full derivation + every figure + critical analysis (default for paper review)
  - `talk` — general talk, balanced intuition/math
  - `intro` — overview, few equations
  - Empty → ask the user.

## Outputs

- Deck directory `wiki/outputs/<deck-slug>/` containing:
  - `build_deck.js` — pptxgenjs script (living template, reusable)
  - `figures/` — figures cropped from the paper at 300 DPI + `figures/eq/` rendered equations + `figures/dims.json`
  - `<Deck-Name>.pptx` — final output
- Update `wiki/index.md` if the output is under `wiki/outputs/`
- Append `wiki/log.md`: `## [{date}] create-ppt | <short description>`

## Wiki Interaction

### Read
- **Required**: `docs/ppt-guide.vi.md` — the sole rule source; open it before building.
- Source-dependent: `raw/papers/<paper>.pdf` or a wiki page per `--from`.

### Write
- Deck directory `wiki/outputs/<deck-slug>/`
- Temporary files from reading the paper → `raw/tmp/<slug>/` (additions only — never overwrite user-owned inputs)
- `wiki/index.md` (if the output belongs to a catalog category) and `wiki/log.md` (append-only)

## Steps

### STEP 1: Load Rules & Ask Decisions

1. **Read `docs/ppt-guide.vi.md` in full** — do not build without re-reading the guide in the current session.
2. Ask the user the required decisions (Section 1 of the guide): **format, audience/depth, length, figure handling, critical analysis, font, equation font, color palette**. Ask font + palette **up front** — these are the most likely to force a rebuild.
3. Verify the toolchain (Section 2): PyMuPDF, matplotlib, pptxgenjs (installed locally), `soffice`. Check the needed fonts with `fc-list | grep -i <font>`.

### STEP 2: Read the Paper & "See" the Figures

Per Section 4 of the guide:
1. Render every PDF page to an image (PyMuPDF, ~110 DPI) and **Read the pages that contain figures** with vision to confirm each figure's content.
2. Extract the full text (`page.get_text()`) to capture the technical detail, numbers, and equations.
3. **Do not fabricate**: numbers/tables/citations must come straight from the paper.

### STEP 3: Crop Figures & Render Equations

1. Crop each figure at 300 DPI by caption bbox (Section 4) → use descriptive names (`fig1_architecture.png`…) → **Read a few cropped figures** to confirm they are not clipped/misaligned.
2. Render equations from LaTeX → transparent PNG with matplotlib (Section 5); set `mathtext.fontset` per the chosen equation font; note `\left|\right|` in place of `\big`.
3. Export `figures/dims.json` (sizes of every PNG) to preserve aspect ratio when embedding.

### STEP 4: Write `build_deck.js`

Per Sections 6–7 of the guide:
1. Define the **palette as constants, assigned by role**; choose fonts (sans for text, serif math for equations, mono for code).
2. Build the **reusable helpers**: `head`, `footer`, `divider`, `card`, `bullets`, `fitImg` (aspect-preserving via `dims.json`), `caption`, a `sh()` shadow factory.
3. **Light background** for every slide (unless the user requests otherwise); special slides add a **left vertical accent band**.
4. Build content with the **5-part frame**: Motivation → Method → Architecture → Experiments → Discussion. One main idea per slide; concise, professional titles (avoid strong verbs/casual phrasing).
5. Respect the **pptxgenjs pitfalls** (Section 9): hex without `#`, no 8-char hex; real bullets; shadow factory; install locally.

### STEP 5: Build & QA Loop (mandatory ≥ 1 round)

Per Section 8 of the guide:
1. `node build_deck.js` → `.pptx`.
2. `soffice --headless --convert-to pdf` → use PyMuPDF to render the PDF to PNG (no `pdftoppm` needed).
3. **QA with a subagent (fresh eyes)** — split the slides into 2 groups, prompt it to *assume there are bugs*: overflow/overlap/contrast/caption colliding with footer/truncated tables. When changing the theme: also ask "any leftover old-theme colors?".
4. Fix issues → **re-render the fixed slides to verify**. Note: a subagent report of "content compressed / figures tiny" is usually an artifact of 100-DPI rendering → re-render that slide at 140 DPI and Read it yourself before "fixing".
5. Content QA: `python -m markitdown <Deck>.pptx | grep -iE "xxxx|lorem|undefined|TODO"` must be empty.

### STEP 6: Self-Review against the Section 11 Checklist

Go through every item in Section 11 of the guide (figures & equations · design & layout · content & authenticity). Any item that fails → fix before reporting.

### STEP 7: Update Navigation & Log

1. If the output is under `wiki/outputs/`, add an entry to `wiki/index.md` under the `Outputs` category (see `docs/runtime-support-files.vi.md`).
2. Append `wiki/log.md`: `## [{YYYY-MM-DD}] create-ppt | <short description>`.
3. **Do not touch `graph/`**.

### STEP 8: Report

- List: the `.pptx` path, slide count, type, source, number of embedded figures.
- Summarize the main content in 1–2 lines.
- Remind the user to open it in PowerPoint/Keynote; the QA PDF is in the deck directory for a quick preview.

## Constraints

- **`docs/ppt-guide.vi.md` is the sole rule source** — every format/design/QA decision is looked up there; do not invent extra rules.
- **Do not fabricate content**: numbers/citations come from the paper; if missing, drop or mark as a hypothesis.
- **The paper's original figures are embedded verbatim** — do not redraw, do not fabricate charts.
- **Equations are rendered from LaTeX** (PowerPoint has no LaTeX) — do not type math symbols as plain text.
- **`raw/` is user-owned**: only add temporary files under `raw/tmp/`, never overwrite inputs.
- **The QA loop is mandatory** — do not report completion without at least one round of subagent QA + fix + re-render verification.
- **Do not overwrite an existing `.pptx`** not produced by this skill without confirming with the user.
- **Do not edit `graph/`**; update `index.md` and append to `log.md`.

## References

- `docs/ppt-guide.vi.md` — full rules: toolchain, figure cropping, equation rendering, design system, content frame, QA loop, pptxgenjs pitfalls, checklist
- `skills/create-ppt/references/build_deck.template.js` — ready-to-use pptxgenjs scaffold (palette + `head/footer/divider/card/bullets/fitImg/caption` helpers + shadow factory). Copy into the deck directory, swap palette/content, then `node build_deck.js`
- `docs/runtime-support-files.vi.md` — `index.md` / `log.md` format when updating navigation
- pptxgenjs: <https://github.com/gitbrent/PptxGenJS>
- Compare: `/create-slides` for Reveal.js/Markdown output (Obsidian); `/create-ppt` for a real `.pptx` file
