---
name: phenosemantic-manager
description: "Manage phenosemantic-py lexaplasts and lexasomes, mine outputs, and schedule automatic ranking. User-friendly wrapper for phenosemantic-py functionality."
homepage: https://github.com/schbz/phenosemantic-py
metadata:
  openclaw:
    emoji: "🧬"
    requires:
      bins: ["python3", "git"]
      paths: ["/home/ubuntu/.openclaw/workspace/phenosemantic-py"]
---

# Phenosemantic Manager Skill

A user-friendly wrapper for phenosemantic-py that lets you create and manage lexaplasts/lexasomes, mine outputs, and schedule automatic ranking for morning review.

## When to Use

✅ **USE this skill when:**
- Want to use phenosemantic-py without dealing with Python scripts
- Need to create/edit lexaplasts or lexasomes
- Want to schedule overnight mining jobs
- Need automatic ranking of generated outputs
- Want a simple CLI interface for phenosemantic functionality

✅ **Perfect for:**
- Game idea generation
- Creative writing prompts  
- Technical question generation
- Test case creation
- Any structured text generation

## When NOT to Use

❌ **DON'T use this skill when:**
- Need low-level control over phenosemantic-py
- Want to modify the phenosemantic-py codebase
- Need real-time interactive generation
- Working with very small batches (< 10 outputs)

## Quick Start

### 1. Initialize
```bash
cd /home/ubuntu/.openclaw/workspace/phenosemantic-manager
./pheno-manager init
```

### 2. Create Your First Lexaplast
```bash
# Create a game concept generator
./pheno-manager create-lexaplast game-concepts --template creative

# Or create from scratch
./pheno-manager create-lexaplast technical-questions --interactive
```

### 3. Create Lexasomes
```bash
# Create a text lexasome
./pheno-manager create-lexasome game-mechanics --type txt
./pheno-manager add-to-lexasome game-mechanics --text "procedural generation"
./pheno-manager add-to-lexasome game-mechanics --text "physics simulation"

# Import from file
./pheno-manager import-lexasome creative-domains --file ~/domains.txt
```

### 4. Mine Outputs
```bash
# Mine 100 outputs
./pheno-manager mine \
  --lexaplast game-concepts \
  --lexasome game-mechanics creative-domains \
  --count 100 \
  --temperature 0.8

# Check progress
./pheno-manager status
```

### 5. Review Results
```bash
# List recent mining jobs
./pheno-manager list-jobs

# View outputs from a job
./pheno-manager view-outputs --job 2026-03-02-abc123

# See top-ranked outputs
./pheno-manager top-outputs --job 2026-03-02-abc123 --limit 10
```

### 6. Schedule Overnight Mining
```bash
# Schedule for 3 AM
./pheno-manager schedule \
  --name "nightly-game-ideas" \
  --time "03:00" \
  --lexaplast game-concepts \
  --lexasome game-mechanics creative-domains \
  --count 300 \
  --notify telegram

# List scheduled jobs
./pheno-manager list-scheduled
```

## Core Commands

### Lexaplast Management
```bash
# Create a new lexaplast
./pheno-manager create-lexaplast <name> [--template <type>] [--interactive]

# Edit an existing lexaplast
./pheno-manager edit-lexaplast <name>

# List all lexaplasts
./pheno-manager list-lexaplasts

# Test a lexaplast
./pheno-manager test-lexaplast <name> [--lexasome <name>] [--count <n>]
```

### Lexasome Management
```bash
# Create a new lexasome
./pheno-manager create-lexasome <name> [--type txt|csv|json]

# Add entries to a lexasome
./pheno-manager add-to-lexasome <name> --text "entry" [--weight 1.0]

# Import from file
./pheno-manager import-lexasome <name> --file <path>

# List all lexasomes
./pheno-manager list-lexasomes
```

### Mining Operations
```bash
# Mine outputs
./pheno-manager mine \
  --lexaplast <name> \
  --lexasome <name1> [name2...] \
  --count <n> \
  [--temperature <0.0-1.0>] \
  [--delay <ms>] \
  [--provider openai|anthropic|deepseek]

# Check mining status
./pheno-manager status [--job <id>]

# Cancel a mining job
./pheno-manager cancel --job <id>
```

