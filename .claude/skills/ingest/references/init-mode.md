# /ingest INIT MODE and Parallel Safety

Mở reference này khi `/ingest` được `/init` invoke như một parallel subagent, hoặc bất kỳ lúc nào bạn cần hiểu các concurrent ingests có thể đang làm gì với shared files.

## Khi INIT MODE active

INIT MODE active cho mọi `/ingest` invocation có source path xuất phát từ `.checkpoints/init-sources.json`. Parent `/init` chạy một `/ingest` cho mỗi paper trong một `git worktree` cô lập, theo contract trong `skills/init/references/parallel-ingest.md`.

Trong INIT MODE:

- source luôn là `canonical_ingest_path` đã được `/init` prepare (một `raw/tmp/...` path cho user-owned papers, hoặc một `raw/discovered/...` path cho introduced papers)
- `raw/` strictly read-only — không ghi vào `raw/tmp/`, `raw/discovered/`, hoặc bất kỳ đâu dưới `raw/`
- `fetch_s2.py citations <arxiv-id>` và `fetch_s2.py references <arxiv-id>` được **skip** — parent `/init` làm unified citation sweep tại fan-in
- `rebuild-context-brief` và `rebuild-open-questions` được **skip** — parent chạy chúng một lần sau khi tất cả subagents merge
- conflict-prone topic writes được **skip** — nếu nhiều parallel ingests đều append vào cùng topic, chúng sẽ merge-conflict. Để parent xử lý topic updates sau fan-in, hoặc defer chúng cho `/edit`.
- **skip reverse-link edits to existing pages** — không append `key_papers` vào existing concept page, không append vào `## Key papers` hoặc `## Related` của existing paper page, và không append vào existing people page. Thay vào đó, ghi relationship qua `tools/research_wiki.py add-edge`. Parent `/init` rebuild backlinks này trong fan-in.

Mọi thứ khác — paper page creation, concept/claim dedup qua `find-similar-*`, people page creation, paper `## Related` links, graph edges cho concept/claim/foundation — vẫn chạy trong từng subagent.

## Detect INIT MODE

`/init` truyền canonical path trong subagent prompt. Một `/ingest` invocation có thể nhận biết INIT MODE bằng một trong hai tín hiệu:

- source path bắt đầu bằng `raw/tmp/` hoặc `raw/discovered/` **và** manifest `.checkpoints/init-sources.json` reference tới nó
- subagent prompt explicit ghi "INIT MODE"

Khi cả hai tín hiệu đều vắng mặt, coi invocation là direct user call và chạy full workflow (bao gồm citations, rebuilds, và mọi `raw/tmp/` preparation cần thiết).

## Parallel-safe writes

Ngay cả ngoài INIT MODE, giả định một `/ingest` khác có thể đang chạy concurrent — batch ingest đã nằm trên roadmap. Ba rules giúp concurrent writes an toàn:

1. **Mọi shared-file write đi qua tool.** `graph/edges.jsonl`, `graph/citations.jsonl`, `index.md`, và `log.md` được ghi qua `tools/research_wiki.py add-edge`, `add-citation`, index updates, và `log`. Tool layer dùng append semantics và `.gitattributes` của repository khai báo `merge=union` cho các paths này, nên parallel worktrees có thể merge không conflict.
2. **Slugs được allocate deterministically.** `tools/research_wiki.py slug "<title>"` tạo cùng slug từ cùng title bất kể worktree nào chạy nó. Collisions được resolve bằng numeric suffix qua tool, không phải ad-hoc renaming.
3. **Không bao giờ lock hoặc in-place-rewrite shared file.** Rewriting `wiki/index.md`, `wiki/graph/edges.jsonl`, hoặc `wiki/graph/citations.jsonl` thành một block sẽ replace work của parallel peers khi worktrees merge. Dùng tool commands, vốn append.

## Tạo page mới song song

Khi hai sibling `/ingest` subagents đều cần concept page mới với cùng slug, cả hai sẽ cố tạo nó và fan-in merge sẽ fail. Mitigations:

- per-paper creation limit (`references/dedup-policy.md`) giữ collision surface nhỏ
- parent `/init` merge worktree branches tuần tự; khi ingest của worktree thứ hai ghi cùng slug, sequential merge resolve nó như conflict mà parent xử lý bằng cách chọn write sớm hơn và re-run `find-similar-concept` trên write muộn hơn tại fan-in
- không cố coordinate giữa worktrees trong ingest — worktrees cô lập theo thiết kế

Nếu bạn nhận thấy slug collision trong direct (non-INIT) ingest — tức paper page đã tồn tại với arXiv ID khác — dừng và báo cáo, theo `references/error-handling.md`. Không write-through.

## `/ingest` không làm gì cho `/init`

- Nó không stash hoặc switch branches.
- Nó không merge worktrees hoặc chạy `dedup-edges`, `rebuild-index`, hoặc `lint.py --fix`. Đó là fan-in operations thuộc sở hữu của `/init`.

Trong INIT MODE, `/ingest` **phải** commit work của nó bên trong worktree trước khi thoát, nhưng chỉ khi ingest hoàn thành thành công:
- stage mọi file bạn tạo hoặc sửa dưới `wiki/`
- trước khi commit, chạy `git branch --show-current` và xác minh branch name là worktree branch (chứa `init-`), không phải base branch. Nếu bạn đang ở base branch, dừng và báo cáo thay vì commit
- chạy `git commit -m "ingest: <paper-title>"` (hoặc message mô tả tương tự)
- không push; parent `/init` sẽ merge branch trong fan-in

Nếu ingest fail giữa chừng (partial failure), **không** commit incomplete state. Để parent `/init` xử lý failed worktree tại fan-in.
