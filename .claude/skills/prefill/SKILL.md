---
description: Gieo kiến thức nền tảng lĩnh vực vào wiki/foundations/ để các lần /ingest tiếp theo không tạo các trang khái niệm trùng lặp cho tài liệu sách giáo khoa
argument-hint: "[lĩnh-vực] [--add 'tên khái niệm']"
---

# /prefill

> Lắng đọng kiến thức nền tảng (các phương pháp nền tảng, thực hành phổ biến, kiến trúc tiêu chuẩn) vào `wiki/foundations/` dưới dạng các trang **đầu cuối**.
> Foundations được thiết kế một chiều: các trang khác liên kết đến chúng, foundations không viết liên kết ngược.

## Kích Hoạt

Thủ công: `/prefill [lĩnh-vực]` hoặc `/prefill --add "tên khái niệm"`.

## Đầu Vào

- `domain` *(vị trí, tùy chọn)*: lĩnh vực nghiên cứu — một trong `general`, `NLP`, `CV`, `ML Systems`, `Robotics`. Nếu bỏ qua, suy ra từ tags của `wiki/topics/`; nếu `wiki/topics/` trống, nhắc người dùng.
- `--add "<khái-niệm>"`: bỏ qua danh mục và gieo chính xác một foundation theo tên.

## Đầu Ra

- `wiki/foundations/{slug}.md` — một trang cho mỗi khái niệm được gieo
- Đã cập nhật `wiki/index.md` (phần foundations được tạo lại bởi `rebuild-index`)
- Mục `wiki/log.md`

## Tương Tác Wiki

### Đọc
- `wiki/topics/*.md` — để suy ra lĩnh vực (khi `domain` bị bỏ qua)
- `wiki/foundations/*.md` — để bỏ qua các khái niệm đã được gieo (bất biến)
- `.claude/skills/prefill/foundations-catalog.yaml` — danh sách gieo

### Ghi
- `wiki/foundations/{slug}.md` (chỉ mới — không bao giờ ghi đè)
- `wiki/index.md` (qua `tools/research_wiki.py rebuild-index`)
- `wiki/log.md` (qua `tools/research_wiki.py log`)

## Quy Trình Làm Việc

**Điều kiện tiên quyết**: thư mục làm việc chứa `wiki/`, `tools/`, `.claude/`. Đặt `WIKI_ROOT=wiki/`.

### Bước 1: Giải quyết lĩnh vực

1. Nếu đối số `domain` được cung cấp → sử dụng nó.
2. Nếu không, nếu chế độ `--add` → lĩnh vực là `general` trừ khi người dùng chỉ định.
3. Nếu không: đọc tất cả `tags` frontmatter của `wiki/topics/*.md`; nếu phát hiện một lĩnh vực chiếm ưu thế duy nhất, sử dụng nó; nếu không, hỏi người dùng.

### Bước 2: Tải các hạt giống

- **Chế độ danh mục**: đọc `.claude/skills/prefill/foundations-catalog.yaml`. Chọn tất cả các mục dưới `domains.{domain}` cộng với mọi thứ dưới `domains.general` (các foundations chung áp dụng cho mọi lĩnh vực nghiên cứu).
- **Chế độ `--add`**: tổng hợp một mục hạt giống duy nhất `{slug: <khái-niệm-đã-slugified>, title: <khái-niệm>, summary: ""}`. Sử dụng `python3 tools/research_wiki.py slug "<khái-niệm>"` để tạo slug.

Đối với mỗi hạt giống, kiểm tra `wiki/foundations/{slug}.md`. Nếu nó đã tồn tại, **bỏ qua** (không ghi đè, không cảnh báo).

### Bước 3: Lấy nền tảng từ Wikipedia

Đối với mỗi hạt giống còn lại, gọi `tools/fetch_wikipedia.py`:

```bash
python3 tools/fetch_wikipedia.py summary "<tiêu-đề>"
python3 tools/fetch_wikipedia.py sections "<tiêu-đề>"
python3 tools/fetch_wikipedia.py section "<tiêu-đề>" --index <N>   # cho các phần liên quan
```

- Cuộc gọi summary trả về `{title, extract, url}`.
- Cuộc gọi sections trả về danh sách `{index, line, level}` — chọn các phần có `line` khớp với `Variants`, `Types`, `Architecture`, `History`, `Limitations`, `Applications` (khớp chuỗi con không phân biệt chữ hoa chữ thường).
- Mã thoát `2` từ bất kỳ cuộc gọi nào có nghĩa là **không tìm thấy trang** — quay lại kiến thức LLM cho hạt giống đó và đặt `source_url: ""` trong frontmatter kết quả.

### Bước 4: Soạn trang foundation

