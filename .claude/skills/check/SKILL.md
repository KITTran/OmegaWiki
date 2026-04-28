---
description: Quét toàn bộ wiki để phát hiện các vấn đề về tình trạng và tạo báo cáo khuyến nghị sửa chữa theo cấp độ (bao gồm tất cả 8 loại thực thể + tính nhất quán của đồ thị)
---

# /check

> Quét toàn bộ wiki để phát hiện các vấn đề về cấu trúc, liên kết, trường và tình trạng đồ thị, đồng thời tạo báo cáo khuyến nghị sửa chữa theo cấp độ.
> Bao gồm tất cả 8 loại thực thể, bao gồm tính hợp lý của độ tin cậy khẳng định, tính đầy đủ của lý do thất bại ý tưởng,
> tính hợp lệ của liên kết thí nghiệm-khẳng định và tính nhất quán của cạnh đồ thị.

## Đầu Vào

- Thư mục wiki đầy đủ (mặc định `wiki/`)
- Tùy chọn: cờ `--json` (đầu ra định dạng JSON qua tools/lint.py)
- Tùy chọn: cờ `--fix` (tự động sửa các vấn đề xác định)
- Tùy chọn: `--fix --dry-run` (xem trước các sửa chữa mà không áp dụng chúng)
- Tùy chọn: cờ `--suggest` (hiển thị khuyến nghị cho các vấn đề không thể tự động sửa)

## Đầu Ra

- Báo cáo lint (báo cáo trực tiếp cho người dùng)
- Ghi tệp tùy chọn: `wiki/outputs/lint-report-{date}.md`

## Tương Tác Wiki

### Đọc
- `wiki/papers/*.md` — các trường và liên kết của trang bài báo
- `wiki/concepts/*.md` — các trường và liên kết của trang khái niệm
- `wiki/topics/*.md` — các trường và liên kết của trang chủ đề
- `wiki/people/*.md` — các trường và liên kết của trang người
- `wiki/ideas/*.md` — trạng thái ý tưởng, failure_reason, origin_gaps
- `wiki/experiments/*.md` — trạng thái thí nghiệm, target_claim, outcome
- `wiki/claims/*.md` — độ tin cậy khẳng định, trạng thái, evidence, source_papers
- `wiki/Summary/*.md` — các trường của trang khảo sát
- `wiki/graph/edges.jsonl` — kiểm tra tính nhất quán của cạnh đồ thị
- `wiki/index.md` — kiểm tra tính đầy đủ của trang

### Ghi
- Không trực tiếp sửa đổi nội dung wiki (chỉ báo cáo, không sửa)
- `wiki/log.md` — ghi lại tóm tắt kết quả lint qua `tools/research_wiki.py log`

## Quy Trình Làm Việc

**Điều kiện tiên quyết**: xác nhận thư mục làm việc là thư mục gốc dự án wiki (thư mục chứa `wiki/`, `raw/`, `tools/`).
Đặt `WIKI_ROOT=wiki/`.

### Bước 1: Chạy Công Cụ Lint Tự Động

**Chế độ mặc định (chỉ báo cáo)**:
```bash
python3 tools/lint.py --wiki-dir wiki/ --json
```

**Chế độ tự động sửa** (khi người dùng chỉ định `--fix`):
```bash
python3 tools/lint.py --wiki-dir wiki/ --fix --json
```
Tự động sửa các vấn đề xác định (hoàn thiện liên kết ngược xref, điền các trường thiếu bằng giá trị mặc định) và xuất ra báo cáo sửa chữa.

**Chế độ xem trước** (khi người dùng chỉ định `--fix --dry-run`):
```bash
python3 tools/lint.py --wiki-dir wiki/ --fix --dry-run --json
```
Xem trước những gì sẽ được sửa mà không áp dụng bất kỳ thay đổi nào.

Phân tích cú pháp đầu ra JSON để lấy tất cả các vấn đề được phát hiện tự động (và kết quả sửa chữa).

### Bước 2: Tính Đầy Đủ Cấu Trúc (phạm vi tự động)

Công cụ tự động kiểm tra:

1. **Liên kết wiki bị hỏng**: tệp đích `[[slug]]` không tồn tại
2. **Trang mồ côi**: các trang không có liên kết đến
3. **Các trường bắt buộc bị thiếu** (tất cả 8 loại thực thể):
   - papers: title, slug, tags, importance
   - concepts: title, tags, maturity, key_papers
   - topics: title, tags
   - people: name, tags
   - Summary: title, scope, key_topics
   - ideas: title, slug, status, origin, tags, priority
   - experiments: title, slug, status, target_claim, hypothesis, tags
   - claims: title, slug, status, confidence, tags, source_papers, evidence

### Bước 3: Xác Thực Giá Trị Trường (phạm vi tự động)

1. **Kiểm tra giá trị enum**:
   - papers.importance ∈ {1,2,3,4,5}
   - concepts.maturity ∈ {stable, active, emerging, deprecated}
   - ideas.status ∈ {proposed, in_progress, tested, validated, failed}
   - ideas.priority ∈ {1,2,3,4,5}
   - experiments.status ∈ {planned, running, completed, abandoned}
   - experiments.outcome ∈ {succeeded, failed, inconclusive}
   - claims.status ∈ {proposed, weakly_supported, supported, challenged, deprecated}
2. **Độ tin cậy khẳng định** ∈ [0.0, 1.0]
3. **Idea failure_reason**: phải không rỗng khi status=failed (bộ nhớ chống lặp lại)
4. **Experiment target_claim**: khẳng định được tham chiếu phải tồn tại

### Bước 4: Tính Đối Xứng Liên Kết Chéo (phạm vi tự động)

