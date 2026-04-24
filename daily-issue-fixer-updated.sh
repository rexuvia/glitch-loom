#!/bin/bash
# Daily Issue Fixer for Rexuvia repositories - UPDATED VERSION
# This script finds the oldest unaddressed issue by user "schbz" across all rexuvia/* repos,
# analyzes it, creates a plan, sends a Telegram message to Sky with multiple choice options,
# waits for response, executes the fix, and ensures website updates are handled properly.
# UPDATED: Now includes model selection and runs at 7 AM daily.

set -euo pipefail

# Configuration
TELEGRAM_CHAT_ID="6839797771"  # Sky's Telegram ID
WORKSPACE_DIR="/home/ubuntu/.openclaw/workspace"
LOG_FILE="$WORKSPACE_DIR/memory/daily-issue-fixer-$(date +%Y-%m-%d).log"
ISSUE_CACHE="$WORKSPACE_DIR/memory/issue-fixer-cache.json"
MAX_ISSUES_TO_CHECK=50

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

# Create log directory if it doesn't exist
mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$(dirname "$ISSUE_CACHE")"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Error handling function
error_exit() {
    log "ERROR: $1"
    # Send error notification to Telegram
    if [ -n "${2:-}" ]; then
        echo "Error: $1" | openclaw message send --channel telegram --to "$TELEGRAM_CHAT_ID" --message "❌ Issue Fixer Error: $1" 2>/dev/null || true
    fi
    exit 1
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check if gh CLI is installed
    if ! command -v gh &> /dev/null; then
        error_exit "GitHub CLI (gh) is not installed. Please install it first."
    fi
    
    # Check if authenticated
    if ! gh auth status &> /dev/null; then
        error_exit "GitHub CLI is not authenticated. Please run 'gh auth login' first."
    fi
    
    # Check if openclaw is available
    if ! command -v openclaw &> /dev/null; then
        error_exit "OpenClaw CLI is not available. Please check your installation."
    fi
    
    log "Prerequisites check passed."
}

# Find oldest unaddressed issue by schbz
find_oldest_schbz_issue() {
    log "Searching for oldest unaddressed issue by user 'schbz'..."
    
    # Load cache of processed issues
    local processed_issues=()
    if [ -f "$ISSUE_CACHE" ]; then
        processed_issues=($(jq -r '.processed_issues[]' "$ISSUE_CACHE" 2>/dev/null || echo ""))
    fi
    
    # Get list of rexuvia repositories
    local repos
    repos=$(gh repo list rexuvia --json name --limit 100 | jq -r '.[].name' 2>/dev/null || echo "")
    
    if [ -z "$repos" ]; then
        error_exit "Could not fetch rexuvia repositories. Check GitHub API access."
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
        issues_json=$(gh issue list --repo "rexuvia/$repo" --author "schbz" --state open --json number,title,createdAt,updatedAt --limit "$MAX_ISSUES_TO_CHECK" 2>/dev/null || echo "[]")
        
        # Parse each issue
        local issue_count
        issue_count=$(echo "$issues_json" | jq length)
        
        for ((i=0; i<issue_count; i++)); do
            local issue_number
            local issue_title
            local created_at
            local updated_at
            local issue_key
            
            issue_number=$(echo "$issues_json" | jq -r ".[$i].number")
            issue_title=$(echo "$issues_json" | jq -r ".[$i].title")
            created_at=$(echo "$issues_json" | jq -r ".[$i].createdAt")
            updated_at=$(echo "$issues_json" | jq -r ".[$i].updatedAt")
            issue_key="${repo}#${issue_number}"
            
            # Skip if already processed
            if printf '%s\n' "${processed_issues[@]}" | grep -q "^${issue_key}$"; then
                log "  Skipping already processed issue: $issue_key"
                continue
            fi
            
            # Convert date to sortable format
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

# Analyze issue type and create plan
analyze_issue() {
    local repo="$1"
    local issue_number="$2"
    local issue_title="$3"
    
    log "Analyzing issue: rexuvia/$repo#$issue_number"
    
    # Get issue details
    local issue_json
    issue_json=$(gh issue view "$issue_number" --repo "rexuvia/$repo" --json body,labels 2>/dev/null || echo "{}")
    
    local issue_body
    issue_body=$(echo "$issue_json" | jq -r '.body // ""' | head -c 1000)
    local labels
    labels=$(echo "$issue_json" | jq -r '.labels[].name // ""' | tr '\n' ',' | sed 's/,$//')
    
    # Determine issue type
    local issue_type="feature"
    local analysis=""
    
    # Check for bug indicators
    if [[ "$issue_title" =~ [Bb]ug|[Ff]ix|[Ee]rror|[Cc]rash|[Bb]roken ]] || \
       [[ "$issue_body" =~ [Bb]ug|[Ff]ix|[Ee]rror|[Cc]rash|[Bb]roken ]] || \
       [[ "$labels" =~ [Bb]ug ]]; then
        issue_type="bug"
        analysis="This appears to be a bug report. The issue likely requires debugging and fixing existing functionality."
    # Check for documentation indicators
    elif [[ "$issue_title" =~ [Dd]ocs?|[Rr]eadme|[Uu]pdate.*[Dd]oc ]] || \
         [[ "$issue_body" =~ [Dd]ocs?|[Rr]eadme|[Uu]pdate.*[Dd]oc ]] || \
         [[ "$labels" =~ [Dd]ocumentation ]]; then
        issue_type="documentation"
        analysis="This is a documentation issue. It likely requires updating README, comments, or documentation files."
    else
        issue_type="feature"
        analysis="This appears to be a feature request or enhancement. It likely requires implementing new functionality."
    fi
    
    # Add label info if available
    if [ -n "$labels" ]; then
        analysis="$analysis\nLabels: $labels"
    fi
    
    # Create plan based on issue type
    local plan=""
    case "$issue_type" in
        "bug")
            plan="1. Reproduce the bug if possible\n2. Identify root cause\n3. Implement fix\n4. Test thoroughly\n5. Update any affected documentation"
            ;;
        "feature")
            plan="1. Understand requirements\n2. Design implementation\n3. Write code\n4. Test functionality\n5. Update documentation\n6. Consider edge cases"
            ;;
        "documentation")
            plan="1. Review current documentation\n2. Identify gaps/errors\n3. Write updates\n4. Ensure clarity and completeness\n5. Verify links and examples"
            ;;
    esac
    
    log "Issue type: $issue_type"
    
    echo -e "$analysis\n\n*Plan:*\n$plan"
}

