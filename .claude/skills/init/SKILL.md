---
description: Khởi tạo ΩmegaWiki từ các nguồn của người dùng cộng với khám phá tùy chọn, sau đó ingest tập hợp bài báo cuối cùng song song
argument-hint: "[chủ-đề] [--no-introduction]"
---

# /init

> Xây dựng wiki từ `raw/` với chuẩn bị nguồn xác định, khám phá hướng dẫn bởi planner, tạo khung ghi chú/web tạm thời và `/ingest` song song fan-out/fan-in.

Sử dụng các tài liệu tham khảo cục bộ này theo yêu cầu:

- `references/prepare-and-discovery.md` — luồng chuẩn bị, lựa chọn cuối cùng, lấy và quy tắc manifest nguồn
- `references/planner-policy.md` — hành vi planner và kỳ vọng cắt giảm LLM
- `references/parallel-ingest.md` — cô lập worktree, hợp đồng lời nhắc tiểu tác nhân, hợp nhất và dọn dẹp

## Đầu Vào

- `topic` (tùy chọn): từ khóa hướng nghiên cứu; bỏ qua khi `raw/papers/` đã xác định tập hợp hạt giống hoặc khi notes/web đã nắm bắt ý định
- `--no-introduction` (tùy chọn): vô hiệu hóa khám phá bài báo bên ngoài; chỉ sử dụng `raw/papers/`, `raw/notes/` và `raw/web/` thuộc sở hữu người dùng
- ràng buộc tham số: coi `topic` và `--no-introduction` là đầu vào của người dùng, không phải nút điều khiển chiến lược tác nhân. Không suy ra `--no-introduction` chỉ từ trạng thái kho lưu trữ. Chỉ sử dụng nó khi người dùng yêu cầu rõ ràng vô hiệu hóa khám phá bên ngoài.
- `raw/papers/`: nguồn bài báo thuộc sở hữu người dùng (`.tex`, `.pdf`, kho lưu trữ)
- `raw/notes/`: ghi chú thuộc sở hữu người dùng thể hiện mục tiêu, giả thuyết, loại trừ và các hướng phụ ưa thích
- `raw/web/`: các trang web đã lưu thuộc sở hữu người dùng thể hiện mục tiêu, giả thuyết, loại trừ và các hướng phụ ưa thích

## Đầu Ra

- `wiki/` khung thông qua `tools/research_wiki.py init`
- `raw/tmp/` — các nguồn cục bộ đã chuẩn bị được tạo ra, được tái sử dụng bởi `/init` và `/ingest` cục bộ trực tiếp
- `raw/discovered/` — các bài báo mới tải xuống được `/init` chọn khi khám phá được bật
- `wiki/Summary/{area}.md`, `wiki/topics/{topic}.md`, `wiki/ideas/{slug}.md` tạm thời, `wiki/concepts/{slug}.md`, `wiki/claims/{slug}.md`
- `wiki/papers/*.md` cộng với các khái niệm / khẳng định / người có nguồn gốc từ bài báo thông qua `/ingest` song song
- đã cập nhật `wiki/index.md`, `wiki/log.md`, `wiki/graph/edges.jsonl`, `wiki/graph/context_brief.md`, `wiki/graph/open_questions.md`
- `.checkpoints/init-prepare.json`, `.checkpoints/init-plan.json`, `.checkpoints/init-sources.json`

## Tương Tác Wiki

### Đọc

- `raw/papers/`, `raw/notes/`, `raw/web/`
- `.checkpoints/init-prepare.json` và `.checkpoints/init-sources.json` để tiếp tục, lập kế hoạch và fan-out
- `wiki/index.md` cộng với `wiki/topics/`, `wiki/ideas/`, `wiki/concepts/`, `wiki/claims/` hiện có để tránh trùng lặp và căn chỉnh khung

### Ghi

- `wiki/` khung và các trang tạm thời
- `raw/tmp/` và `raw/discovered/`
- `wiki/index.md`, `wiki/log.md`, `wiki/graph/*`
- `.checkpoints/init-prepare.json`, `.checkpoints/init-plan.json`, `.checkpoints/init-sources.json`, và siêu dữ liệu checkpoint `init-session`

### Các cạnh đồ thị được tạo

- `/init` chỉ tự tạo các cạnh cấp khung khi các trang tạm thời cần chúng
- tất cả các cạnh do bài báo tạo ra được ủy quyền cho `/ingest`

## Quy Trình Làm Việc

