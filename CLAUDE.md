# ΩmegaWiki — Sơ Đồ Runtime

> CS/AI ΩmegaWiki. Được hỗ trợ bởi Claude Code.
> Tệp này là điểm nhập runtime của wiki: định nghĩa cấu trúc trang, quy ước liên kết và các ràng buộc quy trình làm việc.

> **Ghi chú bảo trì**: Được quản lý dưới `i18n/`. Chỉnh sửa `i18n/vi/CLAUDE.md` (không chỉnh sửa bản sao hoạt động tại thư mục gốc). Chạy `./setup.sh --lang vi` để đồng bộ.

---

## Cấu Trúc Kho Lưu Trữ

Chỉ mở `docs/runtime-directory-structure.vi.md` khi bạn cần cây thư mục đầy đủ.

Hãy ghi nhớ sơ đồ này trong ngữ cảnh tức thì:

### `wiki/` là bề mặt sản phẩm chính

- `wiki/index.md` là danh mục của tất cả các trang wiki
- `wiki/log.md` là nhật ký hoạt động chỉ được thêm vào
- `wiki/papers/` chứa các bản tóm tắt bài báo
- `wiki/concepts/`, `wiki/topics/`, và `wiki/foundations/` chứa cấu trúc kiến thức có thể tái sử dụng
- `wiki/people/`, `wiki/ideas/`, `wiki/experiments/`, và `wiki/claims/` chứa các tác nhân nghiên cứu, giả thuyết, thử nghiệm và khẳng định
- `wiki/Summary/` chứa các tổng hợp theo lĩnh vực
- `wiki/outputs/` chứa các tạo tác được tạo ra
- `wiki/graph/` là trạng thái phái sinh; không chỉnh sửa thủ công

### Quy tắc định dạng

- Mở `docs/runtime-page-templates.vi.md` trước khi soạn thảo hoặc sửa chữa cấu trúc trang wiki, YAML hoặc các phần nội dung
- Mở `docs/runtime-support-files.vi.md` khi bạn cần chi tiết tệp phái sinh từ đồ thị hoặc định dạng `index.md` / `log.md`
- `SKILL.md` là điểm nhập tức thì cho một kỹ năng; một số kỹ năng lớn hơn cũng có thể cung cấp các tệp tham khảo cục bộ theo yêu cầu trong thư mục kỹ năng của chúng
- `/init` là ví dụ cụ thể đầu tiên của mẫu này: đọc `skills/init/SKILL.md` trước, sau đó mở `skills/init/references/*` chỉ khi cần thiết

### `raw/` và `config/`

- `raw/papers/`, `raw/notes/`, và `raw/web/` là đầu vào do người dùng sở hữu
- `raw/discovered/` lưu trữ các bài báo được lấy từ bên ngoài từ `/init` và `/daily-arxiv`
- `raw/tmp/` lưu trữ các tệp tạm thời được tạo ra cho `/init` và `/ingest` cục bộ trực tiếp
- `config/` chứa các mẫu môi trường và máy chủ từ xa

---

## 9 Loại Trang

`papers`, `concepts`, `topics`, `people`, `ideas`, `experiments`, `claims`, `Summary`, `foundations`.

Mở `docs/runtime-page-templates.vi.md` để biết mẫu trang và `docs/runtime-support-files.vi.md` để biết tham chiếu đồ thị/ chỉ mục/ nhật ký.

---

## Cú Pháp Liên Kết

Tất cả các liên kết nội bộ sử dụng wikilinks theo kiểu Obsidian:

```markdown
[[slug]]                    ← liên kết đến bất kỳ trang nào trong wiki này
[[lora-low-rank-adaptation]] ← liên kết đến papers/lora-low-rank-adaptation.md
[[flash-attention]]          ← liên kết đến concepts/flash-attention.md
```

**Quy ước đặt tên**: tất cả chữ thường, phân tách bằng dấu gạch ngang, không có khoảng trắng.

---

## Quy Tắc Liên Kết Chéo

Khi viết một liên kết xuôi, **luôn viết liên kết ngược đồng thời**:

