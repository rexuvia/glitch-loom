# Daily Issue Fixer - Cron Job Configuration

## Cron Job Command

```bash
openclaw cron add --cron "0 10 * * *" \
  --name "daily-issue-fixer" \
  --session isolated \
  --agent main \
  --message "Run the daily issue fixer" \
  --announce \
  --to "6839797771" \
  --channel telegram \
  --description "Daily issue fixer for rexuvia/* repositories" \
  --thinking low \
  --timeout-seconds 300
```

## Alternative Schedule Options

### Daily at 9:00 AM UTC
```bash
openclaw cron add --cron "0 9 * * *" --name "daily-issue-fixer-9am" ...
```

### Daily at 8:00 AM US Eastern (12:00 UTC)
```bash
openclaw cron add --cron "0 12 * * *" --tz "America/New_York" --name "daily-issue-fixer-8am-et" ...
```

### Weekdays only (Monday-Friday at 10:00 AM UTC)
```bash
openclaw cron add --cron "0 10 * * 1-5" --name "daily-issue-fixer-weekdays" ...
```

## Manual Execution Commands

### Run now (for testing)
```bash
openclaw cron run daily-issue-fixer
```

### Run with specific message
```bash
openclaw cron add --at "+1s" \
  --name "issue-fixer-test" \
  --session isolated \
  --agent main \
  --message "Run the daily issue fixer" \
  --announce \
  --to "6839797771" \
  --channel telegram \
  --delete-after-run
```

## Management Commands

### List all cron jobs
```bash
openclaw cron list
```

### Disable the issue fixer
```bash
openclaw cron disable daily-issue-fixer
```

### Enable the issue fixer
```bash
openclaw cron enable daily-issue-fixer
```

### Remove the issue fixer
```bash
openclaw cron rm daily-issue-fixer
```

### View run history
```bash
openclaw cron runs --name daily-issue-fixer --limit 10
```

## Complete Setup Script

Save this as `setup-issue-fixer-cron.sh`:

```bash
#!/bin/bash
# Setup Daily Issue Fixer Cron Job

set -euo pipefail

echo "=== Setting up Daily Issue Fixer Cron Job ==="

# Check if cron job already exists
if openclaw cron list 2>/dev/null | grep -q "daily-issue-fixer"; then
    echo "⚠️  Cron job 'daily-issue-fixer' already exists."
    echo "   Removing existing job..."
    openclaw cron rm daily-issue-fixer 2>/dev/null || true
fi

# Create new cron job
echo "Creating new cron job..."
openclaw cron add --cron "0 10 * * *" \
  --name "daily-issue-fixer" \
  --session isolated \
  --agent main \
  --message "Run the daily issue fixer" \
  --announce \
  --to "6839797771" \
  --channel telegram \
  --description "Daily issue fixer for rexuvia/* repositories" \
  --thinking low \
  --timeout-seconds 300

if [ $? -eq 0 ]; then
    echo "✅ Cron job created successfully!"
    
    echo ""
    echo "Cron job details:"
    openclaw cron list | grep daily-issue-fixer
    
    echo ""
    echo "To test immediately:"
    echo "  openclaw cron run daily-issue-fixer"
    
    echo ""
    echo "To monitor:"
    echo "  openclaw cron runs --name daily-issue-fixer --limit 5"
else
    echo "❌ Failed to create cron job."
    exit 1
fi
```

## Agent Session Configuration

The cron job uses `--session isolated` which means:
- Each execution runs in a fresh, isolated session
- No shared context with other sessions
- Clean environment for each issue fix
- Prevents contamination between different fixes

## Timeout Configuration

- `--timeout-seconds 300`: 5 minute timeout per execution
- If the issue fix takes longer, it will timeout
- For complex fixes, increase timeout: `--timeout-seconds 600` (10 minutes)

## Telegram Notification Configuration

- `--to "6839797771"`: Sky's Telegram ID
- `--channel telegram`: Use Telegram channel
- `--announce`: Send summary to Telegram when done
- Messages include issue details and fix status

## Error Handling in Cron

The cron job includes built-in error handling:
1. If no issues found: Sends "all clear" notification
2. If GitHub API fails: Logs error and retries next day
3. If Telegram fails: Logs error but continues
4. If agent fails: Logs error and notifies via Telegram

## Logging and Monitoring

Cron job outputs are logged:
1. OpenClaw cron logs: `openclaw cron runs --name daily-issue-fixer`
2. Script logs: `memory/daily-issue-fixer-YYYY-MM-DD.log`
3. Agent logs: In isolated session output

## Testing the Cron Job

### 1. Dry run (no actual actions)
```bash
# Create test cron job that doesn't send Telegram
openclaw cron add --at "+1s" \
  --name "issue-fixer-test-dry" \
  --session isolated \
  --agent main \
  --message "Test daily issue fixer (dry run)" \
  --no-deliver \
  --delete-after-run
```

### 2. Full test with Telegram
```bash
# Run the actual cron job now
openclaw cron run daily-issue-fixer
```

### 3. Check results
```bash
# View latest run
openclaw cron runs --name daily-issue-fixer --limit 1

# Check script logs
tail -f memory/daily-issue-fixer-$(date +%Y-%m-%d).log
```

## Troubleshooting

### Cron job not running
1. Check OpenClaw gateway status: `openclaw gateway status`
2. Check cron scheduler: `openclaw cron status`
3. Check logs: `journalctl -u openclaw-gateway`

### Telegram not receiving messages
1. Check Telegram channel configuration in OpenClaw
2. Verify Sky's Telegram ID is correct
3. Check if messages are being sent: `openclaw cron runs --name daily-issue-fixer`

### Issues not being found
1. Check GitHub authentication: `gh auth status`
2. Test GitHub API access: `gh repo view rexuvia/rexuvia-site`
3. Check if user "schbz" has any open issues

### Website not updating
1. Check `rebuild.sh` permissions and dependencies
2. Verify AWS credentials for S3/CloudFront
3. Check deployment logs in script output

## Maintenance Schedule

### Daily
- Check logs: `tail -f memory/daily-issue-fixer-*.log`
- Monitor cache: `cat memory/issue-fixer-cache.json | jq .`

### Weekly
- Review processed issues
- Clean up old log files (older than 30 days)
- Verify cron job is still active

### Monthly
- Update scripts if needed
- Review error patterns
- Optimize performance if necessary

## Security Considerations

1. **GitHub tokens**: Uses existing `gh` CLI authentication
2. **Telegram IDs**: Hardcoded for Sky only
3. **Isolated sessions**: Prevents cross-contamination
4. **Logging**: All actions are logged for audit
5. **No external dependencies**: Only uses existing OpenClaw infrastructure

## Backup Configuration

Save cron job configuration:
```bash
# Export cron job configuration
openclaw cron list --json > daily-issue-fixer-backup-$(date +%Y%m%d).json

# Restore from backup
cat backup.json | jq -r '.[] | select(.name == "daily-issue-fixer") | "openclaw cron add --cron \"\(.schedule)\" --name \"\(.name)\" --session isolated --agent main --message \"Run the daily issue fixer\" --announce --to \"6839797771\" --channel telegram --description \"\(.description)\""' | bash
```

---
*Configuration version: 1.0.0*
*Last updated: $(date)*
*Compatible with OpenClaw 2026.3.8+*