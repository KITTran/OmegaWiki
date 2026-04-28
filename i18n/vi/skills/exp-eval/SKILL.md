---
description: Cổng phán quyết thí nghiệm — Review LLM đánh giá độc lập kết quả → 4 đường dẫn phán quyết → tự động cập nhật độ tin cậy của khẳng định, trạng thái ý tưởng, cạnh đồ thị
argument-hint: "<slug-thí-nghiệm> [--auto]"
---

# /exp-eval

> Chuyển đổi kết quả thí nghiệm đã hoàn thành thành các cập nhật kiến thức wiki.
> Review LLM đóng vai trò như một giám khảo công bằng (tuân theo cross-model-review), đánh giá độc lập tác động của kết quả thí nghiệm đến khẳng định mục tiêu.
> Bốn đường dẫn phán quyết: supported → khẳng định↑ + ý tưởng được xác thực / partially_supported → thí nghiệm bổ sung /
> not_supported → khẳng định↓ + ý tưởng thất bại / inconclusive → gỡ lỗi.
> Tự động cập nhật độ tin cậy và bằng chứng của khẳng định, trạng thái ý tưởng và các cạnh đồ thị.

## Đầu Vào

- `experiment`: slug từ wiki/experiments/ (trạng thái phải là `completed`)
- `--auto` *(tùy chọn)*: chế độ tự động — không tạm dừng để xác nhận người dùng trước khi cập nhật wiki (được sử dụng khi được gọi bởi /research)

## Đầu Ra

- `wiki/claims/{slug}.md` — cập nhật độ tin cậy, trạng thái, danh sách bằng chứng
- `wiki/ideas/{slug}.md` — cập nhật trạng thái (validated/failed), pilot_result, failure_reason
- `wiki/experiments/{slug}.md` — điền phần `## Cập Nhật Khẳng Định`
- `wiki/graph/edges.jsonl` — thêm các cạnh supports/invalidates mới
- `wiki/graph/context_brief.md` — xây dựng lại
- `wiki/graph/open_questions.md` — xây dựng lại
- `wiki/log.md` — thêm mục nhật ký
- **VERDICT_REPORT** *(in ra terminal)* — kết quả phán quyết, tóm tắt thay đổi wiki, gợi ý bước tiếp theo

## Tương Tác Wiki

### Đọc

- `wiki/experiments/{slug}.md` — kết quả thí nghiệm: outcome, key_result, metrics, toàn bộ phần Kết Quả
- `wiki/claims/{target-claim}.md` — trạng thái hiện tại của khẳng định mục tiêu: status, confidence, danh sách evidence
- `wiki/ideas/{linked-idea}.md` — trạng thái hiện tại của ý tưởng liên kết
- `wiki/experiments/*.md` — các thí nghiệm khác trên cùng khẳng định (đánh giá tổng hợp)
- `wiki/graph/context_brief.md` — ngữ cảnh toàn cục
- `.claude/skills/shared-references/cross-model-review.md` — nguyên tắc độc lập của người đánh giá

### Ghi

- `wiki/claims/{target-claim}.md` — cập nhật status, confidence, evidence, date_updated
- `wiki/ideas/{linked-idea}.md` — cập nhật status, pilot_result, failure_reason, date_resolved
- `wiki/experiments/{slug}.md` — điền phần `## Cập Nhật Khẳng Định`
- `wiki/graph/edges.jsonl` — thêm các cạnh supports hoặc invalidates
- `wiki/graph/context_brief.md` — xây dựng lại
- `wiki/graph/open_questions.md` — xây dựng lại
- `wiki/log.md` — thêm nhật ký hoạt động

### Các cạnh đồ thị được tạo

- `supports`: thí nghiệm → khẳng định (thí nghiệm hỗ trợ khẳng định) — phán quyết = supported hoặc partially_supported
- `invalidates`: thí nghiệm → khẳng định (thí nghiệm bác bỏ khẳng định) — phán quyết = not_supported

## Quy Trình Làm Việc

**Điều kiện tiên quyết**:
1. Xác nhận thư mục làm việc là thư mục gốc dự án wiki (thư mục chứa `wiki/`, `raw/`, `tools/`)
2. Xác nhận trạng thái thí nghiệm == `completed` (các thí nghiệm chưa hoàn thành không thể đánh giá)

