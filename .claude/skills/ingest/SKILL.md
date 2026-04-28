---
description: Ingest một bài báo vào wiki — tạo các trang (papers + concepts + people + claims) và xây dựng tất cả các tham chiếu chéo và cạnh đồ thị. Kích hoạt bất cứ khi nào người dùng nói "ingest", "thêm bài báo này", thả `.pdf` / `.tex` / URL arXiv, hoặc yêu cầu tích hợp bài báo vào cơ sở tri thức.
argument-hint: <đường-dẫn-cục-bộ-hoặc-URL-arXiv>
---

# /ingest

Biến một bài báo thành một tập hợp các trang wiki được kết nối đầy đủ. Tạo ra các thực thể có cấu trúc tốt và tham chiếu chéo chính xác; để lại các kiểm tra ngữ nghĩa (đối xứng liên kết ngược, nút treo, kiểm soát giá trị trường) cho `/check`.

Sử dụng các tài liệu tham khảo cục bộ này theo yêu cầu:

- `references/pdf-preprocessing.md` — khôi phục arXiv-ID, lấy tex, chuyển giao prepare-paper cho các tệp PDF thả trực tiếp
- `references/dedup-policy.md` — quy tắc quyết định hợp nhất-so-với-tạo cho concepts và claims, và ranh giới phân tách kiểm tra hình dạng của `/ingest` với kiểm tra ngữ nghĩa của `/check`
- `references/cross-references.md` — ma trận liên kết xuôi/ngược và lựa chọn loại cạnh paper-to-paper
- `references/init-mode.md` — chuyển giao dựa trên manifest từ `/init` và quy ước an toàn song song
- `references/error-handling.md` — phân tích cú pháp nguồn, API và các phương án dự phòng xung đột slug

Mở `docs/runtime-page-templates.vi.md` trước khi soạn thảo bất kỳ frontmatter hoặc phần nội dung trang wiki nào, và `docs/runtime-support-files.vi.md` cho định dạng `index.md`, `log.md` và `graph/`.

## Đầu Vào

- `source`: một trong số — URL arXiv (ví dụ: `https://arxiv.org/abs/2106.09685`), `.tex` cục bộ, `.pdf` cục bộ, hoặc `canonical_ingest_path` được chuyển giao bởi `/init` qua `.checkpoints/init-sources.json`

## Đầu Ra

- `wiki/papers/{slug}.md` — trang bài báo mới
- `wiki/concepts/{slug}.md`, `wiki/people/{slug}.md`, `wiki/claims/{slug}.md` — được tạo một cách tiết kiệm theo `references/dedup-policy.md`, hoặc được chỉnh sửa tại chỗ để thêm liên kết ngược
- `wiki/topics/{slug}.md` — được chỉnh sửa để thêm các công trình nền tảng / gần đây khi bài báo rõ ràng thuộc về một chủ đề hiện có
- `wiki/graph/edges.jsonl` — được thêm qua `tools/research_wiki.py add-edge`
- `wiki/index.md` — các mục mới được thêm
- `wiki/log.md` — một dòng thêm
- `wiki/graph/context_brief.md`, `wiki/graph/open_questions.md` — được xây dựng lại (bỏ qua trong CHẾ ĐỘ INIT; `/init` cha xây dựng lại một lần tại fan-in)

## Tương Tác Wiki

### Đọc

- `wiki/index.md` cho các slug và tags hiện có
- `wiki/papers/*.md` để phát hiện bài báo đã được ingest
- `wiki/concepts/*.md` và `wiki/foundations/*.md` cho các kết quả khớp loại bỏ trùng lặp
- `wiki/claims/*.md` cho các kết quả khớp loại bỏ trùng lặp
- `wiki/people/*.md` cho các tác giả hiện có
- `wiki/topics/*.md` để đặt bài báo dưới các chủ đề hiện có
- `wiki/graph/open_questions.md` để nhận biết khi bài báo giải quyết một khoảng trống đã biết

### Ghi

- `wiki/papers/{slug}.md` — TẠO
- `wiki/concepts/{slug}.md` — TẠO (mới) hoặc CHỈNH SỬA (thêm `key_papers`, aliases, variants)
- `wiki/claims/{slug}.md` — TẠO (mới) hoặc CHỈNH SỬA (thêm mục `evidence`)
- `wiki/people/{slug}.md` — TẠO (chỉ importance ≥ 4) hoặc CHỈNH SỬA (thêm `Key papers`)
- `wiki/topics/{slug}.md` — CHỈ CHỈNH SỬA (không TẠO từ `/ingest`)
- `wiki/graph/edges.jsonl` — THÊM qua công cụ
- `wiki/graph/context_brief.md` — XÂY DỰNG LẠI (bỏ qua trong CHẾ ĐỘ INIT)
- `wiki/graph/open_questions.md` — XÂY DỰNG LẠI (bỏ qua trong CHẾ ĐỘ INIT)
- `wiki/index.md` — THÊM
- `wiki/log.md` — THÊM qua công cụ

