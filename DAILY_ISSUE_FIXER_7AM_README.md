# Daily Issue Fixer - 7 AM Version with Model Selection

## Overview
This system automatically finds and fixes the oldest unaddressed GitHub issues from user "schbz" in rexuvia/* repositories. It runs daily at 7 AM Eastern (11:00 UTC) and includes model selection for coding tasks.

## Key Features
- ✅ **Runs daily at 7 AM Eastern** (11:00 UTC)
- ✅ **Model selection** - Sky chooses which AI model to use for each fix
- ✅ **One issue per day** - Starts with oldest unaddressed issue
- ✅ **Multiple choice interface** via Telegram
- ✅ **Proper website updates** - Explicitly calls `rebuild.sh` when needed
- ✅ **Isolated agent sessions** - Each fix runs independently
- ✅ **Robust error handling** - Prevents deployment failures

## Files Created
1. `daily-issue-fixer-updated.sh` - Main script with model selection
2. `issue-fixer-response-handler-updated.sh` - Processes two-number responses
3. `setup-daily-issue-fixer-7am.sh` - Setup script
4. This README file

## Setup Instructions

### 1. Run Setup Script
```bash
chmod +x setup-daily-issue-fixer-7am.sh
./setup-daily-issue-fixer-7am.sh
```

### 2. Verify Cron Job
```bash
openclaw cron list | grep daily-issue-fixer-7am
```

### 3. Test the System
```bash
# Run a test execution
openclaw cron run daily-issue-fixer-7am
```

## How It Works

### Daily Execution (7 AM Eastern)
1. **Finds oldest `schbz` issue** across all rexuvia/* repos
2. **Analyzes issue** and creates plan
3. **Sends Telegram message** to Sky with:
   - Issue details and analysis
   - 5 action choices (1-5)
   - 7 model choices (1-7)
4. **Waits for response** - Sky replies with two numbers (e.g., "1 4")

### Response Format
Sky replies with: `action model`
- **Action** (1-5): How to proceed
- **Model** (1-7): Which AI model to use

### Example Responses
- `1 4` = Fix it now with GPT-5 Codex
- `2 1` = Plan first with Opus 4.6
- `3 5` = Investigate more with Kimi K2.5
- `4` = Skip this one (default model used)
- `5` = Stop fixing (pauses daily fixer)

## Available Models

| # | Model | Alias | Best For |
|---|-------|-------|----------|
| 1 | Claude Opus 4.6 | `opus46` | Complex tasks, deep analysis |
| 2 | Claude Sonnet 4.6 | `sonnet46` | Balanced, reliable work |
| 3 | Gemini 3.1 Pro | `gemini31or` | Creative solutions |
| 4 | GPT-5 Codex | `gpt5codex` | Code generation, programming |
| 5 | Kimi K2.5 | `kimi` | Analysis, research |
| 6 | Grok 4 | `grok` | Creative, unconventional ideas |
| 7 | DeepSeek V3.2 | `deepseek` | Technical tasks, coding |

## Available Actions

| # | Action | Description |
|---|--------|-------------|
| 1 | ✅ Fix it now | Immediate implementation |
| 2 | 📝 Plan first | Create detailed plan first |
| 3 | 🔍 Investigate more | Research before deciding |
| 4 | ⏸️ Skip this one | Skip and check again tomorrow |
| 5 | 🛑 Stop fixing | Pause the daily fixer |

## Processing Responses

When Sky responds on Telegram, you need to run:
```bash
./issue-fixer-response-handler-updated.sh <repo> <issue_number> '<choice>'
```

### Example
If Sky responds "1 4" to fix glitch-loom issue #2:
```bash
./issue-fixer-response-handler-updated.sh glitch-loom 2 '1 4'
```

## Website Update Handling

When an issue affects the rexuvia.com website:
1. Agent updates website files in `rexuvia-site/`
2. Agent runs `rebuild.sh` to build and deploy
3. CloudFront cache is invalidated
4. Changes go live immediately

## Logging and Monitoring

### Log Files
- `memory/daily-issue-fixer-YYYY-MM-DD.log` - Main execution logs
- `memory/issue-fixer-response-YYYY-MM-DD.log` - Response handling logs
- `memory/issue-fixer-responses/` - Response records (JSON)

### Monitoring Commands
```bash
# Check cron job status
openclaw cron list

# View recent runs
openclaw cron runs --name daily-issue-fixer-7am --limit 5

# Check logs
tail -f memory/daily-issue-fixer-$(date +%Y-%m-%d).log
```

## Troubleshooting

### No Issues Found
- Check if user "schbz" has any open issues: `gh issue list --author schbz --state open`
- Verify GitHub authentication: `gh auth status`

### Telegram Not Working
- Check OpenClaw Telegram configuration
- Verify Sky's Telegram ID (6839797771)

### Website Not Updating
- Check `rebuild.sh` permissions and dependencies
- Verify AWS credentials for S3/CloudFront
- Check deployment logs in script output

### Model Not Available
- Verify model alias exists in OpenClaw configuration
- Check `openclaw config.get` for available models

## Maintenance

### Daily
- Check logs: `tail -f memory/daily-issue-fixer-*.log`
- Monitor cache: `cat memory/issue-fixer-cache.json | jq .`

### Weekly
- Review processed issues
- Clean up old log files (older than 30 days)

### Monthly
- Update scripts if needed
- Review error patterns

## Security
- Uses existing `gh` CLI authentication
- Hardcoded Telegram ID for Sky only
- Isolated sessions prevent cross-contamination
- All actions logged for audit

## Backup
```bash
# Export cron job configuration
openclaw cron list --json > daily-issue-fixer-7am-backup-$(date +%Y%m%d).json
```

---
*Version: 2.0.0 (with model selection)*  
*Schedule: Daily at 7 AM Eastern (11:00 UTC)*  
*Last updated: $(date)*