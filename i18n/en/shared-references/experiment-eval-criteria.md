# Experiment Evaluation Criteria

This document defines the structured criteria used by `/exp-eval` to assess experimental results. The evaluation process maps outcomes to claims, updates confidence scores, and drives the research pipeline.

---

## Core Evaluation Dimensions

| Dimension          | Description                                                                 | Scoring (0-1)                          |
|-------------------|-----------------------------------------------------------------------------|-----------------------------------------|
| **Validity**       | Does the experiment correctly test the target claim?                        | 0: Flawed, 1: Valid                     |
| **Reproducibility** | Are results consistent across runs and environments?                         | 0: Inconsistent, 1: Reproducible         |
| **Significance**   | Are the observed effects statistically or practically meaningful?           | 0: Negligible, 1: Significant            |
| **Novelty**        | Does the result provide new insight or confirm existing knowledge?          | 0: Redundant, 1: Novel                    |
| **Robustness**     | Do results hold under perturbations (noise, hyperparameters, data)?       | 0: Fragile, 1: Robust                     |

---

## Judgment Pathways

### 1. **Supports Claim**
- **Conditions**:
  - Validity = 1
  - Significance = 1
  - Effect direction matches claim
- **Actions**:
  - Increase claim confidence (+0.2, capped at 0.95)
  - Add `supports` edge in graph
  - Mark related ideas as `viable`

### 2. **Contradicts Claim**
- **Conditions**:
  - Validity = 1
  - Significance = 1
  - Effect direction opposes claim
- **Actions**:
  - Decrease claim confidence (-0.3, floored at 0.05)
  - Add `contradicts` edge in graph
  - Mark related ideas as `invalidated` (if confidence < 0.2)

### 3. **Inconclusive**
- **Conditions**:
  - Validity = 1 but Significance = 0, **OR**
  - Reproducibility = 0
- **Actions**:
  - No change to claim confidence
  - Add `tested_by` edge with `result: inconclusive`
  - Trigger `/exp-design` to refine or redesign experiment

### 4. **Invalid**
- **Conditions**:
  - Validity = 0
- **Actions**:
  - No change to claim confidence
  - Add `tested_by` edge with `result: invalid`
  - Mark experiment as `failed` with `failure_reason`

---

## Confidence Update Rules

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

## Output Artifacts

### Graph Edges

```jsonl
{"source": "experiment:flash-attention-speedup", "target": "claim:flash-attention-2x-faster", "type": "supports", "weight": 0.85}
{"source": "experiment:adversarial-pgd-attack", "target": "claim:robustness-against-pgd", "type": "contradicts", "weight": 0.3}
```

### Wiki Updates

- **Claims**: Update `evidence` field with experiment results and new confidence score.
- **Ideas**: Set `status` to `viable` or `invalidated` based on claim confidence.
- **Experiments**: Set `status` to `completed` and record `result_summary`.

---

## Review LLM Prompt Template

```text
You are an independent reviewer assessing experimental results for alignment with claims.

**Input**:
- Claim: {claim_text}
- Experiment design: {experiment_design}
- Results: {results}

**Task**:
1. Validate the experiment design against the claim.
2. Assess the significance and direction of observed effects.
3. Flag any threats to validity or reproducibility.
4. Output a structured verdict (supports/contradicts/inconclusive/invalid) with justification.

**Output Format**:
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