### Các cạnh đồ thị được tạo

- `paper → concept`: `supports` / `extends`
- `paper → foundation`: `derived_from` (foundation là điểm cuối; không có liên kết ngược)
- `paper → claim`: `supports` / `contradicts`
- `paper → paper`: `extends` / `supersedes` / `inspired_by` / `contradicts` (xem `references/cross-references.md` cho quy tắc lựa chọn)

## Quy Trình Làm Việc

**Điều kiện tiên quyết**: thư mục làm việc chứa `wiki/`, `raw/` và `tools/`. Giải quyết trình thông dịch Python một lần và tái sử dụng:

```bash
if [ -x .venv/bin/python ]; then
  PYTHON_BIN=.venv/bin/python
elif [ -x .venv/Scripts/python.exe ]; then
  PYTHON_BIN=.venv/Scripts/python.exe
else
  PYTHON_BIN=python3
fi
export PYTHON_BIN
```

### Bước 1: Giải Quyết Nguồn

1. Nếu `/init` chuyển giao `canonical_ingest_path`, vào **CHẾ ĐỘ INIT** và sử dụng đường dẫn đó nguyên văn. Không quét lại `raw/`. Xem `references/init-mode.md`.
2. Nếu nguồn là URL arXiv, lấy `.tex` dưới `raw/discovered/` qua `"$PYTHON_BIN" tools/fetch_arxiv.py`. Quay lại PDF nếu kho lưu trữ nguồn không khả dụng.
3. Nếu nguồn là `.tex` cục bộ, sử dụng trực tiếp.
4. Nếu nguồn là `.pdf` cục bộ, chạy quy trình tiền xử lý trong `references/pdf-preprocessing.md` để tạo ra `.tex` đã chuẩn bị dưới `raw/tmp/` trước khi tiếp tục.

Quy tắc lưu trữ thô: không bao giờ sao chép hoặc nhân đôi tệp đã có dưới `raw/discovered/`, `raw/tmp/` hoặc `raw/papers/` vào cây con thô khác.

### Bước 2: Danh Tính và Làm Giàu Bài Báo

1. Tạo slug bài báo:

   ```bash
   "$PYTHON_BIN" tools/research_wiki.py slug "<tiêu-đề-bài-báo>"
   ```

2. Dừng-nếu-tồn-tại: nếu `wiki/papers/{slug}.md` đã tồn tại và ID arXiv hoặc tiêu đề khớp, báo cáo và thoát. Nếu khác nhau, giải quyết xung đột theo `references/error-handling.md`.
3. Khi có ID arXiv, truy vấn Semantic Scholar:

   ```bash
   "$PYTHON_BIN" tools/fetch_s2.py paper <arxiv-id>
   ```

   Sử dụng kết quả cho `venue`, `year`, `s2_id`, số lượng trích dẫn và bằng chứng đằng sau điểm `importance` (1-5).
4. Làm giàu DeepXiv tùy chọn, khi khả dụng. Bỏ qua âm thầm nếu thất bại:

   ```bash
   "$PYTHON_BIN" tools/fetch_deepxiv.py brief <arxiv-id>
   "$PYTHON_BIN" tools/fetch_deepxiv.py head <arxiv-id>
   "$PYTHON_BIN" tools/fetch_deepxiv.py social <arxiv-id>
   ```

   `brief` khởi tạo phần Key-idea; `head` kiểm tra phân tích tex của bạn với cấu trúc phần; `social` là tín hiệu importance phụ trợ.

### Bước 3: Viết Trang Bài Báo

Mở `docs/runtime-page-templates.vi.md` cho mẫu paper. Điền mọi trường frontmatter bắt buộc; để `cited_by` trống hiện tại (bước 5 điền lại).

Trước khi viết, chạy **kiểm tra hình dạng** trên frontmatter bạn sắp tạo — không hơn thế này:

- mọi khóa bắt buộc đều có mặt và không trống
- `importance` ∈ {1,2,3,4,5}; `status` trên claims ∈ tập hợp được ghi chép; `maturity` trên concepts ∈ tập hợp được ghi chép; `confidence` ∈ [0,1]
- YAML phân tích được

