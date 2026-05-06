---
description: Soạn thảo bài báo LaTeX từ PAPER_PLAN — viết từng phần từ nguồn wiki + tạo hình ảnh/bảng + xác minh BibTeX + đánh bóng de-AI
argument-hint: <đường-dẫn-paper-plan> [--review] [--sections <số-phần>]
---

# /paper-draft

> Soạn thảo bài báo LaTeX hoàn chỉnh từ PAPER_PLAN.md được tạo bởi /paper-plan.
> Viết từng phần: mỗi phần lấy tài liệu từ wiki claims/experiments/papers/concepts,
> tạo LaTeX + hình ảnh + bảng. BibTeX được lấy từ DBLP/CrossRef (tuân theo citation-verification).
> Áp dụng đánh bóng de-AI sau khi hoàn thành (tuân theo academic-writing).
> Tùy chọn đánh giá Review LLM cho từng phần. Xuất ra thư mục paper/ có thể biên dịch.

## Đầu vào

- `plan`: đường dẫn đến PAPER_PLAN.md (ví dụ: `wiki/outputs/paper-plan-sparse-lora-2026-04-08.md`)
- `--review` *(tùy chọn)*: kích hoạt đánh giá Review LLM cho từng phần
- `--sections` *(tùy chọn)*: chỉ viết các phần được chỉ định (ví dụ: `--sections 3,4` chỉ viết Phương pháp + Thí nghiệm); dùng cho viết tăng dần

## Đầu ra

- Thư mục `paper/` (dưới thư mục gốc dự án wiki):
  - `paper/main.tex` — tệp chính (bao gồm từng phần)
  - `paper/sections/introduction.tex`
  - `paper/sections/related_work.tex`
  - `paper/sections/method.tex`
  - `paper/sections/experiments.tex`
  - `paper/sections/conclusion.tex`
  - `paper/sections/appendix.tex` *(nếu có)*
  - `paper/figures/` — hình ảnh được tạo (PDF/PNG)
  - `paper/tables/` — tệp bảng độc lập *(tùy chọn)*
  - `paper/math_commands.tex` — định nghĩa ký hiệu toán học dùng chung
  - `paper/references.bib` — các mục BibTeX đã xác minh
- `wiki/log.md` — mục nhật ký được thêm vào

## Tương tác với Wiki

### Đọc

- `wiki/outputs/paper-plan-*.md` — PAPER_PLAN (đề cương phần, bản đồ bằng chứng, kế hoạch hình ảnh, kế hoạch trích dẫn)
- `wiki/claims/*.md` — Phát biểu, Tóm tắt bằng chứng, Điều kiện của các khẳng định mục tiêu
- `wiki/experiments/*.md` — Kết quả, Phân tích, key_result, dữ liệu chỉ số
- `wiki/papers/*.md` — Phương pháp, Kết quả, Liên quan *(như nội dung trích dẫn và tham chiếu baseline)*
- `wiki/concepts/*.md` — Định nghĩa, Ký hiệu hình thức, Các biến thể *(hỗ trợ viết Phương pháp)*
- `wiki/topics/*.md` — Tổng quan, Dòng thời gian, Theo dõi SOTA *(hỗ trợ ngữ cảnh Giới thiệu)*
- `wiki/ideas/*.md` — Động lực, Giả thuyết *(hỗ trợ tường thuật khoảng trống trong Giới thiệu)*
- `wiki/people/*.md` — tên tác giả và tổ chức *(định dạng trích dẫn)*
- `wiki/graph/edges.jsonl` — đồ thị quan hệ *(xây dựng chuỗi logic lập luận)*
- `wiki/graph/open_questions.md` — các hạn chế đã biết *(viết Hạn chế và Hướng nghiên cứu tương lai)*
- `.claude/skills/shared-references/academic-writing.md` — tiêu chuẩn viết
- `.claude/skills/shared-references/citation-verification.md` — kỷ luật trích dẫn

### Ghi

- Thư mục `paper/` *(tất cả các tệp)*
- `wiki/log.md` — nhật ký hoạt động được thêm vào

