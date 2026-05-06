---
description: 新增或修改 skill 的标准流程 — 创建 fix branch、编辑 i18n 源文件、翻译、同步 active files、合并到 main 和 research branch。
argument-hint: "<skill-name> [--new]"
---

# /update-skill

> 新增或修改 skill 时的标准流程。所有变更均通过 `i18n/<lang>/skills/` 进行 — 禁止直接编辑 `.claude/skills/`。

## Inputs

- `skill-name`：要新增或修改的 skill 名称（例如 `init`、`ingest`、`update-skill`）
- `--new`（可选）：创建全新 skill 而非修改已有 skill 时使用

## Outputs

- 已更新的 skill 文件 `i18n/<lang>/skills/<skill-name>/SKILL.md`（如有 `references/` 也一并更新）
- 其他语言对应的翻译版本 `i18n/<other-lang>/skills/<skill-name>/`
- 同步到 `.claude/skills/<skill-name>/` 的 active files
- `fix/<skill-name>` branch 上的 commits，可随时合并

## 源文件规则

- **唯一真相源**：`i18n/<lang>/skills/` — 这是唯一允许手动编辑的位置
- **Active files**：`.claude/skills/` — 仅通过 `./setup.sh --lang <lang>` 更新，禁止直接编辑
- **当前语言**：通过 `cat .claude/.current-lang` 确认，或查看当前激活的 `CLAUDE.md`

## Workflow

### 第 1 步：从 `main` 创建 fix branch

```bash
git checkout -b fix/<skill-name> main
```

- 始终从 `main` 创建 — 该 branch 只含 skills/config，不含 wiki 数据库
- 不要从 `origin/main` 创建：用户可能尚未 push 最新代码
- 不要从 research branch 创建（research branch 含有与 skill 无关的 wiki 数据库）
- 命名规范：`fix/<skill-name>` 或 `fix/<skill-name>-<简短描述>`

### 第 2 步：在当前语言的源目录中编辑 skill

确认当前语言：

```bash
cat .claude/.current-lang   # vi | en | zh
```

编辑 `i18n/<lang>/skills/<skill-name>/SKILL.md`（以及 skill 用到的 `references/` 文件）。若创建新 skill（`--new`），先建目录：

```bash
mkdir -p i18n/<lang>/skills/<skill-name>
```

必需的 frontmatter 格式：

```markdown
---
description: <一行描述>
argument-hint: "<参数>"
---
```

然后提交：

```bash
git add i18n/<lang>/skills/<skill-name>/
git commit -m "fix(<skill-name>): <变更描述> [<lang>]"
```

### 第 3 步：翻译到其余语言

对每种其他语言（`en`、`vi`、`zh`）：

- 保留所有技术内容原文不变（命令、代码块、字段名）
- 将 prose、描述、约束翻译为目标语言
- 注意：`i18n/` 下某些文件即使位于 `vi/` 或 `zh/` 目录，仍以英文书写 — 若原文为英文，则保持英文不变

```bash
mkdir -p i18n/en/skills/<skill-name>
# ... 编辑 i18n/en/skills/<skill-name>/SKILL.md
mkdir -p i18n/zh/skills/<skill-name>
# ... 编辑 i18n/zh/skills/<skill-name>/SKILL.md

git add i18n/en/skills/<skill-name>/ i18n/zh/skills/<skill-name>/
git commit -m "fix(<skill-name>): translate to en and zh"
```

### 第 4 步：通过 setup.sh 同步 active files

```bash
./setup.sh --lang <当前语言>
```

该命令将 `i18n/<lang>/` 的内容复制到 `.claude/`（包括 `.claude/skills/`、`.claude/CLAUDE.md`、`.claude/docs/`）。

然后提交 `.claude/skills/` 下的所有变更：

```bash
git add .claude/skills/
git commit -m "chore: sync active skill files after setup --lang <lang>"
```

若只修改了一个 skill，先单独提交该 skill，再提交其余：

```bash
git add .claude/skills/<skill-name>/
git commit -m "chore: sync <skill-name> after setup --lang <lang>"
git add .claude/skills/
git commit -m "chore: sync remaining skill files after setup --lang <lang>"
```

### 第 5 步：合并到 `main`

```bash
git switch main
git merge --no-ff fix/<skill-name>
git branch -d fix/<skill-name>
```

- 使用 `--no-ff` 以保留 fix branch 的历史记录
- 合并成功后删除 fix branch

### 第 6 步：合并到 research branch（如有）

```bash
git switch research/<topic>
git merge main
```

若不想将整个 `main` 合并到 research branch，可使用 cherry-pick：

```bash
git cherry-pick fix/<skill-name>  # fix branch 的 merge commit
```

## 更新 `CLAUDE.md`（仅新增 skill 时）

创建全新 skill（`--new`）时，必须在 `i18n/<lang>/CLAUDE.md` 及所有语言版本的 Skills 表中添加条目：

```markdown
| `/update-skill` | `skills/update-skill/SKILL.md` | 手动 |
```

然后再次运行 `./setup.sh --lang <lang>` 以同步 active `CLAUDE.md`。

## Constraints

- **禁止直接编辑 `.claude/skills/`** — 只有 `./setup.sh` 才能写入该目录
- **始终从 `main` 创建 branch** — 不从 research branch（含 wiki 数据库）创建，不从 `origin/main`（用户可能未 push）创建
- **先 commit i18n 变更，再 commit active files** — 保持两类 commit 分离，便于 cherry-pick
- **运行 `setup.sh` 前检查 `.claude/.current-lang`** — 同步错误语言会用错误翻译覆盖 active files
- **不要使用 `git rebase -i`** 的交互模式 — Claude Code 不支持；需要拆分/合并 commit 时使用 `git reset --soft` 后重新提交

## Error Handling

- **`git switch` 因未提交变更被阻塞**：先 stash 无关文件再切换
  ```bash
  git stash push -m "wip: <描述>" -- <文件列表>
  git switch fix/<skill-name>
  ```
- **忘记先运行 `setup.sh` 就提交了 active files**：重新运行 `setup.sh`，然后 `git add .claude/skills/`
- **需要拆分已合并的 commit**：`git reset --soft HEAD~1` 将文件退回 staged 状态，再用 `git restore --staged <file>` 选择性取消暂存

## 实际示例

为 `/init` 添加两轮提交规则：

```
git checkout -b fix/init-worktree-flow main
# 编辑 i18n/vi/skills/init/SKILL.md 和 references/parallel-ingest.md
git add i18n/vi/skills/init/
git commit -m "fix(init): add two-turn scaffold commit rule [vi]"
# 翻译到 en 和 zh
git add i18n/en/skills/init/ i18n/zh/skills/init/
git commit -m "fix(init): translate two-turn commit rule to en and zh"
./setup.sh --lang vi
git add .claude/skills/init/
git commit -m "chore: sync init skill after setup --lang vi"
git add .claude/skills/
git commit -m "chore: sync remaining skills after setup --lang vi"
git switch main && git merge --no-ff fix/init-worktree-flow
git switch research/pinn-ndt && git merge main
```