Kiểm tra hình dạng cố ý hẹp. Đối xứng liên kết ngược, phát hiện nút treo và tính nhất quán giữa các thực thể là công việc của `/check`, không phải kỹ năng này.

Các phần nội dung cần điền: Problem, Key idea, Method, Results, Limitations, Open questions, My take, Related.

### Bước 4: Concepts, Claims, People

Tuân theo `references/dedup-policy.md`. Tóm lại:

1. Đối với mỗi concept hoặc claim ứng viên, gọi công cụ `find-similar-*` khớp trước.
2. Ưu tiên hợp nhất vào kết quả hàng đầu. Chỉ tạo trang mới khi công cụ không trả về ứng viên chấp nhận được và importance của bài báo biện minh cho nó.
3. Đối với mỗi thực thể bạn viết hoặc chỉnh sửa, viết liên kết ngược trong cùng lượt. Ma trận nghĩa vụ nằm trong `references/cross-references.md`.
4. Chỉ tạo `wiki/people/{slug}.md` cho các bài báo có importance ≥ 4. Nếu không, chỉ thêm vào các trang tác giả hiện có.

### Bước 5: Các Cạnh Paper-to-Paper và `cited_by`

Bỏ qua toàn bộ bước này trong CHẾ ĐỘ INIT — `/init` cha xử lý nó tại fan-in.

```bash
"$PYTHON_BIN" tools/fetch_s2.py references <arxiv-id>
"$PYTHON_BIN" tools/fetch_s2.py citations <arxiv-id>
```

- Đối với mỗi tham chiếu có ID arXiv hoặc tiêu đề giải quyết thành `wiki/papers/{slug}.md` hiện có, thêm một cạnh paper-to-paper duy nhất. Lựa chọn loại cạnh nằm trong `references/cross-references.md`. Nếu không có bài báo wiki hiện có nào khớp, **không suy đoán** — bỏ qua.
- Đối với mỗi trích dẫn đã có trong wiki, thêm slug của người trích dẫn vào `cited_by` của bài báo này.
- Nổi bật các tham chiếu có trích dẫn cao không khớp trong báo cáo cuối cùng để người dùng có thể quyết định có nên theo dõi bằng `/ingest` khác không.

### Bước 6: Topics và Index

1. Khớp lĩnh vực và tags của bài báo với `wiki/topics/*.md` hiện có. Đối với mỗi kết quả khớp:
   - importance ≥ 4 → thêm vào `## Seminal works` của chủ đề
   - importance < 4 → thêm dưới `## SOTA tracker` hoặc `## Recent work` theo năm
   - nếu bài báo trực tiếp giải quyết một vấn đề mở được liệt kê, chú thích dòng đó trên trang chủ đề
2. Không tạo trang chủ đề mới từ `/ingest` — tạo chủ đề thuộc về `/init` và `/edit`.
3. Thêm các mục trang mới hoặc đã chỉnh sửa vào `wiki/index.md` dưới tiêu đề danh mục của chúng. Xem `docs/runtime-support-files.vi.md` cho định dạng chính xác.

### Bước 7: Log và Xây Dựng Lại

```bash
"$PYTHON_BIN" tools/research_wiki.py log wiki/ "ingest | added papers/<slug> | updated: <danh-sách>"
```

Trừ khi trong CHẾ ĐỘ INIT:

```bash
"$PYTHON_BIN" tools/research_wiki.py rebuild-context-brief wiki/
"$PYTHON_BIN" tools/research_wiki.py rebuild-open-questions wiki/
```

### Bước 8: Báo Cáo

Tạo một tóm tắt ngắn gọn bao gồm: các trang đã tạo, các trang đã cập nhật, các cạnh đồ thị đã thêm, các mâu thuẫn được nổi lên (nếu có), và các tham chiếu có trích dẫn cao chưa có trong wiki (đề xuất ingest tiếp theo). Kết thúc bằng:

```
Wiki: +1 paper, +{N} claims, +{M} concepts, +{K} edges
```

## Các Ràng Buộc

