#!/bin/bash
# MSPP Keyword Approval Helper
# This script implements the keyword approval workflow for MSPP publishing

set -euo pipefail

WORKSPACE_DIR="/home/ubuntu/.openclaw/workspace"
PRIVATE_DIR="$WORKSPACE_DIR/modelshow-private"
PUBLISHED_DIR="$WORKSPACE_DIR/modelshow-published"

# Function to generate keywords using LLM
generate_keywords() {
    local result_id="$1"
    local json_file="$PRIVATE_DIR/$result_id.json"
    
    # Extract prompt
    local prompt
    prompt=$(jq -r '.meta.prompt' "$json_file" 2>/dev/null || jq -r '.prompt' "$json_file" 2>/dev/null)
    
    # Extract top results for context
    local top_results
    top_results=$(jq -r '.results[0:3] | .[] | "\(.model_alias): \(.response)"' "$json_file" 2>/dev/null | head -3)
    
    # Create keyword generation task
    cat << EOF
Generate 3-4 relevant keywords for this ModelShow result:

Prompt: "$prompt"

Top results:
$top_results

Key considerations:
1. Focus on content-specific terms (not generic "AI comparison" or "model evaluation")
2. Consider the subject matter, response format, and unique aspects
3. Make keywords useful for categorization and discovery
4. Return only keywords as a comma-separated list

Examples of good keywords:
- For simulation theory prompt: "simulation theory, instruction following, philosophical probability"
- For ethical dilemma: "trolley problem, temporal ethics, resource allocation"
- For technical question: "cryptography, prime numbers, internet security"

Return only the keywords as a comma-separated list.
EOF
}

# Function to publish with approved keywords
publish_with_keywords() {
    local result_id="$1"
    local keywords="$2"
    
    echo "Publishing $result_id with keywords: $keywords"
    
    # Convert comma-separated keywords to JSON array
    local keywords_json
    keywords_json=$(echo "$keywords" | jq -R 'split(", ") | map(select(. != ""))')
    
    # Update JSON with keywords
    jq --argjson keywords "$keywords_json" '.meta.keywords = $keywords' \
        "$PRIVATE_DIR/$result_id.json" > "$PRIVATE_DIR/$result_id.json.tmp"
    mv "$PRIVATE_DIR/$result_id.json.tmp" "$PRIVATE_DIR/$result_id.json"
    
    # Copy to published directory
    cp "$PRIVATE_DIR/$result_id.json" "$PUBLISHED_DIR/"
    cp "$PRIVATE_DIR/$result_id.md" "$PUBLISHED_DIR/" 2>/dev/null || true
    
    echo "✅ Result prepared for publishing with keywords"
}

# Main execution
if [ $# -lt 1 ]; then
    echo "Usage: $0 <result_id>"
    exit 1
fi

RESULT_ID="$1"

# Check if result exists
if [ ! -f "$PRIVATE_DIR/$RESULT_ID.json" ]; then
    echo "Error: Result $RESULT_ID not found in $PRIVATE_DIR"
    exit 1
fi

# Generate initial keywords
echo "Generating suggested keywords for $RESULT_ID..."
KEYWORD_TASK=$(generate_keywords "$RESULT_ID")

# In a real implementation, this would spawn an LLM subagent
# For now, just output the task
echo "=== KEYWORD GENERATION TASK ==="
echo "$KEYWORD_TASK"
echo "=== END TASK ==="

echo ""
echo "In the actual implementation, this would:"
echo "1. Spawn LLM subagent to generate keywords"
echo "2. Present keywords to user for approval"
echo "3. Handle user response (approve/edit/regenerate/cancel)"
echo "4. Publish with approved keywords"