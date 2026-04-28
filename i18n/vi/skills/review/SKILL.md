---
description: Đánh giá chéo giữa các mô hình cho mục đích chung — Review LLM đánh giá độc lập bất kỳ tạo tác nghiên cứu nào, xuất ra điểm số có cấu trúc, ánh xạ thực thể wiki và gợi ý cải thiện
argument-hint: <đường-dẫn-tạo-tác-hoặc-slug> [--difficulty standard|hard|adversarial] [--focus method|evidence|writing|completeness]
---

# /review

> Đánh giá bất kỳ tạo tác nghiên cứu nào (ý tưởng, đề xuất, kế hoạch thí nghiệm, bản thảo bài báo, khẳng định) bằng đánh giá chéo giữa các mô hình.
> Sử dụng Review LLM như một người đánh giá độc lập. Xuất ra điểm số có cấu trúc, gợi ý cải thiện có thể thực hiện được,
> và ánh xạ đến các thực thể wiki (khẳng định nào cần củng cố, khoảng trống nào được phát hiện).
> Hỗ trợ ba mức độ khó (standard / hard / adversarial) và bốn trọng tâm đánh giá.
> Có thể được sử dụng độc lập hoặc được gọi bởi /ideate, /refine, /exp-design.

## Đầu Vào

- `artifact`: tạo tác cần đánh giá, một trong các mục sau:
  - slug của trang wiki (ví dụ: `sparse-lora-for-edge-devices`, tìm kiếm trong ideas/experiments/claims/)
  - đường dẫn tệp (ví dụ: `wiki/outputs/paper-draft-v1.md`)
  - văn bản tự do (mô tả đề xuất hoặc ý tưởng được dán trực tiếp)
- `--difficulty` (tùy chọn, mặc định `standard`):
  - `standard`: đánh giá một vòng, cung cấp phản hồi có cấu trúc
  - `hard`: đối thoại nhiều vòng (tối đa 3 vòng), Claude phản biện từng điểm yếu
  - `adversarial`: đối thoại nhiều vòng (tối đa 3 vòng), Review LLM cố gắng tìm ra lỗi nghiêm trọng, mô phỏng người đánh giá khắt khe nhất
- `--focus` (tùy chọn, mặc định đánh giá toàn diện):
  - `method`: tập trung vào tính đúng đắn kỹ thuật, tính mới lạ và tính khả thi của thiết kế phương pháp
  - `evidence`: tập trung vào tính đầy đủ của bằng chứng, tính chặt chẽ thực nghiệm, hỗ trợ khẳng định
  - `writing`: tập trung vào sự rõ ràng, tổ chức cấu trúc và logic lập luận
  - `completeness`: tập trung vào nội dung thiếu (công trình liên quan, ablations, baselines)

## Đầu Ra

- **Báo Cáo Đánh Giá** (xuất ra terminal):
  - Điểm Tổng Thể (1-10)
  - Điểm Mạnh (danh sách các điểm tích cực)
  - Điểm Yếu (danh sách các vấn đề, xếp hạng theo mức độ nghiêm trọng)
  - Câu Hỏi (câu hỏi của người đánh giá)
  - Gợi Ý Có Thể Thực Hiện (gợi ý cải thiện xếp hạng theo mức độ ưu tiên)
  - Ánh Xạ Thực Thể Wiki (khẳng định nào cần củng cố, khoảng trống nào được tìm thấy)
  - Phán Quyết: `ready` / `needs-work` / `major-revision` / `rethink`
- Nếu `--difficulty >= hard`: thêm lịch sử đối thoại nhiều vòng và điểm số đã sửa đổi cuối cùng
- Kỹ năng này **không trực tiếp sửa đổi wiki**, nhưng xuất ra danh sách các cập nhật wiki được đề xuất

## Tương Tác Wiki

