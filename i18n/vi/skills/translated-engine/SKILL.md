--- 
description: Engine dịch thuật kỹ thuật giúp bảo toàn ngữ cảnh, ý nghĩa, giọng văn và từ khóa kỹ thuật giữa các ngôn ngữ (en/vi/zh). Dịch tài liệu skill, shared references và nội dung wiki trong khi duy trì nhất quán với thuật ngữ hiện có và quy ước của dự án.
argument-hint: <source-path> <target-lang> [--dry-run] [--force]
---

# /translated-engine

> Engine dịch thuật kỹ thuật cho ΩmegaWiki. Dịch tài liệu skill, shared references và nội dung wiki trong khi bảo toàn:
> - Ngữ cảnh và ý nghĩa chuyên ngành
> - Giọng văn kỹ thuật và tính nghiêm túc học thuật
> - Từ khóa không được dịch (commands, flags, paths, tên API, tên field)
> - Cấu trúc Markdown và code blocks
> - Nhất quán giữa các ngôn ngữ với các bản dịch hiện có

## Đầu Vào

- `source-path`: đường dẫn đến file nguồn cần dịch (phải nằm trong `i18n/en/`, `i18n/vi/` hoặc `i18n/zh/`)
- `target-lang`: mã ngôn ngữ đích (`en`, `vi` hoặc `zh`)
- `--dry-run` (tùy chọn): xem trước bản dịch mà không ghi vào đĩa
- `--force` (tùy chọn): ghi đè file đích hiện có mà không cần xác nhận

## Đầu Ra

- File đã dịch được ghi vào đường dẫn tương ứng trong thư mục ngôn ngữ đích
- Báo cáo dịch thuật (in ra terminal) bao gồm:
  - Danh sách các thuật ngữ kỹ thuật được giữ nguyên (commands, flags, paths, tên API, tên field)
  - Kết quả kiểm tra cấu trúc Markdown
  - Cảnh báo nhất quán (nếu có xung đột thuật ngữ với các bản dịch hiện có)

## Tương Tác Wiki

### Đọc
- File nguồn được chỉ định trong `source-path`
- Tất cả các file hiện có trong thư mục ngôn ngữ đích (`i18n/<target-lang>/`) để kiểm tra nhất quán
- `i18n/en/CLAUDE.md`, `i18n/vi/CLAUDE.md` và `i18n/zh/CLAUDE.md` cho các quy ước dự án
- `docs/runtime-page-templates.md` cho các quy tắc cấu trúc Markdown

### Ghi
- File đã dịch vào `i18n/<target-lang>/<relative-path>` (chỉ khi không ở chế độ `--dry-run`)
- Không sửa đổi nội dung wiki hoặc các file graph

## Quy Trình

### Bước 1: Phân Tích Trước Khi Dịch

1. **Kiểm tra đầu vào**:
   - Xác nhận `source-path` tồn tại và nằm trong thư mục i18n
   - Xác nhận `target-lang` là một trong các giá trị `en`, `vi` hoặc `zh`
   - Kiểm tra xem file đích đã tồn tại chưa (trừ khi chỉ định `--force`)

2. **Trích xuất từ khóa kỹ thuật**:
   - Xác định tất cả commands (ví dụ: `/ingest`, `/exp-run`)
   - Xác định tất cả flags (ví dụ: `--discover`, `--full`)
   - Xác định tất cả paths (ví dụ: `wiki/papers/`, `raw/discovered/`)
   - Xác định tất cả tên API, tên field và enum values (ví dụ: `DEEPXIV_TOKEN`, `supports`, `contradicts`)
   - Xác định tất cả wikilinks (ví dụ: `[[slug]]`, `[[flash-attention]]`)
   - Xác định tất cả code blocks và inline code

3. **Kiểm tra nhất quán**:
   - So sánh các từ khóa đã xác định với các bản dịch hiện có trong `i18n/<target-lang>/`
   - Đánh dấu các bất nhất với thuật ngữ hiện có
   - Tạo danh sách các thuật ngữ phải giữ nguyên không dịch

### Bước 2: Dịch Thuật

