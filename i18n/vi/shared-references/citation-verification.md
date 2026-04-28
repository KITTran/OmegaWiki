# Kỷ Luật Trích Dẫn

> Tài liệu tham khảo chung cho tất cả các kỹ năng tạo ra trích dẫn: /paper-draft, /survey, /paper-plan.
> Mọi trích dẫn trong sản phẩm của ΩmegaWiki phải **có thể xác minh** — không bao giờ được tạo ra bởi AI.

---

## Quy Tắc Cốt Lõi

**Các mục BibTeX phải đến từ các nguồn có thẩm quyền, không phải từ bộ nhớ của AI.**

AI thường tạo ra các chi tiết trích dẫn sai (năm sai, hội nghị sai, tác giả sai, bài báo không tồn tại).
Các nguồn chấp nhận được cho BibTeX chỉ bao gồm:

1. **DBLP** (`https://dblp.org/`) — nguồn chính cho các hội nghị khoa học máy tính
2. **CrossRef** (`https://api.crossref.org/`) — nguồn chính cho các ấn phẩm có DOI
3. **Semantic Scholar** (`https://api.semanticscholar.org/`) — nguồn dự phòng cho các bản preprint
4. **Tệp .bib của chính bài báo** — nếu có sẵn trong `raw/papers/`

## Giao Thức [UNCONFIRMED]

Khi một mục BibTeX **không thể** được lấy từ bất kỳ nguồn có thẩm quyền nào:

1. Tạo một mục nỗ lực tốt nhất từ thông tin có sẵn (tiêu đề, tác giả, năm từ trang wiki)
2. Thêm tiền tố `UNCONFIRMED_` vào khóa BibTeX: `@article{UNCONFIRMED_smith2024attention, ...}`
3. Thêm chú thích: `% [UNCONFIRMED] BibTeX chưa được xác nhận từ DBLP/CrossRef — cần kiểm tra thủ công`
4. Dấu `[UNCONFIRMED]` là **rào cản cứng** đối với việc nộp bài — /paper-compile phải gắn cờ tất cả các mục `[UNCONFIRMED]` còn lại

## Lấy BibTeX

### DBLP (ưu tiên cho khoa học máy tính)

```bash
# Tìm kiếm theo tiêu đề
WebFetch: https://dblp.org/search/publ/api?q={url-encoded-title}&format=json&h=3

# Phân tích phản hồi: .result.hits.hit[].info chứa tiêu đề, tác giả, hội nghị, năm, url
# Lấy BibTeX: WebFetch trường .url + hậu tố ".bib"
```

### CrossRef (ưu tiên cho DOI)

```bash
# Tìm kiếm theo tiêu đề
WebFetch: https://api.crossref.org/works?query.bibliographic={url-encoded-title}&rows=3

# Phân tích phản hồi: .message.items[] chứa tiêu đề, tác giả, container-title, DOI
# Xây dựng BibTeX từ dữ liệu có cấu trúc
```

### Semantic Scholar (dự phòng cho arXiv preprints)

```bash
# Sử dụng tools/fetch_s2.py đã có trong dự án
python3 tools/fetch_s2.py search "<title>"
# Trả về paperId, tiêu đề, tác giả, năm, hội nghị, externalIds
```

## Quy Ước Đặt Khóa Trích Dẫn

```
{họ-tác-giả-đầu}{năm}{từ-khóa-đầu}
```

Ví dụ:
- `hu2022lora` (Hu và cộng sự, 2022, "LoRA: Low-Rank Adaptation...")
- `vaswani2017attention` (Vaswani và cộng sự, 2017, "Attention Is All You Need")

## Quy Tắc Cho Các Kỹ Năng

### /paper-draft
1. Sau khi soạn thảo mỗi phần, thu thập tất cả các tham chiếu `\cite{}`
2. Đối với mỗi trích dẫn: thử DBLP → CrossRef → S2 theo thứ tự
3. Chỉ bao gồm các mục thực sự được trích dẫn (`\nocite{*}` bị cấm)
4. Viết `references.bib` với các mục đã lấy + các mục [UNCONFIRMED] được tách riêng ở cuối

### /survey
1. Sử dụng liên kết wiki `[[slug]]` trong quá trình soạn thảo (định dạng nội bộ wiki)
2. Khi chuyển đổi sang LaTeX, giải quyết mỗi `[[slug]]` thành `\cite{key}`
3. Khóa trích dẫn phải khớp với một mục BibTeX đã được xác minh
4. Nếu một bài báo wiki không có BibTeX có thể xác minh, xuất ra `\cite{UNCONFIRMED_slug}` và gắn cờ

### /paper-plan
1. Trong kế hoạch trích dẫn, liệt kê tất cả các bài báo wiki sẽ được trích dẫn
2. Tiền lấy BibTeX cho mỗi trích dẫn đã lên kế hoạch (thất bại sớm: xác định các mục [UNCONFIRMED] sớm)
3. Báo cáo mức độ bao phủ trích dẫn: bao nhiêu đã được xác minh so với [UNCONFIRMED]

## Những Điều Không Nên Làm

- **Không bao giờ** tạo BibTeX từ bộ nhớ (hội nghị/năm sai còn tệ hơn [UNCONFIRMED])
- **Không bao giờ** trích dẫn bài báo không có trong wiki (mọi trích dẫn phải truy nguyên về wiki/papers/)
- **Không bao giờ** sử dụng `\nocite{*}` (mọi mục phải được trích dẫn rõ ràng)
- **Không bao giờ** âm thầm bỏ qua dấu [UNCONFIRMED] (nó phải tồn tại cho đến khi được xác minh thủ công hoặc lấy thành công)
- **Không bao giờ** bịa đặt DOI hoặc arXiv ID