# Daily Issue Fixer for Rexuvia Repositories

## Overview

This is an automated system that:
1. **Finds** the oldest unaddressed issue created by user "schbz" across all `rexuvia/*` GitHub repositories
2. **Analyzes** the issue and creates a plan for how to fix it
3. **Sends** a Telegram message to Sky (ID: 6839797771) with a multiple choice question on how to proceed
4. **Waits** for Sky's response, then executes the chosen plan
5. **Updates** the repository with the fix, commits, and pushes
6. **Ensures** the website gets correctly updated if the fix affects the website

## Important Constraints

- Only fixes **ONE** issue per cron job execution (starting with the oldest)
- Ensures website updates are handled properly (unlike previous errors)
- Runs **daily** via cron job
- Uses **isolated agent sessions** for each execution
- Includes proper **error handling** and **logging**

## Files

1. **`daily-issue-fixer-complete.sh`** - Main entry point for cron job
2. **`daily-issue-fixer.sh`** - Finds and analyzes issues, sends Telegram question
3. **`issue-fixer-response-handler.sh`** - Processes Sky's response and spawns appropriate agent
4. **`setup-daily-issue-fixer.sh`** - Setup script (to be created)
5. **`DAILY_ISSUE_FIXER_README.md`** - This documentation

## How It Works

### 1. Daily Execution (Cron Job)
- Runs daily at a specified time
- Checks for pending responses from previous days
- If no pending responses, finds the oldest unaddressed `schbz` issue
- Analyzes the issue type (bug, feature, documentation)
- Sends Telegram message with multiple choice options

### 2. Multiple Choice Options
Sky can respond with:
1. **✅ Fix it now** - Spawns an agent to implement the fix immediately
2. **📝 Plan first** - Spawns an agent to create a detailed implementation plan
3. **🔍 Investigate more** - Spawns an agent to research before deciding
4. **⏸️ Skip this one** - Skips this issue, checks again tomorrow
5. **🛑 Stop fixing** - Pauses the daily fixer (disables cron job)

### 3. Agent Execution
- When Sky chooses option 1, 2, or 3, an **isolated agent session** is spawned
- The agent receives specific instructions based on the choice
- For fixes (option 1), the agent:
  - Reads the issue details
  - Implements the fix
  - Tests the fix
  - Commits and pushes changes
  - Ensures website updates if needed
  - Updates the issue with a comment

### 4. Website Update Handling
- If the fix affects `rexuvia-site` repository:
  - Agent runs `rebuild.sh` to rebuild the site
  - Changes are deployed to S3 + CloudFront
  - Cache is invalidated
- This prevents the "website wasn't updated" error from happening again

### 5. State Management
- **Cache file**: `memory/issue-fixer-cache.json` - Tracks processed issues
- **Waiting files**: `memory/issue-fixer-waiting-*.json` - Tissues waiting for response
- **Log files**: `memory/daily-issue-fixer-*.log` - Daily execution logs

## Setup Instructions

### Prerequisites
1. GitHub CLI (`gh`) installed and authenticated
2. OpenClaw CLI available
3. Telegram channel configured in OpenClaw
4. Access to `rexuvia/*` repositories

### Installation
```bash
# Make scripts executable
chmod +x daily-issue-fixer*.sh issue-fixer-response-handler.sh

# Create necessary directories
mkdir -p memory

# Test the issue finder
./daily-issue-fixer-complete.sh
```

### Cron Job Setup
```bash
# Add daily cron job (runs at 10:00 AM UTC)
openclaw cron add --cron "0 10 * * *" \
  --name "daily-issue-fixer" \
  --session isolated \
  --agent main \
  --message "Run the daily issue fixer" \
  --announce \
  --to "6839797771" \
  --channel telegram \
  --description "Daily issue fixer for rexuvia/* repositories"
```

### Manual Response Processing
When Sky responds to a Telegram question, the response needs to be processed manually (for now). Example:

```bash
# Process response: Fix it now
./issue-fixer-response-handler.sh rexuvia-site 42 1

# Process response: Skip this one  
./issue-fixer-response-handler.sh rexuvia-site 42 4
```

**Future improvement**: Automate response handling via Telegram bot integration.

## Error Handling

1. **Missing prerequisites**: Script checks for `gh` CLI and authentication
2. **Network failures**: Graceful degradation with fallbacks
3. **No issues found**: Sends "all clear" notification
4. **Stale waiting files**: Automatically cleaned up after 2 days
5. **Website update failures**: Logged and reported

## Logging

All activities are logged to:
- `memory/daily-issue-fixer-YYYY-MM-DD.log` - Daily execution log
- `memory/issue-fixer-response-YYYY-MM-DD.log` - Response handling log
- Console output (captured by OpenClaw cron system)

## Testing

Test the system manually:
```bash
# Test issue finding
./daily-issue-fixer.sh

# Test response handling (simulate Sky choosing "Fix it now")
./issue-fixer-response-handler.sh rexuvia-site 1 1 "Test response"

# Test complete workflow
./daily-issue-fixer-complete.sh
```

## Maintenance

### Monitoring
- Check log files regularly: `tail -f memory/daily-issue-fixer-*.log`
- Monitor cache file: `cat memory/issue-fixer-cache.json | jq .`
- Check cron job status: `openclaw cron list`

### Troubleshooting
1. **No issues found**: Check if `gh` can access rexuvia repos
2. **Telegram not sending**: Check OpenClaw Telegram configuration
3. **Website not updating**: Check AWS credentials and `rebuild.sh` permissions
4. **Agent not spawning**: Check OpenClaw cron job limits and agent configuration

### Updates
To update the system:
1. Edit the script files as needed
2. Test manually
3. Restart cron job if necessary: `openclaw cron disable daily-issue-fixer && openclaw cron enable daily-issue-fixer`

## Design Considerations

### Robustness
- Only processes one issue per day to avoid overload
- Maintains state to prevent reprocessing the same issue
- Handles failures gracefully with notifications
- Includes comprehensive logging

### Security
- Uses existing `gh` CLI authentication
- No new credentials needed
- Isolated agent sessions prevent contamination
- All actions are logged and traceable

### Scalability
- Can be extended to other GitHub organizations
- Response handling can be automated in the future
- Multiple issue types supported (bug, feature, documentation)
- Configurable via environment variables

## Future Improvements

1. **Automated response handling**: Integrate with Telegram bot to auto-process responses
2. **More issue sources**: Support issues from other users or organizations
3. **Priority scoring**: Implement smart priority algorithm instead of just oldest
4. **Batch processing**: Option to process multiple simple issues in one run
5. **Dashboard**: Web interface to monitor and control the system
6. **Slack integration**: Add Slack as an alternative notification channel
7. **Email notifications**: Send email summaries of daily activities

## Support

For issues or questions:
1. Check the logs first
2. Review this documentation
3. Test components manually
4. Contact system administrator if needed

---
*Last updated: $(date)*
*System version: 1.0.0*