# Hướng Dẫn Soạn PowerPoint (.pptx) — `/create-ppt`

> Nguồn quy tắc duy nhất cho kỹ năng `/create-ppt`: dựng một file PowerPoint `.pptx` đẳng cấp từ một paper PDF (hoặc nguồn nội dung khác), nhúng đầy đủ hình gốc + công thức render, có phân tích phản biện, qua vòng QA trực quan.
>
> Khác với `/create-slides` (Reveal.js/Markdown trên Obsidian), kỹ năng này xuất **file `.pptx` thật** mở được bằng PowerPoint/Keynote, build bằng **pptxgenjs**.

---

## 0. Triết lý — điều gì làm một deck "đẳng cấp"

1. **Thật sự "nhìn" được hình** — render từng trang PDF ra ảnh rồi đọc bằng vision (không đoán). Nhờ đó crop chính xác và mô tả đúng nội dung từng figure.
2. **Nhúng hình gốc của paper** nguyên bản (crop sạch 300 DPI), không vẽ lại → trung thực, chuyên nghiệp.
3. **Công thức = ảnh render từ LaTeX** (PowerPoint không có LaTeX) → nét, sắc, đúng ký hiệu.
4. **Design system nhất quán** — 1 palette, 2 họ font, các helper layout dùng lại → mọi slide cùng một "ngôn ngữ".
5. **QA bằng con mắt mới (subagent)** trên ảnh render thật → bắt lỗi tràn, đè, tương phản mà người viết code không thấy.
6. **Hỏi rõ trước khi làm** — không suy diễn các quyết định lớn.

---

## 1. Hỏi người dùng trước (quyết định bắt buộc)

Trước khi build, chốt bằng câu hỏi tương tác:

| Quyết định | Mô tả |
|---|---|
| **Format** | `.pptx` (kỹ năng này) — xác nhận không phải Reveal.js/Markdown |
| **Audience / độ sâu** | seminar deep-technical · talk tổng quát · intro |
| **Độ dài** | ngắn (~10–12) · vừa (~15–20) · đầy đủ (~25+) |
| **Xử lý hình** | crop từng hình riêng (đẹp nhất) · dùng nguyên trang |
| **Phân tích phản biện** | có (strengths/limitations + liên hệ research) · chỉ trình bày paper |
| **Font chữ** | mặc định **Lato**; hỏi nếu người dùng có ý khác |
| **Font công thức** | mặc định **STIX** (≈ Cambria Math); hoặc `cm` (LaTeX cổ điển) |
| **Palette màu** | hỏi sớm — đây là thứ người dùng quan tâm và dễ phải làm lại nhất |

> **Bài học**: hỏi **font + palette ngay từ đầu**. Bỏ qua sẽ phải build lại nhiều vòng.

---

## 2. Toolchain (kiểm tra/cài 1 lần)

- **PyMuPDF (`fitz`)** — render PDF ra ảnh + crop hình + render slide để QA. Ưu tiên `.venv/bin/python`. `pdfimages` cũ (v3.02) **không** dùng được (`-png` không hỗ trợ).
- **matplotlib + pillow** — render công thức LaTeX→PNG, đo kích thước ảnh. `.venv/bin/pip install matplotlib pillow`.
- **pptxgenjs** — build `.pptx`. Cài **LOCAL trong thư mục deck**: `npm install pptxgenjs` (cài global hay lỗi `Cannot find module`).
- **LibreOffice `soffice`** (headless, `libreoffice-nogui` là đủ) — chuyển `.pptx → .pdf` để QA. Không cần `pdftoppm` — dùng PyMuPDF render PDF.
- **Font** cần cài sẵn trong hệ thống để LibreOffice render đúng. Kiểm tra: `fc-list | grep -i <font>`. **Cambria Math không cài được** (độc quyền Microsoft) → dùng **STIX**.

---

## 3. Bố cục thư mục output

Mọi artefact của một deck nằm gọn trong một thư mục dưới `wiki/outputs/<deck-slug>/`:

```
wiki/outputs/<deck-slug>/
├── build_deck.js              # script pptxgenjs (bản mẫu sống — copy để tái dùng)
├── figures/                   # hình crop từ paper, 300 DPI
│   ├── dims.json              # {path: [w,h]} — giữ tỷ lệ ảnh khi nhúng
│   ├── eq/                    # công thức render từ LaTeX (PNG trong suốt)
│   └── pages/                 # (tạm) các trang PDF render để đọc/QA
├── <Deck-Name>.pptx           # output cuối
└── node_modules/              # pptxgenjs cài local
```