### Bước 1: Tải Ngữ Cảnh

1. **Đọc trang thí nghiệm** `wiki/experiments/{slug}.md`:
   - outcome (succeeded/failed/inconclusive)
   - key_result
   - slug target_claim
   - slug linked_idea
   - metrics và toàn bộ phần Kết Quả
   - hypothesis

2. **Đọc khẳng định mục tiêu** `wiki/claims/{target-claim}.md`:
   - Trạng thái và độ tin cậy hiện tại
   - Danh sách bằng chứng hiện có
   - Điều kiện và phạm vi

3. **Đọc ý tưởng liên kết** `wiki/ideas/{linked-idea}.md` (nếu tồn tại):
   - Trạng thái hiện tại
   - Giả thuyết

4. **Tải các thí nghiệm khác trên cùng khẳng định**:
   - Glob: `wiki/experiments/*.md`, lọc target_claim == cùng khẳng định
   - Tóm tắt kết quả thí nghiệm hiện có (để đánh giá độ tin cậy tổng hợp của khẳng định)

5. **Đọc ngữ cảnh toàn cục**:
   - `wiki/graph/context_brief.md`

6. **Đọc cross-model-review.md**: xác nhận nguyên tắc độc lập của Review LLM

### Bước 2: Phán Quyết Review LLM (Phán Quyết Chéo Mô Hình)

**Tuân theo cross-model-review.md**: không gửi đánh giá trước của Claude đến Review LLM.

```
mcp__llm-review__chat:
  system: "Bạn là một giám khảo khoa học công bằng đánh giá liệu kết quả thí nghiệm
           có hỗ trợ hay bác bỏ một khẳng định nghiên cứu hay không. Hãy nghiêm ngặt và khách quan.
           Xem xét: ý nghĩa thống kê, kích thước hiệu ứng, tính hợp lệ của thí nghiệm,
           các yếu tố gây nhiễu tiềm ẩn, và liệu kết quả có thể khái quát hóa ngoài
           thiết lập cụ thể được kiểm tra hay không."
  message: |
    ## Khẳng Định Đang Kiểm Tra
    Tiêu đề: {tiêu đề khẳng định}
    Phát biểu: {phát biểu khẳng định từ phần ## Phát biểu}
    Trạng thái hiện tại: {status}
    Độ tin cậy hiện tại: {confidence}
    Điều kiện: {điều kiện và phạm vi}

    ## Thí Nghiệm
    Tiêu đề: {tiêu đề thí nghiệm}
    Giả thuyết: {hypothesis}
    Thiết lập: {mô hình, tập dữ liệu, phần cứng, framework}
    Chỉ số: {danh sách chỉ số}

    ## Kết Quả
    {toàn bộ phần Kết Quả từ trang thí nghiệm}

    ## Phát Hiện Chính
    {key_result}

    ## Các Thí Nghiệm Khác Trên Khẳng Định Này
    {tóm tắt kết quả của các thí nghiệm khác trên cùng khẳng định, nếu có}

    ## Nhiệm Vụ Của Bạn
    Đưa ra phán quyết của bạn:
    1. **Phán quyết**: Một trong: supported / partially_supported / not_supported / inconclusive
    2. **Điều chỉnh độ tin cậy**: Đề xuất giá trị độ tin cậy mới (0.0-1.0) kèm lý do
    3. **Độ mạnh bằng chứng**: weak / moderate / strong
    4. **Lý luận chính**: 2-3 câu giải thích phán quyết của bạn
    5. **Mối quan ngại**: Bất kỳ mối quan ngại về phương pháp hoặc hạn chế nào
    6. **Gợi ý bước tiếp theo**: Điều gì sẽ củng cố hoặc làm rõ kết quả này?
```

Ghi lại phán quyết của Review LLM.

### Bước 3: Tổng Hợp Claude

1. **Hình thành phán quyết độc lập của Claude** (sau khi đọc phán quyết của Review LLM, Claude cũng phân tích độc lập):
   - Dựa trên kết quả thí nghiệm, ngữ cảnh khẳng định và bằng chứng tổng hợp từ các thí nghiệm khác
   - Hình thành phán quyết và đề xuất độ tin cậy của riêng Claude

