# PowerPoint (.pptx) 撰写指南 — `/create-ppt`

> `/create-ppt` skill 的唯一规则来源：从论文 PDF（或其他内容来源）构建高质量 PowerPoint `.pptx` 演示文稿，嵌入完整原始图表 + 渲染公式，含批判性分析，经过视觉 QA 循环。
>
> 与 `/create-slides`（Obsidian 上的 Reveal.js/Markdown）不同，本 skill 输出可在 PowerPoint/Keynote 打开的**真正的 `.pptx` 文件**，使用 **pptxgenjs** 构建。

---

## 0. 理念 — 什么让一个 deck "高质量"

1. **真正"看见"图表** — 将每页 PDF 渲染为图像并用视觉阅读（不猜测）。由此精确裁剪并正确描述每张图的内容。
2. **逐字嵌入论文原始图表**（干净的 300 DPI 裁剪），不重绘 → 忠实、专业。
3. **公式 = 从 LaTeX 渲染的图像**（PowerPoint 无 LaTeX）→ 清晰、锐利、记号正确。
4. **一致的设计系统** — 1 套 palette、2 个字体家族、可复用 layout helper → 每张 slide 说同一种"语言"。
5. **用新鲜的眼睛（subagent）做 QA**，在真实渲染图上 → 捕捉代码作者看不到的溢出、重叠、对比度问题。
6. **动手前问清楚** — 不臆断重大决策。

---

## 1. 先问用户（必需决策）

构建前，用交互式问题敲定：

| 决策 | 描述 |
|---|---|
| **格式** | `.pptx`（本 skill）— 确认不是 Reveal.js/Markdown |
| **受众 / 深度** | deep-technical seminar · 通用 talk · intro |
| **长度** | 短（~10–12）· 中（~15–20）· 完整（~25+） |
| **图表处理** | 逐张裁剪（最佳）· 用整页 |
| **批判性分析** | 有（strengths/limitations + 与 research 的关联）· 仅讲解论文 |
| **正文字体** | 默认 **Lato**；用户另有偏好则询问 |
| **公式字体** | 默认 **STIX**（≈ Cambria Math）；或 `cm`（经典 LaTeX） |
| **配色方案** | 尽早询问 — 这是用户最在意、也最容易返工的项 |

> **教训**：**一开始就**问字体 + 配色。跳过会导致多轮返工。

---

## 2. 工具链（检查/安装一次）

- **PyMuPDF (`fitz`)** — 将 PDF 渲染为图像 + 裁剪图表 + 渲染 slide 用于 QA。优先 `.venv/bin/python`。旧版 `pdfimages`（v3.02）**不可用**（不支持 `-png`）。
- **matplotlib + pillow** — 渲染 LaTeX→PNG 公式、测量图像尺寸。`.venv/bin/pip install matplotlib pillow`。
- **pptxgenjs** — 构建 `.pptx`。在 **deck 目录内本地安装**：`npm install pptxgenjs`（全局安装常报 `Cannot find module`）。
- **LibreOffice `soffice`**（headless，`libreoffice-nogui` 即可）— 将 `.pptx → .pdf` 用于 QA。无需 `pdftoppm` — 用 PyMuPDF 渲染 PDF。
- **字体**须在系统中预装，LibreOffice 才能正确渲染。检查：`fc-list | grep -i <font>`。**Cambria Math 无法安装**（微软专有）→ 用 **STIX**。

---

## 3. 输出目录布局

一个 deck 的所有产物都放在 `wiki/outputs/<deck-slug>/` 下的一个目录中：

```
wiki/outputs/<deck-slug>/
├── build_deck.js              # pptxgenjs 脚本（活模板 — 复制以复用）
├── figures/                   # 从论文裁剪的图表，300 DPI
│   ├── dims.json              # {path: [w,h]} — 嵌入时保持长宽比
│   ├── eq/                    # 从 LaTeX 渲染的公式（透明 PNG）
│   └── pages/                 #（临时）渲染的 PDF 页，用于阅读/QA
├── <Deck-Name>.pptx           # 最终输出
└── node_modules/              # 本地安装的 pptxgenjs
```

