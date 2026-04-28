---
description: Điều phối nghiên cứu đầu-cuối — khám phá ý tưởng → thiết kế thí nghiệm → thực thi → phán quyết → viết bài báo, với các cổng kiểm soát của con người và trạng thái có thể tiếp tục phiên
argument-hint: <hướng-nghiên-cứu-hoặc-tóm-tắt> [--auto] [--start-from stage1|stage2|stage3|stage3-collect|stage3-check|stage4|stage5] [--skip-paper] [--venue ICLR|NeurIPS|ICML|ACL|CVPR]
---

# /research

> Điều phối nghiên cứu đầu-cuối kết hợp tất cả các kỹ năng thành một quy trình nghiên cứu hoàn chỉnh.
> Giai đoạn 0 (Khởi tạo) + 5 Giai đoạn + 2 Cổng Kiểm soát của Con người, bao phủ toàn bộ quy trình từ wiki trống đến nộp bài báo.
> **Điểm nhập không ma sát**: nếu wiki trống, Giai đoạn Khởi tạo được kích hoạt tự động (tìm kiếm + tự động ingest 5 bài báo); không cần chạy /init thủ công.
> Mỗi Cổng và Giai đoạn lưu tiến trình vào `wiki/outputs/pipeline-progress.md`, hỗ trợ khôi phục giữa các phiên.
>
> **Giai đoạn 3 không chặn**: các thí nghiệm được triển khai và điều khiển trả về ngay lập tức (`--auto` tự động thiết lập CronCreate để giám sát mỗi 30 phút).
> Khi tất cả các thí nghiệm hoàn thành, Giai đoạn 4 được kích hoạt tự động. Sử dụng `/exp-status` bất kỳ lúc nào để kiểm tra tiến trình.
>
> `--auto` bỏ qua xác nhận thủ công (tự động chọn ý tưởng hàng đầu). `--skip-paper` chạy nghiên cứu mà không viết bài báo.

## Đầu Vào

- `direction`: mô tả hướng nghiên cứu hoặc đường dẫn đến tệp `RESEARCH_BRIEF.md`
  - Dạng văn bản: mô tả một câu về hướng nghiên cứu (ví dụ: "sparse LoRA cho thiết bị biên")
  - Dạng tệp: RESEARCH_BRIEF.md có cấu trúc (chứa domain, ràng buộc, hội nghị mục tiêu)
- `--auto` *(tùy chọn)*: chế độ hoàn toàn tự động; Cổng 1 tự động chọn ý tưởng hàng đầu, Cổng 2 tự động tiếp tục, Giai đoạn 3b tự động tạo CronCreate
- `--start-from <stage>` *(tùy chọn)*: tiếp tục thực thi từ giai đoạn được chỉ định
  - Giá trị hợp lệ: `stage1`, `stage2`, `stage3`, `stage3-collect`, `stage3-check`, `stage4`, `stage5`
  - `stage3-collect`: bỏ qua triển khai, chuyển thẳng đến Giai đoạn 3c (thu thập kết quả từ các thí nghiệm đã triển khai)
  - `stage3-check`: chỉ kiểm tra trạng thái thí nghiệm (tương đương với `/exp-status --pipeline {slug}`), không tiếp tục thực thi
  - Yêu cầu `wiki/outputs/pipeline-progress.md` phải tồn tại
- `--skip-paper` *(tùy chọn)*: chỉ chạy nghiên cứu (Giai đoạn 1-4), bỏ qua viết bài báo (Giai đoạn 5), nhưng vẫn chạy /exp-eval (Giai đoạn 4)
- `--venue` *(tùy chọn)*: hội nghị mục tiêu (ICLR / NeurIPS / ICML / ACL / CVPR), chuyển đến /paper-plan

## Đầu Ra