### Cạnh đồ thị được tạo

- Không có *(paper-plan đã tạo các cạnh derived_from)*

## Quy trình

**Điều kiện tiên quyết**: Xác nhận thư mục làm việc là thư mục gốc dự án wiki *(thư mục chứa `wiki/`, `raw/`, `tools/`).*

### Bước 1: Khởi tạo Thư mục Bài báo

1. Đọc PAPER_PLAN.md; trích xuất hội nghị, tiêu đề, danh sách phần
2. Nếu thư mục `paper/` đã tồn tại:
   - Sao lưu thành `paper.bak-{timestamp}/`
   - Nhắc người dùng xác nhận ghi đè
3. Tạo cấu trúc thư mục:
   ```
   paper/
   ├── main.tex
   ├── math_commands.tex
   ├── references.bib
   ├── sections/
   └── figures/
   ```
4. Sao chép mẫu hội nghị từ `templates/` nếu tồn tại:
   - `templates/{venue}.sty` hoặc `templates/{venue}/`
   - Nếu không có mẫu: sử dụng lớp article chung; ghi chú trong main.tex rằng mẫu chính thức phải được thay thế
5. Tạo `math_commands.tex`:
   - Thu thập tất cả **Ký hiệu hình thức** từ `wiki/concepts/`
   - Thống nhất định nghĩa ký hiệu *(vector, ma trận, tập hợp, toán tử phổ biến)*
6. Tạo khung `main.tex`:
   ```latex
   \documentclass{article} % thay thế bằng mẫu hội nghị
   \input{math_commands}
   % các gói
   \usepackage{booktabs,graphicx,amsmath,hyperref}

   \title{<tiêu đề>}
   \author{} % để trống cho nộp ẩn danh

   \begin{document}
   \maketitle
   \begin{abstract}
   % được tạo trong Bước 3
   \end{abstract}
   \input{sections/introduction}
   \input{sections/related_work}
   \input{sections/method}
   \input{sections/experiments}
   \input{sections/conclusion}
   \bibliography{references}
   \bibliographystyle{plain} % thay thế bằng kiểu yêu cầu của hội nghị
   % \input{sections/appendix} % bỏ chú thích nếu cần
   \end{document}
   ```

### Bước 2: Tạo Hình ảnh và Bảng

Đối với mỗi mục trong **Kế hoạch hình ảnh** từ PAPER_PLAN:

1. **Loại sơ đồ** *(sơ đồ kiến trúc, v.v.)*:
   - Sử dụng TikZ hoặc pgfplots để tạo hình ảnh LaTeX gốc
   - Nếu quá phức tạp: tạo tập lệnh Python matplotlib → xuất PDF
   - Lưu vào `paper/figures/{tên-hình}.pdf`

2. **Loại biểu đồ** *(biểu đồ kết quả thí nghiệm)*:
   - Trích xuất dữ liệu từ `wiki/experiments/{slug}.md`
   - Tạo tập lệnh matplotlib *(tuân theo tiêu chuẩn thiết kế hình ảnh trong academic-writing)*:
     - Bảng màu an toàn cho người mù màu
     - Kích thước phông chữ ≥ 8pt
     - Thanh lỗi / dải tin cậy
     - Chú giải rõ ràng
   - Thực thi tập lệnh để tạo PDF:
     ```bash
     python3 paper/figures/plot_{tên}.py
     ```
   - Lưu vào `paper/figures/{tên-hình}.pdf`

3. **Loại bảng**:
   - Sử dụng kiểu **booktabs** *(toprule, midrule, bottomrule)*
   - Kết quả tốt nhất **in đậm**, tốt thứ hai **gạch dưới**
   - Nhúng trực tiếp vào tệp .tex của phần *(bảng nhỏ)* hoặc độc lập `paper/tables/{tên}.tex` *(bảng lớn)*

### Bước 3: Viết Các Phần

Đối với mỗi phần *(theo thứ tự đề cương từ PAPER_PLAN)*; nếu `--sections` được chỉ định, chỉ viết các phần đó:

**3a. Thu thập Tài liệu**

