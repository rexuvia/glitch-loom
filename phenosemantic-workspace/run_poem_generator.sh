#!/bin/bash
# Run the funny poem generator
# This script handles everything

echo "🎭 Starting Funny Poem Generator"
echo "================================"

# Navigate to workspace
cd /home/ubuntu/.openclaw/workspace/phenosemantic-workspace/phenosemantic-py

echo "1. Checking virtual environment..."
if [ ! -f ".venv/bin/activate" ]; then
    echo "   ❌ Virtual environment not found"
    echo "   Creating virtual environment..."
    python3 -m venv .venv
fi

echo "2. Activating virtual environment..."
source .venv/bin/activate

echo "3. Installing phenosemantic if needed..."
pip install -e . > /dev/null 2>&1

echo "4. Checking configuration..."
if [ ! -f "config.ini" ]; then
    echo "   ❌ config.ini not found"
    exit 1
else
    echo "   ✅ config.ini found"
fi

echo "5. Checking poem resources..."
if [ ! -f "lexaplasts/funny_poem_generator.json" ]; then
    echo "   ❌ Poem generator not found"
    exit 1
else
    echo "   ✅ Poem generator found"
fi

echo ""
echo "🚀 GENERATING 3 FUNNY POEMS..."
echo "================================"

# Run the poem generator
phenosemantic --mine 3 1000 --lexaplast funny_poem_generator.json --incognito

echo ""
echo "📁 Checking output..."
if [ -d "/home/ubuntu/pheno-outputs" ]; then
    echo "   Output directory: /home/ubuntu/pheno-outputs/"
    find /home/ubuntu/pheno-outputs -name "*.jsonl" -type f 2>/dev/null | head -5 | while read f; do
        echo "   - $(basename "$f")"
    done
else
    echo "   No output directory created yet"
fi

echo ""
echo "🎉 Done! Check above for poem output."
echo ""
echo "To view generated poems:"
echo "find /home/ubuntu/pheno-outputs -name \"*.jsonl\" -exec cat {} \; 2>/dev/null | grep -A5 \"content\""