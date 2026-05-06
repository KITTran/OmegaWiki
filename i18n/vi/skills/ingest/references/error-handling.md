# /ingest Error Handling

Mở reference này khi một bước thất bại. `/ingest` ưu tiên degrade gracefully: ghi lại chuyện đã xảy ra, tiếp tục với phần còn lại, và nêu gap trong final report.

## Source parsing

- **`.tex` parse fails**: fall back sang PDF nếu có PDF trong cùng source directory.
- **PDF text extraction fails**: fall back sang một vision-API pass trên vài trang đầu để khôi phục title và abstract, rồi chạy preprocessing pipeline trong `references/pdf-preprocessing.md` với recovered title.
- **No readable source at all**: dừng và báo cáo. Không tạo paper page chỉ từ một title — paper page không có grounded content là noise.
- **INIT MODE input unreadable**: không thử re-prepare source (INIT MODE là read-only trên `raw/`). Dừng, ghi failure, và để parent `/init` retry hoặc skip paper tại fan-in.

## External APIs

- **Semantic Scholar unavailable** (`fetch_s2.py paper` lỗi): skip S2 enrichment, đặt mặc định `importance` là 3, và ghi chú trong report rằng importance của paper là provisional. Skip toàn bộ citation backfill step cho ingest này.
- **DeepXiv unavailable** (`fetch_deepxiv.py` lỗi): skip enrichment âm thầm. DeepXiv là optional; thiếu nó không phải degraded ingest, chỉ là ingest ít enrichment hơn. Không nêu điều này trong user report trừ khi user hỏi riêng về DeepXiv.
- **arXiv source fetch fails**: nếu paper nằm trên arXiv nhưng source archive không tồn tại hoặc timeout, chuyển tiếp sang PDF path. Ghi warning trong final report.

## Slug collisions

- **Generated slug khớp một page hiện có với arXiv ID hoặc title khác**: dừng và báo cáo. Không âm thầm thêm numeric suffix — collision giữa hai papers khác nhau ở cùng slug là tín hiệu wiki có naming problem cần user xử lý.
- **Generated slug khớp một page hiện có với cùng paper**: paper đã được ingest. Báo cáo và thoát.
- **Trong một ingest duy nhất, generated concept hoặc claim slug collide với một existing page khác**: thêm numeric suffix (`-2`, `-3`, ...) qua built-in collision handling của tool. Đây là trường hợp duy nhất suffixing là đúng — nó xảy ra khi hai ideas thật sự khác nhau tạo cùng slug theo deterministic rule.

## Wiki not initialized

Nếu `wiki/` thiếu hoặc trống, chạy:

```bash
"$PYTHON_BIN" tools/research_wiki.py init wiki/
```

Sau đó retry `/ingest`. Không cố tạo pages trong wiki chưa initialized; `index.md` và `graph/` scaffolding phải tồn tại trước.

## Partial failure mid-ingest

Nếu ingest thất bại sau khi một số writes đã landed (paper page đã ghi, nhưng concept dedup hoặc graph edge thất bại):

- không roll back các writes đã thành công
- append một log entry qua `tools/research_wiki.py log` mô tả bước nào đã hoàn thành và bước nào incomplete
- nêu incomplete steps trong user report để user có thể chạy `/edit` hoặc `/check --fix` hoàn tất công việc
- trong INIT MODE, nếu ingest hoàn thành thành công, commit bên trong worktree trước khi thoát (xem `references/init-mode.md`). Nếu ingest partial failed, **không** commit incomplete state; để parent `/init` xử lý failed worktree tại fan-in

## Khi nào dừng vs. tiếp tục

Dừng hẳn khi:

- không đọc được source nào
- paper đã được ingest (slug + arXiv ID khớp existing page)
- slug collision sẽ âm thầm overwrite một existing paper khác

Tiếp tục với warning khi:

- một enrichment source (S2 hoặc DeepXiv) bị down
- reference list không parse được (skip step 5; paper ingest vẫn hoạt động)
- một concept hoặc claim dedup call đơn lẻ thất bại tạm thời (retry một lần; nếu vẫn fail, skip candidate đó và ghi chú)

Nguyên tắc dẫn đường: một partial ingest giữ lại well-shaped paper page hữu ích hơn một clean abort khiến wiki không đổi. Partial state có thể recover qua `/check` và `/edit`. Partial state bị mất thì không.
