---
name: create-ppt
description: Dựng file PowerPoint (.pptx) đẳng cấp từ một paper PDF — nhúng hình gốc + công thức render, có phân tích phản biện, qua QA trực quan; theo quy tắc trong docs/ppt-guide.vi.md
argument-hint: "<đường-dẫn-output-dir> [--from <paper.pdf|slug>] [--type seminar|talk|intro]"
---

# /create-ppt

> Dựng hoặc cập nhật một **file PowerPoint `.pptx` thật** trong `wiki/outputs/<deck-slug>/` từ một paper PDF (hoặc nguồn nội dung khác), build bằng **pptxgenjs**.
> Nguồn quy tắc duy nhất: **`docs/ppt-guide.vi.md`** — đọc đầy đủ trước khi build.
>
> Khác `/create-slides` (Reveal.js/Markdown trên Obsidian): kỹ năng này xuất file `.pptx` mở được bằng PowerPoint/Keynote, nhúng hình gốc của paper và công thức render từ LaTeX.

## Kích Hoạt

Lệnh thủ công: `/create-ppt <đường-dẫn-output-dir> [--from <nguồn>] [--type seminar|talk|intro]`

## Đầu Vào

- `<đường-dẫn-output-dir>` (bắt buộc): thư mục deck, ví dụ `wiki/outputs/dal-pinn-presentation/`. Mọi artefact (script, hình, công thức, `.pptx`) nằm gọn trong đây.
- `--from <nguồn>` (tùy chọn): nguồn nội dung — đường dẫn tới `raw/papers/<paper>.pdf`, một slug trang wiki, hoặc bỏ trống nếu người dùng mô tả trực tiếp.
- `--type <loại>` (tùy chọn):
  - `seminar` — deep-technical, đầy đủ derivation + mọi hình + phân tích phản biện (mặc định cho paper review)
  - `talk` — bài nói tổng quát, cân bằng trực giác/toán
  - `intro` — tổng quan, ít công thức
  - Bỏ trống → hỏi người dùng.

## Đầu Ra

- Thư mục deck `wiki/outputs/<deck-slug>/` chứa:
  - `build_deck.js` — script pptxgenjs (bản mẫu sống, tái dùng được)
  - `figures/` — hình crop 300 DPI từ paper + `figures/eq/` công thức render + `figures/dims.json`
  - `<Deck-Name>.pptx` — output cuối
- Cập nhật `wiki/index.md` nếu output nằm trong `wiki/outputs/`
- Append `wiki/log.md`: `## [{date}] create-ppt | <mô tả ngắn>`

## Tương Tác Wiki

### Đọc
- **Bắt buộc**: `docs/ppt-guide.vi.md` — nguồn quy tắc duy nhất; mở trước khi build.
- Tùy nguồn: `raw/papers/<paper>.pdf` hoặc trang wiki theo `--from`.

### Ghi
- Thư mục deck `wiki/outputs/<deck-slug>/`
- File tạm khi đọc paper → `raw/tmp/<slug>/` (chỉ thêm, không ghi đè input người dùng)
- `wiki/index.md` (nếu output thuộc danh mục) và `wiki/log.md` (append-only)

## Các Bước

### BƯỚC 1: Tải Quy Tắc & Hỏi Quyết Định

1. **Đọc `docs/ppt-guide.vi.md` đầy đủ** — không build khi chưa đọc lại guide trong session hiện tại.
2. Hỏi người dùng các quyết định bắt buộc (Section 1 của guide): **format, audience/độ sâu, độ dài, xử lý hình, phân tích phản biện, font, font công thức, palette màu**. Hỏi font + palette **ngay từ đầu** — đây là thứ dễ phải làm lại nhất.
3. Xác minh toolchain (Section 2): PyMuPDF, matplotlib, pptxgenjs (cài local), `soffice`. Kiểm tra font cần dùng bằng `fc-list | grep -i <font>`.

### BƯỚC 2: Đọc Paper & "Nhìn" Hình

Theo Section 4 của guide:
1. Render mọi trang PDF ra ảnh (PyMuPDF, ~110 DPI) và **đọc (Read) các trang có hình** bằng vision để xác nhận nội dung từng figure.
2. Trích full text (`page.get_text()`) để nắm chi tiết kỹ thuật, số liệu, công thức.
3. **Không bịa**: số liệu/bảng/citation phải lấy đúng từ paper.

### BƯỚC 3: Crop Hình & Render Công Thức

1. Crop từng figure ở 300 DPI theo bbox caption (Section 4) → đặt tên mô tả (`fig1_architecture.png`…) → **Read lại vài hình** kiểm tra không cụt/lệch.
2. Render công thức từ LaTeX → PNG trong suốt bằng matplotlib (Section 5); dùng `mathtext.fontset` theo lựa chọn font công thức; lưu ý `\left|\right|` thay `\big`.
3. Xuất `figures/dims.json` (kích thước mọi PNG) để giữ tỷ lệ khi nhúng.