| Hành động xuôi | Hành động ngược bắt buộc |
|----------------|--------------------------|
| papers/A viết `Related: [[concept-B]]` | concepts/B thêm A vào `key_papers` |
| papers/A viết `[[researcher-C]]` | people/C thêm A vào `Key papers` |
| papers/A viết `supports: [[claim-D]]` | claims/D thêm `{source: A, type: supports}` vào `evidence` |
| topics/T viết `key_people: [[person-D]]` | people/D thêm T vào `Research areas` |
| concepts/K viết `key_papers: [[paper-E]]` | papers/E thêm K vào `Related` |
| concepts/K viết part_of `[[topic-F]]` | topics/F thêm K vào đoạn tổng quan |
| ideas/I viết `origin_gaps: [[claim-C]]` | claims/C thêm I vào `## Linked ideas` |
| experiments/E viết `target_claim: [[claim-C]]` | claims/C thêm `{source: E, type: tested_by}` vào `evidence` |
| claims/C viết `source_papers: [[paper-P]]` | papers/P thêm C vào `## Related` |
| bất kỳ trang nào liên kết đến `[[foundation-X]]` | **không có liên kết ngược** — foundations là điểm cuối: chúng nhận liên kết vào từ papers/concepts/etc. nhưng không bao giờ viết `key_papers` hoặc bất kỳ trường tham chiếu ngược nào |

---

## Quy Tắc Đồ Thị

- `graph/` được tạo tự động; không chỉnh sửa thủ công
- Các tệp phái sinh cốt lõi là `edges.jsonl`, `context_brief.md`, và `open_questions.md`
- Các loại cạnh hợp lệ là `extends`, `contradicts`, `supports`, `inspired_by`, `tested_by`, `invalidates`, `supersedes`, `addresses_gap`, và `derived_from`
- Sử dụng `tools/research_wiki.py add-edge`, `rebuild-context-brief`, và `rebuild-open-questions`

## Định Dạng log.md

Dòng nhật ký chuẩn:

```markdown
## [YYYY-MM-DD] skill | chi tiết
```

---

## Môi Trường Python

- Ưu tiên `.venv/bin/python` (Unix/macOS) hoặc `.venv/Scripts/python.exe` (Windows) khi `.venv/` tồn tại
- Nếu không, sử dụng môi trường conda đang hoạt động nếu có
- Nếu không, sử dụng `python3` (Unix/macOS) hoặc `python` (Windows)
- Các công cụ Python tự động tải khóa API từ `~/.env` và `.env` trong thư mục gốc dự án thông qua `tools/_env.py`

---

## Các Ràng Buộc

