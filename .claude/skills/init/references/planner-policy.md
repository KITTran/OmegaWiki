# /init Planner Policy

Dùng reference này khi đọc `.checkpoints/init-plan.json`, cắt giảm shortlist, hoặc diễn giải các cảnh báo và lỗi của planner.

## Behavioral Policy

- Trong seeded mode, suy ra tín hiệu discovery và ranking từ titles/abstracts của local papers cộng với tín hiệu notes/web khi `topic` bị bỏ qua.
- Trong bootstrap mode, nếu cả `topic` và keywords từ notes/web đều vắng mặt, nêu planner error thay vì phát ra một empty search.
- Ưu tiên relevance, freshness, connectivity, và survey coverage.
- Ưu tiên một survey/overview khi nó cải thiện coverage.
- Trong seeded mode với limited introduced capacity, freshness nên chiếm ưu thế và các external non-survey papers cũ hơn không nên tích tụ chỉ nhờ citation advantage.
- Trong bootstrap mode hoặc các seeded cases rộng bất thường, một canonical anchor cũ hơn có thể chấp nhận được khi nó cải thiện coverage một cách đáng kể.
- Khi phát hiện nội dung ghi chú hoặc web bằng tiếng Trung, giữ planner warning rằng extraction/ranking có thể kém tin cậy hơn và coi provisional outputs là lower-confidence.
- Nếu `SEMANTIC_SCHOLAR_API_KEY` chưa được đặt, vẫn tiếp tục và giữ public-rate-limit path chậm hơn như một planner warning.

## LLM Trim Expectations

- Đọc `.checkpoints/init-plan.json` và cắt giảm rõ ràng shortlist bị over-picked trước `fetch`.
- Không bỏ qua trim step ngay cả khi shortlist đã có vẻ hợp lý.
- Phát ra final selection artifact trước `fetch` chứa `shortlist_count`, `final_count`, và danh sách `candidate_id` cuối cùng theo thứ tự shortlist.
- Nếu final count nằm ngoài range, revise selection trước `fetch` trừ khi có documented exception áp dụng.

## Source Of Truth Boundary

- `tools/init_discovery.py` là implementation authority cho weights, thresholds, shortlist constants, và scoring math chính xác.
- `SKILL.md` và reference này chỉ mô tả orchestration và behavioral expectations.
- Không duplicate numeric planner constants ở đây hoặc override tool-owned policy trong LLM reasoning.
