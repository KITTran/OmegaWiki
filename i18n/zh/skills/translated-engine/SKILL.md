--- 
description: 技术翻译引擎，在语言间（en/vi/zh）保留上下文、含义、语气和技术关键词。翻译 skill 文档、shared references 和 wiki 内容，同时与现有术语和项目规范保持一致。
argument-hint: <source-path> <target-lang> [--dry-run] [--force]
---

# /translated-engine

> ΩmegaWiki 的技术翻译引擎。翻译 skill 文档、shared references 和 wiki 内容，同时保留：
> - 上下文和领域特定含义
> - 技术语气和学术严谨性
> - 不得翻译的关键词（commands、flags、paths、API 名称、field 名称）
> - Markdown 结构和代码块
> - 与现有翻译的跨语言一致性

## 输入

- `source-path`：待翻译源文件的路径（必须位于 `i18n/en/`、`i18n/vi/` 或 `i18n/zh/` 内）
- `target-lang`：目标语言代码（`en`、`vi` 或 `zh`）
- `--dry-run`（可选）：预览翻译内容，不写入磁盘
- `--force`（可选）：无需确认直接覆盖已有目标文件

## 输出

- 翻译后的文件写入目标语言目录中的对应路径
- 翻译报告（打印到终端），包含：
  - 保留的技术术语列表（commands、flags、paths、API 名称、field 名称）
  - Markdown 结构校验结果
  - 一致性警告（如有术语与现有翻译冲突）

## Wiki 交互

### 读取
- `source-path` 指定的源文件
- 目标语言目录（`i18n/<target-lang>/`）中所有现有文件（用于一致性检查）
- `i18n/en/CLAUDE.md`、`i18n/vi/CLAUDE.md` 和 `i18n/zh/CLAUDE.md`（用于项目规范）
- `docs/runtime-page-templates.md`（用于 Markdown 结构规则）

### 写入
- 翻译文件写入 `i18n/<target-lang>/<relative-path>`（仅在非 `--dry-run` 模式下）
- 不修改 wiki 内容或 graph 文件

## 工作流

### 第 1 步：翻译前分析

1. **校验输入**：
   - 确认 `source-path` 存在且位于 i18n 目录内
   - 确认 `target-lang` 为 `en`、`vi` 或 `zh` 之一
   - 检查目标文件是否已存在（除非指定 `--force`）

2. **提取技术关键词**：
   - 识别所有 commands（例如 `/ingest`、`/exp-run`）
   - 识别所有 flags（例如 `--discover`、`--full`）
   - 识别所有 paths（例如 `wiki/papers/`、`raw/discovered/`）
   - 识别所有 API 名称、field 名称和 enum 值（例如 `DEEPXIV_TOKEN`、`supports`、`contradicts`）
   - 识别所有 wikilinks（例如 `[[slug]]`、`[[flash-attention]]`）
   - 识别所有代码块和行内代码

3. **一致性检查**：
   - 将识别到的关键词与 `i18n/<target-lang>/` 中的现有翻译对比
   - 标记与现有术语的不一致之处
   - 生成不得翻译的术语列表

### 第 2 步：翻译

1. **保留结构**：
   - 保留所有 Markdown 元素（标题、列表、表格、引用块、代码围栏）
   - 保留 YAML frontmatter 原样不变
   - 保留第 1 步中识别的所有技术关键词

2. **基于上下文翻译**：
   - 对每个段落/章节，分析周围上下文以确定：
     - 领域（ML 研究、实验设计、论文写作等）
     - 语气（技术性、学术性、指导性）
     - 目标读者（研究人员、开发者）
   - 按领域应用翻译规则：
     | 领域 | 翻译方式 |
     |------|----------|
     | Commands/Flags | 保留原文（例如 `/ingest --discover` → `/ingest --discover`） |
     | 技术术语 | 若该领域已有惯用译法则保留原文（例如 "LoRA"、"attention mechanism"） |
     | 学术写作 | 适应目标语言的学术表达惯例 |
     | 错误信息 | 翻译同时保留技术精确性 |

