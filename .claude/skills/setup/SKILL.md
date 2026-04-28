---
description: Hướng dẫn cấu hình khóa API tương tác — kiểm tra trạng thái .env hiện tại và hướng dẫn bạn thiết lập Semantic Scholar, DeepXiv và Review LLM
---

# /setup

> Hướng dẫn bạn cấu hình khóa API tùy chọn của ΩmegaWiki.
> Đọc tệp `.env` hiện tại của bạn, hiển thị những gì đã và chưa được cấu hình, và giúp bạn
> thiết lập từng khóa với giải thích rõ ràng về chức năng và cách lấy chúng.
> An toàn khi chạy lại bất kỳ lúc nào — chỉ cập nhật các khóa bạn chọn cấu hình.

## Đầu Vào

- Không yêu cầu đối số
- Đọc: `.env` (trạng thái cấu hình hiện tại)
- Đọc: `config/setup-guide.md` (tham khảo về chức năng của từng khóa)

## Đầu Ra

- Đã cập nhật `.env` với bất kỳ khóa mới nào được cấu hình
- Tóm tắt trạng thái cấu hình hiện tại

## Tương Tác Wiki

### Đọc
- Không có (setup chạy trước khi wiki tồn tại)

### Ghi
- Không có (không chạm vào wiki)

## Quy Trình Làm Việc

### Bước 1: Đọc Tài Liệu Tham Khảo Cấu Hình

Đọc `config/setup-guide.md` để tải tham khảo đầy đủ cho tất cả các khóa có thể cấu hình,
bao gồm chức năng, kỹ năng sử dụng, cách lấy và hành vi dự phòng.

### Bước 2: Phát Hiện Môi Trường Hiện Tại

Chạy lệnh sau để kiểm tra những gì đã được cấu hình:

```bash
python3 -c "
import sys, os
sys.path.insert(0, 'tools')
try:
    import _env
except Exception:
    pass
keys = {
    'SEMANTIC_SCHOLAR_API_KEY': 'Semantic Scholar',
    'DEEPXIV_TOKEN':            'DeepXiv',
    'LLM_API_KEY':              'Review LLM (API key)',
    'LLM_BASE_URL':             'Review LLM (base URL)',
    'LLM_MODEL':                'Review LLM (model)',
}
for k, label in keys.items():
    v = os.environ.get(k, '').strip()
    print(f'SET:{k}' if v else f'UNSET:{k}')
"
```

Cũng phát hiện môi trường Python và trạng thái `.venv`:
```bash
ls .venv/ 2>/dev/null && echo "venv:present" || echo "venv:absent"
python3 --version
```

### Bước 3: Hiển Thị Trạng Thái Cấu Hình

Trình bày tóm tắt rõ ràng cho người dùng, nhóm theo trạng thái:

```
Trạng Thái Cấu Hình ΩmegaWiki
================================
✓  ANTHROPIC_API_KEY      — được quản lý bởi Claude Code (claude login)

Được khuyến nghị:
✗  Semantic Scholar        — chưa thiết lập  (mở rộng trích dẫn chậm hơn 3 lần — lấy khóa miễn phí)

Tùy chọn:
✗  DeepXiv                 — chưa thiết lập  (tìm kiếm ngữ nghĩa không khả dụng)
✗  Review LLM              — chưa thiết lập  (đánh giá chéo giữa các mô hình không khả dụng)
```

Hỏi người dùng: "Bạn muốn cấu hình cái nào? (Bạn có thể bỏ qua bất kỳ hoặc tất cả.)"

### Bước 4: Cấu Hình Từng Khóa (theo hướng dẫn của người dùng)

Đối với mỗi khóa người dùng muốn cấu hình, thực hiện quy trình con cụ thể dưới đây.
Luôn yêu cầu xác nhận của người dùng trước khi ghi vào `.env`.

---

#### 4a: Khóa API Semantic Scholar

**Giải thích**: "Semantic Scholar cung cấp dữ liệu trích dẫn và tìm kiếm bài báo.
Được sử dụng bởi /ingest, /init, /novelty, /ideate. Miễn phí.
**Được khuyến nghị** — nếu không có, /init chạy chậm hơn 3 lần và mở rộng chuỗi trích dẫn kém hiệu quả hơn nhiều."

**Hướng dẫn lấy**: "Truy cập https://www.semanticscholar.org/product/api và nhấp vào 'Get API Key'. Nó miễn phí."

**Hỏi**: "Bạn có khóa API Semantic Scholar không? (dán vào đây, hoặc 'bỏ qua')"