Từ định nghĩa phần trong PAPER_PLAN, trích xuất:
- Các khẳng định mà phần này hỗ trợ
- Danh sách các trang wiki tương ứng
- Hình ảnh/bảng đã lên kế hoạch
- Danh sách trích dẫn

Đọc các phần liên quan của tất cả các trang wiki liên quan:
- **Giới thiệu** → `wiki/ideas/{idea}.md#Động_lực` + `wiki/topics/{topic}.md#Tổng_quan`
- **Công trình liên quan** → `wiki/papers/*.md#Liên_quan` + `wiki/concepts/*.md#So_sánh`
- **Phương pháp** → `wiki/concepts/*.md#Ký_hiệu_hình_thức` + `wiki/claims/{claim}.md#Phát_biểu`
- **Thí nghiệm** → `wiki/experiments/*.md#Kết_quả` + `wiki/experiments/*.md#Phân_tích`
- **Kết luận** → `wiki/graph/open_questions.md` + `wiki/claims/*.md#Câu_hỏi_mở`

**3b. Viết LaTeX**

Tuân theo `shared-references/academic-writing.md`:
- Viết theo kế hoạch đoạn văn cho phần đó
- Chèn trích dẫn `\cite{key}` *(khóa được ánh xạ từ kế hoạch trích dẫn)*
- Chèn tham chiếu `\ref{fig:tên}` / `\ref{tab:tên}` đến hình ảnh/bảng
- Sử dụng ký hiệu được định nghĩa trong `math_commands.tex`
- Bắt đầu mỗi đoạn bằng **câu chủ đề**
- Phần **Thí nghiệm**: cấu trúc **khẳng định trước** *("Chúng tôi khẳng định X. Để xác minh, chúng tôi...")*

**3c. Đánh bóng De-AI**

Áp dụng đánh bóng de-AI cho từng phần đã viết *(theo academic-writing.md)*:
1. Quét và thay thế từ vựng đặc trưng AI *(delve, leverage, utilize, comprehensive...)*
2. Loại bỏ **hedging** quá mức
3. Đa dạng hóa cách mở đầu câu *(tránh các cấu trúc câu giống nhau liên tiếp)*
4. Loại bỏ **câu thừa** *(câu không thêm thông tin)*
5. Đảm bảo **thể chủ động** chiếm ưu thế
6. Kiểm tra **tính nhất quán của ký hiệu**

**3d. Đánh giá Review LLM Tùy chọn *(--review)***

Nếu `--review` được kích hoạt, cho từng phần:

```
mcp__llm-review__chat:
  system: "Bạn là một nhà nghiên cứu ML cao cấp đang đánh giá một phần của bản thảo bài báo.
           Tập trung vào: sự rõ ràng, luồng logic, sự phù hợp khẳng định-bằng chứng, tính nhất quán ký hiệu.
           Chỉ ra bất kỳ mẫu ngôn ngữ giống AI còn lại nào.
           Đề xuất viết lại cụ thể cho các đoạn không rõ ràng."
  message: |
    ## Phần: {tên phần}
    {nội dung LaTeX}

    ## Các khẳng định mà phần này nên hỗ trợ
    {khẳng định từ ma trận}

    ## Đánh giá phần này về:
    1. Nó có hỗ trợ rõ ràng các khẳng định mục tiêu không?
    2. Cách viết có rõ ràng và chính xác không?
    3. Có mẫu ngôn ngữ do AI tạo còn lại không?
    4. Ký hiệu có nhất quán với các phần khác không?
    5. Nội dung nào còn thiếu mà người đánh giá sẽ mong đợi?
```

Sửa đổi phần dựa trên phản hồi của Review LLM *(chỉnh sửa nội tuyến; không viết lại toàn bộ phần)*.

### Bước 4: Xây dựng Thư mục Tài liệu tham khảo

Tuân theo `shared-references/citation-verification.md`:

1. Thu thập tất cả trích dẫn `\cite{key}` được sử dụng trong các phần
2. Đối với mỗi trích dẫn, lấy BibTeX từ kế hoạch trích dẫn của PAPER_PLAN:
   - **Đã xác minh**: ghi trực tiếp vào `references.bib`
   - **[UNCONFIRMED]**: ghi vào cuối `references.bib` với chú thích `% [UNCONFIRMED]`
3. Loại trừ các mục không sử dụng *(không sử dụng `\nocite{*}`)*
4. Xác thực tính đúng đắn của định dạng BibTeX *(mỗi mục có title, author, year)*
5. Xuất thống kê thư mục tài liệu:
   ```
   references.bib: {N} mục, {M} đã xác minh, {K} [UNCONFIRMED]
   ```

### Bước 5: Đánh giá Chéo Toàn bài báo

Sau khi tất cả các phần hoàn thành:

```
mcp__llm-review__chat:
  system: "Bạn là một nhà nghiên cứu ML cao cấp thực hiện đánh giá cuối cùng của bản thảo bài báo hoàn chỉnh.
           Tập trung vào: tính mạch lạc giữa các phần, chuỗi khẳng định-bằng chứng *(bài báo có chứng minh những gì nó khẳng định không?)*,
           luồng tường thuật, tính nhất quán ký hiệu giữa các phần, tham chiếu hình ảnh/bảng.
           Đây KHÔNG phải là đánh giá từng dòng — tập trung vào các vấn đề cấu trúc và lập luận."
  message: |
    ## Bản thảo bài báo đầy đủ
    {LaTeX nối của tất cả các phần}

    ## Bản đồ bằng chứng
    {từ PAPER_PLAN}

    ## Trọng tâm đánh giá
    1. Bài báo có kể một câu chuyện mạch lạc từ Giới thiệu đến Kết luận không?
    2. Tất cả các khẳng định từ ma trận có được hỗ trợ đầy đủ trong văn bản không?
    3. Có sự không nhất quán ký hiệu giữa các phần không?
    4. Tất cả hình ảnh/bảng có được tham chiếu và thảo luận không?
    5. Có sự dư thừa giữa các phần không?
    6. Mức độ sẵn sàng tổng thể để nộp *(1-10)*?
```

Thực hiện điều chỉnh cuối cùng dựa trên phản hồi của Review LLM.

### Bước 6: Hoàn thiện Đầu ra

1. Xác nhận tất cả tệp được ghi vào thư mục `paper/`
2. Xác minh tính toàn vẹn cơ bản:
   - Tất cả tệp được tham chiếu bởi `\input{sections/X}` tồn tại
   - Tất cả tệp được tham chiếu bởi `\includegraphics{figures/X}` tồn tại
   - Tất cả khóa `\cite{key}` có mục tương ứng trong `references.bib`
   - Tất cả `\ref{label}` có `\label{label}` tương ứng
3. Thêm nhật ký:
   ```bash
   python3 tools/research_wiki.py log wiki/ \
     "paper-draft | đã soạn thảo bài báo {venue} '{title}' | {N} phần, {M} hình ảnh, {K} trích dẫn ({V} đã xác minh)"
   ```
4. In ra terminal:
   ```markdown
   # Hoàn thành Viết bài báo

   ## Tệp
   - paper/main.tex *(tệp chính)*
   - paper/sections/ *(*{N} tệp phần)*
   - paper/figures/ *(*{M} tệp hình ảnh)*
   - paper/references.bib *(*{K} mục, {V_count} [UNCONFIRMED])*
   - paper/math_commands.tex

   ## Trạng thái
   - Các phần đã viết: {danh sách}
   - Đánh bóng de-AI: đã áp dụng
   - Đánh giá Review LLM: {có/không, nếu có: điểm tổng thể}
   - Trích dẫn [UNCONFIRMED]: {số lượng} *(giải quyết trước /paper-compile)*

   ## Bước tiếp theo
   - Chạy `/paper-compile paper/` để biên dịch và xác minh
   - Giải quyết trích dẫn [UNCONFIRMED] thủ công
   - Chạy `/refine paper/main.tex --focus writing` để đánh bóng thêm
   ```

## Ràng buộc

