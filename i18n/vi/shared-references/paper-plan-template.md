# Mẫu Kế Hoạch Bài Báo

Mẫu này được sử dụng để tạo ra một kế hoạch bài báo có cấu trúc từ đồ thị khẳng định trong wiki. Kế hoạch bao gồm bản đồ bằng chứng, cấu trúc tường thuật, đề cương phần, kế hoạch hình ảnh/bảng và kế hoạch trích dẫn.

## Cấu Trúc Tệp Kế Hoạch Bài Báo

Tệp kế hoạch bài báo (`PAPER_PLAN.md`) được tạo ra trong `wiki/outputs/` và bao gồm các phần sau:

```markdown
---
venue: ICLR|NeurIPS|ICML|ACL|CVPR|IEEE
working_title: "Tiêu đề dự kiến của bài báo"
date: YYYY-MM-DD
target_claims:
  - [[claim-slug-1]]
  - [[claim-slug-2]]
---

# Bản Đồ Bằng Chứng

| Khẳng Định | Trạng Thái | Độ Tin Cậy | Nguồn Bằng Chứng | Độ Mạnh | Phần Bài Báo |
|-------------|------------|------------|-------------------|---------|--------------|
| [[khẳng-định-chính]] | supported | 0.85 | exp-chính, paper-A | strong | Phương Pháp + Thí Nghiệm 5.2 |
| [[khẳng-định-phụ-1]] | supported | 0.75 | exp-ablation-1 | moderate | Thí Nghiệm 5.3 (Ablation) |
| [[khẳng-định-phụ-2]] | weakly_supported | 0.55 | exp-scaling | weak | Thí Nghiệm 5.4 (Scaling) |

# Đề Cương Phần

## 1. Giới Thiệu (1.5 trang)

### Khẳng định được đề cập
- Khẳng định khoảng trống: {các phương pháp hiện tại thiếu X vì Y}
- Khẳng định đóng góp: [[khẳng-định-chính]]

### Kế hoạch đoạn văn
1. Bối cảnh rộng: {tầm quan trọng của lĩnh vực, tiến bộ gần đây}
2. Vấn đề cụ thể: {điều gì còn thiếu, tại sao nó quan trọng}
3. Phương pháp của chúng tôi: "Trong công trình này, chúng tôi đề xuất..." + danh sách đóng góp
4. Xem trước kết quả: {con số nổi bật}
5. Cấu trúc bài báo: "Phần còn lại của bài báo..."

### Trích dẫn chính
- [[paper-A]] — xác định vấn đề
- [[paper-B]] — công trình liên quan gần nhất (chúng tôi cải tiến từ)
- [[paper-C]] — baseline của chúng tôi

---

## 2. Công Trình Liên Quan (1 trang)

### Phân nhóm
- Hướng A: {các bài báo, vị trí của chúng tôi}
- Hướng B: {các bài báo, vị trí của chúng tôi}
- Hướng C: {các bài báo, vị trí của chúng tôi}

### Khẳng định được đề cập
- Các khẳng định ngữ cảnh phân biệt với công trình trước

---

## 3. Phương Pháp (2-3 trang)

### Khẳng định được đề cập
- [[khẳng-định-chính]]: phần 3.1-3.2
- [[khẳng-định-phụ-1]]: phần 3.3

### Kế hoạch tiểu mục
- 3.1 Công thức vấn đề: ký hiệu, mục tiêu
- 3.2 Phương pháp cốt lõi: trực giác → hình thức hóa
- 3.3 Thành phần X: quyết định thiết kế + lý giải
- 3.4 Chi tiết huấn luyện/suy luận

### Hình ảnh
- Hình 1: Kiến trúc tổng thể (bắt buộc)
- Hình 2: Chi tiết Thành phần X (nếu phức tạp)

---

## 4. Thí Nghiệm (2-3 trang)

### Khẳng định được đề cập
- [[khẳng-định-chính]]: phần 4.2 (kết quả chính)
- [[khẳng-định-phụ-1]]: phần 4.3 (ablation)
- [[khẳng-định-phụ-2]]: phần 4.4 (scaling)

### Kế hoạch tiểu mục
- 4.1 Thiết lập: tập dữ liệu, baseline, chỉ số, chi tiết triển khai
- 4.2 Kết quả chính: Bảng 1 (so sánh chính), [[exp-chính]]
- 4.3 Nghiên cứu ablation: Bảng 2 (phân tích thành phần), [[exp-ablation-*]]
- 4.4 Phân tích: scaling, robustness, ví dụ định tính

### Hình ảnh/Bảng
- Bảng 1: So sánh chính với baseline
- Bảng 2: Kết quả ablation
- Hình 3: Đường cong scaling / ví dụ định tính

---

## 5. Kết Luận (0.5 trang)

### Điểm chính cần nhớ
- {một câu mà người đọc nên ghi nhớ}

### Hạn chế
- {từ gap_map hoặc điều kiện khẳng định}

### Hướng nghiên cứu tương lai
- {từ câu hỏi mở trong gap_map}

# Kế Hoạch Hình Ảnh/Bảng

## Hình 1: Kiến Trúc Hệ Thống
- Loại: sơ đồ
- Nguồn: mô tả trong phần Phương Pháp
- Phong cách: sơ đồ khối với các thành phần được gắn nhãn
- Kích thước: chiều rộng đầy đủ (1 cột = chiều rộng văn bản)

## Bảng 1: Kết Quả Chính
- Loại: bảng so sánh
- Nguồn: [[exp-chính]] key_result + baseline
- Cột: Phương Pháp | Chỉ Số-1 | Chỉ Số-2 | ...
- Hàng: baseline + của chúng tôi (in đậm)
- Ghi chú: in đậm kết quả tốt nhất, gạch dưới kết quả tốt thứ hai, mũi tên ↑/↓ cho hướng

## Hình 3: Phân Tích Scaling
- Loại: biểu đồ đường
- Nguồn: kết quả [[exp-scaling]]
- Trục X: chiều scaling (kích thước mô hình / kích thước dữ liệu)
- Trục Y: chỉ số hiệu suất
- Đường: của chúng tôi vs baseline, với dải lỗi

# Kế Hoạch Trích Dẫn

- Liệt kê tất cả các bài báo wiki được tham chiếu thông qua `[[slug]]` trong đề cương.
- Đối với mỗi bài báo, lấy trước BibTeX:
  - DBLP trước, sau đó CrossRef, sau đó S2
  - Thành công: ghi lại khóa BibTeX + nguồn
  - Thất bại: đánh dấu `[UNCONFIRMED]`
- Báo cáo độ phủ trích dẫn:
  ```
  Trích dẫn: 15 tổng cộng, 12 đã xác minh (DBLP: 8, CrossRef: 3, S2: 1), 3 [UNCONFIRMED]
  ```
- Đối với các mục [UNCONFIRMED], cung cấp URL gợi ý để xác minh thủ công.

# Tóm Tắt Đánh Giá Của Review LLM

Tóm tắt phản hồi chính từ đánh giá của Review LLM (được sử dụng như một chủ tịch khu vực để đánh giá tính thuyết phục của đề cương), bao gồm:
- Đánh giá về tính thuyết phục của cấu trúc tường thuật (khoảng trống → giải pháp → bằng chứng → tác động)
- Các khẳng định thiếu bằng chứng và các thí nghiệm còn thiếu
- Đánh giá về sự phù hợp của phân nhóm công trình liên quan
- Đánh giá về ngân sách trang
- Đánh giá về sự đầy đủ của hình ảnh/bảng
- Điểm số đánh giá (X/10) và kết luận
- Các sửa đổi được thực hiện dựa trên phản hồi

# Báo Cáo Kế Hoạch Bài Báo

Báo cáo này được in ra terminal sau khi kế hoạch được tạo:

```markdown
# Báo Cáo Kế Hoạch Bài Báo

