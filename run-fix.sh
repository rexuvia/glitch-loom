#!/bin/bash
export GH_TOKEN=$(gh auth token)
export REPO="melody-explorer"
export ISSUE="2"

# Update cache to mark this issue as processed
jq '.processed_issues += ["'"$REPO#$ISSUE"'"] | .last_processed = "'"$(date -u +"%Y-%m-%dT%H:%M:%SZ")"'"' memory/issue-fixer-cache.json > temp.json && mv temp.json memory/issue-fixer-cache.json

# Remove the waiting file
rm -f memory/issue-fixer-waiting-melody-explorer-2.json
