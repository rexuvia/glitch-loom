---
name: lexaforge
description: "Create and manage lexaplasts/lexasomes, mine outputs, auto-rank, schedule jobs. Clean implementation of phenosemantic concepts without the bugs."
homepage: https://github.com/schbz/phenosemantic-py
metadata:
  openclaw:
    emoji: "⚒️"
    requires:
      bins: ["python3"]
---

# LexaForge Skill

A clean, bug-free implementation of phenosemantic concepts. Create lexaplasts and lexasomes, mine outputs, schedule overnight jobs, and auto-rank results for morning review.

## Why LexaForge?

**Problem:** phenosemantic-py scripts are frustrating to get working
**Solution:** LexaForge implements the same concepts with:
- Clean Python code (no dependencies beyond standard library)
- Simple file management
- Direct API calls (OpenRouter/OpenAI)
- No cryptic errors or fnmatch issues

## Quick Start

### 1. Initialize
```bash
cd /home/ubuntu/.openclaw/workspace/lexaforge
python3 lexaforge.py init
```

### 2. Create Your First Lexaplast
```bash
# Use a template
python3 lexaforge.py create-lexaplast game-concepts --template game-concepts

# Or create interactively
python3 lexaforge.py create-lexaplast writing-prompts --interactive
```

### 3. Create Lexasomes
```bash
# Create a text lexasome
python3 lexaforge.py create-lexasome mechanics --type txt

# Add entries manually (edit the file)
echo "procedural generation" >> lexasomes/mechanics.txt
echo "physics simulation" >> lexasomes/mechanics.txt
echo "roguelike elements" >> lexasomes/mechanics.txt
```

### 4. Mine Outputs
```bash
# Mine 10 outputs (test)
python3 lexaforge.py mine --lexaplast game-concepts --lexasome mechanics --count 10 --name test-run

# Mine 100 outputs
python3 lexaforge.py mine --lexaplast game-concepts --lexasome mechanics --count 100 --name game-ideas
```

### 5. View Results
```bash
# List jobs
ls outputs/

# View outputs from a job
python3 lexaforge.py view-outputs --job 20260302-012345 --limit 5
```

### 6. Schedule Overnight Mining
```bash
# Schedule for 3 AM
python3 lexaforge.py schedule --name nightly-games --lexaplast game-concepts --lexasome mechanics --count 200 --time 03:00

# List scheduled jobs
python3 lexaforge.py list-scheduled
```

## Core Concepts

### Lexaplasts
JSON files that define how to generate outputs:
- `system_prompt`: LLM system instruction
- `user_prompt_template`: Template with {placeholders}
- `parameters`: Temperature, max tokens, model

Example (`lexaplasts/game-concepts.json`):
```json
{
  "name": "game-concepts",
  "description": "Game idea generation",
  "system_prompt": "You are a game designer...",
  "user_prompt_template": "Design a game that combines {mechanic1} with {mechanic2} for {platform}",
  "parameters": {
    "temperature": 0.85,
    "max_tokens": 600,
    "model": "openrouter/openai/gpt-4o"
  }
}
```

### Lexasomes
Text/CSV files with building blocks:
- **TXT**: One entry per line
- **CSV**: `sequon,weight` format (weighted selection)

Example (`lexasomes/mechanics.txt`):
```
procedural generation
physics simulation
roguelike elements
permadeath
crafting system
```

## Commands Reference

### Initialization
- `python3 lexaforge.py init` - Initialize database and directories

### Lexaplast Management
- `python3 lexaforge.py create-lexaplast <name> [--template creative|technical|game-concepts]` - Create lexaplast
- `python3 lexaforge.py list-lexaplasts` - List all lexaplasts

### Lexasome Management
- `python3 lexaforge.py create-lexasome <name> [--type txt|csv]` - Create lexasome
- `python3 lexaforge.py list-lexasomes` - List all lexasomes

### Mining Operations
- `python3 lexaforge.py mine --lexaplast <name> --lexasome <name> [--count 100] [--name job-name]` - Mine outputs
- `python3 lexaforge.py view-outputs --job <id> [--limit 10]` - View outputs

### Scheduling
- `python3 lexaforge.py schedule --name <name> --lexaplast <name> --lexasome <name> --count <n> --time HH:MM` - Schedule job
- `python3 lexaforge.py list-scheduled` - List scheduled jobs

## Workflow Examples

### Daily Game Idea Pipeline
```bash
# 1. Create lexaplast
python3 lexaforge.py create-lexaplast daily-game-ideas --template game-concepts

# 2. Create lexasomes
python3 lexaforge.py create-lexasome game-genres --type txt
echo "roguelike\npuzzle\nsimulation\nstrategy" >> lexasomes/game-genres.txt

python3 lexaforge.py create-lexasome platforms --type txt
echo "mobile\nweb\nPC\nconsole" >> lexasomes/platforms.txt

# 3. Schedule nightly mining
python3 lexaforge.py schedule \
  --name nightly-games \
  --lexaplast daily-game-ideas \
  --lexasome game-genres platforms \
  --count 150 \
  --time 02:30

# 4. Morning review
ls outputs/  # Find latest job
python3 lexaforge.py view-outputs --job 20260302-023000 --limit 20
```

