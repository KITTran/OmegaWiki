# Slides Guide: Format, Style & Rules

> General guide for authoring Reveal.js slides in the wiki.
> Applies to every kind of presentation: research summary, paper presentation, technical talk, teaching, project review.
> **Default engine**: Obsidian + plugin [`obsidian-advanced-slides`](https://github.com/MSzturc/obsidian-advanced-slides) (Reveal.js under the hood).

---

## 1. Frontmatter Structure (YAML + CSS)

Each slides file starts with a YAML frontmatter that configures Reveal.js, followed by a `<style>` block:

```yaml
---
theme: black            # or white, league, beige, sky, night, serif, simple, solarized
transition: slide       # or fade, convex, concave, zoom, none
width: 1280
height: 800
center: false           # left-aligned by default
controls: true
progress: true
css: |
  .reveal { font-size: 22px; }
  .reveal h1 { font-size: 1.8em; }
  .reveal h2 { font-size: 1.4em; }
  .reveal h3 { font-size: 1.1em; }
  .reveal table { font-size: 0.75em; }
  .reveal table th, .reveal table td { padding: 4px 8px; }
  .reveal p, .reveal li { font-size: 0.85em; line-height: 1.3; }
  .reveal code { font-size: 0.85em; }
  .reveal pre { font-size: 0.7em; }
  .reveal .MathJax, .reveal mjx-container { font-size: 0.9em !important; }
---
```

**After the frontmatter**, add a separate `<style>` block for further overrides:

```html
<style>
.reveal .slides section { text-align: left; }
.reveal .slides > section,
.reveal .slides > section > section { top: 0 !important; padding-top: 30px; }
</style>
```

**Core principles:**
- **`center: false`** + **`text-align: left`** — left-aligned slides read naturally
- **Reference font sizes**: base 22px (slide-heavy content), H1 ~1.8em, H2 ~1.4em, H3 ~1.1em — adjust to content density
- **Tables**: smaller than the main content ~0.75em, cell padding 4px 8px
- **Math**: ~0.9em (slightly smaller than text to avoid line breaks)
- **`!important`** for properties Reveal.js tends to override (padding, top, MathJax font-size)

**When to adjust the size**: light-text slides → larger font (28-32px); lecture-style (text-heavy) slides → keep 22px as above.

---

## 2. Slide Hierarchy

### Whole-presentation title slide — use `#` at the start of the file

```markdown
# Presentation title

## Subtitle or sub-topic

**Author name** · Date

Short description (e.g. number of papers, number of experiments, scope)
```

### Section title slide — use `#` (H1)

```markdown
# I. Section one
```

Use Roman numerals, ordinals, or a clear title to mark a major section. H1 only for a section's opening slide.

### Content slide — use `##` (H2)

```markdown
## Slide title
```

### Sub-heading within a slide — use `###` (H3)

```markdown
### Sub-group within a slide
```

### Slide separator — `---` (three dashes)

A standalone `---` line creates a new slide. Leave a blank line before and after to avoid confusion with a table/list separator.

---

## 3. Two-Column Layout

Use the custom `<split>` tag with two child `<div>`s:

```markdown
<split even gap="2">

<div>

Left-column content...

</div>

![[path/to/image.png|widthxheight]]

</split>
```

**Rules:**
- `even` — split space evenly; you can change the ratio with `<split left="60" right="40">`
- `gap="2"` — gap between the two columns (em units)
- Left column: text/description; right column: image, table, or summary text
- Always put text content inside a `<div>`; an image may sit outside a `<div>` (the right column is automatic)
- Avoid cramming >5 bullet points into one column — split the slide if too crowded

---

## 4. Tables

### General alignment rules

```markdown
| Col1 | Col2 | Col3 |
|---|:---:|---:|
| left-aligned | center | right-aligned |
```

- `---` → left-aligned (default)
- `:---:` → centered (for short-value columns, labels)
- `---:` → right-aligned (for numeric columns)

### Emphasis within tables

- **Bold** for: the best row / baseline, important values, prominent names
- Use `—` for empty cells / reference baselines
- Use `−` (Unicode minus sign) instead of `-` for negative numbers
- Number `**1**`, `**2**` for ranking
- *Italics* for secondary notes (e.g. `kan-single *(baseline)*`)

### Table size

- Too-wide table → reduce columns, merge metrics, or split into 2 tables
- Too-many-row table (>10) → consider splitting the slide or using `<small>` for the secondary table
- Table headers should be short — avoid more than 2-3 words

---

## 5. Writing Math Equations

### Inline and block formulas

```markdown
Inline: $f(x) = x^{2}$ within a sentence.

Block standalone:
$$\mathcal{L} = w_1 \mathcal{L}_1 + w_2 \mathcal{L}_2$$
```

### Commonly used symbols

| Symbol | Code | Meaning |
|---------|------|---------|
| $\mathcal{L}$ | `\mathcal{L}` | Loss / Lagrangian (calligraphic) |
| $\mathbb{E}$ | `\mathbb{E}` | Expectation (blackboard bold) |
| $\mathcal{N}$ | `\mathcal{N}` | Normal distribution |
| $\mathcal{O}$ | `\mathcal{O}` | Big-O notation |
| $\nabla$ | `\nabla` | Gradient |
| $\partial$ | `\partial` | Partial derivative |
| $\|A\|$ | `\|A\|` | Norm (double pipe) |
| $\|A\|^{2}$ | `\|A\|^{2}` | Squared norm |
| $\propto$ | `\propto` | Proportional to |
| $\mathrm{Tr}(K)$ | `\mathrm{Tr}(K)` | Trace, written roman |
| $\mathrm{MSE}$ | `\mathrm{MSE}` | Abbreviated function name |
| $\cdot$ | `\cdot` | Multiplication dot |
| $\mapsto$ | `\mapsto` | Maps to |
| $\to$ | `\to` | To / implies |
| $\approx$ | `\approx` | Approximately |
| $\sim$ | `\sim` | Distributed as / same order |
| $\gg$ | `\gg` | Much greater than |

### Equation-writing rules

- **Block formula** (`$$...$$`) for important formulas that need to stand out; **inline** (`$...$`) for short symbols/expressions within a sentence
- **Use only `$$...$$`** — no LaTeX environments (`\begin{equation}`, `\begin{align}`); MathJax on Reveal.js does not support them reliably
- Keep formulas **short enough to fit on one line** — a slide is not a paper
- Use `\cdot` instead of `*`
- Use `\|` for the double-bar norm, **not** `||`
- Use `\mathrm{}` for text in math: `\mathrm{MSE}`, `\mathrm{PDE}`, `\mathrm{Tr}`
- **Exponents must go inside `{}`**: for equations of the form `$<operator>^<number>$`, the `<number>` must be inside `{}`
  - Correct: `x^{2}`, `\nabla^{2}`, `N^{2}`, `L^{2}`, `[0,1]^{2}`, `10^{-3}`
  - Wrong: `x^2`, `\nabla^2`, `N^2`, `10^-3`
  - Applies to both single character (`^{2}`) and multi-character (`^{ij}`, `^{-1}`)
  - Single-char subscripts (`\mu_1`, `K_2`, `J_0`) stay as-is, no `{}` needed
- Multi-char subscripts or those with special characters must be wrapped in `{}`: `\mathcal{L}_{\mathrm{total}}`, `x_{i,j}`

### Standalone equations must be centered in preview

Slides use `text-align: left` for all content (per Section 1) — but a **standalone block equation `$$...$$` must be centered** in preview so the equation becomes the visual focal point, reads cleanly, and stands out. This is a convention specific to equations and does not conflict with the left-alignment rule for text.

Because `obsidian-advanced-slides` inherits `text-align: left` from the section CSS, block math defaults to left-aligned. To force centering, use one of two approaches:

**Approach 1 — wrap in a centered `<div>` (recommended, most reliable):**

```markdown
<div style="text-align: center;">

$$\mathcal{L}_\mathrm{total} = w_\mathrm{pde}\mathcal{L}_\mathrm{pde} + w_\mathrm{bc}\mathcal{L}_\mathrm{bc}$$

</div>
```

**Approach 2 — add a global CSS rule in the `<style>` block at the top of the file** (applies to every block math in the file):

```css
.reveal .slides section .math.math-display,
.reveal .slides section mjx-container[display="true"],
.reveal .slides section p:has(> mjx-container[display="true"]) {
  text-align: center !important;
}
```

Choose Approach 2 if the file has many block equations and you want uniform application; choose Approach 1 for specific equations if only a few places need centering.

**Application rules:**
- A block equation `$$...$$` **standalone on its own line** (not within a bullet) → **centered**
- An inline equation `$...$` → stays inline within the sentence, not split onto its own line, not centered
- A block equation inside a bullet point → keep it left-aligned with the bullet (to avoid breaking the list layout)
- An equation with a caption/label → wrap both the equation and the caption in the same `<div style="text-align: center;">`

---

## 6. Images

### Obsidian-style syntax

```markdown
![[path/to/image.png|widthxheight]]
```

- Path relative to the directory containing the slides file
- Size specified in pixels: `|520x440`
- A single dimension may be specified: `|520` (preserves aspect ratio)

### Reference sizes

- **Split column**: 420–520px wide × 340–440px tall
- **Full-screen** (full-width): 800–900px wide
- **Small inline diagram**: 300–400px wide

### When to use an image

General rule: an image must convey something that text cannot in the same area.
- Comparison plots, architecture diagrams, pipeline diagrams
- Maps/heatmaps of spatial data
- Bar/line charts comparing metrics
- Screenshots for a UI/UX presentation

Avoid using images purely for decoration — left-aligned slides with a dark theme already look professional.

---

## 7. Writing Style

### Language

- Vietnamese as the primary language (if the audience is Vietnamese); pick one primary language consistently throughout the slides
- **Keep technical terms in English** when they are standardized in the field (e.g. "loss function", "gradient descent", "API", "framework")
- Do not half-translate — either fully translate or keep the whole phrase as-is
- Quotation marks `""` for quotes, `''` for concepts/labels

### Voice

- **Professional, neutral phrasing that is not overly terse and reads smoothly**
  - Avoid telegraphic clumps like "X good. Y bad." — write "X yields better results than Y under conditions ..."
  - Avoid promotional tone ("breakthrough", "amazing", "super fast") — use objective, quantitative descriptions
  - Avoid non-standard abbreviations / slang (e.g. "ko", "vs.", "etc")
  - Avoid imperative or exclamatory sentences — this is a technical slide, not marketing
  - Bullets may be short, but each bullet should read smoothly like a clause, not a clipped fragment
- **Short bullet points**, no long rambling sentences — still need a subject-predicate to read naturally
- **One idea per line** — if you must wrap many times, it may be better to split the bullet
- **Bold** (`**text**`) for:
  - Names (paper, person, tool, method)
  - Important numbers/metrics
  - Conclusions / keywords to emphasize
- Use `—` (em dash) or `:` to explain / expand
- Use `→` (arrow) for "leads to", "shows", "progresses toward"
- Use `·` (middle dot) as a light separator between short items

### Common slide structures

**Concept / theory slide**

```markdown
## Idea name

**Definition / Theory**

Short description...
$$formula if any$$

**Why it matters** (or "Why this choice")

- Reason 1
- Reason 2

**Implementation / Application**

Short description of usage / pipeline.
```

**Results / data slide**

```markdown
## Experiment / result name

<split even gap="2">

<div>

### Metrics

| Metric | Value |
|---|---|
| Accuracy | **95.2%** |
| Latency | 12 ms |

**Short analysis**

Main cause, comments.

</div>

![[image.png|520x440]]

</split>
```

**Comparison / overview slide**

```markdown
## Topic name

**Common problem**: short description

| Item | Contribution | Imp |
|---|---|:---:|
| Item A | ... | **5** |
| Item B | ... | 4 |
```

---

## 7.1 Paper Review / Literature Survey Pattern

When presenting multiple papers (related work, survey, literature review), use a three-layer flow: **Topic overview → Paper detail → Summary**. Avoid cramming many papers into one table — each paper deserves its own slide so the audience can keep up.

### Overall flow

```
Topic N — Topic name              ← 1 overview slide
├── N.1 Paper A — short slogan     ← 1 slide / paper
├── N.2 Paper B — short slogan     ← 1 slide / paper
└── N.3 Paper C — short slogan     ← 1 slide / paper
Related-work summary               ← 1 closing slide for the section
```

### Topic overview slide

Opens each group of papers — states the common problem, the trade-off, and the list of papers to be presented next.

```markdown
## Topic N — Topic name

**Common problem**: short description of the problem this group of papers addresses

**Trade-off**: state the common trade-off of the approach (if any)

**N representative papers**

- Paper A (Venue Year, Imp **5**) — one-sentence contribution
- Paper B (Venue Year, Imp **4**) — one-sentence contribution
- Paper C (Venue Year, Imp **4**) — one-sentence contribution
```

**Rules:**
- The title uses an em dash `—` to separate the topic number and name: `## Topic 2 — Training stability`
- List 2–4 papers / topic; more than that should be split into sub-topics
- One bullet per paper — do not cram in superfluous metadata

### Per-paper detail slide

This is the core pattern for each paper. A 4-block structure: **Header → Method → Main results → Ref**.

```markdown
## N.X Short-name — one-sentence slogan

**Paper**: *Full title* (Venue Year, Authors if needed) · Imp **5** · secondary metadata

**Method**
- Core idea (1 sentence / bullet)
- Important formula if needed:

$$\text{standalone block math}$$

- Secondary component / architecture / pipeline
- Other notable feature

**Main results** (with benchmark / dataset)
- Main metric with a specific number, **bold**
- A representative example illustrating the strength
- Limitation / applicability condition (if needed for balance)

<small>Ref: `paper-slug-in-wiki`</small>
```

**Rules:**
- Slide title: `## <num>.<num> <Short name> — <slogan>` (e.g. `## 2.1 NTK PINN — diagnosing training failure`)
- The slogan is short (3–7 words) and states the paper's **angle**, not repeating the name
- The `**Paper**:` line at the top: italic title + venue/year + importance score + citations/conf if notable
- **Method**: 3–5 bullets, prioritizing the core idea and 1 key formula (no more than 1 block math / slide)
- **Main results**: must have a **specific number**, no vague claims ("significant improvement" → "reduced $L^{2}$ from X to Y")
- You may use a metric table instead of bullets if the data is multi-dimensional (e.g. I-PINNs with 4 benchmarks)
- Always end the slide with `<small>Ref: ...</small>` pointing to the paper slug in the wiki

### Related-work summary slide

Place at the end of the related-work section to wrap up the big picture before moving on.

```markdown
## Related-work summary & gaps

**N papers presented** — grouped into M topics

| Topic | Papers | Main contribution |
|---|---|---|
| **1. Topic name** | Paper A (5), Paper B (4) | Synthesized contribution |
| **2. ...** | ... | ... |

**Key research gaps**
- Gap 1 — no general solution yet
- Gap 2 — not systematically tested
- Gap 3 — good results but limited to 2D / specific case
```

**Rules:**
- A condensed table — one row per topic, papers with importance in parentheses
- The **Gaps** section points the way for what follows (motivation for the presentation's contribution)

### Flow variant: Single Paper Review (1 deep paper)

If you need to present **a single paper** in depth (paper club, deep dive), replace 1 slide with 4–6 slides following this flow:

```
1. Paper context — problem, motivation         ← 1 slide
2. Main idea — main contribution               ← 1 slide
3. Method — formulas, architecture             ← 1–2 slides
4. Results — benchmark, comparison             ← 1–2 slides
5. Limitations & open questions                ← 1 slide
6. Relation to your own work                   ← 1 slide (optional)
```

Each slide's structure still follows the general pattern in Section 7 (Writing Style).

### Tips to keep a paper review engaging

- **A unique slogan per paper**: instead of repeating the paper name, use a distinct angle (e.g. NTK — "diagnosing training failure"; VS-PINN — "variable scaling for stiff PDEs")
- **Specific numbers**: each paper must have at least 1–2 quantitative figures for its contribution (speedup, error reduction, accuracy)
- **Vary the presentation form**: alternate bullets, block formulas, metric tables — don't let every slide look the same
- **Links between papers**: when introducing paper N, you can mention which aspect paper M earlier addressed

---

## 7.2 Idea / Method Proposal Pattern

When presenting ideas (proposal, hypothesis, method design, experimental approach), the goal is for the audience to grasp **two things**: what the idea is theoretically, and why you chose to build it that way. Use a two-block pattern: **Theory → Rationale**.

### Template

```markdown
## Idea N: Short idea name

**Theory** — an opening sentence stating the core mechanism:

$$\text{main equation if any}$$

A paragraph explaining the equation's meaning and its secondary components. If multiple parts work together, use 2–3 short bullets:

- **Part A**: role and mechanism (1 sentence)
- **Part B**: role and mechanism (1 sentence)
- **Part C**: role and mechanism (1 sentence)

**Rationale**: a coherent paragraph explaining the motivation — prior experimental observations, theoretical grounds from the literature, or both pointing the same way. Make clear why this idea is a grounded experiment, not a random choice.
```

### Rules for each block

**Theory**
- Open with the phrase `**Theory** — <short description>:` to go straight into the content
- Place the **block equation** right after the opening sentence if the formula is the crux; at most 1 block math / slide
- If the idea has several components (e.g. combining 3 improvements), use short bullets with the pattern `**Part name**: role + mechanism`
- Avoid over-detailing implementation (number of layers, optimizer, epochs) — that belongs on the results slide, not the idea slide

**Rationale**
- Write as a **coherent paragraph**, not clipped bullets — this is the persuasive part, it needs a smooth cadence
- State **at least one** kind of grounding: (1) experimental observation from a prior experiment, (2) a claim from a paper in the literature (with conf if available), (3) structural similarity between the current problem and a solved benchmark
- Avoid promotional tone ("breakthrough idea", "very promising") — explain the logic of why this direction is feasible
- A closing sentence may state a specific expectation if appropriate (e.g. "expected to give a fast inference model with accuracy approximating FEM")

### Worked example

```markdown
## Idea 3: Curriculum source sharpening

**Theory** — approximate a fragmented source with a smooth function parameterized by a sharpness control:

$$J(x) \approx J_0 \cdot \left[\sigma(k(x-a)) - \sigma(k(x-b))\right]$$

The parameter $k$ controls sharpness — as $k \to \infty$ the function approaches a step. The curriculum schedule increases $k$ across training stages:

- Start with low $k$ — a smooth source, a loss landscape with fewer local extrema
- Gradually increase $k$ to approach $J_\mathrm{exact}$ while keeping training stable

**Rationale**: an ablation shows $J_\mathrm{exact}$ makes Az about 4× worse than $J_\mathrm{smooth}$ — suggesting that an overly sharp source creates a loss landscape that is hard to optimize. A gradual curriculum schedule is a natural way to get both advantages: an easy start with low $k$, accurate convergence with high $k$.
```

### Flow for a group of multiple ideas

When several ideas belong to the same group (e.g. 4–6 proposals for the same problem), organize with this flow:

```
Overview slide: a table summarizing N ideas       ← 1 slide
├── Idea 1: name                                  ← 1 slide / idea
├── Idea 2: name                                  ← 1 slide / idea
└── Idea N: name                                  ← 1 slide / idea
Combined results slide (after running)            ← 1 slide
```

**The overview slide** uses a 3-4 column table:

```markdown
## Overview of N ideas

| Idea | Mechanism | Theoretical basis | Status |
|---|---|---|---|
| Idea 1 | Short mechanism | Paper / concept | Not run |
| Idea 2 | Short mechanism | Paper / concept | Target met |
```

The **Status** column is filled only after experimental results; before that, leave it empty or write "Proposed". The overview slide serves as a table of contents — the audience knows in advance how many ideas there are and that each will be explained in turn on the following slides.

### Tips for idea slides

- **Separate theory from implementation**: the idea slide is about *what* and *why*; the results slide is about *how* and *outcome*. Don't cram both onto one slide.
- **An equation is a support, not a burden**: if a formula is too long to fit on one line, write it in prose rather than forcing it into `$$...$$`
- **The rationale must be traceable to a source**: if you cite a paper, give the slug and conf; if you cite an experiment, give the experiment name in the wiki
- **No need to list limitations on the idea slide** — limitations belong in the results/discussion section after a trial run

---

## 7.3 Sourcing & Content Authenticity

**General principle**: Every statement on a slide must be traceable to a source or clearly marked as a hypothesis / personal observation. A technical slide is not a place for unverified claims — the audience must know where each number / claim comes from to assess its reliability. This rule applies to **every kind of slide**, not just related work or idea proposals.

### 1. Classify every statement into three types

Before writing any assertion on a slide, ask which type it is — and mark it clearly so the audience can distinguish:

- **Sourced fact**: a claim from a peer-reviewed paper, official documentation, or a published dataset. Must include a source (slug, citation, link, or end-of-slide reference).
- **Observation from your own experiment**: the author's experimental result stored in the wiki / log. Must include the experiment slug + seed + the specific metric measured.
- **Author's hypothesis**: speculation, prediction, or a personal claim not yet verified. Must be clearly marked with hypothetical wording ("hypothesis", "expected", "may", "suggests that") — not presented as fact.

Avoid mixing the three types in one sentence without distinction — e.g. "Method X reduces error 30% and will be applicable to 3D" mixes a fact (30%) with a hypothesis (3D) without any warning to the audience.

### 2. Authoritative sources for facts

When presenting a fact, cite only from verifiable sources:

- **Peer-reviewed paper**: with venue/year + slug in the wiki (e.g. `NTK PINN, JCP 2022, conf 0.92`)
- **Official documentation**: the official docs of the framework / tool / standard
- **Experiment with log + code**: an experiment in the wiki that is reproducible, with slug + seed + run date
- **Published benchmark**: a dataset / benchmark with a DOI or an original paper

**Do not cite as fact**:
- Blog post, tweet, forum thread that is unverified
- Numbers recalled approximately with no specific source
- "Everyone knows" claims with no traceable original paper
- Results from a single run with no seed / not reproducible
- AI-generated content not independently verified by the author

If you only have a weak source, write the sentence as a hypothesis or drop it entirely — do not "upgrade" a weak source into a fact by presenting it as an assertion.

### 3. Numbers must be specific and traceable

Every number on a slide needs enough context for the audience to assess it:

- **A clear metric**: "RMSE 0.056 mm" is better than "small error"
- **A comparison baseline**: "Az R² 0.99 (kan-single) vs 0.73 (fd-warm-start)" is better than "Az R² 0.99"
- **Dataset / setting**: "9 flat-bottom holes on Aluminum 2024" is better than "on an NDT benchmark"
- **Source slug**: with `<small>Ref: slug</small>` to trace back to the log / paper

Avoid "decorative" numbers — e.g. "very fast speedup" needs to be made specific as "4–5 orders of magnitude speedup on 9 PDE benchmarks" with a clear source. A number with no context is best dropped.

### How to mark a statement's type in the writing

Use typical phrases to help the audience distinguish the claim type as they read:

| Type | Typical phrases |
|---|---|
| Sourced fact | "achieves", "reports", "proves", "shows", "publishes" |
| Experimental observation | "experiment X observes", "managed rerun shows", "reproducible" |
| Hypothesis / speculation | "may", "suggests that", "hypothesis", "expected", "potentially" |

**Distinguishing examples:**

- *Fact*: "VS-PINN reduces the wave-equation error from 63.1% to 1.2% (JCP 2024)"
- *Observation*: "Managed rerun 2026-06-01 shows kan-single achieves Az R² 0.9924, reproducible to ±0.001 across 2 runs"
- *Hypothesis*: "A similar approach may reduce amplitude collapse 36× in nondim first-order"

The three sentences have different verb structures — the audience immediately distinguishes the statement type without a separate note.

---

## 8. Footnotes and References

### End-of-slide footnote — use `<small>`

```markdown
<small>Refs: `paper-slug-1` · `paper-slug-2`</small>
```

- Use `<small>` to shrink
- Slug, ID, or short name (not the full name — too long)
- Separate with ` · ` (middle dot)
- Place at the end of the slide, after the main content

### Metadata / short labels

Use the `**Name**: value` phrase to attach metadata quickly — e.g. `**Date**: 2026-06-04`, `**Conf**: 0.92`, `**Status**: in progress`.

---

## 9. Useful Patterns

### Flow chart / Pipeline (text-based, no image needed)

```markdown
Phase 1: data prep
├── step 1.1                            → output A
├── step 1.2                            → output B
└── step 1.3                            → output C
Phase 2: training
└── ...
```

Trees drawn with `├──`, `└──`, `│` read clearly in a terminal-style theme.

### Findings summary — short comparison table

```markdown
| Technique / Method | Impact | Comment |
|---|---|---|
| Approach A | +X% | Reliable |
| Approach B | −Y% | Needs condition ... |
```

### Status — standard phrases

When listing experiment/idea status, use short consistent phrases: `met` / `not met` / `running` / `unstable` / `target met`.

### Callout / emphasis

In body text, wrap an important idea in a short `**...**` pair (no more than 1 line). Avoid using a blockquote `>` for a callout — it renders poorly in many themes.

---

## 10. Important Notes

### Layout

- **Left-aligned throughout** (`center: false` + `.reveal .slides section { text-align: left; }`)
- **Content must not overflow the slide** — if too dense, split into 2 slides or trim
- **Images always have a size** — don't let Reveal pick
- **Tables not too wide** — reference font 0.75em, moderate padding

### Content

- **One main idea per slide**; the slide title already states what that idea is
- **Numbers need context** — don't give an absolute number without a baseline / unit
- **Always state the unit**: %, ms, GB, R², MAPE
- **Cite the source** whenever using data / a claim from external material

### Equations

- Use only `$$...$$` and `$...$` — no LaTeX environments
- Block math should be standalone, not within a bullet
- Subscripts/superscripts per the rules in Section 5

### Color & emphasis

- Pick one theme (`black`, `white`, `league`,...) and stick with it
- **Bold** is the main emphasis tool — don't overuse (>30% of a slide bold = no emphasis left)
- Don't add inline color (`<span style="color:..">`) — it breaks the theme and is hard to maintain
- Use `<small>` to de-emphasize (references, captions, footnotes)

---

## 11. Pre-Completion Checklist

- [ ] Frontmatter complete (theme, transition, width, height, center, controls, progress)
- [ ] CSS style block overrides font sizes and `text-align: left`
- [ ] `center: false`
- [ ] H1 only for a section's opening slide / title slide
- [ ] `---` between slides, with a blank line before/after
- [ ] Images have a specific size `|widthxheight`
- [ ] Tables have alignment markers `:---:`, `---:` where needed
- [ ] Equations use `$$...$$` or `$...$` (no LaTeX environments)
- [ ] Exponents inside `{}`: `x^{2}`, not `x^2`
- [ ] Multi-char subscripts inside `{}`: `\mathcal{L}_{\mathrm{total}}`
- [ ] Standalone block equations are centered in preview (wrap `<div style="text-align: center;">` or use a global CSS rule)
- [ ] Source footnote at the end of the slide as `<small>`
- [ ] Important metrics and prominent names in bold
- [ ] Content does not overflow the slide — split slides if too dense
- [ ] One consistent primary language (VN or EN, not mixed)
- [ ] Professional, neutral, smooth-reading voice — not clipped, not promotional

### Sourcing & authenticity

- [ ] Every fact has a source (peer-reviewed paper / official doc / experiment with a log)
- [ ] No blog, tweet, forum, or approximate number cited as fact
- [ ] Hypotheses / speculation clearly marked ("may", "expected", "hypothesis")
- [ ] Experimental observations include the experiment slug + seed + specific metric
- [ ] Every number has full context: metric / baseline / dataset / source
- [ ] No fact + hypothesis mixed in one sentence without distinction
- [ ] References at the end of the slide as `<small>Ref: slug</small>` or equivalent
- [ ] Claims from the literature include conf if available (e.g. `conf 0.92`)