3. **处理特殊情况**：
   - **Wikilinks**：保留 slug 格式，仅在适当时翻译显示文本
     ```markdown
     [[flash-attention]] → [[flash-attention]] （不变）
     [[lora-low-rank-adaptation|LoRA]] → [[lora-low-rank-adaptation|LoRA]] （不变）
     ```
   - **代码块**：完整保留，包括注释
   - **JSON/YAML**：保留所有键和 enum 值，仅在适当时翻译字符串值
   - **表格**：翻译内容同时保持对齐和格式
   - **占位符**：保留所有占位符（例如 `{slug}`、`{date}`）

### 第 3 步：翻译后校验

1. **Markdown 校验**：
   - 验证所有标题层级匹配
   - 验证所有列表缩进正确
   - 验证所有代码围栏正确闭合
   - 验证所有表格格式正确

2. **一致性校验**：
   - 重新检查所有保留关键词与现有翻译的一致性
   - 验证没有技术术语被误译
   - 验证所有 wikilinks 使用正确的 slug 格式

3. **上下文校验**：
   - 抽样关键章节，确保含义和语气得到保留
   - 验证技术指令仍具可操作性
   - 验证学术论证保持逻辑流畅

### 第 4 步：输出

1. 若指定 `--dry-run`：
   - 将翻译内容打印到终端
   - 打印翻译报告
   - 不写入磁盘

2. 若未指定 `--dry-run`：
   - 将翻译内容写入目标路径
   - 将翻译报告打印到终端
   - 若目标文件已存在，创建 `.bak` 扩展名的备份

## 翻译规则

### 必须保留原文不翻译
- Commands：`/ingest`、`/exp-run`、`/paper-draft` 等
- Flags：`--discover`、`--full`、`--env`、`--difficulty` 等
- Paths：`wiki/papers/`、`raw/discovered/`、`experiments/code/` 等
- API 名称：`DEEPXIV_TOKEN`、`SEMANTIC_SCHOLAR_API_KEY` 等
- Field 名称：`target_claim`、`evidence`、`confidence`、`slug` 等
- 边类型：`supports`、`contradicts`、`tested_by`、`invalidates` 等
- Enum 值：`ready`、`needs-work`、`major-revision`、`rethink` 等
- 文件扩展名：`.md`、`.tex`、`.pdf`、`.jsonl` 等
- 代码标识符：变量名、函数名、类名
- Wikilinks：必须保留 `[[slug]]` 格式
- 占位符：`{slug}`、`{date}`、`{score}` 等

### 必须翻译
- 解释概念、指令或论证的描述性文本
- 学术短语和过渡词
- 错误信息和用户提示
- 章节标题和列表项
- 表格内容（同时保留格式）
- 引用块内容

### 条件翻译
- **技术术语**：仅在目标语言中有公认译法时才翻译，否则保留原文。
  - 示例（英文 → 中文）：
    - "attention mechanism" → "注意力机制"（翻译）
    - "gradient descent" → "梯度下降"（翻译）
    - "LoRA" → "LoRA"（保留）
- **缩写**：若在该领域中常用则保留（例如 "LoRA"、"SOTA"），否则展开并翻译。
- **引用**：保留引用键不翻译，但在适当时翻译周围文本。

## 一致性保障

1. **术语数据库**：维护一个内部翻译术语数据库，每次翻译后更新：
   ```json
   {
     "commands": {
       "/ingest": {"en": "/ingest", "vi": "/ingest", "zh": "/ingest"},
       "/exp-run": {"en": "/exp-run", "vi": "/exp-run", "zh": "/exp-run"}
     },
     "flags": {
       "--discover": {"en": "--discover", "vi": "--discover", "zh": "--discover"},
       "--full": {"en": "--full", "vi": "--full", "zh": "--full"}
     },
     "terms": {
       "confidence": {"en": "confidence", "vi": "độ tin cậy", "zh": "置信度"},
       "evidence": {"en": "evidence", "vi": "bằng chứng", "zh": "证据"}
     }
   }
   ```

