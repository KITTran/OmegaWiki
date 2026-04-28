---
description: Xem trạng thái của tất cả các thí nghiệm đang chạy; tùy chọn tự động thu thập các thí nghiệm đã hoàn thành và tiến hành pipeline
argument-hint: "[--pipeline <slug>] [--collect-ready] [--auto-advance]"
---

# /exp-status

> Điểm nhập giám sát trạng thái thí nghiệm thống nhất.
> Quét tất cả các thí nghiệm `running`, thực hiện kiểm tra trạng thái trực tiếp trên từng thí nghiệm (phiên screen / SSH),
> và xuất ra bảng trạng thái (alive / anomaly / completed) để hướng dẫn hành động tiếp theo của người dùng.
>
> Khi được sử dụng với `/research --auto`, hoạt động như một trình kiểm tra định kỳ được lên lịch bởi CronCreate:
> khi tất cả các thí nghiệm trong một pipeline đã hoàn thành, tự động kích hoạt `/research --start-from stage4`.

## Đầu Vào

- Không có đối số (mặc định): kiểm tra tất cả các thí nghiệm `running`, in bảng trạng thái
- `--pipeline <slug>` *(tùy chọn)*: chỉ kiểm tra các thí nghiệm thuộc pipeline được chỉ định; thêm in tiến độ tổng thể của pipeline
- `--collect-ready` *(tùy chọn)*: tự động gọi `/exp-run --collect` cho tất cả các thí nghiệm có phiên đã kết thúc
- `--auto-advance` *(tùy chọn, yêu cầu `--pipeline <slug>`)*: nếu tất cả các thí nghiệm trong pipeline đã `completed`,
  tự động kích hoạt `/research --start-from stage4` mà không chờ người dùng

## Đầu Ra

- **Báo cáo trạng thái** *(đầu ra terminal, tất cả chế độ)*: danh sách các thí nghiệm ở trạng thái running/anomaly/completed
- `wiki/experiments/{slug}.md` — cập nhật (outcome/key_result/status) khi `--collect-ready` kích hoạt Giai đoạn 4
- `wiki/outputs/pipeline-progress.md` — `--auto-advance` cập nhật current_stage → stage4 (được thực hiện nội bộ bởi /research --start-from stage4)
- `wiki/log.md` — thêm nhật ký kiểm tra trạng thái

## Tương Tác Wiki

### Đọc

- `wiki/experiments/*.md` — status, frontmatter remote (server/session/started), date_planned
- `wiki/outputs/pipeline-progress.md` — trong chế độ `--pipeline`, xác định các thí nghiệm mục tiêu và monitoring_cron_id

### Ghi

- `wiki/experiments/{slug}.md` — cập nhật qua /exp-run --collect trong chế độ `--collect-ready`
- `wiki/outputs/pipeline-progress.md` — cập nhật bởi /research khi `--auto-advance` kích hoạt Giai đoạn 4
- `wiki/log.md` — thêm nhật ký kiểm tra trạng thái

### Các cạnh đồ thị được tạo

- Không có (các ghi kết quả được kích hoạt gián tiếp qua /exp-run --collect không tạo ra các cạnh mới)

## Quy Trình Làm Việc

**Điều kiện tiên quyết**: xác nhận thư mục làm việc là thư mục gốc dự án wiki (thư mục chứa `wiki/`, `raw/`, `tools/`).

### Bước 1: Thu Thập Danh Sách Thí Nghiệm Mục Tiêu

1. **Xác định phạm vi kiểm tra**:
   - Nếu `--pipeline <slug>` được chỉ định:
     - Đọc `wiki/outputs/pipeline-progress.md`, trích xuất danh sách slug từ trường `stage3a_deployed`
     - Nếu tệp không tồn tại hoặc slug không khớp: báo lỗi, đề xuất chạy `/research` trước hoặc chỉ định thủ công
   - Nếu không:
     - Sử dụng Glob để quét `wiki/experiments/*.md`, lọc `status == running`

2. **Nếu không có thí nghiệm đang chạy**:
   - In thông báo thân thiện:
     ```
     Không tìm thấy thí nghiệm đang chạy.
     - Để bắt đầu một thí nghiệm: /exp-run <slug>
     - Để xem tất cả các thí nghiệm: kiểm tra wiki/experiments/
     ```
   - Trả về

### Bước 2: Kiểm Tra Trạng Thái Của Từng Thí Nghiệm

Đối với mỗi thí nghiệm mục tiêu, thực thi song song (hoặc tuần tự):

