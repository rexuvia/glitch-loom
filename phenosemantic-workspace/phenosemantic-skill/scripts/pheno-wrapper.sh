#!/bin/bash
# Phenosemantic Skill Wrapper
# Handles all pheno commands for OpenClaw skill

set -e

# Load configuration
CONFIG_FILE="$(dirname "$0")/../config.json"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: config.json not found at $CONFIG_FILE"
    exit 1
fi

# Parse config (simplified)
PHENO_DIR=$(grep -o '"pheno_dir": "[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)
OUTPUT_DIR=$(grep -o '"output_dir": "[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)
LOG_DIR=$(grep -o '"log_dir": "[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)

# Defaults
QUICK_COUNT=20
STANDARD_COUNT=100
OVERNIGHT_COUNT=500
DEFAULT_DELAY=1000

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

# Mining command
cmd_mine() {
    local count=$STANDARD_COUNT
    local delay=$DEFAULT_DELAY
    local mode="standard"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --quick)
                count=$QUICK_COUNT
                delay=500
                mode="quick"
                shift
                ;;
            --overnight)
                count=$OVERNIGHT_COUNT
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
            --debug)
                set -x
                shift
                ;;
            *)
                error "Unknown flag: $1"
                return 1
                ;;
        esac
    done
    
    log "Starting $mode mining: $count outputs, ${delay}ms delay"
    
    # Use modelshow lexasomes/lexaplast by default
    run_pheno --mine "$count" "$delay" \
        --lexasome modelshow_tasks \
        --lexasome modelshow_constraints \
        --lexasome modelshow_domains \
        --lexaplast modelshow_prompt \
        --length 3 \
        --incognito
    
    success "Mining completed: $count outputs generated"
}

# Housekeeping command
cmd_housekeep() {
    local path=""
    local batch=false
    local auto=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --path)
                path="$2"
                shift 2
                ;;
            --batch)
                batch=true
                shift
                ;;
            --auto)
                auto=true
                shift
                ;;
            --verbose)
                set -x
                shift
                ;;
            *)
                error "Unknown flag: $1"
                return 1
                ;;
        esac
    done
    
    log "Starting housekeeping${path:+ for path: $path}"
    
    local args="--housekeeping"
    if [ -n "$path" ]; then
        args="$args $path"
    fi
    
    run_pheno $args
    
    success "Housekeeping completed"
}

# Create lexasome command
cmd_create_lexasome() {
    local name="$1"
    if [ -z "$name" ]; then
        error "Lexasome name required"
        return 1
    fi
    
    local template_file="$(dirname "$0")/../templates/lexasome.txt.template"
    local target_file="$PHENO_DIR/lexasomes/${name}.txt"
    
    if [ -f "$target_file" ]; then
        error "Lexasome already exists: $target_file"
        return 1
    fi
    
    if [ ! -f "$template_file" ]; then
        # Create basic template
        cat > "$target_file" << EOF
# ${name} Lexasome
# Add your sequons (one per line)

# Example sequons:
example_concept_1
example_concept_2
example_concept_3

# Add your sequons below:

EOF
    else
        cp "$template_file" "$target_file"
        sed -i "s/LEXASOME_NAME/$name/g" "$target_file"
    fi
    
    success "Created lexasome: $target_file"
    echo "Edit this file to add your sequons, then use with: pheno mine --lexasome $name"
}