**Nếu được cung cấp**, ghi vào `.env`:
```python
# Đọc .env hiện tại, cập nhật hoặc thêm SEMANTIC_SCHOLAR_API_KEY=<giá trị>
```
Sử dụng công cụ Edit để cập nhật `.env`:
- Nếu dòng `SEMANTIC_SCHOLAR_API_KEY=` tồn tại (ngay cả khi trống), thay thế nó
- Nếu không, thêm `SEMANTIC_SCHOLAR_API_KEY=<giá trị>`

---

#### 4b: Token DeepXiv

**Giải thích**: "DeepXiv cho phép tìm kiếm bài báo theo ngữ nghĩa, tóm tắt bài báo bằng AI (TLDR),
và phát hiện bài báo xu hướng. Được sử dụng bởi /daily-arxiv, /novelty, /ideate, /ingest, /init.
Nếu không có, các kỹ năng này sẽ quay lại RSS arXiv + Semantic Scholar — mọi thứ vẫn hoạt động."

**Đề xuất ba tùy chọn**:
1. **Tự động đăng ký** (được khuyến nghị, miễn phí, tức thì): Thực hiện đăng ký trực tiếp
2. **Dán token hiện có**: Người dùng cung cấp token của họ
3. **Bỏ qua**: Cấu hình sau

**Đối với tùy chọn 1 — tự động đăng ký**, chạy:
```bash
python3 -c "
import sys, json
from uuid import uuid4
try:
    import requests
except ImportError:
    print('ERROR: requests chưa được cài đặt', file=sys.stderr)
    sys.exit(1)

suffix = uuid4().hex[:10]
payload = {
    'sdk_secret': 'UuZp0i83svQU7_naUEexczc-X3NWv7lvNkD8e3sPyng',
    'name': f'deepxiv_{suffix}',
    'email': f'{suffix}@example.com',
}
try:
    resp = requests.post('https://data.rag.ac.cn/api/register/sdk', json=payload, timeout=30)
    resp.raise_for_status()
    result = resp.json()
except Exception as e:
    print(f'ERROR: {e}', file=sys.stderr)
    sys.exit(1)

if not result.get('success'):
    print(f'ERROR: {result.get(\"message\", \"unknown\")}', file=sys.stderr)
    sys.exit(1)

token = result.get('data', {}).get('token', '')
daily_limit = result.get('data', {}).get('daily_limit', 1000)
if not token:
    print('ERROR: không có token trong phản hồi', file=sys.stderr)
    sys.exit(1)

print(token)
print(f'daily_limit:{daily_limit}', file=sys.stderr)
"
```
stdout → giá trị token; stderr → trạng thái dễ đọc (chuyển tiếp, không chặn).

Nếu đăng ký thành công, ghi token vào `.env`. Nếu thất bại, hiển thị lỗi và
hỏi người dùng có muốn dán token thủ công không.

---

#### 4c: Review LLM

**Giải thích**: "Review LLM kết nối ΩmegaWiki với mô hình AI thứ hai để đánh giá đối kháng độc lập.
Được sử dụng bởi /review, /novelty, /ideate, /paper-plan, /paper-draft,
/rebuttal, /refine, /exp-eval và /exp-design. Hoạt động với bất kỳ API tương thích OpenAI nào.
Nếu không có, các kỹ năng này sẽ bỏ qua bước đánh giá chéo giữa các mô hình (mọi thứ vẫn hoạt động)."

**Trình bày bảng nhà cung cấp** từ `config/setup-guide.md` (Mục 3).

**Giải thích 'tương thích OpenAI'** nếu người dùng hỏi: bất kỳ API nào chấp nhận
`POST /chat/completions` với `{"model": "...", "messages": [...]}` theo định dạng OpenAI.

**Hỏi**:
1. `LLM_BASE_URL` — ví dụ: `https://api.deepseek.com/v1`
2. `LLM_API_KEY` — khóa API của họ cho nhà cung cấp đó
3. `LLM_MODEL` — tên mô hình, ví dụ: `deepseek-chat`

**Xác thực định dạng**: Base URL nên bắt đầu bằng `http://` hoặc `https://` và kết thúc bằng `/v1`
(hoặc đường dẫn tương tự). Nếu có vẻ sai, yêu cầu xác nhận trước khi ghi.

**Ghi cả ba** vào `.env` sau khi người dùng xác nhận.

**Sau khi ghi**: Nhắc người dùng rằng máy chủ MCP Review LLM khởi động khi Claude Code
khởi chạy và đọc `.env` tại thời điểm đó — các thay đổi có hiệu lực sau khi khởi động lại Claude Code.

