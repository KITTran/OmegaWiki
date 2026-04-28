---
description: Thiết kế thí nghiệm dựa trên khẳng định — xác định phạm vi các khẳng định mục tiêu → thiết kế các khối thí nghiệm (baseline/validation/ablation/robustness) → xây dựng thứ tự chạy → tùy chọn đánh giá Review LLM → ghi vào wiki
argument-hint: "<slug-ý-tưởng-hoặc-giả-thuyết> [--review] [--budget <giờ-GPU>]"
---

# /exp-design

> Dựa trên một ý tưởng (hoặc một giả thuyết dạng văn bản tự do), thiết kế một kế hoạch thí nghiệm hoàn chỉnh.
> Khẳng định là cốt lõi: xác định phạm vi các khẳng định cần xác thực trên ba chiều — Mục tiêu, Phân rã và Mối đe dọa.
> Thiết kế bốn loại khối thí nghiệm: baseline (tái tạo baseline), validation (xác minh cốt lõi), ablation (cô lập yếu tố), và robustness (kiểm tra độ bền).
> Các thí nghiệm được sắp xếp theo thứ tự phụ thuộc với các cổng quyết định giữa các giai đoạn (thất bại kiểm tra tính hợp lý → dừng sớm).
> Tùy chọn đánh giá Review LLM để kiểm tra tính đầy đủ của kế hoạch thí nghiệm. Tất cả các thí nghiệm được ghi vào wiki/experiments/ với các cạnh đồ thị.

## Đầu Vào

- `idea`: một trong các mục sau:
  - Một slug từ wiki/ideas/ (ví dụ: `sparse-lora-for-edge-devices`)
  - Mô tả giả thuyết dạng văn bản tự do (cung cấp mục tiêu thí nghiệm trực tiếp)
- `--review` *(tùy chọn)*: kích hoạt đánh giá Review LLM để kiểm tra tính đầy đủ của kế hoạch thí nghiệm
- `--budget <giờ-GPU>` *(tùy chọn)*: giới hạn tổng ngân sách tính toán (giờ GPU), ảnh hưởng đến phạm vi thí nghiệm robustness

## Đầu Ra

- `wiki/experiments/{slug}.md` — một trang cho mỗi khối thí nghiệm (trạng thái: planned)
- `wiki/graph/edges.jsonl` — các cạnh tested_by mới: thí nghiệm → khẳng định
- `wiki/ideas/{slug}.md` — cập nhật trường linked_experiments
- `wiki/graph/context_brief.md` — xây dựng lại
- `wiki/graph/open_questions.md` — xây dựng lại
- `wiki/log.md` — thêm mục nhật ký
- **EXPERIMENT_PLAN_REPORT** *(in ra terminal)* — tóm tắt khối thí nghiệm, thứ tự chạy, ngân sách tính toán

## Tương Tác Wiki

### Đọc

- `wiki/ideas/{slug}.md` — giả thuyết, cách tiếp cận, rủi ro, origin_gaps của ý tưởng
- `wiki/claims/*.md` — trạng thái hiện tại, bằng chứng hiện có, độ tin cậy của các khẳng định mục tiêu
- `wiki/experiments/*.md` — các thí nghiệm hiện có (tránh thiết kế trùng lặp, tham khảo cấu hình thiết lập)
- `wiki/papers/*.md` — các bài báo liên quan với baseline và thiết lập thí nghiệm
- `wiki/concepts/*.md` — các khái niệm kỹ thuật liên quan (hướng dẫn thiết kế thí nghiệm)
- `wiki/graph/context_brief.md` — ngữ cảnh toàn cục
- `wiki/graph/open_questions.md` — các khoảng trống kiến thức (hướng dẫn ưu tiên thí nghiệm)

### Ghi

