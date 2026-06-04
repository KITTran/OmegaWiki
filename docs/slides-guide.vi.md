# Hướng dẫn làm Slides: Format, Phong cách & Quy tắc

> Hướng dẫn tổng quát cho việc soạn thảo slides Reveal.js trong wiki.
> Áp dụng được cho mọi loại trình bày: research summary, paper presentation, technical talk, teaching, project review.
> **Engine mặc định**: Obsidian + plugin [`obsidian-advanced-slides`](https://github.com/MSzturc/obsidian-advanced-slides) (Reveal.js dưới nền).

---

## 1. Cấu trúc Frontmatter (YAML + CSS)

Mỗi file slides bắt đầu bằng frontmatter YAML cấu hình Reveal.js, theo sau là `<style>` block:

```yaml
---
theme: black            # hoặc white, league, beige, sky, night, serif, simple, solarized
transition: slide       # hoặc fade, convex, concave, zoom, none
width: 1280
height: 800
center: false           # căn trái mặc định
controls: true
progress: true
css: |
  .reveal { font-size: 22px; }
  .reveal h1 { font-size: 1.8em; }
  .reveal h2 { font-size: 1.4em; }
  .reveal h3 { font-size: 1.1em; }
  .reveal table { font-size: 0.75em; }
  .reveal table th, .reveal table td { padding: 4px 8px; }
  .reveal p, .reveal li { font-size: 0.85em; line-height: 1.3; }
  .reveal code { font-size: 0.85em; }
  .reveal pre { font-size: 0.7em; }
  .reveal .MathJax, .reveal mjx-container { font-size: 0.9em !important; }
---
```

**Sau frontmatter**, thêm `<style>` block riêng để ghi đè thêm:

```html
<style>
.reveal .slides section { text-align: left; }
.reveal .slides > section,
.reveal .slides > section > section { top: 0 !important; padding-top: 30px; }
</style>
```

**Nguyên tắc chính:**
- **`center: false`** + **`text-align: left`** — slides căn trái, đọc tự nhiên
- **Font chữ tham khảo**: base 22px (slide-heavy content), H1 ~1.8em, H2 ~1.4em, H3 ~1.1em — điều chỉnh theo độ dày nội dung
- **Bảng**: nhỏ hơn nội dung chính ~0.75em, cell padding 4px 8px
- **Math**: ~0.9em (hơi nhỏ hơn text để không vỡ dòng)
- **`!important`** cho các thuộc tính hay bị Reveal.js ghi đè (padding, top, font-size MathJax)

**Khi nào điều chỉnh size**: slide ít chữ → font lớn hơn (28-32px); slide kiểu lecture (text-heavy) → giữ 22px như trên.

---

## 2. Phân cấp Slide

### Slide tiêu đề toàn trình bày — dùng `#` ở đầu file

```markdown
# Tiêu đề presentation

## Subtitle hoặc chủ đề con

**Tên tác giả** · Date

Mô tả ngắn (vd: số papers, số experiments, scope)
```

### Slide tiêu đề phần — dùng `#` (H1)

```markdown
# I. Phần một
```

Dùng số La Mã, số thứ tự hoặc tiêu đề rõ ràng để đánh dấu phần lớn. Chỉ H1 cho slide mở đầu một phần.

### Slide nội dung — dùng `##` (H2)

```markdown
## Tiêu đề slide
```

### Sub-heading trong slide — dùng `###` (H3)

```markdown
### Nhóm con trong slide
```

### Phân cách slide — `---` (ba dash)

Một dòng `---` riêng tạo ra slide mới. Để dòng trống trước và sau để tránh nhầm với separator của bảng/list.

---

## 3. Bố cục hai cột

Dùng thẻ `<split>` tùy chỉnh với hai `<div>` con:

```markdown
<split even gap="2">

<div>

Nội dung cột trái...

</div>

![[path/to/image.png|widthxheight]]

</split>
```

**Quy tắc:**
- `even` — chia đều không gian; có thể đổi tỉ lệ với `<split left="60" right="40">`
- `gap="2"` — khoảng cách giữa hai cột (đơn vị em)
- Cột trái: text/mô tả; cột phải: hình ảnh, bảng, hoặc text tóm tắt
- Luôn đặt nội dung text trong `<div>`; ảnh có thể đặt ngoài `<div>` (cột phải tự động)
- Tránh nhồi >5 bullet points vào một cột — chia slide nếu quá đông

---

## 4. Bảng biểu

### Quy tắc căn chỉnh chung

```markdown
| Col1 | Col2 | Col3 |
|---|:---:|---:|
| left-aligned | center | right-aligned |
```

- `---` → căn trái (mặc định)
- `:---:` → căn giữa (dùng cho cột giá trị nhỏ, label)
- `---:` → căn phải (dùng cho cột số)

### Nhấn mạnh trong bảng

- **In đậm** cho: hàng tốt nhất / baseline, giá trị quan trọng, tên nổi bật
- Dùng `—` cho ô không có / baseline tham chiếu
- Dùng `−` (minus sign Unicode) thay vì `-` cho số âm
- Đánh số `**1**`, `**2**` cho ranking
- *In nghiêng* để chú thích phụ (vd: `kan-single *(baseline)*`)

### Kích thước bảng

- Bảng quá rộng → giảm số cột, gộp metric, hoặc chia thành 2 bảng
- Bảng quá nhiều hàng (>10) → cân nhắc chia slide hoặc dùng `<small>` cho bảng phụ
- Header bảng nên ngắn — tránh hơn 2-3 từ

---

## 5. Viết phương trình Toán

### Công thức inline và block

```markdown
Inline: $f(x) = x^{2}$ trong câu văn.

Block standalone:
$$\mathcal{L} = w_1 \mathcal{L}_1 + w_2 \mathcal{L}_2$$
```

### Các ký hiệu thường dùng

| Ký hiệu | Code | Ý nghĩa |
|---------|------|---------|
| $\mathcal{L}$ | `\mathcal{L}` | Loss / Lagrangian (calligraphic) |
| $\mathbb{E}$ | `\mathbb{E}` | Kỳ vọng (blackboard bold) |
| $\mathcal{N}$ | `\mathcal{N}` | Phân phối chuẩn |
| $\mathcal{O}$ | `\mathcal{O}` | Big-O notation |
| $\nabla$ | `\nabla` | Gradient |
| $\partial$ | `\partial` | Đạo hàm riêng |
| $\|A\|$ | `\|A\|` | Norm (double pipe) |
| $\|A\|^{2}$ | `\|A\|^{2}` | Bình phương norm |
| $\propto$ | `\propto` | Tỉ lệ với |
| $\mathrm{Tr}(K)$ | `\mathrm{Tr}(K)` | Trace, viết roman |
| $\mathrm{MSE}$ | `\mathrm{MSE}` | Tên hàm viết tắt |
| $\cdot$ | `\cdot` | Dấu nhân |
| $\mapsto$ | `\mapsto` | Ánh xạ |
| $\to$ | `\to` | Tới / suy ra |
| $\approx$ | `\approx` | Xấp xỉ |
| $\sim$ | `\sim` | Phân phối theo / cùng bậc |
| $\gg$ | `\gg` | Lớn hơn nhiều |

### Quy tắc viết equation

- **Block formula** (`$$...$$`) cho công thức quan trọng cần nổi bật; **inline** (`$...$`) cho ký hiệu/biểu thức ngắn xen trong câu
- **Chỉ dùng `$$...$$`** — không dùng môi trường LaTeX (`\begin{equation}`, `\begin{align}`); MathJax trên Reveal.js không hỗ trợ ổn định
- Giữ công thức **đủ ngắn để nằm gọn một dòng** — slide không phải paper
- Dùng `\cdot` thay vì `*`
- Dùng `\|` cho double-bar norm, **không** dùng `||`
- Dùng `\mathrm{}` cho chữ trong math: `\mathrm{MSE}`, `\mathrm{PDE}`, `\mathrm{Tr}`
- **Số mũ phải để trong `{}`**: equations có dạng `$<operator>^<số>$` thì `<số>` phải đặt trong `{}`
  - Đúng: `x^{2}`, `\nabla^{2}`, `N^{2}`, `L^{2}`, `[0,1]^{2}`, `10^{-3}`
  - Sai: `x^2`, `\nabla^2`, `N^2`, `10^-3`
  - Áp dụng cho cả single character (`^{2}`) lẫn multi-character (`^{ij}`, `^{-1}`)
  - Subscripts single-char (`\mu_1`, `K_2`, `J_0`) giữ nguyên không cần bọc `{}`
- Subscripts multi-char hoặc chứa ký tự đặc biệt phải bọc `{}`: `\mathcal{L}_{\mathrm{total}}`, `x_{i,j}`

### Equation đứng riêng phải căn giữa khi preview

Slides dùng `text-align: left` cho toàn bộ nội dung (theo Section 1) — nhưng **block equation `$$...$$` đứng riêng phải căn giữa** khi preview để equation trở thành tâm điểm thị giác, đọc thoáng và nổi bật. Đây là quy ước riêng cho equation, không xung đột với rule căn trái của text.

Vì `obsidian-advanced-slides` kế thừa `text-align: left` từ section CSS, mặc định block math sẽ căn trái. Để buộc căn giữa, dùng một trong hai cách:

**Cách 1 — bọc trong `<div>` căn giữa (khuyến nghị, ổn định nhất):**

```markdown
<div style="text-align: center;">

$$\mathcal{L}_\mathrm{total} = w_\mathrm{pde}\mathcal{L}_\mathrm{pde} + w_\mathrm{bc}\mathcal{L}_\mathrm{bc}$$

</div>
```

**Cách 2 — thêm CSS rule chung trong `<style>` block ở đầu file** (áp dụng cho mọi block math trong file):

```css
.reveal .slides section .math.math-display,
.reveal .slides section mjx-container[display="true"],
.reveal .slides section p:has(> mjx-container[display="true"]) {
  text-align: center !important;
}
```

Chọn cách 2 nếu file có nhiều block equation và muốn áp dụng đồng nhất; chọn cách 1 cho từng equation cụ thể nếu chỉ vài chỗ cần căn giữa.

**Quy tắc áp dụng:**
- Block equation `$$...$$` **đứng riêng trên dòng riêng** (không xen trong bullet) → **căn giữa**
- Inline equation `$...$` → giữ inline trong câu, không tách dòng, không căn giữa
- Block equation nằm trong bullet point → giữ căn trái theo bullet (tránh phá vỡ layout list)
- Equation đi kèm caption/label → bọc cả equation và caption vào cùng `<div style="text-align: center;">`

---

## 6. Hình ảnh

### Cú pháp Obsidian-style

```markdown
![[path/to/image.png|widthxheight]]
```

- Đường dẫn tương đối từ thư mục chứa file slides
- Kích thước chỉ định bằng pixel: `|520x440`
- Có thể chỉ định một chiều: `|520` (giữ aspect ratio)

### Kích thước tham khảo

- **Cột split**: 420–520px ngang × 340–440px cao
- **Toàn màn hình** (full-width): 800–900px ngang
- **Diagram nhỏ inline**: 300–400px ngang

### Khi nào dùng ảnh

Quy tắc chung: một ảnh phải truyền tải ý không thể nói bằng text trong cùng diện tích.
- Comparison plots, diagram kiến trúc, sơ đồ pipeline
- Bản đồ/heatmap dữ liệu không gian
- Bar/line charts so sánh metrics
- Screenshots cho UI/UX presentation

Tránh dùng ảnh chỉ để trang trí — slides căn trái với theme tối đã đủ chuyên nghiệp.

---

## 7. Phong cách viết

### Ngôn ngữ

- Tiếng Việt làm ngôn ngữ chính (nếu audience VN); chọn ngôn ngữ chính nhất quán toàn slide
- **Giữ nguyên thuật ngữ kỹ thuật tiếng Anh** khi đã chuẩn hóa trong lĩnh vực (vd: "loss function", "gradient descent", "API", "framework")
- Không dịch nửa vời — chọn dịch hoàn toàn hoặc giữ nguyên cả cụm
- Dấu ngoặc kép `""` cho trích dẫn, `''` cho khái niệm/nhãn

### Văn phong

- **Câu từ chuyên nghiệp, trung lập, không bị gãy gọn quá mức, đọc phải mượt**
  - Tránh cụm telegraphic kiểu "X tốt. Y tệ." — viết "X cho kết quả tốt hơn Y trong điều kiện ..."
  - Tránh giọng quảng cáo ("đột phá", "tuyệt vời", "siêu nhanh") — dùng mô tả khách quan có số liệu
  - Tránh viết tắt phi chuẩn / từ lóng trong văn phong (vd: "ko", "vs.", "etc")
  - Tránh câu mệnh lệnh hoặc cảm thán — slide kỹ thuật, không phải marketing
  - Bullet vẫn được phép ngắn, nhưng từng bullet nên đọc trôi chảy như mệnh đề, không phải fragment cụt
- **Bullet points ngắn**, không viết câu dài lê thê — vẫn cần đủ chủ ngữ-vị ngữ để đọc tự nhiên
- **Mỗi dòng một ý** — nếu phải xuống dòng nhiều, có thể nên tách bullet
- **In đậm** (`**text**`) cho:
  - Tên (paper, người, công cụ, phương pháp)
  - Giá trị số/metrics quan trọng
  - Kết luận / từ khóa cần nhấn mạnh
- Dùng `—` (em dash) hoặc `:` để giải thích / mở rộng
- Dùng `→` (mũi tên) cho "dẫn đến", "cho thấy", "tiến tới"
- Dùng `·` (middle dot) làm phân cách nhẹ giữa các item ngắn

### Cấu trúc slide phổ biến

**Slide khái niệm / lý thuyết**

```markdown
## Tên ý tưởng

**Định nghĩa / Lý thuyết**

Mô tả ngắn gọn...
$$công thức nếu có$$

**Lý do quan trọng** (hoặc "Tại sao chọn")

- Lý do 1
- Lý do 2

**Triển khai / Áp dụng**

Mô tả ngắn cách dùng / pipeline.
```

**Slide kết quả / dữ liệu**

```markdown
## Tên thí nghiệm / kết quả

<split even gap="2">

<div>

### Metrics

| Metric | Value |
|---|---|
| Accuracy | **95.2%** |
| Latency | 12 ms |

**Phân tích ngắn**

Nguyên nhân chính, nhận xét.

</div>

![[image.png|520x440]]

</split>
```

**Slide so sánh / overview**

```markdown
## Tên chủ đề

**Vấn đề chung**: mô tả ngắn

| Mục | Đóng góp | Imp |
|---|---|:---:|
| Item A | ... | **5** |
| Item B | ... | 4 |
```

---

## 7.1 Pattern trình bày Paper Review / Literature Survey

Khi trình bày nhiều papers (related work, survey, literature review), dùng flow ba lớp: **Chủ đề overview → Paper detail → Tổng kết**. Tránh nhồi nhiều paper vào một bảng — mỗi paper xứng đáng một slide riêng để người nghe theo kịp.

### Flow tổng thể

```
Chủ đề N — Tên chủ đề              ← 1 slide overview
├── N.1 Paper A — slogan ngắn      ← 1 slide / paper
├── N.2 Paper B — slogan ngắn      ← 1 slide / paper
└── N.3 Paper C — slogan ngắn      ← 1 slide / paper
Tổng kết related work              ← 1 slide kết phần
```

### Slide overview chủ đề

Mở đầu mỗi nhóm papers — nêu vấn đề chung, đánh đổi, và danh sách papers sẽ trình bày tiếp theo.

```markdown
## Chủ đề N — Tên chủ đề

**Vấn đề chung**: mô tả ngắn vấn đề mà nhóm papers này giải quyết

**Đánh đổi**: nêu trade-off chung của hướng tiếp cận (nếu có)

**N paper tiêu biểu**

- Paper A (Venue Year, Imp **5**) — đóng góp một câu
- Paper B (Venue Year, Imp **4**) — đóng góp một câu
- Paper C (Venue Year, Imp **4**) — đóng góp một câu
```

**Quy tắc:**
- Tiêu đề dùng dấu `—` (em dash) để tách số chủ đề và tên: `## Chủ đề 2 — Ổn định huấn luyện`
- Liệt kê 2–4 paper / chủ đề; nhiều hơn nên chia thành chủ đề nhỏ
- Mỗi paper một bullet — không nhồi metadata thừa

### Slide chi tiết từng paper

Đây là pattern cốt lõi cho mỗi paper. Cấu trúc 4 khối: **Header → Phương pháp → Kết quả chính → Ref**.

```markdown
## N.X Tên-rút-gọn — slogan một câu

**Paper**: *Tiêu đề đầy đủ* (Venue Year, Tác giả nếu cần) · Imp **5** · metadata phụ

**Phương pháp**
- Ý tưởng cốt lõi (1 câu / bullet)
- Công thức quan trọng nếu cần:

$$\text{block math standalone}$$

- Thành phần phụ / kiến trúc / pipeline
- Đặc trưng nổi bật khác

**Kết quả chính** (kèm benchmark / dataset)
- Metric chính kèm con số cụ thể và **in đậm**
- Ví dụ điển hình minh họa độ mạnh
- Hạn chế / điều kiện áp dụng (nếu cần cân bằng)

<small>Ref: `slug-paper-trong-wiki`</small>
```

**Quy tắc:**
- Tiêu đề slide: `## <số>.<số> <Tên rút gọn> — <slogan>` (vd: `## 2.1 NTK PINN — chẩn đoán thất bại huấn luyện`)
- Slogan ngắn (3–7 từ) nêu **góc nhìn** của paper, không lặp lại tên
- Dòng `**Paper**:` đầu slide: in nghiêng tiêu đề + venue/year + importance score + citations/conf nếu nổi bật
- **Phương pháp**: 3–5 bullet, ưu tiên ý tưởng cốt lõi và 1 công thức quan trọng (không quá 1 block math / slide)
- **Kết quả chính**: phải có **con số cụ thể**, không nói chung chung ("cải thiện đáng kể" → "giảm $L^{2}$ từ X xuống Y")
- Có thể dùng bảng metric thay bullet nếu dữ liệu nhiều chiều (vd: I-PINNs với 4 benchmark)
- Cuối slide luôn có `<small>Ref: ...</small>` trỏ về slug paper trong wiki

### Slide tổng kết related work

Đặt ở cuối phần related work để chốt lại bức tranh toàn cảnh trước khi sang phần tiếp theo.

```markdown
## Tổng kết related work & khoảng trống

**N paper đã trình bày** — phân theo M chủ đề

| Chủ đề | Papers | Đóng góp chính |
|---|---|---|
| **1. Tên chủ đề** | Paper A (5), Paper B (4) | Đóng góp tổng hợp |
| **2. ...** | ... | ... |

**Khoảng trống nghiên cứu chính**
- Gap 1 — chưa có lời giải tổng quát
- Gap 2 — chưa được thử nghiệm hệ thống
- Gap 3 — kết quả tốt nhưng giới hạn 2D / specific case
```

**Quy tắc:**
- Bảng nén cô đọng — mỗi chủ đề một dòng, paper kèm importance trong dấu ngoặc
- Mục **Khoảng trống** chỉ ra hướng đi cho phần sau (motivation cho contribution của bài presentation)

### Flow biến thể: Paper Review đơn (1 paper sâu)

Nếu cần trình bày **một paper duy nhất** rất sâu (paper club, deep dive), thay 1 slide thành 4–6 slides theo flow:

```
1. Paper context — vấn đề, motivation         ← 1 slide
2. Ý tưởng chính — main contribution          ← 1 slide
3. Phương pháp — công thức, kiến trúc         ← 1–2 slides
4. Kết quả — benchmark, comparison            ← 1–2 slides
5. Hạn chế & open questions                   ← 1 slide
6. Liên hệ với công việc của mình             ← 1 slide (optional)
```

Cấu trúc mỗi slide vẫn theo pattern tổng quát ở section 7 (Phong cách viết).

### Tip để paper review không bị nhàm

- **Slogan riêng cho mỗi paper**: thay vì nhắc tên paper lặp lại, dùng góc nhìn riêng (vd: NTK — "chẩn đoán thất bại huấn luyện"; VS-PINN — "variable scaling cho stiff PDE")
- **Con số cụ thể**: mỗi paper phải có ít nhất 1–2 con số định lượng đóng góp (speedup, error reduction, accuracy)
- **Đa dạng dạng trình bày**: xen kẽ bullet, công thức block, bảng metrics — đừng để tất cả slide trông giống nhau
- **Liên kết giữa các paper**: khi giới thiệu paper N, có thể nhắc paper M trước đã giải quyết khía cạnh nào

---

## 7.2 Pattern trình bày Ý tưởng / Đề xuất phương pháp

Khi trình bày các ý tưởng (proposal, hypothesis, method design, experimental approach), mục tiêu là người nghe nắm được **hai điều**: ý tưởng đó là gì về mặt lý thuyết, và tại sao chọn xây dựng theo hướng đó. Dùng pattern hai khối: **Lý thuyết → Lý do xây dựng**.

### Template

```markdown
## Ý tưởng N: Tên rút gọn ý tưởng

**Lý thuyết** — câu mở đầu nêu cơ chế cốt lõi:

$$\text{equation chính nếu có}$$

Đoạn văn diễn giải ý nghĩa của equation và các thành phần phụ. Nếu có nhiều phần phối hợp, dùng 2–3 bullet ngắn:

- **Phần A**: vai trò và cơ chế (1 câu)
- **Phần B**: vai trò và cơ chế (1 câu)
- **Phần C**: vai trò và cơ chế (1 câu)

**Lý do xây dựng**: đoạn văn liền mạch giải thích động lực — quan sát thực nghiệm trước đó, cơ sở lý thuyết từ literature, hoặc hai nguồn cùng chỉ về một hướng. Nêu rõ vì sao ý tưởng này là phép thử có cơ sở chứ không phải lựa chọn ngẫu nhiên.
```

### Quy tắc cho mỗi khối

**Lý thuyết**
- Mở đầu bằng cụm `**Lý thuyết** — <câu mô tả ngắn>:` để vào thẳng nội dung
- Đặt **block equation** ngay sau câu mở đầu nếu công thức là điểm cốt lõi; tối đa 1 block math / slide
- Nếu ý tưởng có nhiều thành phần (vd: kết hợp 3 cải tiến), dùng bullet ngắn với pattern `**Tên phần**: vai trò + cơ chế`
- Tránh liệt kê quá chi tiết về implementation (số layer, optimizer, epoch) — thuộc về slide kết quả, không phải slide ý tưởng

**Lý do xây dựng**
- Viết thành **đoạn văn liền mạch**, không bullet cụt — đây là phần thuyết phục, cần ngữ điệu trôi chảy
- Nêu **ít nhất một** trong các loại cơ sở: (1) quan sát thực nghiệm từ thí nghiệm trước, (2) claim từ paper trong literature (kèm conf nếu có), (3) tương đồng cấu trúc giữa bài toán hiện tại và benchmark đã được giải
- Tránh giọng quảng cáo ("ý tưởng đột phá", "rất tiềm năng") — diễn giải logic vì sao hướng này khả thi
- Một câu kết có thể nêu kỳ vọng cụ thể nếu phù hợp (vd: "kỳ vọng cho mô hình inference nhanh và độ chính xác xấp xỉ FEM")

### Ví dụ minh họa

```markdown
## Ý tưởng 3: Curriculum source sharpening

**Lý thuyết** — xấp xỉ source phân mảnh bằng hàm trơn có tham số điều khiển độ sắc:

$$J(x) \approx J_0 \cdot \left[\sigma(k(x-a)) - \sigma(k(x-b))\right]$$

Tham số $k$ điều khiển độ sắc — khi $k \to \infty$ hàm tiệm cận bậc thang. Lộ trình curriculum tăng dần $k$ qua các giai đoạn huấn luyện:

- Khởi đầu với $k$ thấp — source trơn, loss landscape ít cực trị địa phương hơn
- Tăng dần $k$ để tiệm cận $J_\mathrm{exact}$ trong khi giữ huấn luyện ổn định

**Lý do xây dựng**: ablation cho thấy $J_\mathrm{exact}$ làm Az tệ hơn khoảng 4× so với $J_\mathrm{smooth}$ — gợi ý rằng source quá sắc tạo ra loss landscape khó tối ưu. Lộ trình curriculum tăng dần là cách tự nhiên để hưởng cả hai ưu điểm: khởi động dễ với $k$ thấp, hội tụ chính xác với $k$ cao.
```

### Flow cho nhóm nhiều ý tưởng

Khi có nhiều ý tưởng cùng nhóm (vd: 4–6 đề xuất cho cùng một bài toán), tổ chức theo flow:

```
Slide overview: bảng tổng quan N ý tưởng    ← 1 slide
├── Ý tưởng 1: tên                          ← 1 slide / ý tưởng
├── Ý tưởng 2: tên                          ← 1 slide / ý tưởng
└── Ý tưởng N: tên                          ← 1 slide / ý tưởng
Slide kết quả tổng hợp (sau khi chạy)       ← 1 slide
```

**Slide overview** dùng bảng 3-4 cột:

```markdown
## Tổng quan N ý tưởng

| Ý tưởng | Cơ chế | Lý thuyết nền | Trạng thái |
|---|---|---|---|
| Ý tưởng 1 | Cơ chế ngắn | Paper / khái niệm | Chưa chạy |
| Ý tưởng 2 | Cơ chế ngắn | Paper / khái niệm | Đạt mục tiêu |
```

Cột **Trạng thái** chỉ điền sau khi có kết quả thí nghiệm; trước đó để trống hoặc ghi "Đề xuất". Slide overview phục vụ như mục lục — người nghe biết trước có bao nhiêu ý tưởng và sẽ được giải thích lần lượt ở các slide tiếp theo.

### Tip cho slide ý tưởng

- **Tách lý thuyết khỏi triển khai**: slide ý tưởng nói về *what* và *why*; slide kết quả nói về *how* và *outcome*. Đừng nhồi cả hai vào một slide.
- **Equation là điểm tựa, không phải gánh nặng**: nếu công thức quá dài để nằm gọn một dòng, viết bằng văn xuôi thay vì cố nhét vào `$$...$$`
- **Lý do xây dựng phải truy được nguồn**: nếu dẫn paper, ghi rõ slug và conf; nếu dẫn thí nghiệm, ghi rõ tên experiment trong wiki
- **Không cần liệt kê hạn chế trên slide ý tưởng** — hạn chế thuộc về phần kết quả/thảo luận sau khi chạy thử

---

## 7.3 Sourcing & Tính xác thực của nội dung

**Nguyên tắc tổng quát**: Mọi tuyên bố trên slide phải truy được nguồn hoặc được đánh dấu rõ là giả thuyết / quan sát cá nhân. Slide kỹ thuật không phải nơi cho khẳng định không kiểm chứng — người nghe phải biết mỗi con số / claim đến từ đâu để đánh giá độ tin cậy. Quy tắc này áp dụng cho **mọi loại slide**, không chỉ phần related work hay đề xuất ý tưởng.

### 1. Phân loại mọi tuyên bố thành ba loại

Trước khi viết bất kỳ câu khẳng định nào trên slide, tự hỏi nó thuộc loại nào — và đánh dấu rõ ràng để người nghe phân biệt được:

- **Fact có nguồn**: claim đến từ paper peer-reviewed, official documentation, hoặc dataset đã công bố. Phải kèm nguồn (slug, citation, link, hoặc reference cuối slide).
- **Quan sát từ thí nghiệm của mình**: kết quả thực nghiệm của tác giả lưu trong wiki / log. Phải kèm slug experiment + seed + metric cụ thể đo được.
- **Giả thuyết của tác giả**: suy đoán, dự đoán, hoặc luận điểm cá nhân chưa được kiểm chứng. Phải đánh dấu rõ bằng từ ngữ giả định ("giả thuyết", "kỳ vọng", "có thể", "gợi ý rằng") — không trình bày như fact.

Tránh trộn ba loại trong cùng một câu mà không phân biệt — vd: "Phương pháp X giảm error 30% và sẽ áp dụng được cho bài 3D" trộn fact (30%) với giả thuyết (3D) mà không có cảnh báo nào cho người nghe.

### 2. Nguồn chính thống cho fact

Khi trình bày fact, chỉ dẫn từ nguồn có thể kiểm chứng:

- **Peer-reviewed paper**: kèm venue/year + slug trong wiki (vd: `NTK PINN, JCP 2022, conf 0.92`)
- **Official documentation**: tài liệu chính thức của framework / tool / standard
- **Thí nghiệm có log + code**: experiment trong wiki có thể tái lập được, kèm slug + seed + date chạy
- **Benchmark đã công bố**: dataset / benchmark có DOI hoặc paper gốc

**Không dẫn làm fact**:
- Blog post, tweet, forum thread chưa qua kiểm chứng
- Số liệu nhớ áng chừng không có nguồn cụ thể
- Claim kiểu "ai cũng biết" mà không truy được paper gốc
- Kết quả từ một lần chạy không có seed / không tái lập được
- AI-generated content chưa được tác giả kiểm chứng độc lập

Nếu chỉ có nguồn yếu, viết câu dưới dạng giả thuyết hoặc bỏ luôn — không "nâng cấp" nguồn yếu thành fact bằng cách trình bày khẳng định.

### 3. Số liệu phải cụ thể và truy được

Mỗi con số trên slide cần đủ ngữ cảnh để người nghe đánh giá:

- **Metric rõ ràng**: "RMSE 0.056 mm" tốt hơn "sai số nhỏ"
- **Baseline so sánh**: "Az R² 0.99 (kan-single) vs 0.73 (fd-warm-start)" tốt hơn "Az R² 0.99"
- **Dataset / setting**: "9 flat-bottom holes trên Aluminum 2024" tốt hơn "trên benchmark NDT"
- **Slug nguồn**: kèm `<small>Ref: slug</small>` để truy ngược về log / paper

Tránh con số "trang trí" — vd: "tăng tốc rất nhanh" cần cụ thể hóa thành "tăng tốc 4–5 bậc trên 9 benchmark PDE" với nguồn rõ ràng. Con số không có ngữ cảnh tốt nhất là bỏ đi.

### Cách đánh dấu loại tuyên bố trong văn phong

Dùng cụm từ điển hình giúp người nghe phân biệt loại claim ngay khi đọc:

| Loại | Cụm từ điển hình |
|---|---|
| Fact có nguồn | "đạt", "báo cáo", "chứng minh", "cho thấy", "công bố" |
| Quan sát thực nghiệm | "thí nghiệm X quan sát", "managed rerun cho thấy", "tái lập được" |
| Giả thuyết / suy đoán | "có thể", "gợi ý rằng", "giả thuyết", "kỳ vọng", "có khả năng" |

**Ví dụ phân biệt:**

- *Fact*: "VS-PINN giảm lỗi wave equation từ 63.1% xuống 1.2% (JCP 2024)"
- *Quan sát*: "Managed rerun 2026-06-01 cho thấy kan-single đạt Az R² 0.9924, tái lập ±0.001 qua 2 lần chạy"
- *Giả thuyết*: "Cách tiếp cận tương tự có thể giảm hiện tượng sụp đổ biên độ 36× trong nondim first-order"

Ba câu có cấu trúc động từ khác nhau — người nghe phân biệt được ngay loại tuyên bố mà không cần ghi chú riêng.

---

## 8. Chú thích và References

### Chú thích cuối slide — dùng `<small>`

```markdown
<small>Refs: `slug-paper-1` · `slug-paper-2`</small>
```

- Dùng `<small>` để thu nhỏ
- Slug, ID, hoặc tên rút gọn (không phải tên đầy đủ — dài quá)
- Phân cách bằng ` · ` (middle dot)
- Đặt ở cuối slide, sau nội dung chính

### Metadata / nhãn ngắn

Dùng cụm `**Tên**: giá trị` để gắn metadata nhanh — vd: `**Date**: 2026-06-04`, `**Conf**: 0.92`, `**Status**: in progress`.

---

## 9. Các pattern hữu ích

### Flow chart / Pipeline (text-based, không cần hình)

```markdown
Phase 1: data prep
├── step 1.1                            → output A
├── step 1.2                            → output B
└── step 1.3                            → output C
Phase 2: training
└── ...
```

Trees vẽ bằng ký tự `├──`, `└──`, `│` đọc rõ trong terminal-style theme.

### Tóm tắt findings — bảng so sánh ngắn

```markdown
| Kỹ thuật / Phương pháp | Tác động | Nhận xét |
|---|---|---|
| Approach A | +X% | Đáng tin cậy |
| Approach B | −Y% | Cần điều kiện ... |
```

### Trạng thái — cụm từ chuẩn

Khi liệt kê experiment/idea status, dùng cụm ngắn nhất quán: `đạt` / `chưa đạt` / `đang chạy` / `bất ổn` / `đạt mục tiêu`.

### Callout / nhấn mạnh

Trong text body, gói ý quan trọng trong cặp `**...**` ngắn (không quá 1 dòng). Tránh dùng blockquote `>` cho callout — render kém trong nhiều theme.

---

## 10. Các lưu ý quan trọng

### Layout

- **Căn trái toàn bộ** (`center: false` + `.reveal .slides section { text-align: left; }`)
- **Nội dung không tràn slide** — nếu quá dày, chia thành 2 slides hoặc giảm bớt
- **Ảnh luôn có kích thước** — không để Reveal tự chọn
- **Bảng không quá rộng** — tham khảo font 0.75em, padding vừa phải

### Nội dung

- **Mỗi slide một ý chính**; tiêu đề slide đã nói rõ ý đó là gì
- **Số liệu cần ngữ cảnh** — không đưa số tuyệt đối nếu không có baseline / đơn vị
- **Luôn ghi đơn vị**: %, ms, GB, R², MAPE
- **Trích nguồn** mỗi khi dùng dữ liệu / claim từ tài liệu ngoài

### Equation

- Chỉ dùng `$$...$$` và `$...$` — không môi trường LaTeX
- Block math nên đứng riêng, không xen trong bullet
- Subscripts/superscripts theo rule ở section 5

### Màu sắc & nhấn mạnh

- Chọn 1 theme (`black`, `white`, `league`,...) và stick với nó
- **In đậm** là công cụ nhấn mạnh chính — không lạm dụng (>30% slide đậm = không còn nhấn mạnh)
- Không thêm màu inline (`<span style="color:..">`) — phá vỡ theme và khó duy trì
- Dùng `<small>` để giảm tầm quan trọng (references, captions, footnotes)

---

## 11. Checklist kiểm tra trước khi hoàn tất

- [ ] Frontmatter đầy đủ (theme, transition, width, height, center, controls, progress)
- [ ] CSS style block ghi đè font sizes và `text-align: left`
- [ ] `center: false`
- [ ] H1 chỉ dùng cho slide mở đầu phần / title slide
- [ ] `---` giữa các slide, có dòng trống trước/sau
- [ ] Ảnh có kích thước cụ thể `|widthxheight`
- [ ] Bảng có alignment markers `:---:`, `---:` khi cần
- [ ] Equation dùng `$$...$$` hoặc `$...$` (không môi trường LaTeX)
- [ ] Số mũ trong `{}`: `x^{2}`, không `x^2`
- [ ] Subscripts multi-char trong `{}`: `\mathcal{L}_{\mathrm{total}}`
- [ ] Block equation đứng riêng được căn giữa khi preview (bọc `<div style="text-align: center;">` hoặc dùng CSS rule chung)
- [ ] Chú thích nguồn ở cuối slide dạng `<small>`
- [ ] In đậm metrics quan trọng và tên nổi bật
- [ ] Nội dung không tràn slide — chia slide nếu quá dày
- [ ] Một ngôn ngữ chính nhất quán (VN hoặc EN, không trộn)
- [ ] Văn phong chuyên nghiệp, trung lập, đọc trôi chảy — không gãy gọn cụt lủn, không quảng cáo

### Sourcing & tính xác thực

- [ ] Mọi fact đều có nguồn (paper peer-reviewed / official doc / experiment có log)
- [ ] Không dẫn blog, tweet, forum, hay số liệu áng chừng làm fact
- [ ] Giả thuyết / suy đoán được đánh dấu rõ ("có thể", "kỳ vọng", "giả thuyết")
- [ ] Quan sát thực nghiệm kèm slug experiment + seed + metric cụ thể
- [ ] Mỗi con số có ngữ cảnh đầy đủ: metric / baseline / dataset / nguồn
- [ ] Không trộn fact + giả thuyết trong cùng một câu mà không phân biệt
- [ ] References ở cuối slide dạng `<small>Ref: slug</small>` hoặc tương đương
- [ ] Claim từ literature kèm conf nếu có (vd: `conf 0.92`)
