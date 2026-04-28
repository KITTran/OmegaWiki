# Tệp Hỗ trợ Runtime

> Tài liệu tham khảo theo yêu cầu cho các tệp phái sinh từ đồ thị cùng với các tệp runtime không phải trang `index.md` và `log.md`.

## Tệp Đồ thị

| Tệp | Nội dung | Được tạo bởi |
|------|---------|-------------|
| `edges.jsonl` | các mối quan hệ ngữ nghĩa: paper-paper, paper-concept, claim/experiment/idea/provenance edges | `python3 tools/research_wiki.py add-edge` |
| `citations.jsonl` | trích dẫn tài liệu tham khảo của bài báo (`type: cites`) | `python3 tools/research_wiki.py add-citation` |
| `context_brief.md` | ngữ cảnh nén: khẳng định + lỗ hổng + ý tưởng thất bại + bài báo + cạnh (≤8000 ký tự) | `python3 tools/research_wiki.py rebuild-context-brief` |
| `open_questions.md` | câu hỏi mở: các khẳng định thiếu bằng chứng + câu hỏi mở từ papers/topics | `python3 tools/research_wiki.py rebuild-open-questions` |

Định dạng cạnh ngữ nghĩa: `{"from": "node_id", "to": "node_id", "type": "edge_type", "evidence": "...", "confidence": "high|medium|low", "date": "..."}`

Định dạng trích dẫn: `{"from": "papers/citing", "to": "papers/cited", "type": "cites", "source": "semantic_scholar|parsed_bib|manual", "date": "..."}`

## Định dạng index.md

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

## Định dạng log.md

```markdown
## [2026-04-07] ingest | đã thêm papers/lora-low-rank-adaptation | cập nhật: concepts/parameter-efficient-fine-tuning
## [2026-04-07] lint | báo cáo: 0 🔴, 2 🟡, 1 🔵
## [2026-04-08] daily-arxiv | 3 bài báo được ingest từ RSS
```