**Điều kiện tiên quyết**: thư mục làm việc là thư mục gốc dự án chứa `wiki/`, `raw/` và `tools/`. Đặt `WIKI_ROOT=wiki/`. Giải quyết `PYTHON_BIN` một lần và tái sử dụng cho mọi lệnh Python trong `/init` để quy trình làm việc sử dụng trình thông dịch mà `setup.sh` đã chuẩn bị:

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

### Bước 1: Khởi tạo cấu trúc wiki

```bash
"$PYTHON_BIN" tools/research_wiki.py init wiki/
```

Tạo các thư mục wiki tiêu chuẩn, `graph/`, `outputs/`, `index.md` và `log.md`. Không thêm mục nhật ký khởi tạo thứ hai ở đây.

### Bước 2: Chuẩn bị đầu vào cục bộ vào `raw/tmp/`

```bash
"$PYTHON_BIN" tools/init_discovery.py prepare --raw-root raw --pdf-titles-json .checkpoints/init-pdf-titles.json --output-manifest .checkpoints/init-prepare.json
```

- trước khi chạy `prepare`, kiểm tra từng PDF cục bộ và ghi lại chuyển giao khôi phục vào `.checkpoints/init-pdf-titles.json` dưới dạng `{ "raw/papers/foo.pdf": "Tiêu đề bài báo đã khôi phục" }` hoặc `{ "raw/papers/foo.pdf": { "title": "Tiêu đề bài báo đã khôi phục", "arxiv_id": "2401.00001" } }` khi đã biết ID arXiv đáng tin cậy
- sử dụng `"$PYTHON_BIN" tools/prepare_paper_source.py --raw-root raw --source <đường-dẫn-cục-bộ> [--title "<tiêu-đề-đã-khôi-phục>"] [--arxiv-id "<arxiv-id-đã-khôi-phục>"]` để chuẩn hóa bài báo cục bộ
- thứ tự khôi phục PDF cục bộ nghiêm ngặt: ID arXiv chuyển giao hoặc ID arXiv từ tên tệp/đường dẫn -> tiêu đề đã khôi phục bởi tác nhân qua Semantic Scholar -> nguồn arXiv đã lấy -> `.tex` tổng hợp
- khi tác nhân cung cấp tiêu đề PDF, coi tiêu đề đó là có thẩm quyền cho manifest đã chuẩn bị; các tiêu đề từ nguồn/tải về chỉ là siêu dữ liệu dự phòng đã được làm sạch và không được ghi đè lên nó
- không sử dụng siêu dữ liệu PDF hoặc văn bản nội dung làm gợi ý ID arXiv trong quá trình chuẩn bị
- tiêu đề siêu dữ liệu hoặc tên tệp chỉ có thể giữ lại làm nhãn hiển thị tạm thời; chúng không được tin cậy làm đầu vào nhận dạng hoặc tìm kiếm tiêu đề
- giữ nguyên notes/web trên đường dẫn nguồn gốc của chúng; `/init` đọc chúng trực tiếp trong quá trình lập kế hoạch
- đặt `canonical_ingest_path` của mỗi bài báo cục bộ thành đường dẫn `raw/tmp/` đã chuẩn bị khi có sẵn; nếu không, quay lại đường dẫn gốc `raw/papers/...`
- ghi lại cảnh báo cho các lỗi giải mã / khôi phục tiêu đề / lấy nguồn arXiv thay vì hủy bỏ `/init`
- xem `references/prepare-and-discovery.md` cho cây quyết định chuẩn bị và quy tắc ưu tiên nguồn

### Bước 3: Lập kế hoạch khám phá, cắt giảm tập hợp cuối cùng và viết manifest nguồn

```bash
"$PYTHON_BIN" tools/init_discovery.py plan [--topic "<chủ-đề>"] --mode auto --raw-root raw --wiki-root wiki --prepared-manifest .checkpoints/init-prepare.json --allow-introduction <true|false> --output-plan .checkpoints/init-plan.json
```

