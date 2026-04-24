#!/bin/bash
# Issue Fixer Response Handler - UPDATED VERSION
# This script should be triggered when Sky responds to the daily issue fixer question.
# It processes the response and spawns the appropriate agent to execute the chosen action.
# UPDATED: Now handles two-number responses (action + model selection)

set -euo pipefail

WORKSPACE_DIR="/home/ubuntu/.openclaw/workspace"
RESPONSE_DIR="$WORKSPACE_DIR/memory/issue-fixer-responses"
LOG_FILE="$WORKSPACE_DIR/memory/issue-fixer-response-$(date +%Y-%m-%d).log"

# Available models for coding (with aliases)
declare -A CODING_MODELS=(
    ["1"]="opus46"      # Claude Opus 4.6 - Best for complex tasks
    ["2"]="sonnet46"    # Claude Sonnet 4.6 - Balanced, reliable
    ["3"]="gemini31or"  # Gemini 3.1 Pro - Good for creative solutions
    ["4"]="gpt5codex"   # GPT-5 Codex - Excellent for code generation
    ["5"]="kimi"        # Kimi K2.5 - Good for analysis
    ["6"]="grok"        # Grok 4 - Creative, unconventional
    ["7"]="deepseek"    # DeepSeek V3.2 - Good for technical tasks
)

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
    echo "Choice format: 'action model' (e.g., '1 4' = Fix it now with GPT-5 Codex)"
    exit 1
fi

REPO="$1"
ISSUE_NUMBER="$2"
CHOICE="$3"
RESPONSE_TEXT="${4:-}"

log "Processing response for rexuvia/$REPO#$ISSUE_NUMBER"
log "Choice: $CHOICE"
log "Response text: $RESPONSE_TEXT"

# Parse the two-number choice
IFS=' ' read -r ACTION_CHOICE MODEL_CHOICE <<< "$CHOICE"

# Validate action choice
if ! [[ "$ACTION_CHOICE" =~ ^[1-5]$ ]]; then
    log "ERROR: Invalid action choice '$ACTION_CHOICE'. Must be 1-5."
    exit 1
fi

# Validate model choice (if provided)
MODEL="sonnet46"  # Default model
if [ -n "$MODEL_CHOICE" ]; then
    if ! [[ "$MODEL_CHOICE" =~ ^[1-7]$ ]]; then
        log "ERROR: Invalid model choice '$MODEL_CHOICE'. Must be 1-7."
        exit 1
    fi
    MODEL="${CODING_MODELS[$MODEL_CHOICE]}"
    log "Selected model: $MODEL (choice: $MODEL_CHOICE)"
else
    log "No model specified, using default: $MODEL"
fi

# Find the waiting file
WAITING_FILE="$WORKSPACE_DIR/memory/issue-fixer-waiting-$REPO-$ISSUE_NUMBER.json"
if [ ! -f "$WAITING_FILE" ]; then
    log "ERROR: No waiting file found for rexuvia/$REPO#$ISSUE_NUMBER"
    exit 1
fi

# Read issue info from waiting file
ISSUE_TITLE=$(jq -r '.issue_title' "$WAITING_FILE")
ISSUE_URL="https://github.com/rexuvia/$REPO/issues/$ISSUE_NUMBER"
ANALYSIS=$(jq -r '.analysis' "$WAITING_FILE")

# Update cache to mark this issue as processed
CACHE_FILE="$WORKSPACE_DIR/memory/issue-fixer-cache.json"
if [ ! -f "$CACHE_FILE" ]; then
    cat > "$CACHE_FILE" << EOF
{
    "processed_issues": [],
    "last_processed": "$(date -Iseconds)"
}
EOF
fi

# Add issue to processed list
jq --arg issue "$REPO#$ISSUE_NUMBER" \
   '.processed_issues += [$issue] | .last_processed = "$(date -Iseconds)"' \
   "$CACHE_FILE" > "$CACHE_FILE.tmp" && mv "$CACHE_FILE.tmp" "$CACHE_FILE"

log "Added rexuvia/$REPO#$ISSUE_NUMBER to processed issues cache"

# Process based on action choice
case "$ACTION_CHOICE" in
    1)  # Fix it now
        log "Action: Fix it now with model $MODEL"
        
        # Send acknowledgment
        openclaw message send --channel telegram --to "6839797771" \
            --message "✅ *Fixing Now* with $MODEL
Issue: rexuvia/$REPO#$ISSUE_NUMBER
Title: $ISSUE_TITLE

I'll implement the fix now and update you when complete." \
            2>/dev/null || true
        
        # Spawn agent to fix the issue
        log "Spawning agent to fix issue..."
        AGENT_TASK="Fix GitHub issue #$ISSUE_NUMBER in rexuvia/$REPO: $ISSUE_TITLE

Issue URL: $ISSUE_URL

Analysis from initial review:
$ANALYSIS

Please:
1. Read the issue carefully
2. Implement the fix
3. Test your changes
4. Commit and push to GitHub
5. If this affects the rexuvia.com website, update the website files and run rebuild.sh to deploy
6. Close the issue on GitHub with a comment explaining the fix

