# Modelshow Miner

**Generate challenging test prompts for modelshow using phenosemantic-py**

## Overview

This custom OpenClaw skill uses phenosemantic-py to mine diverse, high-quality prompts that reveal differences between AI models in blind comparisons.

### What It Does

1. **Combines conceptual building blocks:**
   - Task types (code review, ethical dilemma, system design, etc.)
   - Constraints (concise, detailed, with humor, expert-level, etc.)
   - Domains (web dev, ML, distributed systems, etc.)

2. **Generates prompts via LLM:**
   - Uses phenosemantic's mining mode for batch generation
   - Produces 20-500+ prompts in one run
   - Each prompt designed to reveal model differences

3. **Outputs structured data:**
   - JSONL format with full provenance
   - Includes input elements, temperature, model used
   - Ready for curation and testing

## Quick Start

### 1. Setup (First Time)

```bash
cd /home/ubuntu/.openclaw/workspace/phenosemantic-py

# Create virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install phenosemantic
pip install -e .

# Configure (will prompt for API keys on first run)
pheno

# Add API keys to config.ini (can reuse OpenClaw keys)
# Set output_base_path = ~/pheno-outputs
```

### 2. Generate Prompts

**Quick test (20 prompts):**
```bash
/home/ubuntu/.openclaw/workspace/modelshow-miner/mine-prompts.sh --quick
```

**Standard batch (100 prompts):**
```bash
/home/ubuntu/.openclaw/workspace/modelshow-miner/mine-prompts.sh
```

**Overnight mining (500 prompts):**
```bash
/home/ubuntu/.openclaw/workspace/modelshow-miner/mine-prompts.sh --overnight
```

### 3. Review & Use

```bash
# View generated prompts
less ~/pheno-outputs/ModelshowPrompt/$(date +%Y-%m-%d).jsonl

# Extract just the text
jq -r '.text' ~/pheno-outputs/ModelshowPrompt/$(date +%Y-%m-%d).jsonl > prompts.txt

# Test first prompt with modelshow
mdls "$(head -1 prompts.txt)"
```

## Files Created

### Lexasomes (Input Sources)
- `phenosemantic-py/lexasomes/modelshow_tasks.txt` - 25 task types
- `phenosemantic-py/lexasomes/modelshow_constraints.csv` - 20 constraints (weighted)
- `phenosemantic-py/lexasomes/modelshow_domains.txt` - 40+ technical domains

### Lexaplast (Prompt Template)
- `phenosemantic-py/lexaplasts/modelshow_prompt.json` - Generation template

### Skill Files
- `SKILL.md` - Full documentation
- `mine-prompts.sh` - Easy-to-use wrapper script
- `README.md` - This file

## Example Output

**Input Elements:** `code review, extremely concise, distributed systems`

**Generated Prompt:**
> "Review this distributed cache invalidation approach: Service A writes to DB, publishes event to queue, Service B consumes event and clears local cache. What's wrong? How would you fix it?"

**Why This Works for Modelshow:**
- Clear technical problem
- Multiple valid approaches
- Reveals model knowledge depth
- Shows reasoning style differences
- Not trivially googleable

## Advanced Usage

### Custom Domains

Create targeted lexasomes for specific areas:

```bash
cat > ~/phenosemantic-py/lexasomes/frontend-domains.txt << 'EOF'
React patterns
Vue reactivity
state management
performance optimization
bundle size
lazy loading
code splitting
hydration
EOF

# Mine with custom domains
cd ~/phenosemantic-py
source .venv/bin/activate
pheno --mine 50 \
  --lexasome modelshow_tasks \
  --lexasome modelshow_constraints \
  --lexasome frontend-domains \
  --lexaplast modelshow_prompt
```

### Automated Testing Pipeline

1. **Mine prompts overnight (cron at 3 AM)**
2. **Filter for quality in morning (housekeeping mode)**
3. **Feed top prompts to modelshow throughout the day**
4. **Collect modelshow results for analysis**

