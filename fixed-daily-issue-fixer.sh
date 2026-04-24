#!/bin/bash
# Fixed Daily Issue Fixer for Rexuvia repositories
# Simplified version to find and report the oldest unaddressed issue

set -euo pipefail

# Configuration
TELEGRAM_CHAT_ID="6839797771"  # Sky's Telegram ID
WORKSPACE_DIR="/home/ubuntu/.openclaw/workspace"
LOG_FILE="$WORKSPACE_DIR/memory/daily-issue-fixer-$(date +%Y-%m-%d).log"
ISSUE_CACHE="$WORKSPACE_DIR/memory/issue-fixer-cache.json"

# Create log directory if it doesn't exist
mkdir -p "$(dirname "$LOG_FILE")"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Error handling function
error_exit() {
    log "ERROR: $1"
    exit 1
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    if ! command -v gh &> /dev/null; then
        error_exit "GitHub CLI (gh) is not installed."
    fi
    
    if ! gh auth status &> /dev/null; then
        error_exit "GitHub CLI is not authenticated."
    fi
    
    if ! command -v openclaw &> /dev/null; then
        error_exit "OpenClaw CLI is not available."
    fi
    
    log "Prerequisites check passed."
}

# Find oldest unaddressed issue by schbz
find_oldest_schbz_issue() {
    log "Searching for oldest unaddressed issue by user 'schbz'..."
    
    # Load cache of processed issues
    local processed_issues=()
    if [ -f "$ISSUE_CACHE" ] && jq -e '.processed_issues' "$ISSUE_CACHE" >/dev/null 2>&1; then
        processed_issues=($(jq -r '.processed_issues[]' "$ISSUE_CACHE"))
    fi
    
    # Get list of rexuvia repositories
    local repos
    repos=$(gh repo list rexuvia --json name --limit 100 | jq -r '.[].name' 2>/dev/null || echo "")
    
    if [ -z "$repos" ]; then
        log "Warning: Could not fetch rexuvia repositories."
        # Use known repos as fallback
        repos="rexuvia-site glitch-loom word-bird memory-palace-builder flock-mind"
    fi
    
    local oldest_issue=""
    local oldest_date="9999-99-99"
    local oldest_repo=""
    local oldest_title=""
    local oldest_number=""
    
    # Check each repository
    for repo in $repos; do
        log "Checking repository: rexuvia/$repo"
        
        # Get open issues by schbz
        local issues_json
        issues_json=$(gh issue list --repo "rexuvia/$repo" --author "schbz" --state open --json number,title,createdAt --limit 10 2>/dev/null || echo "[]")
        
        # Parse each issue
        local issue_count
        issue_count=$(echo "$issues_json" | jq length)
        
        for ((i=0; i<issue_count; i++)); do
            local issue_number
            local issue_title
            local created_at
            local issue_key
            
            issue_number=$(echo "$issues_json" | jq -r ".[$i].number")
            issue_title=$(echo "$issues_json" | jq -r ".[$i].title")
            created_at=$(echo "$issues_json" | jq -r ".[$i].createdAt")
            issue_key="${repo}#${issue_number}"
            
            # Skip if already processed
            local skip=0
            for processed in "${processed_issues[@]}"; do
                if [ "$processed" = "$issue_key" ]; then
                    log "  Skipping already processed issue: $issue_key"
                    skip=1
                    break
                fi
            done
            
            if [ $skip -eq 1 ]; then
                continue
            fi
            
            # Convert date to sortable format (YYYY-MM-DD)
            local sort_date="${created_at:0:10}"
            
            # Check if this is older than current oldest
            if [[ "$sort_date" < "$oldest_date" ]]; then
                oldest_date="$sort_date"
                oldest_issue="$issue_key"
                oldest_repo="$repo"
                oldest_title="$issue_title"
                oldest_number="$issue_number"
                log "  New oldest issue found: $issue_key ($sort_date)"
            fi
        done
    done
    
    if [ -n "$oldest_issue" ]; then
        log "Found oldest unaddressed issue: $oldest_issue (created: $oldest_date)"
        echo "$oldest_repo $oldest_number \"$oldest_title\" $oldest_date"
    else
        log "No unaddressed issues found by user 'schbz'."
        echo ""
    fi
}