File tạm khi đọc paper (full text, ảnh trang) có thể để ở `raw/tmp/<slug>/` (chỉ thêm, không ghi đè input người dùng).

---

## 4. Trích xuất & crop hình từ PDF

### 4.1 Render mọi trang + đọc bằng vision
```python
import fitz, os
doc = fitz.open("raw/papers/PAPER.pdf")
os.makedirs("figures/pages", exist_ok=True)
for i, page in enumerate(doc):
    page.get_pixmap(dpi=110).save(f"figures/pages/p{i+1:02d}.png")
    print(i+1, len(page.get_images(full=True)), page.get_text()[:60])
```
→ Sau đó **đọc (Read) các trang có hình** để xác nhận nội dung từng figure. Trích full text bằng `page.get_text()` để nắm chi tiết kỹ thuật.

### 4.2 Tìm vị trí caption ("Fig. N …")
```python
for b in page.get_text("blocks"):
    x0,y0,x1,y1,txt,*_ = b
    if txt.strip().startswith("Fig."):
        print(f"cap y0={y0:.0f} :: {txt[:60]}")
```

### 4.3 Lấy bbox vùng đồ hoạ gần caption
- Ảnh nhúng: `page.get_images(full=True)` → `page.get_image_rects(xref)`.
- Hình vector (vẽ bằng path): union `d["rect"]` của `page.get_drawings()` (lọc rect đủ lớn).
- Figure thường nằm **phía trên caption**, hoặc ở đầu trang.

### 4.4 Crop DPI cao + padding nhỏ
```python
mat = fitz.Matrix(300/72, 300/72); P = 6  # padding pt
clip = fitz.Rect(x0-P, y0-P, x1+P, y1+P) & page.rect
page.get_pixmap(matrix=mat, clip=clip).save("figures/fig1_architecture.png")
```
- Đặt tên mô tả: `fig1_architecture.png`, `fig7_error_dist.png`…
- **Đọc lại vài hình** sau khi crop để chắc không cụt/lệch.

---

## 5. Render công thức (LaTeX → PNG)

PowerPoint không có LaTeX → render bằng matplotlib mathtext, **nền trong suốt**, DPI cao.

```python
import matplotlib; matplotlib.use("Agg")
matplotlib.rcParams["mathtext.fontset"] = "stix"   # STIX ≈ Cambria Math; "cm" = LaTeX cổ điển
import matplotlib.pyplot as plt

def render(name, tex, fs=30, color="#172332"):
    fig = plt.figure(figsize=(0.01, 0.01))
    fig.text(0, 0, f"${tex}$", fontsize=fs, color=color)
    fig.savefig(f"figures/eq/{name}.png", dpi=300,
                bbox_inches="tight", pad_inches=0.12, transparent=True)
    plt.close(fig)
```

**Bẫy cú pháp mathtext** (KHÁC LaTeX thật):
- **Không** có `\big| \big|` → dùng `\left| ... \right|`.
- `\mathcal{L}`, `\frac`, `\partial`, `\nabla`, `\sum_{}^{}`, `\dot{}` đều OK.
- Test sớm: render 1–2 công thức, Read kiểm tra trước khi render cả loạt.

---

## 6. Design system

### 6.1 Palette — định nghĩa thành hằng số, gán theo VAI TRÒ
Gán màu theo chức năng, không theo tên — để đổi theme chỉ sửa một chỗ. Ví dụ palette earthy:

```js
const SAGE="A5B9A1", SAGE_D="839388";  // chủ đạo / phụ
const BLUE="4375BC";                    // kicker, header bảng, số liệu chính
const TERRA="B17158";                   // highlight kết quả + DẢI DỌC slide đặc biệt
const SLATE="606969";                   // dữ liệu phụ
const INK="172332";                     // tiêu đề + chữ chính
const LIGHT="F4F4EE", CARD="FFFFFF";    // nền sáng + card
const MUTED="414240", LINE="D4D5D0", PANEL="E7E8E1";
```
Nguyên tắc: **1 màu thống trị, 1–2 màu phụ, 1 accent sắc**. Dùng alias để hạn chế sửa code khi đổi theme.

