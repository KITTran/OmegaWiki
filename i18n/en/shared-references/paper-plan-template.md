# Paper Plan Template

This template is used to create a structured paper plan from the claim graph in the wiki. The plan includes an evidence map, narrative structure, section outline, figure/table plan, and citation plan.

## Paper Plan File Structure

The paper plan file (`PAPER_PLAN.md`) is created in `wiki/outputs/` and includes the following sections:

```markdown
---
venue: ICLR|NeurIPS|ICML|ACL|CVPR|IEEE
working_title: "Planned title of the paper"
date: YYYY-MM-DD
target_claims:
  - [[claim-slug-1]]
  - [[claim-slug-2]]
---

# Evidence Map

| Claim | Status | Confidence | Evidence Sources | Strength | Paper Section |
|-------|--------|------------|------------------|----------|---------------|
| [[main-claim]] | supported | 0.85 | main-exp, paper-A | strong | Method + Experiments 5.2 |
| [[secondary-claim-1]] | supported | 0.75 | exp-ablation-1 | moderate | Experiments 5.3 (Ablation) |
| [[secondary-claim-2]] | weakly_supported | 0.55 | exp-scaling | weak | Experiments 5.4 (Scaling) |

# Section Outline

## 1. Introduction (1.5 pages)

### Claims covered
- Gap claim: {current methods lack X because Y}
- Contribution claim: [[main-claim]]

### Paragraph plan
1. Broad context: {importance of the area, recent progress}
2. Specific problem: {what is missing, why it matters}
3. Our method: "In this work, we propose..." + contribution list
4. Result preview: {headline number}
5. Paper structure: "The rest of the paper..."

### Key citations
- [[paper-A]] — defines the problem
- [[paper-B]] — closest related work (we improve on)
- [[paper-C]] — our baseline

---

## 2. Related Work (1 page)

### Grouping
- Direction A: {papers, our position}
- Direction B: {papers, our position}
- Direction C: {papers, our position}

### Claims covered
- Contextual claims distinguishing this work from prior work

---

## 3. Method (2-3 pages)

### Claims covered
- [[main-claim]]: sections 3.1-3.2
- [[secondary-claim-1]]: section 3.3

### Subsection plan
- 3.1 Problem formulation: notation, objective
- 3.2 Core method: intuition → formalization
- 3.3 Component X: design decision + rationale
- 3.4 Training/inference details

### Figures
- Figure 1: Overall architecture (required)
- Figure 2: Component X details (if complex)

---

## 4. Experiments (2-3 pages)

### Claims covered
- [[main-claim]]: section 4.2 (main results)
- [[secondary-claim-1]]: section 4.3 (ablation)
- [[secondary-claim-2]]: section 4.4 (scaling)

### Subsection plan
- 4.1 Setup: datasets, baselines, metrics, implementation details
- 4.2 Main results: Table 1 (main comparison), [[main-exp]]
- 4.3 Ablation study: Table 2 (component analysis), [[exp-ablation-*]]
- 4.4 Analysis: scaling, robustness, qualitative examples

### Figures/Tables
- Table 1: Main comparison with baselines
- Table 2: Ablation results
- Figure 3: Scaling curves / qualitative examples

---

## 5. Conclusion (0.5 pages)

### Key takeaway
- {one sentence the reader should remember}

### Limitations
- {from gap_map or claim conditions}

### Future work
- {from open questions in gap_map}

# Figure/Table Plan

## Figure 1: System Architecture
- Type: diagram
- Source: description in the Method section
- Style: block diagram with labeled components
- Size: full width (1 column = text width)

## Table 1: Main Results
- Type: comparison table
- Source: [[main-exp]] key_result + baselines
- Columns: Method | Metric-1 | Metric-2 | ...
- Rows: baselines + ours (bold)
- Notes: bold best results, underline second-best results, arrows ↑/↓ for direction

## Figure 3: Scaling Analysis
- Type: line chart
- Source: [[exp-scaling]] results
- X-axis: scaling dimension (model size / data size)
- Y-axis: performance metric
- Lines: ours vs baseline, with error bands

# Citation Plan

- List all wiki papers referenced via `[[slug]]` in the outline.
- For each paper, fetch BibTeX in advance:
  - DBLP first, then CrossRef, then S2
  - Success: record BibTeX key + source
  - Failure: mark `[UNCONFIRMED]`
- Report citation coverage:
  ```
  Citations: 15 total, 12 verified (DBLP: 8, CrossRef: 3, S2: 1), 3 [UNCONFIRMED]
  ```
- For [UNCONFIRMED] items, provide suggested URLs for manual verification.

# Review LLM Assessment Summary

Summarize the main feedback from the Review LLM assessment (used as an area chair to evaluate the persuasiveness of the outline), including:
- Assessment of the persuasiveness of the narrative structure (gap → solution → evidence → impact)
- Claims missing evidence and missing experiments
- Assessment of the appropriateness of the related-work grouping
- Assessment of the page budget
- Assessment of the completeness of the figures/tables
- Review score (X/10) and conclusion
- Revisions made based on the feedback

# Paper Plan Report

This report is printed to the terminal after the plan is created:

```markdown
# Paper Plan Report

## General Information
- Title: {planned title}
- Venue: {venue}
- Page limit: {N} pages
- Date: {date}

## Claims → Sections
| Claim | Confidence | Section |
|-------|------------|---------|
| [[main]] | 0.85 | Method + Experiments 5.2 |
| [[secondary-1]] | 0.75 | Experiments 5.3 |

## Page Budget
| Section | Pages | Claims |
|---------|-------|--------|
| Introduction | 1.5 | gap, contribution |
| Related Work | 1.0 | context |
| Method | 2.5 | main, secondary |
| Experiments | 2.5 | all |
| Conclusion | 0.5 | — |

## Figures/Tables: {N} planned
## Citations: {verified}/{total} verified, {unconfirmed_count} [UNCONFIRMED]
## Review LLM Assessment: score {X}/10, conclusion: {conclusion}

## Next Steps
- Run `/paper-draft wiki/outputs/paper-plan-{slug}-{date}.md` to draft the paper
- Resolve {unconfirmed_count} [UNCONFIRMED] citations before `/paper-compile`
```
