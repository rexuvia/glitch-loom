---
name: modelshow-miner
description: "Mine challenging test prompts for modelshow using phenosemantic-py. Generates diverse, high-quality prompts that reveal model differences through long-running exploration."
homepage: https://github.com/schbz/phenosemantic-py
metadata:
  openclaw:
    emoji: "⛏️"
    requires:
      bins: ["python3"]
      paths: ["/home/ubuntu/.openclaw/workspace/phenosemantic-py"]
---

# Modelshow Miner Skill

Generate challenging test prompts for the modelshow skill using phenosemantic-py's mining mode.

## When to Use

✅ **USE this skill when:**
- Need diverse test prompts for modelshow blind comparisons
- Want to explore edge cases that reveal model differences
- Building a prompt library for systematic model evaluation
- Running overnight exploration for interesting prompts
- Need prompts across different domains/constraints

## When NOT to Use

❌ **DON'T use this skill when:**
- Need a single specific prompt (write it directly)
- Time-sensitive (mining takes time)
- Want interactive curation (use phenosemantic directly)

## Quick Start

### Mine 100 Prompts (Standard)
```bash
cd /home/ubuntu/.openclaw/workspace/phenosemantic-py
source .venv/bin/activate
pheno --mine 100 \
  --lexasome modelshow_tasks \
  --lexasome modelshow_constraints \
  --lexasome modelshow_domains \
  --lexaplast modelshow_prompt \
  --length 3 \
  --incognito
```

### Mine 500 Prompts (Overnight)
```bash
pheno --mine 500 \
  --lexasome modelshow_tasks \
  --lexasome modelshow_constraints \
  --lexasome modelshow_domains \
  --lexaplast modelshow_prompt \
  --length 3 \
  --delay 2000 \
  --incognito
```

### Mine with Random Temperature (Exploration)
```bash
pheno --mine 200 \
  --lexasome modelshow_tasks \
  --lexasome modelshow_constraints \
  --lexasome modelshow_domains \
  --lexaplast modelshow_prompt \
  --random-temp \
  --incognito
```

## Output Location

Prompts are saved to:
```
~/pheno-outputs/ModelshowPrompt/YYYY-MM-DD.jsonl
```

Each line contains:
- `text`: The generated prompt
- `codon_sequons`: The input elements (task, constraint, domain)
- `rating`: User rating (if curated)
- `provider`: API provider used
- `model`: Model used for generation
- `temperature`: Generation temperature
- `timestamp`: When generated

## Curation Workflow

After mining, curate the best prompts:

```bash
# Review and rate outputs
pheno --housekeep ~/pheno-outputs/ModelshowPrompt/

# Filter for 4-5 star ratings
jq 'select(.rating >= 4)' ~/pheno-outputs/ModelshowPrompt/YYYY-MM-DD.jsonl > best-prompts.jsonl

# Extract just the prompt text
jq -r '.text' best-prompts.jsonl > modelshow-prompts.txt
```

## Integration with Modelshow

Use mined prompts with modelshow:

```bash
# Read first prompt from file
PROMPT=$(head -1 modelshow-prompts.txt)

# Run modelshow with that prompt
# (In OpenClaw chat context)
mdls $PROMPT
```

Or automate testing multiple prompts in sequence.

## Advanced Usage

### Target Specific Domains

Create a custom lexasome with only your target domains:

```bash
echo "web development
frontend performance
Canvas rendering
WebGL
state management" > /home/ubuntu/.openclaw/workspace/phenosemantic-py/lexasomes/custom-domains.txt

pheno --mine 50 \
  --lexasome modelshow_tasks \
  --lexasome modelshow_constraints \
  --lexasome custom-domains \
  --lexaplast modelshow_prompt
```

### Automated Nightly Mining

Create `/home/ubuntu/.openclaw/workspace/modelshow-miner/nightly-mine.sh`:

```bash
#!/bin/bash
cd /home/ubuntu/.openclaw/workspace/phenosemantic-py
source .venv/bin/activate

DATE=$(date +%Y-%m-%d)
mkdir -p ~/mining-logs
LOG=~/mining-logs/modelshow-$DATE.log

echo "Starting modelshow mining: $DATE" >> $LOG

pheno --mine 200 \
  --lexasome modelshow_tasks \
  --lexasome modelshow_constraints \
  --lexasome modelshow_domains \
  --lexaplast modelshow_prompt \
  --length 3 \
  --random-temp \
  --delay 2000 \
  --incognito >> $LOG 2>&1

echo "Mining complete: $(date)" >> $LOG
echo "done" > ~/mining-logs/modelshow-$DATE.done
```

Make executable:
```bash
chmod +x /home/ubuntu/.openclaw/workspace/modelshow-miner/nightly-mine.sh
```

Add to crontab:
```bash
0 3 * * * /home/ubuntu/.openclaw/workspace/modelshow-miner/nightly-mine.sh
```

## Example Prompts

Here are examples of what gets generated:

**Input:** `code review, extremely concise, distributed systems`
**Output:**
> "Review this distributed cache invalidation approach: Service A writes to DB, publishes event to queue, Service B consumes event and clears local cache. What's wrong? How would you fix it?"

**Input:** `ethical dilemma, multiple perspectives, machine learning`
**Output:**
> "An ML model predicting recidivism is 15% more accurate than human judges but shows racial bias. Judges show the same bias but are less accurate. Should the model be used? Argue for and against, then decide."

**Input:** `naming things, with humor, API design`
**Output:**
> "You're designing an API for a time-travel service. Name the endpoints, methods, and error codes. Constraint: every name must be a pun or reference to time-travel movies."

## Tips

**For Diverse Outputs:**
- Use `--random-temp` to vary creativity
- Mine in batches of 50-100 for manageable curation
- Mix domains to get unexpected combinations

**For Quality:**
- Start with small batches (20-50) to test lexaplast
- Refine lexaplast based on what generates well
- Curate ruthlessly—quality over quantity

**For Efficiency:**
- Use `--delay` to avoid rate limits
- Use `--incognito` to skip interactive curation
- Mine overnight, curate in the morning

## Troubleshooting

**No outputs generated:**
- Check phenosemantic is installed: `pheno --version`
- Verify lexasomes exist in `phenosemantic-py/lexasomes/`
- Check API keys in `config.ini`

**Low-quality outputs:**
- Refine lexaplast template
- Adjust temperature (lower = more focused)
- Improve lexasome quality (remove weak entries)

**API rate limits:**
- Add `--delay 2000` (2 seconds between calls)
- Use DeepSeek provider (cheaper, faster for mining)
- Reduce batch size

---

**Created by:** Rexuvia  
**Last Updated:** 2026-03-01  
**Status:** Active