### 6.2 Font
- Thân slide (tiêu đề + body): **1 họ sans** (mặc định Lato).
- Công thức: **serif math** (STIX) — tương phản serif/sans là chuẩn slide khoa học.
- Code/thuật toán: **monospace** (Consolas).
- Đổi font toàn cục: 1 dòng `const HEAD = BODY = "Lato"`.

### 6.3 Nền sáng + dải dọc cho slide đặc biệt
Ưu tiên **nền sáng** cho mọi slide (trừ khi người dùng yêu cầu khác). Slide đặc biệt (title / divider / takeaways) thêm **dải màu dọc** bên trái làm điểm nhấn — không làm tối slide:
```js
function newSlide(sp){ const s=pres.addSlide(); s.background={color:LIGHT};
  if(sp) s.addShape(pres.shapes.RECTANGLE,{x:0,y:0,w:0.35,h:H,fill:{color:TERRA}});
  return s; }
```
Nếu cần khối tối có chủ đích (code/thuật toán) thì dùng card mực `INK` — đó là điểm tối duy nhất.

### 6.4 Helper dùng lại (xương sống deck)
- `head(slide, kicker, title)` — kicker (chữ nhỏ in hoa, màu accent) + title ~27pt.
- `footer(slide)` — thương hiệu trái + số trang phải.
- `divider(num, title, sub)` — slide phân phần, ghost number to mờ.
- `card(x,y,w,h,fill)` — khối trắng bo nhẹ + shadow factory.
- `bullets(items, ...)` — bullet thật (`bullet:{code:"2022"}`), hỗ trợ cấp con + bold.
- `fitImg(key, bx,by,bw,bh)` — **nhúng ảnh GIỮ TỶ LỆ** trong một box (đọc `figures/dims.json`).
- `caption(...)` — chú thích italic dưới hình.

### 6.5 Lưu kích thước ảnh để giữ tỷ lệ
```python
from PIL import Image; import glob, json, os
d = {}
for f in glob.glob("figures/**/*.png", recursive=True):
    im = Image.open(f); d[os.path.relpath(f, ".")] = [im.width, im.height]
json.dump(d, open("figures/dims.json", "w"), indent=0)
```
`fitImg` đọc file này, tính `aspect ratio`, fit ảnh trong box mà không méo.

---

## 7. Cấu trúc nội dung (deep-technical, khung 5 phần)

1. **Motivation** — vấn đề (2–3 slide) + background + related work + key idea + contributions.
2. **Method** — derivation từng bước (mỗi bước 1 slide), bảng giảm độ phức tạp, loss/kết quả cuối, diễn giải trực giác.
3. **Architecture & Algorithm** — figure kiến trúc + pseudo-code + chiến lược.
4. **Experiments** — setup → từng ablation → từng benchmark; mỗi slide 1–2 hình gốc + bảng số.
5. **Discussion** — strengths / limitations (grid card) + liên hệ research của người dùng + takeaways.

**Quy tắc tiêu đề**: mỗi slide 1 ý chính; bảng số trích **đúng** từ paper; tiêu đề **ngắn gọn, chuyên nghiệp, tránh động từ mạnh / khẩu ngữ**.
- Tốt: "Two problems addressed by this paper", "Physics-Informed Neural Networks: an overview".
- Tránh: "…this paper attacks", "…in 60 seconds", "My take".

---

## 8. Build & QA loop (bắt buộc lặp ≥ 1 vòng)

```bash
# build
node build_deck.js                       # -> <Deck-Name>.pptx

# render để QA (KHÔNG cần pdftoppm)
soffice --headless --convert-to pdf --outdir qa <Deck>.pptx
# rồi PyMuPDF: doc[i].get_pixmap(dpi=100).save(f"qa/slide-{i+1:02d}.png")
```

**QA bằng subagent (con mắt mới)** — chia 2 nhóm slide, prompt yêu cầu *giả định có lỗi*:
- text tràn ra ngoài card / mép slide; phần tử đè nhau (text qua bảng, card đè bảng);
- **tương phản thấp** (chữ sáng trên nền sáng / tối trên tối);
- caption đè hình/footer; bảng cụt dòng; tiêu đề wrap 2 dòng đè nội dung;
- khi đổi theme: thêm mục "còn sót màu theme cũ không?".