- **Cập nhật wiki** (ủy quyền cho các kỹ năng con): ideas/, experiments/, claims/, outputs/, graph/
- **wiki/outputs/pipeline-progress.md** — ảnh chụp tiến trình pipeline (để khôi phục)
- **wiki/outputs/PIPELINE_REPORT.md** — báo cáo pipeline đầy đủ
- **thư mục paper/** (nếu không có --skip-paper) — bài báo có thể nộp
- **wiki/log.md** — nhật ký được thêm sau mỗi giai đoạn

## Tương Tác Wiki

### Đọc

- `wiki/graph/context_brief.md` — ngữ cảnh toàn cục (chuyển đến các kỹ năng con)
- `wiki/graph/open_questions.md` — lỗ hổng kiến thức (chuyển đến /ideate)
- `wiki/ideas/*.md` — Lựa chọn Cổng 1, phán quyết Giai đoạn 4
- `wiki/experiments/*.md` — Kiểm tra trạng thái Giai đoạn 3-4
- `wiki/claims/*.md` — Phán quyết Giai đoạn 4, lập kế hoạch bài báo Giai đoạn 5
- `wiki/outputs/pipeline-progress.md` — khôi phục trạng thái --start-from
- `wiki/papers/*.md` — ngữ cảnh viết bài báo Giai đoạn 5

### Ghi

- `wiki/outputs/pipeline-progress.md` — lưu tiến trình tại mỗi Cổng (các ghi thực thể wiki được ủy quyền cho các kỹ năng con)
- `wiki/outputs/PIPELINE_REPORT.md` — báo cáo cuối cùng
- `wiki/log.md` — thêm mục nhật ký
- Tất cả các ghi thực thể wiki khác được ủy quyền cho các kỹ năng con (không ghi trực tiếp vào ideas/experiments/claims/)

### Các cạnh đồ thị được tạo

- Không trực tiếp — tất cả các cạnh đồ thị được ủy quyền cho các kỹ năng con (/ideate, /exp-design, /exp-eval mỗi kỹ năng tạo cạnh riêng)

## Quy Trình Làm Việc

**Điều kiện tiên quyết**:
1. Xác nhận thư mục làm việc là thư mục gốc dự án wiki (chứa `wiki/`, `raw/`, `tools/`)
2. Nếu `--start-from` được chỉ định, đọc `wiki/outputs/pipeline-progress.md` để khôi phục trạng thái

### Bước 0: Khởi Tạo

1. **Phân tích đầu vào**:
   - Nếu là đường dẫn tệp: đọc RESEARCH_BRIEF.md, trích xuất direction, domain, ràng buộc, target_venue
   - Nếu là văn bản: sử dụng làm direction; để trống domain/ràng buộc
   - Tạo slug: `python3 tools/research_wiki.py slug "{direction}"`

2. **Phát hiện tự động khôi phục** (khi `--start-from` không được chỉ định):
   - Nếu `wiki/outputs/pipeline-progress.md` tồn tại và `status == running`:
     - Đọc direction, current_stage, started, slug
     - Sử dụng AskUserQuestion để nhắc người dùng:
       ```
       Phát hiện pipeline chưa hoàn thành:
       Hướng: {direction}
       Giai đoạn hiện tại: {current_stage}
       Bắt đầu: {started}

       [1] Tiếp tục từ {current_stage} (đề xuất)
       [2] Bắt đầu pipeline mới (sẽ ghi đè tiến trình cũ)
       [3] Xem trạng thái thí nghiệm trước (/exp-status --pipeline {slug})
       ```
     - Nếu --auto hoặc người dùng chọn [1]: tự động đặt `--start-from {current_stage}`, tiếp tục thực thi
     - Nếu người dùng chọn [2]: tiếp tục tạo pipeline mới (ghi đè tệp tiến trình cũ)
     - Nếu người dùng chọn [3]: gọi `/exp-status --pipeline {slug}` sau đó thoát mà không tiếp tục

3. **Kiểm tra khôi phục** (khi `--start-from` được chỉ định):
   - Nếu `wiki/outputs/pipeline-progress.md` tồn tại:
     - Đọc tệp tiến trình, khôi phục idea_slug, experiment_slugs, stage3a_deployed, claim_slugs, monitoring_cron_id
     - Chuyển đến giai đoạn được chỉ định
   - Nếu tệp tiến trình không tồn tại: báo lỗi và thoát; nhắc người dùng chạy pipeline đầy đủ trước
   - **`--start-from stage3-check`**: tương đương với gọi `/exp-status --pipeline {slug}`; hiển thị trạng thái sau đó thoát
   - **`--start-from stage3-collect`**: bỏ qua Giai đoạn 3a+3b; chuyển thẳng đến Giai đoạn 3c (thu thập các thí nghiệm đã triển khai)

3. **Tạo tệp tiến trình** `wiki/outputs/pipeline-progress.md`:
   ```yaml
   ---
   slug: "{pipeline-slug}"
   direction: "{hướng nghiên cứu}"
   status: running
   current_stage: stage1
   started: YYYY-MM-DD
   mode: auto|interactive
   skip_paper: true|false
   venue: "{venue}"
   idea_slug: ""
   experiment_slugs: []
   stage3a_deployed: []
   claim_slugs: []
   iteration_count: 0
   ---
   ## Nhật Ký Giai Đoạn
   - Giai đoạn 0 (Khởi tạo): bỏ qua
   - Giai đoạn 1: đang chờ
   - Cổng 1: đang chờ
   - Giai đoạn 2: đang chờ
   - Giai đoạn 3a (Triển khai): đang chờ
   - Giai đoạn 3b (Chờ): đang chờ
   - Giai đoạn 3c (Thu thập): đang chờ
   - Giai đoạn 4: đang chờ
   - Cổng 2: đang chờ
   - Giai đoạn 5: đang chờ
   ```

4. **Thêm nhật ký**:
   ```bash
   python3 tools/research_wiki.py log wiki/ \
     "research | bắt đầu | hướng: {direction} | chế độ: {auto|interactive}"
   ```

5. **Chụp trạng thái wiki** (cho Báo cáo Tăng trưởng trong Bước Cuối):
   ```bash
   python3 tools/research_wiki.py maturity wiki/ --json
   ```
   Lưu JSON trả về vào biến bộ nhớ `maturity_before`.

### Giai đoạn 0: Khởi Tạo (được kích hoạt tự động khi wiki trống)

**Điều kiện kích hoạt**: chạy `python3 tools/research_wiki.py maturity wiki/ --json`. Nếu `level == "cold"` và `papers < 3`: vào Khởi Tạo tự động. Ngược lại, bỏ qua và chuyển đến Giai đoạn 1.

1. **Khởi tạo cấu trúc wiki** (nếu chưa được khởi tạo):
   ```bash
   python3 tools/research_wiki.py init wiki/
   ```

2. **Tìm kiếm các bài báo liên quan** (sử dụng công cụ Agent với 3 tìm kiếm song song):
   - DeepXiv: `python3 tools/fetch_deepxiv.py search "{direction}" --mode hybrid --limit 20`
   - Semantic Scholar: `python3 tools/fetch_s2.py search "{direction}" --limit 20`
   - arXiv: `python3 tools/fetch_arxiv.py` (sử dụng từ khóa direction)
   - Nếu DeepXiv không khả dụng: bỏ qua; chỉ sử dụng S2 + arXiv

3. **Hợp nhất, xếp hạng và chọn top 5**:
   - Loại bỏ trùng lặp theo arxiv_id
   - Ưu tiên xếp hạng: điểm liên quan DeepXiv > số trích dẫn S2 > mới nhất
   - Chọn top 5 (5 = ngưỡng tối thiểu cho cold→warm)

4. **Tự động ingest từng bài báo**:
   ```
   Skill: ingest
   Args: "{arxiv_url_or_path}"
   ```
   Xuất tiến trình sau mỗi ingest: `[{i}/5] Đã ingest: {paper_title}`

5. **Xây dựng lại dữ liệu phái sinh**:
   ```bash
   python3 tools/research_wiki.py rebuild-context-brief wiki/
   python3 tools/research_wiki.py rebuild-open-questions wiki/
   ```

6. **Báo cáo Khởi Tạo**:
   ```bash
   python3 tools/research_wiki.py maturity wiki/ --json
   ```
   Xuất ra terminal:
   ```
   Hoàn thành Khởi Tạo:
   Bài báo: {N} | Khẳng định: {M} | Khái niệm: {K} | Cạnh: {E}
   Độ trưởng thành: cold → {new_level}
   Chuyển sang Giai đoạn 1: Khám phá Ý tưởng...
   ```

7. **Nhật ký + cập nhật tiến trình**:
   ```bash
   python3 tools/research_wiki.py log wiki/ \
     "research | stage0-khoi-tao | tự động ingest {N} bài báo | độ trưởng thành: {level}"
   python3 tools/research_wiki.py set-meta \
     wiki/outputs/pipeline-progress.md current_stage stage1
   ```

### Giai đoạn 1: Khám Phá Ý Tưởng

Gọi `/ideate`:

```
Skill: ideate
Args: "{direction}" --domain {domain}
```

**Sau khi hoàn thành**:
1. Đọc các ý tưởng được tạo, sắp xếp theo mức độ ưu tiên
2. Cập nhật pipeline-progress: Giai đoạn 1 → hoàn thành, ghi lại các slug ý tưởng được tạo
3. Thêm nhật ký

### Cổng 1: Chọn Ý Tưởng

**Nếu chế độ `--auto`**:
- Tự động chọn ý tưởng có mức độ ưu tiên cao nhất (top-1)
- Xuất kết quả lựa chọn ra terminal mà không chờ xác nhận

**Nếu chế độ tương tác**:
- Liệt kê tất cả các ý tưởng được tạo (slug, tiêu đề, mức độ ưu tiên, điểm tính mới)
- Sử dụng AskUserQuestion để nhắc người dùng chọn một ý tưởng (hoặc nhập "stop" để dừng)
- Nếu người dùng chọn stop: lưu tiến trình, kết thúc pipeline

**Lưu tiến trình**:
- Cập nhật pipeline-progress: Cổng 1 → đã qua, ghi lại idea_slug
- Cập nhật trạng thái ý tưởng được chọn: proposed → in_progress

### Giai đoạn 2: Thiết Kế Thí Nghiệm

Gọi `/exp-design`:

```
Skill: exp-design
Args: "{idea_slug}" --review
```

**Sau khi hoàn thành**:
1. Đọc các slug thí nghiệm được tạo (các trang trong wiki/experiments/ có linked_idea == idea_slug)
2. Cập nhật pipeline-progress: Giai đoạn 2 → hoàn thành, ghi lại experiment_slugs

### Giai đoạn 3: Thực Thi Thí Nghiệm (không chặn)

Giai đoạn 3 được chia thành ba tiểu giai đoạn, cho phép các thí nghiệm chạy không đồng bộ ở chế độ nền mà không chặn phiên.

#### Giai đoạn 3a: Triển Khai Tất Cả

Triển khai từng thí nghiệm theo thứ tự chạy (baseline → validation → ablation → robustness) bằng cách gọi `/exp-run {experiment_slug}` (chế độ triển khai mặc định, Giai đoạn 1+2):

```
Skill: exp-run
Args: "{experiment_slug}"
```

(Chế độ triển khai mặc định, Giai đoạn 1+2: trả về ngay sau khi triển khai, không chờ thí nghiệm hoàn thành)

**Sau mỗi triển khai**:
- Ghi lại kết quả triển khai (thành công/thất bại) trong bộ nhớ
- Nếu triển khai thất bại: ghi vào pipeline-progress với cảnh báo (thất bại triển khai baseline nhận cảnh báo mạnh hơn), nhưng **tiếp tục triển khai các thí nghiệm còn lại** (không hủy bỏ)

**Sau khi tất cả các triển khai hoàn thành**, cập nhật pipeline-progress.md:
```bash
python3 tools/research_wiki.py set-meta \
  wiki/outputs/pipeline-progress.md current_stage stage3-await
python3 tools/research_wiki.py set-meta \
  wiki/outputs/pipeline-progress.md stage3a_deployed \
  "[{experiment_slug_1}, {experiment_slug_2}, ...]"
```
Thêm nhật ký:
```bash
python3 tools/research_wiki.py log wiki/ \
  "research | stage3a | đã triển khai {N} thí nghiệm | pipeline: {slug}"
```

#### Giai đoạn 3b: Chờ (không chặn)

Sau khi tất cả các thí nghiệm được triển khai, tính toán ETA, lưu tiến trình và kết thúc phiên hiện tại.

1. Cập nhật pipeline-progress:
   ```bash
   python3 tools/research_wiki.py set-meta \
     wiki/outputs/pipeline-progress.md current_stage stage3-await
   ```
2. **Tính toán thời gian hoàn thành ước tính cho từng thí nghiệm**:
   Đối với mỗi thí nghiệm đã triển khai, đọc `started` và `estimated_hours` từ frontmatter:
   - `eta = started + estimated_hours`
   - `recommended_return = max(all etas) + bộ đệm 30 phút, làm tròn lên đến giờ hoặc nửa giờ gần nhất`
3. Thêm nhật ký:
   ```bash
   python3 tools/research_wiki.py log wiki/ \
     "research | stage3b | đang chờ {N} thí nghiệm | eta mới nhất: {YYYY-MM-DD HH:MM} | pipeline: {slug}"
   ```
4. Xuất hướng dẫn sau đó **kết thúc phiên hiện tại**:
   ```
   Hoàn thành Giai đoạn 3a: {N} thí nghiệm đã triển khai:

   Thí nghiệm                      Môi trường     Thời gian ước tính   Hoàn thành ước tính
   ──────────────────────────────  ──────────────  ───────────────────  ────────────────────
   exp-foo-baseline                local           ~8h                 Ngày mai 09:30
   exp-foo-validation              remote (gpu1)   ~6h                 Hôm nay 23:00
   exp-foo-ablation                local           ~4h                 Hôm nay 21:00

   Hoàn thành mới nhất: Ngày mai 09:30 (exp-foo-baseline)
   Thời gian đề xuất quay lại: Ngày mai 10:00+

     /exp-status                              ← xác nhận tất cả thí nghiệm đã hoàn thành
     /research --start-from stage3-collect    ← thu thập kết quả và tiếp tục

   Tiến trình được lưu vào wiki/outputs/pipeline-progress.md; phiên hiện tại có thể đóng.
   ```

#### Giai đoạn 3c: Thu Thập (được kích hoạt sau khi các thí nghiệm hoàn thành)

**Kích hoạt**: người dùng chạy thủ công `/research --start-from stage3-collect`

Đối với mỗi thí nghiệm đã triển khai (đọc từ danh sách `stage3a_deployed`):
```
Skill: exp-run
Args: "{experiment_slug} --collect"
```

(Chế độ thu thập, Giai đoạn 3+4: kiểm tra trạng thái hoàn thành và thu thập kết quả)

**Quyết định sau mỗi thu thập**:
- Nếu outcome == failed và đây là thí nghiệm baseline → **kết thúc pipeline**, báo cáo baseline không thể tái tạo
- Nếu outcome == failed và đây là thí nghiệm validation → ghi lại thất bại, tiếp tục thu thập các thí nghiệm còn lại, tiến hành đánh giá Giai đoạn 4
- Nếu outcome == inconclusive → ghi lại và tiếp tục

**Sau khi tất cả các thu thập hoàn thành**:
- Cập nhật pipeline-progress: Giai đoạn 3 → hoàn thành
  ```bash
  python3 tools/research_wiki.py set-meta \
    wiki/outputs/pipeline-progress.md current_stage stage4
  ```
- Thêm nhật ký:
  ```bash
  python3 tools/research_wiki.py log wiki/ \
    "research | stage3c | đã thu thập {N} thí nghiệm | pipeline: {slug}"
  ```
- Chuyển sang Giai đoạn 4

### Giai đoạn 4: Phán Quyết & Lặp Lại

Gọi `/exp-eval` cho mỗi thí nghiệm đã hoàn thành:

```
Skill: exp-eval
Args: "{experiment_slug}" --auto
```

**Đánh giá xem các khẳng định có đủ không**:
1. Đọc trạng thái mới nhất của tất cả các khẳng định mục tiêu
2. Xác định xem có cần lặp lại không:
   - **Khẳng định đủ** (độ tin cậy khẳng định chính >= 0.7 và trạng thái là supported hoặc weakly_supported) → tiến hành Cổng 2
   - **Khẳng định không đủ** (độ tin cậy < 0.4 hoặc trạng thái là challenged) → vào vòng lặp

**Đường lặp lại** (khi khẳng định không đủ, tối đa 1 lần thử lại):
1. Phân tích nguyên nhân thất bại
2. Gọi `/refine` để cải thiện kế hoạch thí nghiệm:
   ```
   Skill: refine
   Args: "{experiment_plan_slug}" --max-rounds 2 --focus evidence
   ```
3. Chạy lại Giai đoạn 3 → Giai đoạn 4 cho các thí nghiệm mới/sửa đổi
4. Tối đa 2 lần lặp lại (ngăn chặn vòng lặp vô hạn); mỗi giai đoạn có tối đa 1 lần thử lại tự động

**Sau khi hoàn thành**:
- Cập nhật pipeline-progress: Giai đoạn 4 → hoàn thành, ghi lại claim_slugs

### Cổng 2: Xác Nhận Bài Báo Sẵn Sàng

**Nếu `--skip-paper`**: bỏ qua Cổng 2 và Giai đoạn 5, tạo báo cáo cuối cùng trực tiếp

**Nếu chế độ `--auto`**: tự động tiếp tục, vào Giai đoạn 5

**Nếu chế độ tương tác**:
- Hiển thị tóm tắt trạng thái khẳng định:
  ```
  Khẳng định: {slug} | Trạng thái: {status} | Độ tin cậy: {confidence}
  Bằng chứng: {count} nguồn ({strong}/{moderate}/{weak})
  ```
- Sử dụng AskUserQuestion để nhắc người dùng: sẵn sàng cho bài báo / cần thêm thí nghiệm / dừng tại đây
- Nếu "cần thêm thí nghiệm": quay lại Giai đoạn 2 để lập kế hoạch lại
- Nếu "dừng tại đây": lưu tiến trình, tạo báo cáo cuối cùng (không có bài báo)

**Lưu tiến trình**:
- Cập nhật pipeline-progress: Cổng 2 → đã qua

### Giai đoạn 5: Viết Bài Báo

Gọi các kỹ năng con theo thứ tự: /paper-plan → /paper-draft → /refine → /paper-compile

**5a. Gọi /paper-plan**:
```
Skill: paper-plan
Args: "{claim_slugs}" --venue {venue}
```

**5b. Gọi /paper-draft**:
```
Skill: paper-draft
Args: "wiki/outputs/PAPER_PLAN.md" --review
```

**5c. Gọi /refine cho bài báo**:
```
Skill: refine
Args: "paper/main.tex" --max-rounds 3 --target-score 8 --focus writing
```

**5d. Gọi /paper-compile**:
```
Skill: paper-compile
Args: "paper/"
```

**Sau khi hoàn thành**:
- Cập nhật pipeline-progress: Giai đoạn 5 → hoàn thành, status: completed

### Bước Cuối: Báo Cáo Pipeline

Tạo `wiki/outputs/PIPELINE_REPORT.md`:

```markdown
# Báo Cáo Pipeline Nghiên Cứu

## Tóm Tắt Giai Đoạn
| Giai đoạn | Trạng thái | Thời gian |
|-------|--------|----------|
| Giai đoạn 0: Khởi tạo | hoàn thành/bỏ qua | ... |
| Giai đoạn 1: Khám phá Ý tưởng | hoàn thành | ... |
| Cổng 1: Lựa chọn Ý tưởng | đã qua | ... |
| Giai đoạn 2: Thiết kế Thí nghiệm | hoàn thành | ... |
| Giai đoạn 3a: Triển khai Thí nghiệm | hoàn thành | ... |
| Giai đoạn 3b: Chờ (bất đồng bộ) | hoàn thành | ... |
| Giai đoạn 3c: Thu thập Kết quả | hoàn thành | ... |
| Giai đoạn 4: Phán quyết | hoàn thành | ... |
| Cổng 2: Bài báo sẵn sàng | đã qua | ... |
| Giai đoạn 5: Viết Bài báo | hoàn thành | ... |

## Ý Tưởng Được Chọn
- **Ý tưởng**: [[{idea_slug}]] — {tiêu đề ý tưởng}
- **Mức độ ưu tiên**: {N}
- **Điểm tính mới**: {score}

## Theo Dõi Khẳng Định
| Khẳng định | Trạng thái Ban đầu | Trạng thái Cuối cùng | Độ tin cậy (đề xuất → hỗ trợ) |
|-------|-------------------|---------------------|-----------------------------------|
| [[{slug}]] | proposed | supported | 0.3 → 0.8 |

## Kết Quả Thí Nghiệm
| Thí nghiệm | Kết quả | Kết quả Chính |
|-----------|---------|------------|
| [[{slug}]] | succeeded | {result} |

## Lịch Sử Lặp Lại
- Tổng số lần lặp lại: {N}
- Lý do lặp lại: {khẳng định không đủ / ...}

## Sản Phẩm
- Ý tưởng: +{N} được tạo
- Thí nghiệm: +{N} được tạo, {N} hoàn thành
- Khẳng định: {N} được cập nhật
- Cạnh đồ thị: +{N}
- Bài báo: paper/main.pdf (nếu có)

## Tăng Trưởng Wiki (tổng pipeline)
| Chỉ số | Trước | Sau | Chênh lệch |
|--------|--------|-------|-------|
| Bài báo | {N} | {N} | +{N} |
| Khẳng định | {N} | {N} | +{N} |
| Ý tưởng | {N} | {N} | +{N} |
| Thí nghiệm | {N} | {N} | +{N} |
| Cạnh | {N} | {N} | +{N} |
| Độ trưởng thành | {level} | {level} | {status} |
| Độ phủ | {%} | {%} | +{%} |
(Dữ liệu từ so sánh `maturity_before` từ Bước 0 với lệnh gọi mới `maturity --json` tại đây. Chỉ hiển thị các hàng có chênh lệch != 0.)

## Bước Tiếp Theo
- {khuyến nghị dựa trên các lỗ hổng hoặc vấn đề chưa giải quyết còn lại}
```

Thêm nhật ký:
```bash
python3 tools/research_wiki.py log wiki/ \
  "research | hoàn thành | ý tưởng: {slug} | khẳng định: {N} cập nhật | bài báo: {có/không}"
```

Cập nhật pipeline-progress: status: completed

## Các Ràng Buộc

- **Điều phối viên không trực tiếp sửa đổi thực thể wiki hoặc nhúng logic kỹ năng con**: tất cả các sửa đổi wiki được ủy quyền cho các kỹ năng con; pipeline chỉ điều phối bằng cách gọi chúng thông qua công cụ Skill
- **Cổng và Giai đoạn phải lưu tiến trình**: mọi Cổng và Giai đoạn phải lưu pipeline-progress.md khi hoàn thành hoặc vào chế độ chờ
- **Thất bại triển khai Giai đoạn 3a không hủy bỏ**: ghi cảnh báo và tiếp tục triển khai; không kết thúc sớm (thất bại thu thập baseline mới kích hoạt kết thúc)
- **Thất bại thu thập baseline kết thúc**: trong Giai đoạn 3c, nếu baseline outcome == failed, kết thúc pipeline
- **Giai đoạn 3b kết thúc phiên**: sau khi Giai đoạn 3b hoàn thành, phiên hiện tại kết thúc; không tiếp tục chờ các thí nghiệm
- **Tối đa 2 lần lặp lại**: Giai đoạn 4 lặp lại tối đa 2 lần để ngăn chặn vòng lặp vô hạn
- **--auto không bỏ qua tính toán**: chế độ auto bỏ qua xác nhận của con người nhưng không bỏ qua bước tính toán nào
- **--skip-paper vẫn chạy Giai đoạn 4 /exp-eval**: cập nhật khẳng định phải được hoàn thành ngay cả khi không viết bài báo
- **Chuyển tiếp tham số kỹ năng con**: chuyển chính xác domain, --venue và các tham số khác đến các kỹ năng con
- **Nhật ký mọi Giai đoạn**: thêm mục kiểm toán log.md sau khi mỗi Giai đoạn hoàn thành
- **Không chạy lại các giai đoạn đã hoàn thành**: --start-from bỏ qua các giai đoạn đã hoàn thành
- **Tệp tiến trình tại wiki/outputs/pipeline-progress.md**: vị trí nhất quán để dễ dàng phát hiện và khôi phục
- **Ưu tiên tự động khôi phục**: nếu không có --start-from và tồn tại pipeline chưa hoàn thành, mặc định nhắc người dùng tiếp tục thay vì bắt đầu mới

## Xử Lý Lỗi

- **pipeline-progress thiếu nhưng --start-from được chỉ định**: báo lỗi; nhắc người dùng chạy pipeline đầy đủ trước
- **pipeline-progress bị hỏng hoặc định dạng sai**: cố gắng suy luận tiến trình từ trạng thái wiki hiện tại (đọc trạng thái ideas/experiments/claims), khôi phục đến Cổng gần nhất
- **Gọi kỹ năng con thất bại**: ghi lỗi vào pipeline-progress, báo cáo giai đoạn thất bại, đề xuất --start-from để tiếp tục
- **Tạo ý tưởng thất bại**: kết thúc pipeline; đề xuất người dùng điều chỉnh hướng nghiên cứu
- **Tất cả triển khai thí nghiệm thất bại**: kết thúc pipeline (Giai đoạn 3a); tạo báo cáo thất bại; đề xuất kiểm tra cấu hình GPU/SSH
- **Thu thập baseline Giai đoạn 3c thất bại**: kết thúc pipeline; báo cáo baseline không thể tái tạo; đề xuất chạy lại /exp-design
- **Tất cả thu thập thí nghiệm thất bại (không phải baseline)**: tiến hành đánh giá Giai đoạn 4 (xem thất bại như bằng chứng)
- **Người dùng chọn dừng tại Cổng**: lưu tiến trình vào pipeline-progress; tạo báo cáo một phần
- **RESEARCH_BRIEF.md định dạng sai**: quay lại hướng văn bản thuần túy; bỏ qua các trường có cấu trúc
- **Wiki trống (không có bài báo/khái niệm)**: tự động kích hoạt Giai đoạn 0 Khởi tạo (tìm kiếm + tự động ingest 5 bài báo)
- **Khẳng định vẫn không đủ sau lần lặp lại**: chú thích báo cáo với "khẳng định không đủ sau số lần lặp lại tối đa"; để người dùng quyết định có tiếp tục không
- **Người dùng chọn xem trạng thái (tự động phát hiện khôi phục [3])**: gọi `/exp-status --pipeline {slug}` sau đó thoát mà không bắt đầu pipeline mới

## Phụ Thuộc

### Kỹ Năng (thông qua công cụ Skill)

- `/ingest` — Tự động ingest Giai đoạn 0 Khởi tạo
- `/ideate` — Khám phá ý tưởng Giai đoạn 1
- `/exp-design` — Thiết kế thí nghiệm Giai đoạn 2
- `/exp-run` — Giai đoạn 3a (chế độ triển khai) và Giai đoạn 3c (chế độ --collect)
- `/exp-status` — Người dùng kiểm tra tiến trình thí nghiệm thủ công; `--auto-advance` có thể tự động kích hoạt Giai đoạn 4 khi tất cả hoàn thành
- `/exp-eval` — Phán quyết Giai đoạn 4
- `/refine` — Lặp lại Giai đoạn 4 + cải thiện bài báo Giai đoạn 5
- `/paper-plan` — Lập kế hoạch bài báo Giai đoạn 5
- `/paper-draft` — Viết bài báo Giai đoạn 5
- `/paper-compile` — Biên dịch bài báo Giai đoạn 5

### Công cụ (thông qua Bash)

- `python3 tools/research_wiki.py slug "{title}"` — tạo slug pipeline
- `python3 tools/research_wiki.py set-meta <path> <field> <value>` — cập nhật trường pipeline-progress
- `python3 tools/research_wiki.py log wiki/ "<message>"` — thêm mục nhật ký
- `python3 tools/research_wiki.py maturity wiki/ --json` — kiểm tra độ trưởng thành wiki (kích hoạt Giai đoạn 0 + Báo cáo Tăng trưởng)
- `python3 tools/research_wiki.py init wiki/` — khởi tạo cấu trúc wiki (Giai đoạn 0)
- `python3 tools/fetch_deepxiv.py search "{query}" --mode hybrid --limit 20` — Tìm kiếm ngữ nghĩa DeepXiv (Giai đoạn 0)
- `python3 tools/fetch_s2.py search "{query}" --limit 20` — Tìm kiếm Semantic Scholar (Giai đoạn 0)
- `python3 tools/fetch_arxiv.py` — Tìm kiếm RSS arXiv (Giai đoạn 0)

### Máy Chủ MCP

- Không trực tiếp — tất cả tương tác Review LLM được sử dụng gián tiếp thông qua các kỹ năng con

### Claude Code Gốc

- `Read` — đọc pipeline-progress, trang wiki, RESEARCH_BRIEF
- `Write` — ghi pipeline-progress, PIPELINE_REPORT
- `Glob` — tìm thí nghiệm, ý tưởng, khẳng định
- `Skill` — gọi các kỹ năng con (khả năng cốt lõi)
- `AskUserQuestion` — tương tác người dùng tại Cổng và phát hiện tự động khôi phục