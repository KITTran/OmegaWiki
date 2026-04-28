---
description: Ingest một bài báo vào wiki — tạo các trang (papers + concepts + people + claims) và xây dựng tất cả các tham chiếu chéo và cạnh đồ thị. Kích hoạt bất cứ khi nào người dùng nói "ingest", "thêm bài báo này", thả tệp `.pdf` / `.tex` / URL arXiv, hoặc yêu cầu tích hợp bài báo vào cơ sở tri thức.
argument-hint: <đường-dẫn-cục-bộ-hoặc-URL-arXiv> [--discover]
---

# /ingest

Chuyển một bài báo thành một tập hợp các trang wiki được kết nối đầy đủ. Tạo ra các thực thể có cấu trúc tốt và các tham chiếu chéo chính xác; để lại các kiểm tra ngữ nghĩa (đối xứng liên kết ngược, nút treo, kiểm soát giá trị trường) cho `/check`.

Sử dụng các tài liệu tham khảo cục bộ này theo yêu cầu:

- `references/pdf-preprocessing.md` — khôi phục arXiv-ID, lấy tex, chuyển giao prepare-paper cho các tệp PDF thả trực tiếp
- `references/dedup-policy.md` — quy tắc quyết định hợp nhất-so-với-tạo cho concepts và claims, và ranh giới phân tách kiểm tra hình dạng của `/ingest` với kiểm tra ngữ nghĩa của `/check`
- `references/cross-references.md` — ma trận liên kết xuôi/ngược và lựa chọn loại cạnh paper-to-paper
- `references/init-mode.md` — chuyển giao dựa trên manifest từ `/init` và quy ước an toàn song song
- `references/error-handling.md` — xử lý lỗi phân tích cú pháp nguồn, API, và xung đột slug

Mở `docs/runtime-page-templates.vi.md` trước khi soạn thảo bất kỳ frontmatter hoặc phần nội dung trang wiki nào, và `docs/runtime-support-files.vi.md` cho định dạng `index.md`, `log.md` và `graph/`.

## Đầu Vào

- `source`: một trong các loại sau — URL arXiv (ví dụ: `https://arxiv.org/abs/2106.09685`), tệp `.tex` cục bộ, tệp `.pdf` cục bộ, hoặc `canonical_ingest_path` được chuyển giao bởi `/init` thông qua `.checkpoints/init-sources.json` (xem `references/init-mode.md`)
- `--discover` (tùy chọn, mặc định **tắt**): sau báo cáo cuối cùng, gọi `/discover --anchor <arxiv-id-của-bài-báo-này>` và thêm danh sách ngắn vào báo cáo dưới dạng "Các bài báo liên quan bạn có thể muốn ingest tiếp theo". Không bao giờ tự động ingest các gợi ý. Bỏ qua tự động trong CHẾ ĐỘ INIT. Xem đây là cờ thuộc sở hữu của người dùng: không thiết lập nó dựa trên trạng thái kho lưu trữ.

## Đầu Ra

- Một trang bài báo được kết nối đầy đủ cùng với các thực thể liên kết (concepts, claims, people)
- Các cạnh đồ thị và trích dẫn được thêm thông qua `tools/research_wiki.py`
- Báo cáo cuối cùng với số lượng trang và các gợi ý ingest tiếp theo

## Tương Tác Wiki

### Đọc

- `wiki/index.md` để lấy các slug và thẻ hiện có
- `wiki/papers/*.md` để phát hiện bài báo đã được ingest
- `wiki/concepts/*.md` và `wiki/foundations/*.md` để tìm các kết quả trùng lặp
- `wiki/claims/*.md` để tìm các kết quả trùng lặp
- `wiki/people/*.md` để tìm các tác giả hiện có
- `wiki/topics/*.md` để đặt bài báo dưới các chủ đề hiện có
- `wiki/graph/open_questions.md` để nhận biết khi bài báo giải quyết một khoảng trống đã biết

### Ghi

- `wiki/papers/{slug}.md` — TẠO
- `wiki/concepts/{slug}.md` — TẠO (mới) hoặc CHỈNH SỬA (thêm `key_papers`, aliases, variants)
- `wiki/claims/{slug}.md` — TẠO (mới) hoặc CHỈNH SỬA (thêm mục `evidence`)
- `wiki/people/{slug}.md` — TẠO (chỉ với importance ≥ 4) hoặc CHỈNH SỬA (thêm `Key papers`)
- `wiki/topics/{slug}.md` — CHỈ CHỈNH SỬA (không TẠO từ `/ingest`)
- `wiki/graph/edges.jsonl` — THÊM thông qua công cụ
- `wiki/graph/citations.jsonl` — THÊM thông qua công cụ
- `wiki/graph/context_brief.md` — XÂY DỰNG LẠI (bỏ qua trong CHẾ ĐỘ INIT)
- `wiki/graph/open_questions.md` — XÂY DỰNG LẠI (bỏ qua trong CHẾ ĐỘ INIT)
- `wiki/index.md` — THÊM
- `wiki/log.md` — THÊM thông qua công cụ

