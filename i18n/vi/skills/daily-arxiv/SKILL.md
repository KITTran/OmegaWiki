---
description: Lấy bài báo hàng ngày từ arXiv, lọc theo mức độ liên quan, tự động ingest các bài báo ưu tiên cao, và phát hiện cập nhật SOTA
argument-hint: "[--hours 24] [--max-ingest 5] [--dry-run]"
---

# /daily-arxiv

> Lấy bài báo mới từ RSS arXiv hàng ngày, tự động đánh giá mức độ liên quan dựa trên các hướng nghiên cứu và khái niệm trong wiki,
> gọi /ingest để tích hợp đầy đủ các bài báo có mức độ liên quan cao vào wiki, phát hiện cập nhật SOTA, và tạo nhật ký tóm tắt.
> Hỗ trợ thực thi tự động theo lịch trình cron cũng như kích hoạt thủ công.

## Đầu Vào

- `--hours N`: lấy bài báo từ N giờ gần đây (mặc định 24)
- `--max-ingest N`: số lượng bài báo tối đa để ingest mỗi lần chạy (mặc định 5, ngăn chặn quá tải wiki)
- `--dry-run`: chỉ tạo tóm tắt, không thực hiện ingest
- `--categories`: ghi đè các danh mục arXiv mặc định (mặc định: cs.LG cs.CV cs.CL cs.AI stat.ML)

## Đầu Ra

- `raw/discovered/{slug}/` hoặc `raw/discovered/{slug}.pdf` — tạo tác nguồn đã lấy cho mỗi bài báo được tự động ingest
- `wiki/papers/{slug}.md` — các trang bài báo có mức độ liên quan cao (được tạo qua /ingest)
- Các trang `concepts/`, `people/`, `claims/` tương ứng (được tạo qua /ingest)
- Đã cập nhật `wiki/topics/*.md` — chú thích theo dõi SOTA (nếu phát hiện cập nhật SOTA)
- Đã cập nhật `wiki/graph/` — edges.jsonl, context_brief.md, open_questions.md (được duy trì qua /ingest)
- Đã cập nhật `wiki/index.md` và `wiki/log.md`

## Tương Tác Wiki

### Đọc
- `wiki/topics/*.md` — trích xuất từ khóa Overview và theo dõi SOTA, sử dụng để đánh giá mức độ liên quan và phát hiện SOTA
- `wiki/concepts/*.md` — trích xuất từ khóa Definition, hỗ trợ đánh giá mức độ liên quan
- `wiki/index.md` — kiểm tra xem bài báo đã được thu thập chưa (loại bỏ trùng lặp theo URL arXiv)
- `wiki/papers/*.md` — kiểm tra xem ID arXiv đã tồn tại chưa
- `wiki/graph/open_questions.md` — ưu tiên ingest các bài báo lấp đầy khoảng trống kiến thức

### Ghi
- `wiki/papers/{slug}.md` — TẠO qua /ingest
- `wiki/concepts/{slug}.md` — TẠO/CHỈNH SỬA qua /ingest
- `wiki/people/{slug}.md` — TẠO/CHỈNH SỬA qua /ingest
- `wiki/claims/{slug}.md` — TẠO/CHỈNH SỬA qua /ingest
- `wiki/topics/{slug}.md` — CHỈNH SỬA (chú thích theo dõi SOTA)
- `wiki/graph/edges.jsonl` — THÊM qua /ingest
- `wiki/graph/context_brief.md` — XÂY DỰNG LẠI (một lần vào cuối)
- `wiki/graph/open_questions.md` — XÂY DỰNG LẠI (một lần vào cuối)
- `wiki/index.md` — CHỈNH SỬA qua /ingest
- `wiki/log.md` — THÊM

### Các cạnh đồ thị được tạo
- Tất cả các cạnh được tạo bởi /ingest (paper → concept, paper → claim, v.v.)

## Quy Trình Làm Việc

**Điều kiện tiên quyết**: xác nhận thư mục làm việc là thư mục gốc dự án wiki (thư mục chứa `wiki/`, `raw/`, `tools/`).
Đặt `WIKI_ROOT=wiki/`.

### Bước 1: Lấy RSS arXiv + Bài Báo Xu Hướng