阅读论文产生的临时文件（全文、页图）可放在 `raw/tmp/<slug>/`（只增不改，绝不覆盖用户输入）。

---

## 4. 从 PDF 提取并裁剪图表

### 4.1 渲染每页 + 用视觉阅读
```python
import fitz, os
doc = fitz.open("raw/papers/PAPER.pdf")
os.makedirs("figures/pages", exist_ok=True)
for i, page in enumerate(doc):
    page.get_pixmap(dpi=110).save(f"figures/pages/p{i+1:02d}.png")
    print(i+1, len(page.get_images(full=True)), page.get_text()[:60])
```
→ 然后 **Read 含图表的页面**以确认每张图的内容。用 `page.get_text()` 提取全文以掌握技术细节。

### 4.2 查找 caption 位置（"Fig. N …"）
```python
for b in page.get_text("blocks"):
    x0,y0,x1,y1,txt,*_ = b
    if txt.strip().startswith("Fig."):
        print(f"cap y0={y0:.0f} :: {txt[:60]}")
```

### 4.3 取 caption 附近图形区域的 bbox
- 嵌入图像：`page.get_images(full=True)` → `page.get_image_rects(xref)`。
- 矢量图（用 path 绘制）：对 `page.get_drawings()` 的 `d["rect"]` 取并集（过滤足够大的 rect）。
- 图通常位于 **caption 上方**，或页面顶部。

### 4.4 高 DPI 裁剪 + 小 padding
```python
mat = fitz.Matrix(300/72, 300/72); P = 6  # padding pt
clip = fitz.Rect(x0-P, y0-P, x1+P, y1+P) & page.rect
page.get_pixmap(matrix=mat, clip=clip).save("figures/fig1_architecture.png")
```
- 使用描述性命名：`fig1_architecture.png`、`fig7_error_dist.png`…
- 裁剪后 **重新 Read 几张图**，确保未被裁切/错位。

---

## 5. 渲染公式（LaTeX → PNG）

PowerPoint 无 LaTeX → 用 matplotlib mathtext 渲染，**透明背景**，高 DPI。

```python
import matplotlib; matplotlib.use("Agg")
matplotlib.rcParams["mathtext.fontset"] = "stix"   # STIX ≈ Cambria Math；"cm" = 经典 LaTeX
import matplotlib.pyplot as plt

def render(name, tex, fs=30, color="#172332"):
    fig = plt.figure(figsize=(0.01, 0.01))
    fig.text(0, 0, f"${tex}$", fontsize=fs, color=color)
    fig.savefig(f"figures/eq/{name}.png", dpi=300,
                bbox_inches="tight", pad_inches=0.12, transparent=True)
    plt.close(fig)
```

**mathtext 语法陷阱**（与真 LaTeX 不同）：
- **没有** `\big| \big|` → 用 `\left| ... \right|`。
- `\mathcal{L}`、`\frac`、`\partial`、`\nabla`、`\sum_{}^{}`、`\dot{}` 都可用。
- 尽早测试：渲染 1–2 个公式，Read 检查后再批量渲染。

---

## 6. 设计系统

### 6.1 Palette — 定义为常量，按角色分配
按功能而非名称分配颜色 — 换主题只改一处。示例 earthy palette：

```js
const SAGE="A5B9A1", SAGE_D="839388";  // 主色 / 次色
const BLUE="4375BC";                    // kicker、表头、主数据
const TERRA="B17158";                   // 结果高亮 + 特殊 slide 竖向色带
const SLATE="606969";                   // 次要数据
const INK="172332";                     // 标题 + 正文
const LIGHT="F4F4EE", CARD="FFFFFF";    // 浅色背景 + card
const MUTED="414240", LINE="D4D5D0", PANEL="E7E8E1";
```
原则：**1 个主色、1–2 个次色、1 个锐利 accent**。用别名以在换主题时少改代码。