2. **Tổng hợp cả hai phán quyết** (tuân theo quy tắc tổng hợp trong cross-model-review.md):
   - **Cả hai đồng ý** (cùng phán quyết): sử dụng phán quyết đó, lấy trung bình độ tin cậy, độ chắc chắn cao
   - **Cả hai không đồng ý**:
     - Gắn cờ rõ ràng về sự không đồng ý
     - Lấy phán quyết thận trọng hơn (supported > partially_supported > not_supported)
     - Sử dụng giá trị độ tin cậy thấp hơn
     - Chi tiết lý do không đồng ý trong báo cáo
   - **Phát hiện nghiêm trọng được ưu tiên**: nếu một trong hai bên phát hiện vấn đề phương pháp (rò rỉ dữ liệu, so sánh không công bằng), phát hiện đó được ưu tiên

3. **Xác định phán quyết cuối cùng**: phán quyết + new_confidence + evidence_strength

### Bước 4: Cập Nhật Wiki Dựa Trên Phán Quyết

**Nếu `--auto` không được thiết lập**: hiển thị phán quyết và các thay đổi dự kiến trước, chờ xác nhận của người dùng.

#### Đường dẫn A: SUPPORTED (thí nghiệm hỗ trợ khẳng định)

1. **Cập nhật khẳng định**:
   - confidence: ↑ điều chỉnh đến giá trị mới (thường +0.1~0.3)
   - status: điều chỉnh dựa trên độ tin cậy mới
     - confidence >= 0.7 → `supported`
     - confidence 0.4–0.7 → `weakly_supported`
   - evidence: thêm mục mới `{source: experiment-slug, type: supports, strength: strong/moderate, detail: key_result}`
   - date_updated: ngày hôm nay

2. **Cập nhật ý tưởng** (nếu tồn tại và trạng thái là in_progress/tested):
   - Nếu tất cả các khẳng định liên kết đều supported/weakly_supported:
     - status: `validated`
     - pilot_result: tóm tắt key_result
     - date_resolved: ngày hôm nay

3. **Thêm cạnh đồ thị**:
   ```bash
   python3 tools/research_wiki.py add-edge wiki/ \
     --from "experiments/{slug}" --to "claims/{target-claim}" \
     --type supports --evidence "{key_result}"
   ```

4. **Gợi ý bước tiếp theo**: `/paper-plan` hoặc tiếp tục các thí nghiệm ablation/robustness

#### Đường dẫn B: PARTIALLY_SUPPORTED (hỗ trợ một phần)

1. **Cập nhật khẳng định**:
   - confidence: điều chỉnh nhỏ (+0.05~0.15)
   - evidence: thêm `{type: supports, strength: weak, detail: ...}`
   - date_updated: ngày hôm nay

2. **Thêm cạnh đồ thị**:
   ```bash
   python3 tools/research_wiki.py add-edge wiki/ \
     --from "experiments/{slug}" --to "claims/{target-claim}" \
     --type supports --evidence "Hỗ trợ một phần: {hạn chế}"
   ```

3. **Gợi ý thí nghiệm bổ sung**:
   - Chỉ rõ bằng chứng nào còn thiếu
   - Đề xuất sử dụng `/exp-design` để thiết kế các thí nghiệm bổ sung
   - Nếu các mối quan ngại do Review LLM gắn cờ có thể giải quyết bằng thí nghiệm, đề xuất hướng thí nghiệm cụ thể

4. **Trạng thái ý tưởng không thay đổi**: giữ in_progress, chờ thêm bằng chứng

#### Đường dẫn C: NOT_SUPPORTED (thí nghiệm không hỗ trợ khẳng định)

1. **Cập nhật khẳng định**:
   - confidence: ↓ giảm đáng kể (thường -0.2~0.4)
   - status: nếu confidence < 0.3 → `challenged`
   - evidence: thêm `{type: invalidates, strength: strong/moderate, detail: ...}`
   - date_updated: ngày hôm nay

2. **Cập nhật ý tưởng** (nếu tồn tại):
   - status: `failed`
   - failure_reason: lý do cụ thể cho thất bại (trích xuất từ kết quả thí nghiệm và phân tích của Review LLM)
   - date_resolved: ngày hôm nay
   - Lưu ý: failure_reason là bộ nhớ chống lặp lại — phải được viết rõ ràng, giải thích tại sao thất bại