- `wiki/experiments/{slug}.md` — tạo trang thí nghiệm (một trang cho mỗi khối thí nghiệm)
- `wiki/ideas/{slug}.md` — cập nhật trường linked_experiments
- `wiki/graph/edges.jsonl` — thêm các cạnh tested_by
- `wiki/graph/context_brief.md` — xây dựng lại
- `wiki/graph/open_questions.md` — xây dựng lại
- `wiki/log.md` — thêm mục nhật ký hoạt động

### Các cạnh đồ thị được tạo

- `tested_by`: khẳng định → thí nghiệm (khẳng định được xác thực bởi thí nghiệm này)

## Quy Trình Làm Việc

**Điều kiện tiên quyết**: xác nhận thư mục làm việc là thư mục gốc dự án wiki (thư mục chứa `wiki/`, `raw/`, `tools/`).

### Bước 1: Tải Ngữ Cảnh

1. **Phân tích đầu vào ý tưởng**:
   - Nếu là slug: đọc `wiki/ideas/{slug}.md`, trích xuất `## Motivation`, `## Hypothesis`, `## Approach sketch`, `## Risks`, và các trường frontmatter `origin_gaps`, `tags`, `domain`, `priority` (theo mẫu ý tưởng trong CLAUDE.md)
   - Nếu là văn bản tự do: sử dụng trực tiếp như mô tả giả thuyết
2. **Tải ngữ cảnh wiki liên quan**:
   - Đọc `wiki/graph/context_brief.md` (ngữ cảnh toàn cục)
   - Đọc `wiki/graph/open_questions.md` (các khoảng trống kiến thức)
   - Từ `origin_gaps` của ý tưởng, đọc các `wiki/claims/*.md` tương ứng (các khẳng định mục tiêu)
   - Từ trường `source_papers` của mỗi khẳng định mục tiêu, đọc các `wiki/papers/*.md` tương ứng để lấy thiết lập baseline và giao thức thí nghiệm trước đó — đây là đường dẫn chính tắc từ ý tưởng → khẳng định → bài báo (ý tưởng **không** mang trường `linked_papers`; sử dụng `origin_gaps` → `source_papers` thay thế)
   - Đọc các `wiki/experiments/*.md` hiện có để kiểm tra các thí nghiệm tương tự
3. **Nếu ý tưởng không có origin_gaps**: trích xuất các khẳng định ngụ ý từ mô tả giả thuyết; tìm kiếm trong wiki/claims/ hoặc gắn cờ cần tạo khẳng định mới

### Bước 2: Xác Định Phạm Vi Khẳng Định

Xác định phạm vi các khẳng định cho kế hoạch thí nghiệm này trên ba chiều. Đối với mỗi chiều, tìm kiếm trong wiki/claims/ các khẳng định hiện có trước; nếu không có, tạo khẳng định mới (trạng thái: proposed, độ tin cậy: 0.3).

1. **Mục tiêu** *(cần xác thực gì)*:
   - Khẳng định tương ứng với giả thuyết cốt lõi của ý tưởng — mục tiêu chính mà kế hoạch thí nghiệm này trực tiếp xác thực
   - Thông thường là 1, tối đa 2
2. **Phân rã** *(cần phân rã gì)*:
   - Các khẳng định đóng góp riêng lẻ cho từng yếu tố độc lập trong phương pháp
   - Một khẳng định cho mỗi yếu tố, dùng để thiết kế các thí nghiệm cô lập
3. **Mối đe dọa** *(điều gì có thể bác bỏ chúng ta)*:
   - Các rủi ro đã biết, giải thích thay thế, điều kiện biên
   - Nguồn: bằng chứng phản bác trong wiki, hạn chế của bài báo, câu hỏi mở trong khẳng định
   - Hướng dẫn thiết kế thí nghiệm robustness

Đầu ra: danh sách các khẳng định đã xác định phạm vi (danh sách slug + chú thích chiều + trạng thái/độ tin cậy hiện tại cho mỗi khẳng định)

### Bước 3: Thiết Kế Các Khối Thí Nghiệm

Thiết kế các khối thí nghiệm cho từng khẳng định đã xác định phạm vi. Bốn loại:

**A. Thí nghiệm baseline (tái tạo baseline)**:
- Mục đích: xác nhận vấn đề tồn tại và baseline có thể tái tạo được
- Tái tạo thí nghiệm cốt lõi từ bài báo liên quan nhất
- Tiêu chí thành công: kết quả baseline sai lệch < 5% so với giá trị báo cáo trong bài báo (ngưỡng này giống với ngưỡng được sử dụng bởi cổng quyết định Giai đoạn 1 bên dưới — không đưa ra số khác ở nơi khác)
- Tính toán: thường là tối thiểu

**B. Thí nghiệm validation (xác minh khẳng định Mục tiêu)**:
- Mục đích: xác thực đóng góp cốt lõi trên baseline
- Chỉ số: cải thiện có ý nghĩa thống kê so với baseline
- Yêu cầu đủ số lượng seed/lần chạy để đảm bảo độ tin cậy (khuyến nghị >= 3 seeds)
- Tính toán: trung bình

**C. Thí nghiệm ablation (xác minh các khẳng định Phân rã)**:
- Mục đích: cô lập đóng góp của từng yếu tố độc lập
- Mỗi ablation loại bỏ một yếu tố và xác thực sự giảm hiệu suất kết quả
- N yếu tố → N thí nghiệm ablation
- Tính toán: tương tự validation × N

**D. Thí nghiệm robustness (loại trừ các Mối đe dọa)**:
- Mục đích: loại trừ các rủi ro đã biết và giải thích thay thế; xác minh phương pháp vẫn hiệu quả trong các điều kiện khác nhau
- Các chiều biến đổi: kích thước mô hình, tập dữ liệu, siêu tham số, lĩnh vực
- Kiểm tra ít nhất 2 chiều biến đổi
- Tính toán: phụ thuộc vào --budget

Mỗi khối thí nghiệm bao gồm:
- `title`: tiêu đề mô tả
- `target_claim`: slug khẳng định tương ứng
- `hypothesis`: giả thuyết cụ thể mà thí nghiệm kiểm tra
- `type`: baseline / validation / ablation / robustness
- `setup`: mô hình, tập dữ liệu, phần cứng, framework
- `metrics`: danh sách các chỉ số đánh giá
- `baseline`: baseline so sánh
- `success_criterion`: tiêu chí thành công/ thất bại rõ ràng
- `estimated_gpu_hours`: thời gian tính toán ước tính
- `seeds`: số lượng seed ngẫu nhiên (khuyến nghị >= 3)

### Bước 4: Xây Dựng Thứ Tự Chạy

Sắp xếp các thí nghiệm theo thứ tự phụ thuộc và thiết lập các cổng quyết định:

```
Giai đoạn 0: Kiểm tra tính hợp lý
  └── Chạy quy mô nhỏ (1 epoch / 100 bước) để xác minh không có lỗi code, dữ liệu tải được, GPU khả dụng, loss giảm
  └── Cổng: thất bại kiểm tra tính hợp lý → dừng, sửa code

Giai đoạn 1: Baseline (tái tạo baseline)
  └── Tái tạo kết quả baseline
  └── Cổng: độ lệch baseline > 5% → dừng, kiểm tra triển khai (ngưỡng giống với tiêu chí thành công ở Bước 3)

Giai đoạn 2: Validation (xác minh cốt lõi)
  └── Xác thực phương pháp cốt lõi trên baseline
  └── Cổng: không cải thiện → dừng, phân tích lý do (ý tưởng có thể không đúng)

Giai đoạn 3: Ablation (cô lập yếu tố)
  └── Nhiều ablation có thể chạy song song
  └── Cổng: nếu một ablation yếu tố không có tác dụng → ghi lại, nhưng tiếp tục các ablation khác

Giai đoạn 4: Robustness (xác minh độ bền)
  └── Chỉ thực hiện sau khi Giai đoạn 2 thành công
  └── Phạm vi được xác định bởi ngân sách --budget còn lại
```

