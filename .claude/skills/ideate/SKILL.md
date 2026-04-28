---
description: Tạo ý tưởng nghiên cứu từ một hướng, khoảng trống hoặc khẳng định — quy trình 4 giai đoạn (phân kỳ → hội tụ → kiểm tra tính mới lạ → đánh giá) → các ý tưởng hàng đầu được ghi vào wiki
argument-hint: "<hướng|khoảng-trống|slug-khẳng-định> [--count <N>] [--review] [--budget <giờ-GPU>]"
---

# /ideate

> Tạo ý tưởng nghiên cứu từ một hướng nghiên cứu, khoảng trống kiến thức hoặc khẳng định.
> Quy trình bốn giai đoạn: tạo ý tưởng phân kỳ → xếp hạng hội tụ → kiểm tra tính mới lạ → đánh giá Review LLM.
> Các ý tưởng hàng đầu được ghi vào wiki/ideas/ với các cạnh đồ thị đến khoảng trống nguồn và các khẳng định liên kết.

## Đầu Vào

- `seed`: một trong các mục sau:
  - Một hướng nghiên cứu (văn bản tự do, ví dụ: "hiệu quả suy luận LLM trên thiết bị")
  - Một slug khoảng trống kiến thức từ wiki/graph/open_questions.md (ví dụ: `sparse-lora-for-edge-devices`)
  - Một slug khẳng định từ wiki/claims/ (ví dụ: `sparse-lora-reduces-memory-usage`)
- `--count <N>` *(tùy chọn, mặc định 3)*: số lượng ý tưởng hàng đầu được ghi vào wiki
- `--review` *(tùy chọn)*: kích hoạt đánh giá Review LLM cho các ý tưởng hàng đầu (Giai đoạn 4)
- `--budget <giờ-GPU>` *(tùy chọn, mặc định 100)*: giới hạn tổng ngân sách tính toán (giờ GPU), ảnh hưởng đến tính khả thi của ý tưởng

## Đầu Ra

- `wiki/ideas/{slug}.md` — N ý tưởng hàng đầu (trạng thái: proposed)
- `wiki/graph/edges.jsonl` — các cạnh inspired_by mới: ý tưởng → khoảng trống/khẳng định
- `wiki/graph/context_brief.md` — xây dựng lại
- `wiki/graph/open_questions.md` — xây dựng lại
- `wiki/log.md` — thêm mục nhật ký
- **IDEATION_REPORT** *(in ra terminal)* — tóm tắt quy trình, các ý tưởng hàng đầu, gợi ý bước tiếp theo

## Tương Tác Wiki

### Đọc

- `wiki/graph/open_questions.md` — nếu seed là slug khoảng trống, đọc mô tả khoảng trống
- `wiki/claims/{slug}.md` — nếu seed là slug khẳng định, đọc phát biểu khẳng định và trạng thái
- `wiki/ideas/*.md` — các ý tưởng hiện có (tránh trùng lặp, tham khảo các ý tưởng tương tự)
- `wiki/papers/*.md` — các bài báo liên quan (hướng dẫn tạo ý tưởng)
- `wiki/concepts/*.md` — các khái niệm liên quan (hướng dẫn tạo ý tưởng)
- `wiki/graph/context_brief.md` — ngữ cảnh toàn cục
- `.claude/skills/shared-references/cross-model-review.md` — Giai đoạn 4 nguyên tắc độc lập của Review LLM

### Ghi

- `wiki/ideas/{slug}.md` — tạo trang ý tưởng (N ý tưởng hàng đầu)
- `wiki/graph/edges.jsonl` — thêm các cạnh inspired_by
- `wiki/graph/context_brief.md` — xây dựng lại
- `wiki/graph/open_questions.md` — xây dựng lại
- `wiki/log.md` — thêm nhật ký hoạt động

### Các cạnh đồ thị được tạo

- `inspired_by`: ý tưởng → khoảng trống/khẳng định (ý tưởng được lấy cảm hứng từ khoảng trống hoặc khẳng định)

## Quy Trình Làm Việc

**Điều kiện tiên quyết**: xác nhận thư mục làm việc là thư mục gốc dự án wiki (thư mục chứa `wiki/`, `raw/`, `tools/`).

### Giai đoạn 1: Tạo Ý Tưởng Phân Kỳ (100 ý tưởng)

