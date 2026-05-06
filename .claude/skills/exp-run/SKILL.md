---
description: Quy trình thực thi thí nghiệm đầy đủ — chuẩn bị mã → triển khai → giám sát → thu thập kết quả, hỗ trợ ba chế độ chạy
argument-hint: "<slug-thí-nghiệm> [--review] [--collect] [--full] [--env local|remote]"
---

# /exp-run

> Thực thi một thí nghiệm đã được lên kế hoạch trong wiki/experiments/.
> **Ba chế độ chạy** cho các tình huống khác nhau:
> - **Mặc định (triển khai)**: Chỉ Giai đoạn 1-2 — triển khai và trả về ngay. Phù hợp nhất cho các thí nghiệm kéo dài hàng giờ hoặc ngày.
> - **`--collect`**: Chỉ Giai đoạn 3-4 — kiểm tra xem thí nghiệm đã triển khai có hoàn thành chưa; thu thập kết quả nếu có (`--check` là bí danh).
> - **`--full`**: Cả bốn giai đoạn từ đầu đến cuối. Phù hợp nhất cho các thí nghiệm cục bộ ngắn kết thúc trong vài phút.
>
> Quy trình đề xuất: `/exp-run <slug>` để triển khai → `/exp-status` để giám sát → `/exp-run <slug> --collect` để thu thập.

## Đầu Vào

- `experiment`: slug từ wiki/experiments/
  - chế độ triển khai: trạng thái phải là `planned`
  - chế độ --collect: trạng thái phải là `running`
  - chế độ --full: trạng thái phải là `planned`
- `--review` *(tùy chọn)*: kích hoạt đánh giá mã Review LLM cho mã thí nghiệm trong Giai đoạn 1 (hợp lệ trong chế độ triển khai / full)
- `--collect` *(tùy chọn)*: chế độ thu thập — kiểm tra xem thí nghiệm đã hoàn thành chưa và thu thập kết quả; `--check` là bí danh
- `--full` *(tùy chọn)*: chế độ đầy đủ — thực thi cả 4 giai đoạn (phù hợp nhất cho các thí nghiệm cục bộ nhanh)
- `--env local|remote` *(tùy chọn, mặc định `local`)*: môi trường triển khai
  - `local`: chạy trực tiếp trên GPU cục bộ
  - `remote`: triển khai đến máy từ xa qua SSH (yêu cầu `config/server.yaml`)

## Đầu Ra

- **chế độ triển khai**:
  - Mã thí nghiệm: `experiments/code/{slug}/` (được tạo trong Giai đoạn 1)
  - `wiki/experiments/{slug}.md` — trạng thái: planned → running
  - **DEPLOY_REPORT** *(in ra terminal)* — xác nhận triển khai, thông tin phiên, bước tiếp theo
  - `wiki/log.md` — thêm nhật ký triển khai
- **chế độ thu thập** (thí nghiệm đã hoàn thành):
  - `wiki/experiments/{slug}.md` — trạng thái: running → completed; outcome/key_result/date_completed được điền
  - **RUN_REPORT** *(in ra terminal)* — tóm tắt kết quả, so sánh chỉ số, gợi ý bước tiếp theo
  - `wiki/log.md` — thêm nhật ký thu thập
- **chế độ thu thập** (thí nghiệm vẫn đang chạy):
  - Báo cáo tiến độ chỉ in ra terminal; wiki không được sửa đổi
- **chế độ đầy đủ**: tất cả đầu ra từ cả triển khai và thu thập

## Tương Tác Wiki

### Đọc

- `wiki/experiments/{slug}.md` — cấu hình thí nghiệm: setup, metrics, baseline, hypothesis, target_claim
- `wiki/claims/{target-claim}.md` — ngữ cảnh khẳng định mục tiêu (hiểu mục đích thí nghiệm)
- `wiki/ideas/{linked-idea}.md` — bản phác thảo cách tiếp cận của ý tưởng liên kết (hướng dẫn triển khai mã)
- `wiki/papers/*.md` — chi tiết phương pháp và siêu tham số của các bài báo liên quan (tham khảo triển khai)
- `wiki/experiments/*.md` — các thí nghiệm khác trên cùng khẳng định (tham khảo thiết lập, tránh các lỗi đã biết)

