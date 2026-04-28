---
description: Đặt câu hỏi cho wiki, truy xuất và tổng hợp các trang liên quan, tùy chọn kết tinh câu trả lời trở lại wiki
argument-hint: <câu-hỏi>
---

# /ask

> Đặt câu hỏi cho cơ sở tri thức wiki. LLM đọc context_brief.md để có ngữ cảnh toàn cục,
> truy xuất các trang liên quan, tổng hợp câu trả lời với trích dẫn. Câu trả lời tốt có thể được
> kết tinh trở lại wiki — ghi vào outputs/ hoặc dưới dạng trang concept/claim mới —
> để việc khám phá tích lũy như việc ingest.

## Đầu Vào

- `question`: câu hỏi bằng ngôn ngữ tự nhiên (ví dụ: "Sự khác biệt cốt lõi giữa LoRA và Adapter là gì?")
- `--crystallize` (tùy chọn): nếu được chỉ định, kết tinh câu trả lời trở lại wiki (mặc định: chỉ trả lời, không ghi)
- `--format` (tùy chọn): định dạng đầu ra, mặc định `markdown`, tùy chọn: `table` / `timeline` / `bullets`

## Đầu Ra

- **Luôn luôn**: đầu ra terminal của câu trả lời được tổng hợp (với trích dẫn `[[slug]]`)
- **Nếu crystallize**:
  - `wiki/outputs/{query-slug}.md` — trang kết quả truy vấn (mục tiêu kết tinh mặc định)
  - hoặc `wiki/concepts/{slug}.md` — nếu câu trả lời tiết lộ một khái niệm xuyên bài báo mới
  - hoặc `wiki/claims/{slug}.md` — nếu câu trả lời nổi lên một khẳng định có thể xác minh mới
  - cập nhật `wiki/graph/edges.jsonl` (các mối quan hệ được tạo ra bởi crystallize)
  - cập nhật `wiki/index.md` và `wiki/log.md`

## Tương Tác Wiki

### Đọc
- `wiki/graph/context_brief.md` — ngữ cảnh nén toàn cục (khẳng định, khoảng trống, ý tưởng thất bại, bài báo, cạnh)
- `wiki/index.md` — danh mục trang để định vị các trang liên quan
- `wiki/graph/open_questions.md` — câu hỏi mở, giúp xác định liệu câu hỏi có chạm đến các khoảng trống đã biết không
- `wiki/papers/*.md` — các trang bài báo liên quan đến câu hỏi
- `wiki/concepts/*.md` — các trang khái niệm liên quan đến câu hỏi
- `wiki/claims/*.md` — các trang khẳng định liên quan đến câu hỏi
- `wiki/topics/*.md` — các trang chủ đề liên quan đến câu hỏi
- `wiki/people/*.md` — nếu câu hỏi liên quan đến các nhà nghiên cứu cụ thể
- `wiki/ideas/*.md` — nếu câu hỏi liên quan đến ý tưởng nghiên cứu hoặc ý tưởng thất bại
- `wiki/experiments/*.md` — nếu câu hỏi liên quan đến kết quả thí nghiệm
- `wiki/Summary/*.md` — nếu câu hỏi liên quan đến cảnh quan toàn lĩnh vực

### Ghi (chỉ chế độ crystallize)
- `wiki/outputs/{query-slug}.md` — TẠO (trang kết quả truy vấn)
- `wiki/concepts/{slug}.md` — TẠO (khái niệm mới được phát hiện) hoặc CHỈNH SỬA (bổ sung khái niệm hiện có)
- `wiki/claims/{slug}.md` — TẠO (khẳng định mới được phát hiện) hoặc CHỈNH SỬA (thêm bằng chứng)
- `wiki/graph/edges.jsonl` — THÊM (các mối quan hệ được tạo ra bởi crystallize)
- `wiki/graph/context_brief.md` — XÂY DỰNG LẠI (nếu crystallize tạo ra các trang mới)
- `wiki/graph/open_questions.md` — XÂY DỰNG LẠI (nếu crystallize tạo ra các trang mới)
- `wiki/index.md` — CHỈNH SỬA (nếu crystallize tạo ra các trang mới)
- `wiki/log.md` — THÊM

### Các cạnh đồ thị được tạo ra (chỉ crystallize)
- `output → paper`: `derived_from` (các bài báo được trích dẫn trong câu trả lời)
- `output → concept`: `derived_from` (các khái niệm được trích dẫn trong câu trả lời)
- `output → claim`: `derived_from` (các khẳng định được trích dẫn trong câu trả lời)
- `concept → paper`: `supports` (nếu một khái niệm mới được tổng quát hóa từ các bài báo)
- `claim → paper`: `supports` (nếu một khẳng định mới được trích xuất từ các bài báo)

## Quy Trình Làm Việc

**Điều kiện tiên quyết**: xác nhận thư mục làm việc là thư mục gốc dự án wiki (chứa `wiki/`, `raw/`, `tools/`).
Đặt `WIKI_ROOT=wiki/`.

### Bước 1: Tải Ngữ Cảnh Toàn Cục