### BƯỚC 4: Viết `build_deck.js`

Theo Section 6–7 của guide:
1. Định nghĩa **palette thành hằng số, gán theo vai trò**; chọn font (sans cho chữ, serif math cho công thức, mono cho code).
2. Dựng các **helper dùng lại**: `head`, `footer`, `divider`, `card`, `bullets`, `fitImg` (giữ tỷ lệ qua `dims.json`), `caption`, factory `sh()` cho shadow.
3. **Nền sáng** cho mọi slide (trừ khi người dùng yêu cầu khác); slide đặc biệt thêm **dải dọc accent** bên trái.
4. Dựng nội dung theo **khung 5 phần**: Motivation → Method → Architecture → Experiments → Discussion. Mỗi slide 1 ý chính; tiêu đề ngắn gọn chuyên nghiệp (tránh động từ mạnh/khẩu ngữ).
5. Tuân thủ **bẫy pptxgenjs** (Section 9): hex không `#`, không hex 8 ký tự; bullet thật; factory shadow; cài local.

### BƯỚC 5: Build & QA Loop (bắt buộc ≥ 1 vòng)

Theo Section 8 của guide:
1. `node build_deck.js` → `.pptx`.
2. `soffice --headless --convert-to pdf` → dùng PyMuPDF render PDF ra PNG (không cần `pdftoppm`).
3. **QA bằng subagent (con mắt mới)** — chia 2 nhóm slide, prompt yêu cầu *giả định có lỗi*: tràn/đè/tương phản/caption đè footer/bảng cụt. Khi đổi theme: hỏi thêm "còn sót màu theme cũ không?".
4. Sửa lỗi → **render lại slide đã sửa để xác minh**. Lưu ý: báo cáo "nội dung nén/hình nhỏ" của subagent thường là ảo giác do render 100 DPI → render lại 140 DPI và tự Read trước khi sửa.
5. Content QA: `python -m markitdown <Deck>.pptx | grep -iE "xxxx|lorem|undefined|TODO"` phải rỗng.

### BƯỚC 6: Self-Review theo Checklist Section 11

Đối chiếu từng item trong Section 11 của guide (hình & công thức · design & layout · nội dung & xác thực). Item nào không đạt → sửa trước khi báo cáo.

### BƯỚC 7: Cập Nhật Điều Hướng & Log

1. Nếu output nằm trong `wiki/outputs/`, thêm mục vào `wiki/index.md` dưới danh mục `Outputs` (xem `docs/runtime-support-files.vi.md`).
2. Append `wiki/log.md`: `## [{YYYY-MM-DD}] create-ppt | <mô tả ngắn>`.
3. **Không chạm `graph/`**.

### BƯỚC 8: Báo Cáo

- Liệt kê: đường dẫn `.pptx`, số slide, loại, nguồn, số hình đã nhúng.
- Tóm tắt 1–2 dòng nội dung chính.
- Nhắc người dùng mở bằng PowerPoint/Keynote; bản PDF QA nằm trong thư mục deck nếu muốn xem nhanh.

## Các Ràng Buộc

- **`docs/ppt-guide.vi.md` là nguồn quy tắc duy nhất** — mọi quyết định format/design/QA tra cứu từ đó; không tự chế thêm.
- **Không bịa nội dung**: số liệu/citation lấy từ paper; thiếu thì bỏ hoặc đánh dấu giả định.
- **Hình gốc của paper nhúng nguyên bản** — không vẽ lại, không bịa biểu đồ.
- **Công thức render từ LaTeX** (PowerPoint không có LaTeX) — không gõ ký hiệu toán bằng text thường.
- **`raw/` thuộc sở hữu người dùng**: chỉ thêm file tạm vào `raw/tmp/`, không ghi đè input.
- **QA loop bắt buộc** — không báo cáo hoàn tất khi chưa qua ≥ 1 vòng QA subagent + sửa + render lại xác minh.
- **Không ghi đè deck `.pptx` hiện có** không do kỹ năng này sinh ra mà chưa xác nhận với người dùng.
- **Không chỉnh sửa `graph/`**; cập nhật `index.md` và append `log.md`.

## Tham Khảo

- `docs/ppt-guide.vi.md` — quy tắc đầy đủ: toolchain, crop hình, render công thức, design system, khung nội dung, QA loop, bẫy pptxgenjs, checklist
- `skills/create-ppt/references/build_deck.template.js` — khung pptxgenjs sẵn dùng (palette + helper `head/footer/divider/card/bullets/fitImg/caption` + factory shadow). Copy vào thư mục deck, đổi palette/nội dung rồi `node build_deck.js`
- `docs/runtime-support-files.vi.md` — định dạng `index.md` / `log.md` khi cập nhật điều hướng
- pptxgenjs: <https://github.com/gitbrent/PptxGenJS>
- So sánh: `/create-slides` cho output Reveal.js/Markdown (Obsidian); `/create-ppt` cho file `.pptx` thật