1. **Tải ngữ cảnh seed**:
   - Nếu seed là slug khoảng trống: đọc `wiki/graph/open_questions.md`, trích xuất mô tả khoảng trống
   - Nếu seed là slug khẳng định: đọc `wiki/claims/{slug}.md`, trích xuất phát biểu khẳng định, trạng thái và bằng chứng
   - Nếu seed là văn bản tự do: sử dụng trực tiếp như hướng nghiên cứu
2. **Tải ngữ cảnh liên quan**:
   - Đọc `wiki/graph/context_brief.md` (ngữ cảnh toàn cục)
   - Đọc các bài báo liên quan (từ source_papers của khẳng định hoặc các bài báo liên quan của khoảng trống)
   - Đọc các khái niệm liên quan (từ bài báo hoặc khẳng định)
3. **Tạo 100 ý tưởng** (tư duy phân kỳ):
   - Sử dụng Claude để tạo 100 bản phác thảo ý tưởng một câu
   - Mỗi ý tưởng phải cụ thể, khả thi và có thể kiểm chứng
   - Định dạng: `{phương pháp} để {mục tiêu} cho {vấn đề}`
   - Ví dụ: "Bộ điều hợp LoRA thưa thớt để giảm sử dụng bộ nhớ cho suy luận LLM trên thiết bị"
4. **Loại bỏ trùng lặp**: loại bỏ các bản sao chính xác và gần giống (sử dụng độ tương đồng ngữ nghĩa)
5. **Đầu ra**: 100 bản phác thảo ý tưởng duy nhất

### Giai đoạn 2: Xếp Hạng Hội Tụ (top 10)

1. **Xếp hạng ý tưởng** theo bốn tiêu chí (mỗi tiêu chí 1-5, cao hơn tốt hơn):
   - **Tính mới lạ**: ý tưởng mới đến mức nào? (1 = gia tăng, 5 = đột phá)
   - **Tính khả thi**: dễ triển khai đến mức nào? (1 = rất khó, 5 = dễ)
   - **Tác động**: vấn đề quan trọng đến mức nào? (1 = ngách, 5 = quan trọng)
   - **Sự phù hợp**: phù hợp với seed đến mức nào? (1 = lạc đề, 5 = hoàn toàn phù hợp)
2. **Tính điểm tổng**: `novelty × impact × feasibility × alignment` (trung bình nhân để tránh điểm 0)
3. **Chọn top 10** theo điểm tổng
4. **Đầu ra**: top 10 ý tưởng với điểm và lý do ngắn gọn

### Giai đoạn 3: Kiểm Tra Tính Mới Lạ (top 5)

1. **Đối với mỗi ý tưởng trong top 10**, chạy `/novelty` song song (sử dụng công cụ Agent):
   ```
   Skill: novelty
   Args: "{idea-sketch} --quick"
   ```
2. **Trích xuất điểm tính mới lạ** (1-5) từ mỗi báo cáo
3. **Xếp hạng lại**: nhân điểm Giai đoạn 2 với điểm tính mới lạ (điểm có trọng số tính mới lạ)
4. **Chọn top 5** theo điểm có trọng số tính mới lạ
5. **Đầu ra**: top 5 ý tưởng với điểm tính mới lạ và tóm tắt công trình hiện có

### Giai đoạn 4: Đánh Giá Review LLM (top N, tùy chọn)

Nếu `--review` được chỉ định:

1. **Đối với mỗi ý tưởng trong top 5**, gửi đến Review LLM để đánh giá độc lập:
   ```
   mcp__llm-review__chat:
     system: "Bạn là một nhà nghiên cứu ML cao cấp đang đánh giá các ý tưởng nghiên cứu.
              Tập trung vào: tính mới lạ, tính khả thi, tác động tiềm năng và sự phù hợp với seed.
              Đối với mỗi mối quan ngại, đề xuất một cải tiến cụ thể."
     message: |
       ## Seed
       {mô tả seed}

       ## Ý tưởng
       {tiêu đề và bản phác thảo ý tưởng}

       ## Câu hỏi đánh giá
       1. Ý tưởng này có mới lạ không? Nếu không, công trình gần nhất là gì?
       2. Nó có khả thi trong ngân sách hợp lý không? Những rủi ro lớn nhất là gì?
       3. Tác động tiềm năng nếu thành công là gì?
       4. Nó có giải quyết tốt seed không? Nếu không, làm thế nào để điều chỉnh?
       5. Đề xuất 1-2 cải tiến cụ thể cho ý tưởng.
   ```
