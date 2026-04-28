---
description: Tạo phần Công trình liên quan cho bài báo từ kiến thức wiki — nhóm theo chủ đề → cấu trúc tường thuật → đầu ra LaTeX, tuân theo citation-verification và academic-writing
argument-hint: <câu-hỏi-nghiên-cứu-hoặc-slug-khẳng-định> [--format latex|markdown] [--max-papers 30]
---

# /survey

> Tạo phần Công trình liên quan sẵn sàng để sử dụng trực tiếp trong bài báo, dựa trên kiến thức wiki hiện có.
> Lấy tài liệu từ wiki/papers/, concepts/, topics/; nhóm theo hướng nghiên cứu (không liệt kê từng bài báo).
> Kết thúc mỗi nhóm bằng một tuyên bố về sự khác biệt so với công trình này. Trích dẫn tuân theo citation-verification.md;
> viết tuân theo quy tắc Công trình liên quan trong academic-writing.md.
> Hỗ trợ định dạng đầu ra LaTeX và Markdown.

## Đầu Vào

- `query`: một trong các mục sau:
  - mô tả câu hỏi nghiên cứu (văn bản tự do, ví dụ: "tinh chỉnh hiệu quả tham số cho LLM")
  - danh sách slug khẳng định (từ wiki/claims/, dùng để tổ chức công trình liên quan xung quanh các khẳng định cụ thể)
  - đường dẫn đến PAPER_PLAN.md (trích xuất định nghĩa phần Công trình liên quan từ đó)
- `--format` *(tùy chọn, mặc định `latex`)*: định dạng đầu ra
  - `latex`: trích dẫn `\cite{key}`, có thể nhúng trực tiếp vào bài báo
  - `markdown`: trích dẫn wikilink `[[slug]]`, để lưu trữ wiki
- `--max-papers` *(tùy chọn, mặc định 30)*: số lượng bài báo tối đa để trích dẫn

## Đầu Ra

- `wiki/outputs/related-work-{slug}-{date}.md` — văn bản Công trình liên quan (được lưu trữ)
- `wiki/graph/edges.jsonl` — các cạnh derived_from (nếu một đầu ra mới được tạo)
- `wiki/log.md` — mục nhật ký được thêm
- **Đầu ra terminal** — văn bản nội dung Công trình liên quan (để sao chép-dán trực tiếp)

## Tương Tác Wiki

### Đọc

- `wiki/papers/*.md` — Vấn đề, Ý tưởng chính, Kết quả, Liên quan, Đánh giá của tôi
- `wiki/concepts/*.md` — Định nghĩa, Các biến thể, So sánh, Hạn chế đã biết
- `wiki/topics/*.md` — Tổng quan, Dòng thời gian, Vấn đề mở, Công trình nền tảng
- `wiki/claims/*.md` — Phát biểu, source_papers (nếu đầu vào là slug khẳng định)
- `wiki/ideas/*.md` — Động lực (hiểu định vị của bài báo này)
- `wiki/index.md` — danh mục nội dung, được lọc theo tầm quan trọng
- `wiki/graph/context_brief.md` — ngữ cảnh toàn cục
- `wiki/graph/edges.jsonl` — mối quan hệ ngữ nghĩa giữa các bài báo (same_problem_as, similar_method_to, complementary_to, builds_on, compares_against, improves_on, challenges, surveys)
- `.claude/skills/shared-references/academic-writing.md` — quy tắc viết Công trình liên quan
- `.claude/skills/shared-references/citation-verification.md` — kỷ luật trích dẫn

### Ghi

- `wiki/outputs/related-work-{slug}-{date}.md` — tệp được lưu trữ
- `wiki/graph/edges.jsonl` — các cạnh derived_from
- `wiki/log.md` — nhật ký hoạt động được thêm

### Các cạnh đồ thị được tạo

- `derived_from`: đầu ra công trình liên quan → các bài báo nguồn

## Quy Trình Làm Việc

**Điều kiện tiên quyết**: xác nhận thư mục làm việc là thư mục gốc dự án wiki (thư mục chứa `wiki/`, `raw/`, `tools/`).

### Bước 1: Xác Định Vị Trí Kiến Thức Liên Quan

1. **Phân tích đầu vào**:
   - Nếu là văn bản tự do: trích xuất từ khóa; khớp với thẻ và tiêu đề trong wiki/index.md
   - Nếu là slug khẳng định: đọc source_papers của mỗi khẳng định; thu thập các bài báo liên quan
   - Nếu là đường dẫn PAPER_PLAN: đọc các nhóm và trích dẫn của phần Công trình liên quan
