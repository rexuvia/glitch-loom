#!/bin/bash
# Direct ModelShow execution script
# Usage: bash run_modelshow.sh "your query here"

QUERY="$1"

if [ -z "$QUERY" ]; then
    echo "Error: No query provided"
    echo "Usage: bash run_modelshow.sh \"your query here\""
    exit 1
fi

# Load config
CONFIG_FILE="$HOME/.openclaw/skills/modelshow/config.json"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file not found: $CONFIG_FILE"
    exit 1
fi

# Extract config values
MODELS=$(cat "$CONFIG_FILE" | python3 -c "import sys, json; print(' '.join(json.load(sys.stdin)['models']))")
JUDGE_MODEL=$(cat "$CONFIG_FILE" | python3 -c "import sys, json; print(json.load(sys.stdin)['judgeModel'])")
OUTPUT_DIR=$(cat "$CONFIG_FILE" | python3 -c "import sys, json; print(json.load(sys.stdin)['outputDir'])" | sed "s|~|$HOME|")

echo "🔄 ModelShow comparison starting..."
echo "📝 Query: $QUERY"
echo "🤖 Models: $MODELS"
echo "⚖️ Judge: $JUDGE_MODEL"
echo ""
echo "This will spawn sub-agents and execute the full workflow."
echo "Results will be saved to: $OUTPUT_DIR"
echo ""
echo "⚠️ Note: This script provides a template. Full implementation requires:"
echo "   1. Sub-agent spawning logic (sessions_spawn tool)"
echo "   2. Response collection"
echo "   3. Anonymization (judge_pipeline.py)"
echo "   4. Judge execution"
echo "   5. De-anonymization"
echo "   6. Save via save_results.py"
echo ""
echo "For now, please trigger via: mdls $QUERY"
