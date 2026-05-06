# Tiêu Chí Đánh Giá Thí Nghiệm

Tài liệu này định nghĩa các tiêu chí có cấu trúc được sử dụng bởi `/exp-eval` để đánh giá kết quả thí nghiệm. Quá trình đánh giá ánh xạ kết quả vào các khẳng định, cập nhật điểm độ tin cậy và điều khiển quy trình nghiên cứu.

---

## Các Chiều Đánh Giá Cốt Lõi

| Chiều          | Mô Tả                                                                                     | Điểm (0-1)                              |
|----------------|-------------------------------------------------------------------------------------------|-----------------------------------------|
| **Tính Hợp Lệ** | Thí nghiệm có kiểm tra đúng khẳng định mục tiêu không?                                    | 0: Có lỗi, 1: Hợp lệ                    |
| **Tính Tái Lập** | Kết quả có nhất quán trên các lần chạy và môi trường không?                               | 0: Không nhất quán, 1: Có thể tái lập   |
| **Tính Ý Nghĩa** | Các hiệu ứng quan sát được có ý nghĩa thống kê hoặc thực tiễn không?                     | 0: Không đáng kể, 1: Có ý nghĩa         |
| **Tính Mới Lạ**  | Kết quả có cung cấp cái nhìn mới hoặc xác nhận kiến thức hiện có không?                   | 0: Dư thừa, 1: Mới lạ                   |
| **Tính Mạnh Mẽ** | Kết quả có duy trì dưới các nhiễu loạn (nhiễu, siêu tham số, dữ liệu) không?             | 0: Mỏng manh, 1: Mạnh mẽ                |

---

## Các Đường Dẫn Phán Quyết

### 1. **Hỗ Trợ Khẳng Định**
- **Điều Kiện**:
  - Tính Hợp Lệ = 1
  - Tính Ý Nghĩa = 1
  - Hướng hiệu ứng phù hợp với khẳng định
- **Hành Động**:
  - Tăng độ tin cậy của khẳng định (+0.2, giới hạn ở 0.95)
  - Thêm cạnh `supports` vào đồ thị
  - Đánh dấu các ý tưởng liên quan là `khả thi`

### 2. **Mâu Thuẫn Với Khẳng Định**
- **Điều Kiện**:
  - Tính Hợp Lệ = 1
  - Tính Ý Nghĩa = 1
  - Hướng hiệu ứng trái ngược với khẳng định
- **Hành Động**:
  - Giảm độ tin cậy của khẳng định (-0.3, tối thiểu ở 0.05)
  - Thêm cạnh `contradicts` vào đồ thị
  - Đánh dấu các ý tưởng liên quan là `không hợp lệ` (nếu độ tin cậy < 0.2)

### 3. **Không Kết Luận**
- **Điều Kiện**:
  - Tính Hợp Lệ = 1 nhưng Tính Ý Nghĩa = 0, **HOẶC**
  - Tính Tái Lập = 0
- **Hành Động**:
  - Không thay đổi độ tin cậy của khẳng định
  - Thêm cạnh `tested_by` với `result: inconclusive`
  - Kích hoạt `/exp-design` để tinh chỉnh hoặc thiết kế lại thí nghiệm

### 4. **Không Hợp Lệ**
- **Điều Kiện**:
  - Tính Hợp Lệ = 0
- **Hành Động**:
  - Không thay đổi độ tin cậy của khẳng định
  - Thêm cạnh `tested_by` với `result: invalid`
  - Đánh dấu thí nghiệm là `thất bại` với `failure_reason`

---

## Quy Tắc Cập Nhật Độ Tin Cậy

```json
{
  "confidence_update": {
    "supports": {
      "delta": 0.2,
      "cap": 0.95
    },
    "contradicts": {
      "delta": -0.3,
      "floor": 0.05
    },
    "inconclusive": {
      "delta": 0.0
    }
  }
}
```

---

## Tạo Tác Phẩm Đầu Ra

### Các Cạnh Đồ Thị

```jsonl
{"source": "experiment:flash-attention-speedup", "target": "claim:flash-attention-2x-faster", "type": "supports", "weight": 0.85}
{"source": "experiment:adversarial-pgd-attack", "target": "claim:robustness-against-pgd", "type": "contradicts", "weight": 0.3}
```

### Cập Nhật Wiki

- **Khẳng Định**: Cập nhật trường `evidence` với kết quả thí nghiệm và điểm độ tin cậy mới.
- **Ý Tưởng**: Đặt `status` thành `khả thi` hoặc `không hợp lệ` dựa trên độ tin cậy của khẳng định.
- **Thí Nghiệm**: Đặt `status` thành `đã hoàn thành` và ghi lại `result_summary`.

---

## Mẫu Lời Nhắc Cho Review LLM

```text
Bạn là một người đánh giá độc lập đánh giá kết quả thí nghiệm để xác định sự phù hợp với các khẳng định.

**Đầu Vào**:
- Khẳng Định: {claim_text}
- Thiết Kế Thí Nghiệm: {experiment_design}
- Kết Quả: {results}

**Nhiệm Vụ**:
1. Xác thực thiết kế thí nghiệm so với khẳng định.
2. Đánh giá tính ý nghĩa và hướng của các hiệu ứng quan sát được.
3. Gắn cờ bất kỳ mối đe dọa nào đối với tính hợp lệ hoặc tính tái lập.
4. Đưa ra phán quyết có cấu trúc (supports/contradicts/inconclusive/invalid) cùng với giải thích.

**Định Dạng Đầu Ra**:
```json
{
  "verdict": "supports|contradicts|inconclusive|invalid",
  "justification": "string",
  "scores": {
    "validity": 0.0-1.0,
    "reproducibility": 0.0-1.0,
    "significance": 0.0-1.0,
    "novelty": 0.0-1.0,
    "robustness": 0.0-1.0
  }
}
```
```