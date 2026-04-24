# Closed-Loop Prompt Improvement System

## System Overview
A multi-agent system that autonomously iterates on a set of prompts to improve performance on a given task. No human intervention after initial setup.

## Agents & Responsibilities

### 1. **Executor**
- **Role**: Runs each prompt against the task (e.g., via an LLM API) and collects outputs.
- **Input**: Current prompt set, task definition, input examples.
- **Output**: For each prompt, a set of generated responses on the task inputs.

### 2. **Evaluator**
- **Role**: Scores each prompt’s outputs against a predefined rubric (quality, correctness, relevance, etc.).
- **Input**: Executor’s outputs, scoring criteria (could be automated metrics like BLEU/ROUGE, or a separate LLM-as-a-judge).
- **Output**: Numeric scores per prompt, plus optional diagnostic feedback (e.g., “outputs are verbose but accurate”).

### 3. **Optimizer**
- **Role**: Uses the scores to generate a new, improved set of prompts.
- **Input**: Prompt set, their scores, feedback from Evaluator.
- **Strategy**: Could employ:
  - **Evolutionary**: Select top‑performing prompts, mutate them (word substitutions, structural changes), crossover pairs.
  - **Gradient‑free optimization**: Treat prompt as a parameter vector, use techniques like CMA‑ES.
  - **LLM‑based refinement**: Ask an LLM to rewrite prompts based on the scores and feedback.
- **Output**: New prompt set (same size as before).

## Flow (One Iteration)
1. **Executor** runs all prompts → outputs.
2. **Evaluator** scores outputs → scores + feedback.
3. **Optimizer** uses scores + feedback → new prompts.
4. Loop repeats for a fixed number of iterations or until convergence.

## How the System Knows “Better” or “Worse”
- **Primary signal**: Average score across the task’s input examples. If the score rises, prompts are better.
- **Secondary signals**: Variance (low variance may indicate robustness), diversity of outputs (avoids degenerate solutions).
- **Convergence detection**: Stop when score plateaus (no improvement for N iterations) or max iterations reached.

## Anti‑Stuck Mechanisms
- **Diversity preservation**: Ensure prompt set doesn’t collapse to identical variants (e.g., enforce Hamming distance between prompts).
- **Exploration budget**: Randomly inject new random prompts each iteration.
- **Restart**: If scores stagnate for too long, reset part of the population with random prompts.
- **Multi‑objective scoring**: Balance quality with other desiderata (length, clarity) to avoid over‑fitting to a single metric.

## Stress‑Test: Most Likely Silent Failure
**Score hacking / evaluator over‑fit**  
The Optimizer learns to produce prompts that exploit quirks of the Evaluator, not genuine task improvement.  
Example: If Evaluator uses keyword matching, prompts may learn to insert those keywords regardless of correctness.  
Result: Scores rise steadily while real‑world performance stays flat or degrades.

## Catching the Failure: The Validator Component
Add a **Validator** agent that operates on a held‑out validation set with a different, more robust evaluation method.

- **Validator’s role**: Periodically (every K iterations) test the current best prompts on a separate validation suite that the Optimizer never sees.
- **Validation metric**: Should be more expensive but trustworthy (e.g., human‑like rubric, downstream task success rate, or a different LLM‑judge with contrasting instructions).
- **Action**: If validation score diverges significantly from the primary evaluation score (e.g., >10% drop), trigger an alarm and optionally:
  1. **Roll back** to the last checkpoint that performed well on validation.
  2. **Adjust the Evaluator** (e.g., rotate scoring criteria, add regularization terms).
  3. **Expand the validation set** with new adversarial examples.

## System Diagram
```
[Prompt Set] → Executor → Outputs → Evaluator → Scores
    ↑                                      ↓
    └── Optimizer ←── Feedback ←───┘
          ↓
    [New Prompt Set]
          ↓
    Validator (every K iterations) → Alarm if divergence
```

## Implementation Considerations
- **Initial prompt set**: Seed with diverse hand‑crafted or random prompts.
- **Task definition**: Must be explicit, with input‑output examples or a simulator.
- **Computational cost**: Each iteration requires many LLM calls (Executor + Evaluator). Use caching where possible.
- **Safety**: Ensure prompts don’t drift into harmful content; include a content filter in the Evaluator.

## Summary
The closed‑loop system can autonomously improve prompts by iterating execution, scoring, and optimization. The biggest risk is evaluator over‑fit, which is mitigated by a periodic Validator using a held‑out, robust evaluation. This ensures that observed improvements are real, not just metric gaming.