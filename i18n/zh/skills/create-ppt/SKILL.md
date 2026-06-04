---
name: create-ppt
description: 从论文 PDF 构建高质量 PowerPoint (.pptx) 演示文稿——嵌入原始图表 + 渲染公式，含批判性分析，经过视觉 QA；遵循 docs/ppt-guide.vi.md 中的规则
argument-hint: "<output-dir-path> [--from <paper.pdf|slug>] [--type seminar|talk|intro]"
---

# /create-ppt

> 在 `wiki/outputs/<deck-slug>/` 下从论文 PDF（或其他内容来源）构建或更新一个**真正的 PowerPoint `.pptx` 文件**，使用 **pptxgenjs** 构建。
> 唯一规则来源：**`docs/ppt-guide.vi.md`** — 构建前完整阅读。
>
> 与 `/create-slides`（Obsidian 上的 Reveal.js/Markdown）不同：本 skill 输出可在 PowerPoint/Keynote 打开的 `.pptx` 文件，嵌入论文原始图表和从 LaTeX 渲染的公式。

## 调用方式

手动命令：`/create-ppt <output-dir-path> [--from <source>] [--type seminar|talk|intro]`

## 输入参数

- `<output-dir-path>`（必需）：deck 目录，例如 `wiki/outputs/dal-pinn-presentation/`。所有产物（脚本、图表、公式、`.pptx`）都放在其中。
- `--from <source>`（可选）：内容来源——`raw/papers/<paper>.pdf` 路径、wiki 页面 slug，或留空让用户直接描述内容。
- `--type <type>`（可选）：
  - `seminar` — 深度技术型，完整推导 + 全部图表 + 批判性分析（论文评审的默认值）
  - `talk` — 通用演讲，直觉/数学平衡
  - `intro` — 概览，少量公式
  - 留空 → 询问用户。

## 输出

- deck 目录 `wiki/outputs/<deck-slug>/`，包含：
  - `build_deck.js` — pptxgenjs 脚本（可复用的活模板）
  - `figures/` — 从论文以 300 DPI 裁剪的图表 + `figures/eq/` 渲染的公式 + `figures/dims.json`
  - `<Deck-Name>.pptx` — 最终输出
- 若输出位于 `wiki/outputs/`，更新 `wiki/index.md`
- 追加 `wiki/log.md`：`## [{date}] create-ppt | <简短描述>`

## Wiki 交互

### 读取
- **必需**：`docs/ppt-guide.vi.md` — 唯一规则来源；构建前打开。
- 视来源而定：按 `--from` 读取 `raw/papers/<paper>.pdf` 或 wiki 页面。

### 写入
- deck 目录 `wiki/outputs/<deck-slug>/`
- 阅读论文产生的临时文件 → `raw/tmp/<slug>/`（只增不改，绝不覆盖用户自有输入）
- `wiki/index.md`（若输出属于某个目录类别）与 `wiki/log.md`（append-only）

## 步骤

### 步骤 1：加载规则并询问决策

1. **完整阅读 `docs/ppt-guide.vi.md`** — 未在当前 session 重读规则前不要构建。
2. 询问用户必需的决策（规则 Section 1）：**格式、受众/深度、长度、图表处理、批判性分析、字体、公式字体、配色方案**。**一开始就**询问字体 + 配色——这两项最容易导致返工。
3. 验证工具链（Section 2）：PyMuPDF、matplotlib、pptxgenjs（本地安装）、`soffice`。用 `fc-list | grep -i <font>` 检查所需字体。

### 步骤 2：阅读论文并“看见”图表

按规则 Section 4：
1. 将每页 PDF 渲染为图像（PyMuPDF，~110 DPI），并用视觉 **Read 含图表的页面**以确认每张图的内容。
2. 提取全文（`page.get_text()`）以掌握技术细节、数字和公式。
3. **不得捏造**：数字/表格/引用必须直接取自论文。

### 步骤 3：裁剪图表并渲染公式

1. 按 caption bbox 以 300 DPI 裁剪每张图（Section 4）→ 使用描述性命名（`fig1_architecture.png`…）→ **Read 几张裁剪图**确认未被裁切/错位。
2. 用 matplotlib 将公式从 LaTeX 渲染为透明 PNG（Section 5）；按所选公式字体设置 `mathtext.fontset`；注意用 `\left|\right|` 代替 `\big`。
3. 导出 `figures/dims.json`（每个 PNG 的尺寸）以在嵌入时保持长宽比。