### Đọc
- `wiki/papers/*.md` — định vị các bài báo được tạo tác trích dẫn, xác minh tính chính xác của trích dẫn
- `wiki/concepts/*.md` — hiểu các khái niệm kỹ thuật liên quan đến tạo tác
- `wiki/claims/*.md` — kiểm tra trạng thái và độ tin cậy hiện tại của các khẳng định mà tạo tác phụ thuộc vào
- `wiki/experiments/*.md` — tìm kết quả thí nghiệm liên quan
- `wiki/ideas/*.md` — nếu đánh giá một ý tưởng, kiểm tra ngữ cảnh của nó
- `wiki/graph/context_brief.md` — ngữ cảnh toàn cục
- `wiki/graph/open_questions.md` — kiểm tra tính đầy đủ so với bản đồ khoảng trống
- `.claude/skills/shared-references/cross-model-review.md` — nguyên tắc độc lập của người đánh giá

### Ghi
- **Không có**. Đánh giá là một hoạt động truy vấn chỉ đọc.
  - Kết quả đánh giá được xuất ra terminal; người dùng hoặc người gọi (ví dụ: /refine) quyết định có áp dụng chúng hay không.

### Các cạnh đồ thị được tạo
- **Không có**.

## Quy Trình Làm Việc

**Điều kiện tiên quyết**: xác nhận thư mục làm việc là thư mục gốc dự án wiki (chứa `wiki/`, `raw/`, `tools/`).

### Bước 1: Tải Ngữ Cảnh

1. **Phân tích tạo tác**:
   - Nếu slug: tìm kiếm tuần tự trong `wiki/ideas/`, `wiki/experiments/`, `wiki/claims/`, `wiki/papers/`, `wiki/outputs/` cho `{slug}.md`
   - Nếu đường dẫn tệp: đọc trực tiếp
   - Nếu văn bản tự do: sử dụng trực tiếp
2. **Xác định loại tạo tác**: idea / experiment / claim / paper-draft / proposal / other
3. **Tải ngữ cảnh wiki liên quan**:
   - Đọc `wiki/graph/context_brief.md` để có cái nhìn toàn cục
   - Đọc `wiki/graph/open_questions.md` để có danh sách khoảng trống kiến thức
   - Tải các trang wiki liên quan theo loại tạo tác:
     - idea → các khẳng định origin_gaps của nó, các bài báo liên quan
     - experiment → khẳng định target_claim của nó, các thí nghiệm liên quan
     - claim → các nguồn evidence của nó, các bài báo và thí nghiệm liên quan
     - paper-draft → tất cả các trang wiki mà nó trích dẫn
4. **Đọc cross-model-review.md**: xác nhận nguyên tắc độc lập của Review LLM
5. **Xây dựng lời nhắc hệ thống cho người đánh giá** (dựa trên --focus):

   **Lời nhắc cơ bản (tất cả trọng tâm):**
   ```
   Bạn là một nhà nghiên cứu ML cao cấp đang đánh giá một tạo tác nghiên cứu.
   Hãy kỹ lưỡng, cụ thể và mang tính xây dựng. Đối với mỗi điểm yếu, đề xuất một giải pháp cụ thể.
   Đánh giá theo thang điểm 1-10:
   - 1-3: Lỗi cơ bản, không thể cứu vãn ở dạng hiện tại
   - 4-5: Vấn đề đáng kể nhưng ý tưởng cốt lõi có thể có giá trị
   - 6-7: Công trình vững chắc với các lĩnh vực cần cải thiện rõ ràng
   - 8-9: Công trình mạnh, chỉ có vấn đề nhỏ
   - 10: Xuất sắc, sẵn sàng xuất bản
   ```

   **Bổ sung theo trọng tâm:**
   - `method`: thêm đánh giá tính đúng đắn kỹ thuật, tính mới lạ của cách tiếp cận, tính khả thi, so sánh với các phương pháp thay thế
   - `evidence`: thêm đánh giá tính chặt chẽ thực nghiệm, ý nghĩa thống kê, sự phù hợp giữa khẳng định-bằng chứng, các kiểm soát còn thiếu
   - `writing`: thêm đánh giá sự rõ ràng, luồng logic, tính nhất quán của ký hiệu, chất lượng hình ảnh, phạm vi công trình liên quan
   - `completeness`: thêm đánh giá các baseline còn thiếu, các ablations còn thiếu, các bộ dữ liệu còn thiếu, công trình liên quan còn thiếu, tính tái tạo

   **Bổ sung đối kháng (chỉ chế độ adversarial):**
   ```
   Ngoài ra: tích cực tìm kiếm các lỗi nghiêm trọng. Một lỗi nghiêm trọng là bất cứ điều gì,
   nếu đúng, sẽ làm mất hiệu lực toàn bộ đóng góp (chứng minh không chính xác, rò rỉ dữ liệu,
   so sánh không công bằng, công trình đã xuất bản trước đó). Nếu bạn tìm thấy, hãy gắn cờ rõ ràng.
   ```