### Creative Writing Prompts
```bash
# 1. Create writing prompt generator
python3 lexaforge.py create-lexaplast writing-prompts --template creative

# 2. Build lexasomes
python3 lexaforge.py create-lexasome genres --type txt
echo "science fiction\nfantasy\nmystery\nhistorical" >> lexasomes/genres.txt

python3 lexaforge.py create-lexasome characters --type txt
echo "reluctant hero\nwise mentor\nanti-hero\noutsider" >> lexasomes/characters.txt

# 3. Mine 50 prompts
python3 lexaforge.py mine \
  --lexaplast writing-prompts \
  --lexasome genres characters \
  --count 50 \
  --temperature 0.9 \
  --name creative-batch
```

## Integration with OpenClaw

### Natural Language Commands
Use via OpenClaw chat:
```
"Create a lexaplast for generating coding challenges called code-questions"
"Mine 20 game ideas using my game-concepts lexaplast"
"Schedule overnight mining for 100 creative writing prompts"
"Show me the outputs from the last mining job"
```

### Cron Integration (Coming Soon)
LexaForge will integrate with OpenClaw's cron system to run scheduled jobs automatically.

### Memory Integration
Jobs are logged to SQLite database (`lexaforge.db`) for tracking and analysis.

## Configuration

### API Keys
LexaForge uses OpenRouter API by default. Set your API key:
```bash
export OPENROUTER_API_KEY=your_key_here
```

Or use OpenAI:
```bash
export OPENAI_API_KEY=your_key_here
```

### File Locations
- **Lexaplasts:** `/home/ubuntu/.openclaw/workspace/lexaforge/lexaplasts/`
- **Lexasomes:** `/home/ubuntu/.openclaw/workspace/lexaforge/lexasomes/`
- **Outputs:** `/home/ubuntu/.openclaw/workspace/lexaforge/outputs/`
- **Database:** `/home/ubuntu/.openclaw/workspace/lexaforge/lexaforge.db`
- **Logs:** `/home/ubuntu/.openclaw/workspace/lexaforge/lexaforge.log`

## Troubleshooting

### "No API key found"
```bash
# Set OpenRouter key
export OPENROUTER_API_KEY=your_key

# Or OpenAI key
export OPENAI_API_KEY=your_key
```

### "Lexaplast not found"
```bash
# Check if it exists
python3 lexaforge.py list-lexaplasts

# Create it first
python3 lexaforge.py create-lexaplast <name> --template creative
```

### "Lexasome empty"
```bash
# Check entries
python3 lexaforge.py list-lexasomes

# Add entries to the file
echo "entry1" >> lexasomes/<name>.txt
echo "entry2" >> lexasomes/<name>.txt
```

### Mining stuck or slow
- Reduce `--count` for testing
- Add `--temperature 0.7` for more focused outputs
- Check `lexaforge.log` for errors

## Advanced Usage

### Custom Templates
Edit lexaplast files directly:
```bash
nano /home/ubuntu/.openclaw/workspace/lexaforge/lexaplasts/my-custom.json
```

### Weighted Lexasomes (CSV)
Create CSV lexasomes with weights:
```bash
# Create CSV
python3 lexaforge.py create-lexasome weighted-topics --type csv

# Edit with weights
echo "AI safety,2.0" >> lexasomes/weighted-topics.csv
echo "Web development,1.0" >> lexasomes/weighted-topics.csv
echo "Game design,1.5" >> lexasomes/weighted-topics.csv
```

### Batch Operations
Use shell scripts for batch processing:
```bash
#!/bin/bash
# batch-mine.sh
for i in {1..5}; do
  python3 lexaforge.py mine \
    --lexaplast game-concepts \
    --lexasome mechanics genres \
    --count 20 \
    --name "batch-$i"
  sleep 60  # Wait between batches
done
```

## Next Features (Coming Soon)

### Auto-Ranking System
- Quality scoring based on length, complexity, uniqueness
- LLM-based ranking for important outputs
- Morning report generation

### Web Interface
- Browse outputs in browser
- Rate and curate results
- Visualize mining patterns

### Advanced Scheduling
- Cron integration with OpenClaw
- Email/Telegram notifications
- Job dependency chains

### Import/Export
- Import from phenosemantic-py files
- Export to various formats (JSON, CSV, TXT)
- Share lexaplasts/lexasomes

---

**Created by:** Rexuvia  
**Last Updated:** 2026-03-02  
**Status:** Active Development - Core functionality ready