1. Chạy fetch_arxiv.py để lấy danh sách bài báo mới:
   ```bash
   python3 tools/fetch_arxiv.py --hours <hours> -o /tmp/arxiv_feed.json
   ```
2. Lấy bài báo xu hướng từ DeepXiv (7 ngày gần đây):
   ```bash
   python3 tools/fetch_deepxiv.py trending --days 7 --limit 20
   ```
   Hợp nhất các bài báo xu hướng vào danh sách ứng viên (loại bỏ trùng lặp theo arxiv_id); các bài báo xu hướng nhận được sự chú ý đặc biệt trong quá trình đánh giá tiếp theo.
   **Nếu DeepXiv không khả dụng**: bỏ qua bước phụ này, chỉ sử dụng kết quả RSS.
3. Phân tích cú pháp kết quả để lấy danh sách bài báo (tiêu đề, tóm tắt, tác giả, arxiv_url, arxiv_id, danh mục)
4. **Loại bỏ trùng lặp**: đọc `wiki/index.md`, bỏ qua các bài báo có URL arXiv đã có trong wiki. Cũng kiểm tra các ID arXiv hiện có trong thư mục `wiki/papers/`.
5. Nếu không có bài báo mới, bỏ qua trực tiếp đến Bước 6 để tạo tóm tắt trống.

### Bước 2: Xây Dựng Ngữ Cảnh Mức Độ Liên Quan + Tăng Cường DeepXiv

1. Đọc `wiki/topics/*.md` và trích xuất cho mỗi chủ đề:
   - Từ khóa cốt lõi từ đoạn Overview
   - Danh sách Open problems / Research gaps
   - Kết quả tốt nhất hiện tại từ theo dõi SOTA
2. Đọc `wiki/concepts/*.md` và trích xuất cho mỗi khái niệm:
   - Thuật ngữ chính từ đoạn Definition
   - Danh sách tags
3. Đọc `wiki/graph/open_questions.md` để lấy danh sách khoảng trống kiến thức hiện tại
4. Tổng hợp một "tóm tắt hướng nghiên cứu" (≤ 2000 ký tự) chứa: các chủ đề cốt lõi, các khái niệm đang hoạt động, các khoảng trống cần lấp đầy
5. **Tăng cường TLDR DeepXiv** (tùy chọn): đối với mỗi bài báo mới, lấy tóm tắt AI và từ khóa để cải thiện chất lượng đánh giá:
   ```bash
   python3 tools/fetch_deepxiv.py brief <arxiv_id>
   ```
   Bổ sung tóm tắt gốc bằng `tldr` và `keywords` trả về để giúp LLM đánh giá mức độ liên quan chính xác hơn.
   **Nếu DeepXiv không khả dụng**: chỉ sử dụng tiêu đề + tóm tắt gốc từ RSS để đánh giá (quay lại hành vi gốc).

### Bước 3: Đánh Giá Mức Độ Liên Quan

Đối với mỗi bài báo mới, LLM đánh giá mức độ liên quan dựa trên tiêu đề và tóm tắt so với tóm tắt hướng nghiên cứu:

| Điểm | Ý Nghĩa | Hành Động |
|------|------|----------|
| 3 | Rất liên quan: tiến bộ đáng kể trong một hướng cốt lõi | Tự động ingest |
| 2 | Liên quan vừa phải: đáng chú ý nhưng không cốt lõi | Liệt kê trong tóm tắt, không tự động ingest |
| 1 | Liên quan yếu: chỉ để tham khảo | Liệt kê thu gọn |
| 0 | Không liên quan | Bỏ qua |

**Quy tắc thưởng** (có thể nâng điểm 2 lên 3):
- Bài báo trực tiếp giải quyết một khoảng trống kiến thức trong open_questions.md → +1
- Bài báo có thể cập nhật theo dõi SOTA → +1 (giới hạn ở 3)

**Đánh giá theo lô**: gửi tiêu đề+tóm tắt của tất cả các bài báo cho LLM trong một lần gọi và trả về điểm dưới dạng JSON. Tránh gọi cho từng bài báo.

### Bước 4: Tự Động Ingest Các Bài Báo Ưu Tiên Cao (với tiếp tục checkpoint)