Hiển thị mỗi hạt giống vào mẫu dưới đây. Phân biệt nội dung có nguồn gốc từ Wikipedia với nội dung do LLM cung cấp bằng cách thêm `(phân tích LLM)` vào các phần không có tài liệu nguồn Wikipedia.

```yaml
---
title: "{tiêu-đề}"
slug: "{slug}"
domain: "{lĩnh-vực}"
status: mainstream         # hoặc historical, nếu hạt giống là kỹ thuật đã bị thay thế
aliases: []                # liệt kê bất kỳ bí danh phổ biến nào mà LLM tự tin
first_introduced: "{năm nếu có trong tóm tắt Wikipedia, nếu không để trống}"
date_updated: "{hôm-nay}"
source_url: "{url wikipedia, hoặc trống nếu 404}"
---

## Định Nghĩa
{Đoạn đầu tiên của tóm tắt Wikipedia, hoặc định nghĩa do LLM cung cấp.}

## Trực Giác
{Giải thích bằng ngôn ngữ đơn giản được xây dựng trên định nghĩa.}

## Ký hiệu chính thức
{Toán/ký hiệu được trích xuất từ Wikipedia, hoặc do LLM cung cấp với thẻ `(phân tích LLM)`.}

## Các biến thể chính
{Danh sách gạch đầu dòng được chắt lọc từ các phần "Variants"/"Types"/"Architecture" của Wikipedia.}

## Các hạn chế đã biết
{Từ Wikipedia + đánh giá LLM.}

## Các vấn đề mở
{Phân tích LLM (phân tích LLM)}

## Mức độ liên quan đến nghiên cứu đang hoạt động
{Phân tích LLM (phân tích LLM)}
```

Ghi mỗi tệp vào `wiki/foundations/{slug}.md`.

### Bước 5: Làm mới điều hướng và nhật ký

```bash
python3 tools/research_wiki.py rebuild-index wiki/
python3 tools/research_wiki.py log wiki/ "prefill | {N} foundations được tạo cho {lĩnh-vực}"
```

### Bước 6: Báo cáo

In ra tóm tắt theo nhóm:

```
## Báo Cáo Prefill — {ngày}

**Lĩnh vực**: {lĩnh-vực}
**Đã tạo**: {N}  **Đã bỏ qua (đã có)**: {M}

### mainstream
- foundations/gradient-descent — Gradient Descent
- ...

### historical
- foundations/recurrent-neural-networks — Recurrent Neural Networks
```

Nhắc người dùng rằng các lần chạy `/ingest` tiếp theo sẽ loại bỏ trùng lặp với các foundations này và tạo wikilinks (`[[foundation-slug]]`) thay vì các trang khái niệm mới.

## Các Ràng Buộc

- **foundations là đầu cuối**: không bao giờ viết `key_papers`, `related_concepts` hoặc bất kỳ trường tham chiếu đi ra nào trên trang foundation. Các trang khác có thể liên kết vào.
- **không bao giờ ghi đè** một `wiki/foundations/{slug}.md` hiện có (chạy lại bất biến).
- **phân biệt nguồn**: nội dung có nguồn gốc từ Wikipedia so với nội dung có nguồn gốc từ LLM phải được phân biệt trực quan trong nội dung trang.
- **danh mục là tư vấn**: danh sách hạt giống YAML được tuyển chọn thủ công và không đầy đủ. Người dùng có thể mở rộng nó mà không cần thay đổi mã.
- **chỉ ghi vào `wiki/foundations/`**: không bao giờ tạo các trang dưới `papers/`, `concepts/`, `topics/`, v.v.

## Xử Lý Lỗi

- **`wiki/foundations/` không tồn tại**: chạy `python3 tools/research_wiki.py init wiki/` trước.
- **Wikipedia 404**: ghi lại trang thiếu, quay lại kiến thức LLM cho hạt giống đó (`source_url: ""`).
- **Lỗi mạng**: in ra hạt giống nào thất bại và tiếp tục với phần còn lại; không hủy bỏ toàn bộ lô.
- **Tệp danh mục thiếu**: in ra lỗi trỏ đến `.claude/skills/prefill/foundations-catalog.yaml`.

## Phụ Thuộc

### Công cụ (qua Bash)
- `python3 tools/fetch_wikipedia.py summary|sections|section|wikitext "<tiêu-đề>" [--index N]`
- `python3 tools/research_wiki.py slug "<tiêu-đề>"`
- `python3 tools/research_wiki.py rebuild-index wiki/`
- `python3 tools/research_wiki.py log wiki/ "<thông-điệp>"`

### Danh mục
- `.claude/skills/prefill/foundations-catalog.yaml`