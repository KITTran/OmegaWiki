---
description: Biên soạn đề cương bài báo từ đồ thị khẳng định — bản đồ bằng chứng → cấu trúc tường thuật → kế hoạch phần + kế hoạch hình ảnh + kế hoạch trích dẫn, đánh giá Review LLM là bắt buộc
argument-hint: "<slug-khẳng-định...> --venue <ICLR|NeurIPS|ICML|ACL|CVPR|IEEE> [--title <tiêu-đề-làm-việc>]"
---

# /paper-plan

> Biên soạn đề cương bài báo từ đồ thị khẳng định của wiki.
> Nhập các khẳng định mục tiêu (trạng thái: supported hoặc weakly_supported), chỉ định hội nghị mục tiêu,
> biên soạn bản đồ bằng chứng từ wiki → xác định cấu trúc tường thuật → tạo đề cương phần + kế hoạch hình ảnh + kế hoạch trích dẫn.
> Đánh giá Review LLM là bước bắt buộc (đóng vai trò chủ tịch khu vực để đánh giá tính thuyết phục của đề cương).
> Xuất PAPER_PLAN.md ra wiki/outputs/.
>
> Điểm khác biệt chính: đề cương được điều khiển bởi đồ thị khẳng định — mỗi phần tồn tại vì nó hỗ trợ một khẳng định,
> không phải vì quy ước bài báo yêu cầu phần đó.

## Đầu Vào

- `claims`: danh sách các slug khẳng định mục tiêu (phân tách bằng khoảng trắng)
  - mỗi khẳng định nên có trạng thái `supported` hoặc `weakly_supported`
  - nếu bao gồm các khẳng định `proposed` hoặc `challenged`, cảnh báo nhưng vẫn tiếp tục
- `--venue` *(bắt buộc)*: hội nghị mục tiêu, xác định giới hạn trang và yêu cầu định dạng
  - hỗ trợ: `ICLR` / `NeurIPS` / `ICML` / `ACL` / `CVPR` / `IEEE`
- `--title` *(tùy chọn)*: tiêu đề làm việc; nếu bỏ qua, sẽ được tạo từ các khẳng định mục tiêu

## Đầu Ra

- `wiki/outputs/paper-plan-{slug}-{date}.md` — kế hoạch bài báo hoàn chỉnh (PAPER_PLAN.md)
- `wiki/graph/edges.jsonl` — các cạnh derived_from mới (kế hoạch → các khẳng định/bài báo nguồn)
- `wiki/graph/context_brief.md` — xây dựng lại
- `wiki/log.md` — thêm mục nhật ký
- **PAPER_PLAN_REPORT** *(in ra terminal)* — tóm tắt kế hoạch

## Tương Tác Wiki

### Đọc

- `wiki/claims/*.md` — trạng thái, độ tin cậy, danh sách bằng chứng, điều kiện của các khẳng định mục tiêu
- `wiki/experiments/*.md` — các thí nghiệm hỗ trợ cho khẳng định (kết quả, chỉ số, key_result)
- `wiki/papers/*.md` — các bài báo nguồn bằng chứng (Phương pháp, Kết quả, Liên quan)
- `wiki/concepts/*.md` — các khái niệm kỹ thuật liên quan (hỗ trợ viết phần Phương pháp)
- `wiki/topics/*.md` — ngữ cảnh hướng nghiên cứu (hỗ trợ định vị Giới thiệu)
- `wiki/ideas/*.md` — động lực và giả thuyết của các ý tưởng gốc
- `wiki/graph/context_brief.md` — ngữ cảnh toàn cục
- `wiki/graph/open_questions.md` — các khoảng trống kiến thức (chú thích hạn chế của bài báo)
- `wiki/graph/edges.jsonl` — đồ thị mối quan hệ (xây dựng chuỗi logic tường thuật)
- `.claude/skills/shared-references/academic-writing.md` — nguyên tắc viết
- `.claude/skills/shared-references/citation-verification.md` — kỷ luật trích dẫn

### Ghi

