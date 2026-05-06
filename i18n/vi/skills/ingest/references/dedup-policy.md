# /ingest Dedup Policy

Mở reference này khi bạn sắp tạo hoặc cập nhật một concept, claim, hoặc foundation link.

## Mental model

Một ΩmegaWiki khỏe mạnh có ít claims và concepts hơn papers rất nhiều. Mỗi concept được chia sẻ bởi nhiều papers làm sâu hoặc mở rộng nó; mỗi claim được hỗ trợ bởi nhiều papers trình bày evidence. Khi `/ingest` mặc định tạo một concept hoặc claim mới cho mỗi paper, wiki nhanh chóng biến thành một đống near-duplicates làm hỏng mọi downstream skill — survey generation, gap detection, idea novelty, citation reasoning.

Default action là **merge**. Ngoại lệ là **create**, và mỗi lần đều cần lý do rõ ràng.

## Khi nào mở reference này

- Step 4 của `/ingest`: xác định claims mà paper supports.
- Step 4 của `/ingest`: xác định concepts mà paper introduces hoặc extends.
- Bất kỳ lúc nào bạn muốn tạo concept hoặc claim mới "cho an toàn" mà chưa check.

## Tool call bắt buộc

Trước khi tạo concept hoặc claim mới, gọi dedup tool tương ứng:

```bash
"$PYTHON_BIN" tools/research_wiki.py find-similar-concept wiki/ "<candidate title>" --aliases "<a,b,c>"
"$PYTHON_BIN" tools/research_wiki.py find-similar-claim   wiki/ "<candidate title>" --tags    "<a,b,c>"
```

Cả hai tools trả về JSON list được sort theo similarity. `find-similar-concept` scan `wiki/concepts/` và `wiki/foundations/` cùng lúc và tag mỗi hit bằng `entity_type`. Tool là source of truth cho similarity score; không tự re-estimate bằng mắt.

Bỏ qua các tools này là nguyên nhân phổ biến nhất gây wiki bloat. Nếu bạn nghĩ đã biết câu trả lời từ việc đọc pages trước đó trong session, bạn vẫn phải gọi tool — paraphrases dễ trượt khỏi human scanning.

## Decision rule

Đọc `score` của top result.

- **Top result là foundation với score ≥ 0.40** — route sang foundation linking. Candidate là textbook background, không phải mechanism mới. Ghi edge `paper → foundation` với type `derived_from` và entry `[[foundation-slug]]` trong `## Related` của paper. Không sửa foundation page (foundations là terminal; xem `references/cross-references.md`). Foundation links không tính vào per-paper creation limit.
- **Score ≥ 0.80** — merge. Candidate là cùng concept hoặc claim với top result. Append paper này vào `key_papers` hoặc `evidence` list của existing page, thêm graph edge liên quan, và ghi reverse link trên paper page. Với concepts, mặc định dùng `uses_concept`, chỉ dùng `extends_concept` khi paper materially modifies/generalizes/specializes concept, và chỉ dùng `critiques_concept` cho explicit critique. Không tạo file mới.
- **Score 0.40–0.80** — đọc `## Definition` / `## Statement` của existing page và quyết định. Mặc định merge. Chỉ create khi bạn có thể chỉ ra một technical distinction cụ thể: mechanism khác, formulation khác, hoặc proposition thật sự khác. Nếu candidate là meaningful subclass của existing concept, merge và thêm bullet dưới `## Variants` thay vì split.
- **Score < 0.40 hoặc empty list** — không có match hiện có. Được phép create, tuân theo per-paper creation limit bên dưới.

Over-merging rẻ để undo: entry bị merge sai có thể split sau với history được giữ. Over-creating thì đắt: một biển near-duplicates âm thầm đầu độc mọi downstream skill và khó detect post-hoc.

## Per-paper creation limit

Mục đích của limit là giữ default behavior conservative. Nó không phải quota để lấp đầy.

- importance < 4: tối đa **1** concept mới và **1** claim mới
- importance ≥ 4: tối đa **3** concepts mới và **2** claims mới
- Foundation references không tính.

Khi các candidates tiếp theo vượt limit, merge chúng vào `find-similar-*` result gần nhất ngay cả khi score của nó thấp hơn merge threshold thường dùng. Nếu không có candidate nào đủ gần để merge an toàn, skip writing entity đó — `/check` sẽ surface resulting gaps, và user có thể quyết định có `/edit` chúng vào không.

## Ghi shape, không ghi semantics

Khi bạn tạo hoặc edit concept hoặc claim page, chạy cùng narrow shape check bạn chạy trên paper pages:

- mọi required frontmatter key có mặt và không rỗng
- `maturity` ∈ {`stable`, `active`, `emerging`, `deprecated`} cho concepts
- `status` ∈ {`proposed`, `weakly_supported`, `supported`, `challenged`, `deprecated`} và `confidence` ∈ [0,1] cho claims
- YAML parse được

Check này giúp `/check` không flag trivially malformed pages trong lần chạy tiếp theo. Bất kỳ thứ gì vượt quá — backlink symmetry, evidence của claim có thật sự đủ justify status không, `part_of` topic của concept có reciprocated không — là công việc của `/check`. Chạy các audits đó bên trong `/ingest` làm skill chậm lại và duplicate work.

## `/check` sở hữu gì, không phải `/ingest`

- cross-entity backlink symmetry (A links to B ⇒ B links back to A)
- dangling-node detection (pages được reference nhưng missing, hoặc tồn tại nhưng unreachable)
- status / confidence consistency giữa claims và experiments
- edge-type validity và edge dedup
- tiered fix recommendations cho bất kỳ vấn đề nào ở trên

Bạn có thể tin `/check` sẽ tìm các vấn đề này và tạo fix report. Tập trung `/ingest` vào emitting well-shaped entities và correct forward/reverse links tại điểm viết.
