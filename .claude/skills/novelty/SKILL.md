---
description: Xác minh tính mới lạ từ nhiều nguồn — WebSearch + Semantic Scholar + wiki + Review LLM xác minh chéo — xuất ra điểm số mới lạ và khuyến nghị
argument-hint: <mô-tả-ý-tưởng-hoặc-slug>
---

# /novelty

> Xác minh tính mới lạ của một ý tưởng hoặc phương pháp nghiên cứu bằng nhiều nguồn. Tìm kiếm WebSearch,
> Semantic Scholar, công trình wiki hiện có và các bản preprint arXiv gần đây, sau đó Review LLM xác minh chéo.
> Xuất ra điểm số mới lạ (1-5), công trình trước đây gần nhất, điểm khác biệt và khuyến nghị bước tiếp theo.
> Có thể được sử dụng độc lập hoặc được gọi bởi /ideate Giai đoạn 4.

## Đầu Vào

- `target`: một trong các mục sau:
  - mô tả văn bản tự do của ý tưởng (một đoạn hoặc vài câu)
  - slug của trang ideas/ trong wiki (ví dụ: `sparse-lora-for-edge-devices`)
  - tiêu đề bài báo hoặc URL arXiv (kiểm tra tính mới lạ của phương pháp của bài báo đó)
- `--quick`: chế độ nhanh, bỏ qua xác minh chéo Review LLM (Bước 3), chỉ tìm kiếm
- `--verbose`: xuất ra kết quả tìm kiếm đầy đủ, không chỉ tóm tắt

## Đầu Ra

- **Báo Cáo Tính Mới Lạ** (xuất ra terminal, không ghi vào wiki):
  - Điểm Số Mới Lạ (1-5)
  - Danh sách công trình trước đây gần nhất (top 3-5)
  - Điểm khác biệt so với mỗi công trình trước đây
  - Đánh giá xác minh chéo của Review LLM (trừ khi --quick)
  - Hành động được khuyến nghị: tiếp tục / sửa đổi / từ bỏ
- Kỹ năng này là **truy vấn chỉ đọc** — nó không sửa đổi bất kỳ nội dung wiki nào

## Tương Tác Wiki

### Đọc
- `wiki/papers/*.md` — tìm kiếm các bài báo hiện có cho các phương pháp tương tự
- `wiki/concepts/*.md` — kiểm tra sự trùng lặp khái niệm
- `wiki/ideas/*.md` — kiểm tra trùng lặp với các ý tưởng hiện có (đặc biệt là `failure_reason` của các ý tưởng thất bại)
- `wiki/claims/*.md` — kiểm tra trạng thái hiện tại của các khẳng định mà ý tưởng phụ thuộc vào
- `wiki/graph/context_brief.md` — ngữ cảnh toàn cục để hỗ trợ tìm kiếm

### Ghi
- **Không có**. Kiểm tra tính mới lạ là một hoạt động truy vấn thuần túy; nó không sửa đổi wiki.

### Các cạnh đồ thị được tạo
- **Không có**.

## Quy Trình Làm Việc

**Điều kiện tiên quyết**: xác nhận thư mục làm việc là thư mục gốc dự án wiki (chứa `wiki/`, `raw/`, `tools/`).

### Bước 1: Trích Xuất Chữ Ký Phương Pháp

1. **Nếu target là slug**: đọc `wiki/ideas/{slug}.md`, trích xuất tiêu đề, Hypothesis, Approach sketch
2. **Nếu target là văn bản tự do**: sử dụng trực tiếp
3. **Nếu target là URL arXiv**: tải xuống tóm tắt, trích xuất mô tả phương pháp
4. Trích xuất "chữ ký phương pháp" từ target — các yếu tố cốt lõi của phương pháp:
   - **Cái gì**: nó làm gì (nhiệm vụ / mục tiêu)
   - **Như thế nào**: phương pháp được sử dụng (cách tiếp cận kỹ thuật)
   - **Tại sao mới lạ**: đổi mới được tuyên bố
5. Tạo 3-5 từ khóa cốt lõi cho các tìm kiếm tiếp theo

### Bước 2: Tìm Kiếm Từ Nhiều Nguồn

Thực hiện các tìm kiếm sau song song (sử dụng công cụ Agent để đồng thời):

**Nguồn A — Tìm Kiếm Web (5+ truy vấn):**
1. Truy vấn trực tiếp: `"<tên-phương-pháp>" + "<nhiệm-vụ>"` — tìm kiếm cụm từ chính xác
2. Truy vấn thành phần: `<thành-phần-1> + <thành-phần-2> + <lĩnh-vực>` — tìm kiếm kết hợp thành phần
3. Truy vấn khảo sát: `"survey" OR "review" + <khu-vực-nhiệm-vụ> + 2024 2025`
4. Truy vấn đối thủ: `<cách-tiếp-cận-thay-thế> + <cùng-nhiệm-vụ>`
5. Truy vấn gần đây: `<từ-khóa-phương-pháp> + arXiv + 2025 2026`