3. **Thêm cạnh đồ thị**:
   ```bash
   python3 tools/research_wiki.py add-edge wiki/ \
     --from "experiments/{slug}" --to "claims/{target-claim}" \
     --type invalidates --evidence "{failure_reason}"
   ```

4. **Gợi ý bước tiếp theo**:
   - Phân tích lý do thất bại
   - Cân nhắc thay đổi hướng (ý tưởng mới giải quyết cùng khoảng trống nhưng tránh thất bại đã biết)
   - Đề xuất `/ideate` để tạo các phương án thay thế

#### Đường dẫn D: INCONCLUSIVE (kết quả không rõ ràng)

1. **Không sửa đổi trạng thái/độ tin cậy của khẳng định**: bằng chứng không đủ để đưa ra phán quyết

2. **Cập nhật trang thí nghiệm**: outcome đã là inconclusive (được thiết lập bởi /exp-run)

3. **Gợi ý gỡ lỗi**:
   - Vấn đề dữ liệu? Lỗi triển khai? Chỉ số sai?
   - Phương sai quá lớn? Cần thêm seed?
   - Thiết lập thí nghiệm không phù hợp với khẳng định?

4. **Trạng thái ý tưởng không thay đổi**: giữ trạng thái hiện tại

#### Tất Cả Đường Dẫn (các bước chung)

1. **Điền phần `## Cập Nhật Khẳng Định` của trang thí nghiệm**:
   ```markdown
   ## Cập Nhật Khẳng Định
   - **Phán quyết**: {supported/partially_supported/not_supported/inconclusive}
   - **Khẳng định**: [[{target-claim}]] độ tin cậy {old} → {new}
   - **Sự đồng thuận của giám khảo**: {Claude và Review LLM đồng ý / không đồng ý về ...}
   - **Ngày**: YYYY-MM-DD
   ```

2. **Cập nhật index.md** (nếu trạng thái khẳng định thay đổi)

3. **Xây dựng lại dữ liệu phái sinh**:
   ```bash
   python3 tools/research_wiki.py rebuild-context-brief wiki/
   python3 tools/research_wiki.py rebuild-open-questions wiki/
   ```

4. **Thêm nhật ký**:
   ```bash
   python3 tools/research_wiki.py log wiki/ \
     "exp-eval | {slug} → {target-claim} | phán quyết: {verdict} | độ tin cậy: {old}→{new}"
   ```

5. **In VERDICT_REPORT ra terminal**:
   ```markdown
   # Báo Cáo Phán Quyết: {tiêu đề thí nghiệm}

   ## Phán Quyết: {SUPPORTED / PARTIALLY_SUPPORTED / NOT_SUPPORTED / INCONCLUSIVE}

   ## Đánh Giá Của Giám Khảo
   | | Claude | Review LLM | Cuối cùng |
   |---|-------|------|-------|
   | Phán quyết | {verdict} | {verdict} | {verdict} |
   | Độ tin cậy | {value} | {value} | {value} |
   | Độ mạnh bằng chứng | {strength} | {strength} | {strength} |

   ## Lý Luận Chính
   {2-3 câu từ tổng hợp Review LLM + Claude}

   ## Thay Đổi Wiki
   | Thực thể | Trường | Trước | Sau |
   |--------|-------|--------|-------|
   | claims/{slug} | confidence | {old} | {new} |
   | claims/{slug} | status | {old} | {new} |
   | ideas/{slug} | status | {old} | {new} |

   ## Các Cạnh Đồ Thị Được Thêm
   - experiments/{slug} → claims/{target} (supports/invalidates)

   ## Mối Quan Ngại
   {các mối quan ngại về phương pháp từ Review LLM}

   ## Bước Tiếp Theo
   - {gợi ý cụ thể theo đường dẫn}

   ## Tăng Trưởng Wiki
   | Chỉ số | Trước | Sau | Chênh lệch |
   |--------|--------|-------|-------|
   | Khẳng định được cập nhật | — | — | {N} |
   | Cạnh | {before} | {after} | +{delta} |
   | Độ trưởng thành | {level} | {level} | {không thay đổi/nâng cấp} |
   (Dữ liệu từ so sánh lệnh `python3 tools/research_wiki.py maturity wiki/ --json` ở đầu Bước 1 và cuối Bước 4.)
   ```

