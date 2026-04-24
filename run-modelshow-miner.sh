#!/bin/bash
# Quick test script for modelshow-miner

echo "Starting modelshow-miner test..."
echo ""

# Use the phenosemantic-workspace location
PHENO_DIR="/home/ubuntu/.openclaw/workspace/phenosemantic-workspace/phenosemantic-py"
OUTPUT_DIR="$HOME/pheno-outputs"

echo "Checking phenosemantic-py at: $PHENO_DIR"
if [ ! -d "$PHENO_DIR" ]; then
    echo "ERROR: phenosemantic-py not found!"
    exit 1
fi

echo "Checking for lexasomes..."
if [ ! -f "$PHENO_DIR/lexasomes/modelshow_tasks.txt" ]; then
    echo "ERROR: modelshow_tasks.txt not found!"
    exit 1
fi

echo "All checks passed!"
echo ""
echo "To run the full mining, you would execute:"
echo "cd $PHENO_DIR"
echo "source .venv/bin/activate"
echo "phenosemantic --mine 20 \\"
echo "  --lexasome modelshow_tasks \\"
echo "  --lexasome modelshow_constraints \\"
echo "  --lexasome modelshow_domains \\"
echo "  --lexaplast modelshow_prompt \\"
echo "  --length 3 \\"
echo "  --delay 500 \\"
echo "  --incognito"
echo ""
echo "Output would go to: $OUTPUT_DIR/ModelshowPrompt/$(date +%Y-%m-%d).jsonl"

# Actually, let's try to run it
echo ""
echo "Attempting to run quick test (20 prompts)..."
cd "$PHENO_DIR"

# Check if venv exists
if [ ! -d ".venv" ]; then
    echo "Setting up virtual environment..."
    python3 -m venv .venv
    source .venv/bin/activate
    pip install -e .
else
    source .venv/bin/activate
fi

# Run the mining
phenosemantic --mine 20 \
  --lexasome modelshow_tasks \
  --lexasome modelshow_constraints \
  --lexasome modelshow_domains \
  --lexaplast modelshow_prompt \
  --length 3 \
  --delay 500 \
  --incognito

echo ""
echo "Done! Check output at: $OUTPUT_DIR/ModelshowPrompt/$(date +%Y-%m-%d).jsonl"