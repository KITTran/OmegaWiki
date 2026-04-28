# Tín hiệu xếp hạng của /discover

Cơ chế xếp hạng tất định nằm trong `tools/discover.py` — tệp này ghi lại những gì cơ chế đó cân nhắc và **vì sao nó khác với `/init`**, để các chỉnh sửa trong tương lai không vô tình làm hai cơ chế này hội tụ trở lại.

## Các kênh ứng viên ở anchor mode

Anchor mode thu thập từ **ba** kênh S2 cho mỗi anchor, vì bất kỳ kênh đơn lẻ nào cũng có một thiên lệch đặc trưng:

- **`recommend`** (endpoint khuyến nghị ngữ nghĩa của S2) — đưa lên các bài báo tương tự về mặt ngữ nghĩa, nhưng endpoint này lệch rất mạnh về các công trình gần đây. Nếu đứng một mình, nó sẽ co lại thành "các bài báo gần đây gần chủ đề", chồng lấn với `/daily-arxiv`.
- **`references`** (các bài báo mà anchor trích dẫn) — đưa lên các công trình **canonical cũ hơn** mà anchor đã xây dựng dựa trên đó. Đây là kênh literature-review.
- **`citations`** (các bài báo trích dẫn anchor) — đưa lên các **follow-up có tác động cao** và công trình về sau được xây dựng trên anchor.

Cùng nhau, chúng tạo thành một bước đi thực sự trên literature graph: láng giềng ngữ nghĩa + tổ tiên + hậu duệ. Loại bỏ bất kỳ kênh nào cũng là một suy giảm chất lượng rõ rệt. Chỉ dùng `--no-citation-expand` để bỏ references+citations khi chi phí API là ràng buộc chi phối (ví dụ: một danh sách anchor rất ngắn, nơi chỉ riêng recommend đã đủ).

## Discovery chấm điểm trên những gì

Anchor mode (thứ tự trọng số xấp xỉ):

1. **Số lượng trích dẫn có ảnh hưởng tổng hợp** — được log-scale. Phản ánh uy tín chung của ứng viên. Được gán trọng số nặng hơn `citationCount` thô.
2. **Cạnh ảnh hưởng theo anchor** — cờ `isInfluential` theo từng cạnh của S2, được nâng từ envelope `references`/`citations` lên từng ứng viên dưới dạng `is_influential_edge`. Khi là True, mô hình phân tích trích dẫn của S2 đã đánh giá rằng anchor xây dựng một cách thực chất trên ứng viên này (kênh references) hoặc ứng viên này xây dựng một cách thực chất trên anchor (kênh citations). Sắc nét hơn nhiều so với số lượng tổng hợp: nó cho biết "cái này quan trọng cụ thể đối với anchor", không phải "cái này quan trọng đối với lĩnh vực". Thường là False — cờ của S2 rất nghiêm ngặt — nhưng khi là True thì nó nên chi phối.
3. **Độ chồng lấn anchor** — có bao nhiêu anchor đưa ứng viên này lên. Hai anchor cùng trỏ đến một bài báo nghĩa là bài đó nằm ở giao điểm của chúng.
4. **Đa dạng kênh** — thưởng khi cùng một ứng viên xuất hiện trong nhiều kênh (ví dụ: cả `recommend` và `references`). Một bài báo có mặt trong cả ba kênh là hiếm và thường có tính trung tâm đối với vùng lân cận của anchor.
5. **Độ mới** — thưởng nhẹ cho các năm gần đây. Gần đây ≠ tốt hơn, nên đường cong khá phẳng (1.0 / 0.85 / 0.6 / 0.4 / 0.25 theo các nhóm tuổi).
6. **Author h-index** (tối đa trên các tác giả) — tie-breaker có giới hạn trần. Các list endpoint không trả về `authors.hIndex`, nên tín hiệu này chủ yếu kích hoạt cho các ứng viên topic-mode đến từ single-paper graph API giàu thông tin hơn.

Topic / wiki mode: cùng các tín hiệu, trừ độ chồng lấn anchor và trừ cạnh ảnh hưởng theo anchor (không có anchor trong topic mode; các anchor suy ra từ wiki vẫn chấm tín hiệu cạnh). Ảnh hưởng và độ mới mang trọng số lớn hơn để bù lại.

