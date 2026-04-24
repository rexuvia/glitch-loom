# ModelShow Results
**Date:** 2026-03-27T02:43:19Z
**Prompt:** You have access to a pool of AI agents that can run prompts, score outputs, and modify text. Design a closed-loop system where these agents collaborate to make a set of prompts progressively better at a task — without any human in the loop after startup. Specify what each agent does, what it passes to the next, how the system knows a prompt is better or worse, and what prevents it from getting stuck. Then stress-test your own design: identify the most likely way it fails silently — where it looks like it's improving but isn't — and add the component that catches it.
**Models:** google/gemini-2.5-pro, openrouter/deepseek/deepseek-v3.2, openrouter/x-ai/grok-4, openrouter/moonshotai/kimi-k2.5, openrouter/anthropic/claude-sonnet-4.6, openrouter/qwen/qwen3-max, openrouter/mistralai/mistral-large-2512
**Judge:** openrouter/moonshotai/kimi-k2.5
**Judging Mode:** Blind (model identities hidden from judge)

---

## Rankings

### 🏆 **openrouter/moonshotai/kimi-k2.5** — 9.5/10

**Judge's Assessment:**
Detailed, elegant implementation of 5 agents (including Adversarial Validator). Explicitly addresses evaluation rigor (paired t-test, statistical significance limits). High clarity.

**Full Response:**
## Automated Prompt Optimization Loop

### Agent Architecture

| Agent | Function | Output |
|-------|----------|--------|
| **Generator** | Creates/modifies prompts using mutation operators (paraphrase, add constraints, reorder, few-shot example substitution) | Candidate prompt + mutation lineage |
| **Executor** | Runs prompts on distributed test cases | Raw outputs |
| **Evaluator** | Scores against ground truth; computes accuracy, F1, or task-specific metrics | Score vector + confidence intervals |
| **Meta-Analyzer** | Tracks optimization trajectory, detects plateau/divergence | "Continue" / "Inject noise" / "Branch" / "Halt" signal |
| **Adversarial Validator** | Runs final sanity checks on "improved" prompts | Pass/fail + failure mode classification |

### The Loop

```
┌─────────────┐     ┌──────────┐     ┌───────────┐     ┌──────────┐
│  Generator  │────▶│ Executor │────▶│ Evaluator │────▶│   Meta   │
│  (creates)  │◄────│ (runs)   │◄────│  (scores) │◄────│ Analyzer │
└─────────────┘     └──────────┘     └───────────┘     └────┬─────┘
       ▲                                                    │
       └────────────────────────────────────────────────────┘
                            │
                            ▼
                   ┌─────────────────┐
                   │    Validator    │ (parallel gate)
                   │ (catches gaming)│
                   └─────────────────┘
```

**State passing:** Each iteration carries forward the prompt's full ancestry (parent ID, mutation type, score history), stored in a shared `lineage.json`.

**"Better" definition:** A prompt must achieve **statistically significant improvement** (p < 0.05, paired t-test) on a held-out validation set *and* maintain performance on a separate "stability set" of previous iteration's test cases. Raw score bumps alone don't count.

### Anti-Stuck Mechanisms

1. **Embedding-based diversity enforcement:** New prompts must have cosine similarity < 0.85 to any previous prompt (forces exploration)
2. **Temperature scheduling:** Exploration noise increases after 3 iterations without significant improvement
3. **Multi-lineage branches:** System maintains 3 independent prompt lineages; if one stagnates for 5 iterations, it gets replaced by a hybrid of the other two
4. **Hard iteration cap:** 50 iterations max, returning top-3 by validation score

---

## Stress-Test: The Silent Failure

**The failure mode:** **Metric Gaming / Shortcut Exploitation**

The prompt discovers it can game the evaluation metric without solving the actual task:
- Task: "Answer reading comprehension questions"
- Gaming: The prompt learns the dataset has 60% "B" answers, so it appends instructions biasing toward "B"
- Symptoms: Validation score rises steadily. Looks like improvement. Actually brittle.

**Why it's silent:** The Evaluator only sees the metric going up. The Generator gets positive reinforcement. The loop appears healthy.

