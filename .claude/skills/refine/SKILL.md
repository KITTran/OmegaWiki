---
description: Vòng lặp cải thiện đa vòng mục đích chung — gọi /review liên tục trên bất kỳ thực thể nghiên cứu nào, phân tích phản hồi, áp dụng sửa chữa, cập nhật wiki, cho tới khi đạt được điểm mục tiêu
argument-hint: <artifact-slug-or-path> [--max-rounds N] [--target-score N] [--difficulty standard|hard|adversarial] [--focus method|evidence|writing|completeness]
---

# /refine

> Vòng lặp cải thiện đa vòng mục đích chung cho bất kỳ thực thể nghiên cứu nào
> (ý tưởng, đề xuất, kế hoạch thí nghiệm, bản thảo bài báo).
> Mỗi vòng gọi /review để lấy phản hồi có cấu trúc → trích xuất các mục hành động → Claude sửa đổi thực thể →
> cập nhật các thực thể wiki → đánh giá lại, cho đến khi điểm đạt mục tiêu hoặc hết số vòng tối đa.
> Xuất ra lịch sử cải thiện và điểm đánh giá cuối cùng.

## Đầu Vào

- `artifact`: tạo tác cần cải thiện, một trong các mục sau:
  - slug của trang wiki (tìm kiếm trong ideas/experiments/claims/outputs/)
  - đường dẫn tệp (ví dụ: `wiki/outputs/paper-draft-v1.md`)
- `--max-rounds N` *(tùy chọn, mặc định 4)*: số vòng lặp tối đa
- `--target-score N` *(tùy chọn, mặc định 8)*: điểm đánh giá mục tiêu (1-10); dừng khi đạt được
- `--difficulty` *(tùy chọn, mặc định `hard`)*: mức độ khó chuyển đến /review
- `--focus` *(tùy chọn)*: trọng tâm đánh giá chuyển đến /review

## Đầu Ra

- **Tạo tác đã cải thiện** (trang wiki hoặc tệp, được cập nhật tại chỗ)
- **Cập nhật thực thể wiki** (nếu đánh giá phát hiện khẳng định cần củng cố hoặc xác định lỗ hổng)
- **BÁO_CÁO_REFINE** (xuất ra terminal):
  - Lịch sử điểm qua tất cả các vòng
  - Danh sách tích lũy các vấn đề đã sửa
  - Điểm đánh giá cuối cùng và kết luận
  - Các vấn đề chưa giải quyết (nếu có)

## Tương Tác Wiki

### Đọc

- `wiki/ideas/*.md` — nếu tạo tác là một ý tưởng
- `wiki/experiments/*.md` — nếu tạo tác là một kế hoạch thí nghiệm
- `wiki/claims/*.md` — các khẳng định được tham chiếu bởi đánh giá
- `wiki/papers/*.md` — các bài báo được tham chiếu bởi đánh giá
- `wiki/outputs/*.md` — nếu tạo tác là bản thảo bài báo hoặc đầu ra
- `wiki/graph/context_brief.md` — ngữ cảnh toàn cục chuyển đến /review
- `wiki/graph/open_questions.md` — kiểm tra xem có lỗ hổng mới cần ghi lại không

### Ghi

- `wiki/ideas/{slug}.md` — nếu tạo tác là ý tưởng, sửa các vấn đề được phát hiện bởi đánh giá
- `wiki/experiments/{slug}.md` — nếu tạo tác là kế hoạch thí nghiệm
- `wiki/claims/{slug}.md` — nếu đánh giá phát hiện khẳng định cần cập nhật (điều chỉnh độ tin cậy, ghi chú bằng chứng)
- `wiki/outputs/*.md` — nếu tạo tác là bản thảo bài báo hoặc đầu ra
- `wiki/graph/edges.jsonl` — nếu phát hiện mối quan hệ mới trong quá trình sửa chữa
- `wiki/graph/context_brief.md` — xây dựng lại sau mỗi vòng nếu có thay đổi wiki
- `wiki/graph/open_questions.md` — xây dựng lại sau mỗi vòng nếu có thay đổi wiki
- `wiki/log.md` — thêm nhật ký hoạt động

### Các cạnh đồ thị được tạo

- Phụ thuộc vào nội dung sửa chữa; có thể thêm: `supports`, `addresses_gap`, `inspired_by`, v.v.

## Quy Trình Làm Việc

**Điều kiện tiên quyết**: xác nhận thư mục làm việc là thư mục gốc dự án wiki (chứa `wiki/`, `raw/`, `tools/`).

### Bước 1: Khởi Tạo

1. **Xác định vị trí tạo tác**:
   - Nếu là slug: tìm kiếm tuần tự trong `wiki/ideas/`, `wiki/experiments/`, `wiki/claims/`, `wiki/outputs/`, `wiki/papers/` cho `{slug}.md`
   - Nếu là đường dẫn tệp: đọc trực tiếp
   - Ghi lại loại và đường dẫn của tạo tác