# Send Telegram message with multiple choice options (UPDATED with model selection)
send_telegram_question() {
    local repo="$1"
    local issue_number="$2"
    local issue_title="$3"
    local analysis="$4"
    
    log "Sending Telegram message to Sky..."
    
    # Truncate analysis for Telegram (max 4096 chars)
    local truncated_analysis
    truncated_analysis=$(echo "$analysis" | head -c 2500)
    
    # Create message with multiple choice options including model selection
    local message="🦀 *Daily Issue Fixer* 🦀

*Issue Found:* rexuvia/$repo#$issue_number
*Title:* $issue_title

*Analysis:*
$truncated_analysis

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
    echo "$message" | openclaw message send --channel telegram --to "$TELEGRAM_CHAT_ID" --message "$message" 2>/dev/null || error_exit "Failed to send Telegram message" "notify"
    
    log "Telegram message sent. Waiting for response..."
    
    # Store issue info for response handling (UPDATED to include model selection)
    local response_file="$WORKSPACE_DIR/memory/issue-fixer-waiting-$repo-$issue_number.json"
    cat > "$response_file" << EOF
{
    "repo": "$repo",
    "issue_number": "$issue_number",
    "issue_title": "$issue_title",
    "analysis": "$(echo "$analysis" | jq -R -s -c .)",
    "timestamp": "$(date -Iseconds)",
    "status": "waiting_for_response",
    "requires_model_selection": true
}
EOF
    
    log "Response file created: $response_file"
}

# Main execution
main() {
    log "=== Daily Issue Fixer Started ==="
    log "Version: 2.0.0 (with model selection)"
    
    check_prerequisites
    
    # Check if there's already a waiting response
    local waiting_files
    waiting_files=$(find "$WORKSPACE_DIR/memory" -name "issue-fixer-waiting-*.json" -mtime -2 2>/dev/null || echo "")
    
    if [ -n "$waiting_files" ]; then
        log "Found waiting response files. Skipping new issue search."
        log "Use the response handler to process waiting responses first."
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

All issues are either:
• Already processed
• Already fixed
• Being handled

Check again tomorrow at 7:00 AM."
        
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
    
    # Send Telegram question
    send_telegram_question "$repo" "$issue_number" "$issue_title" "$analysis"
    
    log "=== Daily Issue Fixer Completed ==="
    log "Waiting for Sky's response..."
}

# Run main function
main "$@"