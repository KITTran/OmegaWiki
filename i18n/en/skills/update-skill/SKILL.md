---
description: Standard workflow for adding or modifying a skill — create fix branch, edit i18n source, translate, sync active files, merge to main and research branch.
argument-hint: "<skill-name> [--new]"
---

# /update-skill

> Standard process for adding or modifying a skill. All changes go through `i18n/<lang>/skills/` — never edit `.claude/skills/` directly.

## Inputs

- `skill-name`: name of the skill to create or modify (e.g. `init`, `ingest`, `update-skill`)
- `--new` (optional): when creating a brand-new skill rather than editing an existing one

## Outputs

- Updated skill file at `i18n/<lang>/skills/<skill-name>/SKILL.md` (and `references/` if the skill has them)
- Corresponding translations under `i18n/<other-lang>/skills/<skill-name>/`
- Active files synced into `.claude/skills/<skill-name>/`
- Commits on `fix/<skill-name>` branch, ready to merge

## Source Rules

- **Source of truth**: `i18n/<lang>/skills/` — the only place manual edits are allowed
- **Active files**: `.claude/skills/` — updated only via `./setup.sh --lang <lang>`, never edited directly
- **Current language**: check with `cat .claude/.current-lang` or look at which `CLAUDE.md` is active

## Workflow

### Step 1: Create a fix branch from `main`

```bash
git checkout -b fix/<skill-name> main
```

- Always branch from `main` — it contains only skills/config, not the wiki database
- Do not branch from `origin/main`: the user may not have pushed yet
- Do not branch from a research branch (contains wiki database unrelated to the skill)
- Name the branch `fix/<skill-name>` or `fix/<skill-name>-<short-description>`

### Step 2: Edit the skill in the current language source

Identify the active language:

```bash
cat .claude/.current-lang   # vi | en | zh
```

Edit `i18n/<lang>/skills/<skill-name>/SKILL.md` (and any `references/` files the skill uses). For a new skill (`--new`), create the directory first:

```bash
mkdir -p i18n/<lang>/skills/<skill-name>
```

Required frontmatter format:

```markdown
---
description: <one-line description>
argument-hint: "<parameters>"
---
```

Then commit:

```bash
git add i18n/<lang>/skills/<skill-name>/
git commit -m "fix(<skill-name>): <description of change> [<lang>]"
```

### Step 3: Translate to the remaining languages

For each of the other languages (`en`, `vi`, `zh`):

- Keep all technical content verbatim (commands, code blocks, field names)
- Translate prose, descriptions, and constraints into the target language
- Note: some files under `i18n/` are written in English even though they sit in a `vi/` or `zh/` folder — preserve the existing language if the original file is in English

```bash
mkdir -p i18n/en/skills/<skill-name>
# ... edit i18n/en/skills/<skill-name>/SKILL.md
mkdir -p i18n/zh/skills/<skill-name>
# ... edit i18n/zh/skills/<skill-name>/SKILL.md

git add i18n/en/skills/<skill-name>/ i18n/zh/skills/<skill-name>/
git commit -m "fix(<skill-name>): translate to en and zh"
```

### Step 4: Sync active files with setup.sh

```bash
./setup.sh --lang <current-lang>
```

This copies content from `i18n/<lang>/` into `.claude/` (including `.claude/skills/`, `.claude/CLAUDE.md`, `.claude/docs/`).

Then commit all changes under `.claude/skills/`:

```bash
git add .claude/skills/
git commit -m "chore: sync active skill files after setup --lang <lang>"
```

When only one skill was modified, commit it first and then the rest separately:

```bash
git add .claude/skills/<skill-name>/
git commit -m "chore: sync <skill-name> after setup --lang <lang>"
git add .claude/skills/
git commit -m "chore: sync remaining skill files after setup --lang <lang>"
```

### Step 5: Merge to `main`

```bash
git switch main
git merge --no-ff fix/<skill-name>
git branch -d fix/<skill-name>
```

- Use `--no-ff` to keep the fix branch history visible
- Delete the fix branch after a successful merge

### Step 6: Merge to the research branch (if active)

```bash
git switch research/<topic>
git merge main
```

Or cherry-pick if you do not want to pull all of `main` into the research branch:

```bash
git cherry-pick fix/<skill-name>  # the merge commit of the fix branch
```

## Updating `CLAUDE.md` (new skills only)

For a brand-new skill (`--new`), add an entry to the Skills table in `i18n/<lang>/CLAUDE.md` and all other language versions:

```markdown
| `/update-skill` | `skills/update-skill/SKILL.md` | manual |
```

Then run `./setup.sh --lang <lang>` again to sync the active `CLAUDE.md`.

## Constraints

- **Never edit `.claude/skills/` directly** — only `./setup.sh` may write there
- **Always branch from `main`** — not from a research branch (wiki database) and not from `origin/main` (user may not have pushed)
- **Commit i18n changes before committing active files** — keeps the two types of commits separate and easy to cherry-pick
- **Check `.claude/.current-lang`** before running `setup.sh` — syncing the wrong language overwrites active files with the wrong translation
- **Do not use `git rebase -i`** in interactive mode — Claude Code does not support it; use `git reset --soft` and re-commit to split or squash commits

## Error Handling

- **`git switch` blocked by uncommitted changes**: stash unrelated files before switching
  ```bash
  git stash push -m "wip: <description>" -- <file-list>
  git switch fix/<skill-name>
  ```
- **Forgot to run `setup.sh` before committing active files**: run `setup.sh` again, then `git add .claude/skills/`
- **Need to split a squashed commit**: `git reset --soft HEAD~1` to bring files back to staged, then `git restore --staged <file>` to unstage selectively

## Real-World Example

Adding the two-turn commit rule to `/init`:

```
git checkout -b fix/init-worktree-flow main
# Edit i18n/vi/skills/init/SKILL.md and references/parallel-ingest.md
git add i18n/vi/skills/init/
git commit -m "fix(init): add two-turn scaffold commit rule [vi]"
# Translate to en and zh
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