1. **Bảo toàn cấu trúc**:
   - Giữ nguyên tất cả các thành phần Markdown (headings, lists, tables, blockquotes, code fences)
   - Giữ nguyên YAML frontmatter
   - Giữ nguyên tất cả từ khóa kỹ thuật đã xác định ở Bước 1

2. **Dịch theo ngữ cảnh**:
   - Với mỗi đoạn/phần, phân tích ngữ cảnh xung quanh để xác định:
     - Lĩnh vực (nghiên cứu ML, thiết kế thí nghiệm, viết bài báo, v.v.)
     - Giọng văn (kỹ thuật, học thuật, hướng dẫn)
     - Đối tượng (nhà nghiên cứu, lập trình viên)
   - Áp dụng quy tắc dịch thuật theo lĩnh vực:
     | Lĩnh vực | Cách tiếp cận dịch thuật |
     |----------|--------------------------|
     | Commands/Flags | Giữ nguyên (ví dụ: `/ingest --discover` → `/ingest --discover`) |
     | Thuật ngữ kỹ thuật | Giữ nguyên nếu đã được thiết lập trong lĩnh vực (ví dụ: "LoRA", "attention mechanism") |
     | Văn học thuật | Điều chỉnh theo quy ước học thuật của ngôn ngữ đích |
     | Thông báo lỗi | Dịch trong khi đảm bảo độ chính xác kỹ thuật |

3. **Xử lý các trường hợp đặc biệt**:
   - **Wikilinks**: Giữ nguyên định dạng slug, chỉ dịch display text khi phù hợp
     ```markdown
     [[flash-attention]] → [[flash-attention]] (giữ nguyên)
     [[lora-low-rank-adaptation|LoRA]] → [[lora-low-rank-adaptation|LoRA]] (giữ nguyên)
     ```
   - **Code blocks**: Giữ nguyên hoàn toàn, bao gồm cả comments
   - **JSON/YAML**: Giữ nguyên tất cả keys và enum values, chỉ dịch string values khi phù hợp
   - **Tables**: Dịch nội dung trong khi giữ nguyên căn chỉnh và định dạng
   - **Placeholders**: Giữ nguyên tất cả placeholders (ví dụ: `{slug}`, `{date}`)

### Bước 3: Kiểm Tra Sau Khi Dịch

1. **Kiểm tra Markdown**:
   - Xác minh tất cả headings có cấp độ phù hợp
   - Xác minh tất cả lists được thụt lề đúng
   - Xác minh tất cả code fences được đóng đúng
   - Xác minh tất cả tables được định dạng đúng

2. **Kiểm tra nhất quán**:
   - Kiểm tra lại tất cả từ khóa được giữ nguyên với các bản dịch hiện có
   - Xác minh không có thuật ngữ kỹ thuật nào bị dịch nhầm
   - Xác minh tất cả wikilinks dùng định dạng slug đúng

3. **Kiểm tra ngữ cảnh**:
   - Lấy mẫu các phần quan trọng để đảm bảo ý nghĩa và giọng văn được bảo toàn
   - Xác minh các hướng dẫn kỹ thuật vẫn có thể thực hiện được
   - Xác minh các lập luận học thuật duy trì được mạch logic

### Bước 4: Xuất Kết Quả

1. Nếu chỉ định `--dry-run`:
   - In nội dung đã dịch ra terminal
   - In báo cáo dịch thuật
   - Không ghi vào đĩa

2. Nếu không chỉ định `--dry-run`:
   - Ghi nội dung đã dịch vào đường dẫn đích
   - In báo cáo dịch thuật ra terminal
   - Nếu file đích đã tồn tại, tạo bản sao lưu với đuôi `.bak`

## Quy Tắc Dịch Thuật