### Bước 2: Đánh Giá Ban Đầu Của Review LLM

**Tuân theo cross-model-review.md**: không gửi bất kỳ đánh giá trước nào của Claude đến Review LLM.

```
mcp__llm-review__chat:
  system: {lời nhắc hệ thống người đánh giá từ Bước 1}
  message: |
    ## Tạo Tác Cần Đánh Giá
    {toàn bộ văn bản tạo tác}

    ## Ngữ Cảnh Từ Cơ Sở Tri Thức
    {ngữ cảnh wiki liên quan: các khẳng định liên quan với trạng thái/độ tin cậy, các thí nghiệm liên quan, các mục bản đồ khoảng trống}

    ## Hướng Dẫn Đánh Giá
    Vui lòng cung cấp:
    1. **Điểm Mạnh** (3-5 gạch đầu dòng)
    2. **Điểm Yếu** (xếp hạng theo mức độ nghiêm trọng, mỗi điểm có gợi ý sửa chữa cụ thể)
    3. **Câu Hỏi** (những điều không rõ ràng hoặc cần làm rõ)
    4. **Điểm Số** (1-10 với giải thích một câu)
    5. **Phán Quyết**: ready / needs-work / major-revision / rethink
    6. **Phản Hồi Cấp Khẳng Định**: Đối với mỗi khẳng định được tạo tác tham chiếu, đánh giá xem bằng chứng có đủ không. Liệt kê bất kỳ khẳng định nào cần hỗ trợ mạnh mẽ hơn.
    7. **Khoảng Trống Kiến Thức Được Xác Định**: Bất kỳ câu hỏi mở hoặc kiến thức thiếu nào có thể củng cố công trình này.
```

Ghi lại `threadId` được trả về bởi Review LLM (cho đối thoại nhiều vòng trong Bước 3).

### Bước 3: Đối Thoại Nhiều Vòng (chế độ hard / adversarial)

Bỏ qua bước này nếu `--difficulty` là `standard`.

**Phản hồi từng điểm yếu của Review LLM** (tối đa 3 vòng):

**Vòng N (N = 1, 2, 3):**

1. Claude phân tích các điểm yếu của Review LLM và phân loại từng điểm:
   - **Phản biện**: Claude có lý luận hoặc bằng chứng wiki mạnh để bác bỏ → viết phản biện
   - **Thừa nhận**: điểm yếu thực sự tồn tại → thừa nhận và đề xuất giải pháp
   - **Làm rõ**: điểm yếu dựa trên hiểu lầm → cung cấp làm rõ

2. Gửi phản hồi của Claude đến Review LLM:
   ```
   mcp__llm-review__chat-reply:
     threadId: {từ Bước 2}
     message: |
       Cảm ơn bạn đã đánh giá. Đây là phản hồi của tôi:

       {đối với mỗi điểm yếu: phản biện / thừa nhận / làm rõ}

       Vui lòng đánh giá lại xem xét các phản hồi này. Cập nhật điểm số nếu cần.
       Nếu --difficulty == adversarial: Ngoài ra, vui lòng cố gắng hơn để tìm bất kỳ lỗi nghiêm trọng nào tôi có thể đã bỏ lỡ.
   ```

