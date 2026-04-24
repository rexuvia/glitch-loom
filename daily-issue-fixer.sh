#!/bin/bash
# Daily Issue Fixer for Rexuvia repositories
# This script finds the oldest unaddressed issue by user "schbz" across all rexuvia/* repos,
# analyzes it, creates a plan, sends a Telegram message to Sky with multiple choice options,
# waits for response, executes the fix, and ensures website updates are handled properly.

set -euo pipefail

# Configuration
TELEGRAM_CHAT_ID="6839797771"  # Sky's Telegram ID
WORKSPACE_DIR="/home/ubuntu/.openclaw/workspace"
LOG_FILE="$WORKSPACE_DIR/memory/daily-issue-fixer-$(date +%Y-%m-%d).log"
ISSUE_CACHE="$WORKSPACE_DIR/memory/issue-fixer-cache.json"
MAX_ISSUES_TO_CHECK=50

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
        error_exit "OpenClaw CLI is not available."
    fi
    
    log "Prerequisites check passed."
}

# Find all rexuvia/* repositories
find_rexuvia_repos() {
    log "Finding rexuvia/* repositories..."
    
    # Use gh to list repositories for the rexuvia organization
    local repos
    repos=$(gh repo list rexuvia --limit 100 --json name --jq '.[].name' 2>/dev/null || echo "")
    
    if [ -z "$repos" ]; then
        # Fallback: try to get repos from API
        repos=$(gh api orgs/rexuvia/repos --jq '.[].name' 2>/dev/null || echo "")
    fi
    
    if [ -z "$repos" ]; then
        log "Warning: Could not fetch rexuvia repositories. Using known repos."
        # Known rexuvia repositories
        echo "rexuvia-site"
        return 0
    fi
    
    echo "$repos"
}

# Find the oldest unaddressed issue by user "schbz"
find_oldest_schbz_issue() {
    log "Searching for oldest unaddressed issue by user 'schbz'..."
    
    local repos
    repos=$(find_rexuvia_repos)
    
    local oldest_issue=""
    local oldest_date=""
    local oldest_repo=""
    local oldest_number=""
    local oldest_title=""
    local oldest_url=""
    
    for repo in $repos; do
        log "Checking repo: rexuvia/$repo"
        
        # Search for open issues created by schbz
        local issues_json
        issues_json=$(gh issue list --repo "rexuvia/$repo" --state open --author "schbz" --limit "$MAX_ISSUES_TO_CHECK" --json number,title,createdAt,url 2>/dev/null || echo "[]")
        
        if [ "$issues_json" = "[]" ] || [ -z "$issues_json" ]; then
            continue
        fi
        
        # Parse issues
        local issue_count
        issue_count=$(echo "$issues_json" | jq length)
        
        for i in $(seq 0 $((issue_count - 1))); do
            local issue_number
            local issue_title
            local issue_created
            local issue_url
            
            issue_number=$(echo "$issues_json" | jq -r ".[$i].number")
            issue_title=$(echo "$issues_json" | jq -r ".[$i].title")
            issue_created=$(echo "$issues_json" | jq -r ".[$i].createdAt")
            issue_url=$(echo "$issues_json" | jq -r ".[$i].url")
            
            # Check if we've already processed this issue
            if jq -e ".processed_issues[] | select(.url == \"$issue_url\")" "$ISSUE_CACHE" &>/dev/null 2>&1; then
                log "Issue #$issue_number already processed, skipping."
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
    
    if [ -n "$oldest_issue" ]; then
        log "Found oldest issue: rexuvia/$oldest_repo#$oldest_number - $oldest_issue (created: $oldest_date)"
        echo "$oldest_repo,$oldest_number,$oldest_issue,$oldest_url,$oldest_date"
    else
        log "No unaddressed issues by schbz found."
        echo ""
    fi
}