2. **Tổng hợp phản hồi của Review LLM** với đánh giá của Claude:
   - Nếu Review LLM phát hiện lỗi nghiêm trọng (ví dụ: đã được công bố), loại bỏ ý tưởng
   - Nếu Review LLM đề xuất cải tiến, tinh chỉnh ý tưởng
3. **Xếp hạng lại top 5** dựa trên phản hồi của Review LLM
4. **Đầu ra**: top N ý tưởng (N = --count, mặc định 3) với phản hồi của Review LLM

Nếu `--review` không được chỉ định, sử dụng top N ý tưởng từ Giai đoạn 3.

### Bước 5: Ghi Vào Wiki

1. **Tạo trang ý tưởng**:
   Đối với mỗi ý tưởng trong top N:
   ```bash
   python3 tools/research_wiki.py slug "{tiêu-đề-ý-tưởng}"
   ```
   Tạo `wiki/ideas/{slug}.md`:
   ```yaml
   ---
   title: "{tiêu đề ý tưởng}"
   slug: "{slug}"
   status: proposed
   origin_gaps: ["{gap-or-claim-slug}"]  # nếu seed là khoảng trống hoặc khẳng định
   tags: []
   domain: "{suy ra từ seed}"
   priority: 3  # 1-5, mặc định 3
   pilot_result: ""  # trống cho đến /exp-run
   failure_reason: ""  # trống cho đến khi ý tưởng thất bại
   linked_experiments: []
   date_proposed: YYYY-MM-DD
   date_resolved: ""  # trống cho đến khi được xác thực/thất bại
   ---

   ## Động Lực
   {tại sao ý tưởng này quan trọng}

   ## Giả Thuyết
   {khẳng định cụ thể, có thể kiểm chứng}

   ## Bản Phác Thảo Cách Tiếp Cận
   {mô tả phương pháp cấp cao}

   ## Rủi Ro
   {các cạm bẫy và thách thức tiềm ẩn}

   ## Các Ý Tưởng Liên Quan
   {liên kết đến các ý tưởng tương tự trong wiki}

   ## Kiểm Tra Tính Mới Lạ
   {tóm tắt báo cáo /novelty}

   ## Phản Hồi Đánh Giá
   {phản hồi của Review LLM (nếu --review được sử dụng)}
   ```

2. **Thêm cạnh đồ thị**:
   ```bash
   # Đối với mỗi ý tưởng → seed (khoảng trống hoặc khẳng định)
   python3 tools/research_wiki.py add-edge wiki/ \
     --from "ideas/{slug}" --to "{gap-or-claim-type}/{slug}" \
     --type inspired_by --evidence "Được tạo bởi /ideate từ {seed}"
   ```

3. **Cập nhật index.md**: thêm mục vào danh mục ý tưởng

4. **Xây dựng lại dữ liệu phái sinh**:
   ```bash
   python3 tools/research_wiki.py rebuild-context-brief wiki/
   python3 tools/research_wiki.py rebuild-open-questions wiki/
   ```

5. **Thêm nhật ký**:
   ```bash
   python3 tools/research_wiki.py log wiki/ \
     "ideate | {N} ý tưởng được tạo từ {seed} | hàng đầu: {danh-sách-slug}"
   ```

6. **In IDEATION_REPORT ra terminal**:
   ```markdown
   # Báo Cáo Tạo Ý Tưởng: {seed}

   ## Tóm Tắt Quy Trình
   | Giai đoạn | Đầu vào | Đầu ra | Bộ lọc |
   |-------|-------|--------|--------|
   | Phân kỳ | 1 seed | 100 ý tưởng | — |
   | Hội tụ | 100 ý tưởng | 10 ý tưởng | novelty × impact × feasibility × alignment |
   | Tính mới lạ | 10 ý tưởng | 5 ý tưởng | điểm /novelty |
   | Đánh giá | 5 ý tưởng | {N} ý tưởng | phản hồi Review LLM |

   ## Top {N} Ý Tưởng
   | Hạng | Ý tưởng | Điểm | Tính mới lạ | Khả thi | Tác động | Sự phù hợp |
   |------|------|-------|---------|-------------|--------|-----------|
   | 1 | [[idea-slug]] | 4.2 | 4 | 3 | 5 | 5 |
   | 2 | [[idea-slug]] | 3.8 | 3 | 4 | 5 | 4 |

   ## Bước Tiếp Theo
   - Chạy `/exp-design [[idea-slug]]` để thiết kế thí nghiệm cho ý tưởng hàng đầu
   - Chạy `/ideate --review` để có ý kiến thứ hai về các ý tưởng hàng đầu
   - Chạy `/research [[idea-slug]]` để bắt đầu quy trình nghiên cứu đầy đủ
   ```