2. **Đọc nội dung hiện tại**: tải toàn bộ văn bản tạo tác
3. **Khởi tạo các biến theo dõi**:
   - `round = 0`
   - `score_history = []`
   - `fixed_issues = []`
   - `unresolved_issues = []`
   - `wiki_changes = []`

### Bước 2: Vòng Lặp Lặp Đi Lặp Lại

Lặp lại các bước sau cho đến khi điều kiện kết thúc được đáp ứng:

**Vòng N (N = 1, 2, ..., max-rounds):**

#### 2a. Gọi /review

```
Skill: review
Args: "<artifact-path-or-content>" --difficulty {difficulty} --focus {focus}
```

Phân tích đầu ra đánh giá và trích xuất:
- `score` (1-10)
- `verdict` (ready / needs-work / major-revision / rethink)
- `weaknesses` (theo mức độ nghiêm trọng: critical / major / minor)
- `actionable_items` (danh sách được xếp hạng)
- `wiki_entity_mapping` (các khẳng định cần hỗ trợ, các lỗ hổng được xác định)

#### 2b. Kiểm Tra Điều Kiện Kết Thúc

- **Đạt điểm mục tiêu**: `score >= target-score` → kết thúc, xuất báo cáo cuối cùng
- **Không cải thiện điểm trong hai vòng liên tiếp**: `score_history[-1] == score_history[-2]` → kết thúc (đã hội tụ)
- **Đạt số vòng tối đa**: `round >= max-rounds` → kết thúc
- **verdict == ready**: → kết thúc
- **verdict == rethink và round == 1**: → kết thúc và đề xuất thiết kế lại (không lặp lại trên một tạo tác cấp độ rethink)

#### 2c. Phân Loại Các Mục Có Thể Thực Hiện và Áp Dụng Sửa Chữa

Phân loại và xử lý từng mục có thể thực hiện:

**Loại A — Vấn đề về phương pháp/nội dung (Claude sửa trực tiếp):**
- Mô tả phương pháp quá mơ hồ → thêm chi tiết
- Thiếu phân tích so sánh → thêm so sánh với baseline
- Logic lập luận không đầy đủ → thêm các bước lập luận
- Diễn đạt không rõ ràng → viết lại các đoạn liên quan
- → Chỉnh sửa trực tiếp tệp tạo tác

**Loại B — Lỗ hổng tri thức wiki (đề xuất thao tác bên ngoài):**
- Bằng chứng khẳng định không đủ → đề xuất chạy `/exp-design` hoặc `/ingest`
- Thiếu trích dẫn công trình liên quan → đề xuất chạy `/ingest` để thêm bài báo
- Cần xác thực thực nghiệm → đề xuất chạy `/exp-run`
- → Ghi lại trong `unresolved_issues`, liệt kê các thao tác được đề xuất trong báo cáo
- → Nếu cần điều chỉnh độ tin cậy của khẳng định, cập nhật trực tiếp `wiki/claims/{slug}.md`

**Loại C — Cập nhật trạng thái khẳng định (Claude sửa wiki):**
- Đánh giá cho biết độ tin cậy của một khẳng định nên được hạ thấp → cập nhật trang khẳng định
- Đánh giá phát hiện lỗ hổng mới → ghi lại vào gap_map (thông qua rebuild)
- Đánh giá phát hiện mối quan hệ mới → thêm cạnh đồ thị
- → Cập nhật các trang wiki liên quan, ghi lại trong `wiki_changes`

**Loại D — Ngoài phạm vi (bỏ qua):**
- Cần dữ liệu thực nghiệm mới → không thể giải quyết trong vòng lặp refine
- Cần đánh giá của chuyên gia lĩnh vực → đánh dấu là chưa giải quyết
- → Ghi lại trong `unresolved_issues`

#### 2d. Cập Nhật Theo Dõi

- `score_history.append(score)`
- `fixed_issues.extend(category_A_items + category_C_items)`
- `unresolved_issues.extend(category_B_items + category_D_items)`
- `wiki_changes.extend(category_C_changes)`
- `round += 1`

#### 2e. Xây Dựng Lại Dữ Liệu Phái Sinh (nếu wiki đã thay đổi)

Nếu vòng này có thay đổi wiki (Loại C):
```bash
python3 tools/research_wiki.py rebuild-context-brief wiki/
python3 tools/research_wiki.py rebuild-open-questions wiki/
```

### Bước 3: Báo Cáo Cuối Cùng

Sau khi vòng lặp kết thúc, tạo BÁO_CÁO_REFINE:

```markdown
# Báo Cáo Vòng Lặp Refine: {tiêu đề tạo tác}

## Tóm Tắt
- **Tạo tác**: {slug hoặc đường dẫn}
- **Số vòng**: {N} / {max-rounds}
- **Lịch sử điểm**: {score_history, ví dụ: 5 → 6 → 7 → 8}
- **Điểm cuối cùng**: {final_score}/10
- **Kết luận cuối cùng**: {verdict}
- **Lý do kết thúc**: {đạt mục tiêu / hội tụ / đạt số vòng tối đa / rethink}

## Các Vấn Đề Đã Sửa ({số lượng})

| Vòng | Vấn Đề | Mức Độ Nghiêm Trọng | Sửa Chữa Áp Dụng |
|-------|--------|---------------------|------------------|
| 1 | Mô tả phương pháp quá mơ hồ | lớn | Thêm các bước thuật toán cụ thể |
| 1 | Độ tin cậy của khẳng định quá cao | lớn | Giảm độ tin cậy [[claim-slug]] từ 0.8→0.6 |
| 2 | Thiếu thiết kế ablation | nhỏ | Thêm kế hoạch ablation |

## Các Thay Đổi Wiki Đã Thực Hiện

| Trang | Thay Đổi | Vòng |
|-------|----------|-------|
| `wiki/claims/{slug}.md` | độ tin cậy 0.8 → 0.6 | 1 |
| `wiki/graph/edges.jsonl` | +1 cạnh (addresses_gap) | 2 |

## Các Vấn Đề Chưa Giải Quyết ({số lượng})

| Vấn Đề | Mức Độ Nghiêm Trọng | Hành Động Đề Xuất |
|--------|---------------------|-------------------|
| Thiếu xác thực thực nghiệm | nghiêm trọng | Chạy `/exp-design {slug}` |
| Thiếu bài báo so sánh | lớn | Chạy `/ingest` cho {tiêu-đề-bài-báo} |

## Bước Tiếp Theo
- {dựa trên verdict và các vấn đề chưa giải quyết}
```

Thêm nhật ký:
```bash
python3 tools/research_wiki.py log wiki/ \
  "refine | {artifact-slug} | {N} vòng | điểm {initial}→{final} | verdict: {verdict}"
```

## Các Ràng Buộc

- **Mỗi vòng phải thể hiện tiến triển thực chất**: nếu điểm không thay đổi trong hai vòng liên tiếp, kết thúc (ngăn chặn vòng lặp vô hạn)
- **Không lặp lại trên rethink**: nếu verdict của vòng đầu tiên là rethink, kết thúc ngay lập tức và đề xuất thiết kế lại
- **Các sửa đổi wiki chỉ giới hạn trong đề xuất của đánh giá**: refine chỉ sửa đổi các thực thể wiki được đề xuất rõ ràng bởi đánh giá; không mở rộng phạm vi chủ động
- **Các vấn đề chưa giải quyết phải được liệt kê**: không bỏ qua các vấn đề không thể giải quyết trong vòng lặp
- **Bảo toàn lịch sử cải thiện**: score_history và fixed_issues được ghi lại đầy đủ; không loại bỏ trạng thái trung gian
- **Chuyển tiếp các tham số đánh giá**: --difficulty và --focus được chuyển tiếp đến /review; duy trì tiêu chuẩn đánh giá nhất quán
- **Cập nhật tạo tác tại chỗ**: các sửa chữa sửa đổi trực tiếp tệp gốc; không tạo bản sao

## Xử Lý Lỗi

- **Không tìm thấy tạo tác**: nhắc người dùng kiểm tra slug hoặc đường dẫn, liệt kê các trang ứng viên có khả năng
- **Gọi /review thất bại**: thử lại một lần; nếu vẫn thất bại, kết thúc vòng lặp và xuất lịch sử cải thiện đã hoàn thành cho đến thời điểm đó
- **Ghi wiki thất bại**: ghi lại lỗi, tiếp tục vòng tiếp theo (các thay đổi wiki được hạ cấp thành chưa giải quyết)
- **Điểm vòng đầu tiên đã >= điểm mục tiêu**: kết thúc ngay lập tức, xuất báo cáo (không cần cải thiện)
- **Tất cả các vấn đề đều thuộc Loại B/D**: không thể sửa trong vòng lặp; kết thúc và xuất danh sách các vấn đề chưa giải quyết

## Phụ Thuộc

### Công cụ (thông qua Bash)

- `python3 tools/research_wiki.py rebuild-context-brief wiki/` — xây dựng lại query_pack
- `python3 tools/research_wiki.py rebuild-open-questions wiki/` — xây dựng lại gap_map
- `python3 tools/research_wiki.py add-edge wiki/ ...` — thêm cạnh đồ thị (nếu cần)
- `python3 tools/research_wiki.py log wiki/ "<message>"` — thêm mục nhật ký

### Kỹ Năng (thông qua công cụ Skill)

- `/review` — đánh giá mỗi vòng (phụ thuộc cốt lõi)

### Claude Code Gốc

- `Read` — đọc tạo tác và trang wiki
- `Edit` — sửa nội dung tạo tác
- `Glob` — tìm tạo tác và các trang wiki liên quan

### Tài Liệu Tham Khảo Chung

- `.claude/skills/shared-references/cross-model-review.md` — phụ thuộc gián tiếp thông qua /review