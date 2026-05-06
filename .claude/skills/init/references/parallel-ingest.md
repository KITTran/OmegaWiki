# /init Parallel Ingest

Dùng reference này khi `/init` chuyển giao source cho các `/ingest` subagent song song và merge công việc của chúng trở lại.

## An Toàn Trước Fan-Out

- Chạy `git status --short`.
- Coi các file dưới `wiki/`, `raw/papers/`, `raw/tmp/`, `raw/discovered/`, và `.checkpoints/init-*.json` là scaffold files.
- Stash các file bẩn không liên quan nằm ngoài những path đó.
- Xác minh `.gitattributes` chứa `merge=union` cho `wiki/log.md`, `wiki/graph/edges.jsonl`, `wiki/graph/citations.jsonl`, và `wiki/index.md`.
- Commit scaffold trước fan-out để `BASE_COMMIT` chứa các trang đã tạo, source `raw/tmp/` / `raw/discovered/`, và manifests mà mọi worktree phải kế thừa. Vì các Agent worktree cô lập có thể capture `HEAD` tại thời điểm bắt đầu tool-call, scaffold commit phải xảy ra trong **turn assistant riêng của nó**. Không launch Agent fan-out trong cùng response tạo scaffold commit.

```bash
git add wiki/ raw/tmp/ raw/discovered/ .checkpoints/init-pdf-titles.json .checkpoints/init-prepare.json .checkpoints/init-plan.json .checkpoints/init-sources.json
git commit -m "init: scaffold before parallel ingest"
BASE_COMMIT=$(git rev-parse HEAD)
git ls-tree -r "$BASE_COMMIT" raw/tmp/ raw/discovered/ .checkpoints/init-sources.json | head
```

- Nếu xác minh `git ls-tree` không hiển thị các canonical source paths từ `.checkpoints/init-sources.json`, dừng lại và sửa staging trước fan-out.
- Sau khi scaffold commit được xác minh, kết thúc turn assistant. Chỉ launch Agent fan-out ở turn user/assistant tiếp theo, dùng `BASE_COMMIT=$(git rev-parse HEAD)` từ scaffold đã commit sẵn.
- Ghi `stash_ref`, `base_branch`, và `base_commit` bằng `tools/research_wiki.py checkpoint-set-meta`.
- Chế độ worktree của `/init` yêu cầu một branch có tên; dừng lại nếu đang ở detached HEAD.

## Tạo Worktree

Với mỗi paper, tạo worktree từ scaffold commit trên branch hiện tại:

```bash
WT_BRANCH="init-${BASE_BRANCH//\//-}-<rank>-<paper-slug>"
WT_PATH="../.worktrees/$WT_BRANCH"
git worktree add -b "$WT_BRANCH" "$WT_PATH" "$BASE_COMMIT"
```

- Không chạy `git worktree add` trực tiếp với tên current branch; Git sẽ từ chối vì branch đó đã được checkout trong workspace chính.
- Sắp xếp papers theo `shortlist_rank` từ `.checkpoints/init-sources.json`, không quét lại raw folders và không dùng raw citation count.

## Subagent Prompt Contract

- Shell working directory của subagent phải là worktree path (`$WT_PATH`), không phải repository root chính. Mọi relative paths resolve từ đó.
- Thực thi `/ingest` cho đúng một relative source path.
- Không bypass `/ingest`.
- Trong INIT MODE, dùng đúng canonical path được chuyển giao, nguyên văn như đã cung cấp.
- Skip `fetch_s2.py citations`.
- Skip `fetch_s2.py references`.
- Skip per-subagent `rebuild-index`.
- Skip per-subagent `rebuild-context-brief`.
- Skip per-subagent `rebuild-open-questions`.
- Skip các topic writes dễ gây conflict.
- Commit kết quả bên trong worktree trước khi thoát để fan-in merge một ingest commit thật.

## Fan-In

Sau khi tất cả agents hoàn thành:

1. Switch workspace chính về `BASE_BRANCH` nếu cần, rồi merge các worktree branches tuần tự ở đó theo thứ tự planner.
2. Resolve các concept/claim conflicts thật một cách thận trọng: merge, không nhân bản các near-duplicates.
3. Chỉ merge các worktree branches đã commit. Branch không có ingest commit là lỗi cần dừng và sửa, không phải thứ để merge tiếp.
3. Chạy:

```bash
git switch "$BASE_BRANCH"
git merge --no-ff "$WT_BRANCH" --no-edit
git worktree remove "$WT_PATH"
git branch -d "$WT_BRANCH"
"$PYTHON_BIN" tools/research_wiki.py dedup-edges wiki/
"$PYTHON_BIN" tools/research_wiki.py dedup-citations wiki/
"$PYTHON_BIN" tools/research_wiki.py rebuild-index wiki/
"$PYTHON_BIN" tools/research_wiki.py rebuild-context-brief wiki/
"$PYTHON_BIN" tools/research_wiki.py rebuild-open-questions wiki/
"$PYTHON_BIN" tools/lint.py --wiki-dir wiki/ --fix
```

Nếu `stash_ref` tồn tại, pop nó ở cuối. Nếu stash pop thất bại, giữ checkpoint và báo cáo lỗi.
