---
description: Biên dịch LaTeX → PDF — latexmk biên dịch + tự động sửa lỗi + kiểm tra số trang/ẩn danh/phông chữ/[UNCONFIRMED] + danh sách kiểm tra nộp
argument-hint: "[paper-dir] [--fix] [--checklist]"
---

# /paper-compile

> Biên dịch bài báo LaTeX thành PDF, tự động sửa các lỗi phổ biến và xác minh các yêu cầu nộp.
> Đầu vào: thư mục paper/ được tạo bởi /paper-draft. Chạy biên dịch latexmk,
> phân tích lỗi và cố gắng tự động sửa (gói thiếu, tham chiếu không xác định, đường dẫn hình ảnh).
> Xác minh giới hạn số trang, tuân thủ ẩn danh, nhúng phông chữ và xóa các dấu [UNCONFIRMED].
> Tạo danh sách kiểm tra nộp.

## Đầu vào

- `paper_dir` (tùy chọn, mặc định `paper/`): thư mục dự án LaTeX chứa `main.tex`
- `--fix` (tùy chọn): bật chế độ tự động sửa (tự động cài đặt gói thiếu, sửa đường dẫn)
- `--checklist` (tùy chọn): tạo danh sách kiểm tra nộp chi tiết (chỉ kiểm tra, không biên dịch)

## Đầu ra

- `paper/main.pdf` — tệp PDF đã biên dịch
- **COMPILE_REPORT** (in ra terminal) — trạng thái biên dịch, kết quả kiểm tra, danh sách kiểm tra nộp
- Nếu `--fix`: các tệp .tex đã sửa (tự động sửa)

## Tương tác với Wiki

### Đọc

- `wiki/outputs/paper-plan-*.md` — lấy thông tin hội nghị (giới hạn số trang, yêu cầu ẩn danh)
- `.claude/skills/shared-references/citation-verification.md` — quy tắc kiểm tra dấu [UNCONFIRMED]

### Ghi

- `paper/main.pdf` — đầu ra biên dịch
- `wiki/log.md` — thêm nhật ký biên dịch

### Cạnh đồ thị được tạo

- Không có

## Quy trình

**Điều kiện tiên quyết**: xác nhận `paper/main.tex` tồn tại. Xác nhận `latexmk` đã được cài đặt (`which latexmk`).

### Bước 1: Biên dịch

1. **Biên dịch lần đầu**:
   ```bash
   cd paper/ && latexmk -pdf -interaction=nonstopmode main.tex 2>&1
   ```

2. **Phân tích đầu ra biên dịch**:
   - Thu thập tất cả lỗi (`\! ...`)
   - Thu thập tất cả cảnh báo (`Warning:` / `Overfull` / `Underfull`)
   - Phân loại:
     - **Gói thiếu**: `\! LaTeX Error: File 'xxx.sty' not found`
     - **Tham chiếu không xác định**: `LaTeX Warning: Reference 'xxx' on page N undefined`
     - **Trích dẫn không xác định**: `LaTeX Warning: Citation 'xxx' on page N undefined`
     - **Hình ảnh thiếu**: `\! LaTeX Error: File 'figures/xxx' not found`
     - **Lỗi cú pháp**: các lỗi khác bắt đầu bằng `\!`
     - **Overfull/Underfull**: cảnh báo sắp chữ (không chặn)

3. **Nếu biên dịch thành công** (tệp main.pdf được tạo): chuyển sang Bước 3
4. **Nếu biên dịch thất bại**: chuyển sang Bước 2

### Bước 2: Tự động sửa lỗi

Nếu `--fix` được bật, cố gắng tự động sửa từng loại lỗi:

**2a. Gói thiếu**:
```bash
# kiểm tra xem gói có thể cài đặt qua TeX Live không
tlmgr info {package-name} 2>/dev/null
# nếu có thể cài đặt và người dùng xác nhận:
tlmgr install {package-name}
```
Nếu không thể cài đặt: comment dòng `\usepackage{xxx}` và chú thích `% TODO: install package {xxx}`

**2b. Tham chiếu/trích dẫn không xác định**:
- Tham chiếu không xác định: kiểm tra xem `\label{}` tương ứng có tồn tại không; nếu không, thêm nhãn placeholder
- Trích dẫn không xác định: kiểm tra xem `references.bib` có chứa khóa không
  - Nếu không: cố gắng khớp từ các bài báo trong wiki và thêm mục [UNCONFIRMED]
  - Nếu có nhưng bibtex chưa chạy: chạy lại `latexmk` (latexmk thường xử lý điều này tự động)