### Các cạnh đồ thị được tạo

- `paper → concept`: `introduces_concept` / `uses_concept` / `extends_concept` / `critiques_concept` với `confidence`
- `paper → foundation`: `derived_from` (foundation là điểm cuối; không có liên kết ngược)
- `paper → claim`: `supports` / `contradicts`
- `paper → paper`: `same_problem_as` / `similar_method_to` / `complementary_to` / `builds_on` / `compares_against` / `improves_on` / `challenges` / `surveys` với `confidence`
- trích dẫn thư mục `paper → paper`: `cites` trong `graph/citations.jsonl`

`tools/research_wiki.py add-edge` từ chối thiếu confidence/evidence cho các cạnh ngữ nghĩa paper-paper và paper-concept, và từ chối các loại cạnh paper-to-concept hoặc paper-to-paper cũ trong các lần ghi mới.

## Quy Trình Làm Việc

**Điều kiện tiên quyết**: thư mục làm việc chứa `wiki/`, `raw/` và `tools/`. Giải quyết trình thông dịch Python một lần và tái sử dụng:

```bash
# Tìm thư mục gốc dự án thông qua git để các tiểu tác nhân worktree vẫn có thể định vị .venv.
# .venv bị gitignore, vì vậy một tiểu tác nhân có thư mục làm việc là ../.worktrees/<branch>/ 
# sẽ không có .venv — nếu không có tra cứu này, nó sẽ quay lại python3 hệ thống và
# bỏ lỡ các khóa API được tải từ .env cùng các gói phụ thuộc đã cài đặt (deepxiv-sdk, v.v.).
# git rev-parse --git-common-dir trả về thư mục .git chính của kho lưu trữ bất kể
# worktree nào đang được sử dụng; thư mục cha của nó là thư mục gốc dự án.
GIT_COMMON_DIR=$(git rev-parse --git-common-dir 2>/dev/null || true)
PROJECT_ROOT=""
if [ -n "$GIT_COMMON_DIR" ]; then
  PROJECT_ROOT=$(cd "$(dirname "$GIT_COMMON_DIR")" 2>/dev/null && pwd)
fi

if   [ -x "$PROJECT_ROOT/.venv/bin/python" ];         then PYTHON_BIN="$PROJECT_ROOT/.venv/bin/python"
elif [ -x "$PROJECT_ROOT/.venv/Scripts/python.exe" ]; then PYTHON_BIN="$PROJECT_ROOT/.venv/Scripts/python.exe"
elif [ -x .venv/bin/python ];                         then PYTHON_BIN=.venv/bin/python
elif [ -x .venv/Scripts/python.exe ];                 then PYTHON_BIN=.venv/Scripts/python.exe
else                                                       PYTHON_BIN=python3
fi
export PYTHON_BIN
```

### Bước 1: Giải quyết nguồn

1. Nếu `/init` đã chuyển giao `canonical_ingest_path`, vào **CHẾ ĐỘ INIT** và sử dụng đường dẫn đó nguyên văn. Không quét lại `raw/`. Xem `references/init-mode.md`.
2. Nếu nguồn là URL arXiv, trích xuất arXiv ID, sử dụng `"$PYTHON_BIN" tools/fetch_s2.py paper <arxiv-id>` để khôi phục tiêu đề khi có thể, sau đó chạy `"$PYTHON_BIN" tools/init_discovery.py download --raw-root raw --arxiv-id <arxiv-id> --title "<tiêu-đề-hoặc-arxiv-id>"`. Tiếp tục từ `canonical_ingest_path` được trả về. Trình trợ giúp thử nguồn arXiv trước và quay lại PDF; không gọi `fetch_arxiv.py` cho một bài báo đơn lẻ vì nó chỉ dành cho RSS.
3. Nếu nguồn là tệp `.tex` cục bộ, sử dụng trực tiếp.
4. Nếu nguồn là tệp `.pdf` cục bộ, chạy quy trình tiền xử lý trong `references/pdf-preprocessing.md` để tạo ra tệp `.tex` đã chuẩn bị dưới `raw/tmp/` trước khi tiếp tục.

