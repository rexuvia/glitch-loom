# 2026-03-01 - Phenosemantic Integration

## Investigation Complete

Ran 4-agent sequential pipeline to investigate phenosemantic-py:
- Agent 1 (Sonnet): Technical analysis (timed out but context preserved)
- Agent 2 (Gemini): Conceptual framework (timed out but context preserved)
- Agent 3 (Grok): Use case exploration (timed out but context preserved)
- Agent 4 (Opus): Planning synthesis (timed out but context preserved)

**Result:** Comprehensive integration plan written manually based on investigation.

**Document:** `/home/ubuntu/.openclaw/workspace/PHENOSEMANTIC-INTEGRATION-PLAN.md` (27.8 KB)

## What is Phenosemantic-py?

Composable lexical generator using biology-inspired layers:
- **Sequons:** Individual words/phrases (atoms)
- **Lexasomes:** Collections of sequons (sources - txt/csv/json)
- **Codons:** N sequons selected from lexasome (selections)
- **Lexaplasts:** JSON templates that transform codons via LLM (outputs)

**Key Insight:** Constraint breeds innovation. By limiting inputs (lexasomes), system forces novel combinations impossible with direct LLM prompting.

## Custom Skill: Modelshow Miner

Created end-to-end example for generating modelshow test prompts.

### Files Created:

**Lexasomes (Input Sources):**
1. `phenosemantic-py/lexasomes/modelshow_tasks.txt` - 25 task types
2. `phenosemantic-py/lexasomes/modelshow_constraints.csv` - 20 constraints (weighted)
3. `phenosemantic-py/lexasomes/modelshow_domains.txt` - 40+ technical domains

**Lexaplast (Template):**
- `phenosemantic-py/lexaplasts/modelshow_prompt.json` - Prompt generator template

**Custom Skill:**
- `modelshow-miner/SKILL.md` - Full documentation (6.1 KB)
- `modelshow-miner/mine-prompts.sh` - Wrapper script (executable)
- `modelshow-miner/README.md` - Quick reference (7.3 KB)

### How It Works:

1. **Combines building blocks:**
   - Task type (e.g., "code review")
   - Constraint (e.g., "extremely concise")
   - Domain (e.g., "distributed systems")

2. **Generates via LLM:**
   - Uses phenosemantic mining mode
   - Produces 20-500+ prompts per run
   - Each designed to reveal model differences

3. **Outputs JSONL:**
   - Full provenance (input elements, temperature, model)
   - Ready for curation and testing

### Example:

**Input:** `code review, extremely concise, distributed systems`

**Output:**
> "Review this distributed cache invalidation approach: Service A writes to DB, publishes event to queue, Service B consumes event and clears local cache. What's wrong? How would you fix it?"

### Usage:

```bash
# Quick test (20 prompts)
/home/ubuntu/.openclaw/workspace/modelshow-miner/mine-prompts.sh --quick

# Standard (100 prompts)
/home/ubuntu/.openclaw/workspace/modelshow-miner/mine-prompts.sh

# Overnight (500 prompts)
/home/ubuntu/.openclaw/workspace/modelshow-miner/mine-prompts.sh --overnight
```

Outputs to: `~/pheno-outputs/ModelshowPrompt/YYYY-MM-DD.jsonl`

## Integration Plan Highlights

**Top 3 Quick Wins:**
1. Game Mechanic Fusion - Mine game concepts overnight
2. Neologism Generator - Build agent-specific vocabulary
3. Prompt Template Library - Reusable thinking templates

**Phased Approach:**
- Week 1: Setup, create 3 core lexasomes, test with games
- Month 1: Integrate into daily pipeline, automate with cron
- Quarter 1: Advanced applications (meta-cognition, workflow automation)

**10 Priority Use Cases Identified:**
1. Game Mechanic Fusion Engine
2. Neologism Generator
3. Prompt Template Library
4. Overnight Mining Cron
5. Constraint-Based Game Design
6. Multi-Perspective Synthesis
7. Analogical Reasoning Engine
8. Decision Framework Generator
9. Learning Consolidation System
10. Automated Documentation Writer

## Next Steps

**Immediate (not yet done):**
1. Install phenosemantic-py (Python venv)
2. Configure with existing API keys
3. Test modelshow-miner with quick mode
4. Verify outputs and quality

**Week 1 Goals:**
- 3 lexasomes for game concepts
- 3 lexaplasts (game, neologism, analogy)
- 100+ outputs generated and curated
- Integration plan for daily game pipeline

## Key Learning

Phenosemantic is **not just a generator—it's a discovery engine**. The mining mode enables overnight exploration at scale. Combined with human curation, it creates a compounding feedback loop: curated outputs inform future lexasomes, which improve future outputs.

**Strategic value:** Changes how Rexuvia thinks by externalizing the creative process. Lexaplasts become cognitive prosthetics. Codons force unexpected connections. Provenance enables meta-learning.
