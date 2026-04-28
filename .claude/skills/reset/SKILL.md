---
description: Đặt lại trạng thái wiki về khung sạch theo phạm vi (wiki / raw / log / checkpoints / all). Hữu ích trong quá trình phát triển hoặc khởi động lại không lo lắng sau khi thiết lập thất bại.
argument-hint: "--scope wiki|raw|log|checkpoints|all"
---

# /reset

> Đặt lại wiki về khung sạch theo phạm vi. Được thiết kế cho quá trình lặp phát triển và khôi phục sau khi thiết lập thất bại — không phải là hoạt động thường xuyên.

## Kích Hoạt

Thủ công: `/reset --scope wiki` / `--scope raw` / `--scope log` / `--scope checkpoints` / `--scope all`. Có thể kết hợp nhiều phạm vi bằng dấu phẩy: `--scope wiki,log`.

## Đầu Vào

- `--scope` *(bắt buộc)*: một trong các mục sau
  - `wiki` — xóa mọi `*.md` trong `wiki/<entity>/` và `wiki/outputs/`, cộng với `wiki/index.md`, `wiki/log.md` và các tệp trong `wiki/graph/`. Giữ lại `.gitkeep` và `wiki/CLAUDE.md`.
  - `raw` — xóa mọi mục trong `raw/papers/`, `raw/discovered/`, `raw/tmp/`, `raw/notes/`, `raw/web/` (trừ `.gitkeep`).
  - `log` — đặt lại `wiki/log.md` về tiêu đề trống.
  - `checkpoints` — xóa trạng thái batch qua `research_wiki.py checkpoint-clear`.
  - `all` — tất cả phạm vi trên.

## Đầu Ra

- Các tệp đã xóa / đặt lại trên đĩa.
- Tóm tắt trên console về các tệp đã xóa và đặt lại.

## Tương Tác Wiki

### Đọc
- Tất cả `wiki/<entity>/*.md` (để lập kế hoạch xóa).
- `raw/<sub>/*` (để liệt kê các xóa raw).

### Ghi
- Xóa `wiki/<entity>/*.md` (giữ lại `.gitkeep`).
- Viết lại `wiki/index.md`, `wiki/graph/*`, tùy chọn `wiki/log.md`.
- Xóa `raw/<sub>/*` (trừ `.gitkeep`).

## Quy Trình Làm Việc

**Điều kiện tiên quyết**: thư mục làm việc chứa `wiki/`, `tools/`. Đặt `WIKI_ROOT=wiki/`.

### Bước 1: Xây dựng kế hoạch xóa (dry-run)

```bash
python3 tools/reset_wiki.py --scope <phạm-vi>
```

Điều này in ra kế hoạch JSON liệt kê mọi tệp sẽ bị xóa hoặc đặt lại, **mà không sửa đổi bất cứ thứ gì**. Hiển thị kế hoạch cho người dùng theo nhóm phạm vi (thư mục thực thể wiki, thư mục con raw, log, checkpoints).

### Bước 2: Xác nhận với người dùng

In ra tóm tắt kế hoạch và yêu cầu xác nhận rõ ràng:

```
Sắp xóa N tệp và đặt lại M tệp. Tiếp tục? [y/N]
```

Nếu người dùng nói không, thoát. **Không bao giờ tiếp tục mà không có sự chấp thuận rõ ràng** — `/reset` có tính phá hủy và việc xóa `raw/` không được git theo dõi.

### Bước 3: Thực thi

```bash
python3 tools/reset_wiki.py --scope <phạm-vi> --yes
```

Công cụ in ra báo cáo trạng thái JSON (`{deleted_files, reset_files}`).

### Bước 4: Ghi nhật ký (trừ khi phạm vi `log` được đặt lại)

Nếu phạm vi thực thi không bao gồm `log`, thêm một mục nhật ký để các phiên sau có thể thấy việc đặt lại đã xảy ra:

```bash
python3 tools/research_wiki.py log wiki/ "reset | phạm vi: <phạm-vi>"
```

### Bước 5: Báo cáo

In ra kết quả và đề xuất các bước tiếp theo:

```
## Đặt lại hoàn tất — phạm vi: <phạm-vi>

Đã xóa: N tệp
Đã đặt lại:   M tệp

Các bước tiếp theo:
- /init       — khởi tạo wiki từ raw/
- /prefill    — gieo nền tảng kiến thức cơ bản
- /ingest     — thêm một nguồn thủ công
```

## Các Ràng Buộc

- **Xác nhận trước khi hành động phá hủy**: không bao giờ gọi `--yes` mà không hiển thị kế hoạch và hỏi người dùng.
- **Bảo tồn**: các placeholder `.gitkeep`, `wiki/CLAUDE.md`, `.claude/` (không bao giờ chạm vào kỹ năng).
- **Xóa `raw/` không thể hoàn tác**: các tệp PDF không có trong lịch sử git. Cảnh báo người dùng trước khi thực thi phạm vi `raw` hoặc `all`.
- **`/reset` không chạm vào `tools/`, `mcp-servers/`, `i18n/`, `.env` hoặc trạng thái git.**
- **Phạm vi là bắt buộc**: không có hành động mặc định (`/reset` không có cờ sẽ nhắc nhập phạm vi thay vì đoán).

## Xử Lý Lỗi

- **Phạm vi không xác định**: in ra các phạm vi hợp lệ và thoát với mã lỗi.
- **Thiếu thư mục wiki**: báo cáo và đề xuất chạy `/init`.
- **Lỗi `checkpoint-clear`**: ghi lại cảnh báo nhưng không làm lỗi các phạm vi khác.

## Phụ Thuộc

### Công cụ (qua Bash)
- `python3 tools/reset_wiki.py --scope <phạm-vi> [--yes] [--project-root .]` — công cụ hỗ trợ phá hủy xác định
- `python3 tools/research_wiki.py log wiki/ "<thông-điệp>"` — thêm nhật ký
- `reset_wiki.py` xóa trực tiếp `wiki/.checkpoints/*.json` cho phạm vi `checkpoints` (không gọi CLI — lệnh con `checkpoint-clear` yêu cầu `task_id` cụ thể, trong khi ngữ nghĩa `/reset --scope checkpoints` là "xóa tất cả")