Quy tắc lưu trữ thô: không bao giờ sao chép hoặc nhân đôi một tệp đã có dưới `raw/discovered/`, `raw/tmp/` hoặc `raw/papers/` vào một cây con thô khác.

### Bước 2: Danh tính và làm giàu bài báo

1. Tạo slug bài báo:

   ```bash
   "$PYTHON_BIN" tools/research_wiki.py slug "<tiêu-đề-bài-báo>"
   ```

2. Dừng nếu đã tồn tại: nếu `wiki/papers/{slug}.md` đã tồn tại và ID arXiv hoặc tiêu đề khớp, báo cáo và thoát. Nếu khác nhau, giải quyết xung đột theo `references/error-handling.md`.
3. Khi có sẵn ID arXiv, truy vấn Semantic Scholar:

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

   `brief` khởi tạo phần Ý tưởng chính; `head` kiểm tra phân tích tex của bạn với cấu trúc phần; `social` là tín hiệu quan trọng phụ trợ.

### Bước 3: Viết trang bài báo

Mở `docs/runtime-page-templates.vi.md` để xem mẫu bài báo. Điền tất cả các trường frontmatter bắt buộc; để trống `cited_by` hiện tại (bước 5 sẽ điền lại).

Trước khi viết, chạy **kiểm tra hình dạng** trên frontmatter bạn sắp xuất ra — không nhiều hơn thế này:

- mọi khóa bắt buộc đều có mặt và không trống
- `importance` ∈ {1,2,3,4,5}; `status` trên claims thuộc tập hợp đã được ghi chép; `maturity` trên concepts thuộc tập hợp đã được ghi chép; `confidence` của claim ∈ [0,1]
- YAML phân tích được

Kiểm tra hình dạng được thiết kế hẹp. Đối xứng liên kết ngược, phát hiện nút treo và tính nhất quán giữa các thực thể là công việc của `/check`, không phải kỹ năng này.

Các phần nội dung cần điền: Problem, Key idea, Method, Results, Limitations, Open questions, My take, Related.

### Bước 4: Concepts, claims, people

Tuân theo `references/dedup-policy.md`. Tóm tắt:

1. Đối với mỗi concept hoặc claim ứng viên, gọi công cụ `find-similar-*` tương ứng trước.
2. Ưu tiên hợp nhất vào kết quả hàng đầu. Chỉ tạo trang mới khi công cụ không trả về ứng viên chấp nhận được và importance của bài báo biện minh cho điều đó.
3. Đối với mỗi thực thể bạn viết hoặc chỉnh sửa, viết liên kết ngược trong cùng lượt. Ma trận nghĩa vụ nằm trong `references/cross-references.md`.
4. Chỉ tạo `wiki/people/{slug}.md` cho các bài báo có importance ≥ 4. Nếu không, chỉ thêm vào các trang tác giả hiện có.

### Bước 5: Các cạnh paper-to-paper và `cited_by`

Bỏ qua toàn bộ bước này trong CHẾ ĐỘ INIT — `/init` cha xử lý nó tại fan-in.

```bash
"$PYTHON_BIN" tools/fetch_s2.py references <arxiv-id>
"$PYTHON_BIN" tools/fetch_s2.py citations <arxiv-id>
```

- Đối với mỗi tham chiếu có ID arXiv hoặc tiêu đề trùng khớp với `wiki/papers/{slug}.md` hiện có, thêm một hàng `cites` thư mục vào `graph/citations.jsonl`.
- Thêm một cạnh ngữ nghĩa paper-to-paper vào `graph/edges.jsonl` chỉ khi văn bản nguồn đưa ra tín hiệu rõ ràng. Lựa chọn loại cạnh nằm trong `references/cross-references.md`. Nếu không có quan hệ ngữ nghĩa nào phù hợp, chỉ giữ lại hàng `cites`.
- Đối với mỗi trích dẫn đã có trong wiki, thêm slug của người trích dẫn vào `cited_by` của bài báo này.
- Nêu bật các tham chiếu có trích dẫn cao không trùng khớp trong báo cáo cuối cùng để người dùng có thể quyết định có nên theo dõi bằng `/ingest` khác không.

### Bước 6: Topics và index

1. Khớp lĩnh vực và thẻ của bài báo với `wiki/topics/*.md` hiện có. Đối với mỗi khớp:
   - importance ≥ 4 → thêm vào `## Seminal works` của chủ đề
   - importance < 4 → thêm dưới `## SOTA tracker` hoặc `## Recent work` theo năm
   - nếu bài báo trực tiếp giải quyết một vấn đề mở được liệt kê, chú thích dòng đó trên trang chủ đề