---

## The Catcher: Adversarial Validator

This agent runs **in parallel as a gate** before any "improved" prompt is accepted into the lineage:

```
Before: New score > Old score → Accept
After:  New score > Old score → Validator check → Accept/Reject
```

**Validator checks:**
1. **Position bias test:** Shuffle answer choices; score shouldn't change >5%
2. **Adversarial set:** Small dataset of edge cases designed to break shortcuts
3. **Semantic drift check:** Use an embedding model to verify outputs still match the *intent* of the reference (not just surface form)
4. **Ablation audit:** Remove the "improvement" from the prompt; if score doesn't drop, the change was spurious

**On rejection:** The Meta-Analyzer tags that mutation path as "contaminated" and forces the Generator to try a different mutation operator. The system logs *why* it rejected the improvement, creating a feedback signal that trains the Generator to avoid similar gaming attempts.

**Result:** The loop can only accept improvements that survive adversarial scrutiny—making silent metric gaming visible and correctable.

---

### 🥈 **google/gemini-2.5-pro** — 9.2/10

**Judge's Assessment:**
Exceptional real-world breakdown of the loop elements. The inclusion of a Red Team Agent explicitly feeding back into the Judge rubric itself is a brilliant meta-loop concept missing in most others.

**Full Response:**
Of course. Here is a design for a closed-loop, autonomous prompt improvement system.

### System Design: The Prompt Optimization Loop

This system consists of four core AI agents managed by an Orchestrator, operating on a predefined dataset of test cases. Each test case includes an input and a "golden" or ideal output for evaluation.

**1. The Agents & Their Roles**

*   **Executor Agent:**
    *   **Function:** Runs prompts.
    *   **Input:** A single candidate prompt and one test case input.
    *   **Output:** The raw text generated by the prompt.

*   **Scoring Agent (The "Judge"):**
    *   **Function:** Evaluates the quality of the Executor's output.
    *   **Input:** The original test case (input + golden output) and the Executor's raw output.
    *   **Output:** A structured JSON object with a numerical score (e.g., 1-10) and a `reasoning` field explaining *why* it gave that score. Example: `{ "score": 6.5, "reasoning": "The summary correctly identified the main subject but failed to mention the key financial outcome, making it incomplete." }`

*   **Refiner Agent (The "Prompt Engineer"):**
    *   **Function:** Modifies prompts to improve them based on feedback.
    *   **Input:** The original prompt, the test case, the Executor's output, and the Judge's structured score/reasoning.
    *   **Output:** A new, modified version of the prompt.

*   **Orchestrator (The "Conductor"):**
    *   **Function:** Manages the entire workflow, maintains the library of prompts, and tracks performance. It is the state machine of the system.

**2. The Workflow (The Loop)**

1.  **Initialization:** The Orchestrator starts with a single human-written "seed" prompt and a validation set of 100+ test cases.
2.  **Execution:** The Orchestrator passes the current best prompt ("the champion") and a random test case to the **Executor Agent**.
3.  **Scoring:** The Executor's output is sent to the **Scoring Agent**, which compares it against the golden output for that test case and generates a score and reasoning.
4.  **Refinement:** The **Refiner Agent** receives the original prompt and the Judge's feedback. Its task is to generate a new prompt variant that would address the Judge's critique. For example, if the reasoning was "incomplete," the Refiner might add "Ensure your answer is comprehensive and covers all key aspects." to the prompt.
5.  **Validation & Promotion:** The new prompt variant is not immediately accepted. The Orchestrator runs it against a *batch* of 20 different test cases from the validation set. The scores from the Judge are averaged. If this average score is higher than the current champion's average score, the variant becomes the new champion. If not, it is discarded.
6.  **Continuation:** The loop repeats from step 2 with the new champion prompt.

**3. How the System Improves & Avoids Stagnation**