**2c. Hình ảnh thiếu**:
- Kiểm tra xem `paper/figures/` có chứa tệp với phần mở rộng khác không (.pdf vs .png vs .eps)
- Nếu tìm thấy: sửa đường dẫn `\includegraphics`
- Nếu không tìm thấy: thay thế bằng placeholder `\missingfigure{xxx}` (yêu cầu gói `todonotes`)

**2d. Lỗi cú pháp**:
- Các sửa lỗi phổ biến: dấu ngoặc đóng `{}`, không khớp `\begin{}`/`\end{}`, ký tự không hợp lệ
- Cố gắng xác định số dòng lỗi; cung cấp gợi ý sửa cụ thể
- Nếu không thể tự động sửa: báo cáo vị trí lỗi và gợi ý

**Biên dịch lại sau khi sửa** (tối đa 3 vòng sửa-biên dịch):
```bash
cd paper/ && latexmk -pdf -interaction=nonstopmode main.tex 2>&1
```

### Bước 3: Kiểm tra xác minh

Sau khi biên dịch thành công, chạy các kiểm tra sau:

**3a. Kiểm tra số trang**:
```bash
# lấy số trang PDF
python3 -c "
import subprocess
result = subprocess.run(['pdfinfo', 'paper/main.pdf'], capture_output=True, text=True)
for line in result.stdout.splitlines():
    if line.startswith('Pages:'):
        print(line.split(':')[1].strip())
"
```
So sánh với giới hạn số trang của hội nghị (lấy từ PAPER_PLAN hoặc bảng hội nghị trong academic-writing.md).
- Vượt quá giới hạn: báo cáo số trang vượt quá; gợi ý nén hoặc chuyển nội dung sang phụ lục
- Dưới giới hạn: báo cáo không gian còn lại; gợi ý thêm nội dung

**3b. Kiểm tra ẩn danh**:
Quét tất cả tệp .tex:
- Tìm kiếm tên tác giả (nếu `\author{}` không rỗng → cảnh báo)
- Tìm kiếm tên tổ chức (đại học, phòng lab, viện → cảnh báo)
- Tìm kiếm liên kết GitHub/GitLab (có thể tiết lộ danh tính → cảnh báo)
- Tìm kiếm "our previous work" / "we previously" → nên sử dụng trích dẫn ở ngôi thứ ba
- Tìm kiếm `\thanks{}` / `\acknowledgments` → xóa cho nộp ẩn danh

**3c. Kiểm tra dấu [UNCONFIRMED]**:
```bash
# quét references.bib và tất cả tệp .tex
grep -rn "UNCONFIRMED" paper/
```
- Nếu tồn tại dấu [UNCONFIRMED]: liệt kê từng dấu; đánh dấu là **chặn nộp**
- Theo citation-verification.md: [UNCONFIRMED] là chặn nộp cứng

**3d. Kiểm tra nhúng phông chữ**:
```bash
pdffonts paper/main.pdf
```
- Kiểm tra cột "emb": tất cả phông chữ phải là "yes"
- Phông chữ không được nhúng: báo cáo tên phông chữ; gợi ý thêm tùy chọn nhúng phông chữ vào lệnh biên dịch

**3e. Kiểm tra tính đầy đủ nội dung**:
- Tìm kiếm dấu `TODO`, `FIXME`, `XXX`
- Tìm kiếm `\missingfigure`, phần trống (`\section{X}` theo sau không có nội dung)
- Tìm kiếm hình ảnh/bảng không được tham chiếu (`\includegraphics` có nhưng không có `\ref`)
- Kiểm tra xem abstract có tồn tại và không rỗng không

### Bước 4: Tạo danh sách kiểm tra nộp và báo cáo