### 6.2 字体
- slide 正文（标题 + body）：**1 个 sans 家族**（默认 Lato）。
- 公式：**serif math**（STIX）— serif/sans 对比是科学幻灯片的标准。
- 代码/算法：**monospace**（Consolas）。
- 全局换字体：1 行 `const HEAD = BODY = "Lato"`。

### 6.3 浅色背景 + 特殊 slide 竖向色带
所有 slide 优先**浅色背景**（除非用户另有要求）。特殊 slide（title / divider / takeaways）在左侧加一条**竖向色带**作 accent — 不使 slide 变暗：
```js
function newSlide(sp){ const s=pres.addSlide(); s.background={color:LIGHT};
  if(sp) s.addShape(pres.shapes.RECTANGLE,{x:0,y:0,w:0.35,h:H,fill:{color:TERRA}});
  return s; }
```
若需有意的深色块（代码/算法），用 `INK` card — 那是唯一的深色处。

### 6.4 可复用 helper（deck 的骨架）
- `head(slide, kicker, title)` — kicker（小号大写，accent 色）+ 标题 ~27pt。
- `footer(slide)` — 左侧品牌 + 右侧页码。
- `divider(num, title, sub)` — 分章 slide，大号淡色 ghost number。
- `card(x,y,w,h,fill)` — 轻圆角白块 + 阴影工厂。
- `bullets(items, ...)` — 真 bullet（`bullet:{code:"2022"}`），支持子级 + 加粗。
- `fitImg(key, bx,by,bw,bh)` — 在 box 内**保持长宽比嵌入图像**（读取 `figures/dims.json`）。
- `caption(...)` — 图下斜体注释。

### 6.5 存储图像尺寸以保持长宽比
```python
from PIL import Image; import glob, json, os
d = {}
for f in glob.glob("figures/**/*.png", recursive=True):
    im = Image.open(f); d[os.path.relpath(f, ".")] = [im.width, im.height]
json.dump(d, open("figures/dims.json", "w"), indent=0)
```
`fitImg` 读取此文件，计算 `aspect ratio`，把图像无变形地放进 box。

---

## 7. 内容结构（deep-technical，五部分框架）

1. **Motivation** — 问题（2–3 slide）+ background + related work + key idea + contributions。
2. **Method** — 逐步推导（每步 1 slide）、复杂度降低表、最终 loss/结果、直觉解读。
3. **Architecture & Algorithm** — 架构图 + pseudo-code + 策略。
4. **Experiments** — setup → 各 ablation → 各 benchmark；每 slide 1–2 张原始图 + 数字表。
5. **Discussion** — strengths / limitations（grid card）+ 与用户 research 的关联 + takeaways。

**标题规则**：每 slide 一个主旨；数字表**准确**转录自论文；标题**简洁、专业，避免强势动词 / 口语化**。
- 好："Two problems addressed by this paper"、"Physics-Informed Neural Networks: an overview"。
- 避免："…this paper attacks"、"…in 60 seconds"、"My take"。

---

## 8. 构建与 QA 循环（强制 ≥ 1 轮）

```bash
# 构建
node build_deck.js                       # -> <Deck-Name>.pptx

# 渲染用于 QA（无需 pdftoppm）
soffice --headless --convert-to pdf --outdir qa <Deck>.pptx
# 然后 PyMuPDF: doc[i].get_pixmap(dpi=100).save(f"qa/slide-{i+1:02d}.png")
```

**用 subagent 做 QA（新鲜的眼睛）** — 将 slide 分为 2 组，提示它*假定存在 bug*：
- 文字溢出 card / slide 边缘；元素重叠（文字压表、card 压表）；
- **对比度低**（浅色文字在浅背景 / 深色在深背景）；
- caption 撞图/footer；表格行被截断；标题折两行压住内容；
- 换主题时：另加"是否残留旧主题颜色？"。

