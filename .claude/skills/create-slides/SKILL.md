---
name: create-slides
description: Soạn slides Reveal.js (Obsidian + obsidian-advanced-slides) theo quy tắc format, văn phong và sourcing trong docs/slides-guide.vi.md
argument-hint: "<đường-dẫn-output> [--from <nguồn>] [--type paper-review|ideas|results|talk]"
---

# /create-slides

> Soạn hoặc cập nhật một file slides Markdown trong `wiki/outputs/` theo bộ quy tắc thống nhất ở `docs/slides-guide.vi.md`.
> Engine mặc định: **Obsidian + plugin [`obsidian-advanced-slides`](https://github.com/MSzturc/obsidian-advanced-slides)** (Reveal.js dưới nền).

## Kích Hoạt

Lệnh thủ công: `/create-slides <đường-dẫn-output> [--from <nguồn>] [--type <loại-slide>]`

## Đầu Vào

- `<đường-dẫn-output>` (bắt buộc): đường dẫn file slides cần tạo / cập nhật, ví dụ `wiki/outputs/my-talk-slides.md`
- `--from <nguồn>` (tùy chọn): nguồn nội dung để dựng slides. Có thể là:
  - Slug hoặc đường dẫn tới một trang trong wiki (`papers/`, `topics/`, `Summary/`, `experiments/`, `claims/`, `ideas/`)
  - Đường dẫn tới file note thô đã có sẵn
  - Danh sách slug phân cách bằng dấu phẩy khi tổng hợp nhiều nguồn
  - Bỏ trống nếu người dùng sẽ mô tả nội dung trực tiếp trong yêu cầu
- `--type <loại-slide>` (tùy chọn): loại trình bày để chọn pattern phù hợp. Các giá trị hỗ trợ:
  - `paper-review` — related work / literature survey nhiều papers (mặc định flow 3 lớp Section 7.1)
  - `ideas` — đề xuất ý tưởng / phương pháp (pattern Lý thuyết → Lý do xây dựng Section 7.2)
  - `results` — báo cáo kết quả thí nghiệm (slide kết quả/dữ liệu Section 7)
  - `talk` — bài nói tổng hợp / research summary (kết hợp nhiều pattern)
  - Bỏ trống → tự xác định từ nội dung hoặc hỏi người dùng

## Đầu Ra

- File slides Markdown tại `<đường-dẫn-output>` với:
  - Frontmatter YAML cấu hình Reveal.js + `<style>` block căn trái
  - Slide tiêu đề, các slide nội dung phân cấp đúng quy tắc, slide kết thúc
  - Equation, bảng, hình ảnh, references theo quy tắc trong guide
- Cập nhật `wiki/index.md` nếu output nằm trong `wiki/outputs/`
- Append `wiki/log.md`: `## [{date}] create-slides | <mô tả ngắn>`

## Tương Tác Wiki

### Đọc
- Bắt buộc: `docs/slides-guide.vi.md` — nguồn quy tắc duy nhất; mở trước khi viết bất kỳ slide nào
- Tùy nguồn: các trang trong `wiki/` được người dùng chỉ định qua `--from`
- Tùy chọn: `docs/runtime-page-templates.vi.md` nếu output là trang wiki khác ngoài `outputs/`

### Ghi
- `<đường-dẫn-output>` (file slides mới hoặc đã cập nhật)
- `wiki/index.md` (nếu output thuộc danh mục được liệt kê)
- `wiki/log.md` (append-only)

## Các Bước

### BƯỚC 1: Tải Quy Tắc & Xác Định Phạm Vi

1. **Đọc `docs/slides-guide.vi.md` đầy đủ** — đây là nguồn duy nhất cho mọi quy tắc format, văn phong, sourcing, pattern slide. Không viết slide khi chưa đọc lại guide trong session hiện tại.
2. Xác định:
   - Loại slide (`--type` hoặc suy luận từ yêu cầu)
   - Ngôn ngữ chính (VI / EN) — nhất quán toàn file
   - Số slide ước tính & flow chính
3. Nếu thiếu thông tin chủ đề / scope, **hỏi người dùng trước khi soạn**; không bịa nội dung.

### BƯỚC 2: Thu Thập Nội Dung Có Nguồn

1. Với mỗi nguồn trong `--from`, đọc trang đó để lấy:
   - Tiêu đề chuẩn, venue / year, importance score
   - Phương pháp cốt lõi, công thức quan trọng, kết quả định lượng
   - Slug để dẫn nguồn cuối slide
2. Phân loại mọi tuyên bố sẽ đưa lên slide theo Section 7.3 của guide:
   - **Fact có nguồn** — phải kèm slug/citation/link
   - **Quan sát thực nghiệm** — phải kèm slug experiment + seed + metric
   - **Giả thuyết** — phải đánh dấu rõ bằng từ ngữ giả định
3. **Không bịa số liệu, citation, hay claim**. Nếu nguồn không có thông tin cần thiết, viết câu dưới dạng giả thuyết hoặc bỏ qua.

### BƯỚC 3: Dựng Khung Slide

Áp dụng pattern phù hợp với `--type` theo `docs/slides-guide.vi.md`:

- **`paper-review`** → flow 3 lớp ở Section 7.1: slide overview chủ đề → mỗi paper một slide (header / phương pháp / kết quả / Ref) → slide tổng kết & gap.
- **`ideas`** → pattern Section 7.2: slide overview bảng → mỗi ý tưởng một slide (Lý thuyết → Lý do xây dựng).
- **`results`** → pattern Section 7 "Slide kết quả / dữ liệu" với layout hai cột bảng metric + hình.
- **`talk`** → kết hợp: title → motivation → related work (paper-review) → contributions (ideas) → results → kết luận.

Luôn dựng:
1. Slide title (H1 + subtitle + tác giả · date)
2. Slide mục lục (nếu nhiều phần)
3. Các phần (H1) chứa các slide nội dung (H2)
4. Slide kết / Q&A / references tổng

### BƯỚC 4: Viết Slides Tuân Thủ Guide

Mỗi slide phải qua các quy tắc sau (đối chiếu lại với guide khi cần):

1. **Frontmatter** (Section 1): YAML + `<style>` block; `center: false`, `text-align: left`, font sizes theo guide.
2. **Phân cấp** (Section 2): H1 mở phần, H2 cho slide nội dung, H3 cho sub-heading, `---` giữa slides.
3. **Hai cột** (Section 3): `<split even gap="2">` với `<div>` cho text, ảnh đặt ngoài `<div>`.
4. **Bảng** (Section 4): căn chỉnh `:---:` / `---:`, in đậm hàng quan trọng, `<small>` cho bảng phụ.
5. **Equation** (Section 5):
   - Chỉ `$$...$$` (block) và `$...$` (inline); cấm môi trường LaTeX
   - Số mũ trong `{}`: `x^{2}`, `\nabla^{2}`, `10^{-3}`
   - Subscripts multi-char trong `{}`: `\mathcal{L}_{\mathrm{total}}`
   - Subscripts single-char (`\mu_1`, `K_2`) giữ nguyên
   - `\mathrm{}` cho chữ trong math; `\|...\|` cho norm; `\cdot` cho dấu nhân
   - **Block equation đứng riêng phải căn giữa** khi preview: bọc `<div style="text-align: center;">` cho per-equation, hoặc thêm CSS rule chung cho toàn file
6. **Hình ảnh** (Section 6): Obsidian syntax `![[path|widthxheight]]`; luôn chỉ định kích thước.
7. **Văn phong** (Section 7):
   - Câu từ chuyên nghiệp, trung lập, không gãy gọn quá mức, đọc trôi chảy
   - Tránh giọng quảng cáo, mệnh lệnh, cảm thán, viết tắt phi chuẩn
   - In đậm cho tên / metrics / từ khóa; `—`, `→`, `·` đúng ngữ cảnh
8. **Sourcing** (Section 7.3):
   - Mỗi fact phải có nguồn chính thống (peer-reviewed / official doc / experiment có log)
   - Không dẫn blog / tweet / AI-generated chưa kiểm chứng
   - Mỗi con số đi kèm metric / baseline / dataset / slug
   - Đánh dấu rõ giả thuyết ("có thể", "kỳ vọng", "giả thuyết")
9. **Chú thích** (Section 8): `<small>Ref: slug-a · slug-b</small>` cuối slide khi dùng nguồn ngoài.

### BƯỚC 5: Self-Review theo Checklist Section 11

Trước khi báo cáo hoàn tất, đối chiếu từng item trong checklist của Section 11 — chia hai nhóm:

**Format & văn phong:**
- [ ] Frontmatter đầy đủ + `<style>` căn trái + `center: false`
- [ ] H1 chỉ cho slide mở đầu phần; `---` có dòng trống trước/sau
- [ ] Ảnh có `|widthxheight`; bảng có alignment markers khi cần
- [ ] Equation dùng `$$...$$` / `$...$`; số mũ `^{}`; subscripts multi-char `_{}`
- [ ] Block equation đứng riêng được căn giữa (cách 1 hoặc cách 2)
- [ ] Chú thích nguồn cuối slide bằng `<small>`
- [ ] Văn phong chuyên nghiệp, trung lập, đọc trôi chảy
- [ ] Một ngôn ngữ nhất quán; nội dung không tràn slide

**Sourcing & tính xác thực:**
- [ ] Mọi fact có nguồn; không dẫn blog / tweet / áng chừng
- [ ] Giả thuyết được đánh dấu rõ
- [ ] Quan sát thực nghiệm kèm slug experiment + seed + metric
- [ ] Mỗi con số có ngữ cảnh đầy đủ (metric / baseline / dataset / nguồn)
- [ ] Không trộn fact + giả thuyết trong cùng một câu
- [ ] References cuối slide đúng format
- [ ] Claim từ literature kèm conf nếu có

Nếu có item nào không đạt → sửa slide trước khi báo cáo.

### BƯỚC 6: Cập Nhật Điều Hướng & Log

1. Nếu output nằm trong `wiki/outputs/`, thêm mục vào `wiki/index.md` dưới danh mục `Outputs`. Xem `docs/runtime-support-files.vi.md` cho định dạng chính xác.
2. Append `wiki/log.md`:
   ```markdown
   ## [{YYYY-MM-DD}] create-slides | <mô tả ngắn nội dung slides>
   ```
3. **Không chạm vào `graph/`**.

### BƯỚC 7: Báo Cáo

- Liệt kê: đường dẫn file, số slide, loại slide, nguồn đã dùng
- Tóm tắt 1–2 dòng nội dung chính
- Nhắc người dùng mở bằng `obsidian-advanced-slides` để preview, kiểm tra trực quan equation căn giữa và layout cột

## Các Ràng Buộc

- **`docs/slides-guide.vi.md` là nguồn quy tắc duy nhất** — mọi quyết định format / văn phong / sourcing phải tra cứu từ đó; không tự ý chế thêm quy tắc mới.
- **Không bịa nội dung**: nguồn không có thì không viết; nếu cần claim chưa có nguồn, đánh dấu giả thuyết theo Section 7.3.
- **Không dùng môi trường LaTeX** (`\begin{equation}`, `\begin{align}`) — MathJax trên Reveal.js không hỗ trợ ổn định.
- **Số mũ luôn bọc `{}`**: `x^{2}`, không `x^2`; subscripts multi-char bọc `{}`; subscripts single-char để nguyên.
- **Block equation đứng riêng phải căn giữa** khi preview (theo guide Section 5).
- **Một ngôn ngữ chính** xuyên suốt file; thuật ngữ kỹ thuật đã chuẩn hóa có thể giữ nguyên tiếng Anh.
- **Sourcing bắt buộc**: tuân thủ checklist Section 11 phần "Sourcing & tính xác thực" trước khi báo cáo hoàn tất.
- **Không chỉnh sửa `graph/`**; cập nhật `index.md` và append `log.md`.
- **Không ghi đè file slides hiện có** mà không xác nhận với người dùng nếu nội dung cũ không phải do kỹ năng này sinh ra.

## Tham Khảo

- `docs/slides-guide.vi.md` — quy tắc đầy đủ: frontmatter, phân cấp, hai cột, bảng, equation, hình, văn phong, sourcing, checklist
- Plugin engine: [`obsidian-advanced-slides`](https://github.com/MSzturc/obsidian-advanced-slides)
- `docs/runtime-page-templates.vi.md` — quy tắc Markdown chung khi cần đối chiếu equation cho non-slide pages
- `docs/runtime-support-files.vi.md` — định dạng `index.md` / `log.md` khi cập nhật điều hướng