# Create lexaplast command  
cmd_create_lexaplast() {
    local name="$1"
    if [ -z "$name" ]; then
        error "Lexaplast name required"
        return 1
    fi
    
    local template_file="$(dirname "$0")/../templates/lexaplast.json.template"
    local target_file="$PHENO_DIR/lexaplasts/${name}.json"
    
    if [ -f "$target_file" ]; then
        error "Lexaplast already exists: $target_file"
        return 1
    fi
    
    if [ ! -f "$template_file" ]; then
        # Create basic template
        cat > "$target_file" << EOF
{
  "name": "${name}",
  "description": "Custom lexaplast for generating outputs",
  "codon": {
    "lexasomes": [
      "default.txt",
      "default.txt"
    ],
    "n": 2
  },
  "prompt": "Combine these concepts: {{codon[0]}} and {{codon[1]}}. Create something interesting.",
  "model": "deepseek-chat",
  "temperature": 0.8,
  "max_tokens": 300
}
EOF
    else
        cp "$template_file" "$target_file"
        sed -i "s/LEXAPLAST_NAME/$name/g" "$target_file"
    fi
    
    success "Created lexaplast: $target_file"
    echo "Edit this JSON file to customize the template, then use with: pheno mine --lexaplast $name"
}

# List command
cmd_list() {
    local what="$1"
    
    case $what in
        lexasomes)
            log "Available lexasomes:"
            find "$PHENO_DIR/lexasomes" -name "*.txt" -o -name "*.csv" -o -name "*.json" | \
                xargs -I {} basename {} | sort
            ;;
        lexaplasts)
            log "Available lexaplasts:"
            find "$PHENO_DIR/lexaplasts" -name "*.json" | xargs -I {} basename {} .json | sort
            ;;
        outputs)
            log "Output directories:"
            find "$OUTPUT_DIR" -type d -maxdepth 2 | sort
            ;;
        templates)
            log "Available templates:"
            find "$(dirname "$0")/../templates" -name "*.template" | xargs -I {} basename {} .template | sort
            ;;
        *)
            error "Unknown list type: $what"
            echo "Available types: lexasomes, lexaplasts, outputs, templates"
            return 1
            ;;
    esac
}

# Stats command
cmd_stats() {
    local period="all"
    local json_output=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --today)
                period="today"
                shift
                ;;
            --week)
                period="week"
                shift
                ;;
            --month)
                period="month"
                shift
                ;;
            --json)
                json_output=true
                shift
                ;;
            *)
                error "Unknown flag: $1"
                return 1
                ;;
        esac
    done
    
    log "Statistics for period: $period"
    
    # Count output files
    local total_files=$(find "$OUTPUT_DIR" -type f -name "*.jsonl" | wc -l)
    local today_files=$(find "$OUTPUT_DIR" -type f -name "*.jsonl" -mtime 0 | wc -l)
    
    # Count lexasomes/lexaplasts
    local lexasome_count=$(find "$PHENO_DIR/lexasomes" -name "*.txt" -o -name "*.csv" -o -name "*.json" | wc -l)
    local lexaplast_count=$(find "$PHENO_DIR/lexaplasts" -name "*.json" | wc -l)
    
    if [ "$json_output" = true ]; then
        cat << EOF
{
  "period": "$period",
  "outputs": {
    "total": $total_files,
    "today": $today_files
  },
  "resources": {
    "lexasomes": $lexasome_count,
    "lexaplasts": $lexaplast_count
  },
  "paths": {
    "pheno_dir": "$PHENO_DIR",
    "output_dir": "$OUTPUT_DIR",
    "log_dir": "$LOG_DIR"
  }
}
EOF
    else
        echo "📊 Phenosemantic Statistics"
        echo "=========================="
        echo "Outputs:"
        echo "  Total files: $total_files"
        echo "  Today's files: $today_files"
        echo ""
        echo "Resources:"
        echo "  Lexasomes: $lexasome_count"
        echo "  Lexaplasts: $lexaplast_count"
        echo ""
        echo "Paths:"
        echo "  Pheno dir: $PHENO_DIR"
        echo "  Output dir: $OUTPUT_DIR"
        echo "  Log dir: $LOG_DIR"
    fi
}