### Integration with Rexuvia Workflow

**Daily model testing routine:**
```bash
# Morning: Review mined prompts
pheno --housekeep ~/pheno-outputs/ModelshowPrompt/

# Extract high-rated prompts
jq 'select(.rating >= 4) | .text' ~/pheno-outputs/ModelshowPrompt/*.jsonl > today-prompts.txt

# Throughout day: Test with modelshow
# (Use in Telegram or OpenClaw chat)
```

## Command Reference

### mine-prompts.sh Options

```
-n, --count NUM       Number of prompts (default: 100)
-d, --delay MS        Delay between API calls (default: 1000)
-r, --random-temp     Use random temperature variation
-q, --quick           Quick mode: 20 prompts
-o, --overnight       Overnight mode: 500 prompts, 2s delay
-h, --help            Show help
```

### Direct Phenosemantic Commands

```bash
# Standard mining
pheno --mine 100 --lexasome modelshow_tasks --lexaplast modelshow_prompt

# With multiple lexasomes (creates 3-element codons)
pheno --mine 100 \
  --lexasome modelshow_tasks \
  --lexasome modelshow_constraints \
  --lexasome modelshow_domains \
  --lexaplast modelshow_prompt

# Random temperature exploration
pheno --mine 200 --lexasome modelshow_tasks --lexaplast modelshow_prompt --random-temp

# With specific seed for reproducibility
pheno --mine 50 --lexasome modelshow_tasks --lexaplast modelshow_prompt --seed 42

# Housekeeping (curation)
pheno --housekeep ~/pheno-outputs/ModelshowPrompt/
```

## Output Format

Each generated prompt is saved as a JSONL line:

```json
{
  "text": "Design a browser game that combines: platformer, one-button control, underwater environment. Technical constraints: Canvas-based, 60fps, mobile-first, single HTML file. Explain core mechanic, controls, win condition.",
  "codon_sequons": ["creative writing", "extremely concise", "game design"],
  "rating": 5,
  "provider": "openai",
  "model": "gpt-4o",
  "temperature": 0.85,
  "timestamp": "2026-03-01T13:00:00.000Z",
  "lexaplast_hash": "abc123...",
  "lexasome_hashes": ["def456...", "ghi789..."]
}
```

## Tips & Best Practices

**For Quality:**
- Start with small batches (20-50) to test lexaplast
- Refine template based on what generates well
- Use housekeeping mode to curate and rate
- Build feedback loop: best prompts inform future lexasomes

**For Diversity:**
- Use `--random-temp` for variation
- Combine different domains
- Update lexasomes regularly with new concepts
- Experiment with different sequon combinations

**For Efficiency:**
- Mine overnight with `--delay 2000`
- Use `--incognito` to skip interactive rating
- Curate in batch during morning coffee
- Automate with cron for continuous pipeline

**For Integration:**
- Keep prompts.txt file for easy access
- Use jq to filter by rating or domain
- Integrate with modelshow via simple read loop
- Track which prompts reveal most differences

## Troubleshooting

**"command not found: pheno"**
→ Activate venv: `source ~/phenosemantic-py/.venv/bin/activate`

**"API key not found"**
→ Add to config.ini: `nano ~/phenosemantic-py/config.ini`

**"No outputs generated"**
→ Check lexasomes exist: `ls ~/phenosemantic-py/lexasomes/modelshow_*`

**"Rate limited by API"**
→ Increase delay: `mine-prompts.sh -d 3000` (3 seconds)

## Next Steps

1. **Test the pipeline:** Run quick mode and review outputs
2. **Refine lexasomes:** Add domain-specific vocabulary
3. **Customize lexaplast:** Adjust template for your needs
4. **Automate mining:** Set up nightly cron job
5. **Integrate with modelshow:** Build testing routine
6. **Analyze results:** Track which prompts reveal most

---

**Created:** 2026-03-01  
**Author:** Rexuvia  
**Version:** 1.0  
**Status:** Production-ready
