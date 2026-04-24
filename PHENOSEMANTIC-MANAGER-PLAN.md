# Phenosemantic Manager Skill - Implementation Plan

## Problem Statement
Sky is frustrated with getting phenosemantic-py scripts working. Instead of fixing the underlying Python issues, we'll create a wrapper skill that makes phenosemantic-py easy to use through OpenClaw.

## Core Philosophy
**"Don't fix the engine, build a better dashboard."** - We'll wrap phenosemantic-py with user-friendly OpenClaw interfaces.

## Skill Architecture

### 1. Directory Structure
```
phenosemantic-manager/
├── SKILL.md                      # Main skill documentation
├── README.md                     # Quick start guide
├── pheno-manager                 # Main CLI script (Python)
├── config/
│   ├── lexaplasts/               # User lexaplasts (managed here)
│   │   ├── game-concepts.json
│   │   ├── creative-prompts.json
│   │   └── technical-questions.json
│   ├── lexasomes/                # User lexasomes (managed here)
│   │   ├── game-mechanics.txt
│   │   ├── creative-domains.txt
│   │   └── technical-topics.csv
│   └── templates/                # Template files
│       ├── lexaplast-template.json
│       └── lexasome-template.txt
├── scripts/
│   ├── mine.py                   # Mining engine wrapper
│   ├── rank.py                   # Auto-ranking system
│   ├── create.py                 # Create lexaplasts/lexasomes
│   ├── list.py                   # List available resources
│   └── schedule.py               # Scheduler
├── db/
│   └── pheno-manager.db          # SQLite for job tracking
├── outputs/                      # Generated outputs
│   ├── raw/                      # Raw JSONL outputs
│   ├── ranked/                   # Ranked outputs
│   └── curated/                  # User-curated outputs
└── logs/                         # Activity logs
```

### 2. Core Features

#### A. Lexaplast Management
- **Create:** `pheno-manager create-lexaplast <name> --template <type>`
- **Edit:** `pheno-manager edit-lexaplast <name>`
- **List:** `pheno-manager list-lexaplasts`
- **Test:** `pheno-manager test-lexaplast <name> --sample`

#### B. Lexasome Management  
- **Create:** `pheno-manager create-lexasome <name> --type <txt|csv|json>`
- **Import:** `pheno-manager import-lexasome <name> --file <path>`
- **Add:** `pheno-manager add-to-lexasome <name> --text "new entry"`
- **List:** `pheno-manager list-lexasomes`

#### C. Mining Engine
- **Simple:** `pheno-manager mine --lexaplast <name> --lexasome <name> --count 100`
- **Advanced:** `pheno-manager mine --lexaplast X --lexasome Y Z --count 500 --temperature 0.8 --delay 2000`
- **Progress:** Real-time progress tracking
- **Output:** Saves to `outputs/raw/YYYY-MM-DD-<job-id>.jsonl`

#### D. Auto-Ranking System
- **Quality Metrics:**
  1. Length (optimal range: 50-500 chars)
  2. Complexity (sentence count, vocabulary diversity)
  3. Uniqueness (compared to existing outputs)
  4. Structure (has paragraphs, lists, etc.)
- **LLM Ranking:** Optional GPT-4/Claude scoring
- **Morning Report:** Top 10 outputs for review

#### E. Scheduler
- **Schedule:** `pheno-manager schedule --time "03:00" --lexaplast X --lexasome Y --count 300`
- **Cron Integration:** Creates OpenClaw cron jobs
- **Notifications:** Telegram/email when complete
- **History:** Track all scheduled jobs

### 3. Implementation Strategy

#### Phase 1: Foundation (Today)
1. Create directory structure
2. Write main `pheno-manager` CLI script
3. Implement lexaplast/lexasome management
4. Test with existing phenosemantic-py

#### Phase 2: Mining Wrapper (Today)
1. Build Python wrapper around phenosemantic-py
2. Add progress tracking and error handling
3. Implement output storage
4. Create basic ranking system

#### Phase 3: Advanced Features (Tomorrow)
1. Implement LLM-based ranking
2. Build scheduler with OpenClaw cron integration
3. Add morning report generation
4. Create web interface (optional)

#### Phase 4: Polish & Documentation (Tomorrow)
1. Add comprehensive error handling
2. Write detailed documentation
3. Create example workflows
4. Test end-to-end

