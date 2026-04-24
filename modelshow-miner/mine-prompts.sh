#!/bin/bash
# Modelshow Prompt Miner - Easy wrapper for phenosemantic mining

set -e

# Configuration
PHENO_DIR="/home/ubuntu/.openclaw/workspace/phenosemantic-workspace/phenosemantic-py"
OUTPUT_DIR="$HOME/pheno-outputs"
LOG_DIR="$HOME/mining-logs"

# Defaults
COUNT=100
DELAY=1000
TEMP_MODE="fixed"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

usage() {
    cat << EOF
${GREEN}Modelshow Prompt Miner${NC}

Usage: $0 [OPTIONS]

Options:
    -n, --count NUM       Number of prompts to generate (default: 100)
    -d, --delay MS        Delay between API calls in ms (default: 1000)
    -r, --random-temp     Use random temperature variation
    -q, --quick          Quick mode: 20 prompts, no delay
    -o, --overnight      Overnight mode: 500 prompts, 2s delay
    -h, --help           Show this help message

Examples:
    # Generate 100 prompts (standard)
    $0

    # Quick test (20 prompts)
    $0 --quick

    # Overnight mining (500 prompts)
    $0 --overnight

    # Custom count with random temperature
    $0 -n 200 -r

Output Location:
    $OUTPUT_DIR/ModelshowPrompt/$(date +%Y-%m-%d).jsonl

Log Location:
    $LOG_DIR/modelshow-$(date +%Y-%m-%d).log
EOF
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--count)
            COUNT="$2"
            shift 2
            ;;
        -d|--delay)
            DELAY="$2"
            shift 2
            ;;
        -r|--random-temp)
            TEMP_MODE="random"
            shift
            ;;
        -q|--quick)
            COUNT=20
            DELAY=500
            shift
            ;;
        -o|--overnight)
            COUNT=500
            DELAY=2000
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# Setup
mkdir -p "$LOG_DIR"
DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
LOG_FILE="$LOG_DIR/modelshow-$TIMESTAMP.log"

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Modelshow Prompt Miner Starting     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Configuration:${NC}"
echo "  Prompts to generate: $COUNT"
echo "  Delay between calls: ${DELAY}ms"
echo "  Temperature mode: $TEMP_MODE"
echo "  Output: $OUTPUT_DIR/ModelshowPrompt/$DATE.jsonl"
echo "  Log: $LOG_FILE"
echo ""

# Check phenosemantic installation
if [ ! -d "$PHENO_DIR" ]; then
    echo -e "${YELLOW}Error: phenosemantic-py not found at $PHENO_DIR${NC}"
    exit 1
fi

# Activate venv
cd "$PHENO_DIR"
if [ ! -d ".venv" ]; then
    echo -e "${YELLOW}Setting up phenosemantic virtual environment...${NC}"
    python3 -m venv .venv
    source .venv/bin/activate
    pip install -e . >> "$LOG_FILE" 2>&1
else
    source .venv/bin/activate
fi

# Build command
CMD="phenosemantic --mine $COUNT $DELAY \
  --lexasome modelshow \
  --lexaplast modelshow_prompt.json"

if [ "$TEMP_MODE" = "random" ]; then
    CMD="$CMD --random-temp"
fi

echo -e "${GREEN}Running mining operation...${NC}"
echo "Command: $CMD" >> "$LOG_FILE"
echo "Started: $(date)" >> "$LOG_FILE"
echo ""

# Run mining
eval $CMD >> "$LOG_FILE" 2>&1

EXIT_CODE=$?

echo "Completed: $(date)" >> "$LOG_FILE"
echo "Exit code: $EXIT_CODE" >> "$LOG_FILE"

if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✓ Mining complete!${NC}"
    echo ""
    
    # Show output location
    OUTPUT_FILE="$OUTPUT_DIR/ModelshowPrompt/$DATE.jsonl"
    if [ -f "$OUTPUT_FILE" ]; then
        LINES=$(wc -l < "$OUTPUT_FILE")
        echo -e "${YELLOW}Results:${NC}"
        echo "  Generated: $LINES prompts"
        echo "  File: $OUTPUT_FILE"
        echo ""
        echo -e "${BLUE}Next steps:${NC}"
        echo "  1. Review prompts: less $OUTPUT_FILE"
        echo "  2. Extract text: jq -r '.text' $OUTPUT_FILE > prompts.txt"
        echo "  3. Test with modelshow: mdls \"\$(head -1 prompts.txt)\""
    fi
else
    echo -e "${YELLOW}✗ Mining failed (exit code: $EXIT_CODE)${NC}"
    echo "Check log: $LOG_FILE"
    exit $EXIT_CODE
fi
