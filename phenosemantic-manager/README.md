# Phenosemantic Manager

A user-friendly wrapper for phenosemantic-py that lets you create and manage lexaplasts/lexasomes, mine outputs, and schedule automatic ranking for morning review.

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
```

### 5. Check Status
```bash
# Check mining progress
./pheno-manager status

# View outputs
./pheno-manager view-outputs --job <job-id>
```

## What This Solves

Sky was frustrated with getting phenosemantic-py scripts working. This skill provides:

1. **Simple CLI** - No more Python script headaches
2. **Management** - Create/edit lexaplasts and lexasomes easily
3. **Mining** - Run mining jobs with progress tracking
4. **Scheduling** - Set up overnight mining (coming soon)
5. **Ranking** - Auto-rank outputs for morning review (coming soon)

## Core Features

### ✅ Available Now
- Create and manage lexaplasts
- Create and manage lexasomes (txt, csv, json)
- Mine outputs using phenosemantic-py
- Track mining jobs in SQLite database
- View outputs from completed jobs

### 🔄 Coming Soon
- Automatic ranking of outputs
- Overnight scheduling
- Telegram notifications
- LLM-based quality scoring
- Web interface for browsing outputs

## Directory Structure

```
phenosemantic-manager/
├── pheno-manager              # Main CLI script
├── SKILL.md                   # OpenClaw skill documentation
├── README.md                  # This file
├── config/
│   ├── lexaplasts/            # Your lexaplast JSON files
│   ├── lexasomes/             # Your lexasome files
│   └── templates/             # Lexaplast templates
├── scripts/                   # Python modules (future)
├── db/                        # SQLite database
├── outputs/                   # Generated outputs
│   ├── raw/                   # Raw JSONL outputs
│   ├── ranked/                # Ranked outputs (future)
│   └── curated/               # User-curated outputs (future)
└── logs/                      # Activity logs
```

## Example Workflows

### Daily Game Ideas
```bash
# 1. Create lexaplast for game concepts
./pheno-manager create-lexaplast daily-game-ideas --template game-concepts

# 2. Create lexasomes
./pheno-manager create-lexasome game-genres --type txt
./pheno-manager add-to-lexasome game-genres --text "roguelike"
./pheno-manager add-to-lexasome game-genres --text "puzzle"

./pheno-manager create-lexasome platforms --type txt
./pheno-manager add-to-lexasome platforms --text "mobile"
./pheno-manager add-to-lexasome platforms --text "web"

# 3. Mine 200 game ideas
./pheno-manager mine \
  --lexaplast daily-game-ideas \
  --lexasome game-genres platforms \
  --count 200 \
  --name "nightly-game-ideas"
```

### Creative Writing Prompts
```bash
# 1. Create writing prompt generator
./pheno-manager create-lexaplast writing-prompts --template creative

# 2. Build lexasomes
./pheno-manager create-lexasome genres --type txt
./pheno-manager add-to-lexasome genres --text "science fiction"
./pheno-manager add-to-lexasome genres --text "fantasy"

./pheno-manager create-lexasome characters --type txt
./pheno-manager add-to-lexasome characters --text "reluctant hero"
./pheno-manager add-to-lexasome characters --text "wise mentor"

# 3. Mine 50 prompts
./pheno-manager mine \
  --lexaplast writing-prompts \
  --lexasome genres characters \
  --count 50 \
  --temperature 0.9
```

## Commands Reference

### Initialization
- `./pheno-manager init` - Initialize the manager

### Lexaplast Management
- `./pheno-manager create-lexaplast <name> [--template <type>]` - Create lexaplast
- `./pheno-manager list-lexaplasts` - List all lexaplasts

### Lexasome Management
- `./pheno-manager create-lexasome <name> [--type txt|csv|json]` - Create lexasome
- `./pheno-manager add-to-lexasome <name> --text "entry"` - Add to lexasome
- `./pheno-manager list-lexasomes` - List all lexasomes

### Mining Operations
- `./pheno-manager mine --lexaplast <name> --lexasome <name> --count <n>` - Mine outputs
- `./pheno-manager status [--job <id>]` - Check mining status
- `./pheno-manager list-jobs [--days <n>]` - List mining jobs
- `./pheno-manager view-outputs --job <id>` - View outputs from job

## Prerequisites

1. **phenosemantic-py** installed at `/home/ubuntu/.openclaw/workspace/phenosemantic-py/`
2. Python 3.8+ with virtual environment activated
3. API keys configured in phenosemantic-py's `config.ini`

## Troubleshooting

### "phenosemantic-py not found"
```bash
# Check installation
cd /home/ubuntu/.openclaw/workspace/phenosemantic-py
source .venv/bin/activate
pheno --version
```

### "API key error"
```bash
# Check config.ini
cat /home/ubuntu/.openclaw/workspace/phenosemantic-py/config.ini
```

### "Mining stuck"
```bash
# Check status
./pheno-manager status

# Check logs
tail -f logs/pheno-manager.log
```

## Next Steps

1. **Today:** Test the basic functionality
2. **Tomorrow:** Add ranking system
3. **Tomorrow:** Add scheduling
4. **Day after:** Add web interface

## Development Status

**Phase 1: Foundation** ✅ Complete
- Basic CLI structure
- Lexaplast/lexasome management
- Mining wrapper
- Job tracking

**Phase 2: Mining Engine** ✅ Complete  
- Progress tracking
- Error handling
- Output management

**Phase 3: Advanced Features** 🔄 In Progress
- Auto-ranking system
- Scheduling
- Notifications

**Phase 4: Polish** ⏳ Planned
- Web interface
- Advanced analytics
- Integration with OpenClaw cron

---

**Created by:** Rexuvia  
**Last Updated:** 2026-03-02  
**Status:** Active Development