- **`raw/papers/`, `raw/notes/`, `raw/web/` thuộc sở hữu của người dùng**: coi chúng là đầu vào có thẩm quyền. `/init` và `/daily-arxiv` chỉ có thể thêm các bài báo được lấy từ bên ngoài vào `raw/discovered/`. `/init` và `/ingest` cục bộ trực tiếp chỉ có thể thêm các tệp tạm thời được tạo ra vào `raw/tmp/` (chỉ thêm — không bao giờ ghi đè lên tệp do người dùng sở hữu). `/edit` chỉ có thể thêm nguồn thô khi người dùng yêu cầu rõ ràng. Các tiểu tác nhân `/init` chạy `/ingest` trong CHẾ ĐỘ INIT vẫn coi `raw/` là chỉ đọc và phải sử dụng đường dẫn chính tắc được chuyển giao trực tiếp.
- **Các tham số kỹ năng hướng tới người dùng thuộc sở hữu của người dùng**: các cờ và giá trị hiển thị trong `argument-hint` của một kỹ năng thuộc về lệnh của người dùng, không phải chiến lược của tác nhân. Không tự ý tạo, thay đổi hoặc bỏ qua các tham số này chỉ dựa trên trạng thái kho lưu trữ. Nếu người dùng bỏ qua một tham số, chỉ sử dụng giá trị mặc định hoặc giá trị phái sinh khi kỹ năng đó ghi rõ hành vi bỏ qua; nếu không, hãy để nó không được đặt hoặc hỏi người dùng. Các cài đặt phái sinh nội bộ không phải là tham số hướng tới người dùng vẫn có thể được suy ra bởi kỹ năng.
- **Việc chuyển giao trong CHẾ ĐỘ INIT được điều khiển bởi manifest**: khi `/init` ghi `.checkpoints/init-sources.json`, manifest đó trở thành nguồn sự thật duy nhất cho thứ tự ingest và đường dẫn nguồn chính tắc. Các đầu vào cục bộ đã chuẩn bị nên trỏ đến `raw/tmp/`; các bài báo từ bên ngoài được giới thiệu nên trỏ đến `raw/discovered/`.
- **graph/ được tạo tự động**: không bao giờ chỉnh sửa thủ công các tệp trong `graph/` — chỉ thông qua `tools/research_wiki.py`.
- **Liên kết hai chiều**: luôn viết liên kết ngược khi viết liên kết xuôi.
- **Ưu tiên tex**: .tex > .pdf; chuỗi dự phòng: tex thất bại → phân tích PDF, PDF thất bại → API thị giác.
- **index.md được cập nhật sau mỗi ingest**; log.md là chỉ thêm vào.
- **Mặc định lint là chỉ báo cáo**: `--fix` tự động sửa các vấn đề xác định (liên kết ngược xref, giá trị mặc định trường bị thiếu); `--suggest` đưa ra gợi ý cho các vấn đề không xác định; `--fix --dry-run` xem trước các sửa chữa.
- **Quy tắc tạo slug**: từ khóa tiêu đề bài báo, nối bằng dấu gạch ngang, tất cả chữ thường.
- **Điểm quan trọng**: 1 = ngách, 2 = hữu ích, 3 = tiêu chuẩn lĩnh vực, 4 = có ảnh hưởng, 5 = nền tảng.
- **Các ý tưởng thất bại phải ghi lại lý do**: `failure_reason` là bộ nhớ chống lặp lại — ngăn chặn việc khám phá lại các ngõ cụt đã biết.
- **Phạm vi độ tin cậy của khẳng định**: 0.0-1.0; đánh giá lại mỗi khi bằng chứng thay đổi.
- **Các thí nghiệm phải liên kết đến một khẳng định**: mọi thí nghiệm đều yêu cầu `target_claim`; kết quả phải được ghi lại vào bằng chứng của khẳng định.
- **Mã thí nghiệm nằm trong experiments/code/{slug}/**: `/exp-run` ghi mã vào đường dẫn này (`train.py`, `config.yaml`, `run.sh`, `requirements.txt`) — không ghi vào thư mục gốc dự án hoặc nơi khác.
- **Token DeepXiv**: biến môi trường `DEEPXIV_TOKEN`. Nếu không được đặt, SDK sẽ tự động đăng ký (ghi vào `~/.env`). Gói miễn phí: 10,000 yêu cầu/ngày. Khi DeepXiv không khả dụng, tất cả các kỹ năng sẽ chuyển sang chế độ S2+RSS.

---

## Kỹ Năng

| Kỹ năng | Tệp | Kích hoạt |
|-------|------|---------|
| `/setup` | `skills/setup/SKILL.md` | thủ công (cấu hình lần đầu) |
| `/reset` | `skills/reset/SKILL.md` | thủ công (`--scope wiki|raw|log|checkpoints|all`) |
| `/init` | `skills/init/SKILL.md` | thủ công |
| `/prefill` | `skills/prefill/SKILL.md` | thủ công (`[domain] [--add concept]`) |
| `/ingest` | `skills/ingest/SKILL.md` | thủ công |
| `/ask` | `skills/ask/SKILL.md` | thủ công |
| `/edit` | `skills/edit/SKILL.md` | thủ công |
| `/check` | `skills/check/SKILL.md` | hai tuần một lần/thủ công |
| `/daily-arxiv` | `skills/daily-arxiv/SKILL.md` | cron 08:00 / thủ công |
| `/novelty` | `skills/novelty/SKILL.md` | thủ công |
| `/review` | `skills/review/SKILL.md` | thủ công |
| `/ideate` | `skills/ideate/SKILL.md` | thủ công |
| `/exp-design` | `skills/exp-design/SKILL.md` | thủ công |
| `/exp-run` | `skills/exp-run/SKILL.md` | thủ công (`<slug> [--collect] [--full] [--env local|remote]`) |
| `/exp-status` | `skills/exp-status/SKILL.md` | thủ công (`[--pipeline <slug>] [--collect-ready] [--auto-advance]`) |
| `/exp-eval` | `skills/exp-eval/SKILL.md` | thủ công |
| `/refine` | `skills/refine/SKILL.md` | thủ công |
| `/paper-plan` | `skills/paper-plan/SKILL.md` | thủ công |
| `/paper-draft` | `skills/paper-draft/SKILL.md` | thủ công |
| `/paper-compile` | `skills/paper-compile/SKILL.md` | thủ công |
| `/survey` | `skills/survey/SKILL.md` | thủ công |
| `/research` | `skills/research/SKILL.md` | thủ công |
| `/rebuttal` | `skills/rebuttal/SKILL.md` | thủ công |