Đầu ra:
- Danh sách thí nghiệm đã sắp xếp (với các phụ thuộc)
- Điều kiện cổng quyết định cho mỗi giai đoạn
- Ước tính tổng ngân sách tính toán (nếu vượt quá --budget, điều chỉnh phạm vi Giai đoạn 4)

### Bước 5: Đánh Giá Review LLM Tùy Chọn (--review)

Nếu `--review` được chỉ định:

```
mcp__llm-review__chat:
  system: "Bạn là một nhà nghiên cứu ML cao cấp đang đánh giá kế hoạch thí nghiệm.
           Tập trung vào: thiếu baseline, thiếu ablation, so sánh không công bằng,
           độ chặt chẽ thống kê (đủ seed?), và lựa chọn tập dữ liệu.
           Đối với mỗi vấn đề phát hiện, đề xuất một giải pháp cụ thể."
  message: |
    ## Kế Hoạch Thí Nghiệm
    {kế hoạch thí nghiệm hoàn chỉnh: khẳng định, khối, thứ tự chạy, ngân sách}

    ## Ngữ Cảnh
    {các khẳng định mục tiêu với trạng thái hiện tại, thiết lập thí nghiệm của các bài báo liên quan}

    ## Câu Hỏi Đánh Giá
    1. Có thiếu thí nghiệm quan trọng nào không?
    2. Các baseline có công bằng và toàn diện không?
    3. Thiết kế ablation có đủ để cô lập từng đóng góp không?
    4. Các tiêu chí thành công có được định nghĩa rõ ràng và hợp lý không?
    5. Có vấn đề thống kê nào không (kích thước mẫu, phương sai, seed)?"
```

Sửa đổi kế hoạch thí nghiệm dựa trên phản hồi của Review LLM (thêm thí nghiệm thiếu, điều chỉnh tiêu chí không hợp lý).

### Bước 6: Ghi Vào Wiki

1. **Tạo trang thí nghiệm**:
   Đối với mỗi khối thí nghiệm:
   ```bash
   python3 tools/research_wiki.py slug "<tiêu-đề-thí-nghiệm>"
   ```
   Tạo `wiki/experiments/{slug}.md`:
   Tạo `wiki/experiments/{slug}.md` theo **mẫu experiments trong CLAUDE.md chính xác** — mọi trường dưới đây phải có mặt ngay cả khi trống, vì `/exp-run` sau này sử dụng `tools/research_wiki.py set-meta` để cập nhật chúng, và `set-meta` từ chối tạo các trường không tồn tại trong frontmatter (chỉ cập nhật các khóa đã tồn tại):
   ```yaml
   ---
   title: ""
   slug: ""
   status: planned
   target_claim: ""          # slug khẳng định
   hypothesis: ""
   tags: []
   domain: ""
   setup:
     model: ""
     dataset: ""
     hardware: ""
     framework: ""
   metrics: []
   baseline: ""
   outcome: ""                # trống cho đến /exp-run Giai đoạn 4 — succeeded | failed | inconclusive
   key_result: ""             # trống cho đến /exp-run Giai đoạn 4
   linked_idea: "{idea-slug}" # BẮT BUỘC: slug ý tưởng nguồn (liên kết ngược đến wiki/ideas/{idea-slug}.md linked_experiments)
   date_planned: YYYY-MM-DD
   date_completed: ""         # trống cho đến /exp-run Giai đoạn 4
   run_log: ""                # trống cho đến /exp-run Giai đoạn 2
   started: ""                # trống cho đến /exp-run Giai đoạn 2 (dấu thời gian ISO, thiết lập qua set-meta)
   estimated_hours: 0         # 0 cho đến /exp-run Giai đoạn 2 (thiết lập qua set-meta)
   remote:                    # toàn bộ khối phải tồn tại để /exp-run --env remote có thể điền các trường con qua Edit
     server: ""
     gpu: ""
     session: ""
     started: ""
     completed: ""
   ---

   ## Mục Tiêu
   {mục đích của thí nghiệm này}

   ## Thiết Lập
   {thiết lập chi tiết: mô hình, tập dữ liệu, phần cứng, siêu tham số}

   ## Quy Trình
   {kế hoạch thực hiện từng bước}

   ## Kết Quả
   (sẽ được điền sau /exp-run)

   ## Phân Tích
   (sẽ được điền sau /exp-run)

   ## Cập Nhật Khẳng Định
   (sẽ được điền sau /exp-eval)

   ## Tiếp Theo
   {kế hoạch dự phòng: làm gì nếu thành công / thất bại}
   ```