### 4. Technical Decisions

#### 4.1 Wrapper Approach
Instead of modifying phenosemantic-py, we'll:
- Use subprocess to call `pheno` command
- Parse stdout/stderr for progress
- Handle errors gracefully
- Provide better user feedback

#### 4.2 Storage Strategy
- **Lexaplasts/Lexasomes:** Store in skill's `config/` directory
- **Outputs:** JSONL files in `outputs/raw/`
- **Metadata:** SQLite database for job tracking
- **Backup:** Git commit important configurations

#### 4.3 Error Handling
- Catch and explain phenosemantic-py errors
- Provide troubleshooting steps
- Log detailed errors for debugging
- Graceful degradation when phenosemantic-py fails

#### 4.4 User Experience
- Natural language commands via OpenClaw
- Progress bars for long operations
- Clear success/error messages
- Examples and help text

### 5. Sample Workflows

#### Workflow 1: Create and Test a Lexaplast
```bash
# Create a game concept generator
pheno-manager create-lexaplast game-concepts --template creative

# Add some game mechanics
pheno-manager create-lexasome mechanics --type txt
pheno-manager add-to-lexasome mechanics --text "procedural generation"
pheno-manager add-to-lexasome mechanics --text "physics simulation"

# Test it
pheno-manager test-lexaplast game-concepts --lexasome mechanics --count 5
```

#### Workflow 2: Overnight Mining
```bash
# Schedule overnight mining
pheno-manager schedule \
  --name "game-ideas-overnight" \
  --time "02:00" \
  --lexaplast game-concepts \
  --lexasome mechanics creative-domains \
  --count 500 \
  --notify telegram

# Check results in morning
pheno-manager review --date today --top 20
```

#### Workflow 3: Creative Prompt Generation
```bash
# Mine creative writing prompts
pheno-manager mine \
  --lexaplast creative-prompts \
  --lexasome genres characters settings \
  --count 100 \
  --temperature 0.9

# Rank the results
pheno-manager rank --file outputs/raw/2026-03-02-*.jsonl --top 10
```

### 6. Integration with OpenClaw

#### 6.1 Skill Commands
```bash
# Natural language via OpenClaw
"Create a lexaplast for generating coding challenges"
"Schedule overnight mining for game ideas"
"Show me the best outputs from last night"
```

#### 6.2 Cron Integration
- Use OpenClaw's cron system
- Schedule mining jobs
- Send notifications via Telegram
- Store results in workspace

#### 6.3 Memory Integration
- Log mining jobs to memory files
- Track successful/failed runs
- Learn from user ratings

### 7. Success Metrics

1. **Usability:** Sky can create and use lexaplasts/lexasomes without Python frustration
2. **Reliability:** Mining jobs run successfully overnight
3. **Quality:** Auto-ranking surfaces good outputs for morning review
4. **Speed:** Common operations take < 30 seconds
5. **Documentation:** Clear examples for common use cases

### 8. Risks & Mitigations

#### Risk 1: phenosemantic-py breaks
- **Mitigation:** Graceful error messages, fallback to simple generation
- **Backup:** Store working versions of phenosemantic-py

#### Risk 2: API rate limits
- **Mitigation:** Built-in delays, provider rotation
- **Monitoring:** Track API usage and errors

#### Risk 3: Storage bloat
- **Mitigation:** Automatic cleanup of old outputs
- **Compression:** Compress old JSONL files

#### Risk 4: User confusion
- **Mitigation:** Clear documentation, examples, error messages
- **Onboarding:** Step-by-step tutorials

### 9. Next Steps

1. **Immediate:** Create directory structure and basic CLI
2. **Today:** Implement lexaplast/lexasome management
3. **Today:** Build mining wrapper
4. **Tomorrow:** Add ranking and scheduling
5. **Tomorrow:** Test end-to-end workflow

### 10. Open Questions

1. Should we include a web interface for browsing outputs?
2. How sophisticated should auto-ranking be?
3. Should we support multiple phenosemantic-py versions?
4. How to handle user authentication for API keys?

---

**Goal:** By tomorrow morning, Sky should be able to:
1. Create a lexaplast and lexasome
2. Run a mining job
3. See ranked results
4. Schedule overnight mining