2. **一致性检查**：翻译任何术语前，先查询术语数据库：
   - 若术语已在数据库中，使用已有译法
   - 若术语不在数据库中，判断是否应翻译，然后加入数据库
   - 标记与现有翻译的任何冲突

3. **全项目一致性**：
   - 首次翻译某术语时，搜索目标语言中所有现有文件以排查潜在冲突
   - 与以下已有术语保持一致：
     - `i18n/<lang>/CLAUDE.md`
     - `docs/runtime-page-templates.md`
     - 现有 skill 文档

## 错误处理

- **源文件未找到**：列出源目录中的相似文件
- **无效的目标语言**：列出有效语言代码（`en`、`vi`、`zh`）
- **目标文件已存在**：提示确认，除非指定 `--force`
- **Markdown 解析错误**：尝试恢复结构，标记有问题的章节
- **术语冲突**：标记冲突并提供解决方案选项
- **翻译服务不可用**：降级为本地翻译并发出警告

## 依赖

### 工具（通过 Bash）
- `grep` — 搜索现有翻译
- `diff` — 与现有文件对比

### Claude Code 原生
- `Read` — 读取源文件和现有翻译
- `Write` — 写入翻译文件
- `Glob` — 搜索现有翻译

### Shared References
- 无

## 约束

- **保留要求**：
  - 禁止翻译 commands、flags、paths、API 名称、field 名称或 enum 值
  - 禁止修改 Markdown 结构或代码块
  - 禁止改变内容的含义或技术准确性
  - 禁止破坏现有功能或引用

- **一致性要求**：
  - 与目标语言中的现有翻译保持一致
  - 用新翻译更新术语数据库
  - 标记与现有术语的任何冲突

- **安全要求**：
  - 覆盖现有文件前始终创建备份
  - 禁止修改 i18n 目录结构之外的文件
  - 禁止翻译非 skill 文档或 shared references 的文件

- **性能要求**：
  - 对于大文件（>50KB），分块翻译以避免超出 context window 限制
  - 在多次翻译之间缓存术语数据库
  - 对于大型翻译任务，提供进度更新

## 使用示例

```bash
# 将 ingest skill 翻译为越南语
/translated-engine i18n/en/skills/ingest/SKILL.md vi

# 预览将 exp-design skill 翻译为中文，不写入文件
/translated-engine i18n/en/skills/exp-design/SKILL.md zh --dry-run

# 强制覆盖 review skill 现有的越南语翻译
/translated-engine i18n/en/skills/review/SKILL.md vi --force
```

## 翻译报告示例

```
翻译报告：i18n/en/skills/ingest/SKILL.md → i18n/vi/skills/ingest/SKILL.md

保留术语（24 个）：
- Commands：/ingest, /discover
- Flags：--discover, --full, --env
- Paths：wiki/papers/, raw/discovered/, experiments/code/
- APIs：DEEPXIV_TOKEN, SEMANTIC_SCHOLAR_API_KEY
- Fields：target_claim, evidence, confidence, slug
- 边类型：supports, contradicts, tested_by
- Wikilinks：[[slug]], [[flash-attention]]

Markdown 校验：
- 标题：OK (5/5)
- 列表：OK (12/12)
- 表格：OK (2/2)
- 代码块：OK (4/4)

一致性警告（1 个）：
- 术语 "confidence" 在 i18n/vi/skills/exp-eval/SKILL.md 中已译为 "độ tin cậy"
  → 使用已有译法

翻译摘要：
- 已翻译词数：1,248
- 保留技术术语：24
- 保留 Markdown 元素：38
- 翻译耗时：42s
```