### Ghi

- `experiments/code/{slug}/` — thư mục mã thí nghiệm (Giai đoạn 1, chế độ triển khai / đầy đủ)
  - `experiments/code/{slug}/train.py` — tập lệnh huấn luyện/dự đoán chính
  - `experiments/code/{slug}/config.yaml` — tệp cấu hình siêu tham số
  - `experiments/code/{slug}/run.sh` — tập lệnh wrapper khởi chạy (bao gồm CUDA_VISIBLE_DEVICES, v.v.)
  - `experiments/code/{slug}/requirements.txt` — các phụ thuộc (nếu khác với dự án chính)
- `wiki/experiments/{slug}.md` — cập nhật trạng thái, outcome, key_result, date_completed, run_log, khối remote
- `wiki/log.md` — thêm nhật ký hoạt động

### Các cạnh đồ thị được tạo

- **Không có**. Các cạnh tested_by giữa thí nghiệm và khẳng định được tạo bởi /exp-design.

## Quy Trình Làm Việc

**Điều kiện tiên quyết**: xác nhận thư mục làm việc là thư mục gốc dự án wiki (thư mục chứa `wiki/`, `raw/`, `tools/`).

---

### Chế Độ Triển Khai (mặc định, trạng thái == planned)

**Giai đoạn 1: Chuẩn Bị**

1. **Đọc trang thí nghiệm**:
   - `wiki/experiments/{slug}.md`: trích xuất setup (model, dataset, hardware, framework), metrics, baseline, hypothesis
   - Xác minh trạng thái == `planned`
   - Nếu trạng thái là `running`, nhắc người dùng sử dụng chế độ `--collect`
   - Nếu trạng thái là `completed`/`abandoned`, từ chối thực thi

2. **Tải ngữ cảnh triển khai**:
   - Đọc bản phác thảo cách tiếp cận của ý tưởng liên kết (hướng dẫn triển khai)
   - Đọc mô tả phương pháp của các bài báo liên quan (chi tiết thuật toán)
   - Đọc các thí nghiệm khác trên cùng khẳng định (tham khảo cấu trúc mã)

3. **Viết mã thí nghiệm** vào `experiments/code/{slug}/`:
   - `train.py`: tạo tập lệnh huấn luyện/đánh giá dựa trên cấu hình setup, bao gồm:
     - Phân tích đối số (argparse, tất cả siêu tham số có thể cấu hình)
     - Tải dữ liệu (hỗ trợ setup.dataset)
     - Khởi tạo mô hình (hỗ trợ setup.model và mô hình baseline)
     - Vòng lặp huấn luyện/dự đoán
     - Tính toán chỉ số (khớp với danh sách metrics)
     - Lưu kết quả (định dạng JSON, đường dẫn: `results/{slug}/seed_{N}.json`)
     - Kiểm soát seed ngẫu nhiên (chạy nhiều seed)
     - Lưu/khôi phục checkpoint (`checkpoints/{slug}/`)
   - `config.yaml`: tất cả siêu tham số (learning_rate, batch_size, epochs, seeds, v.v.)
   - `run.sh`: lệnh wrapper khởi chạy hoàn chỉnh (bao gồm CUDA_VISIBLE_DEVICES, ghi nhật ký, kích hoạt conda)
   - `requirements.txt`: các phụ thuộc cụ thể cho thí nghiệm (nếu khác với yêu cầu của dự án chính)

