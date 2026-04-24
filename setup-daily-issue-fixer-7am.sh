#!/bin/bash
# Setup Daily Issue Fixer Cron Job - UPDATED for 7 AM daily with model selection

set -euo pipefail

echo "=== Setting up Daily Issue Fixer Cron Job (7 AM) ==="

# Check if scripts exist
if [ ! -f "daily-issue-fixer-updated.sh" ]; then
    echo "❌ Error: daily-issue-fixer-updated.sh not found"
    exit 1
fi

if [ ! -f "issue-fixer-response-handler-updated.sh" ]; then
    echo "❌ Error: issue-fixer-response-handler-updated.sh not found"
    exit 1
fi

# Make scripts executable
chmod +x daily-issue-fixer-updated.sh
chmod +x issue-fixer-response-handler-updated.sh

echo "✅ Scripts made executable"

# Check if cron job already exists
if openclaw cron list 2>/dev/null | grep -q "daily-issue-fixer-7am"; then
    echo "⚠️  Cron job 'daily-issue-fixer-7am' already exists."
    echo "   Removing existing job..."
    openclaw cron rm daily-issue-fixer-7am 2>/dev/null || true
fi

# Create new cron job for 7 AM daily (7 AM Eastern = 11:00 UTC)
echo "Creating new cron job for 7 AM daily (11:00 UTC)..."
openclaw cron add --cron "0 11 * * *" \
  --name "daily-issue-fixer-7am" \
  --session isolated \
  --agent main \
  --message "Run the daily issue fixer (7 AM version)" \
  --announce \
  --to "6839797771" \
  --channel telegram \
  --description "Daily issue fixer for rexuvia/* repositories - runs at 7 AM Eastern" \
  --thinking low \
  --timeout-seconds 300

if [ $? -eq 0 ]; then
    echo "✅ Cron job created successfully!"
    
    echo ""
    echo "Cron job details:"
    openclaw cron list | grep daily-issue-fixer-7am
    
    echo ""
    echo "=== IMPORTANT: Response Handler Setup ==="
    echo ""
    echo "To handle Sky's responses, you need to:"
    echo "1. Monitor Telegram for responses like '1 4' (action + model)"
    echo "2. When Sky responds, run:"
    echo "   ./issue-fixer-response-handler-updated.sh <repo> <issue_number> '<choice>'"
    echo ""
    echo "Example:"
    echo "  ./issue-fixer-response-handler-updated.sh glitch-loom 2 '1 4'"
    echo "  (Fixes glitch-loom issue #2 with GPT-5 Codex)"
    echo ""
    echo "=== Available Models ==="
    echo "1. 🧠 Opus 4.6 (best for complex tasks)"
    echo "2. ⚡ Sonnet 4.6 (balanced, reliable)"
    echo "3. 🔥 Gemini 3.1 Pro (creative solutions)"
    echo "4. 💻 GPT-5 Codex (excellent for code)"
    echo "5. 📊 Kimi K2.5 (good for analysis)"
    echo "6. 🎨 Grok 4 (creative, unconventional)"
    echo "7. 🛠️ DeepSeek V3.2 (technical tasks)"
    echo ""
    echo "=== Available Actions ==="
    echo "1. ✅ Fix it now"
    echo "2. 📝 Plan first"
    echo "3. 🔍 Investigate more"
    echo "4. ⏸️ Skip this one"
    echo "5. 🛑 Stop fixing"
    echo ""
    echo "Response format: 'action model' (e.g., '1 4' = Fix it now with GPT-5 Codex)"
    echo ""
    echo "To test immediately:"
    echo "  openclaw cron run daily-issue-fixer-7am"
    echo ""
    echo "To monitor:"
    echo "  openclaw cron runs --name daily-issue-fixer-7am --limit 5"
    echo ""
    echo "Logs will be in: memory/daily-issue-fixer-*.log"
else
    echo "❌ Failed to create cron job."
    exit 1
fi