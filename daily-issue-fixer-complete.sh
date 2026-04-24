#!/bin/bash
# Complete Daily Issue Fixer
# This is the main entry point that should be called by the cron job.
# It handles the entire workflow: find issue, ask, wait for response, and execute.

set -euo pipefail

WORKSPACE_DIR="/home/ubuntu/.openclaw/workspace"
SCRIPT_DIR="$WORKSPACE_DIR"
LOG_FILE="$WORKSPACE_DIR/memory/daily-issue-fixer-$(date +%Y-%m-%d).log"

# Make scripts executable
chmod +x "$SCRIPT_DIR/daily-issue-fixer.sh" 2>/dev/null || true
chmod +x "$SCRIPT_DIR/issue-fixer-response-handler.sh" 2>/dev/null || true

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Check if we're waiting for a response from a previous run
check_pending_responses() {
    log "Checking for pending responses..."
    
    local waiting_files
    waiting_files=$(find "$WORKSPACE_DIR/memory" -name "issue-fixer-waiting-*.json" -type f 2>/dev/null || echo "")
    
    if [ -n "$waiting_files" ]; then
        log "Found pending responses. Skipping new issue search today."
        
        # Count how many days old each waiting file is
        for file in $waiting_files; do
            local timestamp
            timestamp=$(jq -r '.timestamp' "$file" 2>/dev/null || echo "")
            if [ -n "$timestamp" ]; then
                local file_age_days
                file_age_days=$(( ($(date +%s) - $(date -d "$timestamp" +%s)) / 86400 ))
                
                if [ "$file_age_days" -ge 2 ]; then
                    log "Removing stale waiting file (${file_age_days} days old): $(basename "$file")"
                    rm -f "$file"
                else
                    log "Still waiting for response for: $(basename "$file") (${file_age_days} days)"
                fi
            fi
        done
        
        # If we have any non-stale waiting files, exit
        local current_waiting_files
        current_waiting_files=$(find "$WORKSPACE_DIR/memory" -name "issue-fixer-waiting-*.json" -type f 2>/dev/null | wc -l)
        
        if [ "$current_waiting_files" -gt 0 ]; then
            log "Still waiting for response on $current_waiting_files issue(s). Exiting."
            exit 0
        fi
    fi
    
    log "No pending responses found."
}

# Main execution
main() {
    log "=== Daily Issue Fixer Complete Workflow Started ==="
    
    # Check for pending responses first
    check_pending_responses
    
    # Run the issue finder
    log "Running issue finder..."
    "$SCRIPT_DIR/daily-issue-fixer.sh"
    
    log "=== Daily Issue Fixer Complete Workflow Finished ==="
}

# Run main function
main "$@"