### Vì sao cần cả ảnh hưởng tổng hợp VÀ ảnh hưởng theo từng cạnh?

Chúng trả lời các câu hỏi khác nhau:

- `influentialCitationCount` = "lĩnh vực có trích dẫn bài báo này một cách thực chất không?" — một proxy cho tầm quan trọng chung
- `isInfluential` trên cạnh anchor = "*anchor này* có xây dựng cụ thể trên / được bài báo này xây dựng trên không?" — một proxy cho mức độ liên quan riêng theo anchor

Một bài báo có thể đạt điểm cao ở một tín hiệu và thấp ở tín hiệu kia. Ví dụ: một bài báo benchmark nổi tiếng có số lượng tổng hợp cao (ai cũng trích dẫn nó) nhưng hiếm khi có cạnh True từ một bài báo phương pháp (benchmark được sử dụng, không phải được xây dựng dựa trên). Xếp hạng của chúng ta dùng cả hai, vì vậy benchmark được đưa lên khi không có tín hiệu tốt hơn, nhưng các bài báo mà anchor thực sự đã xây dựng dựa trên sẽ xếp trên chúng.

## Discovery **không** chấm điểm trên những gì

Đây là nơi `/discover` cố ý khác với planner của `/init` (`tools/init_discovery.py`):

- **Không ưu tiên survey**. `/init` ưu tiên các bài survey/review vì một wiki mới hưởng lợi từ chúng như vùng phủ anchor. `/discover` được gọi khi người dùng đã biết lĩnh vực (anchor mode) hoặc đang khám phá (topic mode); họ hiếm khi cần thêm một survey nữa, và việc đưa survey lên trên công trình mới sẽ là nhiễu.
- **Không có bonus "older canonical anchor"**. Bootstrap mode của `/init` đẩy một bài báo cũ hơn, nhiều trích dẫn lên để mở rộng vùng phủ. Người dùng `/discover` thường muốn khuyến nghị hướng tới tương lai, không phải tái neo vào nền tảng.
- **Không có hạng ưu tiên notes/web**. `/init` đọc `raw/notes/` và `raw/web/` để trích xuất ý định đã nêu của người dùng. `/discover` thì không — đầu vào của nó là tường minh (anchor, topic, hoặc trạng thái wiki).

Nếu một tín hiệu xếp hạng trong tương lai có vẻ được chia sẻ giữa `/init` và `/discover`, hãy ưu tiên giữ hai implementation thay vì trích xuất một scorer dùng chung. Các mục tiêu thực sự khác nhau; một scorer dùng chung sẽ buộc một kỹ năng phải thỏa hiệp.

## Ràng buộc field-set trên các endpoint S2

`tools/fetch_s2.py` dùng hai field set:

- `FIELDS` — tập đầy đủ giàu thông tin. Được `/paper/{id}` **và** `/paper/search` chấp nhận. Bao gồm `authors.hIndex`, `tldr`, và mọi nested selector khác mà chúng ta dùng.
- `FLAT_FIELDS` — tác giả dạng phẳng, không `tldr`, không nested selector. Bắt buộc với `/paper/{id}/citations`, `/paper/{id}/references`, và `/recommendations/*` — ba endpoint này trả về 400 Bad Request khi được truyền nested selector hoặc `tldr`.

Đừng gộp lại hai tập này: các endpoint bị hạn chế thực sự từ chối dạng lồng nhau, đã được xác minh bằng live probes.

Hệ quả thực tế cho anchor mode: các ứng viên chỉ đi vào qua `references` / `citations` / `recommend` thiếu `hIndex` và `tldr` trong rationale của chúng. Ứng viên topic mode (đi vào qua `/paper/search`) mang cả hai. Một lệnh gọi `fetch_s2.paper(arxiv_id)` tiếp sau cho mỗi ứng viên sẽ làm giàu các mục còn thiếu, nhưng công cụ discovery cố ý không làm điều này — nó sẽ nhân chi phí mỗi lần chạy lên theo (shortlist_size × latency) để đổi lấy một cải thiện rationale nhỏ. `/ingest` thực hiện việc làm giàu khi người dùng thực sự chọn một ứng viên để ingest.
