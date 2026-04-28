# Nguyên Tắc Viết Học Thuật

> Tài liệu tham khảo chung cho tất cả các kỹ năng tạo ra sản phẩm viết: /paper-draft, /paper-plan, /survey.
> Những nguyên tắc này đảm bảo chất lượng viết đủ tiêu chuẩn xuất bản, đọc như được viết bởi chuyên gia, không phải bởi AI.

---

## 1. Cấu Trúc Tường Thuật

### Hình Dạng Đồng Hồ Cát

Mọi bài báo có cấu trúc tốt đều tuân theo hình đồng hồ cát:

```
RỘNG:   Giới thiệu — tại sao điều này quan trọng đối với lĩnh vực
HẸP:    Phương pháp — chính xác những gì chúng ta đã làm
HẸP:    Thí nghiệm — chính xác những gì đã xảy ra
RỘNG:   Thảo luận — điều này có ý nghĩa gì đối với lĩnh vực
```

### Quy Tắc Cấp Phần

- **Giới thiệu**: Bắt đầu với vấn đề (không phải giải pháp). Người đọc phải cảm nhận được khoảng trống trước khi bạn lấp đầy nó.
  - Đoạn 1: bối cảnh rộng và tầm quan trọng
  - Đoạn 2: vấn đề cụ thể và lý do các phương pháp hiện tại không đáp ứng được
  - Đoạn 3: "Trong nghiên cứu này, chúng tôi..." — đóng góp của bạn
  - Đoạn 4: tóm tắt kết quả và cấu trúc bài báo

- **Công trình liên quan**: Tổ chức theo chủ đề, không theo bài báo. Mỗi đoạn đề cập đến một hướng nghiên cứu, không phải một trích dẫn đơn lẻ.
  - Kết thúc mỗi đoạn bằng cách nêu sự khác biệt giữa công trình của bạn với hướng đó
  - Không bao giờ viết một danh sách phẳng như "X đã làm Y. Z đã làm W."

- **Phương pháp**: Bắt đầu bằng trực giác trước khi đi vào công thức. Người đọc nên hiểu *tại sao* trước *làm thế nào*.
  - Một hình vẽ minh họa kiến trúc tổng thể (bắt buộc)
  - Ký hiệu được giới thiệu trước khi sử dụng lần đầu
  - Mỗi tiểu mục = một quyết định thiết kế

- **Thí nghiệm**: Cấu trúc ưu tiên khẳng định. Mỗi tiểu mục bắt đầu bằng khẳng định mà nó xác thực.
  - "Chúng tôi khẳng định X. Để xác minh, chúng tôi..." (không phải "Chúng tôi đã chạy thí nghiệm A. Kết quả cho thấy...")
  - Bảng trước khi thảo luận (người đọc quét bảng trước)
  - Thanh lỗi hoặc khoảng tin cậy là bắt buộc

- **Kết luận**: Ý tưởng mới, không phải tóm tắt. Người đọc nên nhớ điều gì vào ngày mai?

## 2. Quy Tắc Rõ Ràng

### Cấp Độ Câu

- **Một ý tưởng mỗi câu.** Nếu một câu có "và" + "mà" + "điều đó", hãy tách nó ra.
- **Thể chủ động theo mặc định.** "Chúng tôi huấn luyện mô hình" thay vì "Mô hình được huấn luyện."
- **Cụ thể hơn mơ hồ.** "Giảm độ trễ 40%" thay vì "cải thiện đáng kể hiệu suất."
- **Định nghĩa trước khi sử dụng.** Mọi từ viết tắt phải được viết đầy đủ khi sử dụng lần đầu. Mọi ký hiệu phải được định nghĩa trước phương trình đầu tiên.

### Cấp Độ Đoạn

- **Câu chủ đề đầu tiên.** Mọi đoạn văn bắt đầu bằng khẳng định chính của nó.
- **Một điểm mỗi đoạn.** Nếu bạn thấy mình viết "Ngoài ra" ở giữa đoạn, hãy bắt đầu một đoạn mới.
- **Chuyển tiếp giữa các đoạn.** Câu cuối của đoạn N nên kết nối với câu đầu của đoạn N+1.

### Tính Nhất Quán Ký Hiệu

- Định nghĩa tệp `math_commands.tex` cho ký hiệu chung
- Ký hiệu giống nhau = ý nghĩa giống nhau trong toàn bộ bài báo
- Chữ thường in đậm cho vector (**x**), chữ hoa in đậm cho ma trận (**W**), chữ viết tay cho tập hợp
- Không bao giờ định nghĩa lại ký hiệu ở giữa bài báo

## 3. Thiết Kế Hình Ảnh và Bảng

### Hình Ảnh

- **Mọi hình ảnh phải được tham chiếu trong văn bản** và được thảo luận (không chỉ hiển thị)
- **Bảng màu an toàn cho người mù màu**: sử dụng mẫu phân biệt + màu sắc (không bao giờ chỉ dựa vào màu)
- **Cỡ chữ >= 8pt** trong tất cả nhãn, chú giải, vạch trục
- **Định dạng vector được ưu tiên** (PDF/SVG cho biểu đồ đường, PNG chỉ cho ảnh/ảnh chụp màn hình)
- **Chú thích tự chứa**: người đọc nên hiểu hình ảnh chỉ từ chú thích của nó
- **Phong cách nhất quán**: tất cả hình ảnh sử dụng cùng phông chữ, độ rộng đường, bảng màu

### Bảng