- `mode=seeded` khi manifest chuẩn bị chứa ít nhất một bài báo cục bộ có thể phân tích cú pháp; nếu không `mode=bootstrap`
- `plan` phải đọc `.checkpoints/init-prepare.json` thay vì quét lại `raw/`
- chính sách planner mang tính định tính ở lớp kỹ năng: ưu tiên mức độ liên quan, tính mới, khả năng kết nối và phạm vi khảo sát
- trong chế độ seeded với khả năng giới thiệu hạn chế, tránh ưu tiên quá mức các bài báo cũ có nhiều trích dẫn
- trong chế độ bootstrap, một bài báo neo kinh điển cũ có thể hữu ích khi nó cải thiện phạm vi
- khi tìm kiếm DeepXiv khả dụng, sử dụng `relevance_score` trả về trong đánh giá công cụ thay vì chỉ ghi chú nó trong văn bản
- trọng số xếp hạng chính xác, hằng số danh sách rút gọn và toán học ngưỡng thuộc về `tools/init_discovery.py`; coi công cụ là cơ quan thực thi và không tái khẳng định hoặc ghi đè các hằng số của nó trong lý luận LLM
- đọc `.checkpoints/init-plan.json` và cắt giảm rõ ràng `shortlist` quá mức thành tổng cộng **8-10** bài báo trước khi `fetch`
- tạo ra một tạo tác lựa chọn cuối cùng rõ ràng trước khi `fetch` với `shortlist_count`, `final_count` và danh sách `candidate_id` cuối cùng chính xác theo thứ tự shortlist
- nếu `final_count` nằm ngoài **8-10**, dừng lại và sửa đổi lựa chọn cuối cùng trước khi `fetch`, trừ khi `--no-introduction` đang hoạt động hoặc người dùng đã cung cấp hơn 10 bài báo có thể phân tích cú pháp
- nếu `--no-introduction` có mặt, chỉ sử dụng nhánh này khi người dùng yêu cầu rõ ràng hành vi chỉ cục bộ; vẫn chạy `fetch` với ID bên ngoài bằng không để nó viết `.checkpoints/init-sources.json`
- xem `references/planner-policy.md` cho hành vi planner, kỳ vọng cắt giảm và ranh giới nguồn sự thật

Sau đó chạy:

```bash
"$PYTHON_BIN" tools/init_discovery.py fetch --raw-root raw --plan-json .checkpoints/init-plan.json --prepared-manifest .checkpoints/init-prepare.json --output-sources .checkpoints/init-sources.json --id <candidate-id> --id <candidate-id>
```

- các bài báo bên ngoài được tải xuống bởi `/init` đi vào `raw/discovered/`, không bao giờ `raw/papers/`
- không bao giờ tải xuống một bài báo đã được đại diện bởi nguồn cục bộ đã chuẩn bị từ `raw/tmp/`
- `.checkpoints/init-sources.json` là nguồn sự thật duy nhất cho thứ tự ingest hạ nguồn

### Bước 4: Tạo các trang khung trước khi ingest bài báo

Tạo một `wiki/Summary/{area}.md`, các `wiki/topics/{slug}.md` cần thiết và các `ideas/`, `concepts/` và `claims/` tạm thời từ notes/web khi được bảo đảm.

Quy tắc:

- notes/web có thẩm quyền về ý định của người dùng, không phải về độ tin cậy của tài liệu
- mọi trang có nguồn gốc từ notes/web phải bao gồm dòng chính xác này ngay sau frontmatter:

```markdown
Ghi chú tạm thời: được khởi tạo từ raw/notes hoặc raw/web trong quá trình /init; chờ xác thực từ các bài báo đã ingest.
```

- `topics/`: tạo khi một hướng được nêu rõ hoặc lặp lại
- `ideas/`: tạo khi người dùng nêu hoặc ngụ ý mạnh mẽ một hướng hoặc giả thuyết nghiên cứu
- `concepts/`: chỉ tạo khi cơ chế xuất hiện nhiều lần trong notes/web, hoặc xuất hiện một lần trong notes/web và một lần trong tập hợp bài báo cuối cùng
- `claims/`: chỉ tạo từ các phát biểu khẳng định rõ ràng, không bao giờ bằng suy luận
- đối với các khẳng định có nguồn gốc từ notes/web, sử dụng `status: proposed`, `confidence: 0.2`, `source_papers: []` và `evidence: []`
- `/prefill` là seeding nền tảng tùy chọn và không phải là một phần của `/init`
- `/init` không được trực tiếp tạo các trang `people/` và không được tự động tạo foundations

### Bước 5: Ingest bài báo song song với cô lập worktree

Nguồn bài báo cho bước này đến nghiêm ngặt từ `.checkpoints/init-sources.json`:

- `origin=user_local`: `.tex` đã chuẩn bị chính tắc dưới `raw/tmp/` khi có sẵn, nếu không quay lại `raw/papers/...`
- `origin=introduced`: các thư mục hoặc PDF đã lấy dưới `raw/discovered/`

Hợp đồng ingest song song:

