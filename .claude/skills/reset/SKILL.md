---
description: Đặt lại trạng thái wiki về khung sạch theo phạm vi (wiki / raw / log / checkpoints / all). Hữu ích trong quá trình phát triển hoặc khởi động lại không lo lắng sau khi thiết lập thất bại.
argument-hint: "--scope wiki|raw|log|checkpoints|all"
---

# /reset

> Đặt lại wiki về khung sạch theo phạm vi. Được thiết kế cho quá trình lặp phát triển và khôi phục sau khi thiết lập thất bại — không phải là thao tác thông thường.

## Trigger

Thủ công: `/reset --scope wiki` / `--scope raw` / `--scope log` / `--scope checkpoints` / `--scope all`. Có thể kết hợp nhiều phạm vi bằng dấu phẩy: `--scope wiki,log`.

## Inputs

- `--scope` *(bắt buộc)*: một trong các tùy chọn sau
  - `wiki` — xóa mọi tệp `*.md` trong `wiki/<entity>/` và `wiki/outputs/`, cùng với `wiki/index.md`, `wiki/log.md`, và các tệp trong `wiki/graph/`. Giữ lại `.gitkeep` và `wiki/CLAUDE.md`.
  - `raw` — xóa mọi mục trong `raw/papers/`, `raw/discovered/`, `raw/tmp/`, `raw/notes/`, `raw/web/` (trừ `.gitkeep`).
  - `log` — đặt lại `wiki/log.md` về tiêu đề trống.
  - `checkpoints` — xóa trạng thái batch thông qua `research_wiki.py checkpoint-clear`.
  - `all` — tất cả các phạm vi trên.

## Outputs

- Các tệp đã bị xóa / đặt lại trên đĩa.
- Báo cáo tóm tắt trên console về các tệp đã xóa và đặt lại.

## Wiki Interaction

### Reads

- Tất cả `wiki/<entity>/*.md` (để liệt kê kế hoạch xóa).
- `raw/<sub>/*` (để liệt kê các tệp raw cần xóa).

### Writes

- Xóa `wiki/<entity>/*.md` (giữ lại `.gitkeep`).
- Viết lại `wiki/index.md`, `wiki/graph/*`, tùy chọn `wiki/log.md`.
- Xóa `raw/<sub>/*` (trừ `.gitkeep`).

## Workflow

**Điều kiện tiên quyết**: thư mục làm việc chứa `wiki/`, `tools/`. Đặt `WIKI_ROOT=wiki/`.

### Bước 1: Xây dựng kế hoạch xóa (dry-run)

```bash
python3 tools/reset_wiki.py --scope <scope>
```

Lệnh này in ra kế hoạch JSON liệt kê mọi tệp sẽ bị xóa hoặc đặt lại, **mà không thay đổi bất kỳ thứ gì**. Hiển thị kế hoạch cho người dùng theo nhóm phạm vi (thư mục thực thể wiki, thư mục con raw, log, checkpoints).

### Bước 2: Xác nhận với người dùng

In tóm tắt kế hoạch và yêu cầu xác nhận rõ ràng:

```
Sắp xóa N tệp và đặt lại M tệp. Tiếp tục? [y/N]
```

Nếu người dùng từ chối, thoát. **Không bao giờ tiếp tục nếu không có sự chấp thuận rõ ràng** — `/reset` là thao tác phá hủy và việc xóa `raw/` không được git theo dõi.

### Bước 3: Thực thi

```bash
python3 tools/reset_wiki.py --scope <scope> --yes
```

Công cụ in báo cáo trạng thái JSON (`{deleted_files, reset_files}`).

### Bước 4: Ghi log (trừ khi phạm vi `log` đã được đặt lại)

Nếu phạm vi thực thi không bao gồm `log`, thêm một mục log để các phiên sau có thể biết việc đặt lại đã xảy ra:

```bash
python3 tools/research_wiki.py log wiki/ "reset | scope: <scope>"
```

### Bước 5: Báo cáo

In kết quả và đề xuất các bước tiếp theo:

```
## Đặt lại hoàn tất — phạm vi: <scope>

Đã xóa: N tệp
Đã đặt lại:   M tệp

Các bước tiếp theo:
- /init       — khởi tạo wiki từ raw/
- /prefill    — gieo kiến thức nền tảng
- /ingest     — thêm một nguồn thủ công
```

## Constraints

- **Xác nhận trước khi thực hiện hành động phá hủy**: không bao giờ gọi `--yes` mà không hiển thị kế hoạch và hỏi người dùng.
- **Bảo tồn**: các tệp giữ chỗ `.gitkeep`, `wiki/CLAUDE.md`, `.claude/` (không bao giờ động đến các kỹ năng).
- **Việc xóa `raw/` không thể hoàn tác**: các tệp PDF không có trong lịch sử git. Cảnh báo người dùng trước khi thực thi phạm vi `raw` hoặc `all`.
- **`/reset` không động đến `tools/`, `mcp-servers/`, `i18n/`, `.env`, hoặc trạng thái git.**
- **Phạm vi là bắt buộc**: không có hành động mặc định (`/reset` không có cờ sẽ yêu cầu nhập phạm vi thay vì đoán).

## Error Handling

- **Phạm vi không xác định**: in các phạm vi hợp lệ và thoát với mã lỗi khác không.
- **Thiếu thư mục wiki**: báo cáo và đề xuất chạy `/init`.
- **Lỗi `checkpoint-clear`**: ghi lại cảnh báo nhưng không làm thất bại các phạm vi khác.

## Dependencies

### Tools (thông qua Bash)

- `python3 tools/reset_wiki.py --scope <scope> [--yes] [--project-root .]` — công cụ hỗ trợ phá hủy xác định
- `python3 tools/research_wiki.py log wiki/ "<message>"` — thêm log
- `reset_wiki.py` xóa trực tiếp `wiki/.checkpoints/*.json` cho phạm vi `checkpoints` (không gọi CLI — lệnh con `checkpoint-clear` yêu cầu `task_id` cụ thể, trong khi ngữ nghĩa `/reset --scope checkpoints` là "xóa tất cả")