# Analyze issue
analyze_issue() {
    local repo="$1"
    local issue_number="$2"
    local issue_title="$3"
    
    log "Analyzing issue: rexuvia/$repo#$issue_number"
    
    # Get issue details
    local issue_json
    issue_json=$(gh issue view "$issue_number" --repo "rexuvia/$repo" --json body,labels 2>/dev/null || echo "{}")
    
    local issue_body
    issue_body=$(echo "$issue_json" | jq -r '.body // ""' | head -c 500)
    
    local labels
    labels=$(echo "$issue_json" | jq -r '.labels[].name // ""' | tr '\n' ',' | sed 's/,$//')
    
    # Determine issue type
    local issue_type="feature"
    if [[ "$issue_title" =~ [Bb]ug|[Ff]ix|[Ee]rror ]] || \
       [[ "$issue_body" =~ [Bb]ug|[Ff]ix|[Ee]rror ]] || \
       [[ "$labels" =~ [Bb]ug ]]; then
        issue_type="bug"
    elif [[ "$issue_title" =~ [Dd]ocs?|[Rr]eadme ]] || \
         [[ "$issue_body" =~ [Dd]ocs?|[Rr]eadme ]] || \
         [[ "$labels" =~ [Dd]ocumentation ]]; then
        issue_type="documentation"
    fi
    
    # Create analysis
    local analysis="*Issue Type:* $issue_type\n"
    if [ -n "$labels" ]; then
        analysis+="*Labels:* $labels\n"
    fi
    analysis+="*Title:* $issue_title\n\n"
    
    if [ -n "$issue_body" ]; then
        analysis+="*Description:*\n${issue_body:0:300}..."
    else
        analysis+="*Description:* No description provided."
    fi
    
    echo -e "$analysis"
}

# Send Telegram message
send_telegram_message() {
    local repo="$1"
    local issue_number="$2"
    local issue_title="$3"
    local analysis="$4"
    
    log "Sending Telegram message to Sky..."
    
    # Create message
    local message="🦀 *Daily Issue Fixer* 🦀

*Issue Found:* rexuvia/$repo#$issue_number

$analysis

*How should I proceed?*

1. ✅ *Fix it now* - I'll implement the fix immediately
2. 📝 *Plan first* - Create a detailed plan before implementing  
3. 🔍 *Investigate more* - Do more research before deciding
4. ⏸️ *Skip this one* - Skip this issue and check again tomorrow
5. 🛑 *Stop fixing* - Pause the daily issue fixer

*Which model should I use for coding?*
1. 🧠 Opus 4.6 (best for complex tasks)
2. ⚡ Sonnet 4.6 (balanced, reliable)
3. 🔥 Gemini 3.1 Pro (creative solutions)
4. 💻 GPT-5 Codex (excellent for code)
5. 📊 Kimi K2.5 (good for analysis)
6. 🎨 Grok 4 (creative, unconventional)
7. 🛠️ DeepSeek V3.2 (technical tasks)

*Reply with TWO numbers (1-5 for action, then 1-7 for model)*
*Example: '1 4' = Fix it now with GPT-5 Codex*"
    
    # Send message via OpenClaw
    echo "$message" | openclaw message send --channel telegram --to "$TELEGRAM_CHAT_ID" --message "$message" 2>/dev/null || error_exit "Failed to send Telegram message"
    
    log "Telegram message sent."
    
    # Store issue info for response handling
    local response_file="$WORKSPACE_DIR/memory/issue-fixer-waiting-$repo-$issue_number.json"
    cat > "$response_file" << EOF
{
    "repo": "$repo",
    "issue_number": "$issue_number",
    "issue_title": "$(echo "$issue_title" | jq -R -s -c .)",
    "timestamp": "$(date -Iseconds)",
    "status": "waiting_for_response"
}
EOF
    
    log "Response file created: $response_file"
}

# Main execution
main() {
    log "=== Daily Issue Fixer Started ==="
    
    check_prerequisites
    
    # Check if there's already a waiting response
    local waiting_files
    waiting_files=$(find "$WORKSPACE_DIR/memory" -name "issue-fixer-waiting-*.json" -mtime -2 2>/dev/null || echo "")
    
    if [ -n "$waiting_files" ]; then
        log "Found waiting response files. Please respond to them first."
        echo "🔄 There are waiting responses. Please respond to them first."
        exit 0
    fi
    
    # Find oldest issue
    local issue_info
    issue_info=$(find_oldest_schbz_issue)
    
    if [ -z "$issue_info" ]; then
        log "No issues to process. Sending all-clear notification."
        
        # Send all-clear message
        local all_clear_msg="🦀 *Daily Issue Fixer* 🦀

✅ *All Clear!*

No unaddressed issues found from user 'schbz' in rexuvia/* repositories.

Check again tomorrow at 7:00 AM Eastern."
        
        echo "$all_clear_msg" | openclaw message send --channel telegram --to "$TELEGRAM_CHAT_ID" --message "$all_clear_msg" 2>/dev/null || true
        
        log "All-clear notification sent."
        exit 0
    fi
    
    # Parse issue info
    read -r repo issue_number issue_title issue_date <<< "$issue_info"
    issue_title=$(echo "$issue_title" | sed 's/^"//;s/"$//')
    
    log "Processing issue: rexuvia/$repo#$issue_number - $issue_title"
    
    # Analyze issue
    local analysis
    analysis=$(analyze_issue "$repo" "$issue_number" "$issue_title")
    
    # Send Telegram message
    send_telegram_message "$repo" "$issue_number" "$issue_title" "$analysis"
    
    log "=== Daily Issue Fixer Completed ==="
    log "Waiting for Sky's response..."
}

# Run main function
main "$@"