1. Đọc `wiki/graph/context_brief.md` — lấy ảnh chụp nhanh nén của kiến thức hiện tại của wiki (khẳng định, khoảng trống, bài báo, cạnh)
2. Đọc `wiki/graph/open_questions.md` — hiểu các câu hỏi mở đã biết và khoảng trống kiến thức
3. Nếu cả hai đều thiếu, xây dựng lại trước:
   ```bash
   python3 tools/research_wiki.py rebuild-context-brief wiki/
   python3 tools/research_wiki.py rebuild-open-questions wiki/
   ```

### Bước 2: Truy Xuất Các Trang Liên Quan

1. Đọc `wiki/index.md`, khớp các slug liên quan với từ khóa câu hỏi
2. Trích xuất các khẳng định và bài báo liên quan ngữ nghĩa đến câu hỏi từ context_brief.md
3. Sắp xếp theo mức độ liên quan, chọn top-K trang (K ≤ 15 để tránh vượt quá cửa sổ ngữ cảnh)
4. Đọc nội dung đầy đủ của các trang đã chọn
5. Nếu câu hỏi liên quan đến mối quan hệ (ví dụ: "sự khác biệt giữa X và Y"), đọc thêm các cạnh kết nối X và Y từ `wiki/graph/edges.jsonl`

### Bước 3: Tổng Hợp Câu Trả Lời

1. Tổng hợp câu trả lời cho câu hỏi của người dùng dựa trên nội dung trang đã thu thập
2. Yêu cầu câu trả lời:
   - **Có trích dẫn**: mọi khẳng định chính phải bao gồm một wikilink `[[slug]]` trỏ đến trang nguồn của nó
   - **Có cấu trúc**: tổ chức đầu ra theo tham số `--format` (markdown / table / timeline / bullets)
   - **Thừa nhận sự không chắc chắn**: gắn cờ rõ ràng "bằng chứng không đủ trong wiki" cho các phần có hỗ trợ yếu
   - **Gắn cờ khoảng trống kiến thức**: nếu câu hỏi chạm đến một khoảng trống đã biết trong open_questions.md, gọi nó ra một cách rõ ràng
   - **Trích dẫn độ tin cậy của khẳng định**: khi tham chiếu các khẳng định, lưu ý độ tin cậy và trạng thái của chúng
3. Nếu câu hỏi vượt quá kiến thức hiện tại của wiki, hãy nói thẳng và đề xuất:
   - những bài báo nào cần ingest để lấp đầy khoảng trống
   - các hướng tìm kiếm có thể (từ khóa arXiv, truy vấn Semantic Scholar)

### Bước 4: Đánh Giá Giá Trị Crystallize

1. Đánh giá liệu câu trả lời có đáng được ghi lại vào wiki không (đưa ra khuyến nghị ngay cả khi `--crystallize` không được chỉ định)
2. Tín hiệu cho thấy crystallize đáng giá:
   - Câu trả lời tổng hợp thông tin từ nhiều bài báo, hình thành một cái nhìn xuyên bài báo mới
   - Câu trả lời tiết lộ một khái niệm chưa được ghi lại rõ ràng trong wiki
   - Câu trả lời nổi lên một khẳng định có thể xác minh mới (claim)
   - Câu trả lời giải quyết một khoảng trống đã biết trong open_questions.md
3. Tín hiệu cho thấy crystallize không đáng giá:
   - Câu trả lời chỉ đơn thuần trình bày lại nội dung của một trang duy nhất
   - Câu hỏi là một tra cứu thực tế đơn giản (ví dụ: "LoRA được xuất bản năm nào?")
   - Câu trả lời chủ yếu dựa vào suy luận hơn là bằng chứng wiki
4. Thêm một khuyến nghị crystallize vào cuối câu trả lời:
   ```
   💡 Khuyến nghị crystallize: [đáng giá / không cần thiết] — [lý do]
   ```

### Bước 5: Kết Tinh Trở Lại Wiki (nếu người dùng xác nhận hoặc --crystallize được chỉ định)

Chọn mục tiêu crystallize dựa trên nội dung câu trả lời:

**Trường hợp A — Ghi vào outputs/ (mặc định):**
1. Tạo slug: `python3 tools/research_wiki.py slug "<query-summary>"`
2. Tạo `wiki/outputs/{query-slug}.md`:
   ```yaml
   ---
   title: ""
   slug: ""
   query: ""           # câu hỏi gốc
   source_pages: []    # slug của tất cả các trang được trích dẫn trong câu trả lời
   date_created: YYYY-MM-DD
   ---
   ```
   Nội dung là câu trả lời (giữ nguyên wikilinks)
3. Thêm một cạnh đồ thị cho mỗi trang nguồn được trích dẫn:
   ```bash
   python3 tools/research_wiki.py add-edge wiki/ --from outputs/<slug> --to papers/<source-slug> --type derived_from --evidence "query answer"
   ```

**Trường hợp B — Tạo khái niệm mới:**
1. Nếu câu trả lời tiết lộ một khái niệm mới: tạo `wiki/concepts/{slug}.md` sử dụng mẫu concept trong CLAUDE.md
2. maturity: emerging
3. key_papers: trích xuất từ trích dẫn câu trả lời
4. Thêm các cạnh đồ thị (concept → papers)
5. Thêm liên kết ngược vào các trang bài báo liên quan dưới `## Related`