2. Không tạo trang chủ đề mới từ `/ingest` — việc tạo chủ đề thuộc về `/init` và `/edit`.
3. Thêm các mục trang mới hoặc đã chỉnh sửa vào `wiki/index.md` dưới các tiêu đề danh mục của chúng. Xem `docs/runtime-support-files.vi.md` cho định dạng chính xác.

### Bước 7: Log và xây dựng lại

```bash
"$PYTHON_BIN" tools/research_wiki.py log wiki/ "ingest | added papers/<slug> | updated: <danh-sách>"
```

Trừ khi trong CHẾ ĐỘ INIT:

```bash
"$PYTHON_BIN" tools/research_wiki.py rebuild-context-brief wiki/
"$PYTHON_BIN" tools/research_wiki.py rebuild-open-questions wiki/
```

### Bước 8: Báo cáo

Xuất một bản tóm tắt ngắn gọn bao gồm: số trang được tạo, trang được cập nhật, cạnh đồ thị được thêm, các mâu thuẫn được phát hiện (nếu có), và các tham chiếu có trích dẫn cao chưa có trong wiki (đề xuất ingest tiếp theo). Kết thúc bằng:

```
Wiki: +1 paper, +{N} claims, +{M} concepts, +{K} edges
```

### Bước 9: Khám phá tùy chọn (chỉ khi `--discover` được thiết lập)

Bỏ qua bước này trừ khi người dùng đã truyền rõ ràng `--discover`. Cũng bỏ qua trong CHẾ ĐỘ INIT — tiến trình cha `/init` quyết định có chạy khám phá tại fan-in hay không, không phải các tiểu tác nhân riêng lẻ.

Khi được kích hoạt, gọi `/discover` với bài báo vừa ingest làm điểm neo duy nhất:

```bash
"$PYTHON_BIN" tools/discover.py from-anchors \
  --id <arxiv-id-của-bài-báo-này> \
  --wiki-root wiki \
  --limit 10 \
  --output-checkpoint .checkpoints/ \
  --markdown
```

Thêm đầu ra markdown vào báo cáo dưới tiêu đề như "Các bài báo liên quan bạn có thể muốn ingest tiếp theo". Không tự động ingest bất kỳ mục nào từ danh sách ngắn — người dùng sẽ chọn. Nếu khám phá thất bại (mất kết nối S2, tất cả kênh đều trống), ghi chú thất bại trong một dòng và tiếp tục — một `/discover` thất bại không được làm hỏng một `/ingest` thành công.

## Các Ràng Buộc

- `raw/papers/`, `raw/notes/`, `raw/web/` thuộc sở hữu của người dùng và chỉ đọc. `/ingest` cục bộ trực tiếp có thể thêm các tệp tạm thời đã chuẩn bị dưới `raw/tmp/`; các ingest arXiv trực tiếp có thể ghi các tạo tác nguồn đã lấy dưới `raw/discovered/`. CHẾ ĐỘ INIT coi toàn bộ `raw/` là chỉ đọc.
- `wiki/graph/` thuộc sở hữu của công cụ. Chỉ chỉnh sửa thông qua `tools/research_wiki.py`.
- Slug luôn đến từ `tools/research_wiki.py slug`. Không bao giờ tự tạo.
- Mọi liên kết xuôi đều viết liên kết ngược của nó trong cùng lượt — bất biến liên kết hai chiều của wiki. Ngoại lệ duy nhất là liên kết đến `wiki/foundations/`, là điểm cuối.
- Trong CHẾ ĐỘ INIT, không viết liên kết ngược vào các trang đã tồn tại (được tạo bởi worktree anh em hoặc khung). Chỉ ghi lại mối quan hệ thông qua `tools/research_wiki.py add-edge`; `/init` cha sẽ điền lại các liên kết ngược trong quá trình fan-in.
- Ưu tiên nguồn: `.tex` > `.pdf` > dự phòng API thị giác. Không bao giờ ingest từ PDF khi có sẵn `.tex` khả dụng.
- Ingest thận trọng về các thực thể mới:
  - importance < 4: tối đa **1** concept mới và **1** claim mới mỗi bài báo
  - importance ≥ 4: tối đa **3** concepts mới và **2** claims mới mỗi bài báo
  - Bất kỳ ứng viên nào khác phải được hợp nhất vào kết quả `find-similar-*` gần nhất của chúng, hoặc bỏ qua để `/check` gắn cờ. Lý do và quy tắc khớp: `references/dedup-policy.md`.
