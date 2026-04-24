#!/bin/bash
cd /home/ubuntu/.openclaw/workspace/phenosemantic-workspace/phenosemantic-py
source .venv/bin/activate

echo "Testing mining with explicit parameters..."
echo ""

# Try with explicit lexaplast and letting it default lexasome
echo "Test 1: Default lexasome"
phenosemantic --mine 2 500 --lexaplast modelshow_prompt.json 2>&1 | tail -30

echo ""
echo "---"
echo ""

# Try with the combiner explicitly
echo "Test 2: With modelshow combiner"
phenosemantic --mine 2 500 --lexaplast modelshow_prompt.json --lexasome modelshow 2>&1 | tail -30