Kiểm tra tất cả các quy tắc liên kết hai chiều được định nghĩa trong CLAUDE.md:

| Liên kết xuôi | Liên kết ngược được kiểm tra |
|----------|---------------|
| concepts.key_papers → papers | papers.Related chứa liên kết khái niệm |
| papers → people (wikilink) | people.Key papers chứa bài báo |
| claims.source_papers → papers | papers.Related chứa liên kết khẳng định |
| ideas.origin_gaps → claims | claims.Linked ideas chứa ý tưởng |
| experiments.target_claim → claims | claims.evidence chứa thí nghiệm |

### Bước 5: Tính Nhất Quán Cạnh Đồ Thị (phạm vi tự động)

1. **Tính hợp lệ định dạng JSON**: mọi dòng là JSON hợp lệ
2. **Các trường bắt buộc**: mỗi cạnh có from, to, type
3. **Tính hợp lệ loại cạnh**: type ∈ {extends, contradicts, supports, inspired_by, tested_by, invalidates, supersedes, addresses_gap, derived_from}
4. **Các nút treo**: các trang wiki được tham chiếu bởi from/to phải tồn tại

### Bước 6: Chất Lượng Nội Dung (hỗ trợ bởi LLM)

Các mục có thể phát hiện bởi công cụ tự động:
1. Các bài báo với importance=5 không có trang khái niệm tham chiếu đến chúng
2. Các khái niệm với maturity=stable chỉ có 1 key_paper
3. Các chủ đề có phần Open problems trống

Các đánh giá bổ sung bởi LLM (yêu cầu đọc nội dung):
1. **Phát hiện khái niệm gần trùng lặp**: quét tất cả tiêu đề trang khái niệm + bí danh và đánh giá xem có cặp nào giống nhau về ngữ nghĩa hoặc rất tương tự không (ví dụ: "attention mechanism" và "self-attention"). Đưa ra khuyến nghị hợp nhất cho các trùng lặp nghi ngờ.
2. Phát hiện tuyên bố mâu thuẫn (mô tả không nhất quán về cùng một sự kiện trên các trang khác nhau)
3. Các bản ghi SOTA không được cập nhật trong hơn 6 tháng
4. Recent work của people không được cập nhật trong hơn 6 tháng
5. Độ tin cậy của khẳng định không nhất quán với số lượng/sức mạnh của bằng chứng
6. Ý tưởng ưu tiên cao bị kẹt ở trạng thái proposed trong thời gian dài

### Bước 7: Tạo Báo Cáo

Đầu ra được sắp xếp theo mức độ ưu tiên:

```
## Báo Cáo Lint — YYYY-MM-DD

**Tóm tắt**: N 🔴, M 🟡, K 🔵

### 🔴 Sửa Ngay Lập Tức
1. [tệp] — {mô tả vấn đề}

### 🟡 Khuyến Nghị Sửa Chữa
1. [tệp] — {mô tả vấn đề}

### 🔵 Cải Tiến Tùy Chọn
1. [tệp] — {mô tả vấn đề}
```

Phân loại:
- **🔴 Sửa Ngay Lập Tức**: liên kết bị hỏng, trường bắt buộc bị thiếu, giá trị enum không hợp lệ, ý tưởng thất bại không có failure_reason, JSON không hợp lệ trong edges, độ tin cậy ngoài phạm vi
- **🟡 Khuyến Nghị Sửa Chữa**: bất đối xứng xref, cạnh đồ thị treo, tham chiếu khẳng định bị hỏng, loại cạnh không xác định
- **🔵 Cải Tiến Tùy Chọn**: trang mồ côi, gợi ý chất lượng, phần trống

Ghi nhật ký:
```bash
python3 tools/research_wiki.py log wiki/ "check | báo cáo: N 🔴, M 🟡, K 🔵"
```

## Các Ràng Buộc

- **Chỉ báo cáo theo mặc định**: không có `--fix`, chỉ báo cáo, không sửa đổi
- **`--fix` chỉ sửa các vấn đề xác định**: hoàn thiện liên kết ngược xref, điền các trường thiếu bằng giá trị mặc định an toàn. Các vấn đề không xác định xuất ra khuyến nghị (`--suggest`) để người dùng phê duyệt
- **raw/ là chỉ đọc**: không sửa đổi các tệp dưới raw/
- **graph/ là chỉ đọc**: lint không sửa đổi các tệp đồ thị, chỉ kiểm tra tính nhất quán
- **Các đánh giá của LLM được gắn nhãn theo nguồn**: các kiểm tra tự động và đánh giá của LLM được phân biệt rõ ràng trong báo cáo
- **Tính bất biến**: chạy nhiều lần tạo ra cùng một kết quả (trừ khi nội dung wiki thay đổi)

## Xử Lý Lỗi

- **wiki/ không tồn tại**: báo cáo lỗi và đề xuất chạy `/init`
- **graph/edges.jsonl không tồn tại**: bỏ qua kiểm tra đồ thị, ghi chú trong báo cáo
- **Thư mục con thiếu**: bỏ qua kiểm tra cho các thư mục thiếu, liệt kê các thư mục thiếu trong báo cáo

## Phụ Thuộc

### Công cụ (qua Bash)
- `python3 tools/lint.py --wiki-dir wiki/ [--json] [--fix] [--dry-run] [--suggest]` — kiểm tra cấu trúc tự động + sửa (phụ thuộc cốt lõi)
- `python3 tools/research_wiki.py log wiki/ "<message>"` — thêm nhật ký
- `python3 tools/research_wiki.py stats wiki/` — lấy thống kê (tùy chọn, cho báo cáo)