4. **Đánh giá mã Review LLM tùy chọn** (`--review`):
   ```
   mcp__llm-review__chat:
     system: "Bạn là một kỹ sư ML cao cấp đang đánh giá mã thí nghiệm.
              Tập trung vào: tính đúng đắn của vòng lặp huấn luyện, giao thức đánh giá chính xác,
              so sánh baseline công bằng, tính tái lập (seed, tính xác định),
              tính toán chỉ số chính xác, và các lỗi phổ biến (rò rỉ dữ liệu,
              phân chia sai, lỗi tích lũy gradient)."
     message: |
       ## Thí Nghiệm
       {tiêu đề thí nghiệm và giả thuyết}

       ## Mã
       {mã được tạo}

       ## Hành Vi Mong Đợi
       {chi tiết thiết lập từ trang wiki}

       Đánh giá tính chính xác và các vấn đề tiềm ẩn.
   ```
   Sửa mã dựa trên phản hồi của Review LLM.

5. **Kiểm tra tính hợp lý (xác thực quy mô nhỏ)**:
   - Chạy ở quy mô tối thiểu (1 epoch / 100 bước / tập con nhỏ)
   - Xác minh: không crash mã, dữ liệu tải đúng, GPU khả dụng, loss giảm
   - Nếu kiểm tra tính hợp lý thất bại → sửa mã, thử lại một lần; nếu vẫn thất bại, báo lỗi và dừng

**Giai đoạn 2: Triển Khai**

#### Chế độ cục bộ (`--env local` hoặc mặc định)

1. **Kiểm tra GPU**: `nvidia-smi` để xác nhận GPU khả dụng và đủ VRAM
2. **Khởi chạy**:
   ```bash
   screen -dmS exp-{slug} bash -c \
     "cd $(pwd) && bash experiments/code/{slug}/run.sh 2>&1 | tee logs/exp-{slug}.log"
   ```
3. Cập nhật `wiki/experiments/{slug}.md`:
   - trạng thái: `running`
   - run_log: `logs/exp-{slug}.log`
4. **Ước tính thời gian chạy** và ghi vào frontmatter:
   Ước tính dựa trên `setup.hardware` (mô hình/count GPU), `setup.model` (số lượng tham số), `setup.dataset` (quy mô):

   | Tình huống điển hình | Phạm vi ước tính |
   |-----------------|-----------------|
   | Single GPU + tập dữ liệu nhỏ (CIFAR / benchmark NLP nhỏ) | 0.5 – 3h |
   | Single A100 + tập dữ liệu trung bình (ImageNet / GLUE) | 4 – 12h |
   | Multi-GPU hoặc fine-tuning mô hình lớn (≥7B) | 8 – 48h |

   ```bash
   python3 tools/research_wiki.py set-meta \
     wiki/experiments/{slug}.md started "{YYYY-MM-DDTHH:MM}"
   python3 tools/research_wiki.py set-meta \
     wiki/experiments/{slug}.md estimated_hours {N}
   ```
5. Thêm nhật ký:
   ```bash
   python3 tools/research_wiki.py log wiki/ \
     "exp-run | triển khai {slug} | env: local | phiên: exp-{slug} | eta: {N}h"
   ```

#### Chế độ từ xa (`--env remote`)

**Điều kiện tiên quyết**: người dùng đã cấu hình `config/server.yaml`.

1. **Xác nhận kết nối**: `python3 tools/remote.py status`
   - Nếu không thể kết nối → báo lỗi và đề xuất kiểm tra config/server.yaml
2. **Tìm GPU trống**: `python3 tools/remote.py gpu-status`
   - Nếu không có GPU trống → báo cáo tình trạng sử dụng của từng GPU, đề xuất chờ đợi
3. **Đồng bộ mã**: `python3 tools/remote.py sync-code`
4. **Cài đặt phụ thuộc** (lần đầu hoặc nếu requirements thay đổi): `python3 tools/remote.py setup-env`
5. **Khởi chạy thí nghiệm từ xa**:
   ```bash
   python3 tools/remote.py launch \
     --name "exp-{slug}" \
     --cmd "bash experiments/code/{slug}/run.sh" \
     --gpu {gpu_index}
   ```
