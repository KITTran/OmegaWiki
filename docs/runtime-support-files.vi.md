# Tệp Hỗ Trợ Runtime

> Tài liệu tham khảo theo yêu cầu cho các tệp phái sinh từ đồ thị cùng với các tệp runtime không phải trang `index.md` và `log.md`.

## Tệp Đồ Thị

| Tệp | Nội dung | Được tạo bởi |
|------|---------|-------------|
| `edges.jsonl` | mối quan hệ có kiểu (extends, contradicts, supports, inspired_by, tested_by, invalidates, supersedes, addresses_gap, derived_from) | `python3 tools/research_wiki.py add-edge` |
| `context_brief.md` | ngữ cảnh nén: khẳng định + lỗ hổng + ý tưởng thất bại + bài báo + cạnh (≤8000 ký tự) | `python3 tools/research_wiki.py rebuild-context-brief` |
| `open_questions.md` | câu hỏi mở: khẳng định được hỗ trợ yếu + câu hỏi mở từ papers/topics | `python3 tools/research_wiki.py rebuild-open-questions` |

Định dạng mỗi cạnh: `{"from": "node_id", "to": "node_id", "type": "edge_type", "evidence": "...", "date": "..."}`

## Định Dạng index.md

```yaml
papers:
  - slug: lora-low-rank-adaptation
concepts:
  - slug: parameter-efficient-fine-tuning
topics:
  - slug: efficient-llm-adaptation
people:
  - slug: tri-dao
ideas:
  - slug: sparse-lora-for-edge-devices
experiments:
  - slug: sparse-lora-latency-benchmark
claims:
  - slug: lora-preserves-quality-at-low-rank
```

## Định Dạng log.md

```markdown
## [2026-04-07] ingest | đã thêm papers/lora-low-rank-adaptation | đã cập nhật: concepts/parameter-efficient-fine-tuning
## [2026-04-07] lint | báo cáo: 0 🔴, 2 🟡, 1 🔵
## [2026-04-08] daily-arxiv | 3 bài báo được ingest từ RSS
```