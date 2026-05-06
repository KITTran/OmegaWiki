# /init Prepare And Discovery

Dùng reference này khi `/init` chuẩn bị local inputs, chọn final paper set, hoặc ghi `.checkpoints/init-sources.json`.

## Prepare Flow

- Chạy `"$PYTHON_BIN" tools/init_discovery.py prepare --raw-root raw --pdf-titles-json .checkpoints/init-pdf-titles.json --output-manifest .checkpoints/init-prepare.json`.
- Trước khi prepare local PDFs, khôi phục confident titles khi có thể và ghi `.checkpoints/init-pdf-titles.json` dưới dạng `{ "raw/papers/foo.pdf": "Recovered Paper Title" }` hoặc `{ "raw/papers/foo.pdf": { "title": "Recovered Paper Title", "arxiv_id": "2401.00001" } }` khi đã biết confident arXiv ID.
- `tools/init_discovery.py prepare` phải truyền các recovered titles và IDs đó vào `"$PYTHON_BIN" tools/prepare_paper_source.py --raw-root raw --source <local-path> [--title "<recovered-title>"] [--arxiv-id "<recovered-arxiv-id>"]`.
- `tools/init_discovery.py prepare` phải delegate local paper normalization cho cùng helper đó và reuse các artifacts `raw/tmp/` đã pre-staged khi chúng đã tồn tại.
- Với local PDFs, chỉ dùng recovery order này: handed-off arXiv ID hoặc filename/path arXiv ID -> title-based Semantic Scholar recovery khi confident title được cung cấp -> fetched arXiv source -> synthetic `.tex`.
- Khi agent cung cấp confident PDF title, title đó có thẩm quyền cho prepared manifest. Sanitized titles từ fetched TeX chỉ là fallback metadata và không được overwrite agent title.
- Không dùng PDF metadata hoặc PDF body text làm arXiv-ID hints trong prepare.
- Khi arXiv ID recovery thành công, ưu tiên fetched raw TeX source dưới `raw/tmp/papers/...-arxiv-src/` hơn synthetic `.tex`.
- Nếu không có confident PDF title, bỏ qua `--title`; nếu không có confident arXiv ID, bỏ qua `--arxiv-id`; sau đó chỉ cho phép filename/path arXiv-ID recovery và fallback trực tiếp về synthetic `.tex`. Metadata hoặc filename titles chỉ giữ vai trò display-only.

## Source Preference Rules

- Ưu tiên local sources theo thứ tự: original local `.tex` > archive-extracted source `.tex` hoặc fetched arXiv source directory > PDF-derived synthetic `.tex` > raw `.pdf`.
- Giữ notes/web ở original source paths của chúng. `/init` đọc chúng trực tiếp trong planning.
- Nếu handed-off source đã nằm dưới `raw/tmp/` hoặc `raw/discovered/`, coi path đó là canonical và không duplicate nó vào `raw/papers/`.
- Đặt `canonical_ingest_path` của mỗi local paper thành prepared `raw/tmp/` path khi có; nếu không thì fallback về original `raw/papers/...` path.

## Final Selection And Fetch

- `plan` phải đọc `.checkpoints/init-prepare.json` thay vì quét lại `raw/`.
- Over-pick shortlist trước, rồi cắt giảm rõ ràng về documented final target trước `fetch`.
- Mặc định giữ tất cả parseable user-owned papers, rồi dùng các slot còn lại cho introduced papers.
- Nếu seeded discovery không thêm external papers nào, tiếp tục với user-owned paper set thay vì coi đó là fatal planner error.
- Nếu user đã cung cấp hơn 10 parseable papers, không thêm papers mới.
- Nếu `--no-introduction` đang active, final paper set = tất cả parseable user papers, và `fetch` vẫn chạy với zero external IDs để ghi `.checkpoints/init-sources.json`.

Chạy:

```bash
"$PYTHON_BIN" tools/init_discovery.py fetch --raw-root raw --plan-json .checkpoints/init-plan.json --prepared-manifest .checkpoints/init-prepare.json --output-sources .checkpoints/init-sources.json --id <candidate-id> --id <candidate-id>
```

- External papers được `/init` download đi vào `raw/discovered/`, không bao giờ vào `raw/papers/`.
- Không bao giờ fetch một paper đã được đại diện bởi prepared local source từ `raw/tmp/`.

## Source Manifest Contract

- `.checkpoints/init-sources.json` là single source of truth cho Step 5 ingest order.
- User-owned papers xuất hiện trong `init-sources.json` với `origin=user_local` và canonical prepared path của chúng khi có.
- Introduced papers xuất hiện trong `init-sources.json` với `origin=introduced` và canonical `raw/discovered/` path của chúng.
- Step 5 phải consume handed-off `canonical_ingest_path` đúng như đã ghi.