- lưu trữ các tệp bẩn không liên quan trước khi fan-out, sau đó ghi lại `stash_ref`, `base_branch` và `base_commit` trong siêu dữ liệu checkpoint
- commit khung và các manifest init mới tạo trước khi fan-out để `BASE_COMMIT` thực sự chứa các trang, manifest và siêu dữ liệu chuyển giao mà các tiểu tác nhân phải phân nhánh từ
- thực hiện commit scaffold và xác minh `git ls-tree` trong một lượt assistant riêng; chỉ launch Agent fan-out ở lượt kế tiếp để tránh worktree chụp `HEAD` cũ
- xác minh `.gitattributes` chứa `merge=union` cho `wiki/log.md`, `wiki/graph/edges.jsonl` và `wiki/index.md` trước khi tạo worktree
- chế độ worktree `/init` phải chạy từ một nhánh có tên, không phải HEAD tách rời
- tạo mỗi worktree từ `BASE_COMMIT`, không phải từ `BASE_BRANCH` đã checkout
- các lời nhắc tiểu tác nhân phải sử dụng **chỉ đường dẫn tương đối**
- thực thi `/ingest` cho chính xác một đường dẫn nguồn đã chuyển giao; không bỏ qua `/ingest`
- trong CHẾ ĐỘ INIT, sử dụng đường dẫn chính tắc đã chuyển giao chính xác như được cung cấp
- bỏ qua `fetch_s2.py citations`
- bỏ qua `fetch_s2.py references`
- bỏ qua `rebuild-index` cho mỗi tiểu tác nhân
- bỏ qua `rebuild-context-brief` cho mỗi tiểu tác nhân
- bỏ qua `rebuild-open-questions` cho mỗi tiểu tác nhân
- bỏ qua các ghi chủ đề dễ gây xung đột
- commit kết quả ingest bên trong worktree trước khi thoát để fan-in hợp nhất một commit cụ thể cho bài báo thay vì một nhánh trống
- xem `references/parallel-ingest.md` cho các lệnh worktree, thứ tự hợp nhất, fan-in và dọn dẹp

### Bước 6: Fan-in, xây dựng lại và báo cáo cuối cùng

Sau khi tất cả các tiểu tác nhân hoàn thành:

- hợp nhất các nhánh worktree tuần tự trên `BASE_BRANCH`
- giải quyết các xung đột khái niệm / khẳng định một cách thận trọng: hợp nhất, không nhân bản các bản sao gần trùng lặp
- chạy:

```bash
"$PYTHON_BIN" tools/research_wiki.py dedup-edges wiki/
"$PYTHON_BIN" tools/research_wiki.py rebuild-index wiki/
"$PYTHON_BIN" tools/research_wiki.py rebuild-context-brief wiki/
"$PYTHON_BIN" tools/research_wiki.py rebuild-open-questions wiki/
"$PYTHON_BIN" tools/lint.py --wiki-dir wiki/ --fix
```

Báo cáo riêng biệt:

- các bài báo do người dùng cung cấp được ingest thông qua các đường dẫn `raw/tmp/` đã chuẩn bị
- các bài báo do người dùng cung cấp quay lại đường dẫn gốc `raw/papers/`
- các bài báo đã khám phá từ `raw/discovered/`
- các trang tạm thời được khởi tạo từ notes/web
- các trang được tạo bởi `/ingest`
- các trang được cập nhật bởi `/ingest`
- bất kỳ bài báo nào bị bỏ qua hoặc thất bại

Nếu `stash_ref` tồn tại, khôi phục nó ở cuối. Nếu khôi phục stash thất bại, giữ checkpoint và báo cáo lỗi.

## Các Ràng Buộc

- `raw/papers/`, `raw/notes/` và `raw/web/` là đầu vào thuộc sở hữu người dùng
- `raw/tmp/` và `raw/discovered/` là khu vực chuyển giao được tạo; `/ingest` cục bộ trực tiếp cũng có thể chuẩn bị các tệp tạm thời cục bộ có thể tái sử dụng dưới `raw/tmp/`
- `/init` chỉ có thể ghi các bài báo bên ngoài vào `raw/discovered/`; `/init` và `/ingest` cục bộ trực tiếp có thể ghi các nguồn cục bộ đã chuẩn bị được tạo vào `raw/tmp/`
- `/prefill` là seeding nền tảng tùy chọn, không phải là một phần của `/init`
- không kỹ năng nào khác ngoài `/prefill` có thể tự động tạo foundations
- `/init` không được trực tiếp tạo các trang `people/`
- các trang có nguồn gốc từ notes/web là tạm thời và phải mang dòng thông báo chính xác ở trên
- bằng chứng bài báo vượt trội hơn notes/web về độ tin cậy của khẳng định và hợp nhất khái niệm
- tất cả ingest bài báo phải chạy thông qua các tiểu tác nhân `/ingest` song song với cô lập worktree
- Bước 5 phải đọc đầu vào bài báo từ `.checkpoints/init-sources.json`, không phải bằng cách quét thư mục đặc biệt
- chính sách planner xác định chính xác thuộc về `tools/init_discovery.py`, không phải trong các hằng số kỹ năng trùng lặp

