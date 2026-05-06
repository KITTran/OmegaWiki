# /ingest PDF Preprocessing

Mở reference này khi `/ingest` nhận một local `.pdf` và cần chuyển nó thành prepared `.tex` trước khi ingest có thể tiếp tục. Skip trong INIT MODE — `/init` đã chạy equivalent batch preprocessing pass và chuyển giao canonical path.

## Vì sao cần preprocessing

Một PDF tự thân là ingest source kém: chất lượng text extraction thay đổi, equations và captions dễ bị mất, và reference list thường không đáng tin cậy. Khi paper nằm trên arXiv, ta có thể làm tốt hơn nhiều bằng cách resolve nó thành arXiv ID và fetch original TeX source. Nếu không có arXiv source, ta vẫn normalize PDF thành synthetic `.tex` để phần còn lại của `/ingest` làm việc từ một input shape thống nhất.

Điều này phản chiếu pipeline `tools/init_discovery.py prepare` chạy nội bộ khi `/init` batch-process local PDFs. Bạn đang làm cùng việc đó cho một paper đơn lẻ, inline.

## Recovery order

Theo đúng thứ tự này. Dừng ở bước đầu tiên tạo ra confident result.

1. **Agent inspection of the PDF itself.**
   Trước khi invoke bất kỳ tool nào, mở PDF và ghi lại:
   - confident paper title (từ first-page title, không từ PDF metadata — metadata thường sai)
   - confident arXiv ID nếu nó được in rõ trên trang đầu hoặc header
   Một trong hai hoặc cả hai có thể rỗng. Không đoán.
2. **Filename / path arXiv ID extraction.**
   `prepare_paper_source.py` đã regex-match arXiv ID nhúng trong filename hoặc folder chứa. Bạn không cần tự làm việc này; chỉ pass PDF path qua.
3. **Title-based Semantic Scholar lookup.**
   Chỉ chạy khi agent cung cấp confident title. `prepare_paper_source.py` xử lý nội bộ khi `--title` được truyền.
4. **arXiv source fetch.**
   Khi biết arXiv ID (từ step 1 hoặc 2), helper download TeX source dưới `raw/tmp/papers/.../<slug>-arxiv-src/` và dùng nó làm prepared source.
5. **Synthetic `.tex` fallback.**
   Nếu không bước nào ở trên tạo ra arXiv match, helper ghi một synthetic `.tex` được distill từ PDF text dưới `raw/tmp/`. Synthetic file đủ tốt cho ingest nhưng được đánh dấu rõ là fallback.

## Invocation

Khi bạn đã có title và/hoặc arXiv ID (có thể cả hai đều rỗng), chạy:

```bash
"$PYTHON_BIN" tools/prepare_paper_source.py \
  --raw-root raw \
  --source <pdf-path> \
  [--title "<agent-recovered-title>"] \
  [--arxiv-id "<agent-recovered-arxiv-id>"]
```

- Chỉ truyền `--title` khi agent confident. Không truyền title lấy từ PDF metadata hoặc filename — helper tự sanitize chúng và coi chúng là authoritative sẽ poison Semantic Scholar lookup.
- Chỉ truyền `--arxiv-id` khi agent đọc nó từ trang. Filename-embedded IDs được tự động pick up.
- Bỏ qua cả hai flags khi không có cái nào confident. Helper sẽ fallback sạch.

Helper ghi một prepared entry dưới `raw/tmp/` và in JSON record với `prepared_path`, `title`, `arxiv_id`, và mọi warnings. Dùng `prepared_path` làm source cho phần còn lại của `/ingest`.

## Title authority

Khi agent cung cấp confident title, coi title đó là authoritative cho field `title` của paper page. Titles được sanitize từ fetched TeX hoặc PDF metadata chỉ là fallback display strings; không để chúng overwrite agent title. Điều này quan trọng vì agent-recovered title là thứ đã dẫn đến S2 lookup thành công; để parsed-TeX title overwrite nó tạo ra identity drift tinh vi.

## Output

Một preprocessing pass thành công tạo đúng một prepared source entry dưới `raw/tmp/`:

- nếu arXiv source được fetch: một directory như `raw/tmp/papers/<slug>-arxiv-src/` chứa original `.tex` tree
- nếu không: một synthetic `raw/tmp/papers/<slug>.tex` distill từ PDF

Từ lúc này, coi prepared entry giống hệt như một user-provided local `.tex`. Không re-copy PDF vào `raw/papers/`; original path vẫn là user-owned artifact.
