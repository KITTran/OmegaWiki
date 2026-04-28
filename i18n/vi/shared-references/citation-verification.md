# Kỷ Luật Trích Dẫn

> Tài liệu tham khảo chung cho tất cả các kỹ năng tạo trích dẫn: /paper-draft, /survey, /paper-plan.
> Mọi trích dẫn trong đầu ra của ΩmegaWiki phải **có thể xác minh** — không bao giờ được tạo bởi LLM.

---

## Quy Tắc Cốt Lõi

**Các mục BibTeX phải đến từ các nguồn có thẩm quyền, không phải từ bộ nhớ của LLM.**

LLM có thể tạo ra các chi tiết trích dẫn sai (năm sai, hội nghị sai, tác giả sai, bài báo không tồn tại).
Các nguồn chấp nhận được duy nhất cho BibTeX là:

1. **DBLP** (`https://dblp.org/`) — nguồn chính cho các hội nghị CS
2. **CrossRef** (`https://api.crossref.org/`) — nguồn chính cho các ấn phẩm có DOI
3. **Semantic Scholar** (`https://api.semanticscholar.org/`) — nguồn dự phòng cho các bản preprint
4. **Tệp .bib của chính bài báo** — nếu có sẵn trong `raw/papers/`

---

## Giao Thức [UNCONFIRMED]

Khi một mục BibTeX **không thể** được lấy từ bất kỳ nguồn có thẩm quyền nào:

1. Tạo một mục nỗ lực tốt nhất từ thông tin có sẵn (tiêu đề, tác giả, năm từ trang wiki)
2. Thêm tiền tố `UNCONFIRMED_` cho khóa BibTeX: `@article{UNCONFIRMED_smith2024attention, ...}`
3. Thêm một chú thích: `% [UNCONFIRMED] BibTeX chưa được xác nhận từ DBLP/CrossRef — cần kiểm tra thủ công`
4. Dấu `[UNCONFIRMED]` là **rào cản cứng** đối với việc nộp bài — /paper-compile phải gắn cờ tất cả các mục `[UNCONFIRMED]` còn lại

---

## Lấy BibTeX

### DBLP (ưu tiên cho CS)

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

---

## Quy Ước Khóa Trích Dẫn

```
{first-author-lastname}{year}{first-keyword}
```

Ví dụ:
- `hu2022lora` (Hu và cộng sự, 2022, "LoRA: Low-Rank Adaptation...")
- `vaswani2017attention` (Vaswani và cộng sự, 2017, "Attention Is All You Need")

---

## Quy Tắc Cho Các Kỹ Năng

### /paper-draft
1. Sau khi soạn thảo mỗi phần, thu thập tất cả các tham chiếu `\cite{}`
2. Đối với mỗi trích dẫn: thử DBLP → CrossRef → S2 theo thứ tự
3. Chỉ bao gồm các mục thực sự được trích dẫn (`\nocite{*}` bị cấm)
4. Ghi `references.bib` với các mục đã lấy + các mục [UNCONFIRMED] được phân tách ở cuối

### /survey
1. Sử dụng liên kết wikilinks `[[slug]]` trong quá trình soạn thảo (định dạng nội bộ wiki)
2. Khi chuyển đổi sang LaTeX, phân giải mỗi `[[slug]]` thành `\cite{key}`
3. Khóa trích dẫn phải khớp với một mục BibTeX đã được xác minh
4. Nếu một bài báo wiki không có BibTeX có thể xác minh, xuất `\cite{UNCONFIRMED_slug}` và gắn cờ

### /paper-plan
1. Trong kế hoạch trích dẫn, liệt kê tất cả các bài báo wiki sẽ được trích dẫn
2. Tiền lấy BibTeX cho mỗi trích dẫn đã lên kế hoạch (thất bại nhanh: xác định các mục [UNCONFIRMED] sớm)
3. Báo cáo độ phủ trích dẫn: bao nhiêu mục đã được xác minh so với [UNCONFIRMED]

---

## Những Điều Không Nên Làm

- **Không bao giờ** tạo BibTeX từ bộ nhớ (sai hội nghị/năm tồi hơn [UNCONFIRMED])
- **Không bao giờ** trích dẫn một bài báo không có trong wiki (tất cả các trích dẫn phải truy nguyên về wiki/papers/)
- **Không bao giờ** sử dụng `\nocite{*}` (mỗi mục phải được trích dẫn rõ ràng)
- **Không bao giờ** âm thầm bỏ qua dấu [UNCONFIRMED] (nó phải tồn tại cho đến khi xác minh thủ công hoặc lấy thành công)
- **Không bao giờ** bịa đặt DOI hoặc arXiv ID