3. Review LLM phản hồi với đánh giá mới và điểm số đã sửa đổi

4. Nếu thay đổi điểm số của Review LLM < 0.5 và không có điểm yếu mới → dừng đối thoại (đã hội tụ)
5. Nếu đã đạt 3 vòng → dừng đối thoại

### Bước 4: Đầu Ra Có Cấu Trúc

Tổng hợp kết quả Bước 2 + Bước 3 thành Báo Cáo Đánh Giá có cấu trúc:

```markdown
# Báo Cáo Đánh Giá: {tiêu đề tạo tác}

## Thông Tin Chung
- **Loại tạo tác**: {ý tưởng / thí nghiệm / khẳng định / bản thảo bài báo / đề xuất}
- **Mức độ khó**: {standard / hard / adversarial}
- **Trọng tâm**: {phương pháp / bằng chứng / viết / tính đầy đủ / toàn diện}
- **Người đánh giá**: Review LLM (được cấu hình trong `.env`)
- **Số vòng**: {1 cho standard, N cho hard/adversarial}

## Điểm: {điểm cuối cùng}/10 — {phán quyết}

| Phán Quyết | Ý Nghĩa |
|---------|---------|
| ready | Sẵn sàng để sử dụng hoặc nộp trực tiếp |
| needs-work | Có điểm cần cải thiện rõ ràng; có thể sử dụng sau khi sửa |
| major-revision | Các phần cốt lõi cần sửa đổi đáng kể |
| rethink | Hướng cơ bản có thể có lỗi; xem xét lại |

## Điểm Mạnh
1. {điểm mạnh 1}
2. {điểm mạnh 2}
...

## Điểm Yếu (theo mức độ nghiêm trọng)

### Nghiêm Trọng
- {điểm yếu}: {mô tả cụ thể} → **Sửa**: {gợi ý sửa chữa cụ thể}

### Chính
- {điểm yếu}: {mô tả cụ thể} → **Sửa**: {gợi ý sửa chữa cụ thể}

### Nhỏ
- {điểm yếu}: {mô tả cụ thể} → **Sửa**: {gợi ý sửa chữa cụ thể}

## Câu Hỏi
1. {câu hỏi}
...

## Ánh Xạ Thực Thể Wiki

### Các Khẳng Định Cần Hỗ Trợ Mạnh Mẽ Hơn
| Khẳng Định | Độ Tin Cậy Hiện Tại | Vấn Đề | Hành Động Đề Xuất |
|-------|-------------------|-------|------------------|
| [[claim-slug]] | 0.6 | Bằng chứng gián tiếp | Thực hiện thí nghiệm mục tiêu |

### Các Khoảng Trống Kiến Thức Được Xác Định
| Khoảng Trống | Liên Quan Đến | Hành Động Đề Xuất |
|-----|-----------|------------------|
| {mô tả} | [[slug]] | /ingest, /exp-run, hoặc /query |

### Các Cập Nhật Wiki Được Đề Xuất
- `wiki/claims/{slug}.md`: cập nhật độ tin cậy, thêm ghi chú bằng chứng
- `wiki/ideas/{slug}.md`: thêm yếu tố rủi ro từ đánh giá
- `wiki/graph/open_questions.md`: sẽ được cập nhật vào lần xây dựng lại tiếp theo

## Lịch Sử Đối Thoại (chỉ hard/adversarial)

### Vòng 1
**Review LLM**: {tóm tắt đánh giá ban đầu}
**Claude**: {tóm tắt phản biện/thừa nhận}

### Vòng 2
**Review LLM**: {đánh giá cập nhật}
...

## Các Mục Có Thể Thực Hiện (xếp hạng)
1. [NGHIÊM TRỌNG] {mục hành động}
2. [CHÍNH] {mục hành động}
3. [NHỎ] {mục hành động}
```

