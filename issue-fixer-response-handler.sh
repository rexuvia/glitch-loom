#!/bin/bash
# Issue Fixer Response Handler
# This script should be triggered when Sky responds to the daily issue fixer question.
# It processes the response and spawns the appropriate agent to execute the chosen action.

set -euo pipefail

WORKSPACE_DIR="/home/ubuntu/.openclaw/workspace"
RESPONSE_DIR="$WORKSPACE_DIR/memory/issue-fixer-responses"
LOG_FILE="$WORKSPACE_DIR/memory/issue-fixer-response-$(date +%Y-%m-%d).log"

# Create directories if they don't exist
mkdir -p "$RESPONSE_DIR"
mkdir -p "$(dirname "$LOG_FILE")"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Parse command line arguments
if [ $# -lt 3 ]; then
    echo "Usage: $0 <repo> <issue_number> <choice> [response_text]"
    exit 1
fi

REPO="$1"
ISSUE_NUMBER="$2"
CHOICE="$3"
RESPONSE_TEXT="${4:-}"

log "Processing response for rexuvia/$REPO#$ISSUE_NUMBER"
log "Choice: $CHOICE"
log "Response text: $RESPONSE_TEXT"

# Find the waiting file
WAITING_FILE="$WORKSPACE_DIR/memory/issue-fixer-waiting-$REPO-$ISSUE_NUMBER.json"
if [ ! -f "$WAITING_FILE" ]; then
    log "ERROR: No waiting file found for rexuvia/$REPO#$ISSUE_NUMBER"
    exit 1
fi

# Read issue info from waiting file
ISSUE_TITLE=$(jq -r '.issue_title' "$WAITING_FILE")
ISSUE_URL="https://github.com/rexuvia/$REPO/issues/$ISSUE_NUMBER"

# Update cache to mark this issue as processed
CACHE_FILE="$WORKSPACE_DIR/memory/issue-fixer-cache.json"
if [ ! -f "$CACHE_FILE" ]; then
    cat > "$CACHE_FILE" << EOF
{
    "processed_issues": []
}
EOF
fi

# Add to processed issues
jq --arg url "$ISSUE_URL" --arg date "$(date -Iseconds)" --arg choice "$CHOICE" \
   '.processed_issues += [{"url": $url, "processed_date": $date, "choice": $choice}]' \
   "$CACHE_FILE" > "${CACHE_FILE}.tmp" && mv "${CACHE_FILE}.tmp" "$CACHE_FILE"

# Process the choice
case "$CHOICE" in
    "1")
        log "Choice 1: Fix it now - Spawning fix agent"
        spawn_fix_agent "immediate"
        ;;
    "2")
        log "Choice 2: Plan first - Spawning planning agent"
        spawn_planning_agent
        ;;
    "3")
        log "Choice 3: Investigate more - Spawning research agent"
        spawn_research_agent
        ;;
    "4")
        log "Choice 4: Skip this one - Marking as skipped"
        send_telegram_message "⏸️ Issue #$ISSUE_NUMBER skipped. Will check for next issue tomorrow."
        ;;
    "5")
        log "Choice 5: Stop fixing - Disabling daily fixer"
        send_telegram_message "🛑 Daily issue fixer paused. To re-enable, run: openclaw cron enable daily-issue-fixer"
        # Disable the cron job
        openclaw cron disable daily-issue-fixer 2>/dev/null || true
        ;;
    *)
        log "ERROR: Invalid choice: $CHOICE"
        send_telegram_message "❌ Invalid choice '$CHOICE'. Please respond with a number 1-5."
        exit 1
        ;;
esac

# Remove waiting file
rm -f "$WAITING_FILE"
log "Response processing complete."

