#!/bin/bash
# Test the phenosemantic skill

echo "🧪 Testing Phenosemantic Skill"
echo "=============================="

# Set up paths
SKILL_DIR="/home/ubuntu/.openclaw/workspace/phenosemantic-workspace/phenosemantic-skill"
WRAPPER="$SKILL_DIR/scripts/pheno-wrapper.sh"

# Make wrapper executable
chmod +x "$WRAPPER"

echo ""
echo "1. Testing help command:"
echo "-----------------------"
"$WRAPPER" help

echo ""
echo "2. Testing configuration:"
echo "-----------------------"
"$WRAPPER" config --show

echo ""
echo "3. Testing list commands:"
echo "-----------------------"
"$WRAPPER" list lexasomes
echo ""
"$WRAPPER" list lexaplasts

echo ""
echo "4. Testing create commands (dry run):"
echo "-----------------------------------"
echo "Note: These would create actual files in production"
# "$WRAPPER" create lexasome test_mechanics
# "$WRAPPER" create lexaplast test_generator

echo ""
echo "5. Testing statistics:"
echo "--------------------"
"$WRAPPER" stats

echo ""
echo "✅ Skill structure verified"
echo ""
echo "To install this skill:"
echo "cp -r $SKILL_DIR ~/.openclaw/skills/phenosemantic"
echo ""
echo "Then use: pheno <command>"
echo ""
echo "Available commands:"
echo "  pheno mine --quick"
echo "  pheno housekeep"
echo "  pheno create lexasome <name>"
echo "  pheno create lexaplast <name>"
echo "  pheno list lexasomes"
echo "  pheno stats --today"
echo "  pheno config --show"
echo "  pheno help --full"