## Thông Tin Chung
- Tiêu đề: {tiêu đề dự kiến}
- Hội nghị: {hội nghị}
- Giới hạn trang: {N} trang
- Ngày: {ngày}

## Khẳng Định → Phần
| Khẳng Định | Độ Tin Cậy | Phần |
|-------------|------------|------|
| [[chính]] | 0.85 | Phương Pháp + Thí Nghiệm 5.2 |
| [[phụ-1]] | 0.75 | Thí Nghiệm 5.3 |

## Ngân Sách Trang
| Phần | Số Trang | Khẳng Định |
|------|----------|------------|
| Giới Thiệu | 1.5 | khoảng trống, đóng góp |
| Công Trình Liên Quan | 1.0 | ngữ cảnh |
| Phương Pháp | 2.5 | chính, phụ |
| Thí Nghiệm | 2.5 | tất cả |
| Kết Luận | 0.5 | — |

## Hình Ảnh/Bảng: {N} đã lên kế hoạch
## Trích Dẫn: {đã xác minh}/{tổng cộng} đã xác minh, {số xác minh} [UNCONFIRMED]
## Đánh Giá Review LLM: điểm {X}/10, kết luận: {kết luận}

## Bước Tiếp Theo
- Chạy `/paper-draft wiki/outputs/paper-plan-{slug}-{date}.md` để soạn thảo bài báo
- Giải quyết {số xác minh} trích dẫn [UNCONFIRMED] trước khi `/paper-compile`
```