# Analyze issue and create a plan
analyze_issue() {
    local repo="$1"
    local issue_number="$2"
    local issue_title="$3"
    local issue_url="$4"
    
    log "Analyzing issue: rexuvia/$repo#$issue_number - $issue_title"
    
    # Get issue details
    local issue_details
    issue_details=$(gh issue view "$issue_number" --repo "rexuvia/$repo" --json body,labels 2>/dev/null || echo "{}")
    
    local issue_body
    issue_body=$(echo "$issue_details" | jq -r '.body // ""')
    
    local labels
    labels=$(echo "$issue_details" | jq -r '.labels[].name // ""' | tr '\n' ',' | sed 's/,$//')
    
    # Determine issue type based on labels and content
    local issue_type="unknown"
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
    local analysis="Issue Type: $issue_type\n"
    analysis+="Labels: ${labels:-none}\n"
    analysis+="Title: $issue_title\n"
    analysis+="URL: $issue_url\n\n"
    
    # Extract key information from issue body (first 500 chars)
    local body_preview
    body_preview=$(echo "$issue_body" | head -c 500)
    analysis+="Description Preview:\n$body_preview\n"
    
    # Generate potential fix approaches based on issue type
    local approaches=""
    case "$issue_type" in
        "bug")
            approaches="1. Fix the bug directly in the code\n2. Add error handling and logging\n3. Write a test to prevent regression\n4. Update documentation about the fix"
            ;;
        "feature")
            approaches="1. Implement the feature as described\n2. Create a minimal viable implementation\n3. Add configuration options if needed\n4. Update documentation and examples"
            ;;
        "documentation")
            approaches="1. Update the README or docs\n2. Add code comments\n3. Create examples or tutorials\n4. Fix typos and improve clarity"
            ;;
        *)
            approaches="1. Analyze and implement the requested change\n2. Check for related issues\n3. Ensure backward compatibility\n4. Test thoroughly before deploying"
            ;;
    esac
    
    echo -e "$analysis"
    echo "=== POTENTIAL APPROACHES ==="
    echo -e "$approaches"
}

# Send Telegram message with multiple choice options
send_telegram_question() {
    local repo="$1"
    local issue_number="$2"
    local issue_title="$3"
    local analysis="$4"
    
    log "Sending Telegram message to Sky..."
    
    # Truncate analysis for Telegram (max 4096 chars)
    local truncated_analysis
    truncated_analysis=$(echo "$analysis" | head -c 3000)
    
    # Create message with multiple choice options
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

*Reply with the number (1-5) to choose.*"
    
    # Send message via OpenClaw
    echo "$message" | openclaw message send --channel telegram --to "$TELEGRAM_CHAT_ID" --message "$message" 2>/dev/null || error_exit "Failed to send Telegram message" "notify"
    
    log "Telegram message sent. Waiting for response..."
    
    # Store issue info for response handling
    local response_file="$WORKSPACE_DIR/memory/issue-fixer-waiting-$repo-$issue_number.json"
    cat > "$response_file" << EOF
{
    "repo": "$repo",
    "issue_number": "$issue_number",
    "issue_title": "$issue_title",
    "timestamp": "$(date -Iseconds)",
    "status": "waiting_for_response"
}
EOF
}

# Main execution
main() {
    log "=== Daily Issue Fixer Started ==="
    
    # Check prerequisites
    check_prerequisites
    
    # Find the oldest unaddressed issue
    local issue_info
    issue_info=$(find_oldest_schbz_issue)
    
    if [ -z "$issue_info" ]; then
        log "No issues to fix today. Exiting."
        # Send notification that no issues were found
        echo "No issues found" | openclaw message send --channel telegram --to "$TELEGRAM_CHAT_ID" --message "✅ No unaddressed issues by schbz found today. Check complete!" 2>/dev/null || true
        exit 0
    fi
    
    # Parse issue info
    IFS=',' read -r repo issue_number issue_title issue_url issue_date <<< "$issue_info"
    
    # Analyze the issue
    local analysis
    analysis=$(analyze_issue "$repo" "$issue_number" "$issue_title" "$issue_url")
    
    # Send Telegram message
    send_telegram_question "$repo" "$issue_number" "$issue_title" "$analysis"
    
    log "=== Daily Issue Fixer Completed Initial Phase ==="
    log "Issue queued for response: rexuvia/$repo#$issue_number"
    
    # Note: The actual fix execution will be handled by a separate process
    # that monitors Telegram responses and spawns the appropriate agent.
}

# Run main function
main "$@"