#!/bin/bash
# Setup script for Daily Issue Fixer

set -euo pipefail

WORKSPACE_DIR="/home/ubuntu/.openclaw/workspace"
SCRIPT_DIR="$WORKSPACE_DIR"

echo "=== Setting up Daily Issue Fixer ==="

# Check prerequisites
echo "1. Checking prerequisites..."

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed."
    echo "Please install it first:"
    echo "  Ubuntu/Debian: sudo apt install gh"
    echo "  macOS: brew install gh"
    echo "  Then run: gh auth login"
    exit 1
fi

# Check if gh is authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ GitHub CLI is not authenticated."
    echo "Please run: gh auth login"
    exit 1
fi

echo "✅ GitHub CLI is installed and authenticated."

# Check if openclaw is available
if ! command -v openclaw &> /dev/null; then
    echo "❌ OpenClaw CLI is not available."
    echo "Please ensure OpenClaw is properly installed."
    exit 1
fi

echo "✅ OpenClaw CLI is available."

# Make scripts executable
echo "2. Making scripts executable..."
chmod +x "$SCRIPT_DIR/daily-issue-fixer.sh" 2>/dev/null || true
chmod +x "$SCRIPT_DIR/issue-fixer-response-handler.sh" 2>/dev/null || true
chmod +x "$SCRIPT_DIR/daily-issue-fixer-complete.sh" 2>/dev/null || true
chmod +x "$SCRIPT_DIR/setup-daily-issue-fixer.sh" 2>/dev/null || true
echo "✅ Scripts are now executable."

# Create necessary directories
echo "3. Creating directories..."
mkdir -p "$WORKSPACE_DIR/memory"
echo "✅ Created memory directory."

# Test GitHub access to rexuvia repos
echo "4. Testing GitHub access to rexuvia repositories..."
if gh repo view rexuvia/rexuvia-site --json name 2>/dev/null; then
    echo "✅ Can access rexuvia repositories."
else
    echo "⚠️  Warning: Cannot access rexuvia/rexuvia-site"
    echo "This might be expected if the repo is private or you don't have access."
    echo "The script will use fallback methods."
fi

# Create cache file if it doesn't exist
echo "5. Initializing cache file..."
CACHE_FILE="$WORKSPACE_DIR/memory/issue-fixer-cache.json"
if [ ! -f "$CACHE_FILE" ]; then
    cat > "$CACHE_FILE" << EOF
{
    "processed_issues": [],
    "setup_date": "$(date -Iseconds)",
    "version": "1.0.0"
}
EOF
    echo "✅ Created cache file: $CACHE_FILE"
else
    echo "✅ Cache file already exists: $CACHE_FILE"
fi

# Test the scripts
echo "6. Testing scripts..."
echo "   Testing daily-issue-fixer.sh..."
if bash -n "$SCRIPT_DIR/daily-issue-fixer.sh"; then
    echo "   ✅ Syntax check passed."
else
    echo "   ❌ Syntax check failed. Please fix the script."
    exit 1
fi

echo "   Testing issue-fixer-response-handler.sh..."
if bash -n "$SCRIPT_DIR/issue-fixer-response-handler.sh"; then
    echo "   ✅ Syntax check passed."
else
    echo "   ❌ Syntax check failed. Please fix the script."
    exit 1
fi

# Create cron job
echo "7. Creating cron job..."
echo "   The cron job will run daily at 10:00 AM UTC."
echo "   This will find issues and send Telegram messages to Sky (ID: 6839797771)."
echo ""
echo "   To create the cron job, run:"
echo "   openclaw cron add --cron \"0 10 * * *\" \\"
echo "     --name \"daily-issue-fixer\" \\"
echo "     --session isolated \\"
echo "     --agent main \\"
echo "     --message \"Run the daily issue fixer\" \\"
echo "     --announce \\"
echo "     --to \"6839797771\" \\"
echo "     --channel telegram \\"
echo "     --description \"Daily issue fixer for rexuvia/* repositories\""
echo ""
echo "   Would you like to create the cron job now? (y/n)"
read -r response

if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "   Creating cron job..."
    openclaw cron add --cron "0 10 * * *" \
      --name "daily-issue-fixer" \
      --session isolated \
      --agent main \
      --message "Run the daily issue fixer" \
      --announce \
      --to "6839797771" \
      --channel telegram \
      --description "Daily issue fixer for rexuvia/* repositories"
    
    if [ $? -eq 0 ]; then
        echo "   ✅ Cron job created successfully."
    else
        echo "   ❌ Failed to create cron job. Please check OpenClaw configuration."
    fi
else
    echo "   Skipping cron job creation. You can create it manually later."
fi

# Final instructions
echo ""
echo "=== Setup Complete ==="
echo ""
echo "📋 Next steps:"
echo "1. Review the configuration in the script files"
echo "2. Test the system manually: ./daily-issue-fixer-complete.sh"
echo "3. Check Telegram to see if messages are sent correctly"
echo "4. When Sky responds to a Telegram question, process it manually:"
echo "   ./issue-fixer-response-handler.sh <repo> <issue_number> <choice>"
echo ""
echo "📚 Documentation:"
echo " - Read DAILY_ISSUE_FIXER_README.md for detailed instructions"
echo " - Check memory/daily-issue-fixer-*.log for execution logs"
echo " - Monitor cache file: cat memory/issue-fixer-cache.json | jq ."
echo ""
echo "🛠️  Maintenance:"
echo " - List cron jobs: openclaw cron list"
echo " - Disable cron job: openclaw cron disable daily-issue-fixer"
echo " - Enable cron job: openclaw cron enable daily-issue-fixer"
echo " - Remove cron job: openclaw cron rm daily-issue-fixer"
echo ""
echo "✅ Daily Issue Fixer setup is complete!"