### Output Management
```bash
# List mining jobs
./pheno-manager list-jobs [--days <n>]

# View outputs from a job
./pheno-manager view-outputs --job <id> [--limit <n>]

# Rank outputs
./pheno-manager rank --job <id> [--method simple|llm]

# Get top outputs
./pheno-manager top-outputs --job <id> [--limit <n>]

# Export outputs
./pheno-manager export --job <id> --format txt|json|csv
```

### Scheduling
```bash
# Schedule a mining job
./pheno-manager schedule \
  --name <name> \
  --time <HH:MM> \
  --lexaplast <name> \
  --lexasome <name1> [name2...] \
  --count <n> \
  [--notify telegram|email]

# List scheduled jobs
./pheno-manager list-scheduled

# Remove a scheduled job
./pheno-manager unschedule --name <name>
```

## Workflow Examples

### Daily Game Idea Pipeline
```bash
# 1. Create lexaplast for game concepts
./pheno-manager create-lexaplast daily-game-ideas --template game-concepts

# 2. Ensure lexasomes exist
./pheno-manager create-lexasome game-genres --type txt
./pheno-manager create-lexasome game-mechanics --type txt
./pheno-manager create-lexasome platforms --type txt

# 3. Schedule nightly mining
./pheno-manager schedule \
  --name "daily-game-ideas" \
  --time "02:00" \
  --lexaplast daily-game-ideas \
  --lexasome game-genres game-mechanics platforms \
  --count 200 \
  --notify telegram

# 4. Morning review
./pheno-manager top-outputs --date today --limit 20
```

### Creative Writing Prompts
```bash
# 1. Create writing prompt generator
./pheno-manager create-lexaplast writing-prompts --template creative

# 2. Build lexasomes
./pheno-manager create-lexasome genres --type txt
./pheno-manager add-to-lexasome genres --text "science fiction"
./pheno-manager add-to-lexasome genres --text "fantasy"
./pheno-manager add-to-lexasome genres --text "mystery"

./pheno-manager create-lexasome characters --type txt
./pheno-manager add-to-lexasome characters --text "reluctant hero"
./pheno-manager add-to-lexasome characters --text "wise mentor"

# 3. Mine prompts
./pheno-manager mine \
  --lexaplast writing-prompts \
  --lexasome genres characters settings \
  --count 50 \
  --temperature 0.9

# 4. Get best prompts
./pheno-manager rank --job latest --method llm
./pheno-manager top-outputs --job latest --limit 10
```

### Technical Interview Questions
```bash
# 1. Create question generator
./pheno-manager create-lexaplast tech-questions --template technical

# 2. Import domain knowledge
./pheno-manager import-lexasome programming-languages --file ~/languages.txt
./pheno-manager import-lexasome concepts --file ~/cs-concepts.txt

# 3. Mine questions
./pheno-manager mine \
  --lexaplast tech-questions \
  --lexasome programming-languages concepts \
  --count 100 \
  --temperature 0.7

# 4. Export for review
./pheno-manager export --job latest --format txt
```

## Configuration

### Skill Configuration
The skill stores configuration in:
- `config/lexaplasts/` - Your lexaplast JSON files
- `config/lexasomes/` - Your lexasome text/CSV/JSON files  
- `db/pheno-manager.db` - SQLite database for tracking
- `outputs/` - Generated outputs

### phenosemantic-py Integration
The skill expects phenosemantic-py to be installed at:
`/home/ubuntu/.openclaw/workspace/phenosemantic-py`

Make sure it's set up:
```bash
cd /home/ubuntu/.openclaw/workspace/phenosemantic-py
source .venv/bin/activate
pheno --version  # Should work
```

### API Keys
The skill uses phenosemantic-py's configuration for API keys. Ensure your `config.ini` has valid keys for:
- OpenAI
- Anthropic  
- DeepSeek (recommended for mining - cheaper)

## Advanced Usage