1. **Đọc trang thí nghiệm**: từ `wiki/experiments/{slug}.md` lấy:
   - Khối `remote` (nếu có, đây là thí nghiệm từ xa)
   - Đường dẫn `run_log`
   - `started` (từ `remote.started` hoặc `date_planned`, dùng để tính thời gian đã trôi qua)
   - Môi trường triển khai (có khối remote → remote, nếu không → local)

2. **Kiểm tra trạng thái tiến trình**:
   - **Cục bộ**: `screen -ls | grep "exp-{slug}"`
     - Có đầu ra → `alive: true`
     - Không có đầu ra → `alive: false` (phiên đã kết thúc)
   - **Từ xa**: `python3 tools/remote.py check --name "exp-{slug}"`
     - Phân tích JSON: `alive`, `last_lines`, `anomalies`

3. **Nếu alive == true**:
   - Lấy nhật ký gần đây (tối đa 20 dòng):
     - Cục bộ: `tail -20 {run_log}`
     - Từ xa: sử dụng `last_lines` từ phản hồi lệnh `check`
   - Trích xuất chỉ số mới nhất (loss, accuracy, step, v.v. — grep dòng chỉ số cuối cùng)
   - Phát hiện bất thường (NaN/OOM/Traceback/Inf): sử dụng trường `anomalies` từ `remote.py check` (từ xa), hoặc grep thủ công (cục bộ)
   - Tính thời gian đã trôi qua (thời gian hiện tại − started)
   - Phân loại là: `running` hoặc `anomaly`

4. **Nếu alive == false**:
   - Phân loại là: `completed_pending_collect` (phiên đã kết thúc nhưng trạng thái wiki vẫn là running)
   - Nếu trạng thái wiki đã là `completed`: phân loại là `collected`

5. **Tổng hợp kết quả**: xây dựng dict trạng thái `{slug: {state, elapsed, latest_metric, anomalies}}`

### Bước 3: In Báo Cáo Trạng Thái

```markdown
# Trạng Thái Thí Nghiệm — {YYYY-MM-DD HH:MM}

### 🔄 Đang Chạy ({N})
| Thí nghiệm | Đã trôi qua | Mới nhất | Môi trường |
|-----------|---------|--------|-----|
| [[exp-foo-baseline]] | 2.3h | loss: 0.42 | local |
| [[exp-foo-validation]] | 1.1h | step: 1200 | remote (gpu1) |

### ⚠️ Phát Hiện Bất Thường ({N})
| Thí nghiệm | Đã trôi qua | Vấn đề | Hành động |
|-----------|---------|-------|--------|
| [[exp-foo-ablation]] | 0.8h | NaN loss tại bước 500 | Chạy `/exp-run exp-foo-ablation --collect` để kiểm tra |

### ✅ Đã Hoàn Thành — Chờ Thu Thập ({N})
| Thí nghiệm | Đã kết thúc (ước tính) |
|-----------|---------------------|
| [[exp-foo-sanity]] | phiên đã kết thúc |

### 📦 Đã Thu Thập ({N})
| Thí nghiệm | Kết quả |
|-----------|---------|
| [[exp-foo-old]] | succeeded |

---
### Hành Động
```bash
# Thu thập tất cả các thí nghiệm đã hoàn thành cùng lúc:
/exp-status --collect-ready

# Thu thập một thí nghiệm cụ thể:
/exp-run exp-foo-sanity --collect

# Tiến độ pipeline (nếu trong /research):
/exp-status --pipeline {pipeline-slug}
```
```

Thêm nhật ký:
```bash
python3 tools/research_wiki.py log wiki/ \
  "exp-status | đang chạy: {N}, bất thường: {M}, chờ-thu-thập: {K}"
```

### Bước 4: --collect-ready Tự Động Thu Thập (nếu được chỉ định)

Đối với mỗi thí nghiệm `completed_pending_collect`, gọi `/exp-run --collect`:

```
Skill: exp-run
Args: "{slug} --collect"
```

Thu thập từng thí nghiệm đã hoàn thành tuần tự (không song song, để tránh ghi wiki đồng thời).

Sau khi tất cả các thu thập hoàn tất, in lại báo cáo trạng thái đã cập nhật.

### Bước 5: --auto-advance Tiến Hành Pipeline (nếu cả --pipeline và --auto-advance được chỉ định)

1. **Kiểm tra điều kiện hoàn thành pipeline**:
   - Đọc danh sách `stage3a_deployed` từ `wiki/outputs/pipeline-progress.md`
   - Kiểm tra trạng thái của `wiki/experiments/{slug}.md` của từng slug
   - **Điều kiện đáp ứng**: tất cả các thí nghiệm có trạng thái == `completed`

