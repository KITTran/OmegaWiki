# Sơ Đồ Thư Mục Runtime

> Tài liệu tham khảo theo yêu cầu cho bố cục kho lưu trữ. `CLAUDE.md` chính chỉ giữ lại sơ đồ và quy tắc cần ở trong ngữ cảnh tức thì.

```text
wiki/
├── CLAUDE.md          ← sơ đồ runtime
├── index.md           ← danh mục nội dung (YAML)
├── log.md             ← nhật ký theo thời gian (chỉ thêm vào)
├── papers/            ← tóm tắt bài báo có cấu trúc
├── concepts/          ← khái niệm kỹ thuật xuyên bài báo
├── topics/            ← bản đồ hướng nghiên cứu
├── people/            ← hồ sơ nhà nghiên cứu
├── ideas/             ← ý tưởng nghiên cứu (với trạng thái vòng đời)
├── experiments/       ← hồ sơ thí nghiệm (trang wiki)
├── claims/            ← khẳng định nghiên cứu có thể kiểm chứng
├── Summary/           ← khảo sát toàn lĩnh vực
├── foundations/       ← kiến thức nền tảng (điểm cuối: nhận liên kết vào, không viết liên kết ra)
├── outputs/           ← tạo tác được tạo (Công trình liên quan, bản thảo bài báo)
└── graph/             ← tự động tạo (không chỉnh sửa)
    ├── edges.jsonl
    ├── context_brief.md
    └── open_questions.md

raw/
├── papers/            ← nguồn .tex / .pdf thuộc sở hữu người dùng
├── discovered/        ← bài báo được lấy từ bên ngoài từ /init và /daily-arxiv
├── tmp/               ← nguồn cục bộ đã chuẩn bị được tạo cho /init và /ingest cục bộ trực tiếp
├── notes/             ← ghi chú .md thuộc sở hữu người dùng
└── web/               ← HTML / Markdown thuộc sở hữu người dùng

config/
├── server.yaml        ← cấu hình máy chủ GPU từ xa (tùy chọn, cần cho /exp-run --env remote)
├── server.yaml.example
├── .env.example
└── settings.local.json.example
```

## Lời Nhắc Nhanh

- `raw/papers/`, `raw/notes/`, và `raw/web/` là đầu vào thuộc sở hữu người dùng.
- `raw/discovered/` dành cho các bài báo bên ngoài được lấy, không phải các tệp người dùng thả vào.
- `raw/tmp/` là trạng thái trung gian được tạo cho `/init` và `/ingest` cục bộ trực tiếp.
- `graph/` được phái sinh và chỉ nên được duy trì thông qua `tools/research_wiki.py`.