- **Chỉ sử dụng đường ngang** (không đường dọc, không lưới đầy đủ): `\toprule`, `\midrule`, `\bottomrule`
- **Kết quả tốt nhất in đậm**, kết quả tốt thứ hai gạch chân
- **Đơn vị trong tiêu đề cột**, không phải trong mỗi ô
- **Căn chỉnh dấu thập phân** trong cột số
- **Chú thích phía trên bảng** (quy ước trong hầu hết các hội nghị ML)

## 4. Quy Tắc Đánh Bóng Loại Bỏ Dấu Vết AI

Văn bản do AI tạo ra có các mẫu nhận biết được. Những điều này phải được loại bỏ trước khi nộp.

### Từ và Cụm Từ Cần Loại Bỏ hoặc Thay Thế

| Mẫu AI | Thay Thế Bằng |
|------------|-------------|
| "đi sâu vào" | "xem xét" / "phân tích" / loại bỏ hoàn toàn |
| "đáng chú ý là" | loại bỏ (chỉ nêu sự việc) |
| "điều quan trọng cần lưu ý" | loại bỏ |
| "trong lĩnh vực" | "trong" |
| "tận dụng" (như động từ) | "sử dụng" / "khai thác" / "áp dụng" |
| "sử dụng" | "dùng" |
| "tạo điều kiện" | "cho phép" / "đáp ứng" / loại bỏ |
| "toàn diện" (không có bằng chứng) | loại bỏ hoặc định lượng |
| "quan trọng" / "then chốt" | "quan trọng" / "chính" / loại bỏ |
| "Hơn nữa" ở đầu đoạn | thay đổi: "Ngoài ra" / "Thêm vào đó" / cấu trúc lại |
| "Tóm lại" (cụm từ chính xác) | "Tóm tắt" / cấu trúc lại mà không cần từ đệm |
| "vô số" | "nhiều" / "đa dạng" / số cụ thể |
| "làm sáng tỏ" | "tiết lộ" / "làm rõ" / "chỉ ra" |
| "mở đường cho" | "cho phép" / loại bỏ |
| "hiện đại" / "tối tân" (như từ đệm) | chỉ sử dụng khi trích dẫn các tiêu chuẩn cụ thể |
| "mạnh mẽ" (không có thí nghiệm về độ mạnh) | loại bỏ hoặc làm rõ |
| "mới lạ" (lạm dụng) | sử dụng một lần trong tóm tắt + một lần trong giới thiệu, không hơn |

### Mẫu Cấu Trúc Cần Sửa

- **Dè dặt quá mức**: "Có thể cho rằng X có thể..." → "X có khả năng vì..."
- **Chuyển chủ đề dư thừa**: "Sau khi thảo luận về X, giờ chúng ta chuyển sang Y" → chỉ bắt đầu Y
- **Nghiện liệt kê**: "Thứ nhất... Thứ hai... Thứ ba..." trong mọi đoạn → thay đổi cấu trúc
- **Lạm dụng so sánh nhất**: "đột phá", "cách mạng" → để kết quả tự nói
- **Mở đầu câu lặp lại**: thay đổi mẫu chủ ngữ-động từ giữa các câu liên tiếp

### Vòng Đánh Bóng

Sau khi soạn thảo, áp dụng danh sách kiểm tra tinh thần cho mỗi đoạn:

1. Liệu một người phản biện có thể đoán được đoạn này do AI tạo ra không? Nếu có, hãy viết lại.
2. Mọi tính từ có xứng đáng với vị trí của nó không? Loại bỏ các từ so sánh nhất không xứng đáng.
3. Có cách nào ngắn gọn hơn để diễn đạt điều này không? Hãy sử dụng nó.
4. Đoạn này bổ sung thông tin hay chỉ lấp đầy khoảng trống? Cắt bỏ phần lấp đầy.
5. Đọc to: liệu nó có nghe như được viết bởi một chuyên gia không?

## 5. Định Dạng Theo Hội Nghị Cụ Thể

### Giới Hạn Trang (điển hình)

| Hội nghị | Chính | Tài liệu tham khảo | Phụ lục |
|-------|------|-----------|----------|
| ICLR | 10 trang | không giới hạn | không giới hạn |
| NeurIPS | 9 trang | không giới hạn | không giới hạn |
| ICML | 8 trang | không giới hạn | không giới hạn |
| ACL | 8 trang (dài) | không giới hạn | không giới hạn |
| CVPR | 8 trang | +2 trang | — |
| IEEE TPAMI | ~20 trang | bao gồm | — |

### Quy Tắc Ẩn Danh

- Không có tên tác giả, tổ chức hoặc lời cảm ơn trong bản nộp
- Không có "công trình trước đây của chúng tôi [1]" — sử dụng "Smith và cộng sự [1]" (ngôi thứ ba)
- Không có liên kết GitHub đến kho lưu trữ có thể nhận diện
- Không có tên cụm đặc trưng của tổ chức

## Những Điều Không Nên Làm

- **Không bao giờ nộp mà không đánh bóng loại bỏ dấu vết AI** — người phản biện ngày càng kiểm tra các mẫu AI
- **Không bao giờ sử dụng đoạn văn đệm** — mọi đoạn phải thúc đẩy lập luận
- **Không bao giờ trình bày kết quả mà không có ngữ cảnh** — "độ chính xác 95%" không có ý nghĩa gì nếu không so sánh với cơ sở
- **Không bao giờ trộn lẫn thì** — Phương pháp ở thì hiện tại, thí nghiệm ở thì quá khứ, kết quả ở thì hiện tại
- **Không bao giờ trích dẫn mà không thảo luận** — mọi \cite phải đi kèm với cách nó liên quan đến công trình của bạn