- `wiki/outputs/paper-plan-{slug}-{date}.md` — tệp kế hoạch bài báo
- `wiki/graph/edges.jsonl` — các cạnh derived_from
- `wiki/graph/context_brief.md` — xây dựng lại
- `wiki/log.md` — thêm nhật ký hoạt động

### Các cạnh đồ thị được tạo

- `derived_from`: paper-plan → khẳng định (các khẳng định mà kế hoạch được xây dựng từ)
- `derived_from`: paper-plan → bài báo (các bài báo mà kế hoạch trích dẫn)

## Quy Trình Làm Việc

**Điều kiện tiên quyết**: xác nhận thư mục làm việc là thư mục gốc dự án wiki (thư mục chứa `wiki/`, `raw/`, `tools/`).

### Bước 1: Tải Đồ Thị Khẳng Định

1. Đọc `wiki/claims/{slug}.md` cho tất cả các khẳng định mục tiêu
2. Đối với mỗi khẳng định, thu thập danh sách bằng chứng của nó:
   - nguồn của mỗi mục bằng chứng (slug bài báo hoặc slug thí nghiệm)
   - loại bằng chứng (supports / contradicts / tested_by / invalidates)
   - độ mạnh bằng chứng (weak / moderate / strong)
3. Đối với mỗi nguồn bằng chứng, đọc trang wiki tương ứng:
   - `wiki/experiments/{source}.md` → key_result, chỉ số, outcome
   - `wiki/papers/{source}.md` → Phương pháp, Kết quả
4. Tải các cạnh liên quan từ `wiki/graph/edges.jsonl` để xây dựng mối quan hệ giữa các khẳng định
5. Đọc `wiki/graph/context_brief.md` để có ngữ cảnh toàn cục
6. Đọc `wiki/graph/open_questions.md` để chú thích các hạn chế đã biết

**Xác thực**:
- Nếu bất kỳ khẳng định mục tiêu nào có trạng thái `proposed`: cảnh báo "khẳng định chưa được xác thực; bài báo có thể thiếu hỗ trợ bằng chứng"
- Nếu bất kỳ khẳng định mục tiêu nào có độ tin cậy < 0.5: cảnh báo "độ tin cậy của khẳng định thấp; cân nhắc chạy thêm thí nghiệm trước"
- Nếu không có bằng chứng thí nghiệm hỗ trợ bất kỳ khẳng định nào: lỗi "cần ít nhất một kết quả thí nghiệm để lên kế hoạch bài báo"

### Bước 2: Biên Soạn Bản Đồ Bằng Chứng Từ Wiki

Tạo ma trận có cấu trúc ánh xạ khẳng định → bằng chứng → phần:

```markdown
| Khẳng định | Trạng thái | Độ tin cậy | Nguồn bằng chứng | Độ mạnh | Phần bài báo |
|-------|--------|-----------|-----------------|----------|---------------|
| [[primary-claim]] | supported | 0.85 | exp-main, paper-A | strong | Phương pháp + Thí nghiệm 5.2 |
| [[supporting-claim-1]] | supported | 0.75 | exp-ablation-1 | moderate | Thí nghiệm 5.3 (Ablation) |
| [[supporting-claim-2]] | weakly_supported | 0.55 | exp-scaling | weak | Thí nghiệm 5.4 (Scaling) |
```

Ánh xạ khẳng định đến cấu trúc bài báo theo từng chiều:
- **Khẳng định mục tiêu** → đóng góp cốt lõi, điều khiển Tóm tắt + Giới thiệu + Phương pháp
- **Khẳng định phân rã** → đóng góp yếu tố, điều khiển các tiểu mục Ablation
- **Khẳng định ngữ cảnh** → kiến thức nền, điều khiển Công trình liên quan + Giới thiệu

### Bước 3: Xác Định Cấu Trúc Tường Thuật

Tuân theo nguyên tắc đồng hồ cát trong `shared-references/academic-writing.md`:

1. **Xác định cốt truyện chính của bài báo**:
   - Khoảng trống (trích xuất từ động lực của ý tưởng hoặc gap_map)
   - Giải pháp (trích xuất từ cách tiếp cận của khẳng định mục tiêu)
   - Bằng chứng (trích xuất từ kết quả của thí nghiệm)
   - Tác động (suy ra từ độ tin cậy và phạm vi của khẳng định)

2. **Xác định góc độ tường thuật**:
   - Bài báo giải quyết vấn đề gì? (hướng vấn đề / hướng phương pháp / hướng dữ liệu)
   - Đối tượng độc giả chính là ai? (lý thuyết / hệ thống / ứng dụng)
   - Nó khác biệt như thế nào so với 3 bài báo gần đây nhất?

3. **Thiết lập ánh xạ phần → khẳng định**:
   Mỗi phần phải hỗ trợ ít nhất một khẳng định. Một phần không hỗ trợ khẳng định nào là phần thừa và nên được loại bỏ.

### Bước 4: Tạo Đề Cương Phần

Tạo đề cương theo yêu cầu định dạng của hội nghị; mỗi phần bao gồm:

```markdown
## 1. Giới thiệu (1.5 trang)

### Các khẳng định được giải quyết
- Khẳng định khoảng trống: {các phương pháp hiện có thiếu X vì Y}
- Khẳng định đóng góp: [[primary-claim]]

### Kế hoạch đoạn văn
1. Ngữ cảnh rộng: {tầm quan trọng của lĩnh vực, tiến bộ gần đây}
2. Vấn đề cụ thể: {điều gì còn thiếu, tại sao nó quan trọng}
3. Cách tiếp cận của chúng tôi: "Trong công trình này, chúng tôi đề xuất..." + danh sách đóng góp
4. Xem trước kết quả: {các con số nổi bật}
5. Cấu trúc bài báo: "Phần còn lại của bài báo này..."

### Trích dẫn chính
- [[paper-A]] — thiết lập vấn đề
- [[paper-B]] — công trình gần nhất (chúng tôi cải tiến từ)
- [[paper-C]] — baseline của chúng tôi

---

## 2. Công trình liên quan (1 trang)

### Các nhóm
- Hướng A: {các bài báo, vị trí của chúng tôi}
- Hướng B: {các bài báo, vị trí của chúng tôi}
- Hướng C: {các bài báo, vị trí của chúng tôi}

### Các khẳng định được giải quyết
- Các khẳng định ngữ cảnh phân biệt với công trình trước

---

## 3. Phương pháp (2-3 trang)

### Các khẳng định được giải quyết
- [[primary-claim]]: phần 3.1-3.2
- [[supporting-claim-1]]: phần 3.3

### Kế hoạch tiểu mục
- 3.1 Công thức vấn đề: ký hiệu, mục tiêu
- 3.2 Cách tiếp cận cốt lõi: trực giác → hình thức
- 3.3 Thành phần X: quyết định thiết kế + lý giải
- 3.4 Chi tiết huấn luyện/dự đoán

### Hình ảnh
- Hình 1: Kiến trúc tổng thể (bắt buộc)
- Hình 2: Chi tiết Thành phần X (nếu phức tạp)

---

## 4. Thí nghiệm (2-3 trang)

### Các khẳng định được giải quyết
- [[primary-claim]]: phần 4.2 (kết quả chính)
- [[supporting-claim-1]]: phần 4.3 (ablation)
- [[supporting-claim-2]]: phần 4.4 (scaling)

### Kế hoạch tiểu mục
- 4.1 Thiết lập: tập dữ liệu, baseline, chỉ số, chi tiết triển khai
- 4.2 Kết quả chính: Bảng 1 (so sánh chính), [[exp-main]]
- 4.3 Nghiên cứu ablation: Bảng 2 (phân tích thành phần), [[exp-ablation-*]]
- 4.4 Phân tích: scaling, độ bền, ví dụ định tính

### Hình ảnh/Bảng
- Bảng 1: So sánh chính với baseline
- Bảng 2: Kết quả ablation
- Hình 3: Đường cong scaling / ví dụ định tính

---

## 5. Kết luận (0.5 trang)

### Điểm chính
- {một câu mà người đọc nên nhớ}

### Hạn chế
- {từ gap_map hoặc điều kiện khẳng định}

### Hướng nghiên cứu tương lai
- {từ các câu hỏi mở trong gap_map}
```

