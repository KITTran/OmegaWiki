---
name: edit
description: Thêm hoặc xóa nguồn thô, hoặc cập nhật nội dung wiki theo yêu cầu của người dùng
argument-hint: "[yêu cầu]"
---

# /edit

> Thêm hoặc xóa nguồn thô, hoặc cập nhật nội dung wiki theo yêu cầu của người dùng.

## Kích Hoạt

Lệnh thủ công của người dùng: `/edit <yêu cầu người dùng>`

## Đầu Vào

Yêu cầu của người dùng, ví dụ:
- "Tải bài báo này vào raw/papers/"
- "Xóa raw/papers/xxx.pdf"
- "Cập nhật theo dõi SOTA trong topics/efficient-llm-adaptation"
- "Thêm một biến thể mới vào concepts/lora"

## Đầu Ra

Các tệp wiki đã cập nhật, `index.md`, `log.md`

## Các Bước

### BƯỚC 1: Phân Tích Ý Định Người Dùng

1. **Thêm nguồn thô**:
   - Nếu người dùng cung cấp đường dẫn cục bộ: sao chép vào thư mục tương ứng dưới `raw/`
   - Nếu người dùng cung cấp URL arXiv: tải xuống vào `raw/papers/`
   - Nếu người dùng cung cấp URL web: lấy nội dung với markdownify và lưu vào `raw/web/`
2. **Xóa nguồn thô**:
   - Xác nhận sau đó thực hiện xóa
3. **Cập nhật wiki**:
   - Đọc các trang liên quan và sửa đổi nội dung theo hướng dẫn của người dùng

### BƯỚC 2: Thực Hiện Cập Nhật

1. Các nguồn thô mới thêm sau này có thể được tích hợp vào wiki qua `/ingest`
2. Các sửa đổi wiki trực tiếp: cập nhật các trường/nội dung cụ thể trong các trang cụ thể theo hướng dẫn của người dùng
3. Khi viết liên kết xuôi, đồng thời viết liên kết ngược

### BƯỚC 3: Cập Nhật Điều Hướng

1. `CHỈNH SỬA wiki/index.md`: cập nhật các mục liên quan
2. `THÊM wiki/log.md`: `## [{date}] update | {mô tả}`

### BƯỚC 4: Báo Cáo

- Liệt kê tất cả các thay đổi đã thực hiện
- Đề xuất các hành động tiếp theo (ví dụ: ingest các nguồn thô mới thêm nếu áp dụng)

## Các Ràng Buộc

- `raw/` là chỉ đọc đối với các tệp hiện có (kỹ năng này có thể thêm tệp vào `raw/`, nhưng không được sửa đổi các tệp hiện có)
- Các sửa đổi wiki phải tuân theo cấu trúc mẫu
- Liên kết hai chiều phải được đồng bộ