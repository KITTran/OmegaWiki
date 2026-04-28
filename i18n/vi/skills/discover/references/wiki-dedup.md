# /discover khử trùng lặp wiki

`tools/discover.py` khử trùng lặp các ứng viên so với wiki hiện có khi truyền `--wiki-root wiki`. Tài liệu này giải thích dedup phát hiện và không phát hiện những gì, để báo cáo hướng tới người dùng được chính xác.

## Những gì nó phát hiện

Với mỗi ứng viên, `tools/discover.py` trích xuất `arxiv_id` từ bản ghi ứng viên (S2's `externalIds.ArXiv`, DeepXiv's `arxiv_id`, v.v.) và kiểm tra xem có trang `wiki/papers/*.md` hiện có nào có `arxiv` (hoặc `arxiv_id` legacy) khớp trong frontmatter của nó hay không. Các mục khớp bị loại khỏi shortlist trước khi chấm điểm; số lượng được báo cáo là `wiki_dedup_count`.

Điều này bắt được trường hợp điển hình: một bài báo đã được ingest lại nổi lên thành khuyến nghị. Hiển thị bài báo như vậy sẽ lãng phí sự chú ý rà soát của người dùng; loại bỏ nó là đúng.

## Những gì nó không phát hiện

- **Khớp chỉ theo tiêu đề**: một bài báo trong wiki không có `arxiv` hoặc `arxiv_id` (ví dụ: một bài báo tạp chí được ingest qua `/edit`) sẽ không khớp với một ứng viên chỉ bằng tiêu đề. Đây là chủ ý — khớp tiêu đề mờ tạo ra false positive che khuất các ứng viên hợp lệ.
- **Lệch phiên bản arXiv**: `2106.09685` và `2106.09685v3` đều nên được coi là cùng một bài báo. Bộ quét frontmatter loại bỏ các tiền tố `arxiv:`/`ARXIV:` nhưng hiện chưa loại bỏ hậu tố `vN`. Nếu bạn thấy các bản trùng lặp lọt qua, hãy chuẩn hóa hậu tố phiên bản trong `arxiv_id` của ứng viên trước khi so sánh.
- **Trùng lặp giữa các nguồn trong tập ứng viên**: lượt khử trùng lặp trước khi lọc theo wiki dùng `_candidate_key` (arxiv → S2 paperId → title-slug), bắt được hầu hết các bản trùng lặp giữa các nguồn từ S2 và DeepXiv. Các mục thiếu hoàn toàn ID và tiêu đề bị loại âm thầm.

## Cần làm gì với báo cáo "high dedup"

Nếu `wiki_dedup_count` cao so với `candidates_total` (ví dụ: 30 / 50), wiki đã bao phủ khá tốt các anchor này. Có hai cách diễn giải:

1. Người dùng đang tìm độ phủ rộng và nên chuyển sang seed khác (anchor khác, chủ đề rộng hơn, hoặc `--from-wiki` để khám phá các bài báo lân cận).
2. Kênh khuyến nghị thực sự đã bão hòa — có rất ít nội dung mới để khuyến nghị trong vùng lân cận này.

Kỹ năng nên đề cập high dedup trong báo cáo hướng tới người dùng; không được che giấu nó.

## Những gì dedup không làm

`/discover` không bao giờ sửa đổi wiki để "sửa" một bản trùng lặp. Nếu metadata của ứng viên có vẻ phong phú hơn những gì hiện có trong wiki, đó là mối quan tâm của `/edit` hoặc `/check`, không phải mối quan tâm của `/discover`.
