#!/bin/bash
# Simple issue reporter - just find and report the oldest issue

set -euo pipefail

TELEGRAM_CHAT_ID="6839797771"
WORKSPACE_DIR="/home/ubuntu/.openclaw/workspace"

echo "=== Simple Issue Reporter ==="

# Check cache
CACHE_FILE="$WORKSPACE_DIR/memory/issue-fixer-cache.json"
if [ -f "$CACHE_FILE" ]; then
    echo "Cache contents:"
    cat "$CACHE_FILE"
    echo ""
    
    # Get processed issues
    if jq -e '.processed_issues' "$CACHE_FILE" >/dev/null 2>&1; then
        PROCESSED_ISSUES=$(jq -r '.processed_issues[]' "$CACHE_FILE")
        echo "Processed issues:"
        echo "$PROCESSED_ISSUES"
    fi
else
    echo "No cache file found"
    PROCESSED_ISSUES=""
fi

# Find oldest issue
echo ""
echo "=== Searching for issues ==="

OLDEST_REPO=""
OLDEST_NUMBER=""
OLDEST_TITLE=""
OLDEST_DATE="9999-99-99"

# Check known rexuvia repositories
REPOS="rexuvia-site glitch-loom word-bird memory-palace-builder flock-mind"

for REPO in $REPOS; do
    echo "Checking rexuvia/$REPO..."
    
    # Get issues by schbz
    ISSUES_JSON=$(gh issue list --repo "rexuvia/$REPO" --author "schbz" --state open --json number,title,createdAt 2>/dev/null || echo "[]")
    
    # Check if we got valid JSON
    if ! echo "$ISSUES_JSON" | jq -e . >/dev/null 2>&1; then
        echo "  Invalid JSON response, skipping"
        continue
    fi
    
    ISSUE_COUNT=$(echo "$ISSUES_JSON" | jq length)
    
    if [ "$ISSUE_COUNT" -gt 0 ]; then
        echo "  Found $ISSUE_COUNT issue(s)"
        
        for ((i=0; i<ISSUE_COUNT; i++)); do
            ISSUE_NUM=$(echo "$ISSUES_JSON" | jq -r ".[$i].number")
            ISSUE_TITLE=$(echo "$ISSUES_JSON" | jq -r ".[$i].title")
            CREATED_AT=$(echo "$ISSUES_JSON" | jq -r ".[$i].createdAt")
            
            ISSUE_KEY="${REPO}#${ISSUE_NUM}"
            
            # Check if already processed
            SKIP=0
            for PROCESSED in $PROCESSED_ISSUES; do
                if [ "$PROCESSED" = "$ISSUE_KEY" ]; then
                    echo "  Skipping processed issue: $ISSUE_KEY"
                    SKIP=1
                    break
                fi
            done
            
            if [ $SKIP -eq 1 ]; then
                continue
            fi
            
            SORT_DATE="${CREATED_AT:0:10}"
            
            if [[ "$SORT_DATE" < "$OLDEST_DATE" ]]; then
                OLDEST_DATE="$SORT_DATE"
                OLDEST_REPO="$REPO"
                OLDEST_NUMBER="$ISSUE_NUM"
                OLDEST_TITLE="$ISSUE_TITLE"
                echo "  New oldest: $ISSUE_KEY ($SORT_DATE) - $ISSUE_TITLE"
            fi
        done
    else
        echo "  No issues found"
    fi
done

if [ -n "$OLDEST_REPO" ]; then
    echo ""
    echo "=== OLDEST ISSUE FOUND ==="
    echo "Repository: rexuvia/$OLDEST_REPO"
    echo "Issue #: $OLDEST_NUMBER"
    echo "Title: $OLDEST_TITLE"
    echo "Created: $OLDEST_DATE"
    
    # Get issue details
    echo ""
    echo "=== Issue Details ==="
    ISSUE_DETAILS=$(gh issue view "$OLDEST_NUMBER" --repo "rexuvia/$OLDEST_REPO" --json body,labels 2>/dev/null || echo "{}")
    
    ISSUE_BODY=$(echo "$ISSUE_DETAILS" | jq -r '.body // ""' | head -c 300)
    LABELS=$(echo "$ISSUE_DETAILS" | jq -r '.labels[].name // ""' | tr '\n' ',' | sed 's/,$//')
    
    echo "Labels: ${LABELS:-none}"
    echo "Body preview: $ISSUE_BODY"
    
    # Send Telegram message
    echo ""
    echo "=== Sending Telegram Message ==="
    
    MESSAGE="🦀 *Daily Issue Fixer* 🦀

*Issue Found:* rexuvia/$OLDEST_REPO#$OLDEST_NUMBER
*Title:* $OLDEST_TITLE
*Created:* $OLDEST_DATE
*Labels:* ${LABELS:-none}

*Description Preview:*
${ISSUE_BODY:0:200}...

*How should I proceed?*

1. ✅ Fix it now
2. 📝 Plan first  
3. 🔍 Investigate more
4. ⏸️ Skip this one
5. 🛑 Stop fixing

*Which model?*
1. 🧠 Opus 4.6
2. ⚡ Sonnet 4.6
3. 🔥 Gemini 3.1 Pro
4. 💻 GPT-5 Codex
5. 📊 Kimi K2.5
6. 🎨 Grok 4
7. 🛠️ DeepSeek V3.2

*Reply with TWO numbers (1-5 then 1-7)*
*Example: '1 4' = Fix now with GPT-5 Codex*"
    
    echo "$MESSAGE" | openclaw message send --channel telegram --target "$TELEGRAM_CHAT_ID" --message "$MESSAGE"
    
    # Create response file
    RESPONSE_FILE="$WORKSPACE_DIR/memory/issue-fixer-waiting-$OLDEST_REPO-$OLDEST_NUMBER.json"
    cat > "$RESPONSE_FILE" << EOF
{
    "repo": "$OLDEST_REPO",
    "issue_number": "$OLDEST_NUMBER",
    "issue_title": "$OLDEST_TITLE",
    "timestamp": "$(date -Iseconds)",
    "status": "waiting_for_response"
}
EOF
    
    echo "Response file created: $RESPONSE_FILE"
    
else
    echo ""
    echo "=== NO ISSUES FOUND ==="
    echo "No unaddressed issues by schbz found."
    
    # Send all-clear message
    ALL_CLEAR_MSG="🦀 *Daily Issue Fixer* 🦀

✅ *All Clear!*

No unaddressed issues found from user 'schbz' in rexuvia/* repositories.

Check again tomorrow at 7:00 AM Eastern."
    
    echo "$ALL_CLEAR_MSG" | openclaw message send --channel telegram --target "$TELEGRAM_CHAT_ID" --message "$ALL_CLEAR_MSG"
fi

echo ""
echo "=== Done ==="