**典型 bug 与修法：**
- *Dark-on-dark title* → `head` helper 须知道背景，或彻底去掉深色背景。
- *Card/stat 压表* → 减小表格 `rowH` + 把下方块的 y 下移。
- *Bullets 压表* → 放 bullets 前重算表格高度（rows×rowH）。
- *Subagent 报告"内容被压到上半 / 图过小"* 通常是 **100 DPI 渲染的假象** → 以 140–150 DPI 重渲染该 slide 并自行 Read 验证**后**再"修复"。

**内容 QA**：`python -m markitdown <Deck>.pptx | grep -iE "xxxx|lorem|undefined|TODO"` → 必须为空。

---

## 9. pptxgenjs 技术陷阱

- hex 颜色**不带** `#`；**不用** 8 位代码（把 opacity 嵌入 hex）→ 损坏文件。用单独的 `opacity` 属性。
- **不要**在多个 shape 间复用同一个 `shadow` 对象（pptxgenjs 就地修改）→ 用每次返回新对象的工厂：`const sh = () => ({...})`。
- bullet：用 `bullet:true` / `{code:"2022"}`，**不要**手敲 "•" 字符（导致双 bullet）。
- run/数组项之间用 `breakLine:true` 换行。
- `RECTANGLE`（无圆角）用于色带/accent；`ROUNDED_RECTANGLE` 用于圆角 card — 别把矩形 accent 盖在圆角上。
- 在 deck 目录内**本地**安装 `pptxgenjs`。
- 每个 presentation 需新实例（`new pptxgen()`），不要复用。

---

## 10. 复现清单（精简）

1. 询问：格式、受众、长度、图表处理、批判性分析、**字体 + 配色**。
2. 阅读论文：渲染每页 PDF → Read 图；提取全文。
3. 以 300 DPI 裁剪图表（按 caption bbox）→ 重新 Read 几张。
4. 用 STIX 渲染公式 → 透明 PNG；导出 `dims.json`。
5. 编写 `build_deck.js`：palette + helper + 按五部分框架的 slide。
6. `node build_deck.js` → `.pptx`。
7. `soffice` → PDF → PyMuPDF PNG → **2 个 subagent QA** → 修复 → 重渲染已修复的 slide 验证。
8. 内容 QA（markitdown grep placeholder）。
9. 更新 `wiki/index.md`（若输出在 `wiki/outputs/`）+ 追加 `wiki/log.md`。

---

## 11. 报告前自查清单

**图表与公式：**
- [ ] 论文每张所需图都已裁剪并嵌入（无遗漏）
- [ ] 图保持正确长宽比（经 `fitImg` + `dims.json`），无变形/裁切
- [ ] 公式渲染清晰、记号正确、背景透明

**设计与排版：**
- [ ] 1 套一致 palette，按角色分配；对比度达标（无浅压浅/深压深）
- [ ] 字体一致（正文 sans、公式 serif、代码 mono）
- [ ] 无元素重叠；无文字溢出 card/边缘；caption 不撞 footer
- [ ] 标题简洁、专业，避免强势动词/口语化

**内容与真实性：**
- [ ] 数字/表准确转录自论文；无捏造
- [ ] 批判性分析（如有）区分 strengths/limitations
- [ ] 无残留 placeholder（markitdown grep 为空）
- [ ] 已过 ≥ 1 轮 subagent QA + 修复 + 重渲染验证

---

## 12. 约束

- **`docs/ppt-guide.zh.md` 是 `/create-ppt` 的唯一规则来源**；不要自创额外规则。
- **不得捏造内容**：数字/引用须取自论文；缺失则删除或标注为假设。
- **论文原始图表逐字嵌入** — 不重绘、不捏造图表。
- **`raw/` 归用户所有**：只能向 `raw/tmp/` 添加临时文件，绝不覆盖输入。
- **不要覆盖**非本 skill 生成的现有 `.pptx`，除非已与用户确认。
- **不要编辑 `graph/`**；更新 `index.md` 并追加 `log.md`。
- QA 循环强制 — 未经至少一轮 QA + 修复，不得报告完成。
