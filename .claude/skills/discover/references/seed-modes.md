# Các chế độ seed của /discover

Chọn đúng một chế độ cho mỗi lần gọi. Quyết định dựa trên những gì người dùng (hoặc kỹ năng gọi) thực sự đã nói, không dựa trên nội dung wiki đang có.

## Chế độ anchor (`from-anchors`)

Sử dụng khi người dùng nêu tên một hoặc nhiều bài báo cụ thể, hoặc khi đây là bước tiếp nối `--discover` sau `/ingest`.

Kích hoạt:

- "find papers similar to LoRA"
- "what's related to this one I just ingested"
- một hoặc nhiều URL / ID arXiv / slug bài báo wiki trong yêu cầu
- lần gọi `/ingest --discover` (anchor = arXiv ID của bài báo vừa được ingest)

Chế độ anchor là kênh tín hiệu mạnh nhất — endpoint recommendations của Semantic Scholar trả về các bài báo tương tự về mặt ngữ nghĩa dựa trên mô hình đã huấn luyện của nó, hữu ích hơn tìm kiếm từ khóa khi người dùng có một điểm tham chiếu cụ thể.

Nếu người dùng cung cấp các phủ định ("not these", "different from X"), hãy truyền chúng qua `--negative`. Endpoint recommendations của S2 đẩy phân phối kết quả ra xa các anchor âm, điều này hữu ích khi người dùng muốn thoát khỏi một tiểu lĩnh vực mà họ đã biết.

## Chế độ topic (`from-topic`)

Sử dụng khi người dùng đưa ra một chủ đề, hướng nghiên cứu, hoặc tập từ khóa mà không nêu tên bài báo cụ thể.

Kích hoạt:

- "find papers about diffusion model fine-tuning"
- "what's been written on retrieval augmented generation"
- một cụm lĩnh vực không có anchor

Chế độ topic chạy S2 search và (khi khả dụng) DeepXiv search, sau đó xếp hạng. Đây là một phương án nhẹ hơn so với planner của `/init`: hữu ích cho khám phá nhưng **không** thay thế quy trình bootstrap rộng hơn của `/init`. Nếu người dùng muốn seed một wiki mới bằng một chủ đề, hãy điều hướng họ tới `/init` thay vì làm phình to `/discover`.

## Chế độ wiki (`from-wiki`)

Sử dụng khi người dùng hỏi mở kiểu "what should I read next" mà không có anchor và không có topic.

Kích hoạt:

- "give me the next batch of papers to read"
- "what's a good follow-up to my current wiki"
- flag `--from-wiki` rõ ràng

Chế độ wiki chọn các trang bài báo được sửa đổi gần đây nhất trong wiki, trích xuất arXiv ID của chúng, và dùng chúng làm anchor. Điều này ngầm thiên lệch việc khám phá về phía những gì người dùng đang làm gần đây — thường là hành vi mong muốn.

Nếu `wiki/papers/` trống hoặc không có bài báo nào mang trường frontmatter `arxiv` hoặc `arxiv_id`, chế độ wiki không thể chạy. Hãy nói với người dùng rằng wiki còn quá thưa thớt và đề xuất chế độ topic (hoặc `/init`).

## Nếu người dùng đưa ra cả anchor và topic thì sao?

Ưu tiên chế độ anchor. Anchor là tín hiệu mạnh hơn nhiều so với chuỗi topic. Nhắc đến topic trong báo cáo hướng tới người dùng để họ biết rằng nó đã được ghi nhận, nhưng bản thân quá trình khám phá chạy qua `from-anchors`.