6. Cập nhật `wiki/experiments/{slug}.md` frontmatter — tất cả các trường này đã tồn tại (trống) vì `/exp-design` đã viết mẫu CLAUDE.md đầy đủ:
   ```bash
   # Các trường vô hướng cấp cao — sử dụng set-meta
   python3 tools/research_wiki.py set-meta wiki/experiments/{slug}.md status running
   python3 tools/research_wiki.py set-meta wiki/experiments/{slug}.md run_log "logs/exp-{slug}.log"
   ```

   Khối `remote:` lồng nhau không thể cập nhật qua `set-meta` (chỉ xử lý các trường vô hướng cấp cao). Sử dụng công cụ `Edit` trực tiếp để thay thế năm giá trị trường con trống tại chỗ. Khối đã tồn tại trong tệp trông như sau:
   ```yaml
   remote:
     server: ""
     gpu: ""
     session: ""
     started: ""
     completed: ""
   ```
   Sử dụng năm lệnh Edit (một cho mỗi trường con) để đặt `server`, `gpu`, `session`, `started`. Để `completed: ""` — Giai đoạn 4 sẽ điền trường này. Nếu bạn thấy khối `remote:` bị thiếu trong tệp, điều đó có nghĩa là `/exp-design` không viết mẫu CLAUDE.md đầy đủ; dừng lại và báo cáo lỗi thay vì cố gắng thêm khối tại đây (việc thêm sẽ làm lệch tệp khỏi thứ tự chính tắc và phá vỡ các chỉnh sửa trong tương lai).

7. **Ước tính thời gian chạy** và ghi vào frontmatter (cùng logic ước tính như chế độ cục bộ):
   ```bash
   python3 tools/research_wiki.py set-meta \
     wiki/experiments/{slug}.md started "{YYYY-MM-DDTHH:MM}"
   python3 tools/research_wiki.py set-meta \
     wiki/experiments/{slug}.md estimated_hours {N}
   ```
8. Thêm nhật ký:
   ```bash
   python3 tools/research_wiki.py log wiki/ \
     "exp-run | triển khai {slug} | env: remote | máy chủ: {host} | gpu: {gpu} | eta: {N}h"
   ```

**In DEPLOY_REPORT ra terminal**:

```markdown
# Báo Cáo Triển Khai: {tiêu đề thí nghiệm}

### Trạng Thái: ĐÃ TRIỂN KHAI ✅

- Phiên: exp-{slug}
- Môi trường: local | remote ({host} GPU {gpu})
- Tệp nhật ký: logs/exp-{slug}.log
- Mã: experiments/code/{slug}/
- Ước tính: ~{N}h (dự kiến hoàn thành: {YYYY-MM-DD HH:MM})

### Bước Tiếp Theo

1. Giám sát tiến độ: `/exp-status`
2. Kiểm tra thí nghiệm này: `/exp-run {slug} --collect`
3. Trong quy trình /research: tiến độ được lưu vào wiki/outputs/pipeline-progress.md

### Lệnh Nhanh
```bash
# Cục bộ: kiểm tra xem vẫn đang chạy không
screen -ls | grep exp-{slug}

# Cục bộ: theo dõi nhật ký
tail -f logs/exp-{slug}.log
```
```

---

### Chế Độ Thu Thập (`--collect` hoặc `--check`, trạng thái == running)

**Giai đoạn 3: Giám Sát / Kiểm Tra Trạng Thái Chạy**

1. **Đọc thông tin triển khai**: từ `wiki/experiments/{slug}.md` frontmatter, lấy môi trường (cục bộ hoặc từ xa) và tên phiên.

2. **Kiểm tra xem tiến trình còn sống không**:
   - **Cục bộ**: `screen -ls | grep exp-{slug}`
   - **Từ xa**: `python3 tools/remote.py check --name "exp-{slug}"`, phân tích trường `alive`