```markdown
# Báo cáo biên dịch

## Biên dịch
- Trạng thái: {THÀNH CÔNG / THẤT BẠI}
- Trình biên dịch: latexmk + pdflatex
- Số vòng: {N} (bao gồm vòng tự động sửa)
- Lỗi: {N} (đã sửa: {M}, còn lại: {K})
- Cảnh báo: {N} (overfull: {O}, underfull: {U}, khác: {W})

## Kết quả xác minh

| Kiểm tra | Trạng thái | Chi tiết |
|-------|--------|---------|
| Số trang | {ĐẠT/KHÔNG ĐẠT} | {N} trang (giới hạn: {L}) |
| Ẩn danh | {ĐẠT/CẢNH BÁO} | {chi tiết} |
| Trích dẫn [UNCONFIRMED] | {ĐẠT/KHÔNG ĐẠT} | {N} còn lại |
| Phông chữ nhúng | {ĐẠT/KHÔNG ĐẠT} | {chi tiết} |
| Không có TODOs | {ĐẠT/CẢNH BÁO} | {N} còn lại |
| Hình ảnh được tham chiếu | {ĐẠT/CẢNH BÁO} | {chi tiết} |
| Abstract có mặt | {ĐẠT/KHÔNG ĐẠT} | {chi tiết} |

## Danh sách kiểm tra nộp

- [ ] PDF biên dịch không lỗi
- [ ] Số trang trong giới hạn hội nghị ({L} trang)
- [ ] Tất cả trích dẫn [UNCONFIRMED] đã được giải quyết
- [ ] Nộp ẩn danh (không có thông tin tác giả)
- [ ] Tất cả phông chữ được nhúng
- [ ] Không có dấu TODO/FIXME
- [ ] Tất cả hình ảnh được tham chiếu trong văn bản
- [ ] Abstract có mặt và đầy đủ
- [ ] Tài liệu bổ sung đã chuẩn bị (nếu có)
- [ ] Tiêu đề bài báo khớp với hệ thống nộp

## Vấn đề chặn
{danh sách các mục KHÔNG ĐẠT phải được giải quyết trước khi nộp}

## Cảnh báo (không chặn)
{danh sách các mục CẢNH BÁO cần xem xét}

## Bước tiếp theo
- {hành động cụ thể để giải quyết vấn đề chặn}
- Chạy `/refine paper/main.tex --focus writing` để hoàn thiện cuối cùng
- Kiểm tra thủ công tuân thủ ẩn danh
```

Ghi nhật ký:
```bash
python3 tools/research_wiki.py log wiki/ \
  "paper-compile | {THÀNH CÔNG/THẤT BẠI} | {pages} trang, {errors} lỗi, {verify_count} [UNCONFIRMED], {checks_passed}/{checks_total} kiểm tra đạt"
```

## Ràng buộc

- **Không sửa đổi nội dung wiki**: chỉ hoạt động trên thư mục paper/ và wiki/log.md
- **Tự động sửa yêu cầu --fix**: mặc định chỉ báo cáo lỗi; không sửa
- **[UNCONFIRMED] là chặn cứng**: [UNCONFIRMED] có trong danh sách kiểm tra nộp = không thể nộp
- **Tối đa 3 vòng sửa-biên dịch**: ngăn chặn vòng lặp sửa vô hạn
- **Không xóa nội dung người dùng**: tự động sửa chỉ thêm hoặc sửa; không xóa nội dung viết tay
- **Phụ thuộc pdfinfo/pdffonts**: nếu không được cài đặt, bỏ qua kiểm tra tương ứng và chú thích "công cụ không khả dụng"
- **Kiểm tra ẩn danh là heuristic**: có thể tạo dương tính giả; chú thích là CẢNH BÁO thay vì KHÔNG ĐẠT

## Xử lý lỗi

- **Không tìm thấy main.tex**: lỗi; gợi ý chạy /paper-draft trước
- **latexmk không được cài đặt**: lỗi; cung cấp lệnh cài đặt (`sudo apt install texlive-full` hoặc `brew install --cask mactex`)
- **Biên dịch thất bại và tự động sửa không thành công**: xuất nhật ký lỗi đầy đủ + xác định tệp .tex và số dòng cụ thể
- **pdfinfo/pdffonts không được cài đặt**: bỏ qua kiểm tra số trang / phông chữ; chú thích trong báo cáo
- **Không tìm thấy PAPER_PLAN**: bỏ qua trích xuất thông tin hội nghị; sử dụng giới hạn mặc định (10 trang); cảnh báo người dùng
- **Vấn đề quyền** (tlmgr yêu cầu sudo): báo cáo danh sách các gói cần cài đặt thủ công

## Phụ thuộc

### Công cụ (thông qua Bash)
- `latexmk` — Biên dịch LaTeX
- `pdfinfo` — Kiểm tra số trang PDF (poppler-utils)
- `pdffonts` — Kiểm tra nhúng phông chữ (poppler-utils)
- `python3 tools/research_wiki.py log wiki/ "<message>"` — Ghi nhật ký

### Máy chủ MCP
- Không có

### Claude Code Native
- `Read` — Đọc tệp .tex và nhật ký biên dịch
- `Edit` — Tự động sửa tệp .tex (chế độ --fix)
- `Bash` — Thực thi lệnh biên dịch và kiểm tra
- `Grep` — Tìm kiếm [UNCONFIRMED], TODO, vi phạm ẩn danh

### Tài liệu tham khảo chung
- `.claude/skills/shared-references/citation-verification.md` — Quy tắc kiểm tra dấu [UNCONFIRMED]
- `.claude/skills/shared-references/academic-writing.md` — Tham chiếu giới hạn số trang hội nghị

### Được gọi bởi
- `/research` Giai đoạn 5 (giai đoạn biên dịch bài báo)
- Lệnh gọi thủ công của người dùng