**Lỗi điển hình & cách sửa:**
- *Dark-on-dark title* → helper `head` phải biết nền, hoặc bỏ nền tối hẳn.
- *Card/stat đè bảng* → giảm `rowH` bảng + đẩy y khối dưới xuống.
- *Bullets đè bảng* → tính lại chiều cao bảng (rows×rowH) trước khi đặt bullets.
- *Subagent báo "nội dung nén nửa trên / hình nhỏ"* thường là **ảo giác do render 100 DPI** → render lại slide đó ở 140–150 DPI và tự Read xác minh **trước khi** "sửa".

**Content QA**: `python -m markitdown <Deck>.pptx | grep -iE "xxxx|lorem|undefined|TODO"` → phải rỗng.

---

## 9. Bẫy kỹ thuật pptxgenjs

- Màu hex **không** dấu `#`; **không** mã 8 ký tự (opacity nhúng trong hex) → corrupt file. Dùng property `opacity` riêng.
- **Không** tái dùng cùng một object `shadow` giữa nhiều shape (pptxgenjs mutate in-place) → dùng factory trả object mới mỗi lần: `const sh = () => ({...})`.
- Bullet: dùng `bullet:true` / `{code:"2022"}`, **không** ký tự "•" thủ công (gây double bullet).
- `breakLine:true` giữa các run/array item để xuống dòng.
- `RECTANGLE` (không bo) cho dải/accent; `ROUNDED_RECTANGLE` cho card bo góc — đừng phủ accent chữ nhật lên góc bo.
- Cài `pptxgenjs` **local** trong thư mục deck.
- Mỗi presentation cần instance mới (`new pptxgen()`), không tái dùng.

---

## 10. Checklist tái lập (rút gọn)

1. Hỏi: format, audience, độ dài, xử lý hình, phân tích phản biện, **font + palette**.
2. Đọc paper: render mọi trang PDF → Read hình; trích full text.
3. Crop figures 300 DPI (theo caption bbox) → Read lại vài cái.
4. Render công thức STIX → PNG trong suốt; xuất `dims.json`.
5. Viết `build_deck.js`: palette + helper + slide theo khung 5 phần.
6. `node build_deck.js` → `.pptx`.
7. `soffice` → PDF → PyMuPDF PNG → **2 subagent QA** → sửa → render lại slide đã sửa để xác minh.
8. Content QA (markitdown grep placeholder).
9. Cập nhật `wiki/index.md` (nếu output trong `wiki/outputs/`) + append `wiki/log.md`.

---

## 11. Checklist self-review trước khi báo cáo

**Hình & công thức:**
- [ ] Mọi figure cần thiết của paper đã được crop và nhúng (không thiếu hình)
- [ ] Hình giữ đúng tỷ lệ (qua `fitImg` + `dims.json`), không méo/cụt
- [ ] Công thức render nét, đúng ký hiệu, nền trong suốt

**Design & layout:**
- [ ] 1 palette nhất quán, gán theo vai trò; tương phản đạt (không sáng-trên-sáng/tối-trên-tối)
- [ ] Font thống nhất (sans cho chữ, serif cho công thức, mono cho code)
- [ ] Không phần tử đè nhau; không text tràn card/mép; caption không đè footer
- [ ] Tiêu đề ngắn gọn, chuyên nghiệp, tránh động từ mạnh/khẩu ngữ

**Nội dung & xác thực:**
- [ ] Số liệu/bảng trích đúng từ paper; không bịa
- [ ] Phân tích phản biện (nếu có) tách bạch strengths/limitations
- [ ] Không còn placeholder (markitdown grep rỗng)
- [ ] Đã qua ≥ 1 vòng QA subagent + sửa + render lại xác minh

---

## 12. Ràng buộc

- **`docs/ppt-guide.vi.md` là nguồn quy tắc duy nhất** cho `/create-ppt`; không tự chế thêm quy tắc.
- **Không bịa nội dung**: số liệu/citation phải lấy từ paper; thiếu thì bỏ hoặc đánh dấu giả định.
- **Hình gốc của paper được nhúng nguyên bản** — không vẽ lại, không bịa biểu đồ.
- **`raw/` thuộc sở hữu người dùng**: chỉ thêm file tạm vào `raw/tmp/`, không ghi đè input.
- **Không ghi đè deck `.pptx` hiện có** nếu không phải do kỹ năng này sinh ra mà chưa xác nhận với người dùng.
- **Không chỉnh sửa `graph/`**; cập nhật `index.md` và append `log.md`.
- QA loop là bắt buộc — không báo cáo hoàn tất khi chưa qua ít nhất một vòng QA + sửa.