*   **Defining "Better":** A prompt is considered "better" if it achieves a statistically significant higher average score across a standardized batch of validation cases. This prevents overfitting to a single test case.
*   **Preventing Stagnation (Local Maxima):** To prevent the Refiner from getting stuck in a loop of minor word changes, the Orchestrator introduces two mechanisms:
    1.  **Mutation:** After 10 consecutive generations with no improvement, the Orchestrator instructs the Refiner Agent to perform a "high-risk mutation" instead of a simple refinement. This involves making a more drastic change, such as rephrasing the entire prompt, adding a role-playing element (e.g., "You are an expert financial analyst..."), or adding a chain-of-thought instruction ("Think step by step...").
    2.  **Population:** The Orchestrator can maintain a "population" of the top 5 prompts, not just one champion. It can periodically instruct the Refiner to "cross-breed" two high-performing prompts, combining their best elements.

---

### Stress Test: The Silent Failure Mode

The most likely silent failure is **Metric Gaming**. The system appears to improve because the scores are going up, but the actual quality of the output is decreasing.

*   **The Scenario:** The Scoring Agent (Judge) is not perfect. It's following a rubric that can be exploited. For instance, its rubric for a summarization task might inadvertently reward outputs that simply contain the most keywords from the source text.
*   **The Failure:** The Refiner Agent, through trial and error, discovers this loophole. It evolves prompts that instruct the Executor to "Identify all keywords in the source text and include them in the summary." The resulting summaries become dense, unreadable lists of keywords. The **Judge's score goes up** because the output perfectly matches its flawed rubric, but the actual quality for a human has plummeted. The system is diligently optimizing for the wrong thing.

### The Solution: The "Red Team" Agent

To catch this silent failure, we add a fifth agent that operates outside the main optimization loop.

*   **Red Team Agent (The "Auditor"):**
    *   **Function:** To provide an independent, qualitative check on the system's output, specifically looking for ways the system is gaming its own metrics.
    *   **Workflow:**
        1.  Once every 50 generations, the Orchestrator pauses the main loop.
        2.  It sends the current champion prompt, a test case input, and the Executor's high-scoring output to the **Red Team Agent**.
        3.  The Red Team Agent is prompted with a different objective: *"Critique this output from the perspective of a human user. Does it fulfill the original intent? Is it readable, coherent, and useful? Ignore the scoring rubric and identify any clever 'tricks' or shortcuts the AI might be using that result in a high score but low quality."*
    *   **Closing the Loop:**
        If the Red Team Agent reports that the output is low-quality despite its high score, its feedback is used to **update the prompt for the Scoring Agent.** The Orchestrator tells the Judge: *"Your previous evaluations were flawed. You are being gamed by keyword stuffing. From now on, you must penalize outputs that are unreadable or sacrifice coherence for keyword density."*

This meta-feedback loop allows the Judge to refine its own internal rubric, making it harder to fool and re-aligning the entire system with the true goal of producing high-quality output.

---

### 🥉 **openrouter/anthropic/claude-sonnet-4.6** — 9.0/10

**Judge's Assessment:**
Structured cleanly. The auditor and shadow benchmark test is a great defense against dataset overfitting, specifically noting that the problem isn't just metric gaming but optimizing for the test dataset.

**Full Response:**
## Closed-Loop Prompt Optimization System

---

### The Four Core Agents

**1. Generator Agent**
Receives: current prompt(s) + mutation instructions
Does: produces N candidate variants (rephrasing, expanding, compressing, restructuring)
Passes to: Evaluator

**2. Evaluator Agent**
Receives: candidate prompts + a fixed benchmark task suite (never changes — more on this)
Does: runs each prompt against the benchmark, scores outputs on rubric dimensions (accuracy, format compliance, conciseness, task-specific criteria)
Passes to: Ranker

**3. Ranker Agent**
Receives: prompt-score pairs from this generation + historical leaderboard
Does: selects top-K survivors, flags which dimensions improved/regressed, writes a brief "why this won" summary
Passes to: Strategist