2. **Đọc wiki/graph/context_brief.md** để có ngữ cảnh toàn cục
3. **Đọc wiki/graph/edges.jsonl**: trích xuất mối quan hệ giữa các bài báo (extends, contradicts, supersedes)
4. **Xây dựng danh sách bài báo ứng viên**:
   - Sắp xếp theo tầm quan trọng giảm dần từ index.md
   - Xếp hạng theo thẻ và khớp lĩnh vực
   - Giới hạn ở `--max-papers` bài báo
5. **Nếu bài báo ứng viên < 5**: cảnh báo "không đủ bài báo liên quan; cân nhắc /ingest thêm bài báo trước"

### Bước 2: Đọc Sâu Các Trang Liên Quan

Đối với mỗi bài báo trong danh sách ứng viên:

1. Đọc `wiki/papers/{slug}.md`: tập trung vào Vấn đề, Ý tưởng chính, Kết quả, Đánh giá của tôi
2. Đọc `wiki/concepts/*.md` được liên kết: tập trung vào Định nghĩa, Các biến thể, So sánh
3. Đọc `wiki/topics/*.md` liên quan: tập trung vào Dòng thời gian, Vấn đề mở

Ghi lại cho mỗi bài báo:
- đóng góp cốt lõi (một câu)
- danh mục phương pháp (thuộc hướng nghiên cứu nào)
- mối quan hệ với công trình này (extends / contradicts / orthogonal / baseline)
- hạn chế (trích xuất từ Hạn chế hoặc Đánh giá của tôi)

### Bước 3: Nhóm Theo Chủ Đề

Tuân theo quy tắc Công trình liên quan trong `shared-references/academic-writing.md`:

1. **Nhóm theo hướng nghiên cứu** (không liệt kê từng bài báo):
   - Trích xuất các nhóm tự nhiên từ phân loại wiki/topics/ và concepts/
   - 3–8 bài báo mỗi nhóm
   - Tiêu đề nhóm mô tả hướng nghiên cứu (ví dụ: "Tinh chỉnh Hiệu quả Tham số"), không phải từng bài báo
2. **Xác định thứ tự nhóm**:
   - Rộng đến cụ thể (hướng chính → hướng phụ → phương pháp liên quan nhất)
   - Hoặc theo thời gian (nền tảng → phát triển → gần đây)
3. **Xác định thứ tự trong nhóm**:
   - Tăng dần theo năm (hiển thị sự tiến triển)
   - Bài báo quan trọng: 2–3 câu; bài báo thứ yếu: 1 câu
4. **Chú thích mối quan hệ của mỗi nhóm với công trình này**:
   - Kết thúc mỗi nhóm bằng một câu: "Không giống như các cách tiếp cận này, phương pháp của chúng tôi..." hoặc "Chúng tôi xây dựng dựa trên X bằng cách..."

### Bước 4: Tạo Đoạn Văn

Tuân theo `shared-references/academic-writing.md`:

1. **Một hoặc hai đoạn văn cho mỗi nhóm**:
   - Mở đầu: bối cảnh và tầm quan trọng của hướng
   - Nội dung: mở rộng về đóng góp của mỗi bài báo theo thứ tự trong nhóm
   - Kết thúc: định vị so với công trình này (bắt buộc)

2. **Định dạng trích dẫn**:
   - `--format latex`: `\cite{key}`, key được tạo từ quy tắc đặt tên trong citation-verification.md
   - `--format markdown`: `[[slug]]`

3. **Tiêu chuẩn viết**:
   - Không có danh sách phẳng ("X đã làm Y. Z đã làm W.")
   - Mỗi đoạn văn có một câu chủ đề
   - Sử dụng liên từ tương phản ("Trong khi X tập trung vào..., Y giải quyết...")
   - Không có từ vựng đặc trưng AI (xem danh sách de-AI trong academic-writing.md)

4. **Đánh bóng de-AI**:
   - Quét và thay thế từ vựng đặc trưng AI
   - Đa dạng hóa cách mở đầu câu
   - Loại bỏ câu thừa

### Bước 5: Chuẩn Bị BibTeX (chỉ --format latex)

Nếu định dạng đầu ra là LaTeX, tuân theo `shared-references/citation-verification.md`:

1. Thu thập tất cả trích dẫn `\cite{key}`
2. Đối với mỗi key, cố gắng lấy BibTeX: DBLP → CrossRef → S2
3. Đã xác minh: ghi lại BibTeX
4. Chưa xác minh: đánh dấu `[UNCONFIRMED]`
5. Xuất danh sách các mục BibTeX (có thể được thêm vào paper/references.bib)
6. Báo cáo độ phủ trích dẫn