2. **Tạo khẳng định mới (nếu các khẳng định thiếu được xác định ở Bước 2)**:
   ```bash
   python3 tools/research_wiki.py slug "<tiêu-đề-khẳng-định>"
   ```
   Tạo `wiki/claims/{slug}.md` (trạng thái: proposed, độ tin cậy: 0.3)

3. **Thêm cạnh đồ thị**:
   ```bash
   # Đối với mỗi thí nghiệm → khẳng định mục tiêu
   python3 tools/research_wiki.py add-edge wiki/ \
     --from "claims/{target-claim}" --to "experiments/{slug}" \
     --type tested_by --evidence "Được thiết kế bởi /exp-design"
   ```

4. **Cập nhật trang ý tưởng** (nếu ý tưởng đến từ wiki):
   - Thêm tất cả các slug thí nghiệm mới vào `linked_experiments` trong `wiki/ideas/{idea-slug}.md`
   - Nếu trạng thái ý tưởng là `proposed`, cập nhật thành `in_progress`

5. **Cập nhật index.md**: thêm mục vào các danh mục experiments và claims (nếu mới)

6. **Xây dựng lại dữ liệu phái sinh**:
   ```bash
   python3 tools/research_wiki.py rebuild-context-brief wiki/
   python3 tools/research_wiki.py rebuild-open-questions wiki/
   ```

7. **Thêm nhật ký**:
   ```bash
   python3 tools/research_wiki.py log wiki/ \
     "exp-design | {N} thí nghiệm được thiết kế cho ý tưởng {slug} | khẳng định: {danh-sách-khẳng-định}"
   ```

8. **In EXPERIMENT_PLAN_REPORT ra terminal**:
   ```markdown
   # Báo Cáo Kế Hoạch Thí Nghiệm

   ## Ý Tưởng Mục Tiêu
   - Ý tưởng: [[idea-slug]]
   - Giả thuyết: {giả thuyết}

   ## Các Khẳng Định Được Xác Định Phạm Vi
   | Khẳng định | Trạng thái hiện tại | Độ tin cậy | Chiều |
   |-------|---------------|------------|-----------|
   | [[claim-slug]] | proposed | 0.3 | mục tiêu |
   | [[claim-slug]] | weakly_supported | 0.5 | phân rã |

   ## Các Khối Thí Nghiệm
   | # | Thí nghiệm | Loại | Khẳng định | Giờ-GPU | Giai đoạn |
   |---|-----------|------|-------|---------|-------|
   | 1 | [[baseline-slug]] | baseline | — | 2 | 1 |
   | 2 | [[validation-slug]] | validation | mục tiêu | 8 | 2 |
   | 3 | [[ablation-1-slug]] | ablation | phân-rã-1 | 8 | 3 |
   | 4 | [[robustness-slug]] | robustness | mục tiêu | 16 | 4 |

   ## Thứ Tự Chạy
   Giai đoạn 0: Kiểm tra tính hợp lý → Giai đoạn 1: Baseline → Giai đoạn 2: Validation → Giai đoạn 3: Ablation → Giai đoạn 4: Robustness
   Cổng quyết định tại ranh giới mỗi giai đoạn.

   ## Ngân Sách
   - Tổng ước tính: {N} giờ-GPU
   - Giới hạn ngân sách: {--budget hoặc "không giới hạn"}

   ## Các Bước Tiếp Theo
   - Chạy `/exp-run [[baseline-slug]]` để bắt đầu Giai đoạn 1
   - Sau mỗi giai đoạn, chạy `/exp-eval` để cập nhật wiki
   ```