### Phải Giữ Nguyên Không Dịch
- Commands: `/ingest`, `/exp-run`, `/paper-draft`, v.v.
- Flags: `--discover`, `--full`, `--env`, `--difficulty`, v.v.
- Paths: `wiki/papers/`, `raw/discovered/`, `experiments/code/`, v.v.
- Tên API: `DEEPXIV_TOKEN`, `SEMANTIC_SCHOLAR_API_KEY`, v.v.
- Tên field: `target_claim`, `evidence`, `confidence`, `slug`, v.v.
- Loại cạnh: `supports`, `contradicts`, `tested_by`, `invalidates`, v.v.
- Enum values: `ready`, `needs-work`, `major-revision`, `rethink`, v.v.
- Phần mở rộng file: `.md`, `.tex`, `.pdf`, `.jsonl`, v.v.
- Code identifiers: tên biến, tên hàm, tên class
- Wikilinks: định dạng `[[slug]]` phải được bảo toàn
- Placeholders: `{slug}`, `{date}`, `{score}`, v.v.

### Phải Dịch
- Văn bản mô tả giải thích khái niệm, hướng dẫn hoặc lập luận
- Cụm từ học thuật và các từ chuyển tiếp
- Thông báo lỗi và lời nhắc người dùng
- Tiêu đề phần và các mục danh sách
- Nội dung bảng (trong khi giữ nguyên định dạng)
- Nội dung blockquote

### Dịch Có Điều Kiện
- **Thuật ngữ khoa học và kỹ thuật**: Giữ nguyên tiếng Anh. Cộng đồng khoa học Việt Nam dùng trực tiếp các thuật ngữ gốc (gradient descent, attention mechanism, loss function, backpropagation, v.v.) — dịch ra sẽ gây khó hiểu hơn.
  - Ví dụ (Tiếng Anh → Tiếng Việt):
    - "attention mechanism" → "attention mechanism" (giữ nguyên)
    - "gradient descent" → "gradient descent" (giữ nguyên)
    - "loss function" → "loss function" (giữ nguyên)
- **Từ viết tắt**: Giữ nguyên nếu thường dùng trong lĩnh vực (ví dụ: "LoRA", "SOTA"), ngược lại mở rộng và dịch.
- **Citations**: Giữ nguyên citation keys không dịch, nhưng dịch văn bản xung quanh nếu phù hợp.

## Đảm Bảo Nhất Quán

1. **Cơ sở dữ liệu thuật ngữ**: Duy trì cơ sở dữ liệu nội bộ về các thuật ngữ đã dịch, cập nhật với mỗi lần dịch:
   ```json
   {
     "commands": {
       "/ingest": {"en": "/ingest", "vi": "/ingest", "zh": "/ingest"},
       "/exp-run": {"en": "/exp-run", "vi": "/exp-run", "zh": "/exp-run"}
     },
     "flags": {
       "--discover": {"en": "--discover", "vi": "--discover", "zh": "--discover"},
       "--full": {"en": "--full", "vi": "--full", "zh": "--full"}
     },
     "terms": {
       "confidence": {"en": "confidence", "vi": "độ tin cậy", "zh": "置信度"},
       "evidence": {"en": "evidence", "vi": "bằng chứng", "zh": "证据"}
     }
   }
   ```

2. **Kiểm tra nhất quán**: Trước khi dịch bất kỳ thuật ngữ nào, kiểm tra với cơ sở dữ liệu thuật ngữ:
   - Nếu thuật ngữ đã có trong cơ sở dữ liệu, dùng bản dịch đã thiết lập
   - Nếu thuật ngữ chưa có, xác định nên dịch hay giữ nguyên, sau đó thêm vào cơ sở dữ liệu
   - Đánh dấu bất kỳ xung đột nào với các bản dịch hiện có

3. **Nhất quán toàn dự án**:
   - Khi dịch một thuật ngữ lần đầu tiên, tìm kiếm tất cả các file hiện có trong ngôn ngữ đích để phát hiện xung đột tiềm ẩn
   - Duy trì nhất quán với các thuật ngữ đã được thiết lập trong:
     - `i18n/<lang>/CLAUDE.md`
     - `docs/runtime-page-templates.md`
     - Tài liệu skill hiện có

## Xử Lý Lỗi