## Các Ràng Buộc

- **Tính độc lập của người đánh giá**: tuân thủ nghiêm ngặt `shared-references/cross-model-review.md`; không để lộ đánh giá trước của Claude cho Review LLM
- **Không sửa đổi wiki**: đánh giá chỉ xuất ra gợi ý; nó không trực tiếp sửa đổi bất kỳ trang wiki nào. Việc sửa đổi wiki được xử lý bởi người gọi (ví dụ: /refine)
- **Điểm số phải có lý do**: điểm số không có lý do không được chấp nhận
- **Điểm yếu phải có giải pháp**: mỗi điểm yếu phải bao gồm gợi ý sửa chữa cụ thể, có thể thực hiện được; chỉ trích mơ hồ không được chấp nhận
- **Yêu cầu ánh xạ cấp khẳng định**: đầu ra phải bao gồm phần Ánh Xạ Thực Thể Wiki, ánh xạ kết quả đánh giá đến các thực thể wiki cụ thể
- **Chế độ adversarial phải tìm kiếm lỗi nghiêm trọng**: ví dụ: công trình giống hệt đã xuất bản, chứng minh không chính xác, rò rỉ dữ liệu
- **Đối thoại nhiều vòng giới hạn ở 3 vòng**: ngăn chặn vòng lặp vô hạn; xuất ra trạng thái hiện tại nếu 3 vòng không hội tụ
- **Sử dụng [[slug]] khi tham chiếu các trang wiki**: tất cả các tham chiếu đến các trang wiki sử dụng cú pháp wikilink

## Xử Lý Lỗi

- **Không tìm thấy tạo tác**: nhắc người dùng kiểm tra slug hoặc đường dẫn, liệt kê các trang ứng viên có khả năng
- **Review LLM không khả dụng**: chuyển xuống chế độ tự đánh giá của Claude; chú thích báo cáo với "đánh giá một mô hình, xác minh chéo giữa các mô hình không khả dụng"; khuyến nghị người dùng thử lại với Review LLM sau
- **Wiki trống**: tiến hành đánh giá bình thường, nhưng chú thích phần Ánh Xạ Thực Thể Wiki với "wiki trống, không có ánh xạ thực thể khả dụng"
- **Tạo tác quá dài**: nếu vượt quá cửa sổ ngữ cảnh của Review LLM, đánh giá theo từng phần và hợp nhất ở cuối
- **Review LLM trả về phản hồi không hợp lệ**: thử lại một lần; nếu vẫn không hợp lệ, sử dụng chế độ dự phòng tự đánh giá của Claude
- **Review LLM không hội tụ trong đối thoại nhiều vòng**: buộc dừng sau 3 vòng; xuất ra điểm số và tóm tắt của vòng cuối cùng

## Phụ Thuộc

### Công cụ (qua Bash)
- Không gọi công cụ trực tiếp (đánh giá không yêu cầu các công cụ xác định)

### Máy Chủ MCP
- `mcp__llm-review__chat` — đánh giá ban đầu của Review LLM (Bước 2)
- `mcp__llm-review__chat-reply` — đối thoại nhiều vòng với Review LLM (Bước 3)

### Claude Code Gốc
- `Read` — đọc tạo tác và các trang wiki
- `Glob` — tìm trang wiki tương ứng với tạo tác

### Tài Liệu Tham Khảo Chung
- `.claude/skills/shared-references/cross-model-review.md` — nguyên tắc độc lập của người đánh giá (yêu cầu đọc)

### Được Gọi Bởi
- `/ideate` Giai đoạn 4 (đánh giá các ý tưởng hàng đầu)
- `/refine` mỗi vòng lặp (đánh giá phiên bản hiện tại)
- `/exp-design --review` (đánh giá kế hoạch thí nghiệm)