# Config command
cmd_config() {
    local action="show"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --show)
                action="show"
                shift
                ;;
            --update)
                action="update"
                shift
                ;;
            --fix-paths)
                action="fix-paths"
                shift
                ;;
            *)
                error "Unknown flag: $1"
                return 1
                ;;
        esac
    done
    
    case $action in
        show)
            log "Current configuration:"
            echo "PHENO_DIR: $PHENO_DIR"
            echo "OUTPUT_DIR: $OUTPUT_DIR"
            echo "LOG_DIR: $LOG_DIR"
            echo "QUICK_COUNT: $QUICK_COUNT"
            echo "STANDARD_COUNT: $STANDARD_COUNT"
            echo "OVERNIGHT_COUNT: $OVERNIGHT_COUNT"
            echo "DEFAULT_DELAY: $DEFAULT_DELAY"
            ;;
        update)
            log "Updating configuration..."
            # In a real implementation, this would update config.json
            error "Configuration update not yet implemented"
            ;;
        fix-paths)
            log "Fixing paths..."
            mkdir -p "$OUTPUT_DIR"
            mkdir -p "$LOG_DIR"
            mkdir -p "$PHENO_DIR/lexasomes"
            mkdir -p "$PHENO_DIR/lexaplasts"
            success "Paths verified/created"
            ;;
    esac
}

# Help command
cmd_help() {
    local topic=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --full)
                cat "$(dirname "$0")/../SKILL.md"
                return 0
                ;;
            --examples)
                topic="examples"
                shift
                ;;
            --commands)
                topic="commands"
                shift
                ;;
            *)
                topic="$1"
                shift
                ;;
        esac
    done
    
    case $topic in
        examples)
            echo "Usage Examples:"
            echo "  pheno mine --quick"
            echo "  pheno mine --overnight"
            echo "  pheno housekeep"
            echo "  pheno create lexasome game_mechanics"
            echo "  pheno create lexaplast game_concept_generator"
            echo "  pheno list lexasomes"
            echo "  pheno stats --today"
            ;;
        commands)
            echo "Available Commands:"
            echo "  mine [--quick|--overnight|--count N|--delay MS]"
            echo "  housekeep [--path PATH|--batch|--auto]"
            echo "  create lexasome NAME"
            echo "  create lexaplast NAME"
            echo "  list [lexasomes|lexaplasts|outputs|templates]"
            echo "  stats [--today|--week|--month|--json]"
            echo "  config [--show|--update|--fix-paths]"
            echo "  help [--full|--examples|--commands]"
            ;;
        "")
            echo "Phenosemantic Skill - Quick Help"
            echo "Usage: pheno <command> [options]"
            echo ""
            echo "Basic commands:"
            echo "  mine      - Generate outputs"
            echo "  housekeep - Process unrated outputs"
            echo "  create    - Create new lexasomes/lexaplasts"
            echo "  list      - List available resources"
            echo "  stats     - Show statistics"
            echo "  config    - Manage configuration"
            echo "  help      - Show help"
            echo ""
            echo "For more details: pheno help --full"
            echo "For examples: pheno help --examples"
            ;;
        *)
            error "Unknown help topic: $topic"
            return 1
            ;;
    esac
}

# Main command router
main() {
    # Check environment first
    if ! check_environment; then
        error "Environment check failed"
        exit 1
    fi
    
    local command="$1"
    shift
    
    case $command in
        mine)
            cmd_mine "$@"
            ;;
        housekeep)
            cmd_housekeep "$@"
            ;;
        create)
            local subcommand="$1"
            shift
            case $subcommand in
                lexasome)
                    cmd_create_lexasome "$@"
                    ;;
                lexaplast)
                    cmd_create_lexaplast "$@"
                    ;;
                *)
                    error "Unknown create subcommand: $subcommand"
                    cmd_help
                    exit 1
                    ;;
            esac
            ;;
        list)
            cmd_list "$@"
            ;;
        stats)
            cmd_stats "$@"
            ;;
        config)
            cmd_config "$@"
            ;;
        help|--help|-h)
            cmd_help "$@"
            ;;
        "")
            cmd_help
            ;;
        *)
            error "Unknown command: $command"
            cmd_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"