# Function to spawn a fix agent
spawn_fix_agent() {
    local mode="$1"
    
    log "Spawning fix agent for rexuvia/$REPO issue #$ISSUE_NUMBER"
    
    # Create agent message
    local agent_message="Fix the GitHub issue rexuvia/$REPO#$ISSUE_NUMBER: $ISSUE_TITLE
    
Please:
1. Read the issue details at $ISSUE_URL
2. Analyze what needs to be fixed
3. Implement the fix
4. Test the fix
5. Commit and push the changes
6. If the fix affects the website (rexuvia-site), ensure it gets properly deployed
7. Update the issue with a comment about the fix

Important constraints:
- Only fix this ONE issue
- Make sure website updates are handled properly (run rebuild.sh if needed)
- Include proper error handling
- Document your changes"

    # Spawn isolated agent session
    local session_id
    session_id=$(openclaw cron add --at "+1s" \
        --name "issue-fix-$REPO-$ISSUE_NUMBER" \
        --session isolated \
        --agent main \
        --message "$agent_message" \
        --announce \
        --to "6839797771" \
        --channel telegram \
        --json 2>/dev/null | jq -r '.id' || echo "")
    
    if [ -n "$session_id" ]; then
        log "Fix agent spawned with session ID: $session_id"
        send_telegram_message "✅ Fix agent spawned for issue #$ISSUE_NUMBER. Agent will work on it now and report back."
    else
        log "ERROR: Failed to spawn fix agent"
        send_telegram_message "❌ Failed to spawn fix agent for issue #$ISSUE_NUMBER. Please check logs."
    fi
}

# Function to spawn a planning agent
spawn_planning_agent() {
    log "Spawning planning agent for rexuvia/$REPO issue #$ISSUE_NUMBER"
    
    local agent_message="Create a detailed implementation plan for GitHub issue rexuvia/$REPO#$ISSUE_NUMBER: $ISSUE_TITLE
    
Please:
1. Read the issue details at $ISSUE_URL
2. Analyze the requirements
3. Create a step-by-step implementation plan
4. Identify potential challenges and solutions
5. Estimate effort required
6. Suggest testing strategy
7. Create a checklist for the actual implementation

The plan should be comprehensive enough that another agent could execute it."

    local session_id
    session_id=$(openclaw cron add --at "+1s" \
        --name "issue-plan-$REPO-$ISSUE_NUMBER" \
        --session isolated \
        --agent main \
        --message "$agent_message" \
        --announce \
        --to "6839797771" \
        --channel telegram \
        --json 2>/dev/null | jq -r '.id' || echo "")
    
    if [ -n "$session_id" ]; then
        log "Planning agent spawned with session ID: $session_id"
        send_telegram_message "📝 Planning agent spawned for issue #$ISSUE_NUMBER. Will create detailed implementation plan."
    else
        log "ERROR: Failed to spawn planning agent"
        send_telegram_message "❌ Failed to spawn planning agent for issue #$ISSUE_NUMBER. Please check logs."
    fi
}

# Function to spawn a research agent
spawn_research_agent() {
    log "Spawning research agent for rexuvia/$REPO issue #$ISSUE_NUMBER"
    
    local agent_message="Investigate GitHub issue rexuvia/$REPO#$ISSUE_NUMBER: $ISSUE_TITLE
    
Please:
1. Read the issue details at $ISSUE_URL
2. Research similar issues or solutions
3. Analyze codebase context
4. Identify dependencies and potential impacts
5. Gather additional information needed
6. Provide recommendations on next steps
7. Suggest whether to fix, defer, or approach differently

Be thorough in your investigation."

    local session_id
    session_id=$(openclaw cron add --at "+1s" \
        --name "issue-research-$REPO-$ISSUE_NUMBER" \
        --session isolated \
        --agent main \
        --message "$agent_message" \
        --announce \
        --to "6839797771" \
        --channel telegram \
        --json 2>/dev/null | jq -r '.id' || echo "")
    
    if [ -n "$session_id" ]; then
        log "Research agent spawned with session ID: $session_id"
        send_telegram_message "🔍 Research agent spawned for issue #$ISSUE_NUMBER. Will investigate and provide recommendations."
    else
        log "ERROR: Failed to spawn research agent"
        send_telegram_message "❌ Failed to spawn research agent for issue #$ISSUE_NUMBER. Please check logs."
    fi
}

# Function to send Telegram message
send_telegram_message() {
    local message="$1"
    echo "$message" | openclaw message send --channel telegram --to "6839797771" --message "$message" 2>/dev/null || true
}

# Main execution
main() {
    log "=== Issue Fixer Response Handler Started ==="
    
    # The actual processing happens in the case statement above
    log "Response handler completed for rexuvia/$REPO#$ISSUE_NUMBER"
}

# Run main function
main "$@"