### 步骤 4：编写 `build_deck.js`

按规则 Section 6–7：
1. 将**配色定义为常量，按角色分配**；选择字体（正文用 sans、公式用 serif math、代码用 mono）。
2. 构建**可复用 helper**：`head`、`footer`、`divider`、`card`、`bullets`、`fitImg`（通过 `dims.json` 保持长宽比）、`caption`、`sh()` 阴影工厂。
3. 所有 slide 使用**浅色背景**（除非用户另有要求）；特殊 slide 在左侧加一条**竖向 accent 色带**。
4. 按**五部分框架**组织内容：Motivation → Method → Architecture → Experiments → Discussion。每张 slide 一个主旨；标题简洁专业（避免强势动词/口语化）。
5. 遵守 **pptxgenjs 陷阱**（Section 9）：hex 不带 `#`、不用 8 位 hex；真 bullet；阴影工厂；本地安装。

### 步骤 5：构建与 QA 循环（强制 ≥ 1 轮）

按规则 Section 8：
1. `node build_deck.js` → `.pptx`。
2. `soffice --headless --convert-to pdf` → 用 PyMuPDF 将 PDF 渲染为 PNG（无需 `pdftoppm`）。
3. **用 subagent 做 QA（新鲜的眼睛）** — 将 slide 分为 2 组，提示它*假定存在 bug*：溢出/重叠/对比度/caption 撞 footer/表格被截断。换主题时：另问“是否残留旧主题颜色？”。
4. 修复问题 → **重新渲染已修复的 slide 进行验证**。注意：subagent 报告“内容被压缩/图表过小”通常是 100 DPI 渲染的假象 → 以 140 DPI 重新渲染该 slide 并自行 Read 后再“修复”。
5. 内容 QA：`python -m markitdown <Deck>.pptx | grep -iE "xxxx|lorem|undefined|TODO"` 必须为空。

### 步骤 6：对照 Section 11 清单自查

逐项对照规则 Section 11（图表与公式 · 设计与排版 · 内容与真实性）。任何不达标项 → 报告前修复。

### 步骤 7：更新导航与日志

1. 若输出位于 `wiki/outputs/`，在 `wiki/index.md` 的 `Outputs` 类别下添加条目（见 `docs/runtime-support-files.vi.md`）。
2. 追加 `wiki/log.md`：`## [{YYYY-MM-DD}] create-ppt | <简短描述>`。
3. **不要触碰 `graph/`**。

### 步骤 8：汇报

- 列出：`.pptx` 路径、slide 数、类型、来源、嵌入图表数。
- 用 1–2 行总结主要内容。
- 提醒用户用 PowerPoint/Keynote 打开；deck 目录中的 QA PDF 可供快速预览。

## 约束

- **`docs/ppt-guide.vi.md` 是唯一规则来源** — 每个格式/设计/QA 决策都从中查阅；不要自创额外规则。
- **不得捏造内容**：数字/引用取自论文；缺失则删除或标注为假设。
- **论文原始图表逐字嵌入** — 不重绘、不捏造图表。
- **公式从 LaTeX 渲染**（PowerPoint 无 LaTeX）— 不要用普通文本敲数学符号。
- **`raw/` 归用户所有**：只能向 `raw/tmp/` 添加临时文件，绝不覆盖输入。
- **QA 循环强制** — 未经至少一轮 subagent QA + 修复 + 重渲染验证，不得报告完成。
- **不要覆盖**非本 skill 生成的现有 `.pptx`，除非已与用户确认。
- **不要编辑 `graph/`**；更新 `index.md` 并追加 `log.md`。

## 参考

- `docs/ppt-guide.vi.md` — 完整规则：工具链、图表裁剪、公式渲染、设计系统、内容框架、QA 循环、pptxgenjs 陷阱、清单
- `skills/create-ppt/references/build_deck.template.js` — 可直接使用的 pptxgenjs 脚手架（配色 + `head/footer/divider/card/bullets/fitImg/caption` helper + 阴影工厂）。复制到 deck 目录，替换配色/内容，然后 `node build_deck.js`
- `docs/runtime-support-files.vi.md` — 更新导航时的 `index.md` / `log.md` 格式
- pptxgenjs：<https://github.com/gitbrent/PptxGenJS>
- 对比：`/create-slides` 输出 Reveal.js/Markdown（Obsidian）；`/create-ppt` 输出真正的 `.pptx` 文件
