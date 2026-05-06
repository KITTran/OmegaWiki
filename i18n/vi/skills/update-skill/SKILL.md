---
description: Quy trình chuẩn để thêm mới hoặc sửa đổi một skill — tạo fix branch, sửa source i18n, dịch, sync active files, merge về main và research branch.
argument-hint: "<skill-name> [--new]"
---

# /update-skill

> Quy trình chuẩn khi cần thêm mới hoặc sửa đổi một skill. Mọi thay đổi đều đi qua `i18n/<lang>/skills/` — không chỉnh sửa trực tiếp `.claude/skills/`.

## Inputs

- `skill-name`: tên skill cần tạo mới hoặc sửa đổi (ví dụ: `init`, `ingest`, `update-skill`)
- `--new` (tùy chọn): khi tạo skill hoàn toàn mới thay vì sửa skill đã có

## Outputs

- File skill đã cập nhật trong `i18n/<lang>/skills/<skill-name>/SKILL.md` (và `references/` nếu có)
- Bản dịch tương ứng trong các `i18n/<other-lang>/skills/<skill-name>/`
- Active files được sync vào `.claude/skills/<skill-name>/`
- Commits trên `fix/<skill-name>` branch, sẵn sàng merge

## Quy Tắc Nguồn

- **Source of truth**: `i18n/<lang>/skills/` — đây là nơi duy nhất được phép chỉnh sửa thủ công
- **Active files**: `.claude/skills/` — chỉ được cập nhật qua `./setup.sh --lang <lang>`, không chỉnh sửa trực tiếp
- **Ngôn ngữ hiện tại**: xác định bằng `cat .claude/.current-lang` hoặc xem `CLAUDE.md` đang dùng ngôn ngữ nào

## Workflow

### Bước 1: Tạo fix branch từ `origin/main`

```bash
git fetch origin
git checkout -b fix/<skill-name> origin/main
```

- Luôn tạo từ `origin/main`, không tạo từ branch research hoặc branch local `main` (có thể đã chứa wiki database)
- Đặt tên theo pattern `fix/<skill-name>` hoặc `fix/<skill-name>-<mô-tả-ngắn>`

### Bước 2: Sửa skill trong source ngôn ngữ hiện tại

Xác định ngôn ngữ đang dùng:

```bash
cat .claude/.current-lang   # vi | en | zh
```

Chỉnh sửa file trong `i18n/<lang>/skills/<skill-name>/SKILL.md` (và các file `references/` nếu skill có). Nếu tạo skill mới (`--new`), tạo thư mục trước:

```bash
mkdir -p i18n/<lang>/skills/<skill-name>
```

Format bắt buộc — frontmatter:

```markdown
---
description: <mô tả ngắn một dòng>
argument-hint: "<tham số>"
---
```

Sau đó commit:

```bash
git add i18n/<lang>/skills/<skill-name>/
git commit -m "fix(<skill-name>): <mô tả thay đổi> [<lang>]"
```

### Bước 3: Dịch sang các ngôn ngữ còn lại

Với mỗi ngôn ngữ khác (`en`, `vi`, `zh`):

- Sao chép nội dung kỹ thuật (commands, code blocks, field names) giữ nguyên
- Dịch phần prose, mô tả, ràng buộc sang ngôn ngữ đích
- Lưu ý: một số file trong `i18n/` được viết bằng tiếng Anh dù nằm trong thư mục `vi/` hoặc `zh/` — giữ nguyên ngôn ngữ đã có nếu file gốc là tiếng Anh

```bash
mkdir -p i18n/en/skills/<skill-name>
# ... chỉnh sửa i18n/en/skills/<skill-name>/SKILL.md
mkdir -p i18n/zh/skills/<skill-name>
# ... chỉnh sửa i18n/zh/skills/<skill-name>/SKILL.md

git add i18n/en/skills/<skill-name>/ i18n/zh/skills/<skill-name>/
git commit -m "fix(<skill-name>): translate to en and zh"
```

### Bước 4: Sync active files bằng setup.sh

```bash
./setup.sh --lang <lang-hiện-tại>
```

Lệnh này copy nội dung từ `i18n/<lang>/` vào `.claude/` (bao gồm `.claude/skills/`, `.claude/CLAUDE.md`, `.claude/docs/`).

Sau đó commit toàn bộ thay đổi trong `.claude/skills/`:

```bash
git add .claude/skills/
git commit -m "chore: sync active skill files after setup --lang <lang>"
```

- Nếu chỉ sửa một skill, chỉ commit file của skill đó trước, rồi commit phần còn lại:
  ```bash
  git add .claude/skills/<skill-name>/
  git commit -m "chore: sync <skill-name> after setup --lang <lang>"
  git add .claude/skills/
  git commit -m "chore: sync remaining skill files after setup --lang <lang>"
  ```

### Bước 5: Merge về `main`

```bash
git switch main
git merge --no-ff fix/<skill-name>
git branch -d fix/<skill-name>
```

- Dùng `--no-ff` để giữ lịch sử fix branch rõ ràng
- Xóa fix branch sau khi merge thành công

### Bước 6: Merge về research branch (nếu đang dùng)

```bash
git switch research/<topic>
git merge main
```

Hoặc cherry-pick nếu không muốn kéo toàn bộ `main` vào research branch:

```bash
git cherry-pick fix/<skill-name>  # merge commit của fix branch
```

## Cập Nhật `CLAUDE.md` (khi thêm skill mới)

Nếu tạo skill hoàn toàn mới (`--new`), phải thêm entry vào bảng Skills trong `i18n/<lang>/CLAUDE.md` và các bản dịch tương ứng:

```markdown
| `/update-skill` | `skills/update-skill/SKILL.md` | thủ công |
```

Sau đó chạy lại `./setup.sh --lang <lang>` để sync `CLAUDE.md` active.

## Constraints

- **Không chỉnh sửa `.claude/skills/` trực tiếp** — chỉ `./setup.sh` mới được ghi vào đó
- **Luôn tạo branch từ `origin/main`** — không từ branch research (có thể chứa wiki database không liên quan đến skill)
- **Commit i18n trước, commit active files sau** — giữ hai loại commit tách biệt để dễ cherry-pick
- **Kiểm tra `.claude/.current-lang`** trước khi chạy `setup.sh` — sync sai ngôn ngữ sẽ overwrite active files bằng bản dịch không đúng
- **Không dùng `git rebase -i`** trong interactive mode — Claude Code không hỗ trợ; dùng `git reset --soft` + commit lại nếu cần tách/gộp commit

## Error Handling

- **`git switch` bị block vì uncommitted changes**: stash các file không liên quan trước khi switch
  ```bash
  git stash push -m "wip: <mô tả>" -- <danh-sách-file>
  git switch fix/<skill-name>
  ```
- **Quên chạy `setup.sh` trước khi commit active files**: chạy lại `setup.sh` rồi `git add .claude/skills/`
- **Cần tách commit đã gộp**: `git reset --soft HEAD~1` để đưa files về staged, rồi `git restore --staged <file>` để tách ra

## Ví Dụ Thực Tế

Sửa `/init` để thêm two-turn commit rule:

```
git checkout -b fix/init-worktree-flow origin/main
# Sửa i18n/vi/skills/init/SKILL.md và references/parallel-ingest.md
git add i18n/vi/skills/init/
git commit -m "fix(init): add two-turn scaffold commit rule [vi]"
# Dịch sang en và zh
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