3. **Nếu thí nghiệm vẫn đang chạy (alive == true)**:
   - Lấy nhật ký gần đây:
     - Cục bộ: `tail -30 logs/exp-{slug}.log`
     - Từ xa: `python3 tools/remote.py tail-log --name "exp-{slug}" --lines 30`
   - **Phát hiện bất thường**:
     - NaN loss: phát hiện `loss: nan`
     - OOM: `CUDA out of memory`
     - Traceback: ngăn xếp ngoại lệ Python
     - Inf loss: `loss: inf`
   - **Cố gắng sửa tự động** (nếu phát hiện bất thường, tối đa 1 lần):
     - NaN/nổ → khôi phục từ checkpoint mới nhất, giảm learning rate
     - OOM → giảm batch size, khởi động lại
   - **In báo cáo tiến độ** (không sửa đổi wiki, chỉ báo cáo):
     ```
     Thí nghiệm {slug}: ĐANG CHẠY
     Tiến độ: bước {N} / epoch {E}
     Chỉ số mới nhất: {metric} = {value}
     Bất thường: {không có | phát hiện NaN | ...}
     Ước tính còn lại: ~{N} giờ
     Chạy `/exp-status` để giám sát tất cả các thí nghiệm đang chạy.
     ```
   - **Trả về** (không thực thi Giai đoạn 4)

4. **Nếu thí nghiệm đã hoàn thành (alive == false / phiên đã kết thúc)**:
   - Tiếp tục Giai đoạn 4

**Giai đoạn 4: Thu Thập Kết Quả**

1. **Kéo kết quả từ xa** (chỉ chế độ từ xa):
   ```bash
   python3 tools/remote.py pull-results \
     --remote-path "results/{slug}/" \
     --local-path "./results/{slug}/"

   python3 tools/remote.py pull-results \
     --remote-path "logs/exp-{slug}.log" \
     --local-path "./logs/"
   ```

2. **Kiểm tra tệp kết quả tồn tại**: `results/{slug}/seed_*.json`

3. **Phân tích kết quả**:
   - Đọc tệp kết quả (JSON)
   - Tính trung bình ± độ lệch chuẩn cho mỗi chỉ số (trên các seed)
   - So sánh với baseline, tính toán delta cải thiện

4. **Cập nhật trang thí nghiệm** `wiki/experiments/{slug}.md`:
   - trạng thái: `completed`
   - outcome: `succeeded` / `failed` / `inconclusive`
     - succeeded: tất cả tiêu chí thành công được đáp ứng
     - failed: các chỉ số cốt lõi không đạt mục tiêu
     - inconclusive: kết quả hỗn hợp hoặc phương sai quá lớn
   - key_result: tóm tắt một câu về phát hiện cốt lõi
   - date_completed: ngày hôm nay
   - Điền phần `## Kết Quả`: bảng kết quả đầy đủ
   - Điền phần `## Phân Tích`: phân tích sơ bộ
   - Nếu chế độ từ xa: cập nhật dấu thời gian `remote.completed`

5. **Thêm nhật ký**:
   ```bash
   python3 tools/research_wiki.py log wiki/ \
     "exp-run | hoàn thành {slug} | kết quả: {outcome} | điểm chính: {key_result}"
   ```

6. **In RUN_REPORT ra terminal**:
   ```markdown
   # Báo Cáo Chạy: {tiêu đề thí nghiệm}

   ## Kết Quả: {succeeded / failed / inconclusive}

   ## Kết Quả
   | Chỉ số | Baseline | Của chúng tôi (trung bình±độ lệch) | Δ |
   |--------|----------|-----------------|---|
   | {metric} | {baseline-value} | {mean}±{std} | +{delta} |

   ## Phát Hiện Chính
   {key_result}

   ## Bước Tiếp Theo
   - Chạy `/exp-eval {slug}` để cập nhật khẳng định trong wiki
   - {nếu succeeded: tiến hành thí nghiệm tiếp theo trong kế hoạch}
   - {nếu failed: phân tích thất bại, cân nhắc sửa đổi /exp-design}
   ```

---

### Chế Độ Đầy Đủ (`--full`, trạng thái == planned)

Thực thi cả 4 giai đoạn theo trình tự (Giai đoạn 1 → Giai đoạn 2 → Giai đoạn 3 → Giai đoạn 4) mà không trả về.