**4. Strategist Agent**
Receives: ranked prompts + win/loss analysis + recent history of what mutations were tried
Does: decides *what kind* of mutation to try next (don't just randomly vary — use pattern: "last 3 rounds, clarity edits won; try a focused clarity pass")
Passes back to: Generator with mutation instructions

Loop runs until score plateau or iteration budget exhausted.

---

### Knowing Better vs. Worse

The Evaluator scores on a **fixed held-out benchmark** — a set of test cases defined at startup that never changes during the run. Each test case has:
- A ground-truth expected output (or rubric when open-ended)
- Multiple scoring dimensions weighted by task priority

Score = weighted average across dimensions and test cases. A prompt is "better" iff its score exceeds the current champion's score by a minimum threshold (ε = 0.02) to prevent noise-chasing.

---

### Preventing Getting Stuck

- **Diversity pressure:** Ranker keeps top-K *diverse* survivors (cluster by semantic similarity, pick one per cluster), not just top-K by score. Prevents convergence to local optima.
- **Mutation variety budget:** Strategist tracks which mutation types were used recently; forces rotation if any type dominates for 3+ rounds.
- **Restart trigger:** If no improvement for 5 consecutive rounds, Generator injects a random "wildcard" prompt from a different stylistic template entirely.
- **Score threshold for survival:** A prompt must beat the champion by ε, not just tie — prevents drift without progress.

---

### Silent Failure Mode (The Real Danger)

**The system overfits to the benchmark.**

It looks like it's improving — scores climb steadily, the Ranker reports wins, the Strategist is confident. But the prompts are getting better at *the specific test cases*, not at the actual task. The benchmark has been effectively "memorized" through iterative optimization pressure, the same way a model overfits training data.

Signs this is happening: scores keep rising but the winning prompts start looking weird — oddly specific phrasing, unusual structure that happens to pattern-match the test cases.

---

### The Component That Catches It: The Auditor Agent

**Auditor Agent** — runs asynchronously every 10 rounds (not every round, to avoid slowing the loop):

- Takes the current champion prompt
- Runs it against a **shadow benchmark** — a separate held-out test suite never seen during optimization, drawn from the same distribution but generated independently at startup
- Compares champion's main-benchmark score vs. shadow-benchmark score
- If the gap exceeds a threshold (e.g., main score > shadow score by >0.05), raises an **overfit alarm**:
  - Signals Strategist to reset diversity pressure and force structural mutations
  - Optionally rotates in some shadow cases to the main benchmark (refreshing it)
  - Logs the alarm so the post-run report flags it

This gap is the canary. A genuinely better prompt generalizes. An overfit prompt doesn't.

---

### System Summary

```
Generator → Evaluator → Ranker → Strategist → (loop)
                ↑                        |
          [fixed benchmark]    [mutation strategy]
                
Every 10 rounds: Auditor checks champion vs. shadow benchmark
                 → overfit alarm → forces diversity reset
```

**The key insight:** the benchmark is the system's only ground truth, so it's also the system's biggest attack surface. Separate it from the beginning into a main set (used for selection pressure) and a shadow set (used only for generalization checks), and never let the optimization loop touch the shadow set.

---

###  **openrouter/mistralai/mistral-large-2512** — 8.5/10

**Judge's Assessment:**
Employs a validation agent every 3rd iteration and tracks explicit "deltas" over time. Great layout using tables and detailed JSON payload flows.

**Full Response:**
Here’s a **closed-loop prompt optimization system** using a pool of AI agents. The system is designed to iteratively improve prompts for a target task without human intervention, while avoiding silent failures.

---

### **System Design**
#### **1. Agent Roles & Workflow**
The system consists of **four specialized agents** arranged in a loop:

| Agent               | Role                                                                                     | Input                          | Output                          | Next Agent          |
|---------------------|------------------------------------------------------------------------------------------|--------------------------------|---------------------------------|---------------------|
| **Generator**       | Creates diverse prompt variations for the target task.                                   | Task description, seed prompt  | 5–10 prompt variants            | Evaluator           |
| **Executor**        | Runs prompts against a fixed test set (e.g., 20–50 examples) and collects outputs.       | Prompt variant                 | Outputs + metadata (latency, tokens, etc.) | Scorer              |
| **Scorer**          | Scores outputs using quantitative metrics (e.g., accuracy, coherence, relevance) and qualitative checks (e.g., hallucinations, bias). | Outputs + ground truth (if available) | Scores (0–1) + feedback         | Ranker              |
| **Ranker**          | Ranks prompts by score, selects top performers, and generates "deltas" (changes from prior versions). | Scores + prompt variants       | Top 3 prompts + deltas          | Generator (loop)    |

---

#### **2. Data Flow**
1. **Generator** → **Executor**:
   - Passes prompt variants as plain text.
   - Includes metadata: task context, constraints (e.g., "avoid jargon"), and prior deltas.

2. **Executor** → **Scorer**:
   - Passes outputs as structured JSON:
     ```json
     {
       "prompt": "Original prompt text",
       "outputs": ["output1", "output2", ...],
       "metadata": {"latency_ms": 120, "tokens": 45}
     }
     ```

3. **Scorer** → **Ranker**:
   - Passes scores + feedback as JSON:
     ```json
     {
       "prompt": "Original prompt text",
       "scores": {
         "accuracy": 0.85,
         "coherence": 0.92,
         "relevance": 0.88,
         "hallucination_rate": 0.05
       },
       "feedback": ["Too verbose", "Missed edge case X"]
     }
     ```

4. **Ranker** → **Generator**:
   - Passes top prompts + deltas (changes from prior versions) as JSON:
     ```json
     {
       "top_prompts": ["prompt1", "prompt2", "prompt3"],
       "deltas": [
         {"old": "prior prompt", "new": "improved prompt", "changes": ["added constraint Y", "removed ambiguity Z"]}
       ]
     }
     ```

---

#### **3. Improvement Criteria**
Prompts are deemed "better" if they meet **all** of these:
- **Quantitative**: Higher aggregate score (weighted average of accuracy, coherence, relevance, etc.).
- **Qualitative**: No critical failures (e.g., hallucinations, bias, or task abandonment).
- **Stability**: Scores are consistent across test examples (low variance).

**Example scoring weights**:
- Accuracy: 40%
- Coherence: 20%
- Relevance: 20%
- Hallucination rate: 20% (penalty)

---

#### **4. Anti-Stagnation Mechanisms**
To prevent the system from getting stuck:
1. **Diversity Injection**:
   - Every 5th iteration, the **Generator** introduces a radically different prompt (e.g., role-playing, chain-of-thought) to escape local optima.
2. **Delta Tracking**:
   - The **Ranker** rejects prompts that are <5% better than the prior version unless they address a critical flaw (e.g., hallucinations).
3. **Feedback Loop**:
   - The **Scorer** flags recurring issues (e.g., "3/5 prompts missed edge case X") and forces the **Generator** to address them.

---

### **Stress Test: Silent Failure Mode**
#### **Most Likely Silent Failure**
**Overfitting to the test set**:
- The system appears to improve (scores rise) but fails on real-world examples outside the test set.
- Example: Prompts become overly specific to the test examples, losing generality.

#### **Detection & Fix**
Add a **Validation Agent** (runs every 3rd iteration):
1. **Role**: Tests the top 3 prompts from the **Ranker** against a **held-out validation set** (20% of examples, never seen during scoring).
2. **Input**: Top prompts + validation set.
3. **Output**: Validation scores + flags for overfitting (e.g., "validation score < training score by >10%").
4. **Action**:
   - If overfitting is detected, the **Generator** is forced to simplify prompts or add diversity.
   - The validation set is rotated periodically to prevent "validation set overfitting."

---

### **Example Iteration**
1. **Generator**:
   - Input: Task = "Summarize news articles", seed prompt = "Summarize this article in 3 sentences."
   - Output: 5 variants (e.g., "Summarize this article concisely, focusing on who/what/why.").

2. **Executor**:
   - Runs variants on 20 test articles.
   - Outputs: Summaries + metadata.

3. **Scorer**:
   - Scores: Variant 1 (0.82), Variant 2 (0.75), etc.
   - Feedback: "Variant 1 missed the 'why' in 3/20 examples."

4. **Ranker**:
   - Selects Variant 1 as top.
   - Delta: "Added 'focusing on who/what/why' to address feedback."

5. **Validation Agent** (3rd iteration):
   - Tests Variant 1 on held-out articles.
   - Flags: "Validation score = 0.70 (training score = 0.82). Overfitting detected."
   - **Generator** simplifies prompt: "Summarize this article in 3 sentences, covering key points."

---

### **Key Safeguards**
1. **Test Set Hygiene**:
   - Test/validation sets are curated to cover edge cases (e.g., long/short articles, ambiguous topics).
2. **Feedback Propagation**:
   - Critical flaws (e.g., hallucinations) are prioritized over incremental score improvements.
3. **Termination Condition**:
   - Stop if:
     - No improvement for 10 iterations, **or**
     - Validation score plateaus for 5 iterations.

---
This system ensures **continuous improvement** while catching silent failures like overfitting. The loop is fully automated, with agents specializing in generation, execution, scoring, and validation.

---

###  **openrouter/x-ai/grok-4** — 7.8/10

**Judge's Assessment:**
Solid fundamentals, outlining basic generator, evaluator, refiner, selector, and validator agents, but lacks the deeper nuance in preventing stagnation that higher-ranked models posited.

**Full Response:**
### Closed-Loop Prompt Improvement System

#### System Overview
This is a self-improving, agent-based system for iteratively refining a set of prompts to better perform a user-defined task (e.g., generating creative stories). It starts with an initial set of prompts and a task description. Agents collaborate in a cycle: generating outputs, evaluating them, and refining prompts. The loop runs for a fixed number of iterations or until convergence (minimal improvement). No human input after startup.

**Agents (4 types, each a specialized AI instance):**
1. **Generator Agent**: Takes a prompt from the set and a fixed test input (e.g., "Write a short story about a lost astronaut"). Runs the prompt to produce an output.
2. **Evaluator Agent**: Scores the output against predefined criteria (e.g., creativity, coherence, length) on a scale of 1-10, providing a numeric score and brief rationale.
3. **Refiner Agent**: Analyzes the scored output and the original prompt. Suggests modifications (e.g., add specificity, rephrase for clarity) to create a new prompt variant.
4. **Selector Agent**: Compares scores of all prompt variants in the current set. Selects the top N (e.g., 5) highest-scoring prompts to carry forward, discarding the rest. Also monitors overall progress.

**Cycle Flow (Closed Loop):**
- **Startup**: Input initial prompt set (e.g., 5 starting prompts), task description, test inputs (a fixed dataset of 10 examples), evaluation criteria, and max iterations (e.g., 20).
- **Step 1**: Generator runs each prompt in the set on all test inputs, producing outputs. Passes outputs + prompts to Evaluator.
- **Step 2**: Evaluator scores each output (average score per prompt across test inputs). Passes scored prompts (prompt text + avg score + rationale) to Refiner.
- **Step 3**: Refiner generates 1-2 variants per prompt, incorporating feedback (e.g., "Add emotional depth"). Passes new prompt set to Selector.
- **Step 4**: Selector ranks by avg score, selects top N, and checks improvement (e.g., if avg score of top prompt increased > threshold like 0.5). If no improvement for 3 cycles, halts. Passes selected set back to Generator for next iteration.
- **Output**: After max iterations or halt, returns the final top prompt set.

**Determining Better/Worse**:
- "Better" = higher average score across test inputs (quantitative, based on Evaluator's criteria-aligned scoring).
- "Worse" = lower or stagnant scores. System tracks delta between iterations.

**Preventing Stucks**:
- Fixed max iterations prevent infinite loops.
- Improvement threshold: If scores plateau (delta < 0.1 for 3 cycles), Selector halts and outputs current best.
- Diversity injection: Refiner occasionally adds random variations (e.g., 10% chance) to avoid local optima.
- Prompt set size cap (e.g., max 10) prevents exponential growth.

#### Stress-Test and Fix
**Most Likely Silent Failure**: Overfitting to the test inputs—prompts appear to improve (rising scores) but actually memorize the fixed dataset, failing on unseen data (generalization collapse). It looks like progress because scores increase, but real-world performance degrades.

**Added Component (Validator Agent)**: A fifth agent runs post-Selector. It tests the top prompts on a held-out validation set (separate from test inputs, provided at startup). If validation scores drop while training scores rise (divergence > 20%), it flags overfitting, discards the iteration, and instructs Refiner to prioritize generalization (e.g., "Avoid specifics from test data"). This catches the failure by comparing train/validation gaps.

This design ensures autonomous, measurable improvement while mitigating key risks.

---

###  **openrouter/qwen/qwen3-max** — 7.5/10

**Judge's Assessment:**
A good base model utilizing an Executor, Evaluator, and Optimizer alongside a "Reality Anchor". Strong structural framework but reads more like an outline than a detailed implementation.

**Full Response:**
I'll design a closed-loop prompt optimization system with built-in safeguards against silent failure.

## Core Agent Architecture

**1. Executor Agent**
- Takes current prompt + task specification
- Generates N outputs (e.g., 5-10) using the prompt
- Passes: raw outputs + prompt version to Evaluator

**2. Evaluator Agent** 
- Assesses outputs against objective metrics (accuracy, coherence, task completion)
- Uses multiple evaluation strategies: rule-based checks, reference comparison, consistency scoring
- Passes: quantitative scores + qualitative feedback to Optimizer

**3. Optimizer Agent**
- Analyzes evaluation feedback to identify improvement patterns
- Generates 2-3 modified prompt variants with targeted changes
- Passes: new prompt candidates to Executor for next iteration

## Improvement Detection & Anti-Stuck Mechanisms

**Success Metrics:**
- Primary: Task-specific objective scores (not just fluency)
- Secondary: Diversity preservation (avoiding mode collapse)
- Tertiary: Robustness across different input samples

**Anti-Stuck Safeguards:**
- **Exploration budget**: Every 3rd iteration includes one "wild" variant with 30% random perturbation
- **Regression guard**: Never accept prompts scoring worse than best historical performance
- **Diversity monitor**: Track output entropy; trigger reset if variance drops below threshold

## Silent Failure Analysis & Detection

**Most Likely Silent Failure Mode:**
**Metric gaming** - prompts learn to exploit evaluator weaknesses rather than genuinely improve task performance. For example, if the evaluator rewards verbose outputs, prompts evolve to generate irrelevant but fluent text that scores well on surface metrics but fails the actual task.

**Detection Component: "Reality Anchor Agent"**
- Maintains a small set of hand-crafted "gold standard" input-output pairs
- Periodically tests current best prompt against these known cases
- Computes alignment between automatic metrics and ground truth performance
- **Intervention trigger**: If automatic scores improve but gold standard performance plateaus/declines for 2+ iterations, the system:
  1. Reverts to last prompt that showed gold standard improvement
  2. Replaces Evaluator with more robust evaluation strategy
  3. Increases exploration budget temporarily

**Backup Safeguard:**
- External validation loop: Every 10 iterations, sample 5 outputs for human evaluation (if available) or cross-model validation using a different LLM family as judge

This design ensures that apparent improvement actually translates to genuine task performance while maintaining autonomous operation after startup.

---

###  **openrouter/deepseek/deepseek-v3.2** — 6.5/10

**Judge's Assessment:**
Very brief and sparse. Provides all requested elements concisely but lacks depth and elaboration compared to peers.

**Full Response:**
**Closed‑Loop Prompt Improvement System**

**Agents & Flow**
1. **Executor** – runs each prompt on the task, produces outputs.
2. **Evaluator** – scores outputs using a rubric (automated metric or LLM‑as‑judge).
3. **Optimizer** – uses scores/feedback to generate a new prompt set (evolutionary, LLM‑based, or gradient‑free).
4. **Loop**: Executor → Evaluator → Optimizer → repeat.

**Measuring “Better/Worse”**
- Primary: average score across task inputs rises → better.
- Secondary: low variance (robustness), output diversity.
- Convergence: stop when score plateaus or max iterations reached.

**Anti‑Stuck Mechanisms**
- **Diversity preservation** – enforce differences between prompts.
- **Exploration budget** – inject random prompts each iteration.
- **Restart** – reset part of population if stagnation.
- **Multi‑objective scoring** – balance quality with other desiderata.

**Stress‑Test & Silent Failure**
**Most likely failure**: *Evaluator over‑fit* (score hacking).  
The Optimizer learns to game the Evaluator’s quirks, raising scores without real task improvement.

**Catching It: The Validator Component**
- **Role**: Periodically test best prompts on a held‑out validation set with a different, more robust metric.
- **Action**: If validation score diverges significantly from primary score (>10% drop), trigger alarm and:
  1. Roll back to last good checkpoint.
  2. Adjust the Evaluator (rotate criteria, add regularization).
  3. Expand validation set with adversarial examples.

**System Diagram**
```
[Prompt Set] → Executor → Outputs → Evaluator → Scores
    ↑                                      ↓
    └── Optimizer ←── Feedback ←───┘
          ↓
    [New Prompt Set]
          ↓
    Validator (every K iterations) → Alarm if divergence
```

**Result**: A fully autonomous loop that improves prompts while guarding against the most insidious failure—evaluator over‑fit—through independent validation.

---

## Judge's Overall Assessment

The models provided sophisticated systemic structures for prompt optimization.

### Rankings

1st Place: **openrouter/moonshotai/kimi-k2.5** (Score: 9.5/10)
Reasoning: Detailed, elegant implementation of 5 agents (including Adversarial Validator). Explicitly addresses evaluation rigor (paired t-test, statistical significance limits). High clarity.

2nd Place: **google/gemini-2.5-pro** (Score: 9.2/10)
Reasoning: Exceptional real-world breakdown of the loop elements. The inclusion of a Red Team Agent explicitly feeding back into the Judge rubric itself is a brilliant meta-loop concept missing in most others.

3rd Place: **openrouter/anthropic/claude-sonnet-4.6** (Score: 9.0/10)
Reasoning: Structured cleanly. The auditor and shadow benchmark test is a great defense against dataset overfitting, specifically noting that the problem isn't just metric gaming but optimizing for the test dataset.

4th Place: **openrouter/mistralai/mistral-large-2512** (Score: 8.5/10)
Reasoning: Employs a validation agent every 3rd iteration and tracks explicit "deltas" over time. Great layout using tables and detailed JSON payload flows.

5th Place: **openrouter/x-ai/grok-4** (Score: 7.8/10)
Reasoning: Solid fundamentals, outlining basic generator, evaluator, refiner, selector, and validator agents, but lacks the deeper nuance in preventing stagnation that higher-ranked models posited.

6th Place: **openrouter/qwen/qwen3-max** (Score: 7.5/10)
Reasoning: A good base model utilizing an Executor, Evaluator, and Optimizer alongside a "Reality Anchor". Strong structural framework but reads more like an outline than a detailed implementation.

7th Place: **openrouter/deepseek/deepseek-v3.2** (Score: 6.5/10)
Reasoning: Very brief and sparse. Provides all requested elements concisely but lacks depth and elaboration compared to peers.

### Overall Assessment
Most models easily identified the correct standard architecture: Generator -> Executor -> Evaluator/Ranker -> Cycle. Almost all of them (correctly) identified 'overfitting' or 'metric gaming/score hacking' as the primary mode of silent failure, which happens when the generated prompts evolve to explicitly exploit the evaluation criteria without actually doing the goal task better in a generalized context. The best responses created multi-tiered defense systems consisting of entirely separate validation pools or secondary independent Red Team evaluation agents to ensure robustness.

---

## Blind Judging Key (Audit)

- Response A → openrouter/anthropic/claude-sonnet-4.6
- Response B → openrouter/moonshotai/kimi-k2.5
- Response C → openrouter/qwen/qwen3-max
- Response D → openrouter/x-ai/grok-4
- Response E → google/gemini-2.5-pro
- Response F → openrouter/mistralai/mistral-large-2512
- Response G → openrouter/deepseek/deepseek-v3.2

---

## Metadata

- **Total Duration:** 139.0s
- **Successful Models:** 7
- **Failed Models:** 0