### Bước 6: Lưu Trữ

1. **Tạo slug**:
   ```bash
   python3 tools/research_wiki.py slug "<từ-khóa-truy-vấn>"
   ```

2. **Ghi tệp lưu trữ**:
   Tạo `wiki/outputs/related-work-{slug}-{date}.md`:
   ```yaml
   ---
   title: "Công trình liên quan: {chủ đề}"
   type: related-work
   format: {latex|markdown}
   paper_count: {N}
   date_generated: YYYY-MM-DD
   ---
   ```
   Nội dung là văn bản Công trình liên quan hoàn chỉnh.
   Nếu định dạng latex: thêm các mục BibTeX như một phụ lục.

3. **Thêm cạnh đồ thị**:
   ```bash
   # đầu ra → mỗi bài báo được trích dẫn
   python3 tools/research_wiki.py add-edge wiki/ \
     --from "outputs/related-work-{slug}-{date}" --to "papers/{paper-slug}" \
     --type derived_from --evidence "Được trích dẫn trong phần công trình liên quan"
   ```

4. **Thêm nhật ký**:
   ```bash
   python3 tools/research_wiki.py log wiki/ \
     "survey | {chủ đề} | {N} bài báo, {G} nhóm, định dạng: {format}"
   ```

5. **Đầu ra terminal**: văn bản nội dung Công trình liên quan hoàn chỉnh + thống kê độ phủ trích dẫn

## Các Ràng Buộc

- **Chỉ trích dẫn các bài báo đã có trong wiki**: không bịa đặt trích dẫn; mọi `\cite{}` hoặc `[[slug]]` phải tương ứng với một trang trong wiki/papers/
- **Nhóm theo chủ đề, không phải danh sách phẳng**: mỗi đoạn văn bao gồm một hướng nghiên cứu, không phải "Bài báo A đã làm X. Bài báo B đã làm Y."
- **Mỗi nhóm phải có câu định vị**: nêu mối quan hệ với công trình này (ở cuối — sự khác biệt hoặc kế thừa)
- **Cảnh báo khi bài báo ứng viên < 5**: nhắc người dùng /ingest thêm bài báo trước
- **BibTeX tuân theo citation-verification.md**: không tạo từ bộ nhớ LLM (chỉ --format latex)
- **Đánh bóng de-AI là bắt buộc**: một lượt đánh bóng phải được áp dụng sau khi tạo
- **Lưu trữ vào outputs/**: không trực tiếp sửa đổi các trang wiki papers/concepts/topics
- **Các cạnh đồ thị thông qua tools/research_wiki.py**: không chỉnh sửa thủ công edges.jsonl

## Xử Lý Lỗi

- **Ít hơn 3 bài báo wiki**: lỗi; đề xuất /ingest đủ bài báo trước
- **Không có bài báo khớp**: mở rộng phạm vi tìm kiếm (nới lỏng khớp thẻ); nếu vẫn không có, lỗi
- **Tất cả lấy BibTeX thất bại** (định dạng latex): sử dụng placeholder [UNCONFIRMED]; báo cáo số lượng
- **Định dạng PAPER_PLAN không khớp**: bỏ qua gợi ý nhóm của kế hoạch; sử dụng nhóm tự động
- **Xung đột slug**: thêm hậu tố ngày

## Phụ Thuộc

### Công cụ (thông qua Bash)

- `python3 tools/research_wiki.py slug "<title>"` — tạo slug
- `python3 tools/research_wiki.py add-edge wiki/ ...` — thêm cạnh đồ thị
- `python3 tools/research_wiki.py log wiki/ "<message>"` — thêm nhật ký
- `python3 tools/fetch_s2.py search "<title>"` — dự phòng BibTeX (tìm kiếm S2)

### Máy Chủ MCP

- Không có (survey không yêu cầu Review LLM; sử dụng /review --focus writing để đánh giá riêng)

### Claude Code Gốc

- `Read` — đọc các trang wiki
- `Glob` — tìm các trang wiki
- `WebFetch` — lấy BibTeX DBLP / CrossRef (chỉ --format latex)

### Tài Liệu Tham Khảo Chung

- `.claude/skills/shared-references/academic-writing.md` — quy tắc viết Công trình liên quan + đánh bóng de-AI
- `.claude/skills/shared-references/citation-verification.md` — lấy BibTeX và giao thức [UNCONFIRMED]

### Được Gọi Bởi

- `/paper-draft` Bước 3 (phần Công trình liên quan có thể được ủy quyền cho kỹ năng này)
- Người dùng gọi thủ công