- **Mỗi phần lấy từ wiki**: không tạo nội dung từ hư không; mọi khẳng định kỹ thuật phải truy ngược về một trang wiki
- **BibTeX tuân theo citation-verification.md**: lấy từ DBLP/CrossRef/S2; không tạo từ bộ nhớ LLM
- **Đánh bóng de-AI là bắt buộc**: mỗi phần phải nhận một lượt đánh bóng sau khi viết; không thể bỏ qua
- **Hình ảnh tuân theo academic-writing.md**: an toàn cho người mù màu, kích thước phông chữ ≥ 8pt, ưu tiên định dạng vector
- **Nộp ẩn danh**: không viết tên tác giả, tổ chức hoặc lời cảm ơn *(theo yêu cầu ẩn danh của hội nghị)*
- **\nocite{*} bị cấm**: chỉ trích dẫn các mục thực sự được sử dụng
- **Tính nhất quán ký hiệu**: tất cả các phần sử dụng ký hiệu thống nhất từ `math_commands.tex`
- **Sao lưu paper/ hiện có trước khi ghi đè**: không ghi đè trực tiếp; sao lưu trước
- **Chuyển đổi Wikilink → \cite**: tham chiếu `[[slug]]` trong PAPER_PLAN được chuyển thành `\cite{key}` trong LaTeX
- **Bảng sử dụng booktabs**: không có đường dọc hoặc lưới đầy đủ

## Xử lý lỗi

- **Không tìm thấy PAPER_PLAN**: lỗi; đề xuất chạy `/paper-plan` trước
- **Định dạng PAPER_PLAN không đầy đủ**: liệt kê các phần thiếu; đề xuất chạy lại `/paper-plan`
- **Không tìm thấy trang wiki** *(khẳng định/thí nghiệm/bài báo được tham chiếu trong kế hoạch không tồn tại)*: cảnh báo và bỏ qua tham chiếu đó; chú thích là **thiếu**
- **Tạo hình ảnh thất bại** *(lỗi matplotlib)*: xuất placeholder `% TODO: tạo hình ảnh {tên}`; tiếp tục với các phần khác
- **Tất cả lấy BibTeX thất bại**: sử dụng placeholder **[UNCONFIRMED]**; báo cáo số lượng cần xử lý thủ công trong terminal
- **Review LLM không khả dụng** *(chế độ --review)*: bỏ qua đánh giá phần và đánh giá chéo; chú thích là **"chưa được đánh giá"**
- **Không tìm thấy mẫu hội nghị**: sử dụng lớp **article** chung; ghi chú trong main.tex
- **Phần quá dài** *(vượt quá ngân sách trang của kế hoạch)*: cảnh báo; đề xuất chuyển sang phụ lục hoặc nén

## Phụ thuộc

### Công cụ *(qua Bash)*

- `python3 tools/research_wiki.py log wiki/ "<message>"` — thêm nhật ký
- `python3 tools/fetch_s2.py search "<title>"` — dự phòng BibTeX *(tìm kiếm S2)*
- `python3` — thực thi tập lệnh hình ảnh matplotlib

### Máy chủ MCP

- `mcp__llm-review__chat` — đánh giá từng phần *(tùy chọn, --review)* + đánh giá chéo toàn bài *(Bước 5)*

### Claude Code Gốc

- `Read` — đọc các trang wiki và PAPER_PLAN
- `Glob` — tìm các trang wiki
- `Write` — ghi tệp vào thư mục `paper/`
- `Bash` — thực thi tập lệnh hình ảnh, tạo thư mục
- `WebFetch` — lấy BibTeX từ DBLP / CrossRef

### Tài liệu tham khảo chung

- `.claude/skills/shared-references/academic-writing.md` — tiêu chuẩn viết + quy tắc đánh bóng de-AI + thiết kế hình ảnh
- `.claude/skills/shared-references/citation-verification.md` — quy trình lấy BibTeX + giao thức **[UNCONFIRMED]**

### Được gọi bởi

- `/research` Giai đoạn 5 *(giai đoạn viết bài báo)*
- Người dùng gọi thủ công