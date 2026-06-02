# Mẫu Trang Runtime

> Tài liệu tham khảo theo yêu cầu cho các mẫu trang wiki đầy đủ. Xem `docs/runtime-support-files.vi.md` để biết các tệp phái sinh từ đồ thị cùng với `index.md` và `log.md`.

## Quy tắc Markdown chung

### Định dạng công thức

Khi tạo hoặc sửa file Markdown trong wiki, viết công thức theo cú pháp equation của Markdown/Obsidian, không dùng môi trường equation của LaTeX.

- Công thức inline dùng `$...$`.
- Công thức block dùng `$$...$$`.
- Không dùng `\begin{equation}`, `\end{equation}`, `\begin{align}`, hoặc các môi trường LaTeX tương tự trong nội dung Markdown wiki.

Ví dụ:

```markdown
Độ lỗi trung bình là $\mathcal{L}_{\mathrm{MSE}}$.

$$
\mathcal{L}_{\mathrm{MSE}} = \frac{1}{N}\sum_{i=1}^{N}(u_i - \hat{u}_i)^2
$$
```

## 9 Loại Trang

### papers/{slug}.md

```yaml
---
title: ""
slug: ""
arxiv: ""
venue: ""
year: 
tags: []
importance: 3           # 1-5
date_added: YYYY-MM-DD
source_type: tex         # tex | pdf
s2_id: ""
keywords: []
domain: ""               # NLP / CV / Hệ thống ML / Robotics
code_url: ""
cited_by: []
---
```

Các phần nội dung: `## Vấn đề` / `## Ý tưởng chính` / `## Phương pháp` / `## Kết quả` / `## Hạn chế` / `## Câu hỏi mở` / `## Đánh giá của tôi` / `## Liên quan`

### concepts/{tên-khái-niệm}.md

```yaml
---
title: ""
aliases: []
tags: []
maturity: active         # stable | active | emerging | deprecated
key_papers: []
first_introduced: ""
date_updated: YYYY-MM-DD
related_concepts: []
---
```

Các phần nội dung: `## Định nghĩa` / `## Trực giác` / `## Ký hiệu hình thức` / `## Các biến thể` / `## So sánh` / `## Khi nào sử dụng` / `## Hạn chế đã biết` / `## Vấn đề mở` / `## Bài báo chính` / `## Hiểu biết của tôi`

### topics/{tên-chủ-đề}.md

```yaml
---
title: ""
tags: []
my_involvement: none     # none | reading | side-project | main-focus
sota_updated: YYYY-MM-DD
key_venues: []
related_topics: []
key_people: []
---
```

Các phần nội dung: `## Tổng quan` / `## Dòng thời gian` / `## Công trình nền tảng` / `## Theo dõi SOTA` / `## Vấn đề mở` / `## Vị trí của tôi` / `## Khoảng trống nghiên cứu` / `## Nhân vật chính`

### people/{họ-tên}.md

```yaml
---
name: ""
affiliation: ""
tags: []
homepage: ""
scholar: ""
date_updated: YYYY-MM-DD
---
```

Các phần nội dung: `## Lĩnh vực nghiên cứu` / `## Bài báo chính` / `## Công trình gần đây` / `## Cộng tác viên` / `## Ghi chú của tôi`

### Summary/{tên-lĩnh-vực}.md

```yaml
---
title: ""
scope: ""
key_topics: []
paper_count: 
date_updated: YYYY-MM-DD
---
```

Các phần nội dung: `## Tổng quan` / `## Lĩnh vực cốt lõi` / `## Sự phát triển` / `## Biên giới hiện tại` / `## Tài liệu tham khảo chính` / `## Liên quan`

### foundations/{slug}.md

```yaml
---
title: ""
slug: ""
domain: ""
status: mainstream       # mainstream | historical
aliases: []
first_introduced: ""
date_updated: YYYY-MM-DD
source_url: ""
---
```

Các phần nội dung: `## Định nghĩa` / `## Trực giác` / `## Ký hiệu hình thức` / `## Các biến thể chính` / `## Hạn chế đã biết` / `## Vấn đề mở` / `## Mức độ liên quan đến nghiên cứu hiện tại`

**Foundations không có trường liên kết ra ngoài**. Các trang khác có thể liên kết đến một foundation; foundations không viết liên kết ngược.

### ideas/{slug-ý-tưởng}.md

```yaml
---
title: ""
slug: ""
status: proposed          # proposed | in_progress | tested | validated | failed
origin: ""
origin_gaps: []
tags: []
domain: ""
priority: 3               # 1-5
pilot_result: ""
failure_reason: ""
linked_experiments: []
date_proposed: YYYY-MM-DD
date_resolved: ""
---
```

Các phần nội dung: `## Động lực` / `## Giả thuyết` / `## Bản phác thảo cách tiếp cận` / `## Kết quả mong đợi` / `## Rủi ro` / `## Kết quả thí điểm` / `## Bài học rút ra`

### experiments/{slug-thí-nghiệm}.md

```yaml
---
title: ""
slug: ""
status: planned           # planned | running | completed | abandoned
target_claim: ""
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
outcome: ""               # succeeded | failed | inconclusive
key_result: ""
linked_idea: ""
date_planned: YYYY-MM-DD
date_completed: ""
run_log: ""
started: ""
estimated_hours: 0
remote:
  server: ""
  gpu: ""
  session: ""
  started: ""
  completed: ""
---
```

Các phần nội dung: `## Mục tiêu` / `## Thiết lập` / `## Quy trình` / `## Kết quả` / `## Phân tích` / `## Cập nhật khẳng định` / `## Theo dõi`

### claims/{slug-khẳng-định}.md

```yaml
---
title: ""
slug: ""
status: proposed          # proposed | weakly_supported | supported | challenged | deprecated
confidence: 0.5           # 0.0-1.0
tags: []
domain: ""
source_papers: []
evidence:
  - source: ""
    type: supports        # supports | contradicts | tested_by | invalidates
    strength: moderate    # weak | moderate | strong
    detail: ""
conditions: ""
date_proposed: YYYY-MM-DD
date_updated: YYYY-MM-DD
---
```

Các phần nội dung: `## Phát biểu` / `## Tóm tắt bằng chứng` / `## Điều kiện và phạm vi` / `## Bằng chứng phản bác` / `## Ý tưởng liên kết` / `## Câu hỏi mở`