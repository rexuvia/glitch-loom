#!/bin/bash

# Test script for Phenosemantic Agentic Skill - Basic Flow
# Demonstrates Phase 1 core functionality

echo "========================================="
echo "Phenosemantic Agentic Skill - Test Flow"
echo "Phase 1: Core Infrastructure"
echo "========================================="

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}[1/5] Checking directory structure...${NC}"
if [ -d "lexasomes" ] && [ -d "lexaplasts" ] && [ -d "agents" ]; then
    echo -e "${GREEN}✓ Directory structure exists${NC}"
else
    echo -e "${YELLOW}✗ Missing directories${NC}"
    exit 1
fi

echo -e "${BLUE}[2/5] Checking lexasome files...${NC}"
LEXASOME_FILES=(
    "lexasomes/domains/technology.txt"
    "lexasomes/domains/creative.txt"
    "lexasomes/tasks/analysis.txt"
    "lexasomes/tasks/generation.txt"
    "lexasomes/constraints/style.csv"
    "lexasomes/constraints/format.csv"
    "lexasomes/models/models.json"
)

for file in "${LEXASOME_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}  ✓ $file${NC}"
    else
        echo -e "${YELLOW}  ✗ Missing: $file${NC}"
    fi
done

echo -e "${BLUE}[3/5] Checking lexaplast templates...${NC}"
if [ -f "lexaplasts/basic-analysis.json" ]; then
    echo -e "${GREEN}  ✓ basic-analysis.json${NC}"
    # Show template structure
    echo "  Template preview:"
    jq -r '.name, .description, ""' lexaplasts/basic-analysis.json 2>/dev/null || \
        echo "  (install jq for better preview)"
else
    echo -e "${YELLOW}  ✗ Missing basic-analysis.json${NC}"
fi

if [ -f "lexaplasts/multi-model-debate.json" ]; then
    echo -e "${GREEN}  ✓ multi-model-debate.json${NC}"
else
    echo -e "${YELLOW}  ✗ Missing multi-model-debate.json${NC}"
fi

echo -e "${BLUE}[4/5] Checking agent documentation...${NC}"
if [ -f "agents/sequon-selector.md" ] && [ -f "agents/template-filler.md" ]; then
    echo -e "${GREEN}  ✓ Agent docs exist${NC}"
else
    echo -e "${YELLOW}  ✗ Missing agent docs${NC}"
fi

echo -e "${BLUE}[5/5] Sample data demonstration...${NC}"
echo ""
echo "Sample lexasome contents:"
echo "-------------------------"

# Show sample from technology domains
echo "Technology domains (first 5):"
head -5 lexasomes/domains/technology.txt
echo ""

# Show sample from analysis tasks
echo "Analysis tasks (first 5):"
head -5 lexasomes/tasks/analysis.txt
echo ""

# Show constraints
echo "Style constraints:"
cat lexasomes/constraints/style.csv
echo ""

echo "========================================="
echo "Test Complete"
echo ""
echo "Next steps for implementation:"
echo "1. Implement sequon-selector agent logic"
echo "2. Implement template-filler agent logic"
echo "3. Create generation agent"
echo "4. Add auto-ranking logic"
echo "5. Test end-to-end flow"
echo "========================================="

# Create a simple Python script to demonstrate the concept
cat > /tmp/pheno-demo.py << 'EOF'
#!/usr/bin/env python3
"""
Simple demonstration of phenosemantic concept
"""

import random
import json
import csv

def select_from_txt(filepath, count=1):
    """Select random lines from a text file"""
    with open(filepath, 'r') as f:
        lines = [line.strip() for line in f if line.strip()]
    return random.sample(lines, min(count, len(lines)))

def select_from_csv(filepath, count=1):
    """Weighted selection from CSV"""
    sequons = []
    weights = []
    with open(filepath, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            sequons.append(row['constraint'])
            weights.append(float(row['weight']))
    return random.choices(sequons, weights=weights, k=count)

def demonstrate_selection():
    """Demonstrate sequon selection"""
    print("\n=== Demonstration: Sequon Selection ===")
    
    # Select a domain
    domain = select_from_txt("lexasomes/domains/technology.txt", 1)[0]
    print(f"Selected domain: {domain}")
    
    # Select a task
    task = select_from_txt("lexasomes/tasks/analysis.txt", 1)[0]
    print(f"Selected task: {task}")
    
    # Select a constraint
    constraint = select_from_csv("lexasomes/constraints/style.csv", 1)[0]
    print(f"Selected constraint: {constraint}")
    
    # Create simple prompt
    prompt = f"Perform {task} on {domain} with {constraint} style."
    print(f"\nGenerated prompt:\n{prompt}")
    
    return {
        "domain": domain,
        "task": task,
        "constraint": constraint,
        "prompt": prompt
    }

if __name__ == "__main__":
    print("Phenosemantic Agentic Skill - Concept Demo")
    print("=" * 50)
    result = demonstrate_selection()
    
    print("\n=== JSON Output ===")
    print(json.dumps(result, indent=2))
EOF

echo ""
echo "Concept demonstration script created at: /tmp/pheno-demo.py"
echo "Run with: python3 /tmp/pheno-demo.py"
echo ""
echo "Note: This is a conceptual demo. Full agent implementation"
echo "will use OpenClaw's native agent orchestration capabilities."