## Xử Lý Lỗi

- **Không có bài báo nào có thể phân tích cú pháp trong `raw/papers/`**: vào chế độ bootstrap
- **`raw/notes/` và `raw/web/` trống**: bỏ qua seeding tạm thời, tiếp tục
- **Thất bại giải mã PDF trong quá trình chuẩn bị**: giữ lại nguồn cục bộ, ghi lại cảnh báo trong `.checkpoints/init-prepare.json` và quay lại đường dẫn gốc nếu cần
- **Không khôi phục được tiêu đề PDF đáng tin cậy**: bỏ qua `--title`, chỉ cho phép khôi phục ID arXiv từ tên tệp/đường dẫn, sau đó quay lại trực tiếp `.tex` tổng hợp; bất kỳ tiêu đề từ siêu dữ liệu hoặc tên tệp chỉ là hiển thị
- **Phát hiện nội dung tiếng Trung trong `raw/notes/` hoặc `raw/web/`**: tiếp tục, nhưng giữ lại cảnh báo planner rằng trích xuất và xếp hạng notes/web có thể kém tin cậy hơn và coi xếp hạng cộng với các trang tạm thời là độ tin cậy thấp hơn
- **S2 hoặc DeepXiv không khả dụng**: planner quay lại các nguồn còn lại; giữ lại cảnh báo trong kế hoạch đã checkpoint và ghi chú khám phá suy giảm trong báo cáo
- **Lấy bên ngoài thất bại cho một bài báo**: giữ lại tập hợp cuối cùng còn lại và báo cáo tải xuống thất bại
- **Ingest một bài báo thất bại**: ghi lại nó qua checkpoint, bỏ qua nó, tiếp tục các bài còn lại và liệt kê nó trong báo cáo
- **Checkout hiện tại là HEAD tách rời**: dừng lại trước khi fan-out worktree và yêu cầu người dùng chuyển sang hoặc tạo một nhánh có tên trước
- **Khôi phục stash thất bại**: giữ lại siêu dữ liệu checkpoint và báo cáo bước khôi phục thủ công

## Phụ Thuộc

### Công cụ (qua Bash)

- `"$PYTHON_BIN" tools/research_wiki.py init wiki/`
- `"$PYTHON_BIN" tools/research_wiki.py checkpoint-set-meta wiki/ init-session <khóa> <giá-trị>`
- `"$PYTHON_BIN" tools/research_wiki.py checkpoint-save/load/clear wiki/ init-session ...`
- `"$PYTHON_BIN" tools/research_wiki.py dedup-edges wiki/`
- `"$PYTHON_BIN" tools/research_wiki.py rebuild-index wiki/`
- `"$PYTHON_BIN" tools/research_wiki.py rebuild-context-brief wiki/`
- `"$PYTHON_BIN" tools/research_wiki.py rebuild-open-questions wiki/`
- `"$PYTHON_BIN" tools/research_wiki.py log wiki/ "<thông-điệp>"`
- `"$PYTHON_BIN" tools/prepare_paper_source.py --raw-root raw --source <đường-dẫn-cục-bộ> [--title "<tiêu-đề-đã-khôi-phục>"]`
- `"$PYTHON_BIN" tools/init_discovery.py prepare --raw-root raw --pdf-titles-json .checkpoints/init-pdf-titles.json --output-manifest .checkpoints/init-prepare.json`
- `"$PYTHON_BIN" tools/init_discovery.py plan [--topic "<chủ-đề>"] --mode auto --raw-root raw --wiki-root wiki --prepared-manifest .checkpoints/init-prepare.json --allow-introduction <true|false> --output-plan .checkpoints/init-plan.json`
- `"$PYTHON_BIN" tools/init_discovery.py fetch --raw-root raw --plan-json .checkpoints/init-plan.json --prepared-manifest .checkpoints/init-prepare.json --output-sources .checkpoints/init-sources.json --id <candidate-id>`
- `"$PYTHON_BIN" tools/lint.py --wiki-dir wiki/ --fix`

### Kỹ Năng

- `/ingest` — một bài báo cho mỗi tiểu tác nhân, trong CHẾ ĐỘ INIT

### API Ngoại Vi được sử dụng bởi `init_discovery.py`

- Semantic Scholar
- DeepXiv (tùy chọn)
- các điểm cuối tải xuống arXiv