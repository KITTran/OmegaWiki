# PowerPoint (.pptx) Authoring Guide — `/create-ppt`

> The sole rule source for the `/create-ppt` skill: build a polished PowerPoint `.pptx` deck from a paper PDF (or another content source), embedding the full original figures + rendered equations, with critical analysis, through a visual QA loop.
>
> Unlike `/create-slides` (Reveal.js/Markdown on Obsidian), this skill outputs a **real `.pptx` file** that opens in PowerPoint/Keynote, built with **pptxgenjs**.

---

## 0. Philosophy — what makes a deck "polished"

1. **Actually "see" the figures** — render each PDF page to an image and read it with vision (don't guess). This lets you crop accurately and describe each figure's content correctly.
2. **Embed the paper's original figures** verbatim (clean 300 DPI crop), no redrawing → faithful, professional.
3. **Equations = images rendered from LaTeX** (PowerPoint has no LaTeX) → crisp, sharp, correct notation.
4. **A consistent design system** — 1 palette, 2 font families, reusable layout helpers → every slide speaks the same "language".
5. **QA with fresh eyes (a subagent)** on the actually rendered images → catches overflow, overlap, and contrast bugs the code author can't see.
6. **Ask clearly before building** — don't infer the big decisions.

---

## 1. Ask the user first (required decisions)

Before building, settle these with interactive questions:

| Decision | Description |
|---|---|
| **Format** | `.pptx` (this skill) — confirm it's not Reveal.js/Markdown |
| **Audience / depth** | deep-technical seminar · general talk · intro |
| **Length** | short (~10–12) · medium (~15–20) · full (~25+) |
| **Figure handling** | crop each figure individually (best) · use whole pages |
| **Critical analysis** | yes (strengths/limitations + relation to research) · present the paper only |
| **Text font** | default **Lato**; ask if the user has another preference |
| **Equation font** | default **STIX** (≈ Cambria Math); or `cm` (classic LaTeX) |
| **Color palette** | ask early — this is what users care about and the most likely to force a rebuild |

> **Lesson**: ask **font + palette up front**. Skipping it forces multiple rebuild rounds.

---

## 2. Toolchain (check/install once)

- **PyMuPDF (`fitz`)** — render PDF to images + crop figures + render slides for QA. Prefer `.venv/bin/python`. The old `pdfimages` (v3.02) is **unusable** (`-png` unsupported).
- **matplotlib + pillow** — render LaTeX→PNG equations, measure image sizes. `.venv/bin/pip install matplotlib pillow`.
- **pptxgenjs** — build the `.pptx`. Install **LOCALLY in the deck directory**: `npm install pptxgenjs` (a global install often errors with `Cannot find module`).
- **LibreOffice `soffice`** (headless, `libreoffice-nogui` is enough) — convert `.pptx → .pdf` for QA. No `pdftoppm` needed — use PyMuPDF to render the PDF.
- **Fonts** must be installed in the system for LibreOffice to render correctly. Check: `fc-list | grep -i <font>`. **Cambria Math is not installable** (Microsoft proprietary) → use **STIX**.

---

## 3. Output directory layout

Every artifact of a deck lives inside one directory under `wiki/outputs/<deck-slug>/`:

```
wiki/outputs/<deck-slug>/
├── build_deck.js              # pptxgenjs script (living template — copy to reuse)
├── figures/                   # figures cropped from the paper, 300 DPI
│   ├── dims.json              # {path: [w,h]} — preserve aspect ratio when embedding
│   ├── eq/                    # equations rendered from LaTeX (transparent PNG)
│   └── pages/                 # (temporary) rendered PDF pages for reading/QA
├── <Deck-Name>.pptx           # final output
└── node_modules/              # pptxgenjs installed locally
```

Temporary files from reading the paper (full text, page images) may go in `raw/tmp/<slug>/` (additions only, never overwrite user inputs).

---

## 4. Extracting & cropping figures from the PDF

### 4.1 Render every page + read with vision
```python
import fitz, os
doc = fitz.open("raw/papers/PAPER.pdf")
os.makedirs("figures/pages", exist_ok=True)
for i, page in enumerate(doc):
    page.get_pixmap(dpi=110).save(f"figures/pages/p{i+1:02d}.png")
    print(i+1, len(page.get_images(full=True)), page.get_text()[:60])
```
→ Then **Read the pages that contain figures** to confirm each figure's content. Extract the full text with `page.get_text()` to capture the technical detail.

### 4.2 Find caption positions ("Fig. N …")
```python
for b in page.get_text("blocks"):
    x0,y0,x1,y1,txt,*_ = b
    if txt.strip().startswith("Fig."):
        print(f"cap y0={y0:.0f} :: {txt[:60]}")
```

### 4.3 Get the bbox of the graphic region near the caption
- Embedded images: `page.get_images(full=True)` → `page.get_image_rects(xref)`.
- Vector figures (drawn with paths): union the `d["rect"]` from `page.get_drawings()` (filter to sufficiently large rects).
- A figure usually sits **above the caption**, or at the top of the page.

### 4.4 Crop at high DPI + small padding
```python
mat = fitz.Matrix(300/72, 300/72); P = 6  # padding pt
clip = fitz.Rect(x0-P, y0-P, x1+P, y1+P) & page.rect
page.get_pixmap(matrix=mat, clip=clip).save("figures/fig1_architecture.png")
```
- Use descriptive names: `fig1_architecture.png`, `fig7_error_dist.png`…
- **Re-Read a few figures** after cropping to be sure they are not clipped/misaligned.

---

## 5. Rendering equations (LaTeX → PNG)

PowerPoint has no LaTeX → render with matplotlib mathtext, **transparent background**, high DPI.

```python
import matplotlib; matplotlib.use("Agg")
matplotlib.rcParams["mathtext.fontset"] = "stix"   # STIX ≈ Cambria Math; "cm" = classic LaTeX
import matplotlib.pyplot as plt

def render(name, tex, fs=30, color="#172332"):
    fig = plt.figure(figsize=(0.01, 0.01))
    fig.text(0, 0, f"${tex}$", fontsize=fs, color=color)
    fig.savefig(f"figures/eq/{name}.png", dpi=300,
                bbox_inches="tight", pad_inches=0.12, transparent=True)
    plt.close(fig)
```

**mathtext syntax pitfalls** (DIFFERENT from real LaTeX):
- There is **no** `\big| \big|` → use `\left| ... \right|`.
- `\mathcal{L}`, `\frac`, `\partial`, `\nabla`, `\sum_{}^{}`, `\dot{}` all work.
- Test early: render 1–2 equations, Read to check before rendering the whole batch.

---

## 6. Design system

### 6.1 Palette — define as constants, assign BY ROLE
Assign colors by function, not by name — so changing the theme means editing one place. Example earthy palette:

```js
const SAGE="A5B9A1", SAGE_D="839388";  // dominant / secondary
const BLUE="4375BC";                    // kicker, table header, primary data
const TERRA="B17158";                   // result highlight + VERTICAL BAND on special slides
const SLATE="606969";                   // secondary data
const INK="172332";                     // titles + main text
const LIGHT="F4F4EE", CARD="FFFFFF";    // light background + card
const MUTED="414240", LINE="D4D5D0", PANEL="E7E8E1";
```
Principle: **1 dominant color, 1–2 secondary, 1 sharp accent**. Use aliases to minimize code edits when changing theme.

### 6.2 Fonts
- Slide body (titles + body): **1 sans family** (default Lato).
- Equations: **serif math** (STIX) — the serif/sans contrast is standard for scientific slides.
- Code/algorithm: **monospace** (Consolas).
- Change the font globally: 1 line `const HEAD = BODY = "Lato"`.

### 6.3 Light background + vertical band for special slides
Prefer a **light background** for every slide (unless the user requests otherwise). Special slides (title / divider / takeaways) add a **vertical color band** on the left as an accent — without darkening the slide:
```js
function newSlide(sp){ const s=pres.addSlide(); s.background={color:LIGHT};
  if(sp) s.addShape(pres.shapes.RECTANGLE,{x:0,y:0,w:0.35,h:H,fill:{color:TERRA}});
  return s; }
```
If you need a deliberately dark block (code/algorithm), use an `INK` card — that's the only dark spot.

### 6.4 Reusable helpers (the deck's backbone)
- `head(slide, kicker, title)` — kicker (small uppercase, accent color) + title ~27pt.
- `footer(slide)` — brand on the left + page number on the right.
- `divider(num, title, sub)` — section slide, large faint ghost number.
- `card(x,y,w,h,fill)` — a lightly rounded white block + shadow factory.
- `bullets(items, ...)` — real bullets (`bullet:{code:"2022"}`), supports sub-levels + bold.
- `fitImg(key, bx,by,bw,bh)` — **embed an image PRESERVING ASPECT RATIO** inside a box (reads `figures/dims.json`).
- `caption(...)` — an italic note under a figure.

### 6.5 Store image sizes to preserve aspect ratio
```python
from PIL import Image; import glob, json, os
d = {}
for f in glob.glob("figures/**/*.png", recursive=True):
    im = Image.open(f); d[os.path.relpath(f, ".")] = [im.width, im.height]
json.dump(d, open("figures/dims.json", "w"), indent=0)
```
`fitImg` reads this file, computes the `aspect ratio`, and fits the image in the box without distortion.

---

## 7. Content structure (deep-technical, 5-part frame)

1. **Motivation** — the problem (2–3 slides) + background + related work + key idea + contributions.
2. **Method** — step-by-step derivation (one step per slide), complexity-reduction table, the final loss/result, intuitive interpretation.
3. **Architecture & Algorithm** — architecture figure + pseudo-code + strategy.
4. **Experiments** — setup → each ablation → each benchmark; 1–2 original figures + a numeric table per slide.
5. **Discussion** — strengths / limitations (grid cards) + relation to the user's research + takeaways.

**Title rule**: one main idea per slide; numeric tables transcribed **correctly** from the paper; titles **concise, professional, avoiding strong verbs / casual phrasing**.
- Good: "Two problems addressed by this paper", "Physics-Informed Neural Networks: an overview".
- Avoid: "…this paper attacks", "…in 60 seconds", "My take".

---

## 8. Build & QA loop (mandatory ≥ 1 round)

```bash
# build
node build_deck.js                       # -> <Deck-Name>.pptx

# render for QA (NO pdftoppm needed)
soffice --headless --convert-to pdf --outdir qa <Deck>.pptx
# then PyMuPDF: doc[i].get_pixmap(dpi=100).save(f"qa/slide-{i+1:02d}.png")
```

**QA with a subagent (fresh eyes)** — split the slides into 2 groups, prompt it to *assume there are bugs*:
- text overflowing a card / the slide edge; overlapping elements (text over a table, a card over a table);
- **low contrast** (light text on a light background / dark on dark);
- caption colliding with a figure/footer; truncated table rows; a 2-line-wrapped title overlapping content;
- when changing the theme: also add "any leftover old-theme colors?".

**Typical bugs & fixes:**
- *Dark-on-dark title* → the `head` helper must know the background, or remove dark backgrounds entirely.
- *Card/stat overlapping a table* → reduce the table `rowH` + push the lower block's y down.
- *Bullets overlapping a table* → recompute the table height (rows×rowH) before placing the bullets.
- *Subagent reports "content compressed into the top half / tiny figures"* is usually a **100-DPI rendering artifact** → re-render that slide at 140–150 DPI and Read it yourself to verify **before** "fixing".

**Content QA**: `python -m markitdown <Deck>.pptx | grep -iE "xxxx|lorem|undefined|TODO"` → must be empty.

---

## 9. pptxgenjs technical pitfalls

- Hex colors **without** a `#`; **no** 8-char codes (opacity embedded in hex) → corrupts the file. Use a separate `opacity` property.
- **Do not** reuse the same `shadow` object across multiple shapes (pptxgenjs mutates in-place) → use a factory returning a fresh object each time: `const sh = () => ({...})`.
- Bullets: use `bullet:true` / `{code:"2022"}`, **not** a manual "•" character (causes double bullets).
- `breakLine:true` between runs/array items to break the line.
- `RECTANGLE` (no rounding) for bands/accents; `ROUNDED_RECTANGLE` for rounded cards — don't overlay a rectangular accent on rounded corners.
- Install `pptxgenjs` **locally** in the deck directory.
- Each presentation needs a fresh instance (`new pptxgen()`), do not reuse.

---

## 10. Reproduction checklist (short)

1. Ask: format, audience, length, figure handling, critical analysis, **font + palette**.
2. Read the paper: render every PDF page → Read figures; extract the full text.
3. Crop figures at 300 DPI (by caption bbox) → Re-Read a few.
4. Render equations in STIX → transparent PNG; export `dims.json`.
5. Write `build_deck.js`: palette + helpers + slides on the 5-part frame.
6. `node build_deck.js` → `.pptx`.
7. `soffice` → PDF → PyMuPDF PNG → **2 subagent QA** → fix → re-render the fixed slides to verify.
8. Content QA (markitdown grep for placeholders).
9. Update `wiki/index.md` (if the output is under `wiki/outputs/`) + append `wiki/log.md`.

---

## 11. Pre-report self-review checklist

**Figures & equations:**
- [ ] Every needed figure of the paper has been cropped and embedded (no missing figures)
- [ ] Figures preserve the correct aspect ratio (via `fitImg` + `dims.json`), no distortion/clipping
- [ ] Equations render crisp, with correct notation, on a transparent background

**Design & layout:**
- [ ] 1 consistent palette, assigned by role; contrast holds (no light-on-light/dark-on-dark)
- [ ] Consistent fonts (sans for text, serif for equations, mono for code)
- [ ] No overlapping elements; no text overflowing a card/edge; caption does not collide with the footer
- [ ] Titles concise, professional, avoiding strong verbs/casual phrasing

**Content & authenticity:**
- [ ] Numbers/tables transcribed correctly from the paper; nothing fabricated
- [ ] Critical analysis (if any) separates strengths/limitations
- [ ] No leftover placeholders (markitdown grep is empty)
- [ ] Went through ≥ 1 round of subagent QA + fix + re-render verification

---

## 12. Constraints

- **`docs/ppt-guide.en.md` is the sole rule source** for `/create-ppt`; do not invent extra rules.
- **Do not fabricate content**: numbers/citations must come from the paper; if missing, drop or mark as a hypothesis.
- **The paper's original figures are embedded verbatim** — do not redraw, do not fabricate charts.
- **`raw/` is user-owned**: only add temporary files under `raw/tmp/`, never overwrite inputs.
- **Do not overwrite an existing `.pptx`** not produced by this skill without confirming with the user.
- **Do not edit `graph/`**; update `index.md` and append to `log.md`.
- The QA loop is mandatory — do not report completion without at least one round of QA + fix.
