---
description: Phân tích nhận xét phản biện → phân tách mối quan ngại (Rvx-Cy) → ánh xạ đến khẳng định wiki → kiểm tra bằng chứng → kiểm tra căng thẳng bằng Review LLM → tạo phản hồi
argument-hint: <tệp-nhận-xét-hoặc-đường-dẫn> [--paper-slug <slug>] [--venue <hội-nghị>] [--stress-test] [--format formal|rich]
---

# /rebuttal

> Phân tích nhận xét phản biện, phân tách từng mối quan ngại (đánh số Rvx-Cy) và ánh xạ đến khẳng định wiki,
> kiểm tra xem bằng chứng có đủ không (truy ngược về các thí nghiệm wiki),
> mô phỏng các câu hỏi tiếp theo của phản biện bằng Review LLM (kiểm tra căng thẳng, chấm điểm 1-5), và tạo
> phản hồi chính thức dạng văn bản thuần túy và phản hồi chi tiết dạng văn bản phong phú.
> Kiểm tra an toàn đảm bảo không bịa đặt, không hứa hẹn quá mức, và đầy đủ phạm vi.

## Đầu Vào

- `review`: nguồn nhận xét phản biện, một trong các mục sau:
  - đường dẫn tệp (ví dụ: `raw/reviews/reviewer1.txt`, `raw/reviews/meta-review.md`)
  - nhiều đường dẫn tệp (phân tách bằng dấu phẩy: `raw/reviews/R1.txt,raw/reviews/R2.txt,raw/reviews/R3.txt`)
  - văn bản nhận xét được dán trực tiếp
- `--paper-slug` *(tùy chọn)*: slug của bài báo liên quan trong wiki/outputs/, dùng để xác định PAPER_PLAN
- `--venue` *(tùy chọn)*: hội nghị/tạp chí mục tiêu (ICLR / NeurIPS / ICML / ACL / CVPR); ảnh hưởng đến định dạng phản hồi và giới hạn từ
- `--stress-test` *(tùy chọn, mặc định bật)*: Review LLM mô phỏng các câu hỏi tiếp theo của phản biện; tắt bằng `--no-stress-test`
- `--format` *(tùy chọn, mặc định `formal`)*: định dạng đầu ra
  - `formal`: phản hồi chính thức dạng văn bản thuần túy (phù hợp để dán trực tiếp vào hệ thống nộp)
  - `rich`: phiên bản văn bản phong phú (với [[liên kết wiki]], phân tích chi tiết, kế hoạch cải thiện)

## Đầu Ra