## Các Ràng Buộc

- **Ý tưởng phải cụ thể và có thể kiểm chứng**: tránh các ý tưởng mơ hồ như "cải thiện hiệu suất mô hình" — phải chỉ rõ cách thức
- **Các cạnh đồ thị thông qua tools/research_wiki.py**: không chỉnh sửa thủ công edges.jsonl
- **Tính độc lập của Review LLM**: tuân thủ nghiêm ngặt cross-model-review.md — không gửi đánh giá trước của Claude đến Review LLM
- **Kiểm tra tính mới lạ là bắt buộc**: không thể bỏ qua Giai đoạn 3
- **Top N giới hạn ở 5**: --count không thể vượt quá 5
- **Trạng thái ý tưởng bắt đầu là proposed**: chỉ /exp-eval mới có thể chuyển sang validated/failed
- **failure_reason là bộ nhớ chống lặp lại**: phải được viết rõ ràng khi một ý tưởng thất bại
- **Không sửa đổi các ý tưởng hiện có**: chỉ tạo trang ý tưởng mới
- **Loại bỏ trùng lặp nghiêm ngặt**: loại bỏ các ý tưởng gần giống để tránh ý tưởng dư thừa

## Xử Lý Lỗi

- **Không tìm thấy seed**: nhắc người dùng kiểm tra slug, liệt kê các ứng viên trong wiki/graph/open_questions.md hoặc wiki/claims/
- **Không tạo được ý tưởng**: báo lỗi, đề xuất nới lỏng seed hoặc thử hướng khác
- **Review LLM không khả dụng** (chế độ --review): bỏ qua Giai đoạn 4, ghi chú "chưa được đánh giá — Review LLM không khả dụng" trong báo cáo
- **Kiểm tra tính mới lạ thất bại** (Giai đoạn 3): bỏ qua ý tưởng, tiếp tục với ý tưởng tiếp theo, ghi chú trong báo cáo
- **Xung đột slug**: thêm hậu tố số (ví dụ: `sparse-lora-v2`)
- **Wiki trống**: tiến hành bình thường, nhưng việc tạo ý tưởng sẽ ít thông tin hơn
- **Ngân sách quá thấp**: cảnh báo người dùng rằng điểm tính khả thi có thể lạc quan

## Phụ Thuộc

### Kỹ Năng (thông qua công cụ Skill)

- `/novelty` — Giai đoạn 3 kiểm tra tính mới lạ (gọi song song)

### Công cụ (thông qua Bash)

- `python3 tools/research_wiki.py slug "<title>"` — tạo slug
- `python3 tools/research_wiki.py add-edge wiki/ ...` — thêm cạnh đồ thị
- `python3 tools/research_wiki.py rebuild-context-brief wiki/` — xây dựng lại query_pack
- `python3 tools/research_wiki.py rebuild-open-questions wiki/` — xây dựng lại gap_map
- `python3 tools/research_wiki.py log wiki/ "<message>"` — thêm nhật ký

### Máy Chủ MCP

- `mcp__llm-review__chat` — Giai đoạn 4 đánh giá độc lập của Review LLM (tùy chọn)

### Claude Code Gốc

- `Read` — đọc các trang wiki
- `Glob` — tìm các ý tưởng hiện có
- `Agent` — gọi /novelty song song trong Giai đoạn 3

### Tài Liệu Tham Khảo Chung

- `.claude/skills/shared-references/cross-model-review.md` — Giai đoạn 4 nguyên tắc độc lập của Review LLM (bắt buộc đọc)

### Được Gọi Bởi

- `/research` Giai đoạn 1 (giai đoạn tạo ý tưởng)
- Người dùng trực tiếp

### Gọi Đến

- `/novelty` (Giai đoạn 3) — kiểm tra tính mới lạ song song
- `/exp-design` (được đề xuất trong báo cáo) — thiết kế thí nghiệm cho các ý tưởng hàng đầu
- `/research` (được đề xuất trong báo cáo) — bắt đầu quy trình nghiên cứu đầy đủ
- `/ideate --review` (được đề xuất trong báo cáo) — có ý kiến thứ hai về các ý tưởng