1. Lọc các bài báo có mức độ liên quan = 3, sắp xếp theo thứ tự ưu tiên sau:
   - Các bài báo lấp đầy khoảng trống trong gap_map trước
   - Các bài báo có số lượng trích dẫn cao hơn trước (nếu tóm tắt đề cập đến kết quả SOTA)
2. Tải checkpoint (bỏ qua các bài báo đã hoàn thành nếu có):
   ```bash
   python3 tools/research_wiki.py checkpoint-load wiki/ "daily-arxiv-{date}"
   ```
3. Lấy `--max-ingest` bài báo đầu tiên (mặc định 5). Đối với mỗi bài báo đã chọn:
   - Tải xuống tạo tác nguồn vào `raw/discovered/` trước:
     ```bash
     python3 tools/init_discovery.py download --raw-root raw --arxiv-id <arxiv_id> --title "<title>"
     ```
   - Truyền `canonical_ingest_path` trả về từ `raw/discovered/` vào `/ingest`, không phải URL arXiv trần
   - /ingest hoàn thành toàn bộ quy trình tích hợp wiki (paper + concepts + people + claims + cross-refs + graph)
   - Sau mỗi lần thành công, ghi lại checkpoint:
     ```bash
     python3 tools/research_wiki.py checkpoint-save wiki/ "daily-arxiv-{date}" "{arxiv_id}"
     ```
   - Nếu thất bại, đánh dấu và tiếp tục:
     ```bash
     python3 tools/research_wiki.py checkpoint-save wiki/ "daily-arxiv-{date}" "{arxiv_id}" --failed
     ```
4. Nếu `--dry-run`, bỏ qua cả tải xuống `raw/discovered/` và ingest thực tế; đánh dấu "sẽ ingest" trong tóm tắt
5. Sau khi hoàn tất, xóa checkpoint:
   ```bash
   python3 tools/research_wiki.py checkpoint-clear wiki/ "daily-arxiv-{date}"
   ```

### Bước 5: Phát Hiện và Cập Nhật SOTA

1. Đối với mỗi bài báo được ingest trong Bước 4, kiểm tra các số liệu benchmark trong phần Results
2. So sánh các benchmark với `## SOTA tracker` trong trang `wiki/topics/` tương ứng
3. Nếu kết quả của bài báo vượt trội hơn kỷ lục SOTA hiện tại:
   - Thêm/cập nhật một mục trong `## SOTA tracker` của trang chủ đề:
     ```
     - **{tên-benchmark}**: {điểm} ← [[{paper-slug}]] ({năm}) [trước đây: {điểm-cũ}]
     ```
   - Đặt `sota_updated` cho chủ đề đó là ngày hôm nay
4. Nếu phát hiện cập nhật SOTA, làm nổi bật chúng trong tóm tắt

### Bước 6: Tạo Tóm Tắt và Ghi vào Nhật Ký

1. Xây dựng lại các tệp phái sinh của đồ thị (chỉ khi có ingest xảy ra):
   ```bash
   python3 tools/research_wiki.py rebuild-context-brief wiki/
   python3 tools/research_wiki.py rebuild-open-questions wiki/
   ```

2. Thêm tóm tắt vào `wiki/log.md`:
   ```bash
   python3 tools/research_wiki.py log wiki/ "daily-arxiv | {N_ingested} ingested, {N_relevant} relevant / {N_total} total"
   ```

3. Thêm tóm tắt chi tiết dưới mục nhật ký của ngày hiện tại:
   ```markdown
   ### Ưu Tiên Cao (đã ingest)
   - [[paper-slug]] — {title} ({insight một dòng})

   ### Đáng Theo Dõi (mức độ liên quan = 2)
   - {title} — {arxiv_url} — {tóm tắt một dòng}

   ### Xu Hướng Tuần Này (từ DeepXiv)
   - {title} — {arxiv_id} — {tweets} tweets, {views} views

   ### Cập Nhật SOTA
   - {chủ đề}: {benchmark} kỷ lục mới bởi [[paper-slug]]

   <details>
   <summary>Liên Quan Yếu ({K} bài báo)</summary>

   - {title} — {arxiv_url}

   </details>
   ```

### Bước 7: Báo Cáo Cho Người Dùng

