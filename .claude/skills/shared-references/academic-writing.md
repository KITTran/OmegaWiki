# Nguyên Tắc Viết Học Thuật

> Tài liệu tham khảo chung cho tất cả các kỹ năng tạo ra sản phẩm văn bản: /paper-draft, /paper-plan, /survey.
> Những nguyên tắc này đảm bảo chất lượng viết đạt tiêu chuẩn xuất bản, đọc như được viết bởi chuyên gia, không phải bởi AI.

---

## 1. Cấu Trúc Tường Thuật

### Hình Dạng Đồng Hồ Cát

Mọi bài báo có cấu trúc tốt đều tuân theo hình dạng đồng hồ cát:

```
RỘNG:   Giới thiệu — tại sao điều này quan trọng đối với lĩnh vực
HẸP:    Phương pháp — chính xác những gì chúng ta đã làm
HẸP:    Thí nghiệm — chính xác những gì đã xảy ra
RỘNG:   Thảo luận — điều này có ý nghĩa gì đối với lĩnh vực
```

### Quy Tắc Cấp Độ Phần

- **Giới thiệu**: Bắt đầu với vấn đề (không phải giải pháp). Người đọc phải cảm nhận được khoảng trống trước khi bạn lấp đầy nó.
  - Đoạn 1: bối cảnh rộng và tầm quan trọng
  - Đoạn 2: vấn đề cụ thể và lý do các phương pháp hiện tại chưa đủ
  - Đoạn 3: "Trong nghiên cứu này, chúng tôi..." — đóng góp của bạn
  - Đoạn 4: tóm tắt kết quả và cấu trúc bài báo

- **Công trình liên quan**: Sắp xếp theo chủ đề, không theo bài báo. Mỗi đoạn đề cập đến một hướng nghiên cứu, không phải một trích dẫn đơn lẻ.
  - Kết thúc mỗi đoạn bằng sự khác biệt của công trình bạn so với hướng đó
  - Không bao giờ viết một danh sách phẳng kiểu "X đã làm Y. Z đã làm W."

- **Phương pháp**: Bắt đầu bằng trực giác trước khi đi vào công thức. Người đọc nên hiểu *tại sao* trước *làm thế nào*.
  - Một hình vẽ minh họa kiến trúc tổng thể (bắt buộc)
  - Ký hiệu được giới thiệu trước khi sử dụng lần đầu
  - Mỗi tiểu mục = một quyết định thiết kế

- **Thí nghiệm**: Cấu trúc ưu tiên khẳng định. Mỗi tiểu mục bắt đầu bằng khẳng định mà nó xác minh.
  - "Chúng tôi khẳng định X. Để xác minh, chúng tôi..." (không phải "Chúng tôi đã tiến hành thí nghiệm A. Kết quả cho thấy...")
  - Bảng trước khi thảo luận (người đọc quét bảng trước)
  - Thanh lỗi hoặc khoảng tin cậy là bắt buộc

- **Kết luận**: Đưa ra cái nhìn mới, không phải tóm tắt. Điều gì người đọc nên nhớ vào ngày mai?

## 2. Quy Tắc Rõ Ràng

### Cấp Độ Câu

- **Một ý tưởng mỗi câu.** Nếu một câu có "và" + "mà" + "điều đó", hãy tách nó.
- **Thể chủ động theo mặc định.** "Chúng tôi huấn luyện mô hình" thay vì "Mô hình được huấn luyện."
- **Cụ thể hơn mơ hồ.** "Giảm độ trễ 40%" thay vì "cải thiện đáng kể hiệu suất."
- **Định nghĩa trước khi sử dụng.** Mọi từ viết tắt phải được giải thích khi sử dụng lần đầu. Mọi ký hiệu phải được định nghĩa trước phương trình đầu tiên.

### Cấp Độ Đoạn

- **Câu chủ đề đầu tiên.** Mỗi đoạn bắt đầu bằng khẳng định chính của nó.
- **Một điểm mỗi đoạn.** Nếu bạn thấy mình viết "Ngoài ra" giữa đoạn, hãy bắt đầu một đoạn mới.
- **Chuyển tiếp giữa các đoạn.** Câu cuối của đoạn N nên kết nối với câu đầu của đoạn N+1.

### Nhất Quán Ký Hiệu

- Định nghĩa tệp `math_commands.tex` cho ký hiệu chung
- Cùng một ký hiệu = cùng một ý nghĩa trong toàn bộ bài báo
- Chữ thường in đậm cho vectơ (**x**), chữ hoa in đậm cho ma trận (**W**), chữ viết hoa cho tập hợp
- Không bao giờ định nghĩa lại ký hiệu ở giữa bài báo

## 3. Thiết Kế Hình Ảnh và Bảng

### Hình Ảnh

