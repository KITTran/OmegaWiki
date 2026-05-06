# /ingest Cross-References

Mở reference này khi bạn viết một link trên bất kỳ wiki page nào. Mọi forward link đều có reverse obligation (trừ foundations). Bảng dưới đây là contract.

## Forward → reverse obligation

Phản chiếu matrix trong root `CLAUDE.md` ("Cross-Reference Rules"), được rút gọn còn những edges mà `/ingest` thật sự ghi:

| Forward action (thứ bạn ghi trên page A) | Required reverse action (thứ bạn cũng ghi trên page B trong cùng turn) |
|------------------------------------------|------------------------------------------------------------------------|
| `papers/P` ghi `Related: [[concept-K]]` | `concepts/K` append `P` vào `key_papers` |
| `papers/P` ghi `[[person-R]]` (trong Key authors) | `people/R` append `P` vào `Key papers` |
| `papers/P` ghi `supports: [[claim-C]]` | `claims/C` append `{source: P, type: supports}` vào `evidence` |
| `papers/P` ghi `supports: [[claim-C]]` nhưng paper contradicts claim | dùng `type: contradicts` trong evidence entry |
| `claims/C` ghi `source_papers: [[paper-P]]` | `papers/P` append `C` vào `## Related` |
| `concepts/K` ghi `key_papers: [[paper-P]]` | `papers/P` append `K` vào `## Related` |
| bất kỳ page nào ghi `[[foundation-X]]` | **không có reverse link** — foundations là terminal |

Viết forward link mà không viết reverse là cách phổ biến nhất khiến `/check` nêu lỗi `missing-field`. Làm cả hai cùng lúc sẽ loại bỏ hẳn lớp lỗi này.

## Foundations là terminal

Không bao giờ sửa foundation page từ `/ingest`. Không có `key_papers` field, không có back-reference dưới bất kỳ dạng nào. Một paper link đến foundation chỉ để lại dấu vết ở hai nơi:

- `## Related` của paper page chứa `[[foundation-slug]]`
- `wiki/graph/edges.jsonl` chứa edge `paper → foundation` với type `derived_from`

Foundations chỉ được tạo bởi `/prefill`. `/ingest` không bao giờ tạo foundations, ngay cả khi một concept candidate trông foundational và không có match. Trong trường hợp đó, route candidate qua ordinary concept path (có thể tạo concept page mới), và để user seed foundation sau nếu họ muốn.

## Paper-to-concept semantic edges

Papers liên hệ với concepts bằng cách sử dụng, giới thiệu, mở rộng, hoặc phê bình chúng. Mọi paper-to-concept semantic edge phải có `--confidence high|medium|low`.

Chọn edge type:

- **`introduces_concept`** — strict novelty only: paper explicit đề xuất, đặt tên, định nghĩa, hoặc gọi tên concept như một contribution.
- **`uses_concept`** — mặc định cho existing concept mà paper dựa vào nhưng không thay đổi đáng kể.
- **`extends_concept`** — paper sửa đổi, tổng quát hóa, chuyên biệt hóa, hoặc formalize một existing concept.
- **`critiques_concept`** — paper lập luận rằng một concept có limitations, failure modes, hoặc invalid assumptions.

Khi không chắc giữa `introduces_concept` và `uses_concept`, chọn `uses_concept`. Khi không chắc giữa `uses_concept` và `extends_concept`, chọn `uses_concept`. Không emit `paper → concept` edges với type `supports` hoặc plain `extends`.
Tool reject missing confidence/evidence và legacy paper-to-concept edge types trên new writes.

## Paper-to-paper edges

Bibliographic layer tách biệt với semantic layer:

- luôn ghi `graph/citations.jsonl` với `type: cites` khi một reference resolve tới existing `wiki/papers/{slug}.md`
- chỉ ghi `graph/edges.jsonl` khi paper text đưa ra semantic cue rõ ràng
- không ép mọi citation thành semantic edge

Paper-to-paper semantic edges cố ý sparse. Chúng yêu cầu một quan hệ cụ thể giữa contributions của các papers, không chỉ là shared topic, modality, architecture family, benchmark family, hoặc high-level method words. Nếu cùng statement đó đúng với hàng chục papers trong wiki, skip paper-to-paper edge và dựa vào topic/concept links cộng citations thay vào đó.

Chọn semantic edge type:

- **`same_problem_as`** — symmetric; cả hai papers giải cùng concrete task, research question, hoặc problem formulation, nên các proposed answers có thể so sánh trực tiếp. Không dùng cho broad areas như "attention", "video generation", hoặc "LLM evaluation".
- **`similar_method_to`** — symmetric; cả hai papers chia sẻ một distinctive mechanism, formulation, training strategy, hoặc algorithmic design. Không dùng cho generic families như "uses transformers", "uses diffusion", hoặc "uses RL".
- **`complementary_to`** — symmetric; approaches hoặc components có thể kết hợp theo một cách technically specific, và paper text hoặc method details đưa ra evidence cho compatibility đó. Không dùng chỉ vì cả hai có thể thuộc cùng một future system.
- **`builds_on`** — directional; paper này trực tiếp phụ thuộc, adapt, hoặc extend method, formulation, dataset, result, hoặc system cụ thể của paper kia. Không dùng cho vague inspiration.
- **`compares_against`** — directional; paper này dùng paper kia như explicit baseline, comparator, hoặc ablation reference.
- **`improves_on`** — directional; paper này explicit claim better quality, efficiency, robustness, simplicity, hoặc scope so với paper kia trong comparable setting.
- **`challenges`** — directional; paper này dispute, weaken, hoặc trình bày counter-evidence chống lại result, assumption, hoặc framing của paper kia.
- **`surveys`** — directional; paper này là survey, benchmark, taxonomy, hoặc position work tóm tắt paper kia hoặc line of work của nó.

Mọi paper-to-paper semantic edges phải có `--confidence high|medium|low`.
Với symmetric types, `tools/research_wiki.py add-edge` canonicalize endpoint order và ghi `symmetric: true`.
Tool reject missing confidence/evidence và legacy paper-paper edge types trên new writes.

- **none / skip** — nếu không có type nào ở trên khớp sạch, skip edge. Graph noise tệ hơn missing edge.

Khi nghi ngờ, skip. Paper-paper semantic edges dành cho high-signal local relationships, không phải clustering theo field.

## Ghi cả hai phía atomically

Với mọi link `/ingest` ghi, reverse nên landed trong cùng turn. Trong thực tế nghĩa là:

1. Quyết định link.
2. Ghi forward entry trên originating page.
3. Ghi reverse entry trên target page.
4. Nếu link cũng tương ứng với semantic graph edge (paper↔concept, paper↔claim, paper↔paper, paper→foundation), emit nó qua `tools/research_wiki.py add-edge`.
5. Nếu paper reference resolve tới existing paper page, emit bibliographic row qua `tools/research_wiki.py add-citation`.

Pattern này giúp `/check` không flag half-written links trong lần chạy tiếp theo. Nó cũng khiến rollback đơn giản: nếu paper ingest bị abort, bạn có thể undo cả hai phía cùng lúc bằng cách revert edits của paper.

## `/ingest` không check gì ở đây

`/ingest` ghi forward và reverse links trong khi làm việc, nhưng nó không verify rằng mọi pre-existing link trong wiki vẫn có reverse. Đó là full-graph audit và thuộc về `/check`. Không đọc toàn bộ `wiki/` để tìm broken back-references trong ingest — time và token cost lớn và công việc bị duplicate với `/check`.