Trường hợp sử dụng: các thí nghiệm cục bộ nhanh trên CPU/GPU kết thúc trong vài phút (kiểm tra tính hợp lý, xác thực tập dữ liệu đồ chơi, v.v.).

Trong Giai đoạn 3, thay vì kiểm tra "có còn đang chạy không", chờ phiên screen thực sự kết thúc trước khi thực thi Giai đoạn 4:
```bash
# Chờ phiên kết thúc (kiểm tra định kỳ)
while screen -ls | grep -q "exp-{slug}"; do
  sleep 30
done
# Phiên đã kết thúc, tiến hành Giai đoạn 4
```

---

## Các Ràng Buộc

- **Chế độ triển khai chỉ chấp nhận các thí nghiệm planned**: nếu trạng thái là running, nhắc sử dụng --collect; nếu completed, từ chối
- **Chế độ thu thập chỉ chấp nhận các thí nghiệm running**: nếu trạng thái là planned, nhắc triển khai trước; nếu completed, ghi chú đã hoàn thành
- **Chế độ thu thập: không ghi wiki khi còn sống**: chỉ báo cáo tiến độ, không sửa đổi bất kỳ tệp wiki nào
- **Mã nằm trong experiments/code/{slug}/**: không ghi vào thư mục gốc dự án hoặc bất kỳ vị trí nào khác
- **Không cập nhật khẳng định**: kết quả thí nghiệm chỉ được ghi vào các trang experiments/; cập nhật khẳng định được xử lý bởi /exp-eval
- **Kiểm tra tính hợp lý phải vượt qua**: thất bại kiểm tra tính hợp lý trong Giai đoạn 1 chặn triển khai (trừ khi người dùng ghi đè rõ ràng)
- **Kết quả phải được lưu**: tất cả kết quả thí nghiệm được lưu dưới dạng JSON trong `results/{slug}/seed_{N}.json`
- **Kết quả nhiều seed sử dụng trung bình**: báo cáo trung bình ± độ lệch chuẩn, không phải kết quả chạy đơn lẻ
- **Các cạnh đồ thị không được tạo tại đây**: các cạnh tested_by được tạo bởi /exp-design
- **Cố gắng sửa tự động giới hạn ở 1 lần**: ngăn chặn vòng lặp khởi động lại vô hạn

## Xử Lý Lỗi

- **Không tìm thấy thí nghiệm**: nhắc người dùng kiểm tra slug, liệt kê các ứng viên trong wiki/experiments/ (trạng thái=planned hoặc running)
- **Chế độ triển khai nhưng trạng thái == running**: nhắc "đã đang chạy — sử dụng `/exp-run {slug} --collect` để kiểm tra trạng thái"
- **Chế độ thu thập nhưng trạng thái == completed**: nhắc "đã hoàn thành — chạy `/exp-eval {slug}` trực tiếp"
- **GPU không khả dụng**: báo lỗi, đề xuất sử dụng --env remote hoặc chờ GPU trống
- **Review LLM không khả dụng** (chế độ --review): bỏ qua đánh giá mã, ghi chú "chưa được đánh giá" trong DEPLOY_REPORT
- **Kiểm tra tính hợp lý thất bại**: báo lỗi chi tiết, cố gắng sửa tự động một lần, nếu vẫn thất bại dừng lại và đề xuất gỡ lỗi thủ công
- **Kết nối từ xa thất bại**: báo lỗi SSH, đề xuất kiểm tra cấu hình kết nối và config/server.yaml
- **Thiếu tệp kết quả** (chế độ thu thập): báo cáo seed nào thiếu kết quả; tóm tắt kết quả có sẵn bình thường; nếu seed thành công < 2, đánh dấu inconclusive
- **Thí nghiệm bị crash** (phát hiện traceback trong chế độ thu thập): bao gồm thông tin crash và hướng sửa đề xuất trong báo cáo
- **Chế độ --full chờ quá thời gian**: nếu phiên screen tồn tại quá 2× thời gian ước tính, cảnh báo người dùng nhưng không ép kết thúc