**Ngân sách trang**: được phân bổ theo `--venue` (tham khảo bảng hội nghị trong academic-writing.md); tổng số trang phần ≤ giới hạn phần chính của hội nghị.

### Bước 5: Kế Hoạch Hình Ảnh

Thiết kế từng hình ảnh/bảng đã lên kế hoạch:

```markdown
## Kế Hoạch Hình Ảnh

### Hình 1: Kiến Trúc Hệ Thống
- Loại: sơ đồ
- Nguồn: mô tả phần Phương pháp
- Phong cách: sơ đồ khối với các thành phần được gắn nhãn
- Kích thước: chiều rộng đầy đủ (1 cột = chiều rộng văn bản)

### Bảng 1: Kết Quả Chính
- Loại: bảng so sánh
- Nguồn: key_result của [[exp-main]] + baseline
- Cột: Phương pháp | Chỉ số-1 | Chỉ số-2 | ...
- Hàng: baseline + của chúng tôi (in đậm)
- Ghi chú: in đậm kết quả tốt nhất, gạch chân kết quả thứ hai, mũi tên ↑/↓ cho hướng

### Hình 3: Phân Tích Scaling
- Loại: biểu đồ đường
- Nguồn: kết quả của [[exp-scaling]]
- Trục X: chiều scaling (kích thước mô hình / kích thước dữ liệu)
- Trục Y: chỉ số hiệu suất
- Đường: của chúng tôi vs baseline, với dải lỗi
```

### Bước 6: Kế Hoạch Trích Dẫn

Tuân theo `shared-references/citation-verification.md`:

1. Liệt kê tất cả các bài báo wiki được tham chiếu qua `[[slug]]` trong đề cương
2. Đối với mỗi bài báo, lấy trước BibTeX:
   - DBLP trước, sau đó CrossRef, sau đó S2
   - Thành công: ghi lại khóa BibTeX + nguồn
   - Thất bại: đánh dấu `[UNCONFIRMED]`
3. Tạo báo cáo độ phủ trích dẫn:
   ```
   Trích dẫn: tổng cộng 15, đã xác minh 12 (DBLP: 8, CrossRef: 3, S2: 1), 3 [UNCONFIRMED]
   ```
4. Đối với các mục [UNCONFIRMED], cung cấp URL đề xuất để xác minh thủ công

### Bước 7: Đánh Giá Review LLM (bắt buộc)

```
mcp__llm-review__chat:
  system: "Bạn là chủ tịch khu vực tại {venue} đang đánh giá đề cương bài báo.
           Đánh giá: Cấu trúc tường thuật có thuyết phục không? Mỗi phần có phục vụ mục đích rõ ràng không?
           Các thí nghiệm có đủ để hỗ trợ các khẳng định không?
           Độ phủ công trình liên quan có đầy đủ không?
           Có những khoảng trống rõ ràng nào mà người đánh giá sẽ tấn công không?
           Cung cấp gợi ý cụ thể để củng cố đề cương."
  message: |
    ## Đề Cương Bài Báo
    {đề cương hoàn chỉnh từ Bước 4}

    ## Bản Đồ Bằng Chứng
    {bản đồ bằng chứng từ Bước 2}

    ## Kế Hoạch Hình Ảnh/Bảng
    {kế hoạch từ Bước 5}

    ## Độ Phủ Trích Dẫn
    {báo cáo từ Bước 6}

    ## Câu Hỏi Đánh Giá
    1. Cấu trúc tường thuật (khoảng trống → giải pháp → bằng chứng → tác động) có thuyết phục không?
    2. Có khẳng định nào thiếu hỗ trợ không? Thí nghiệm nào còn thiếu?
    3. Việc nhóm công trình liên quan có phù hợp không? Có hướng nào bị thiếu không?
    4. Ngân sách trang có khả thi không? Có phần nào quá dài/ngắn không?
    5. Các hình ảnh/bảng có đủ để kể câu chuyện không?
```