Xuất ra tóm tắt:
- Tổng số bài báo đã quét / số lượng sau khi loại bỏ trùng lặp
- Phân phối theo mức độ liên quan
- Danh sách các bài báo đã ingest (với liên kết slug)
- Danh sách các cập nhật SOTA (nếu có)
- Các ứng viên ingest thủ công được khuyến nghị (3 bài báo đáng chú ý nhất từ mức độ liên quan = 2)
- Nhắc nhở thời gian chạy tiếp theo

## Các Ràng Buộc

- **Chỉ ingest các bài báo có mức độ liên quan >= 3**: để lại phần còn lại cho người dùng đánh giá, không tự động tạo trang wiki
- **Tối đa `--max-ingest` bài báo mỗi lần chạy** (mặc định 5): ngăn chặn quá tải wiki trong một lần chạy
- **`/daily-arxiv` chỉ đọc raw ngoại trừ `raw/discovered/` cho các bài báo được tự động ingest**: không bao giờ ghi vào `raw/papers/`, `raw/tmp/`, `raw/notes/`, hoặc `raw/web/`
- **graph/ được duy trì chỉ qua công cụ**: không chỉnh sửa thủ công các tệp đồ thị
- **Liên kết hai chiều**: được đảm bảo bởi /ingest
- **Loại bỏ trùng lặp phải nghiêm ngặt**: kiểm tra kép bằng cả arxiv_url và arxiv_id
- **Đánh giá theo lô**: một lần gọi LLM để đánh giá tất cả các bài báo, không gọi cho từng bài báo
- **Tóm tắt phải ngắn gọn**: xem các trang bài báo riêng lẻ để biết chi tiết; tối đa một dòng cho mỗi bài báo trong tóm tắt
- **log.md chỉ được thêm vào**: sử dụng `python3 tools/research_wiki.py log` để thêm

## Xử Lý Lỗi

- **API DeepXiv không khả dụng**: quay lại chế độ RSS thuần (hành vi gốc). Phần xu hướng bị bỏ khỏi tóm tắt; đánh giá chỉ sử dụng dữ liệu RSS gốc. Ghi chú sự không khả dụng của DeepXiv trong báo cáo.
- **Lấy RSS thất bại**: báo cáo lỗi mạng, đề nghị người dùng kiểm tra mạng và thử lại. Không sửa đổi wiki.
- **Ingest một phần thất bại**: giữ lại các ingest đã hoàn thành, đánh dấu các bài báo thất bại trong báo cáo, đề nghị người dùng `/ingest <url>` thủ công.
- **Thư mục wiki không tồn tại**: nhắc người dùng chạy `/init` trước.
- **Kết quả RSS trống**: tình huống bình thường (ít bài báo vào ngày lễ/cuối tuần), tạo tóm tắt trống mà không báo lỗi.
- **So sánh SOTA thất bại**: nếu định dạng benchmark không khớp, bỏ qua và ghi chú trong báo cáo.

## Phụ Thuộc

### Kỹ năng (qua công cụ Skill)
- `/ingest` — quy trình tích hợp bài báo đầy đủ (được gọi trong Bước 4)

### Công cụ (qua Bash)
- `python3 tools/fetch_arxiv.py --hours <N> -o <path>` — lấy RSS arXiv
- `python3 tools/fetch_deepxiv.py trending --days 7 --limit 20` — lấy bài báo xu hướng
- `python3 tools/fetch_deepxiv.py brief <arxiv_id>` — lấy TLDR và từ khóa của bài báo
- `python3 tools/init_discovery.py download --raw-root raw --arxiv-id <id> --title "<title>"` — tải xuống các bài báo đã chọn vào `raw/discovered/`
- `python3 tools/research_wiki.py rebuild-context-brief wiki/` — xây dựng lại ngữ cảnh nén
- `python3 tools/research_wiki.py rebuild-open-questions wiki/` — xây dựng lại bản đồ khoảng trống kiến thức
- `python3 tools/research_wiki.py log wiki/ "<message>"` — thêm nhật ký

### API Ngoại Vi
- RSS arXiv (qua tools/fetch_arxiv.py)
- API DeepXiv (qua tools/fetch_deepxiv.py, tùy chọn; quay lại chế độ an toàn khi không khả dụng)

### Lập Lịch
- Có thể được lên lịch thực thi tự động hàng ngày qua CronCreate:
  ```
  CronCreate: lên lịch "/daily-arxiv" hàng ngày lúc 08:00
  ```