- **File nguồn không tìm thấy**: Liệt kê các file tương tự trong thư mục nguồn
- **Mã ngôn ngữ không hợp lệ**: Liệt kê các mã hợp lệ (`en`, `vi`, `zh`)
- **File đích đã tồn tại**: Nhắc xác nhận trừ khi chỉ định `--force`
- **Lỗi phân tích Markdown**: Cố gắng khôi phục cấu trúc, đánh dấu các phần có vấn đề
- **Xung đột thuật ngữ**: Đánh dấu xung đột và đề xuất các lựa chọn giải quyết
- **Dịch vụ dịch thuật không khả dụng**: Dùng bản dịch cục bộ với cảnh báo

## Phụ Thuộc

### Công Cụ (qua Bash)
- `grep` — tìm kiếm các bản dịch hiện có
- `diff` — so sánh với các file hiện có

### Claude Code Native
- `Read` — đọc file nguồn và các bản dịch hiện có
- `Write` — ghi file đã dịch
- `Glob` — tìm kiếm các bản dịch hiện có

### Shared References
- Không có

## Ràng Buộc

- **Yêu cầu bảo toàn**:
  - Không bao giờ dịch commands, flags, paths, tên API, tên field hoặc enum values
  - Không bao giờ sửa đổi cấu trúc Markdown hoặc code blocks
  - Không bao giờ thay đổi ý nghĩa hoặc độ chính xác kỹ thuật của nội dung
  - Không bao giờ phá vỡ các chức năng hoặc tham chiếu hiện có

- **Yêu cầu nhất quán**:
  - Duy trì nhất quán với các bản dịch hiện có trong ngôn ngữ đích
  - Cập nhật cơ sở dữ liệu thuật ngữ với các bản dịch mới
  - Đánh dấu bất kỳ xung đột nào với thuật ngữ hiện có

- **Yêu cầu an toàn**:
  - Luôn tạo bản sao lưu trước khi ghi đè file hiện có
  - Không bao giờ sửa đổi file ngoài cấu trúc thư mục i18n
  - Không bao giờ dịch file không phải là tài liệu skill hoặc shared references

- **Yêu cầu hiệu suất**:
  - Với các file lớn (>50KB), dịch theo từng phần để tránh giới hạn context window
  - Cache cơ sở dữ liệu thuật ngữ giữa các lần dịch
  - Cung cấp cập nhật tiến trình cho các bản dịch lớn

## Ví Dụ Sử Dụng

```bash
# Dịch skill ingest sang tiếng Việt
/translated-engine i18n/en/skills/ingest/SKILL.md vi

# Xem trước bản dịch skill exp-design sang tiếng Trung mà không ghi
/translated-engine i18n/en/skills/exp-design/SKILL.md zh --dry-run

# Ghi đè bản dịch tiếng Việt hiện có của skill review
/translated-engine i18n/en/skills/review/SKILL.md vi --force
```

## Ví Dụ Báo Cáo Dịch Thuật

```
Báo cáo dịch thuật: i18n/en/skills/ingest/SKILL.md → i18n/vi/skills/ingest/SKILL.md

Thuật ngữ giữ nguyên (24):
- Commands: /ingest, /discover
- Flags: --discover, --full, --env
- Paths: wiki/papers/, raw/discovered/, experiments/code/
- APIs: DEEPXIV_TOKEN, SEMANTIC_SCHOLAR_API_KEY
- Fields: target_claim, evidence, confidence, slug
- Loại cạnh: supports, contradicts, tested_by
- Wikilinks: [[slug]], [[flash-attention]]

Kiểm tra Markdown:
- Headings: OK (5/5)
- Lists: OK (12/12)
- Tables: OK (2/2)
- Code blocks: OK (4/4)

Cảnh báo nhất quán (1):
- Thuật ngữ "confidence" trước đây được dịch là "độ tin cậy" trong i18n/vi/skills/exp-eval/SKILL.md
  → Sử dụng bản dịch đã thiết lập

Tóm tắt dịch thuật:
- Từ đã dịch: 1.248
- Thuật ngữ kỹ thuật giữ nguyên: 24
- Thành phần Markdown giữ nguyên: 38
- Thời gian dịch: 42s
```
