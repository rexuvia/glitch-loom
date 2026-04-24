# Phenosemantic Skill

A comprehensive skill for working with the phenosemantic-py platform within OpenClaw. Handles mining, housekeeping, lexasome/lexaplast creation, and integration with Rexuvia's workflows.

## Quick Reference

**Keyword:** `pheno` (triggers this skill)

**Commands:**
- `pheno mine [count] [delay]` - Mine outputs with optional count/delay
- `pheno housekeep` - Process unrated outputs
- `pheno create lexasome <name>` - Create a new lexasome
- `pheno create lexaplast <name>` - Create a new lexaplast
- `pheno list` - List available lexasomes/lexaplasts
- `pheno stats` - Show mining statistics
- `pheno config` - Show/update configuration
- `pheno help` - Show this help

## Installation

1. Copy this skill to OpenClaw skills directory:
   ```bash
   cp -r phenosemantic-skill ~/.openclaw/skills/
   ```

2. Ensure phenosemantic-py is installed and configured:
   ```bash
   cd ~/.openclaw/workspace/phenosemantic-py
   python3 -m venv .venv
   source .venv/bin/activate
   pip install -e .
   ```

3. Configure API keys in `config.ini` or environment variables.

## Configuration

Default paths (customize in `config.json`):
- `pheno_dir`: `/home/ubuntu/.openclaw/workspace/phenosemantic-py`
- `output_dir`: `/home/ubuntu/pheno-outputs`
- `workspace_dir`: `/home/ubuntu/.openclaw/workspace/phenosemantic-workspace`

## Usage Examples

### Mining Operations
```bash
# Quick test (20 outputs)
pheno mine --quick

# Standard mining (100 outputs)
pheno mine

# Overnight mining (500 outputs)
pheno mine --overnight

# Custom mining
pheno mine --count 50 --delay 2000
```

### Housekeeping
```bash
# Process unrated outputs
pheno housekeep

# Housekeep specific directory
pheno housekeep --path /custom/outputs
```

### Lexasome Management
```bash
# List lexasomes
pheno list lexasomes

# Create new lexasome
pheno create lexasome game_mechanics

# Add sequons to lexasome
pheno add sequon "emergent behavior" --lexasome game_mechanics
```

### Lexaplast Management
```bash
# List lexaplasts
pheno list lexaplasts

# Create new lexaplast
pheno create lexaplast game_concept_generator

# Test lexaplast
pheno test lexaplast game_concept_generator --count 3
```

## Integration with Rexuvia Workflows

### Daily Game Pipeline Integration
The skill supports integration with Rexuvia's daily game generation:

1. **Phase 0 (Overnight Mining):**
   ```bash
   pheno mine --overnight --lexaplast game_concepts
   ```

2. **Phase 1 (Curated Ideation):**
   ```bash
   pheno housekeep --rating 7+
   # Feed high-rated concepts to multi-agent swarm
   ```

3. **Feedback Loop:**
   - High-rated outputs become new sequons
   - Failed concepts inform constraint refinement
   - Continuous improvement of lexasomes/lexaplasts

### Automated Workflows
Set up cron jobs for:
- **Nightly mining**: `0 2 * * * pheno mine --overnight`
- **Daily housekeeping**: `0 9 * * * pheno housekeep`
- **Weekly lexasome updates**: `0 0 * * 0 pheno update lexasomes`

## File Structure

```
phenosemantic-skill/
├── SKILL.md              # This file
├── config.json           # Skill configuration
├── scripts/
│   ├── mine.sh          # Mining wrapper
│   ├── housekeep.sh     # Housekeeping wrapper
│   ├── create_lexasome.py
│   └── create_lexaplast.py
├── templates/
│   ├── lexasome.txt.template
│   └── lexaplast.json.template
└── examples/
    ├── game_mechanics.txt
    └── game_concept_generator.json
```

## Lexasome Types

The skill supports three lexasome formats:

1. **Plain Text (.txt)** - Simple list of sequons
2. **Weighted CSV (.csv)** - Sequons with probability weights
3. **JSON Combiner (.json)** - Combine multiple lexasomes with rules

## Lexaplast Templates

Common lexaplast types:
- **Concept Generators** - Combine abstract ideas
- **Prompt Templates** - Generate LLM prompts
- **Analysis Frameworks** - Structured thinking templates
- **Creative Constraints** - Force novel combinations

## Troubleshooting

### Common Issues

1. **API Key Errors:**
   - Check `config.ini` has correct keys
   - Ensure environment variables are set
   - Run `pheno config` to verify

2. **CLI Interactive Mode:**
   - The skill uses non-interactive wrappers
   - Set `--incognito` flag for batch operations
   - Use environment variables for API keys

3. **Output Directory Issues:**
   - Ensure output directory exists
   - Check permissions
   - Run `pheno config --fix-paths`

### Debug Mode
```bash
pheno mine --debug
pheno housekeep --verbose
```

## Development

### Adding New Commands
1. Add command to `SKILL.md` documentation
2. Create script in `scripts/` directory
3. Update command routing in skill logic
4. Test with `pheno <command> --test`

### Custom Templates
Place custom templates in `templates/custom/`:
- `lexasome_<type>.txt.template`
- `lexaplast_<type>.json.template`

## Performance Tips

1. **Batch Operations:** Use `--batch` flag for large operations
2. **Caching:** Enable SQLite logging for performance tracking
3. **Parallel Processing:** Use `--workers N` for concurrent API calls
4. **Rate Limiting:** Adjust `--delay` based on API limits

## Security Notes

- API keys stored in `config.ini` (not in skill files)
- Output directories outside workspace for isolation
- No sensitive data in lexasomes/lexaplasts
- Regular cleanup of temporary files

## Support

- Check `pheno help` for command reference
- View logs in `~/mining-logs/`
- Report issues to skill maintainer
- Contribute improvements via GitHub