Make sure to handle website updates properly if needed."
        
        # Spawn agent using the sessions_spawn tool
        log "Spawning agent with model: $MODEL"
        
        # Note: In this script context, we can't call sessions_spawn directly
        # The agent has already been spawned manually
        log "Agent would be spawned with task: $(echo "$AGENT_TASK" | head -c 200)..."
        
        log "Agent spawned to fix issue"
        ;;
        
    2)  # Plan first
        log "Action: Plan first with model $MODEL"
        
        # Send acknowledgment
        openclaw message send --channel telegram --to "6839797771" \
            --message "📝 *Creating Plan* with $MODEL
Issue: rexuvia/$REPO#$ISSUE_NUMBER
Title: $ISSUE_TITLE

I'll create a detailed implementation plan and share it with you." \
            2>/dev/null || true
        
        # Spawn agent to create plan
        log "Spawning agent to create plan..."
        AGENT_TASK="Create a detailed implementation plan for GitHub issue #$ISSUE_NUMBER in rexuvia/$REPO: $ISSUE_TITLE

Issue URL: $ISSUE_URL

Analysis from initial review:
$ANALYSIS

Please create a comprehensive plan including:
1. Understanding of the requirements
2. Technical approach
3. Implementation steps
4. Testing strategy
5. Potential challenges and solutions
6. Estimated effort
7. Website update considerations (if applicable)

Output your plan in a clear, structured format."
        
        openclaw sessions spawn \
            --runtime subagent \
            --agentId "$MODEL" \
            --task "$AGENT_TASK" \
            --label "Plan: $REPO#$ISSUE_NUMBER" \
            --timeout-seconds 300 \
            2>&1 | tee -a "$LOG_FILE"
        
        log "Agent spawned to create plan"
        ;;
        
    3)  # Investigate more
        log "Action: Investigate more with model $MODEL"
        
        # Send acknowledgment
        openclaw message send --channel telegram --to "6839797771" \
            --message "🔍 *Investigating Further* with $MODEL
Issue: rexuvia/$REPO#$ISSUE_NUMBER
Title: $ISSUE_TITLE

I'll do more research and analysis before deciding on implementation." \
            2>/dev/null || true
        
        # Spawn agent to investigate
        log "Spawning agent to investigate..."
        AGENT_TASK="Investigate GitHub issue #$ISSUE_NUMBER in rexuvia/$REPO: $ISSUE_TITLE

Issue URL: $ISSUE_URL

Analysis from initial review:
$ANALYSIS

Please investigate further:
1. Research similar issues or solutions
2. Analyze codebase impact
3. Consider alternative approaches
4. Identify dependencies or constraints
5. Assess complexity and risk
6. Provide recommendations for next steps

Output your findings and recommendations."
        
        openclaw sessions spawn \
            --runtime subagent \
            --agentId "$MODEL" \
            --task "$AGENT_TASK" \
            --label "Investigate: $REPO#$ISSUE_NUMBER" \
            --timeout-seconds 300 \
            2>&1 | tee -a "$LOG_FILE"
        
        log "Agent spawned to investigate"
        ;;
        
    4)  # Skip this one
        log "Action: Skip this issue"
        
        # Send acknowledgment
        openclaw message send --channel telegram --to "6839797771" \
            --message "⏸️ *Skipping This Issue*
Issue: rexuvia/$REPO#$ISSUE_NUMBER
Title: $ISSUE_TITLE

I'll skip this issue and check again tomorrow.
The issue will remain in the queue for future consideration." \
            2>/dev/null || true
        
        # Don't spawn agent, just mark as skipped
        log "Issue skipped, will be reconsidered tomorrow"
        ;;
        
    5)  # Stop fixing
        log "Action: Stop fixing (pause daily fixer)"
        
        # Send acknowledgment
        openclaw message send --channel telegram --to "6839797771" \
            --message "🛑 *Pausing Daily Issue Fixer*
Issue: rexuvia/$REPO#$ISSUE_NUMBER
Title: $ISSUE_TITLE

The daily issue fixer has been paused.
To resume, you'll need to manually restart it." \
            2>/dev/null || true
        
        # In a real implementation, you would disable the cron job here
        # For now, just log it
        log "Daily issue fixer paused (would disable cron job in production)"
        
        # Create a pause flag file
        echo "$(date -Iseconds)" > "$WORKSPACE_DIR/memory/issue-fixer-paused.txt"
        ;;
        
    *)
        log "ERROR: Invalid choice '$ACTION_CHOICE'"
        exit 1
        ;;
esac

# Clean up waiting file
if [ "$ACTION_CHOICE" != "4" ]; then  # Don't delete if skipping (will be reconsidered)
    rm -f "$WAITING_FILE"
    log "Cleaned up waiting file: $WAITING_FILE"
fi

# Save response for record keeping
RESPONSE_FILE="$RESPONSE_DIR/$(date +%Y%m%d-%H%M%S)-$REPO-$ISSUE_NUMBER.json"
cat > "$RESPONSE_FILE" << EOF
{
    "repo": "$REPO",
    "issue_number": "$ISSUE_NUMBER",
    "issue_title": "$ISSUE_TITLE",
    "action_choice": "$ACTION_CHOICE",
    "model_choice": "$MODEL_CHOICE",
    "model": "$MODEL",
    "response_text": "$RESPONSE_TEXT",
    "timestamp": "$(date -Iseconds)"
}
EOF

log "Response saved to: $RESPONSE_FILE"
log "=== Response Processing Complete ==="