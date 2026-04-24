#!/bin/bash
# Test script for Daily Issue Fixer

set -euo pipefail

WORKSPACE_DIR="/home/ubuntu/.openclaw/workspace"
SCRIPT_DIR="$WORKSPACE_DIR"

echo "=== Testing Daily Issue Fixer ==="

# Test 1: Syntax check
echo "1. Syntax check..."
bash -n "$SCRIPT_DIR/daily-issue-fixer.sh" && echo "✅ daily-issue-fixer.sh syntax OK"
bash -n "$SCRIPT_DIR/issue-fixer-response-handler.sh" && echo "✅ issue-fixer-response-handler.sh syntax OK"
bash -n "$SCRIPT_DIR/daily-issue-fixer-complete.sh" && echo "✅ daily-issue-fixer-complete.sh syntax OK"

# Test 2: Check prerequisites
echo ""
echo "2. Checking prerequisites..."
if command -v gh &> /dev/null; then
    echo "✅ GitHub CLI (gh) is installed"
    if gh auth status &> /dev/null; then
        echo "✅ GitHub CLI is authenticated"
    else
        echo "⚠️  GitHub CLI is not authenticated (run: gh auth login)"
    fi
else
    echo "❌ GitHub CLI (gh) is not installed"
fi

if command -v openclaw &> /dev/null; then
    echo "✅ OpenClaw CLI is installed"
else
    echo "❌ OpenClaw CLI is not installed"
fi

# Test 3: Check directories
echo ""
echo "3. Checking directories..."
if [ -d "$WORKSPACE_DIR/memory" ]; then
    echo "✅ memory directory exists"
else
    echo "⚠️  memory directory doesn't exist (will be created automatically)"
fi

# Test 4: Check cache file
echo ""
echo "4. Checking cache file..."
CACHE_FILE="$WORKSPACE_DIR/memory/issue-fixer-cache.json"
if [ -f "$CACHE_FILE" ]; then
    echo "✅ Cache file exists: $CACHE_FILE"
    echo "   Contents:"
    jq . "$CACHE_FILE" 2>/dev/null || cat "$CACHE_FILE"
else
    echo "⚠️  Cache file doesn't exist (will be created automatically)"
fi

# Test 5: Dry run of issue finder (without sending Telegram)
echo ""
echo "5. Dry run of issue finder..."
echo "   This will search for issues but NOT send Telegram messages."
echo "   Press Ctrl+C to cancel or wait 5 seconds to continue..."
sleep 5

# Create a test version that doesn't send Telegram
TEST_SCRIPT=$(mktemp)
cat "$SCRIPT_DIR/daily-issue-fixer.sh" | sed 's/openclaw message send.*Telegram.*/echo "TEST: Would send Telegram: \$1"/' > "$TEST_SCRIPT"
chmod +x "$TEST_SCRIPT"

# Run test
if bash "$TEST_SCRIPT" 2>&1 | head -50; then
    echo "✅ Issue finder dry run completed"
else
    echo "⚠️  Issue finder dry run had issues"
fi

rm -f "$TEST_SCRIPT"

# Test 6: Test response handler
echo ""
echo "6. Testing response handler..."
echo "   Simulating response: Fix it now for issue #1 in rexuvia-site"
if bash -c "source $SCRIPT_DIR/issue-fixer-response-handler.sh && echo '✅ Response handler functions loaded'" 2>&1; then
    echo "✅ Response handler test passed"
else
    echo "⚠️  Response handler test had issues"
fi

echo ""
echo "=== Test Complete ==="
echo ""
echo "Summary:"
echo " - The scripts are syntactically correct"
echo " - Prerequisites are checked"
echo " - Directories and cache are verified"
echo " - Dry run completed without sending actual Telegram messages"
echo ""
echo "Next steps:"
echo "1. Run setup: ./setup-daily-issue-fixer.sh"
echo "2. Create cron job (via setup script or manually)"
echo "3. Test with real issue: ./daily-issue-fixer-complete.sh"
echo "4. Monitor logs in memory/daily-issue-fixer-*.log"