- `/ingest` chạy kiểm tra hình dạng trên đầu ra của chính nó (các khóa bắt buộc, phạm vi enum, YAML phân tích được) và dừng ở đó. Đối xứng liên kết ngược, nút treo và kiểm tra ngữ nghĩa đầy đủ thuộc về `/check`. Không triển khai lại chúng ở đây.
- Giả sử một `/ingest` khác có thể chạy đồng thời trong worktree anh em. Tất cả các ghi tệp chia sẻ (`graph/edges.jsonl`, `graph/citations.jsonl`, `index.md`, `log.md`) phải đi qua `tools/research_wiki.py` hoặc sử dụng ngữ nghĩa chỉ thêm. Xem `references/init-mode.md`.
- Trong CHẾ ĐỘ INIT, bỏ qua `fetch_s2.py citations`, `fetch_s2.py references` và các lệnh `rebuild-*` — `/init` cha chạy chúng một lần sau fan-in.

## Xử Lý Lỗi

Xem `references/error-handling.md`. Điểm nổi bật: thất bại phân tích cú pháp nguồn theo tầng tex → PDF → API thị giác → chuyển giao người dùng; mất kết nối S2 mặc định `importance` là 3 và bỏ qua điền lại trích dẫn; mất kết nối DeepXiv bỏ qua làm giàu âm thầm; xung đột slug thêm hậu tố số.

## Phụ Thuộc

### Công cụ (qua Bash)

- `"$PYTHON_BIN" tools/research_wiki.py slug "<title>"`
- `"$PYTHON_BIN" tools/research_wiki.py find-similar-concept wiki/ "<title>" --aliases "<a,b,c>"`
- `"$PYTHON_BIN" tools/research_wiki.py find-similar-claim wiki/ "<title>" --tags "<a,b,c>"`
- `"$PYTHON_BIN" tools/research_wiki.py add-edge wiki/ --from <id> --to <id> --type <type> --evidence "<text>" [--confidence high|medium|low]`
  - `--confidence high|medium|low` là bắt buộc đối với các cạnh ngữ nghĩa paper-paper và paper-concept.
- `"$PYTHON_BIN" tools/research_wiki.py add-citation wiki/ --from papers/<người-trích-dẫn> --to papers/<được-trích-dẫn> --source semantic_scholar`
- `"$PYTHON_BIN" tools/research_wiki.py log wiki/ "<message>"`
- `"$PYTHON_BIN" tools/research_wiki.py rebuild-context-brief wiki/`
- `"$PYTHON_BIN" tools/research_wiki.py rebuild-open-questions wiki/`
- `"$PYTHON_BIN" tools/prepare_paper_source.py --raw-root raw --source <đường-dẫn-cục-bộ> [--title "<tiêu-đề-đã-khôi-phục>"] [--arxiv-id "<arxiv-id-đã-khôi-phục>"]`
- `"$PYTHON_BIN" tools/init_discovery.py download --raw-root raw --arxiv-id <id> --title "<tiêu-đề-hoặc-id>"` — tải xuống nguồn/PDF arXiv đơn lẻ vào `raw/discovered/`
- `"$PYTHON_BIN" tools/fetch_s2.py paper|citations|references <arxiv-id>`
- `"$PYTHON_BIN" tools/fetch_deepxiv.py brief|head|social <arxiv-id>`
- `"$PYTHON_BIN" tools/discover.py from-anchors --id <arxiv-id> --wiki-root wiki --limit 10 --output-checkpoint .checkpoints/ --markdown` — chỉ khi `--discover` được thiết lập

### Tài Liệu Tham Khảo Chung

- `.claude/skills/shared-references/citation-verification.md`

### Kỹ Năng

- `/init` — gọi `/ingest` trong các tiểu tác nhân song song qua CHẾ ĐỘ INIT
- `/check` — kiểm tra trạng thái wiki sau khi `/ingest` hoàn thành; sở hữu mọi kiểm tra ngữ nghĩa mà `/ingest` cố ý không thực hiện
- `/discover` — tùy chọn theo dõi khi `--discover` được thiết lập; tạo danh sách ngắn các bài báo liên quan mà người dùng có thể muốn ingest tiếp theo

### API Ngoại Vi

- Semantic Scholar (qua `tools/fetch_s2.py`)
- DeepXiv (qua `tools/fetch_deepxiv.py`, tùy chọn; dự phòng an toàn)
- arXiv (tải xuống nguồn)