Sửa đổi đề cương dựa trên phản hồi của Review LLM (thêm phần, điều chỉnh ngân sách trang, thêm hình ảnh/bảng, điều chỉnh cấu trúc tường thuật).

### Bước 8: Ghi Vào Wiki

1. **Tạo slug**:
   ```bash
   python3 tools/research_wiki.py slug "<tiêu-đề-làm-việc>"
   ```

2. **Viết PAPER_PLAN.md**:
   Tạo `wiki/outputs/paper-plan-{slug}-{date}.md` chứa:
   - Siêu dữ liệu (hội nghị, tiêu đề, ngày, khẳng định mục tiêu)
   - Bản đồ bằng chứng (Bước 2)
   - Đề cương phần hoàn chỉnh (Bước 4, với sửa đổi của Review LLM)
   - Kế hoạch hình ảnh/bảng (Bước 5)
   - Kế hoạch trích dẫn + báo cáo độ phủ (Bước 6)
   - Tóm tắt đánh giá Review LLM (phản hồi chính và ghi chép sửa đổi từ Bước 7)

3. **Thêm cạnh đồ thị**:
   ```bash
   # kế hoạch → khẳng định mục tiêu
   python3 tools/research_wiki.py add-edge wiki/ \
     --from "outputs/paper-plan-{slug}-{date}" --to "claims/{primary-claim}" \
     --type derived_from --evidence "Kế hoạch bài báo được xây dựng từ khẳng định này"

   # kế hoạch → bài báo chính
   python3 tools/research_wiki.py add-edge wiki/ \
     --from "outputs/paper-plan-{slug}-{date}" --to "papers/{paper-slug}" \
     --type derived_from --evidence "Kế hoạch bài báo trích dẫn bài báo này"
   ```

4. **Xây dựng lại dữ liệu phái sinh**:
   ```bash
   python3 tools/research_wiki.py rebuild-context-brief wiki/
   ```

5. **Thêm nhật ký**:
   ```bash
   python3 tools/research_wiki.py log wiki/ \
     "paper-plan | đề cương bài báo {venue} cho [[{slug}]] | khẳng định: {danh-sách-khẳng-định} | trích dẫn: {đã-xác-minh}/{tổng}"
   ```

6. **In PAPER_PLAN_REPORT ra terminal**:
   ```markdown
   # Báo Cáo Kế Hoạch Bài Báo

   ## Siêu Dữ Liệu
   - Tiêu đề: {tiêu đề làm việc}
   - Hội nghị: {venue}
   - Giới hạn trang: {N} trang
   - Ngày: {date}

   ## Khẳng Định → Phần
   | Khẳng định | Độ tin cậy | Phần |
   |-------|-----------|---------|
   | [[primary]] | 0.85 | Phương pháp + Thí nghiệm 5.2 |
   | [[supporting-1]] | 0.75 | Thí nghiệm 5.3 |

   ## Ngân Sách Trang
   | Phần | Trang | Khẳng định |
   |---------|-------|--------|
   | Giới thiệu | 1.5 | khoảng trống, đóng góp |
   | Công trình liên quan | 1.0 | ngữ cảnh |
   | Phương pháp | 2.5 | chính, hỗ trợ |
   | Thí nghiệm | 2.5 | tất cả |
   | Kết luận | 0.5 | — |

   ## Hình Ảnh/Bảng: {N} đã lên kế hoạch
   ## Trích dẫn: {đã-xác-minh}/{tổng} đã xác minh, {số-xác-minh} [UNCONFIRMED]
   ## Đánh giá Review LLM: điểm {X}/10, phán quyết: {verdict}

   ## Bước Tiếp Theo
   - Chạy `/paper-draft wiki/outputs/paper-plan-{slug}-{date}.md` để soạn thảo bài báo
   - Giải quyết {số-xác-minh} trích dẫn [UNCONFIRMED] trước khi /paper-compile
   ```

## Các Ràng Buộc