## Các Ràng Buộc

- **Chỉ xử lý các thí nghiệm đã hoàn thành**: từ chối các thí nghiệm có trạng thái != completed; nhắc người dùng sử dụng /exp-run trước
- **Tính độc lập của người đánh giá**: tuân thủ nghiêm ngặt cross-model-review.md — không gửi đánh giá trước của Claude đến Review LLM
- **Phạm vi độ tin cậy 0.0–1.0**: độ tin cậy cập nhật không được vượt quá phạm vi này
- **failure_reason phải cụ thể**: failure_reason của đường dẫn not_supported không được mơ hồ (ví dụ: "thí nghiệm thất bại") — phải nêu lý do cụ thể
- **Không xóa khẳng định**: ngay cả khi not_supported, chỉ thách thức hoặc giảm độ tin cậy; không xóa trang khẳng định. Trong trường hợp cực đoan (nhiều bác bỏ nhất quán, độ tin cậy → 0), đặt trạng thái là deprecated thay vì xóa
- **Các cạnh đồ thị thông qua tools/research_wiki.py**: không chỉnh sửa thủ công edges.jsonl
- **Nguyên tắc thận trọng**: khi phán quyết của Claude và Review LLM không đồng ý, sử dụng phán quyết thận trọng hơn
- **Trạng thái ý tưởng chỉ tiến về phía trước**: proposed → in_progress → tested → validated/failed, không thể đảo ngược
- **Đánh giá khẳng định bằng tất cả các thí nghiệm**: xem xét không chỉ thí nghiệm hiện tại mà còn các thí nghiệm khác trên cùng khẳng định

## Xử Lý Lỗi

- **Không tìm thấy thí nghiệm**: nhắc người dùng kiểm tra slug, liệt kê các ứng viên trong wiki/experiments/ với status=completed
- **Thí nghiệm chưa hoàn thành**: báo cáo trạng thái, đề xuất chạy `/exp-run {slug}` hoặc `/exp-run {slug} --check`
- **Khẳng định mục tiêu không tồn tại**: tạo trang khẳng định mới (trạng thái: proposed, độ tin cậy: 0.3), ghi chú "tự động tạo bởi exp-eval"
- **Ý tưởng liên kết không tồn tại**: bỏ qua cập nhật ý tưởng, chỉ cập nhật khẳng định, ghi chú trong báo cáo
- **Review LLM không khả dụng**: chuyển sang phán quyết một mô hình của Claude, ghi chú "phán quyết một mô hình, xác minh chéo mô hình không khả dụng" trong báo cáo, đề xuất người dùng xác nhận sau
- **Khẳng định đã được sửa đổi bởi thí nghiệm khác**: đọc trạng thái mới nhất, điều chỉnh dựa trên độ tin cậy hiện tại (không ghi đè đóng góp của các thí nghiệm khác)
- **Thiếu dữ liệu kết quả**: nếu phần Kết Quả của trang thí nghiệm trống, nhắc người dùng chạy `/exp-run {slug} --check` trước

## Phụ Thuộc

### Công cụ (thông qua Bash)

- `python3 tools/research_wiki.py add-edge wiki/ ...` — thêm cạnh đồ thị
- `python3 tools/research_wiki.py rebuild-context-brief wiki/` — xây dựng lại query_pack
- `python3 tools/research_wiki.py rebuild-open-questions wiki/` — xây dựng lại gap_map
- `python3 tools/research_wiki.py log wiki/ "<message>"` — thêm nhật ký

### Máy Chủ MCP

- `mcp__llm-review__chat` — Bước 2 phán quyết độc lập của Review LLM

### Claude Code Gốc

- `Read` — đọc các trang wiki
- `Glob` — tìm các thí nghiệm khác trên cùng khẳng định
- `Edit` — cập nhật các trang wiki

### Tài Liệu Tham Khảo Chung

- `.claude/skills/shared-references/cross-model-review.md` — nguyên tắc độc lập của Review LLM (bắt buộc đọc)

### Được Gọi Bởi

- `/research` Giai đoạn 4 (giai đoạn phán quyết và lặp lại)
- Người dùng trực tiếp