- **Mọi hình ảnh phải được tham chiếu trong văn bản** và thảo luận (không chỉ hiển thị)
- **Bảng màu an toàn cho người mù màu**: sử dụng mẫu và màu sắc có thể phân biệt (không bao giờ chỉ dựa vào màu)
- **Cỡ chữ >= 8pt** trong tất cả nhãn, chú giải, trục tọa độ
- **Định dạng vector ưu tiên** (PDF/SVG cho biểu đồ đường, PNG chỉ cho ảnh/ảnh chụp màn hình)
- **Chú giải tự chứa**: người đọc nên hiểu hình ảnh chỉ từ chú giải của nó
- **Phong cách nhất quán**: tất cả hình ảnh sử dụng cùng phông chữ, độ dày đường, bảng màu

### Bảng

- **Chỉ sử dụng đường ngang** (không đường dọc, không lưới đầy đủ): `\toprule`, `\midrule`, `\bottomrule`
- **Kết quả tốt nhất in đậm**, kết quả tốt thứ hai gạch chân
- **Đơn vị trong tiêu đề cột**, không lặp lại trong mỗi ô
- **Căn chỉnh dấu thập phân** trong cột số
- **Chú giải trên bảng** (quy ước trong hầu hết các hội nghị ML)

## 4. Quy Tắc Đánh Bóng Loại Bỏ Dấu Vết AI

Văn bản do AI tạo ra có các mẫu nhận biết được. Những điều này phải được loại bỏ trước khi nộp.

### Từ và Cụm Từ Cần Loại Bỏ hoặc Thay Thế

| Mẫu AI | Thay Thế Bằng |
|--------|--------------|
| "đi sâu vào" | "xem xét" / "phân tích" / loại bỏ hoàn toàn |
| "đáng chú ý là" | loại bỏ (chỉ nêu sự việc) |
| "điều quan trọng cần lưu ý" | loại bỏ |
| "trong lĩnh vực của" | "trong" |
| "tận dụng" (dưới dạng động từ) | "sử dụng" / "khai thác" / "áp dụng" |
| "utilize" | "use" |
| "facilitate" | "enable" / "allow" / loại bỏ |
| "comprehensive" (không có bằng chứng) | loại bỏ hoặc định lượng |
| "crucial" / "pivotal" | "important" / "key" / loại bỏ |
| "Furthermore" ở đầu đoạn | thay đổi: "Moreover" / "In addition" / tái cấu trúc |
| "In conclusion" (cụm từ chính xác) | "To summarize" / tái cấu trúc mà không cần từ đệm |
| "a myriad of" | "many" / "various" / số cụ thể |
| "shed light on" | "reveal" / "clarify" / "show" |
| "pave the way for" | "enable" / loại bỏ |
| "cutting-edge" / "state-of-the-art" (như từ đệm) | chỉ sử dụng SOTA khi trích dẫn các tiêu chuẩn cụ thể |
| "robust" (không có thí nghiệm về độ mạnh) | loại bỏ hoặc làm rõ |
| "novel" (sử dụng quá mức) | dùng một lần trong tóm tắt + một lần trong giới thiệu, không hơn |

### Mẫu Cấu Trúc Cần Sửa

- **Hạn chế quá mức**: "Có thể cho rằng X có thể..." → "X có khả năng vì..."
- **Chuyển chủ đề dư thừa**: "Sau khi thảo luận về X, giờ chúng ta chuyển sang Y" → chỉ bắt đầu Y
- **Liệt kê quá mức**: "Đầu tiên... Thứ hai... Thứ ba..." trong mỗi đoạn → thay đổi cấu trúc
- **Lạm dụng so sánh nhất**: "đột phá", "cách mạng" → để kết quả tự nói
- **Mở đầu câu lặp lại**: thay đổi mẫu chủ ngữ-động từ trong các câu liên tiếp

### Vòng Đánh Bóng

Sau khi soạn thảo, chạy danh sách kiểm tra tinh thần này trên mỗi đoạn:

1. Một người phản biện có thể đoán đây là do AI tạo ra không? Nếu có, viết lại.
2. Mọi tính từ có xứng đáng vị trí của nó không? Loại bỏ các từ so sánh nhất không xứng đáng.
3. Có cách nào ngắn gọn hơn để diễn đạt điều này không? Hãy sử dụng nó.
4. Đoạn này có thêm thông tin, hay chỉ lấp đầy không gian? Cắt bỏ phần lấp đầy.
5. Đọc to: nó có giống như một chuyên gia viết không?

## 5. Định Dạng Theo Hội Nghị Cụ Thể

### Giới Hạn Trang (điển hình)

| Hội nghị | Nội dung chính | Tài liệu tham khảo | Phụ lục |
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

- **Không bao giờ nộp bài mà không đánh bóng loại bỏ dấu vết AI** — người phản biện ngày càng kiểm tra các mẫu AI
- **Không bao giờ sử dụng đoạn văn đệm** — mọi đoạn phải thúc đẩy lập luận
- **Không bao giờ trình bày kết quả mà không có ngữ cảnh** — "độ chính xác 95%" không có ý nghĩa gì nếu không so sánh với cơ sở
- **Không bao giờ trộn lẫn thì** — Phương pháp ở thì hiện tại, thí nghiệm ở thì quá khứ, kết quả ở thì hiện tại
- **Không bao giờ trích dẫn mà không thảo luận** — mọi \cite phải đi kèm với cách nó liên quan đến công trình của bạn