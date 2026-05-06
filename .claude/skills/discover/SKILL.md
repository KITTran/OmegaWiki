---
description: Xây dựng danh sách rút gọn có xếp hạng các bài báo ứng viên (dựa trên neo, dựa trên chủ đề, hoặc phái sinh từ trạng thái wiki hiện tại) mà người dùng — hoặc một kỹ năng thượng nguồn — có thể quyết định đưa vào `/ingest`. Sử dụng bất cứ khi nào người dùng hỏi "tôi nên đọc gì tiếp theo", "tìm các bài báo tương tự như bài này", "đề xuất công trình liên quan", "có gì xung quanh chủ đề này", hoặc bất cứ khi nào `/ingest` được gọi với `--discover`. Không ingest; chỉ đề xuất.
argument-hint: "(--anchor <id> [--anchor <id>] [--negative <id>] | --topic <str> | --from-wiki) [--limit N]"
---

# /discover

> Tạo danh sách rút gọn có xếp hạng các bài báo ứng viên từ một trong ba chế độ seed. Hiển thị chúng cho người dùng (hoặc cho kỹ năng gọi) với lý do. Không bao giờ tự động ingest — `/discover` là giai đoạn đề xuất, `/ingest` là giai đoạn hành động.

Sử dụng các tài liệu tham khảo cục bộ này theo yêu cầu:

- `references/seed-modes.md` — khi nào chọn chế độ anchor / topic / wiki và cách dịch cách diễn đạt của người dùng thành một trong số đó
- `references/ranking-signals.md` — `tools/discover.py` chấm điểm dựa trên gì và tại sao discovery **không** chia sẻ sở thích khảo sát của `/init`
- `references/wiki-dedup.md` — cách các ứng viên được lọc so với `wiki/papers/` và phải làm gì với các kết quả trùng khớp

## Đầu vào

- `--anchor <id>` (có thể lặp lại): một hoặc nhiều ID bài báo neo (ưu tiên arXiv ID; cũng chấp nhận S2 paperIds). Điều khiển **chế độ anchor** — trường hợp sử dụng chính, bao gồm luồng "đọc gì tiếp theo" sau `/ingest`.
- `--negative <id>` (có thể lặp lại, tùy chọn): các ID để đẩy đề xuất ra xa. Chỉ có ý nghĩa với `--anchor`.
- `--topic "<str>"`: một chuỗi chủ đề / truy vấn. Điều khiển **chế độ topic** — thay thế nhẹ hơn cho planner của `/init`.
- `--from-wiki`: tự động phái sinh seeds từ các bài báo được sửa đổi gần đây nhất của wiki. Điều khiển **chế độ wiki**.
- `--limit N` (tùy chọn, mặc định 10): kích thước danh sách rút gọn tối đa.

Chính xác một trong `--anchor`, `--topic`, `--from-wiki` phải được cung cấp.

## Đầu ra

- `.checkpoints/discover-{seed-slug}-{YYYY-MM-DD}.json` — payload danh sách rút gọn đầy đủ, có thể đọc được bằng máy; seed slug được phái sinh từ anchor đầu tiên hoặc chủ đề
- một bản tóm tắt markdown có thể đọc được bởi con người được in cho người dùng với lý do cho mỗi ứng viên
- `wiki/log.md` — một dòng thêm vào thông qua `tools/research_wiki.py log`

`/discover` không ghi vào bất kỳ nơi nào khác trong `wiki/` và không chạm vào `raw/`. Việc có thực sự kéo một ứng viên vào wiki hay không là quyết định của người gọi (một `/ingest` tiếp theo).

## Tương tác Wiki

### Đọc

- `wiki/papers/*.md` — frontmatter `arxiv` (hoặc `arxiv_id` cũ) để dedup so với các bài báo đã được ingest
- `wiki/papers/*.md` thời gian sửa đổi — cho việc chọn anchor `--from-wiki`

### Ghi

- `wiki/log.md` — THÊM VÀO thông qua `tools/research_wiki.py log`

### Các cạnh đồ thị được tạo

- không có. Các thay đổi đồ thị thuộc về `/ingest`, không phải `/discover`.

## Quy trình làm việc

**Điều kiện tiên quyết**: thư mục làm việc chứa `wiki/`, `raw/`, và `tools/`. Xác định trình thông dịch Python một lần và sử dụng lại:

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

### Bước 1: Chọn chế độ seed

Dịch yêu cầu của người dùng thành chính xác một trong `from-anchors`, `from-topic`, hoặc `from-wiki`. Quy tắc quyết định nằm trong `references/seed-modes.md`; phiên bản ngắn:

- người dùng đặt tên một hoặc nhiều bài báo cụ thể, hoặc đây là một follow-up `--discover` sau `/ingest` → **anchors**
- người dùng đưa ra một chủ đề / hướng / từ khóa → **topic**
- người dùng hỏi mở "tôi nên đọc gì tiếp theo" không có anchor và không có chủ đề → **wiki**

Nếu người dùng cung cấp negatives ("không phải những cái này"), bao gồm chúng thông qua `--negative` chỉ trong chế độ anchor.

### Bước 2: Chạy công cụ discovery

```bash
"$PYTHON_BIN" tools/discover.py from-anchors \
  --id <arxiv-id> [--id <arxiv-id>...] [--negative <id>...] \
  --wiki-root wiki \
  --limit 10 \
  --output-checkpoint .checkpoints/ \
  --markdown
```

Hoặc cho các chế độ topic / wiki:

```bash
"$PYTHON_BIN" tools/discover.py from-topic "<query>" --wiki-root wiki --limit 10 --output-checkpoint .checkpoints/ --markdown
"$PYTHON_BIN" tools/discover.py from-wiki --wiki-root wiki --limit 10 --output-checkpoint .checkpoints/ --markdown
```

Chế độ anchor (và wiki) chạy ba kênh S2 cho mỗi anchor theo mặc định — `recommend` + `references` + `citations`. Đây là điều làm cho `/discover` khác biệt có ý nghĩa so với `/daily-arxiv`: references hiển thị công trình chính tắc cũ hơn mà anchor được xây dựng dựa trên, citations hiển thị các follow-up có tác động cao. Chỉ truyền `--no-citation-expand` nếu chi phí API buộc phải đi theo con đường recommend-only hẹp hơn; sự suy giảm chất lượng là rõ rệt.

Công cụ xử lý thu thập ứng viên, dedup wiki, xếp hạng, và ghi checkpoint. Luôn truyền `--wiki-root wiki` để các bài báo đã được ingest được lọc ra — hiển thị các bản sao trùng lặp lãng phí thời gian xem xét của người dùng.

Nếu S2 không khả dụng trong chế độ topic, công cụ sẽ tiếp tục với bất kỳ nguồn nào đã phản hồi; kiểm tra đầu ra và báo cáo discovery bị suy giảm cho người dùng. Nếu mọi kênh đều thất bại, hủy bỏ với một thông báo rõ ràng thay vì phát ra một danh sách rút gọn trống như thể đó là một đề xuất thực sự.

### Bước 3: Trình bày danh sách rút gọn

Hiển thị đầu ra markdown cho người dùng. Đối với mỗi ứng viên, người dùng cần đủ để quyết định có nên ingest hay không:

- tiêu đề và arXiv ID (hoặc S2 paperId dự phòng)
- lý do một dòng (đã được tạo bởi công cụ: số lượng anchor, trích dẫn có ảnh hưởng, năm)
- TLDR nếu công cụ hiển thị một cái (các ứng viên chế độ topic thường có nó; chế độ anchor thường không có — endpoint recommendations không trả về TLDRs)

Thêm một gợi ý "bước tiếp theo" ngắn:

```
Để ingest một ứng viên: /ingest https://arxiv.org/abs/<arxiv-id>
```

Không tự ingest bất cứ thứ gì. Người dùng chọn.

### Bước 4: Ghi log

```bash
"$PYTHON_BIN" tools/research_wiki.py log wiki "discover | mode=<anchors|topic|wiki> | seed=<short-desc> | shortlist=<N>"
```

## Người gọi nội bộ

`/discover` được thiết kế để được gọi bởi cả người dùng (thủ công) và các kỹ năng khác (như một chương trình con).

### Từ `/ingest --discover`

Khi `/ingest` được gọi với cờ tùy chọn `--discover` (mặc định tắt), nó gọi `/discover` sau báo cáo cuối cùng, với arXiv ID của bài báo vừa được ingest làm anchor duy nhất. Danh sách rút gọn được thêm vào báo cáo của `/ingest` dưới tiêu đề "Các bài báo liên quan bạn có thể muốn ingest tiếp theo". `/ingest` không bao giờ tự động ingest bất cứ thứ gì từ danh sách này.

### Từ `/init`

`/init` không gọi `/discover`. Planner của `/init` (`tools/init_discovery.py plan`) có chấm điểm riêng ưu tiên các khảo sát, phạm vi rộng, và các anchor seed — phù hợp để khởi động một wiki. Xếp hạng của `/discover` cố ý khác (không có sở thích khảo sát; trọng số tương đồng anchor và trích dẫn có ảnh hưởng) và sẽ làm loãng danh sách rút gọn của `/init` nếu được thay thế vào. Giữ chúng riêng biệt.

## Ràng buộc