- `raw/papers/`, `raw/notes/`, `raw/web/` thuộc sở hữu của người dùng và chỉ đọc. `/ingest` cục bộ trực tiếp có thể thêm các tệp tạm thời đã chuẩn bị dưới `raw/tmp/`; các ingest arXiv trực tiếp có thể ghi các tạo tác nguồn đã lấy dưới `raw/discovered/`. CHẾ ĐỘ INIT coi toàn bộ `raw/` là chỉ đọc.
- `wiki/graph/` thuộc sở hữu của công cụ. Chỉ chỉnh sửa thông qua `tools/research_wiki.py`.
- Slug luôn đến từ `tools/research_wiki.py slug`. Không bao giờ tự tạo.
- Mọi liên kết xuôi viết liên kết ngược của nó trong cùng lượt — bất biến liên kết hai chiều của wiki. Ngoại lệ duy nhất là liên kết đến `wiki/foundations/`, là điểm cuối.
- Ưu tiên nguồn: `.tex` > `.pdf` > dự phòng API thị giác. Không bao giờ ingest từ PDF khi có `.tex` khả dụng.
- Ingest thận trọng về các thực thể mới:
  - importance < 4: tối đa **1** concept mới và **1** claim mới mỗi bài báo
  - importance ≥ 4: tối đa **3** concepts mới và **2** claims mới mỗi bài báo
  - Bất kỳ ứng viên nào khác phải được hợp nhất vào kết quả `find-similar-*` gần nhất của chúng, hoặc bỏ qua để `/check` gắn cờ. Lý do và quy tắc khớp: `references/dedup-policy.md`.
- `/ingest` chạy kiểm tra hình dạng trên đầu ra của chính nó (các khóa bắt buộc, phạm vi enum, YAML phân tích được) và dừng ở đó. Đối xứng liên kết ngược, nút treo và kiểm tra ngữ nghĩa đầy đủ thuộc về `/check`. Không triển khai lại chúng ở đây.
- Giả sử một `/ingest` khác có thể chạy đồng thời trong worktree anh em. Tất cả các ghi tệp chia sẻ (`graph/edges.jsonl`, `index.md`, `log.md`) phải đi qua `tools/research_wiki.py` hoặc sử dụng ngữ nghĩa chỉ thêm. Xem `references/init-mode.md`.
- Trong CHẾ ĐỘ INIT, bỏ qua `fetch_s2.py citations`, `fetch_s2.py references` và các lệnh `rebuild-*` — `/init` cha chạy chúng một lần sau fan-in.

## Xử Lý Lỗi

Xem `references/error-handling.md`. Điểm nổi bật: thất bại phân tích cú pháp nguồn theo tầng tex → PDF → API thị giác → chuyển giao người dùng; mất kết nối S2 mặc định `importance` là 3 và bỏ qua điền lại trích dẫn; mất kết nối DeepXiv bỏ qua làm giàu âm thầm; xung đột slug thêm hậu tố số.

## Phụ Thuộc

### Công cụ (qua Bash)

- `"$PYTHON_BIN" tools/research_wiki.py slug "<title>"`
- `"$PYTHON_BIN" tools/research_wiki.py find-similar-concept wiki/ "<title>" --aliases "<a,b,c>"`
- `"$PYTHON_BIN" tools/research_wiki.py find-similar-claim wiki/ "<title>" --tags "<a,b,c>"`
- `"$PYTHON_BIN" tools/research_wiki.py add-edge wiki/ --from <id> --to <id> --type <type> --evidence "<text>"`
- `"$PYTHON_BIN" tools/research_wiki.py log wiki/ "<message>"`
- `"$PYTHON_BIN" tools/research_wiki.py rebuild-context-brief wiki/`
- `"$PYTHON_BIN" tools/research_wiki.py rebuild-open-questions wiki/`
- `"$PYTHON_BIN" tools/prepare_paper_source.py --raw-root raw --source <local-path> [--title "<recovered-title>"] [--arxiv-id "<recovered-arxiv-id>"]`
- `"$PYTHON_BIN" tools/fetch_arxiv.py <arxiv-id-or-url>` — tải xuống nguồn arXiv
- `"$PYTHON_BIN" tools/fetch_s2.py paper|citations|references <arxiv-id>`
- `"$PYTHON_BIN" tools/fetch_deepxiv.py brief|head|social <arxiv-id>`

### Tài Liệu Tham Khảo Chung

- `.claude/skills/shared-references/citation-verification.md`

### Kỹ Năng

- `/init` — gọi `/ingest` trong các tiểu tác nhân song song qua CHẾ ĐỘ INIT
- `/check` — kiểm tra trạng thái wiki sau khi `/ingest` hoàn thành; sở hữu mọi kiểm tra ngữ nghĩa mà `/ingest` cố ý không thực hiện

### API Ngoại Vi

- Semantic Scholar (qua `tools/fetch_s2.py`)
- DeepXiv (qua `tools/fetch_deepxiv.py`, tùy chọn; dự phòng an toàn)
- arXiv (tải xuống nguồn)