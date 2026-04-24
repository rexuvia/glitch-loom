#!/bin/bash
# Simple Daily Issue Fixer
# Finds the oldest unaddressed issue by schbz and sends Telegram message

set -euo pipefail

TELEGRAM_CHAT_ID="6839797771"
WORKSPACE_DIR="/home/ubuntu/.openclaw/workspace"
LOG_FILE="$WORKSPACE_DIR/memory/daily-issue-fixer-$(date +%Y-%m-%d).log"

mkdir -p "$(dirname "$LOG_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "=== Simple Daily Issue Fixer Started ==="

# Find all rexuvia repos
repos=$(gh repo list rexuvia --limit 100 --json name --jq '.[].name' 2>/dev/null || echo "rexuvia-site")

oldest_issue=""
oldest_date=""
oldest_repo=""
oldest_number=""
oldest_title=""
oldest_url=""

for repo in $repos; do
    log "Checking repo: rexuvia/$repo"
    
    issues_json=$(gh issue list --repo "rexuvia/$repo" --state open --author "schbz" --limit 10 --json number,title,createdAt,url 2>/dev/null || echo "[]")
    
    if [ "$issues_json" = "[]" ] || [ -z "$issues_json" ]; then
        continue
    fi
    
    issue_count=$(echo "$issues_json" | jq length 2>/dev/null || echo "0")
    
    for i in $(seq 0 $((issue_count - 1)) 2>/dev/null || echo "0"); do
        issue_number=$(echo "$issues_json" | jq -r ".[$i].number" 2>/dev/null || echo "")
        issue_title=$(echo "$issues_json" | jq -r ".[$i].title" 2>/dev/null || echo "")
        issue_created=$(echo "$issues_json" | jq -r ".[$i].createdAt" 2>/dev/null || echo "")
        issue_url=$(echo "$issues_json" | jq -r ".[$i].url" 2>/dev/null || echo "")
        
        if [ -z "$issue_number" ] || [ -z "$issue_created" ]; then
            continue
        fi
        
        # Find the oldest issue
        if [ -z "$oldest_date" ] || [[ "$issue_created" < "$oldest_date" ]]; then
            oldest_date="$issue_created"
            oldest_issue="$issue_title"
            oldest_repo="$repo"
            oldest_number="$issue_number"
            oldest_url="$issue_url"
        fi
    done
done

if [ -z "$oldest_issue" ]; then
    log "No unaddressed issues by schbz found."
    message="✅ *Daily Issue Fixer* ✅

No unaddressed issues by schbz found in rexuvia/* repositories today. Check complete!"
    
    echo "$message" | openclaw message send --channel telegram --to "$TELEGRAM_CHAT_ID" --message "$message" 2>/dev/null || log "Failed to send Telegram message"
    exit 0
fi

log "Found oldest issue: rexuvia/$oldest_repo#$oldest_number - $oldest_issue (created: $oldest_date)"

# Get issue details
issue_details=$(gh issue view "$oldest_number" --repo "rexuvia/$oldest_repo" --json body,labels 2>/dev/null || echo "{}")
issue_body=$(echo "$issue_details" | jq -r '.body // ""' 2>/dev/null || echo "")
labels=$(echo "$issue_details" | jq -r '.labels[].name // ""' 2>/dev/null | tr '\n' ',' | sed 's/,$//' || echo "")

# Determine issue type
issue_type="unknown"
if echo "$labels" | grep -qi "bug"; then
    issue_type="bug"
elif echo "$labels" | grep -qi "enhancement\|feature"; then
    issue_type="feature"
elif echo "$labels" | grep -qi "documentation"; then
    issue_type="documentation"
elif echo "$issue_body" | grep -qi "fix\|error\|broken"; then
    issue_type="bug"
elif echo "$issue_body" | grep -qi "add\|implement\|create"; then
    issue_type="feature"
elif echo "$issue_body" | grep -qi "doc\|readme\|guide"; then
    issue_type="documentation"
fi

# Create analysis
analysis="*Issue Type:* $issue_type
*Labels:* ${labels:-none}
*Title:* $oldest_issue
*URL:* $oldest_url

*Description:*
$(echo "$issue_body" | head -c 500)"

# Send Telegram message with model selection options
message="🦀 *Daily Issue Fixer* 🦀

*Issue Found:* rexuvia/$oldest_repo#$oldest_number
*Created:* $(date -d "$oldest_date" '+%Y-%m-%d %H:%M UTC')

$analysis

*How should I fix this? Choose a model:*

1. 🤖 *GPT-5 Codex* - Best for code fixes and implementations
2. 🧠 *Claude Sonnet 4.6* - Best for analysis and planning  
3. ⚡ *Gemini 2.5 Flash* - Fast and efficient for simple fixes
4. 🎨 *Claude Opus 4* - Creative solutions and complex problems
5. 🔍 *Investigate first* - Research more before deciding

*Reply with the number (1-5) to choose.*"

log "Sending Telegram message..."
echo "$message" | openclaw message send --channel telegram --to "$TELEGRAM_CHAT_ID" --message "$message" 2>/dev/null || log "Failed to send Telegram message"

# Store issue info for response handling
response_file="$WORKSPACE_DIR/memory/issue-fixer-waiting-$oldest_repo-$oldest_number.json"
cat > "$response_file" << EOF
{
    "repo": "$oldest_repo",
    "issue_number": "$oldest_number",
    "issue_title": "$oldest_title",
    "issue_url": "$oldest_url",
    "timestamp": "$(date -Iseconds)",
    "status": "waiting_for_response"
}
EOF

log "=== Daily Issue Fixer Completed ==="
log "Issue queued: rexuvia/$oldest_repo#$oldest_number"