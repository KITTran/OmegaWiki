# 幻灯片指南：格式、风格与规则

> wiki 中编写 Reveal.js 幻灯片的通用指南。
> 适用于各类演示：research summary、论文讲解、技术报告、教学、项目评审。
> **默认引擎**：Obsidian + 插件 [`obsidian-advanced-slides`](https://github.com/MSzturc/obsidian-advanced-slides)（底层为 Reveal.js）。

---

## 1. Frontmatter 结构（YAML + CSS）

每个幻灯片文件以配置 Reveal.js 的 YAML frontmatter 开头，随后是 `<style>` 块：

```yaml
---
theme: black            # 或 white, league, beige, sky, night, serif, simple, solarized
transition: slide       # 或 fade, convex, concave, zoom, none
width: 1280
height: 800
center: false           # 默认左对齐
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

**frontmatter 之后**，再加一个独立的 `<style>` 块做额外覆盖：

```html
<style>
.reveal .slides section { text-align: left; }
.reveal .slides > section,
.reveal .slides > section > section { top: 0 !important; padding-top: 30px; }
</style>
```

**核心原则：**
- **`center: false`** + **`text-align: left`** — 左对齐幻灯片，阅读自然
- **参考字号**：base 22px（内容密集的幻灯片），H1 ~1.8em，H2 ~1.4em，H3 ~1.1em — 按内容密度调整
- **表格**：比正文略小 ~0.75em，单元格 padding 4px 8px
- **公式**：~0.9em（比正文略小以免换行）
- **`!important`** 用于 Reveal.js 容易覆盖的属性（padding、top、MathJax font-size）

**何时调整字号**：少字幻灯片 → 更大字号（28-32px）；lecture 式（文字密集）幻灯片 → 保持上面的 22px。

---

## 2. 幻灯片层级

### 整场演示标题页 — 在文件开头用 `#`

```markdown
# 演示标题

## 副标题或子主题

**作者姓名** · Date

简短描述（如：论文数、实验数、范围）
```

### 章节标题页 — 用 `#`（H1）

```markdown
# I. 第一部分
```

用罗马数字、序号或清晰标题标记大章节。仅章节开篇幻灯片用 H1。

### 内容页 — 用 `##`（H2）

```markdown
## 幻灯片标题
```

### 幻灯片内子标题 — 用 `###`（H3）

```markdown
### 幻灯片内的子分组
```

### 幻灯片分隔 — `---`（三个短横）

单独一行 `---` 生成新幻灯片。前后留空行，以免与表格/列表的分隔符混淆。

---

## 3. 两栏布局

使用自定义 `<split>` 标签，内含两个子 `<div>`：

```markdown
<split even gap="2">

<div>

左栏内容...

</div>

![[path/to/image.png|widthxheight]]

</split>
```

**规则：**
- `even` — 均分空间；可用 `<split left="60" right="40">` 改变比例
- `gap="2"` — 两栏间距（em 单位）
- 左栏：文字/描述；右栏：图片、表格或摘要文字
- 文字内容始终放在 `<div>` 内；图片可放在 `<div>` 外（右栏自动）
- 避免在一栏塞 >5 个 bullet — 太挤就拆分幻灯片

---

## 4. 表格

### 通用对齐规则

```markdown
| Col1 | Col2 | Col3 |
|---|:---:|---:|
| left-aligned | center | right-aligned |
```

- `---` → 左对齐（默认）
- `:---:` → 居中（用于小值列、label）
- `---:` → 右对齐（用于数字列）

### 表格内强调

- **加粗** 用于：最佳行 / baseline、重要值、突出名称
- 空单元格 / 参考 baseline 用 `—`
- 负数用 `−`（Unicode 减号）而非 `-`
- ranking 用 `**1**`、`**2**` 编号
- *斜体* 用于次要注释（如 `kan-single *(baseline)*`）

### 表格尺寸

- 过宽的表格 → 减少列、合并 metric，或拆成 2 个表
- 行数过多（>10）的表 → 考虑拆分幻灯片或对次要表格用 `<small>`
- 表头应简短 — 避免超过 2-3 个词

---

## 5. 数学公式书写

### 行内与块级公式

```markdown
行内：句中的 $f(x) = x^{2}$。

块级独立：
$$\mathcal{L} = w_1 \mathcal{L}_1 + w_2 \mathcal{L}_2$$
```

### 常用符号

| 符号 | 代码 | 含义 |
|---------|------|---------|
| $\mathcal{L}$ | `\mathcal{L}` | Loss / Lagrangian（calligraphic） |
| $\mathbb{E}$ | `\mathbb{E}` | 期望（blackboard bold） |
| $\mathcal{N}$ | `\mathcal{N}` | 正态分布 |
| $\mathcal{O}$ | `\mathcal{O}` | Big-O notation |
| $\nabla$ | `\nabla` | 梯度 |
| $\partial$ | `\partial` | 偏导数 |
| $\|A\|$ | `\|A\|` | Norm（double pipe） |
| $\|A\|^{2}$ | `\|A\|^{2}` | 范数平方 |
| $\propto$ | `\propto` | 正比于 |
| $\mathrm{Tr}(K)$ | `\mathrm{Tr}(K)` | Trace，roman 体 |
| $\mathrm{MSE}$ | `\mathrm{MSE}` | 缩写函数名 |
| $\cdot$ | `\cdot` | 乘号 |
| $\mapsto$ | `\mapsto` | 映射到 |
| $\to$ | `\to` | 到 / 推出 |
| $\approx$ | `\approx` | 约等于 |
| $\sim$ | `\sim` | 服从 / 同阶 |
| $\gg$ | `\gg` | 远大于 |

### 公式书写规则

- **块级公式**（`$$...$$`）用于需要突出的重要公式；**行内**（`$...$`）用于句中短符号/表达式
- **只用 `$$...$$`** — 不用 LaTeX 环境（`\begin{equation}`、`\begin{align}`）；Reveal.js 上的 MathJax 不稳定支持
- 公式保持**短到能放在一行** — 幻灯片不是论文
- 用 `\cdot` 而非 `*`
- 双竖线范数用 `\|`，**不要**用 `||`
- 数学中的文字用 `\mathrm{}`：`\mathrm{MSE}`、`\mathrm{PDE}`、`\mathrm{Tr}`
- **指数必须放在 `{}` 内**：形如 `$<operator>^<数字>$` 的公式，`<数字>` 必须在 `{}` 内
  - 正确：`x^{2}`、`\nabla^{2}`、`N^{2}`、`L^{2}`、`[0,1]^{2}`、`10^{-3}`
  - 错误：`x^2`、`\nabla^2`、`N^2`、`10^-3`
  - 单字符（`^{2}`）和多字符（`^{ij}`、`^{-1}`）都适用
  - 单字符下标（`\mu_1`、`K_2`、`J_0`）保持原样，无需 `{}`
- 多字符或含特殊字符的下标必须用 `{}`：`\mathcal{L}_{\mathrm{total}}`、`x_{i,j}`

### 独立公式在预览中必须居中

幻灯片对所有内容使用 `text-align: left`（见 Section 1）— 但**独立的块级公式 `$$...$$` 在预览中必须居中**，使公式成为视觉焦点，阅读通透且突出。这是公式专属约定，与文字左对齐规则不冲突。

由于 `obsidian-advanced-slides` 从 section CSS 继承 `text-align: left`，块级公式默认左对齐。要强制居中，用以下两种方式之一：

**方式 1 — 包在居中 `<div>` 中（推荐，最稳定）：**

```markdown
<div style="text-align: center;">

$$\mathcal{L}_\mathrm{total} = w_\mathrm{pde}\mathcal{L}_\mathrm{pde} + w_\mathrm{bc}\mathcal{L}_\mathrm{bc}$$

</div>
```

**方式 2 — 在文件开头的 `<style>` 块加全局 CSS 规则**（应用于文件内所有块级公式）：

```css
.reveal .slides section .math.math-display,
.reveal .slides section mjx-container[display="true"],
.reveal .slides section p:has(> mjx-container[display="true"]) {
  text-align: center !important;
}
```

文件有很多块级公式且想统一应用时选方式 2；只有少数几处需要居中时对具体公式选方式 1。

**应用规则：**
- **独立成行**的块级公式 `$$...$$`（不在 bullet 内）→ **居中**
- 行内公式 `$...$` → 保持在句中行内，不单独成行，不居中
- bullet 内的块级公式 → 随 bullet 保持左对齐（以免破坏列表布局）
- 带 caption/label 的公式 → 把公式和 caption 一起包进同一个 `<div style="text-align: center;">`

---

## 6. 图片

### Obsidian 风格语法

```markdown
![[path/to/image.png|widthxheight]]
```

- 路径相对于幻灯片文件所在目录
- 用像素指定尺寸：`|520x440`
- 可只指定一个维度：`|520`（保持长宽比）

### 参考尺寸

- **split 栏**：宽 420–520px × 高 340–440px
- **全屏**（full-width）：宽 800–900px
- **小型行内 diagram**：宽 300–400px

### 何时用图

通用规则：一张图必须传达文字在同等面积内无法表达的内容。
- comparison plot、架构 diagram、pipeline diagram
- 空间数据的地图/heatmap
- 比较 metric 的 bar/line chart
- UI/UX 演示的截图

避免纯装饰用图 — 深色主题的左对齐幻灯片已足够专业。

---

## 7. 写作风格

### 语言

- 越南语为主要语言（若受众为越南人）；全篇一致选定一种主要语言
- 领域内已标准化的**技术术语保留英文**（如 "loss function"、"gradient descent"、"API"、"framework"）
- 不要半译 — 要么整词全译，要么整词保留
- 引号 `""` 用于引用，`''` 用于概念/标签

### 文风

- **专业、中立的表述，不过分简短，读起来流畅**
  - 避免电报式短句 "X good. Y bad." — 写 "X 在……条件下比 Y 给出更好的结果"
  - 避免广告腔（"突破"、"卓越"、"超快"）— 用带数据的客观描述
  - 避免非标准缩写 / 俚语（如 "ko"、"vs."、"etc"）
  - 避免祈使句或感叹句 — 这是技术幻灯片，不是营销
  - bullet 可以短，但每条应读起来像一个完整子句，而非残缺片段
- **bullet 简短**，不写冗长句子 — 仍需主谓以自然阅读
- **一行一个要点** — 若需多次换行，或许应拆 bullet
- **加粗**（`**text**`）用于：
  - 名称（论文、人、工具、方法）
  - 重要数字/metric
  - 需强调的结论/关键词
- 用 `—`（em dash）或 `:` 解释 / 展开
- 用 `→`（箭头）表示"导致"、"表明"、"迈向"
- 用 `·`（middle dot）作短项间的轻分隔

### 常见幻灯片结构

**概念 / 理论页**

```markdown
## 想法名称

**定义 / 理论**

简短描述...
$$公式（如有）$$

**为何重要**（或"为何选此"）

- 理由 1
- 理由 2

**实现 / 应用**

简短描述用法 / pipeline。
```

**结果 / 数据页**

```markdown
## 实验 / 结果名称

<split even gap="2">

<div>

### Metrics

| Metric | Value |
|---|---|
| Accuracy | **95.2%** |
| Latency | 12 ms |

**简短分析**

主因、评论。

</div>

![[image.png|520x440]]

</split>
```

**对比 / overview 页**

```markdown
## 主题名称

**共同问题**：简短描述

| 项 | 贡献 | Imp |
|---|---|:---:|
| Item A | ... | **5** |
| Item B | ... | 4 |
```

---

## 7.1 论文评审 / 文献综述模式

讲解多篇论文（related work、survey、文献综述）时，用三层流程：**主题 overview → 论文细节 → 总结**。避免把多篇论文塞进一个表 — 每篇论文值得单独一页，让听众跟得上。

### 整体流程

```
主题 N — 主题名称                  ← 1 overview 页
├── N.1 Paper A — 简短 slogan       ← 1 页 / 论文
├── N.2 Paper B — 简短 slogan       ← 1 页 / 论文
└── N.3 Paper C — 简短 slogan       ← 1 页 / 论文
related work 总结                   ← 1 章节收尾页
```

### 主题 overview 页

开启每组论文 — 陈述共同问题、trade-off，以及接下来要讲的论文列表。

```markdown
## 主题 N — 主题名称

**共同问题**：这组论文所解决问题的简短描述

**trade-off**：陈述该方向的共同权衡（如有）

**N 篇代表论文**

- Paper A (Venue Year, Imp **5**) — 一句话贡献
- Paper B (Venue Year, Imp **4**) — 一句话贡献
- Paper C (Venue Year, Imp **4**) — 一句话贡献
```

**规则：**
- 标题用 em dash `—` 分隔主题编号与名称：`## 主题 2 — 训练稳定性`
- 每主题列 2–4 篇；更多应拆成子主题
- 每篇一个 bullet — 不塞多余 metadata

### 每篇论文细节页

这是每篇论文的核心模式。4 块结构：**Header → 方法 → 主要结果 → Ref**。

```markdown
## N.X 简称 — 一句话 slogan

**Paper**：*完整标题*（Venue Year, 作者如需）· Imp **5** · 次要 metadata

**方法**
- 核心想法（1 句 / bullet）
- 重要公式（如需）：

$$\text{独立块级公式}$$

- 次要组件 / 架构 / pipeline
- 其他显著特征

**主要结果**（带 benchmark / dataset）
- 主 metric 带具体数字并**加粗**
- 体现优势的代表性例子
- 局限 / 适用条件（如需平衡）

<small>Ref: `wiki-中的论文-slug`</small>
```

**规则：**
- 幻灯片标题：`## <号>.<号> <简称> — <slogan>`（如 `## 2.1 NTK PINN — 诊断训练失败`）
- slogan 简短（3–7 词），陈述论文的**视角**，不重复名称
- 页首 `**Paper**:` 行：斜体标题 + venue/year + importance score + citations/conf（如显著）
- **方法**：3–5 个 bullet，优先核心想法和 1 个关键公式（每页不超过 1 个块级公式）
- **主要结果**：必须有**具体数字**，不空泛（"显著改善" → "把 $L^{2}$ 从 X 降到 Y"）
- 数据多维时可用 metric 表代替 bullet（如 I-PINNs 的 4 个 benchmark）
- 页尾始终有 `<small>Ref: ...</small>` 指向 wiki 中的论文 slug

### related work 总结页

放在 related work 章节末尾，在进入下一部分前收束全局图景。

```markdown
## related work 总结与空白

**已讲 N 篇论文** — 按 M 个主题分组

| 主题 | Papers | 主要贡献 |
|---|---|---|
| **1. 主题名称** | Paper A (5), Paper B (4) | 综合贡献 |
| **2. ...** | ... | ... |

**主要研究空白**
- Gap 1 — 尚无通用解
- Gap 2 — 未系统测试
- Gap 3 — 结果好但限于 2D / 特定情形
```

**规则：**
- 表格压缩凝练 — 每主题一行，论文带括号内 importance
- **空白**部分为后续指明方向（演示贡献的 motivation）

### 流程变体：单论文评审（1 篇深入）

若需**单篇论文**深入讲解（paper club、deep dive），把 1 页换成 4–6 页，按此流程：

```
1. Paper context — 问题、motivation         ← 1 页
2. 主要想法 — main contribution             ← 1 页
3. 方法 — 公式、架构                         ← 1–2 页
4. 结果 — benchmark、comparison             ← 1–2 页
5. 局限与 open questions                     ← 1 页
6. 与自己工作的关联                          ← 1 页（可选）
```

每页结构仍遵循 Section 7（写作风格）的通用模式。

### 让论文评审不枯燥的技巧

- **每篇专属 slogan**：与其重复论文名，用各自视角（如 NTK — "诊断训练失败"；VS-PINN — "stiff PDE 的 variable scaling"）
- **具体数字**：每篇至少有 1–2 个量化贡献数字（speedup、error reduction、accuracy）
- **形式多样**：交替使用 bullet、块级公式、metric 表 — 别让每页看起来一样
- **论文间关联**：介绍论文 N 时可提及前面论文 M 解决了哪个方面

---

## 7.2 想法 / 方法提案模式

讲解想法（proposal、hypothesis、method design、实验方案）时，目标是让听众抓住**两件事**：该想法在理论上是什么，以及为何选择这样构建。用两块模式：**理论 → 构建理由**。

### 模板

```markdown
## 想法 N：想法简称

**理论** — 一句开头陈述核心机制：

$$\text{主公式（如有）}$$

一段解释公式含义及其次要组件。若多部分协同，用 2–3 个短 bullet：

- **部分 A**：作用与机制（1 句）
- **部分 B**：作用与机制（1 句）
- **部分 C**：作用与机制（1 句）

**构建理由**：一段连贯文字解释动机 — 此前的实验观察、文献的理论依据，或两者指向同一方向。讲清为何此想法是有依据的试验，而非随意选择。
```

### 各块规则

**理论**
- 用 `**理论** — <简短描述>:` 开头直入内容
- 若公式是关键，紧接开头句放**块级公式**；每页至多 1 个块级公式
- 若想法有多个组件（如结合 3 项改进），用短 bullet，模式为 `**部分名称**：作用 + 机制`
- 避免过度罗列 implementation 细节（层数、optimizer、epoch）— 那属于结果页，而非想法页

**构建理由**
- 写成**连贯段落**，不用残缺 bullet — 这是说服部分，需流畅语气
- 至少陈述以下一种依据：(1) 此前实验的观察，(2) 文献中论文的 claim（如有 conf 则注明），(3) 当前问题与已解 benchmark 的结构相似性
- 避免广告腔（"突破性想法"、"很有潜力"）— 阐释为何此方向可行的逻辑
- 末句可在适当时陈述具体期望（如"期望给出推理快、精度近似 FEM 的模型"）

### 示例

```markdown
## 想法 3：Curriculum source sharpening

**理论** — 用带锐度控制参数的光滑函数近似分片 source：

$$J(x) \approx J_0 \cdot \left[\sigma(k(x-a)) - \sigma(k(x-b))\right]$$

参数 $k$ 控制锐度 — 当 $k \to \infty$ 函数趋近阶梯。curriculum 计划跨训练阶段递增 $k$：

- 以低 $k$ 起步 — source 光滑，loss landscape 局部极值更少
- 逐步增大 $k$ 以趋近 $J_\mathrm{exact}$，同时保持训练稳定

**构建理由**：ablation 显示 $J_\mathrm{exact}$ 使 Az 比 $J_\mathrm{smooth}$ 差约 4× — 暗示过锐的 source 造就难以优化的 loss landscape。逐步递增的 curriculum 计划是兼得两者优点的自然方式：低 $k$ 易起步，高 $k$ 精确收敛。
```

### 多想法成组的流程

多个想法属同一组时（如同一问题的 4–6 个提案），按此流程组织：

```
overview 页：总览 N 个想法的表          ← 1 页
├── 想法 1：名称                        ← 1 页 / 想法
├── 想法 2：名称                        ← 1 页 / 想法
└── 想法 N：名称                        ← 1 页 / 想法
综合结果页（运行后）                    ← 1 页
```

**overview 页**用 3-4 列表：

```markdown
## N 个想法总览

| 想法 | 机制 | 理论依据 | 状态 |
|---|---|---|---|
| 想法 1 | 简短机制 | Paper / 概念 | 未运行 |
| 想法 2 | 简短机制 | Paper / 概念 | 达标 |
```

**状态**列仅在有实验结果后填写；此前留空或写"提案"。overview 页充当目录 — 听众预先知道有多少想法、将在后续各页逐一讲解。

### 想法页技巧

- **理论与实现分离**：想法页讲 *what* 和 *why*；结果页讲 *how* 和 *outcome*。别把两者塞进一页。
- **公式是支撑而非负担**：若公式太长放不进一行，用散文书写而非硬塞进 `$$...$$`
- **构建理由必须可溯源**：引论文则注明 slug 和 conf；引实验则注明 wiki 中的 experiment 名
- **想法页无需列局限** — 局限属于试运行后的结果/讨论部分

---

## 7.3 来源与内容真实性

**通用原则**：幻灯片上每个陈述都必须可溯源，或明确标记为假设 / 个人观察。技术幻灯片不是未验证 claim 的场所 — 听众必须知道每个数字 / claim 来自何处以评估可信度。此规则适用于**各类幻灯片**，不仅 related work 或想法提案。

### 1. 将每个陈述分为三类

写任何断言前，自问它属于哪类 — 并清晰标记以便听众区分：

- **有来源的 fact**：来自 peer-reviewed 论文、official documentation 或已发布 dataset 的 claim。必须带来源（slug、citation、link，或页尾 reference）。
- **来自自己实验的观察**：作者存于 wiki / log 的实验结果。必须带 experiment slug + seed + 所测的具体 metric。
- **作者的假设**：尚未验证的推测、预测或个人论点。必须用假设性措辞清晰标记（"假设"、"期望"、"可能"、"暗示"）— 不当作 fact 呈现。

避免三类在一句中混杂而不区分 — 如"方法 X 降低 error 30% 且将适用于 3D"把 fact（30%）与假设（3D）混杂，对听众毫无警示。

### 2. fact 的权威来源

呈现 fact 时，只引可验证来源：

- **peer-reviewed 论文**：带 venue/year + wiki 中 slug（如 `NTK PINN, JCP 2022, conf 0.92`）
- **official documentation**：framework / tool / standard 的官方文档
- **带 log + code 的实验**：wiki 中可复现的 experiment，带 slug + seed + 运行日期
- **已发布 benchmark**：带 DOI 或原始论文的 dataset / benchmark

**不可作 fact 引用**：
- 未验证的 blog post、tweet、forum thread
- 无具体来源的约略记忆数字
- 无法溯源到原始论文的"众所周知"式 claim
- 无 seed / 不可复现的单次运行结果
- 作者未独立验证的 AI 生成内容

若只有弱来源，把句子写成假设或直接删去 — 不要靠呈现为断言把弱来源"升级"成 fact。

### 3. 数字必须具体且可溯源

幻灯片上每个数字都需足够上下文供听众评估：

- **明确 metric**："RMSE 0.056 mm" 优于 "误差小"
- **比较 baseline**："Az R² 0.99 (kan-single) vs 0.73 (fd-warm-start)" 优于 "Az R² 0.99"
- **dataset / setting**："Aluminum 2024 上的 9 个 flat-bottom holes" 优于 "在某 NDT benchmark 上"
- **来源 slug**：带 `<small>Ref: slug</small>` 以溯回 log / 论文

避免"装饰性"数字 — 如"很快的 speedup"需具体化为"9 个 PDE benchmark 上 4–5 个数量级的 speedup"并带明确来源。无上下文的数字最好删去。

### 在文风中标记陈述类型

用典型措辞帮助听众在阅读时区分 claim 类型：

| 类型 | 典型措辞 |
|---|---|
| 有来源的 fact | "达到"、"报告"、"证明"、"表明"、"发布" |
| 实验观察 | "实验 X 观察到"、"managed rerun 显示"、"可复现" |
| 假设 / 推测 | "可能"、"暗示"、"假设"、"期望"、"有可能" |

**区分示例：**

- *Fact*："VS-PINN 把 wave equation 误差从 63.1% 降到 1.2%（JCP 2024）"
- *观察*："Managed rerun 2026-06-01 显示 kan-single 达到 Az R² 0.9924，2 次运行可复现 ±0.001"
- *假设*："类似方法可能在 nondim first-order 中把幅度坍缩减少 36×"

三句动词结构不同 — 听众无需额外注释即可立即区分陈述类型。

---

## 8. 注释与 References

### 页尾注释 — 用 `<small>`

```markdown
<small>Refs: `paper-slug-1` · `paper-slug-2`</small>
```

- 用 `<small>` 缩小
- slug、ID 或简称（不用完整名 — 太长）
- 用 ` · `（middle dot）分隔
- 放在幻灯片末尾，主内容之后

### Metadata / 短标签

用 `**名称**: 值` 短语快速附加 metadata — 如 `**Date**: 2026-06-04`、`**Conf**: 0.92`、`**Status**: in progress`。

---

## 9. 实用模式

### Flow chart / Pipeline（基于文字，无需图）

```markdown
Phase 1: data prep
├── step 1.1                            → output A
├── step 1.2                            → output B
└── step 1.3                            → output C
Phase 2: training
└── ...
```

用 `├──`、`└──`、`│` 字符画的树在 terminal 风格主题中清晰可读。

### findings 总结 — 短对比表

```markdown
| 技术 / 方法 | 影响 | 评论 |
|---|---|---|
| Approach A | +X% | 可靠 |
| Approach B | −Y% | 需条件 ... |
```

### 状态 — 标准措辞

列 experiment/idea 状态时，用简短一致的措辞：`达标` / `未达标` / `运行中` / `不稳定` / `达到目标`。

### Callout / 强调

正文中把重要要点包进简短 `**...**`（不超过 1 行）。避免用 blockquote `>` 做 callout — 在许多主题中渲染不佳。

---

## 10. 重要注意事项

### 布局

- **全局左对齐**（`center: false` + `.reveal .slides section { text-align: left; }`）
- **内容不溢出幻灯片** — 太密则拆成 2 页或精简
- **图片始终带尺寸** — 别让 Reveal 自选
- **表格不过宽** — 参考字号 0.75em，padding 适中

### 内容

- **每页一个主要要点**；幻灯片标题已说明该要点是什么
- **数字需上下文** — 无 baseline / 单位则不给绝对数字
- **始终标注单位**：%、ms、GB、R²、MAPE
- **引用来源**：每次使用外部资料的数据 / claim 时

### 公式

- 只用 `$$...$$` 和 `$...$` — 不用 LaTeX 环境
- 块级公式应独立，不在 bullet 内
- 上下标遵循 Section 5 的规则

### 颜色与强调

- 选定一个主题（`black`、`white`、`league`...）并坚持
- **加粗**是主要强调工具 — 勿滥用（一页 >30% 加粗 = 失去强调）
- 不加行内颜色（`<span style="color:..">`）— 破坏主题且难维护
- 用 `<small>` 弱化（references、captions、footnotes）

---

## 11. 完成前检查清单

- [ ] frontmatter 完整（theme、transition、width、height、center、controls、progress）
- [ ] CSS style 块覆盖字号与 `text-align: left`
- [ ] `center: false`
- [ ] H1 仅用于章节开篇 / title 页
- [ ] 幻灯片间有 `---`，前后留空行
- [ ] 图片有具体尺寸 `|widthxheight`
- [ ] 表格在需要时有对齐标记 `:---:`、`---:`
- [ ] 公式用 `$$...$$` 或 `$...$`（不用 LaTeX 环境）
- [ ] 指数在 `{}` 内：`x^{2}`，而非 `x^2`
- [ ] 多字符下标在 `{}` 内：`\mathcal{L}_{\mathrm{total}}`
- [ ] 独立块级公式在预览中居中（包 `<div style="text-align: center;">` 或用全局 CSS 规则）
- [ ] 页尾来源注释为 `<small>` 形式
- [ ] 重要 metric 与突出名称加粗
- [ ] 内容不溢出幻灯片 — 太密则拆页
- [ ] 单一一致的主要语言（VN 或 EN，不混用）
- [ ] 文风专业、中立、流畅 — 不残缺、不广告

### 来源与真实性

- [ ] 每个 fact 都有来源（peer-reviewed 论文 / official doc / 带 log 的 experiment）
- [ ] 不把 blog、tweet、forum 或约略数字作 fact 引用
- [ ] 假设 / 推测清晰标记（"可能"、"期望"、"假设"）
- [ ] 实验观察带 experiment slug + seed + 具体 metric
- [ ] 每个数字有完整上下文：metric / baseline / dataset / 来源
- [ ] 不在一句中混杂 fact + 假设而不区分
- [ ] 页尾 references 为 `<small>Ref: slug</small>` 或等价形式
- [ ] 文献来的 claim 带 conf（如有，如 `conf 0.92`）