---

#### 4d: Danh mục arXiv (chỉ khi người dùng yêu cầu)

Khóa này có giá trị mặc định hợp lý (`cs.LG,cs.CV,cs.CL,cs.AI,stat.ML`). Chỉ cấu hình
nó nếu người dùng yêu cầu rõ ràng, hoặc nếu lĩnh vực nghiên cứu của họ rõ ràng nằm ngoài ML/AI.

---

### Bước 5: Xác Minh Cấu Hình

Sau khi người dùng hoàn tất cấu hình, chạy kiểm tra xác minh từ `config/setup-guide.md`:

```bash
python3 -c "
import sys, os
sys.path.insert(0, 'tools')
try:
    import _env
except Exception:
    pass
keys = ['SEMANTIC_SCHOLAR_API_KEY', 'DEEPXIV_TOKEN', 'LLM_API_KEY', 'LLM_BASE_URL', 'LLM_MODEL']
for k in keys:
    v = os.environ.get(k, '').strip()
    print(f'SET   {k}' if v else f'UNSET {k}')
"
```

Hiển thị tóm tắt cuối cùng. Đối với bất kỳ khóa nào vẫn chưa được thiết lập, ghi chú ngắn gọn về chức năng của chúng
và người dùng có thể chạy `/setup` lại bất kỳ lúc nào để thêm chúng.

### Bước 6: Các Bước Tiếp Theo

Nếu đây là cài đặt mới (không có thư mục `wiki/`):
```
Cấu hình hoàn tất. Tiếp theo:
  • Đặt các bài báo của bạn vào raw/papers/ (.tex hoặc .pdf)
  • Tùy chọn: thêm ghi chú ý định vào raw/notes/ và các trang đã lưu vào raw/web/
  • /init và /ingest cục bộ trực tiếp sẽ quản lý các đầu vào được tạo dưới raw/discovered/ và raw/tmp/
  • Chạy: /init [chủ-đề-nghiên-cứu-của-bạn]
```

Nếu `wiki/` đã tồn tại:
```
Cấu hình đã cập nhật. Khởi động lại Claude Code để các thay đổi của Review LLM có hiệu lực.
```

## Các Ràng Buộc

- **Không bao giờ ghi đè các giá trị không trống hiện có** mà không hỏi người dùng trước
- **Không bao giờ hiển thị toàn bộ giá trị khóa** trong đầu ra — chỉ hiển thị 8 ký tự đầu + `...`
- **Chỉ ghi vào `.env`** — không bao giờ ghi vào `~/.env` hoặc các vị trí khác
- **Không đọc hoặc ghi wiki** — kỹ năng này chạy trước khi wiki có thể tồn tại
- **Bỏ qua một cách nhẹ nhàng**: nếu người dùng nói "bỏ qua tất cả", hiển thị tóm tắt trạng thái và thoát sạch sẽ

## Xử Lý Lỗi

- **`.env` không tìm thấy**: Thông báo cho người dùng rằng `setup.sh` chưa được chạy. Đề nghị tạo `.env` từ `.env.example`:
  ```bash
  cp config/.env.example .env
  ```
  Sau đó tiếp tục cấu hình.

- **`config/setup-guide.md` không tìm thấy**: Tiếp tục sử dụng thông tin trong SKILL.md này trực tiếp.

- **Đăng ký DeepXiv thất bại** (lỗi mạng, lỗi máy chủ): Hiển thị thông báo lỗi rõ ràng,
  đề nghị người dùng dán token thủ công, hoặc bỏ qua.

- **Vấn đề môi trường Python** (`tools/_env.py` không tìm thấy): Lưu ý rằng `.venv` có thể chưa hoạt động,
  nhưng vẫn đọc `.env` trực tiếp bằng shell hoặc I/O tệp Python để kiểm tra trạng thái hiện tại.

## Phụ Thuộc

### Công cụ (qua Bash)
- `python3 -c "import _env; ..."` — đọc trạng thái `.env` hiện tại
- `python3 -c "import requests; ..."` — cuộc gọi HTTP đăng ký tự động DeepXiv

### Tệp Đọc
- `config/setup-guide.md` — tham khảo đầy đủ cho tất cả các khóa có thể cấu hình
- `.env` — cấu hình hiện tại (đọc + ghi)

### Tệp Ghi
- `.env` — đã cập nhật với các khóa mới được cấu hình (qua công cụ Edit)

### Không gọi máy chủ MCP, không gọi wiki, không gọi kỹ năng bên ngoài