**Trường hợp C — Tạo khẳng định mới:**
1. Nếu câu trả lời nổi lên một khẳng định mới: tạo `wiki/claims/{slug}.md` sử dụng mẫu claim trong CLAUDE.md
2. status: proposed (được tổng hợp từ truy vấn, không phải bằng chứng thí nghiệm trực tiếp)
3. confidence: đặt giá trị ban đầu dựa trên sức mạnh của bằng chứng được trích dẫn
4. source_papers: trích xuất từ trích dẫn câu trả lời
5. Thêm các cạnh đồ thị (claim → papers)
6. Thêm liên kết ngược vào các trang bài báo liên quan dưới `## Related`

### Bước 6: Cập Nhật Điều Hướng và Đồ Thị (chỉ crystallize)

1. **index.md**: thêm các mục trang mới dưới danh mục thích hợp
2. **log.md**:
   ```bash
   python3 tools/research_wiki.py log wiki/ "ask | <question-summary> | crystallized: <target-path>"
   ```
   Nếu không crystallize:
   ```bash
   python3 tools/research_wiki.py log wiki/ "ask | <question-summary> | answer-only"
   ```
3. **Xây dựng lại các tệp đồ thị phái sinh** (chỉ khi crystallize tạo ra các trang mới):
   ```bash
   python3 tools/research_wiki.py rebuild-context-brief wiki/
   python3 tools/research_wiki.py rebuild-open-questions wiki/
   ```

### Bước 7: Báo Cáo Cho Người Dùng

Xuất ra một bản tóm tắt bao gồm:
- Số lượng và danh sách các trang đã truy xuất
- Câu trả lời (với trích dẫn và định dạng)
- Chú thích khoảng trống kiến thức (nếu có)
- Khuyến nghị crystallize hoặc kết quả thực thi
- Đề xuất tiếp theo (các bài báo được khuyến nghị để ingest, các câu hỏi mở liên quan)

## Các Ràng Buộc

- **Không bịa đặt**: câu trả lời phải dựa trên nội dung wiki thực tế; không tự tạo từ kiến thức tiền huấn luyện của LLM
- **Trích dẫn phải tồn tại**: mọi `[[slug]]` phải trỏ đến một trang thực sự tồn tại trong wiki
- **raw/ là chỉ đọc**: không sửa đổi các tệp dưới `raw/`
- **graph/ chỉ thông qua công cụ**: không chỉnh sửa thủ công các tệp dưới `graph/`
- **Crystallize yêu cầu xác nhận**: trừ khi người dùng chỉ định rõ ràng `--crystallize`, chỉ khuyến nghị nhưng không ghi
- **Giới hạn ngữ cảnh**: truy xuất tối đa 15 trang để ở trong cửa sổ ngữ cảnh
- **Trích dẫn độ tin cậy của khẳng định**: khi tham chiếu các khẳng định, luôn lưu ý giá trị độ tin cậy và trạng thái của chúng
- **Gắn cờ khoảng trống**: nếu câu hỏi chạm đến một khoảng trống đã biết trong open_questions.md, gọi nó ra một cách rõ ràng
- **frontmatter của outputs/ phải bao gồm query và source_pages**: đảm bảo khả năng truy xuất nguồn gốc

## Xử Lý Lỗi

- **context_brief.md thiếu**: chạy `python3 tools/research_wiki.py rebuild-context-brief wiki/` để xây dựng lại, sau đó thử lại
- **wiki trống**: thông báo cho người dùng chạy `/init` hoặc `/ingest` trước để xây dựng cơ sở tri thức
- **không có trang khớp**: báo cáo trung thực rằng không có nội dung liên quan trong wiki, đề xuất hướng tìm kiếm và ingest
- **xung đột slug crystallize**: thêm hậu tố số (ví dụ: `query-result-2`)
- **index.md thiếu**: chạy `python3 tools/research_wiki.py init wiki/` để khởi tạo, sau đó thử lại

## Phụ Thuộc

### Công cụ (qua Bash)
- `python3 tools/research_wiki.py slug "<title>"` — tạo slug
- `python3 tools/research_wiki.py add-edge wiki/ --from <id> --to <id> --type <type> --evidence "<text>"` — thêm cạnh đồ thị
- `python3 tools/research_wiki.py rebuild-context-brief wiki/` — xây dựng lại ngữ cảnh nén
- `python3 tools/research_wiki.py rebuild-open-questions wiki/` — xây dựng lại bản đồ khoảng trống kiến thức
- `python3 tools/research_wiki.py log wiki/ "<message>"` — thêm mục nhật ký
- `python3 tools/research_wiki.py init wiki/` — khởi tạo wiki (dự phòng)

### Kỹ năng (qua công cụ Skill)
- `/ingest` — được tham chiếu khi đề xuất người dùng bổ sung kiến thức

### Tài liệu tham khảo chung
- `.claude/skills/shared-references/citation-verification.md` (được tạo trong Giai đoạn 3)