### Custom Templates
Create custom lexaplast templates in `config/templates/`:
```json
{
  "name": "custom-template",
  "description": "My custom template",
  "system_prompt": "You are a...",
  "user_prompt_template": "Generate a {domain} {task} with {constraint}",
  "parameters": {
    "temperature": 0.8,
    "max_tokens": 500
  }
}
```

### Weighted Lexasomes (CSV)
Create CSV lexasomes with weights:
```bash
# Create weighted lexasome
./pheno-manager create-lexasome weighted-topics --type csv
./pheno-manager add-to-lexasome weighted-topics --text "AI safety" --weight 2.0
./pheno-manager add-to-lexasome weighted-topics --text "Web development" --weight 1.0
./pheno-manager add-to-lexasome weighted-topics --text "Game design" --weight 1.5
```

### JSON Lexasomes (Combiners)
Create JSON lexasomes that combine other lexasomes:
```json
{
  "type": "combiner",
  "sources": ["lexasome1", "lexasome2"],
  "operation": "cartesian"  // or "random", "sequential"
}
```

### LLM-Based Ranking
Use GPT-4 or Claude to rank outputs:
```bash
# Rank with LLM
./pheno-manager rank --job <id> --method llm --model gpt-4

# Custom ranking criteria
./pheno-manager rank --job <id> --criteria "creativity, clarity, usefulness"
```

## Troubleshooting

### Common Issues

**"phenosemantic-py not found"**
```bash
# Check installation
cd /home/ubuntu/.openclaw/workspace/phenosemantic-py
source .venv/bin/activate
pheno --version
```

**"API key error"**
```bash
# Check config.ini
cat /home/ubuntu/.openclaw/workspace/phenosemantic-py/config.ini

# Test with simple command
pheno --lexasome default --lexaplast default --count 1
```

**"Mining stuck"**
```bash
# Check status
./pheno-manager status --job <id>

# Cancel and retry
./pheno-manager cancel --job <id>
./pheno-manager mine ...  # with --delay 2000
```

**"Low quality outputs"**
- Adjust temperature (lower = more focused)
- Improve lexaplast template
- Clean up lexasome entries
- Use `--random-temp` for variety

### Logs
Check logs for detailed errors:
```bash
tail -f /home/ubuntu/.openclaw/workspace/phenosemantic-manager/logs/pheno-manager.log
```

## Integration with OpenClaw

### Natural Language Commands
Use natural language via OpenClaw:
```
"Create a lexaplast for generating coding challenges"
"Mine 100 game ideas using my game-concepts lexaplast"
"Schedule overnight mining for creative prompts"
"Show me the top 10 outputs from last night"
```

### Cron Integration
The skill creates OpenClaw cron jobs for scheduled mining. View them with:
```bash
openclaw cron list
```

### Memory Integration
Mining jobs are logged to memory files:
- `memory/YYYY-MM-DD.md` - Daily logs
- Job metadata in SQLite database

## Performance Tips

### For Speed
- Use DeepSeek provider for mining (cheaper, faster)
- Set `--delay 1000` (1 second) between calls
- Mine in batches of 50-100
- Use `--incognito` to skip interactive steps

### For Quality
- Start with small tests (--count 10)
- Refine lexaplast based on results
- Curate lexasomes regularly
- Use LLM ranking for important outputs

### For Reliability
- Schedule during off-peak hours
- Monitor API usage
- Keep backups of important lexaplasts/lexasomes
- Check logs regularly

## Contributing

### File Structure
```
phenosemantic-manager/
├── SKILL.md                    # This file
├── pheno-manager              # Main CLI script
├── scripts/                   # Python modules
│   ├── mine.py
│   ├── rank.py
│   ├── create.py
│   └── schedule.py
├── config/                    # User configurations
├── db/                        # SQLite database
├── outputs/                   # Generated outputs
└── logs/                      # Activity logs
```

### Adding New Features
1. Add command to `pheno-manager` script
2. Implement in appropriate `scripts/` module
3. Update documentation in `SKILL.md`
4. Test thoroughly

---

**Created by:** Rexuvia  
**Last Updated:** 2026-03-02  
**Status:** Active Development