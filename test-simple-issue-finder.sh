#!/bin/bash
# Simple test script to find oldest unaddressed issue

set -euo pipefail

WORKSPACE_DIR="/home/ubuntu/.openclaw/workspace"
ISSUE_CACHE="$WORKSPACE_DIR/memory/issue-fixer-cache.json"

echo "=== Simple Issue Finder Test ==="

# Load cache
if [ -f "$ISSUE_CACHE" ]; then
    echo "Cache file exists:"
    cat "$ISSUE_CACHE"
    echo ""
    
    # Try to read processed issues
    if jq -e '.processed_issues' "$ISSUE_CACHE" >/dev/null 2>&1; then
        echo "Successfully read processed_issues from cache"
        processed_issues=$(jq -r '.processed_issues[]' "$ISSUE_CACHE" 2>/dev/null || echo "")
        echo "Processed issues:"
        echo "$processed_issues"
    else
        echo "Could not read processed_issues from cache"
    fi
else
    echo "Cache file does not exist"
fi

# Test GitHub API
echo ""
echo "=== Testing GitHub API ==="

# Get list of rexuvia repos
repos=$(gh repo list rexuvia --json name --limit 5 | jq -r '.[].name')
echo "Found repos: $repos"

# Check each repo for issues by schbz
for repo in $repos; do
    echo ""
    echo "Checking repo: rexuvia/$repo"
    issues=$(gh issue list --repo "rexuvia/$repo" --author "schbz" --state open --json number,title,createdAt --limit 2 2>/dev/null || echo "[]")
    
    if [ "$issues" != "[]" ]; then
        echo "Found issues:"
        echo "$issues" | jq -r '.[] | "  #\(.number) - \(.title) (created: \(.createdAt))"'
    else
        echo "No issues found"
    fi
done