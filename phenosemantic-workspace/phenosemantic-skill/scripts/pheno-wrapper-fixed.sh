#!/bin/bash
# Fixed Phenosemantic Skill Wrapper
# Handles file extensions properly

set -e

# Load configuration
CONFIG_FILE="$(dirname "$0")/../config.json"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: config.json not found at $CONFIG_FILE"
    exit 1
fi

# Parse config (using jq if available, otherwise grep)
if command -v jq >/dev/null 2>&1; then
    PHENO_DIR=$(jq -r '.paths.pheno_dir' "$CONFIG_FILE")
    OUTPUT_DIR=$(jq -r '.paths.output_dir' "$CONFIG_FILE")
    LOG_DIR=$(jq -r '.paths.log_dir' "$CONFIG_FILE")
else
    PHENO_DIR=$(grep -o '"pheno_dir": "[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)
    OUTPUT_DIR=$(grep -o '"output_dir": "[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)
    LOG_DIR=$(grep -o '"log_dir": "[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)
fi

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Logging
log() {
    echo -e "${BLUE}[pheno]${NC} $1"
}

error() {
    echo -e "${RED}[pheno error]${NC} $1"
}

success() {
    echo -e "${GREEN}[pheno success]${NC} $1"
}

# Check if file exists with any extension
find_lexasome() {
    local name="$1"
    local dir="$PHENO_DIR/lexasomes"
    
    # Check without extension first (how CLI expects it)
    if [ -f "$dir/$name" ]; then
        echo "$name"
        return 0
    fi
    
    # Check with .txt extension
    if [ -f "$dir/$name.txt" ]; then
        echo "$name.txt"
        return 0
    fi
    
    # Check with .csv extension
    if [ -f "$dir/$name.csv" ]; then
        echo "$name.csv"
        return 0
    fi
    
    # Check with .json extension
    if [ -f "$dir/$name.json" ]; then
        echo "$name.json"
        return 0
    fi
    
    return 1
}

find_lexaplast() {
    local name="$1"
    local dir="$PHENO_DIR/lexaplasts"
    
    # Check without extension first
    if [ -f "$dir/$name" ]; then
        echo "$name"
        return 0
    fi
    
    # Check with .json extension
    if [ -f "$dir/$name.json" ]; then
        echo "$name.json"
        return 0
    fi
    
    return 1
}

# Check environment
check_environment() {
    if [ ! -d "$PHENO_DIR" ]; then
        error "Phenosemantic directory not found: $PHENO_DIR"
        return 1
    fi
    
    if [ ! -f "$PHENO_DIR/.venv/bin/activate" ]; then
        error "Virtual environment not found in $PHENO_DIR/.venv"
        return 1
    fi
    
    # Create output directories if needed
    mkdir -p "$OUTPUT_DIR"
    mkdir -p "$LOG_DIR"
    
    return 0
}

# Activate environment
activate_env() {
    source "$PHENO_DIR/.venv/bin/activate"
}

# Run phenosemantic command
run_pheno() {
    activate_env
    cd "$PHENO_DIR"
    
    # Set API keys from environment if available
    if [ -n "$DEEPSEEK_API_KEY" ]; then
        export DEEPSEEK_API_KEY
    fi
    if [ -n "$OPENAI_API_KEY" ]; then
        export OPENAI_API_KEY
    fi
    
    # Run the command
    phenosemantic "$@"
}

# Mining command with proper file handling
cmd_mine() {
    local count=100
    local delay=1000
    local lexasomes=()
    local lexaplast=""
    local mode="standard"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --quick)
                count=20
                delay=500
                mode="quick"
                shift
                ;;
            --overnight)
                count=500
                delay=2000
                mode="overnight"
                shift
                ;;
            --count)
                count="$2"
                shift 2
                ;;
            --delay)
                delay="$2"
                shift 2
                ;;
            --lexasome)
                # Find the actual file with extension
                local lex_name="$2"
                local found_file=$(find_lexasome "$lex_name")
                if [ $? -eq 0 ]; then
                    lexasomes+=("$found_file")
                else
                    error "Lexasome not found: $lex_name (checked with .txt, .csv, .json extensions)"
                    return 1
                fi
                shift 2
                ;;
            --lexaplast)
                local lexp_name="$2"
                local found_file=$(find_lexaplast "$lexp_name")
                if [ $? -eq 0 ]; then
                    lexaplast="$found_file"
                else
                    error "Lexaplast not found: $lexp_name (checked with .json extension)"
                    return 1
                fi
                shift 2
                ;;
            --debug)
                set -x
                shift
                ;;
            *)
                # Default: use funny poem generator
                if [ -z "$lexaplast" ]; then
                    lexaplast="funny_poem_generator.json"
                fi
                shift
                ;;
        esac
    done
    
    # Default to funny poem generator if none specified
    if [ -z "$lexaplast" ]; then
        lexaplast="funny_poem_generator.json"
        log "Using default lexaplast: $lexaplast"
    fi
    
    # Default lexasomes for poem generator
    if [ ${#lexasomes[@]} -eq 0 ] && [ "$lexaplast" = "funny_poem_generator.json" ]; then
        lexasomes=("poem_subjects.txt" "poem_styles.txt")
        log "Using default lexasomes for poem generator"
    fi
    
    log "Starting $mode mining: $count outputs, ${delay}ms delay"
    log "Lexaplast: $lexaplast"
    log "Lexasomes: ${lexasomes[*]}"
    
    # Build command
    local cmd="--mine $count $delay --incognito"
    
    # Add lexaplast
    cmd="$cmd --lexaplast $lexaplast"
    
    # Add lexasomes
    for lex in "${lexasomes[@]}"; do
        cmd="$cmd --lexasome $lex"
    done
    
    # Add length (number of sequons per codon)
    if [ "$lexaplast" = "funny_poem_generator.json" ]; then
        cmd="$cmd --length 2"
    else
        cmd="$cmd --length 3"
    fi
    
    log "Running: phenosemantic $cmd"
    
    # Run the command
    run_pheno $cmd
    
    success "Mining completed: $count outputs generated"
}

# Simple test command
cmd_test() {
    log "Testing phenosemantic installation..."
    
    # Check environment
    if ! check_environment; then
        error "Environment check failed"
        return 1
    fi
    
    # Test basic functionality
    activate_env
    cd "$PHENO_DIR"
    
    echo "1. Testing virtual environment..."
    python3 -c "import phenosemantic; print('✅ Phenosemantic module imported')"
    
    echo "2. Testing config loading..."
    python3 -c "
from phenosemantic import config
print('✅ Config loaded')
print('   DEEPSEEK_API_KEY:', '✅ Set' if config.DEEPSEEK_API_KEY else '❌ Not set')
print('   API_PROVIDER_ORDER:', config.API_PROVIDER_ORDER)
"
    
    echo "3. Testing file discovery..."
    echo "   Lexasomes directory: $PHENO_DIR/lexasomes/"
    ls "$PHENO_DIR/lexasomes/" | head -5 | while read f; do echo "   - $f"; done
    
    echo "4. Testing lexaplasts directory: $PHENO_DIR/lexaplasts/"
    ls "$PHENO_DIR/lexaplasts/" | head -5 | while read f; do echo "   - $f"; done
    
    success "Basic tests passed"
    echo ""
    echo "To run actual API test, use:"
    echo "  pheno mine --quick"
    echo "  pheno mine --count 3 --lexaplast funny_poem_generator.json"
}

# Main command router
main() {
    local command="$1"
    shift
    
    case $command in
        mine)
            cmd_mine "$@"
            ;;
        test)
            cmd_test "$@"
            ;;
        help|--help|-h)
            echo "Phenosemantic Skill - Fixed Wrapper"
            echo "Usage: pheno <command> [options]"
            echo ""
            echo "Commands:"
            echo "  mine [--quick|--overnight|--count N|--delay MS|--lexaplast NAME|--lexasome NAME]"
            echo "  test - Run basic tests"
            echo "  help - Show this help"
            echo ""
            echo "Examples:"
            echo "  pheno mine --quick"
            echo "  pheno mine --count 5 --lexaplast funny_poem_generator.json"
            echo "  pheno test"
            ;;
        "")
            echo "Phenosemantic Skill"
            echo "Use: pheno help for commands"
            ;;
        *)
            error "Unknown command: $command"
            echo "Use: pheno help"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"