- **wiki/outputs/rebuttal-{slug}.md** — phản hồi chi tiết dạng văn bản phong phú (với [[liên kết wiki]], truy vết bằng chứng, bảng phân tích)
- **wiki/outputs/rebuttal-{slug}.txt** — phản hồi chính thức (văn bản thuần túy, phù hợp để dán vào hệ thống nộp)
- **wiki/claims/*.md** — nếu một mối quan ngại phát hiện lỗ hổng bằng chứng, thêm gợi ý vào `## Câu hỏi mở`
- **wiki/log.md** — thêm mục nhật ký

## Tương Tác Wiki

### Đọc

- `wiki/claims/*.md` — ánh xạ mối quan ngại đến khẳng định, kiểm tra tính đủ của bằng chứng
- `wiki/experiments/*.md` — tìm kết quả thí nghiệm hỗ trợ khẳng định
- `wiki/papers/*.md` — tìm ngữ cảnh trích dẫn cho các bài báo được tham chiếu
- `wiki/concepts/*.md` — hiểu bối cảnh khái niệm của các mối quan ngại liên quan đến phương pháp
- `wiki/ideas/*.md` — tìm động lực và kết quả thí điểm cho các ý tưởng
- `wiki/outputs/PAPER_PLAN.md` — hiểu cấu trúc bài báo (từ /paper-plan, nếu --paper-slug được cung cấp)
- `wiki/graph/context_brief.md` — ngữ cảnh toàn cục
- `wiki/graph/edges.jsonl` — mối quan hệ khẳng định-thí nghiệm-bài báo
- `.claude/skills/shared-references/cross-model-review.md` — nguyên tắc độc lập kiểm tra căng thẳng của Review LLM

### Ghi

- `wiki/outputs/rebuttal-{slug}.md` — phiên bản văn bản phong phú
- `wiki/outputs/rebuttal-{slug}.txt` — phiên bản văn bản thuần túy chính thức
- `wiki/claims/*.md` — thêm các lỗ hổng do phản biện phát hiện vào `## Câu hỏi mở` (không trực tiếp sửa đổi độ tin cậy/trạng thái; chỉ thêm gợi ý)
- `wiki/log.md` — thêm mục nhật ký

### Các cạnh đồ thị được tạo

- Không có (phản hồi là thao tác truy vấn; không sửa đổi đồ thị tri thức)

## Quy Trình Làm Việc

**Điều kiện tiên quyết**:
1. Xác nhận thư mục làm việc là thư mục gốc dự án wiki (chứa `wiki/`, `raw/`, `tools/`)
2. Đọc `cross-model-review.md` để xác nhận nguyên tắc độc lập kiểm tra căng thẳng
3. Tạo slug: `python3 tools/research_wiki.py slug "{paper-slug}-rebuttal"`

### Bước 1: Phân Tích Nhận Xét Phản Biện

1. **Đọc văn bản nhận xét**:
   - Nếu là đường dẫn tệp: đọc tất cả các tệp được chỉ định
   - Nếu là văn bản trực tiếp: sử dụng trực tiếp
   - Hợp nhất nhận xét của nhiều phản biện, chú thích theo nguồn (Phản biện 1/2/3/Meta)

2. **Xác định cấu trúc**:
   - Trích xuất từ mỗi phản biện: điểm tổng thể (Chấp nhận/Từ chối/Biên giới), độ tin cậy, tóm tắt, Điểm mạnh, Điểm yếu, câu hỏi
   - Nếu định dạng không chuẩn (văn bản thuần túy), sử dụng LLM để phân tích thành định dạng có cấu trúc

3. **Đầu ra**: nhận xét có cấu trúc cho mỗi phản biện

### Bước 2: Phân Tách Mối Quan Ngại

Tách từng điểm yếu và câu hỏi thành các mối quan ngại độc lập:

1. **Quy tắc phân tách**:
   - Một điểm yếu có thể là câu ghép chứa nhiều mối quan ngại độc lập ("phương pháp thiếu thí nghiệm ablation và cũng không so sánh với X" → tách thành 2 mối quan ngại)
   - Gán cho mỗi mối quan ngại độc lập một ID theo định dạng `Rvx-Cy` (Rv1-C1 = Phản biện 1, Mối quan ngại 1; Rv1-C2 = Phản biện 1, Mối quan ngại 2)
   - Giữ lại số phản biện để đảm bảo khả năng truy vết về nhận xét gốc

2. **Phân loại từng mối quan ngại**:
   - **bằng chứng**: câu hỏi thực tế về dữ liệu thí nghiệm hoặc diễn giải kết quả
   - **phương pháp**: câu hỏi về phương pháp về thiết kế phương pháp hoặc tính đúng đắn của thuật toán
   - **thiếu**: thiếu thí nghiệm/phân tích/so sánh/trích dẫn
   - **rõ ràng**: diễn đạt không rõ ràng, nhầm lẫn ký hiệu, vấn đề hình ảnh
   - **phạm vi**: đóng góp không đủ, câu hỏi về tính ứng dụng
   - **tính mới**: trùng lặp với công trình hiện có, thiếu đổi mới
   - **nhỏ**: định dạng, lỗi chính tả và các vấn đề nhỏ khác

3. **Đánh giá mức độ nghiêm trọng**: nghiêm trọng / lớn / nhỏ

4. **Đầu ra**: danh sách mối quan ngại đã phân tách, mỗi mục chứa {id (Rvx-Cy), phản biện, loại, mức độ nghiêm trọng, văn bản}

### Bước 3: Ánh Xạ Mối Quan Ngại Đến Khẳng Định Wiki

Đối với mỗi mối quan ngại:

1. **Tìm khẳng định liên quan**:
   - Trích xuất từ khóa từ văn bản mối quan ngại
   - Tìm kiếm `wiki/claims/*.md` để tìm khẳng định phù hợp
   - Đọc `wiki/graph/edges.jsonl` để tìm mối quan hệ khẳng định-thí nghiệm
   - Nếu không tìm thấy khớp trực tiếp: chú thích là "chưa ánh xạ" (không có khẳng định tương ứng trực tiếp)

2. **Kiểm Tra Trạng Thái Bằng Chứng**:
   - Đọc danh sách bằng chứng của khẳng định
   - Đếm bằng chứng mạnh/trung bình/yếu
   - Tìm kết quả của các thí nghiệm liên quan
   - **Đánh giá**:
     - Đủ: mạnh >= 1 hoặc trung bình >= 2
     - Một phần: bằng chứng tồn tại nhưng không đủ mạnh
     - Không đủ: không có bằng chứng hoặc chỉ có bằng chứng yếu
     - Mâu thuẫn: tồn tại bằng chứng loại invalidates

3. **Đầu ra**:

| ID Mối Quan Ngại | Phản Biện | Loại | Mức Độ Nghiêm Trọng | Khẳng Định Ánh Xạ | Trạng Thái Bằng Chứng | Chiến Lược |
|------------------|-----------|------|---------------------|-------------------|-----------------------|------------|
| Rv1-C1           | R1        | phương pháp | nghiêm trọng        | [[claim-slug]]    | đủ                    | A          |
| Rv1-C2           | R1        | thiếu      | lớn                 | [[claim-slug]]    | không đủ              | B          |
| Rv2-C1           | R2        | tính mới   | lớn                 | chưa ánh xạ       | —                     | D          |

### Bước 4: Soạn Thảo Phản Hồi

Soạn thảo phản hồi cho từng mối quan ngại theo chiến lược của nó:

**Chiến lược A — Bằng chứng đủ (phản hồi trực tiếp):**
- Trích dẫn kết quả thí nghiệm và dữ liệu cụ thể (chú thích nguồn, đảm bảo khả năng truy vết đến wiki/experiments/)
- Chỉ đến bằng chứng trong wiki (chuyển đổi thành trích dẫn bài báo)
- Nếu mối quan ngại dựa trên hiểu lầm: làm rõ một cách lịch sự, chỉ đến Phần liên quan trong bài báo

**Chiến lược B — Bằng chứng không đủ (thừa nhận + kế hoạch cụ thể):**
- Thẳng thắn thừa nhận rằng bằng chứng hiện tại không đủ
- Đề xuất kế hoạch thí nghiệm bổ sung cụ thể (có thể liên kết đến /exp-design)
- Nêu rõ thời gian và yêu cầu tài nguyên cụ thể
- Không sử dụng cam kết mơ hồ; chỉ cam kết các thí nghiệm bổ sung cụ thể và có thể thực hiện được

**Chiến lược C — Vấn đề rõ ràng (cam kết sửa đổi):**
- Thừa nhận diễn đạt không rõ ràng
- Cung cấp mô tả đã cải thiện (hiển thị văn bản đã sửa trực tiếp trong phản hồi)
- Liệt kê kế hoạch Sửa Đổi Bài Báo cụ thể

**Chiến lược D — Thách thức về phạm vi/tính mới (tranh luận):**
- Nhấn mạnh sự khác biệt cơ bản với các công trình hiện có
- Trích dẫn kết quả kiểm tra tính mới (nếu có)
- Chỉ ra những điểm khác biệt mà phản biện có thể đã bỏ qua

**Định dạng cho mỗi phản hồi**:
```markdown
**[Rvx-Cy]** {tóm tắt mối quan ngại}

{văn bản phản hồi, 2-5 câu, chú thích nguồn để truy vết}
```

**Kiểm tra an toàn (cho mỗi phản hồi)**:
- [ ] Không bịa đặt: không bịa đặt dữ liệu hoặc kết quả thí nghiệm
- [ ] Không hứa hẹn quá mức: chỉ cam kết các thí nghiệm bổ sung cụ thể và có thể thực hiện được
- [ ] Dữ liệu được trích dẫn được ghi lại trong wiki/experiments/
- [ ] Nếu khẳng định bị thách thức/không được chấp nhận, không giả vờ rằng nó được hỗ trợ

### Bước 5: Kiểm Tra Căng Thẳng Bằng Review LLM

**Tuân theo cross-model-review.md**: không gửi phân tích chiến lược phản hồi của Claude cho Review LLM.

Nếu `--stress-test` được bật (mặc định):

```
mcp__llm-review__chat:
  system: "Bạn là một phản biện nghiêm khắc vừa đọc phản hồi cho nhận xét của mình.
           Bạn sẽ hoài nghi và phản bác lại các phản hồi yếu.
           Đối với mỗi phản hồi, đánh giá theo thang điểm 1-5:
           1 = không thuyết phục (nghi ngờ né tránh hoặc bịa đặt)
           2 = yếu (mơ hồ, không có bằng chứng cụ thể)
           3 = chấp nhận được (giải quyết mối quan ngại nhưng có thể mạnh hơn)
           4 = mạnh (bằng chứng cụ thể, lập luận rõ ràng)
           5 = hoàn toàn thuyết phục (bằng chứng thuyết phục, phản hồi toàn diện)
           Ngoài ra, kiểm tra xem có hứa hẹn quá mức không: các cam kết có cụ thể và khả thi không?
           Đưa ra câu hỏi tiếp theo cho bất kỳ phản hồi nào có điểm <= 3."
  message: |
    ## Nhận Xét Phản Biện Gốc
    {danh sách mối quan ngại đã phân tách với ID Rvx-Cy}

    ## Phản Hồi Của Tác Giả
    {các phản hồi đã soạn thảo}

    ## Vui lòng đánh giá từng phản hồi (điểm 1-5) và đưa ra câu hỏi tiếp theo.
```

**Xử lý phản hồi của Review LLM**:
- **Điểm 4-5 (thuyết phục)**: giữ nguyên phản hồi
- **Điểm 3 (chấp nhận được)**: củng cố phản hồi, thêm chi tiết theo gợi ý của Review LLM
- **Điểm 1-2 (không thuyết phục/yếu)**: viết lại phản hồi, cân nhắc chuyển đổi chiến lược (A→B, thừa nhận không đủ)

**Vòng thứ hai (nếu có phản hồi nào có điểm <= 2)**:

```
mcp__llm-review__chat-reply:
  threadId: {luồng trước}
  message: |
    Chúng tôi đã sửa đổi các phản hồi sau:
    {các phản hồi đã sửa đổi}
    Vui lòng đánh giá lại (điểm 1-5).
```

Tối đa 2 vòng kiểm tra căng thẳng. Xử lý các câu hỏi tiếp theo và cập nhật phản hồi.

### Bước 6: Định Dạng Đầu Ra + Kiểm Tra An Toàn

**6a. Định dạng phản hồi chính thức rebuttal-{slug}.txt** (văn bản thuần túy, phù hợp cho hệ thống nộp):

```
Chúng tôi cảm ơn các phản biện đã đưa ra những nhận xét mang tính xây dựng. Chúng tôi giải quyết từng mối quan ngại dưới đây.

Phản biện 1:

[Rv1-C1] {tóm tắt mối quan ngại}
{phản hồi}

[Rv1-C2] {tóm tắt mối quan ngại}
{phản hồi}

Phản biện 2:
...

Tóm tắt các sửa đổi:
- {danh sách gạch đầu dòng các thay đổi dự kiến}

Các thí nghiệm bổ sung (nếu có):
- {các thí nghiệm mới cam kết, với thời gian biểu}
```

**6b. Định dạng phản hồi chi tiết rebuttal-{slug}.md**:

```markdown
# Phân Tích Phản Hồi: {tiêu đề bài báo}

## Tóm Tắt Phạm Vi
| ID Mối Quan Ngại | Loại | Mức Độ Nghiêm Trọng | Khẳng Định | Trạng Thái Bằng Chứng | Điểm Review LLM | Chiến Lược |
|------------------|------|---------------------|---------------|-----------------------|-----------------|------------|
| Rv1-C1           | phương pháp | nghiêm trọng        | [[claim-slug]] | đủ                    | 4/5            | A          |
| Rv1-C2           | thiếu      | lớn                 | [[claim-slug]] | không đủ              | 3/5            | B          |

## Phản Hồi
### Phản biện 1
**[Rv1-C1]** ...
**[Rv1-C2]** ...

## Phân Tích Lỗ Hổng Bằng Chứng
| Khẳng Định | Độ Tin Cậy | Lỗ Hổng | Cần Thiết |
|------------|------------|---------|-----------|
| [[claim-slug]] | 0.5        | Không có ablation trên tập dữ liệu X | Thực hiện thí nghiệm ablation |

## Các Hành Động Cần Thực Hiện

### Sửa Đổi Bài Báo
| Phần | Thay Đổi | Lý Do |
|------|----------|-------|
| Phần 3.2 | Làm rõ ký hiệu | Mối quan ngại rõ ràng Rv1-C3 |

### Cập Nhật Wiki
| Trang | Cập Nhật | Lý Do |
|-------|----------|-------|
| claims/{slug} | Thêm câu hỏi mở | Lỗ hổng bằng chứng Rv2-C1 |

### Các Thí Nghiệm Đề Xuất
| Thí Nghiệm | Khẳng Định Mục Tiêu | Được Đề Xuất Bởi |
|-------------|----------------------|------------------|
| ablation-dataset-x | [[claim-slug]] | Rv1-C2 |

→ Chạy `/exp-design ablation-dataset-x` để thiết kế theo dõi

## Tóm Tắt Kiểm Tra Căng Thẳng Review LLM
- Điểm trung bình: {N}/5
- Điểm 4-5: {N}/{tổng}
- Điểm 1-3: {N}/{tổng} (tất cả đã được sửa đổi)

## Danh Sách Kiểm Tra An Toàn
- [x] Không bịa đặt: tất cả dữ liệu được trích dẫn tồn tại trong wiki/experiments
- [x] Không hứa hẹn quá mức: tất cả các thí nghiệm cam kết đều cụ thể và khả thi
- [x] Đầy đủ phạm vi: {N}/{N} mối quan ngại đã được giải quyết (không bỏ sót)
- [x] Các khẳng định bị thách thức không được trình bày như được hỗ trợ
```

**6c. Kiểm tra an toàn cuối cùng**:
- **Đầy đủ phạm vi**: xác nhận mỗi mối quan ngại đều có phản hồi (không bỏ sót)
- **Không bịa đặt**: mọi điểm dữ liệu được trích dẫn đều được ghi lại trong wiki/experiments/ (có thể truy vết)
- **Không hứa hẹn quá mức**: các cam kết thí nghiệm bổ sung đều cụ thể và khả thi
- **Trung thực về các khẳng định yếu**: nếu độ tin cậy của khẳng định < 0.4, không giả vờ rằng bằng chứng là đủ

**6d. Cập nhật wiki**:
- Đối với các khẳng định có lỗ hổng bằng chứng: thêm các lỗ hổng do phản biện phát hiện vào `## Câu hỏi mở` trong `wiki/claims/{slug}.md`
- Thêm nhật ký:
  ```bash
  python3 tools/research_wiki.py log wiki/ \
    "rebuttal | {N} mối quan ngại đã giải quyết | {M} lỗ hổng bằng chứng | kiểm tra căng thẳng trung bình: {điểm}/5"
  ```

## Các Ràng Buộc

- **Không bịa đặt**: không bao giờ bịa đặt dữ liệu hoặc kết quả thí nghiệm. Mọi số liệu được trích dẫn phải có thể truy vết đến wiki/experiments/ với nguồn được chú thích
- **Không hứa hẹn quá mức**: chỉ cam kết các thí nghiệm bổ sung cụ thể và có thể thực hiện được. Sử dụng "chúng tôi sẽ thực hiện ablation trên X với thiết lập Y" thay vì "chúng tôi sẽ điều tra"
- **Đầy đủ phạm vi**: mọi mối quan ngại của phản biện (Rvx-Cy) phải có phản hồi; bỏ sót sẽ chặn đầu ra
- **Khả năng truy vết bằng chứng**: mọi bằng chứng được trích dẫn trong phản hồi phải có thể truy vết đến một trang wiki với nguồn slug được chú thích
- **Không trực tiếp sửa đổi khẳng định wiki**: phản hồi chỉ thêm gợi ý vào Câu hỏi mở của khẳng định; không sửa đổi độ tin cậy/trạng thái
- **Độc lập Review LLM**: trong quá trình kiểm tra căng thẳng, tuân theo cross-model-review.md; không tiết lộ chiến lược phản hồi cho Review LLM
- **Định dạng ID mối quan ngại**: sử dụng nghiêm ngặt định dạng Rvx-Cy (Rv1-C1, Rv1-C2, Rv2-C1) để đảm bảo khả năng truy vết
- **Cam kết cụ thể**: tất cả các cam kết sửa đổi và kế hoạch thí nghiệm phải cụ thể (Phần cụ thể, tập dữ liệu cụ thể, chỉ số rõ ràng)
- **Đầu ra vào wiki/outputs/**: các tệp phản hồi được lưu trữ đồng nhất trong thư mục wiki/outputs/

## Xử Lý Lỗi

- **Không tìm thấy tệp nhận xét**: báo lỗi, liệt kê các tệp có sẵn trong raw/reviews/
- **Không thể phân tích định dạng nhận xét**: chuyển sang xử lý văn bản thuần túy; sử dụng LLM để trích xuất mối quan ngại; chú thích trong báo cáo
- **Mối quan ngại không thể ánh xạ đến khẳng định (chưa ánh xạ)**: chú thích là "chưa ánh xạ"; vẫn phản hồi (dựa trên nội dung bài báo thay vì khẳng định wiki)
- **Kiểm tra căng thẳng Review LLM không khả dụng**: bỏ qua Bước 5; chú thích trong báo cáo "bỏ qua kiểm tra căng thẳng: Review LLM không khả dụng"
- **Bằng chứng cực kỳ không đủ**: nếu >50% mối quan ngại có bằng chứng không đủ, cảnh báo người dùng và đề xuất bổ sung thí nghiệm trước
- **Wiki trống**: cảnh báo rằng cơ sở tri thức wiki trống; đề xuất chạy /ingest để điền khẳng định và thí nghiệm
- **Tất cả phản hồi đều được Review LLM chấm điểm 1-2**: dừng đầu ra, báo cáo cần phân tích lại, đề xuất bổ sung thí nghiệm trước

## Phụ Thuộc

### Công cụ (thông qua Bash)

- `python3 tools/research_wiki.py slug "{title}"` — tạo slug phản hồi
- `python3 tools/research_wiki.py log wiki/ "<message>"` — thêm mục nhật ký

### Máy Chủ MCP

- `mcp__llm-review__chat` — Bước 5 kiểm tra căng thẳng vòng đầu
- `mcp__llm-review__chat-reply` — Bước 5 kiểm tra căng thẳng các vòng tiếp theo

### Claude Code Gốc

- `Read` — đọc nhận xét phản biện, trang wiki, tài liệu tham khảo chung
- `Write` — ghi rebuttal-{slug}.md, rebuttal-{slug}.txt
- `Glob` — tìm khẳng định, thí nghiệm
- `Grep` — tìm kiếm trong wiki các từ khóa mối quan ngại

### Tài Liệu Tham Khảo Chung

- `.claude/skills/shared-references/cross-model-review.md` — nguyên tắc độc lập kiểm tra căng thẳng của Review LLM

### Kỹ Năng Tiếp Theo Được Đề Xuất

- `/exp-design` — thiết kế thí nghiệm bổ sung cho các mối quan ngại có bằng chứng không đủ
- `/paper-draft` — chuẩn bị bài báo đã sửa đổi (dựa trên danh sách Sửa Đổi Bài Báo)