**Nguồn B — Semantic Scholar + DeepXiv:**
```bash
python3 tools/fetch_s2.py search "<từ-khóa-phương-pháp>" --limit 20
python3 tools/fetch_deepxiv.py search "<từ-khóa-phương-pháp>" --mode hybrid --limit 20
```
Hợp nhất kết quả từ cả hai nguồn (loại bỏ trùng lặp theo arxiv_id). Tìm kiếm ngữ nghĩa hybrid của DeepXiv tìm thấy công trình tương tự về mặt ngữ nghĩa mà tìm kiếm từ khóa S2 có thể bỏ lỡ.
- Lấy chi tiết và TLDR cho top 5 kết quả:
```bash
python3 tools/fetch_s2.py paper <s2_id>
python3 tools/fetch_deepxiv.py brief <arxiv_id>
```
Sử dụng TLDR brief của DeepXiv để nhanh chóng đánh giá sự tương đồng phương pháp.
**Nếu DeepXiv không khả dụng**: quay lại chỉ tìm kiếm S2 (hành vi gốc).

**Nguồn C — Tìm Kiếm Nội Bộ Wiki:**
1. Quét các phần Key idea và Method của tất cả các trang trong `wiki/papers/`
2. Quét các phần Definition và Variants của `wiki/concepts/`
3. Quét tất cả nội dung trong `wiki/ideas/`, với sự chú ý đặc biệt đến:
   - các ý tưởng có status = failed và failure_reason của chúng (chống lặp lại)
   - các ý tưởng có status = proposed/in_progress (tránh trùng lặp nội bộ)
4. Đọc `wiki/graph/context_brief.md` cho quan điểm toàn cục

**Nguồn D — Các Bản Preprint arXiv Gần Đây:**
- Sử dụng WebSearch: `site:arxiv.org <từ-khóa-phương-pháp> 2025 2026`

### Bước 3: Xác Minh Chéo Review LLM

(Bỏ qua nếu `--quick`)

Gửi nội dung sau đến Review LLM để đánh giá độc lập:

```
mcp__llm-review__chat:
  system: "Bạn là một nhà nghiên cứu ML cao cấp đánh giá tính mới lạ của một phương pháp được đề xuất.
           Hãy nghiêm ngặt: nếu phương pháp về cơ bản là sự tái kết hợp các kỹ thuật đã biết
           với những thay đổi nhỏ, hãy cho điểm thấp. Chỉ cho điểm 4-5 nếu có một cái nhìn sâu sắc
           hoặc công thức thực sự mới."
  message: |
    ## Phương Pháp Được Đề Xuất
    {chữ ký phương pháp từ Bước 1}

    ## Công Trình Tương Tự Hiện Có Đã Tìm Thấy
    {top 5 công trình tương tự từ Bước 2, với tiêu đề + tóm tắt một dòng}

    ## Câu Hỏi
    1. Phương pháp này có thực sự mới lạ không, hay chỉ là một biến thể nhỏ của công trình hiện có?
    2. Công trình hiện có gần nhất là gì và sự khác biệt thực sự là gì?
    3. Điểm số mới lạ 1-5 với lý do.
    4. Nếu điểm số <= 2, sửa đổi nào có thể tăng tính mới lạ?
```

### Bước 4: Tạo Báo Cáo Tính Mới Lạ

Tổng hợp kết quả tìm kiếm Bước 2 và đánh giá Review LLM Bước 3 thành một báo cáo có cấu trúc:

```markdown
# Báo Cáo Tính Mới Lạ: {tiêu đề ý tưởng}

## Điểm: {1-5}/5 — {nhãn}

| Điểm | Nhãn | Ý Nghĩa |
|-------|-------|---------|
| 1 | Đã Xuất Bản | Công trình đã xuất bản rất tương tự tồn tại |
| 2 | Rất Tương Tự | Phương pháp rất tương tự tồn tại, chỉ có sự khác biệt nhỏ |
| 3 | Gia Tăng | Đóng góp gia tăng rõ ràng so với công trình hiện có |
| 4 | Kết Hợp Mới Lạ | Kết hợp sáng tạo các kỹ thuật hiện có, tạo ra cái nhìn sâu sắc mới |
| 5 | Hoàn Toàn Mới | Đề xuất một mô hình hoặc công thức hoàn toàn mới |

## Công Trình Trước Đây Gần Nhất

1. **{tiêu đề}** ({năm}) — {mô tả một câu về sự tương đồng}
   - Sự khác biệt: {sự phân biệt chính giữa phương pháp này và công trình trước đây}
   - Liên kết wiki: [[slug]] (nếu tồn tại)
2. ...

## Đánh Giá Review LLM
{tóm tắt đánh giá độc lập của Review LLM}

## Kiểm Tra Chống Lặp Lại
- Các ý tưởng thất bại trong wiki: {liệt kê các ý tưởng thất bại liên quan với failure_reason}
- Các ý tưởng đang tiến hành trong wiki: {liệt kê các ý tưởng có thể trùng lặp}

## Khuyến Nghị
- **{tiếp tục / sửa đổi / từ bỏ}**
- Lý do: {một đoạn}
- Nếu sửa đổi: các hướng khác biệt được đề xuất: {gợi ý cụ thể}
```

**Quy tắc đánh giá (đánh giá tổng hợp):**
- Lấy điểm thấp hơn giữa điểm dựa trên tìm kiếm của Claude và điểm của Review LLM (nguyên tắc thận trọng)
- Nếu wiki chứa một ý tưởng thất bại có failure_reason trùng lặp với ý tưởng này → giảm điểm 1
- Nếu wiki chứa một ý tưởng in_progress trùng lặp cao → đánh dấu là từ bỏ (trùng lặp nội bộ)

## Các Ràng Buộc

- **Không sửa đổi wiki**: kiểm tra tính mới lạ là một truy vấn thuần túy; tất cả kết quả chỉ được xuất ra terminal
- **Đánh giá thận trọng**: đánh giá thấp tính mới lạ hơn là đánh giá cao để tránh lãng phí công sức vào công trình đã biết
- **Phải kiểm tra các ý tưởng thất bại**: các ý tưởng có status=failed trong wiki/ideas/ là tín hiệu chống lặp lại quan trọng
- **Phạm vi tìm kiếm**: ít nhất 5 truy vấn WebSearch riêng biệt + Semantic Scholar + tìm kiếm nội bộ wiki
- **Tính độc lập của Review LLM**: không bao gồm đánh giá tính mới lạ của chính Claude khi gửi đến Review LLM; để Review LLM đánh giá độc lập
- **Trích dẫn nguồn thực**: tất cả công trình trước đây được liệt kê trong báo cáo phải là thực (được trả về bởi WebSearch/S2); không bịa đặt

## Xử Lý Lỗi

- **WebSearch không khả dụng**: bỏ qua Nguồn A và D, chỉ dựa vào S2 + tìm kiếm wiki; ghi chú phạm vi hạn chế trong báo cáo
- **API Semantic Scholar không khả dụng**: bỏ qua phần S2, sử dụng DeepXiv + WebSearch để bù đắp
- **API DeepXiv không khả dụng**: bỏ qua phần DeepXiv, dựa vào S2 + WebSearch (quay lại hành vi gốc)
- **Review LLM không khả dụng**: bỏ qua Bước 3; chú thích báo cáo với "Xác minh chéo Review LLM không khả dụng, chỉ đánh giá một mô hình"
- **Wiki trống**: tiếp tục với các tìm kiếm bên ngoài bình thường; chú thích phần tìm kiếm nội bộ wiki với "wiki trống"
- **Không tìm thấy slug ý tưởng**: nhắc người dùng kiểm tra slug, liệt kê các slug có sẵn trong wiki/ideas/

## Phụ Thuộc

### Công cụ (qua Bash)
- `python3 tools/fetch_s2.py search "<truy-vấn>" --limit 20` — tìm kiếm từ khóa Semantic Scholar
- `python3 tools/fetch_s2.py paper <s2_id>` — lấy chi tiết bài báo
- `python3 tools/fetch_deepxiv.py search "<truy-vấn>" --mode hybrid --limit 20` — tìm kiếm ngữ nghĩa DeepXiv
- `python3 tools/fetch_deepxiv.py brief <arxiv_id>` — lấy TLDR bài báo để đánh giá sự tương đồng

### Máy Chủ MCP
- `mcp__llm-review__chat` — xác minh chéo Review LLM (Bước 3)

### Claude Code Gốc
- `WebSearch` — tìm kiếm web nhiều truy vấn (Bước 2 Nguồn A + D)
- Công cụ `Agent` — thực thi song song tìm kiếm từ nhiều nguồn (Bước 2)

### Tài Liệu Tham Khảo Chung
- `.claude/skills/shared-references/cross-model-review.md` (được tạo trong Giai đoạn 2, nguyên tắc độc lập Review LLM)