## Các Ràng Buộc

- **Mỗi thí nghiệm phải liên kết đến một khẳng định**: `target_claim` không được để trống (các thí nghiệm baseline có thể liên kết đến khẳng định Mục tiêu)
- **Không trùng lặp thí nghiệm**: trước khi tạo, kiểm tra wiki/experiments/ để tìm các thí nghiệm hiện có với cùng target_claim + hypothesis
- **Các khẳng định được xác định phạm vi không được sửa đổi**: các khẳng định được xác định phạm vi ở Bước 2 không được cập nhật trạng thái/độ tin cậy trong kế hoạch này — chỉ /exp-eval mới có thể cập nhật chúng
- **Tiêu chí thành công phải được định lượng**: tiêu chí thành công của mỗi khối thí nghiệm phải bao gồm một con số cụ thể (ví dụ: "> 2% cải thiện độ chính xác")
- **Ít nhất 3 seed**: các thí nghiệm yêu cầu độ tin cậy thống kê (validation, ablation) phải chỉ định >= 3 seed ngẫu nhiên
- **Các cạnh đồ thị thông qua tools/research_wiki.py**: không chỉnh sửa thủ công edges.jsonl
- **Trạng thái ý tưởng chỉ tiến về phía trước**: proposed → in_progress, không thể đảo ngược
- **Độ duy nhất của slug**: kiểm tra slug hiện có trước khi tạo

## Xử Lý Lỗi

- **Không tìm thấy ý tưởng**: nhắc người dùng kiểm tra slug, liệt kê các ứng viên trong wiki/ideas/
- **Khẳng định mục tiêu không tồn tại**: tự động tạo trang khẳng định mới (trạng thái: proposed, độ tin cậy: 0.3), gắn cờ trong báo cáo
- **Thí nghiệm tương tự đã tồn tại**: liệt kê các thí nghiệm hiện có, hỏi người dùng có muốn thêm hay bỏ qua
- **Review LLM không khả dụng** (chế độ --review): bỏ qua Bước 5, ghi chú "chưa được đánh giá — Review LLM không khả dụng" trong báo cáo
- **Ngân sách không đủ**: giảm phạm vi thí nghiệm robustness ở Giai đoạn 4, ghi chú phân bổ ngân sách thực tế trong báo cáo
- **Xung đột slug**: thêm hậu tố số (ví dụ: `sparse-lora-ablation-v2`)
- **Wiki trống**: tiến hành bình thường nhưng các thí nghiệm baseline không có kết quả trước đó để tham khảo; khuyến nghị chạy /ingest cho các bài báo liên quan trước

## Phụ Thuộc

### Công cụ (thông qua Bash)

- `python3 tools/research_wiki.py slug "<title>"` — tạo slug
- `python3 tools/research_wiki.py add-edge wiki/ ...` — thêm cạnh đồ thị
- `python3 tools/research_wiki.py rebuild-context-brief wiki/` — xây dựng lại query_pack
- `python3 tools/research_wiki.py rebuild-open-questions wiki/` — xây dựng lại gap_map
- `python3 tools/research_wiki.py log wiki/ "<message>"` — thêm nhật ký

### Máy Chủ MCP

- `mcp__llm-review__chat` — Bước 5 đánh giá kế hoạch thí nghiệm (tùy chọn)

### Claude Code Gốc

- `Read` — đọc các trang wiki
- `Glob` — tìm các thí nghiệm và khẳng định hiện có

### Tài Liệu Tham Khảo Chung

- `.claude/skills/shared-references/cross-model-review.md` — Bước 5 nguyên tắc độc lập đánh giá Review LLM (nếu được kích hoạt)

### Được Gọi Bởi

- `/research` Giai đoạn 2 (giai đoạn thiết kế thí nghiệm)
- Người dùng trực tiếp