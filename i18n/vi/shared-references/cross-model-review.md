# Nguyên Tắc Độc Lập Của Người Đánh Giá

> Được tham chiếu bởi: `/review`, `/novelty`, `/ideate`, `/exp-eval`, `/exp-design`, `/paper-plan`, `/paper-draft`, `/rebuttal`, `/refine`

---

## Quy Tắc Cốt Lõi

Khi sử dụng Mô hình Ngôn ngữ Đánh Giá (Review LLM - bất kỳ mô hình bên ngoài nào) làm người đánh giá hoặc xác minh chéo, **không bao giờ chia sẻ đánh giá, điểm số hoặc kết luận của mô hình chính** với người đánh giá trước khi họ hình thành đánh giá độc lập của mình.

Người đánh giá phải nhận được:
- **Tạo tác** đang được đánh giá (ý tưởng, phương pháp, bản thảo bài báo, kết quả thí nghiệm)
- **Bối cảnh liên quan** (các trang wiki, công trình trước đây, ràng buộc)
- **Tiêu chí đánh giá** (những gì cần đánh giá, ở mức độ khó nào)

Người đánh giá **không được** nhận:
- Điểm số hoặc xếp hạng của Claude về tạo tác
- Đánh giá của Claude về điểm mạnh/điểm yếu
- Khuyến nghị của Claude (tiếp tục/sửa đổi/bỏ qua)
- Bất kỳ cách đóng khung nào khiến người đánh giá bị ảnh hưởng đến một kết luận cụ thể

---

## Tại Sao Điều Này Quan Trọng

1. **Thiên kiến neo**: Nếu Review LLM thấy "Claude đánh giá đây là 7/10", đánh giá của nó sẽ tập trung quanh 7. Đánh giá độc lập phát hiện những điểm mù mà đánh giá bị neo bỏ lỡ.
2. **Thiên kiến xác nhận**: Nếu Claude nói "điểm yếu chính là X", Review LLM sẽ tập trung vào X và bỏ lỡ điểm yếu Y. Người đánh giá không bị định hướng sẽ khám phá toàn bộ không gian.
3. **Đa dạng quan điểm**: Toàn bộ giá trị của đánh giá chéo giữa các mô hình là các mô hình khác nhau có thiên kiến khác nhau. Chia sẻ đánh giá trước khi đánh giá sẽ làm mất đi sự đa dạng này.

---

## Cách Áp Dụng

### Trong `/review` (phê bình đối kháng)
- Bước 2: Gửi tạo tác + bối cảnh + lời nhắc đánh giá cho Review LLM. **Không bao gồm bất kỳ đánh giá trước nào.**
- Bước 3 (đa vòng): Claude có thể phản hồi lại những phê bình của Review LLM bằng các phản biện, nhưng đây là phản hồi đối với các điểm của nó, không phải đánh giá đã được hình thành trước.

### Trong `/novelty` (xác minh chéo)
- Bước 3: Gửi chữ ký phương pháp + các công trình tương tự hiện có cho Review LLM. **Không bao gồm điểm số tính mới lạ của Claude từ Bước 2.**

### Trong `/ideate` (động não song song)
- Giai đoạn 2: Review LLM tạo ra ý tưởng từ cùng bối cảnh với Claude, nhưng **không thấy danh sách ý tưởng của Claude**. Việc hợp nhất diễn ra sau khi cả hai hoàn thành độc lập.

### Trong `/exp-eval` (phán quyết công bằng)
- Bước 2: Gửi kết quả thí nghiệm + khẳng định + bối cảnh cho Review LLM. **Không bao gồm cách diễn giải kết quả của Claude.**

---

## Kết Hợp Các Đánh Giá Độc Lập

Sau khi cả hai mô hình đã đánh giá độc lập:

1. **Nếu điểm số đồng thuận** (chênh lệch trong vòng 1 điểm): Sử dụng điểm số trung bình. Độ tin cậy cao.
2. **Nếu điểm số không đồng thuận** (chênh lệch từ 2 điểm trở lên): Gắn cờ sự không đồng thuận rõ ràng. Điều tra xem mô hình nào đã bỏ lỡ điều gì. Báo cáo cả hai điểm số kèm theo lý do.
3. **Mặc định thận trọng**: Khi kết hợp điểm số tính mới lạ hoặc chất lượng, hãy lấy **điểm số thấp hơn**. Tốt hơn là đánh giá thấp hơn là cam kết quá mức với một ý tưởng có khuyết điểm.
4. **Không bao giờ trung bình hóa một phát hiện quan trọng**: Nếu một mô hình tìm thấy một lỗ hổng nghiêm trọng (ví dụ: phương pháp đã được công bố), phát hiện đó vẫn được giữ nguyên bất kể điểm số của mô hình khác.

---

## Kiểm Tra Tính Khả Dụng Của Review LLM

Trước khi gọi `mcp__llm-review__chat`, mọi kỹ năng phải kiểm tra tính khả dụng và xử lý một cách khéo léo.

### Phát Hiện

Một cuộc gọi đến `mcp__llm-review__chat` sẽ thất bại nếu:
- Máy chủ MCP không được cấu hình (thiếu `.mcp.json` hoặc `enableAllProjectMcpServers` không được đặt)
- `LLM_API_KEY` hoặc `LLM_BASE_URL` không được đặt trong `.env`
- Điểm cuối API không thể truy cập

### Giao Thức Dự Phòng

Khi máy chủ MCP đánh giá **không khả dụng**:

1. **Không bỏ qua bước đánh giá một cách im lặng.** Thông báo cho người dùng:
   > "Chức năng đánh giá chéo giữa các mô hình chưa được cấu hình. Kỹ năng này hoạt động tốt nhất với một mô hình đánh giá độc lập. Bạn có muốn thiết lập ngay bây giờ, hoặc tiếp tục với phân tích chỉ sử dụng Claude?"

2. **Nếu người dùng muốn cấu hình**, hướng dẫn họ tương tác:
   - Hỏi họ sử dụng nhà cung cấp API tương thích OpenAI nào (DeepSeek, OpenAI, Qwen, OpenRouter, v.v.)
   - Hỗ trợ họ chỉnh sửa `.env` để đặt `LLM_API_KEY`, `LLM_BASE_URL`, `LLM_MODEL`
   - Yêu cầu họ khởi động lại Claude Code để máy chủ MCP nhận cấu hình mới
   - Tham khảo `.env.example` để biết bảng nhà cung cấp đầy đủ

3. **Nếu người dùng muốn tiếp tục mà không cần đánh giá**, tiếp tục với chế độ chỉ sử dụng Claude:
   - Bỏ qua cuộc gọi `mcp__llm-review__chat`
   - Thực hiện bước đánh giá/phê bình bằng chính Claude (tự đánh giá)
   - Đánh dấu rõ ràng đầu ra là `[Tự đánh giá của Claude — không có ý kiến thứ hai độc lập]`
   - Phần còn lại của quy trình kỹ năng diễn ra bình thường

### Khi Review LLM Khả Dụng

Tiến hành với giao thức đánh giá chéo giữa các mô hình tiêu chuẩn như đã định nghĩa ở trên. Công cụ `mcp__llm-review__chat` được cung cấp bởi máy chủ MCP `llm-review` (được cấu hình trong `.mcp.json`), hoạt động với bất kỳ API tương thích OpenAI nào.