- **--venue là bắt buộc**: giới hạn trang và yêu cầu định dạng khác nhau đáng kể theo hội nghị; không thể bỏ qua
- **Ít nhất một bằng chứng thí nghiệm**: các khẳng định lý thuyết thuần túy là không đủ cho một bài báo thực nghiệm; cần ít nhất một kết quả thí nghiệm
- **Ngân sách trang phải khả thi**: tổng số trang phần ≤ giới hạn phần chính của hội nghị; nếu không điều chỉnh (nén hoặc chuyển sang phụ lục)
- **Đánh giá Review LLM là bắt buộc**: không thể bỏ qua; phát hiện vấn đề ở giai đoạn đề cương có chi phí thấp nhất
- **Tất cả trích dẫn từ wiki**: mọi bài báo trong kế hoạch trích dẫn phải tồn tại trong wiki/papers/
- **Ánh xạ khẳng định → phần phải đầy đủ**: mọi khẳng định mục tiêu phải xuất hiện trong ít nhất một phần
- **Mọi phần phải có khẳng định**: một phần không hỗ trợ khẳng định nào là phần thừa và nên được loại bỏ hoặc gộp
- **Các cạnh đồ thị thông qua tools/research_wiki.py**: không chỉnh sửa thủ công edges.jsonl
- **Trích dẫn sử dụng [[slug]]**: tất cả trích dẫn trong đề cương sử dụng cú pháp wikilink

## Xử Lý Lỗi

- **Trạng thái khẳng định không đủ**: nếu tất cả các khẳng định đều `proposed`, lỗi "các khẳng định chưa được xác thực; chạy thí nghiệm trước"
- **Không có bằng chứng thí nghiệm**: lỗi "cần ít nhất một kết quả thí nghiệm"; đề xuất chạy /exp-design + /exp-run trước
- **Không đủ bài báo wiki**: nếu kế hoạch trích dẫn có ít hơn 5 bài báo wiki, cảnh báo "độ phủ công trình liên quan không đủ; cân nhắc /ingest thêm bài báo trước"
- **Ngân sách trang vượt quá**: tự động chuyển các phần ưu tiên thấp hơn sang kế hoạch phụ lục; báo cáo điều chỉnh
- **Review LLM không khả dụng**: chuyển sang tự đánh giá của Claude; báo cáo chú thích "đánh giá một mô hình — xác minh chéo mô hình không khả dụng"
- **Lấy BibTeX thất bại**: đánh dấu [UNCONFIRMED]; tóm tắt trong báo cáo kế hoạch trích dẫn
- **Xung đột slug**: thêm hậu tố ngày
- **Không tìm thấy khẳng định mục tiêu**: lỗi; liệt kê các ứng viên trong wiki/claims/

## Phụ Thuộc

### Công cụ (thông qua Bash)

- `python3 tools/research_wiki.py slug "<title>"` — tạo slug
- `python3 tools/research_wiki.py add-edge wiki/ ...` — thêm cạnh đồ thị
- `python3 tools/research_wiki.py rebuild-context-brief wiki/` — xây dựng lại query_pack
- `python3 tools/research_wiki.py log wiki/ "<message>"` — thêm nhật ký
- `python3 tools/fetch_s2.py search "<title>"` — tìm kiếm Semantic Scholar (dự phòng kế hoạch trích dẫn)

### Máy Chủ MCP

- `mcp__llm-review__chat` — Bước 7 đánh giá đề cương (bắt buộc)

### Claude Code Gốc

- `Read` — đọc các trang wiki
- `Glob` — tìm các khẳng định, thí nghiệm, bài báo
- `WebFetch` — lấy BibTeX DBLP / CrossRef (Bước 6)

### Tài Liệu Tham Khảo Chung

- `.claude/skills/shared-references/academic-writing.md` — cấu trúc tường thuật và nguyên tắc thiết kế phần
- `.claude/skills/shared-references/citation-verification.md` — quy tắc lấy và xác minh trích dẫn

### Được Gọi Bởi

- `/research` Giai đoạn 5 (giai đoạn viết bài báo)
- Người dùng gọi thủ công