- **Không bao giờ tự động ingest**: `/discover` trả về một danh sách rút gọn và dừng lại. Ngay cả khi được gọi bởi `/ingest --discover`, người gọi hiển thị kết quả và người dùng quyết định ingest gì.
- **Không ghi vào `wiki/` ngoài `log.md`**: các trang bài báo, khái niệm, khẳng định, cạnh đồ thị đều thuộc về `/ingest`.
- **Không ghi vào `raw/`**: `/discover` không tải xuống bài báo. Người dùng chạy `/ingest <arxiv-url>` sau đó nếu họ muốn một ứng viên.
- **Luôn dedup so với wiki**: truyền `--wiki-root wiki` để danh sách rút gọn chỉ chứa các bài báo chưa có trong wiki. Hiển thị các bản sao trùng lặp là chế độ thất bại chất lượng thấp phổ biến nhất.
- **Xếp hạng là đặc thù cho discovery**: không import hoặc sao chép các helper chấm điểm của `tools/init_discovery.py`. Hai kỹ năng có các mục tiêu khác nhau — `/init` muốn phạm vi nền tảng rộng; `/discover` muốn *các bài đọc tiếp theo* có liên quan. Xem `references/ranking-signals.md`.
- **Thu thập anchor ba kênh**: theo mặc định, chế độ anchor kéo từ S2 `recommend` + `references` + `citations` cho mỗi anchor. Loại bỏ các kênh citation (thông qua `--no-citation-expand`) làm sụp đổ kết quả thành một cụm ngữ nghĩa thiên về gần đây chồng chéo nhiều với `/daily-arxiv`. Giữ cả ba trừ khi chi phí API là một ràng buộc cứng. Xem `references/ranking-signals.md`.
- **Một số endpoint S2 có tập trường phẳng hơn**: `/citations`, `/references`, và `/recommendations/*` từ chối các selector lồng nhau — không có `authors.hIndex`, không có `tldr`. `/paper/{id}` và `/paper/search` chấp nhận chúng, vì vậy các ứng viên chế độ topic mang làm giàu đầy đủ; các ứng viên chế độ anchor chỉ nhập qua citations/references/recommend thì không. Đó là một ràng buộc API thực sự, không phải lỗi.
- **Giới hạn tốc độ áp dụng**: mỗi anchor trong chế độ anchor tốn tới ba lần gọi S2 (recommend + references + citations). Giới hạn mặc định cho mỗi anchor là 50 cho recs và 30 cho mỗi references/citations. Các lần chạy nhiều anchor nhân lên tương ứng; với một API key (1 req/sec) một lần chạy 3-anchor mất ~10 giây.

## Xử lý lỗi

- **Tất cả các kênh seed thất bại**: báo cáo thất bại, không ghi danh sách rút gọn, và không ghi log một lần chạy thành công.
- **S2 không khả dụng, DeepXiv khả dụng (chế độ topic)**: tiếp tục chỉ với DeepXiv; lưu ý sự suy giảm trong báo cáo.
- **S2 trả về không có đề xuất cho một anchor**: tiếp tục với các anchor còn lại; nếu tất cả các anchor trả về không, coi như thất bại hoàn toàn.
- **`--from-wiki` không tìm thấy bài báo có thể neo** (`wiki/papers/` trống hoặc tất cả thiếu `arxiv_id`): nói với người dùng wiki quá thưa thớt cho discovery chế độ wiki và đề xuất chế độ topic.
- **Anchor ID bị sai định dạng hoặc không xác định**: S2 sẽ trả về 404; hiển thị ID xấu trong báo cáo và tiếp tục với bất kỳ anchor còn lại nào.

## Phụ thuộc

### Công cụ (thông qua Bash)

- `"$PYTHON_BIN" tools/discover.py from-anchors --id <id> [--id <id>...] [--negative <id>...] --wiki-root wiki --limit <N> --output-checkpoint .checkpoints/ --markdown`
- `"$PYTHON_BIN" tools/discover.py from-topic "<query>" --wiki-root wiki --limit <N> --output-checkpoint .checkpoints/ --markdown`
- `"$PYTHON_BIN" tools/discover.py from-wiki --wiki-root wiki --limit <N> --output-checkpoint .checkpoints/ --markdown`
- `"$PYTHON_BIN" tools/research_wiki.py log wiki "<message>"`

### Kỹ năng

- `/ingest` — người gọi thông qua cờ `--discover`; cũng là hành động mà người dùng thực hiện trên một ứng viên được chọn
- `/init` — planner độc lập; không gọi `/discover`

### API bên ngoài

- Semantic Scholar — recommendations (`/recommendations/v1/papers/forpaper/{id}`, `POST /recommendations/v1/papers/`), search, paper detail (thông qua `tools/fetch_s2.py`)
- DeepXiv — dự phòng tìm kiếm trong chế độ topic (thông qua `tools/fetch_deepxiv.py`, tùy chọn; dự phòng graceful khi không khả dụng)
