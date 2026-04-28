# 实验评估标准

本文档定义了 `/exp-eval` 用于评估实验结果的结构化标准。评估过程会将结果映射到 claims，更新 confidence scores，并驱动研究流水线。

---

## 核心评估维度

| 维度          | 描述                                                                 | 评分 (0-1)                          |
|-------------------|-----------------------------------------------------------------------------|-----------------------------------------|
| **Validity**       | 实验是否正确检验了目标 claim？                        | 0: Flawed, 1: Valid                     |
| **Reproducibility** | 结果在不同运行和环境中是否一致？                         | 0: Inconsistent, 1: Reproducible         |
| **Significance**   | 观察到的效应在统计上或实践上是否有意义？           | 0: Negligible, 1: Significant            |
| **Novelty**        | 结果是否提供了新的洞见，或确认了现有知识？          | 0: Redundant, 1: Novel                    |
| **Robustness**     | 结果在扰动（噪声、超参数、数据）下是否仍然成立？       | 0: Fragile, 1: Robust                     |

---

## 判断路径

### 1. **Supports Claim**
- **条件**:
  - Validity = 1
  - Significance = 1
  - 效应方向与 claim 一致
- **操作**:
  - 提高 claim confidence（+0.2，上限为 0.95）
  - 在 graph 中添加 `supports` edge
  - 将相关 ideas 标记为 `viable`

### 2. **Contradicts Claim**
- **条件**:
  - Validity = 1
  - Significance = 1
  - 效应方向与 claim 相反
- **操作**:
  - 降低 claim confidence（-0.3，下限为 0.05）
  - 在 graph 中添加 `contradicts` edge
  - 将相关 ideas 标记为 `invalidated`（如果 confidence < 0.2）

### 3. **Inconclusive**
- **条件**:
  - Validity = 1 但 Significance = 0，**或**
  - Reproducibility = 0
- **操作**:
  - 不更改 claim confidence
  - 添加带有 `result: inconclusive` 的 `tested_by` edge
  - 触发 `/exp-design` 以细化或重新设计实验

### 4. **Invalid**
- **条件**:
  - Validity = 0
- **操作**:
  - 不更改 claim confidence
  - 添加带有 `result: invalid` 的 `tested_by` edge
  - 将 experiment 标记为 `failed`，并记录 `failure_reason`

---

## 置信度更新规则

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

## 输出产物

### Graph Edges

```jsonl
{"source": "experiment:flash-attention-speedup", "target": "claim:flash-attention-2x-faster", "type": "supports", "weight": 0.85}
{"source": "experiment:adversarial-pgd-attack", "target": "claim:robustness-against-pgd", "type": "contradicts", "weight": 0.3}
```

### Wiki Updates

- **Claims**: 用实验结果和新的 confidence score 更新 `evidence` 字段。
- **Ideas**: 基于 claim confidence 将 `status` 设置为 `viable` 或 `invalidated`。
- **Experiments**: 将 `status` 设置为 `completed`，并记录 `result_summary`。

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