2. **Nếu điều kiện không được đáp ứng** (một số thí nghiệm vẫn đang chạy hoặc chờ thu thập):
   - In tiến độ hiện tại: `Pipeline {slug}: {M}/{N} thí nghiệm đã hoàn thành`
   - Trả về (không tiến hành)
   - Cron sẽ kích hoạt lại sau 30 phút

3. **Nếu điều kiện được đáp ứng (tất cả các thí nghiệm đã hoàn thành)**:

   a. **In thông báo và kích hoạt Giai đoạn 4**:
   - In:
     ```
     ✅ Tất cả các thí nghiệm đã hoàn thành cho pipeline {slug}!
     Tiến hành Giai đoạn 4 (Phán quyết & Lặp lại)...
     ```
   - Thêm nhật ký:
     ```bash
     python3 tools/research_wiki.py log wiki/ \
       "exp-status | pipeline {slug}: tất cả thí nghiệm hoàn thành, tiến hành stage4"
     ```
   - Kích hoạt giai đoạn tiếp theo:
     ```
     Skill: research
     Args: "--start-from stage4"
     ```

## Các Ràng Buộc

- **Chỉ đọc trong chế độ không có --collect-ready**: không có `--collect-ready`, không sửa đổi bất kỳ tệp wiki nào
- **`--auto-advance` yêu cầu `--pipeline`**: sử dụng `--auto-advance` một mình là không hợp lệ, báo lỗi
- **Kiểm tra trạng thái phải không chặn**: mỗi kiểm tra thí nghiệm nên hoàn thành nhanh (kiểm tra SSH đơn lẻ hoặc screen -ls)
- **Bất thường không được tự động sửa**: `/exp-status` chỉ báo cáo bất thường; sửa chữa yêu cầu người dùng gọi thủ công `/exp-run --collect`
- **pipeline-progress.md phải tồn tại**: trong chế độ `--pipeline`, nếu tệp bị thiếu, báo lỗi

## Xử Lý Lỗi

- **Không có thí nghiệm đang chạy**: in thông báo thân thiện, không phải lỗi; cung cấp gợi ý bước tiếp theo
- **`--pipeline` nhưng pipeline-progress.md không tồn tại**: báo lỗi "Không tìm thấy tệp tiến độ pipeline. Chạy `/research <direction>` trước hoặc kiểm tra wiki/outputs/"
- **`--auto-advance` không có `--pipeline`**: báo lỗi "--auto-advance yêu cầu --pipeline <slug>"
- **Kết nối SSH thất bại** (thí nghiệm từ xa): đánh dấu thí nghiệm đó là `check_failed`, ghi chú trong báo cáo, tiếp tục kiểm tra các thí nghiệm khác
- **screen -ls không trả về gì**: không có nghĩa là thí nghiệm thất bại — có thể là độ trễ ngắn; đánh dấu là `completed_pending_collect`
- **`/exp-run --collect` thất bại** (chế độ `--collect-ready`): ghi lại thất bại, tiếp tục thu thập các thí nghiệm khác, báo cáo tất cả thất bại ở cuối

## Phụ Thuộc

### Kỹ Năng (thông qua công cụ Skill)

- `/exp-run` — gọi giai đoạn thu thập trong chế độ `--collect-ready`
- `/research` — kích hoạt Giai đoạn 4 qua `--auto-advance`

### Công cụ (thông qua Bash)

- `python3 tools/remote.py check --name "exp-{slug}"` — kiểm tra trạng thái thí nghiệm từ xa
- `python3 tools/remote.py tail-log --name "exp-{slug}" --lines 20` — lấy nhật ký từ xa
- `python3 tools/research_wiki.py set-meta <path> <field> <value>` — cập nhật pipeline-progress
- `python3 tools/research_wiki.py log wiki/ "<message>"` — thêm nhật ký
- `screen -ls` — trạng thái tiến trình cục bộ
- `tail -20 {log}` — lấy nhật ký cục bộ

### Claude Code Gốc

- `Read` — đọc các trang thí nghiệm và pipeline-progress
- `Write` — cập nhật trạng thái pipeline-progress
- `Glob` — quét wiki/experiments/*.md
- `Bash` — screen/tail và các lệnh hệ thống khác
- `Skill` — gọi /exp-run --collect và /research

### Được Gọi Bởi

- Lịch trình CronCreate (được tạo bởi `/research --auto` Giai đoạn 3b: kích hoạt mỗi 30 phút)
- Người dùng trực tiếp
- `/research` Giai đoạn 3b (trong chế độ tương tác, được đề xuất cho người dùng)