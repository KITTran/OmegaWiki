---
name: create-slides
description: Author Reveal.js slides (Obsidian + obsidian-advanced-slides) following the formatting, style, and sourcing rules in docs/slides-guide.en.md
argument-hint: "<output-path> [--from <source>] [--type paper-review|ideas|results|talk]"
---

# /create-slides

> Author or update a Markdown slides file under `wiki/outputs/` following the unified rule set in `docs/slides-guide.en.md`.
> Default engine: **Obsidian + plugin [`obsidian-advanced-slides`](https://github.com/MSzturc/obsidian-advanced-slides)** (Reveal.js under the hood).

## Invocation

Manual command: `/create-slides <output-path> [--from <source>] [--type <slide-type>]`

## Inputs

- `<output-path>` (required): path to the slides file to create / update, e.g. `wiki/outputs/my-talk-slides.md`
- `--from <source>` (optional): content source for building slides. Can be:
  - A slug or path to a wiki page (`papers/`, `topics/`, `Summary/`, `experiments/`, `claims/`, `ideas/`)
  - A path to an existing raw note file
  - A comma-separated list of slugs when synthesizing multiple sources
  - Omit if the user will describe content directly in the request
- `--type <slide-type>` (optional): presentation type for selecting the appropriate pattern. Supported values:
  - `paper-review` — related work / literature survey of multiple papers (default 3-layer flow from Section 7.1)
  - `ideas` — idea / method proposal (Theory → Rationale pattern from Section 7.2)
  - `results` — experiment results reporting (results/data slide from Section 7)
  - `talk` — comprehensive talk / research summary (combining multiple patterns)
  - Omit → auto-detect from content or ask the user

## Outputs

- Markdown slides file at `<output-path>` with:
  - YAML frontmatter for Reveal.js config + `<style>` block for left alignment
  - Title slide, content slides with proper hierarchy, closing slide
  - Equations, tables, images, references following guide rules
- `wiki/index.md` update if the output resides under `wiki/outputs/`
- Append to `wiki/log.md`: `## [{date}] create-slides | <short description>`

## Wiki Interactions

### Reading
- Required: `docs/slides-guide.en.md` — sole rule source; must open before writing any slide
- On-demand: wiki pages specified by user via `--from`
- Optional: `docs/runtime-page-templates.vi.md` if the output is a wiki page outside `outputs/`

### Writing
- `<output-path>` (new or updated slides file)
- `wiki/index.md` (if output falls under a listed category)
- `wiki/log.md` (append-only)

## Steps

### STEP 1: Load Rules & Determine Scope

1. **Read `docs/slides-guide.en.md` in full** — this is the sole source for all formatting, style, sourcing, and slide pattern rules. Do not write slides without re-reading the guide in the current session.
2. Determine:
   - Slide type (`--type` or infer from request)
   - Primary language (VI / EN) — consistent throughout the file
   - Estimated slide count & main flow
3. If topic / scope info is insufficient, **ask the user before drafting**; do not fabricate content.

### STEP 2: Gather Sourced Content

1. For each source in `--from`, read the page to extract:
   - Standard title, venue / year, importance score
   - Core method, key equation, quantitative results
   - Slug for end-of-slide attribution
2. Classify every claim to be put on slides per Section 7.3:
   - **Sourced fact** — must include slug/citation/link
   - **Experimental observation** — must include experiment slug + seed + metric
   - **Hypothesis** — must be clearly marked with hedge wording
3. **Do not fabricate numbers, citations, or claims**. If the source lacks required information, write as a hypothesis or omit.

### STEP 3: Build Slide Skeleton

Apply the pattern matching `--type` as per `docs/slides-guide.en.md`:

- **`paper-review`** → 3-layer flow from Section 7.1: topic overview slide → one slide per paper (header / method / results / Ref) → summary & gaps slide.
- **`ideas`** → Section 7.2 pattern: overview table slide → one slide per idea (Theory → Rationale).
- **`results`** → Section 7 "results/data slide" with two-column metric table + figure layout.
- **`talk`** → combined: title → motivation → related work (paper-review) → contributions (ideas) → results → conclusion.

Always include:
1. Title slide (H1 + subtitle + author · date)
2. Table of contents slide (if multiple sections)
3. Sections (H1) containing content slides (H2)
4. Closing / Q&A / overall references slide

### STEP 4: Write Slides Following the Guide

Each slide must pass these rules (cross-check against the guide as needed):

1. **Frontmatter** (Section 1): YAML + `<style>` block; `center: false`, `text-align: left`, font sizes per guide.
2. **Hierarchy** (Section 2): H1 for section openers, H2 for content slides, H3 for sub-headings, `---` between slides.
3. **Two-column** (Section 3): `<split even gap="2">` with `<div>` for text, images outside `<div>`.
4. **Tables** (Section 4): alignment `:---:` / `---:`, bold important rows, `<small>` for secondary tables.
5. **Equations** (Section 5):
   - Only `$$...$$` (block) and `$...$` (inline); no LaTeX environments
   - Exponents in `{}`: `x^{2}`, `\nabla^{2}`, `10^{-3}`
   - Multi-char subscripts in `{}`: `\mathcal{L}_{\mathrm{total}}`
   - Single-char subscripts (`\mu_1`, `K_2`) left as-is
   - `\mathrm{}` for text in math; `\|...\|` for norms; `\cdot` for multiplication
   - **Standalone block equations must be centered** in preview: wrap `<div style="text-align: center;">` per-equation, or add a global CSS rule
6. **Images** (Section 6): Obsidian syntax `![[path|widthxheight]]`; always specify dimensions.
7. **Writing style** (Section 7):
   - Professional, neutral, not over-telegraphic, smooth to read
   - Avoid advertising tone, imperatives, exclamations, non-standard abbreviations
   - Bold for names / metrics / keywords; `—`, `→`, `·` in proper context
8. **Sourcing** (Section 7.3):
   - Every fact must have an authoritative source (peer-reviewed / official doc / experiment with log)
   - Do not cite blog / tweet / unverified AI-generated content
   - Every number accompanied by metric / baseline / dataset / slug
   - Mark hypotheses clearly ("may", "expected", "hypothesis")
9. **Citations** (Section 8): `<small>Ref: slug-a · slug-b</small>` at end of slide when using external sources.

### STEP 5: Self-Review per Section 11 Checklist

Before reporting completion, check off every item in Section 11's checklist — split into two groups:

**Format & style:**
- [ ] Complete frontmatter + `<style>` left-align + `center: false`
- [ ] H1 for section opens only; `---` with blank lines before/after
- [ ] Images have `|widthxheight`; tables have alignment markers when needed
- [ ] Equations use `$$...$$` / `$...$`; exponents `^{}`; multi-char subscripts `_{}`
- [ ] Standalone block equations are centered (method 1 or method 2)
- [ ] Source citations at slide bottom via `<small>`
- [ ] Professional, neutral, smooth writing style
- [ ] One consistent language; content does not overflow slides

**Sourcing & authenticity:**
- [ ] Every fact has a source; no blog / tweet / guesswork as fact
- [ ] Hypotheses clearly marked
- [ ] Experimental observation includes experiment slug + seed + metric
- [ ] Every number has full context (metric / baseline / dataset / source)
- [ ] Fact and hypothesis not mixed in the same sentence
- [ ] End-of-slide references in correct format
- [ ] Literature claim includes confidence score when available

If any item fails → fix slides before reporting.

### STEP 6: Update Navigation & Log

1. If the output is under `wiki/outputs/`, add an entry to `wiki/index.md` under the `Outputs` category. See `docs/runtime-support-files.vi.md` for the exact format.
2. Append to `wiki/log.md`:
   ```markdown
   ## [{YYYY-MM-DD}] create-slides | <short content description>
   ```
3. **Do not touch `graph/`**.

### STEP 7: Report

- List: file path, slide count, slide type, sources used
- 1–2 line summary of main content
- Remind the user to open with `obsidian-advanced-slides` for preview, and check equation centering and column layout visually

## Constraints

- **`docs/slides-guide.en.md` is the sole rule source** — every formatting / style / sourcing decision must consult it; do not invent new rules.
- **Do not fabricate content**: if a source is missing, do not write it; if a claim lacks backing, mark it as a hypothesis per Section 7.3.
- **No LaTeX environments** (`\begin{equation}`, `\begin{align}`) — MathJax on Reveal.js is not stable with them.
- **Exponents always wrapped in `{}`**: `x^{2}`, not `x^2`; multi-char subscripts in `{}`; single-char subscripts left as-is.
- **Standalone block equations must be centered** in preview (per guide Section 5).
- **One primary language** throughout the file; standardized technical terms may stay in English.
- **Sourcing is mandatory**: satisfy Section 11 "Sourcing & authenticity" checklist before reporting completion.
- **Do not edit `graph/`**; update `index.md` and append to `log.md`.
- **Do not overwrite existing slides files** without user confirmation if the existing content was not produced by this skill.

## References

- `docs/slides-guide.en.md` — full rule set: frontmatter, hierarchy, two-column, tables, equations, images, style, sourcing, checklist
- Plugin engine: [`obsidian-advanced-slides`](https://github.com/MSzturc/obsidian-advanced-slides)
- `docs/runtime-page-templates.vi.md` — general Markdown rules for cross-referencing equation rules on non-slide pages
- `docs/runtime-support-files.vi.md` — `index.md` / `log.md` format for navigation updates
