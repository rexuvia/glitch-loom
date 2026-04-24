# Phenosemantic Skill for OpenClaw

A comprehensive skill for working with the phenosemantic-py platform, enabling automated mining, housekeeping, and creative generation through lexasomes and lexaplasts.

## Features

- **Automated Mining**: Generate creative outputs at scale
- **Housekeeping**: Process and rate generated outputs
- **Lexasome Management**: Create and manage input sources
- **Lexaplast Management**: Design output templates
- **Statistics**: Track generation metrics
- **Integration**: Works with Rexuvia's daily game pipeline

## Installation

1. Copy to OpenClaw skills directory:
   ```bash
   cp -r phenosemantic-skill ~/.openclaw/skills/
   ```

2. Ensure phenosemantic-py is installed:
   ```bash
   cd ~/.openclaw/workspace/phenosemantic-py
   python3 -m venv .venv
   source .venv/bin/activate
   pip install -e .
   ```

3. Configure API keys in `config.ini` or environment variables.

## Quick Start

```bash
# Test the skill
pheno help

# Quick mining test
pheno mine --quick

# Create a lexasome
pheno create lexasome my_concepts

# Create a lexaplast  
pheno create lexaplast my_generator

# List available resources
pheno list lexasomes
pheno list lexaplasts

# Check statistics
pheno stats --today
```

## Usage Examples

### Daily Mining Routine
```bash
# Morning: Quick test mining
pheno mine --quick

# Afternoon: Standard mining session
pheno mine --count 100 --delay 1500

# Evening: Housekeeping
pheno housekeep --auto

# Overnight: Large-scale mining
pheno mine --overnight
```

### Game Concept Generation
```bash
# Create game-focused lexasomes
pheno create lexasome game_mechanics
pheno create lexasome game_themes
pheno create lexasome visual_styles

# Create game concept generator
pheno create lexaplast game_concept_generator

# Mine game concepts
pheno mine --count 50 --lexaplast game_concept_generator
```

### Integration with Cron
```bash
# Add to crontab for automated workflow
0 2 * * * /path/to/pheno mine --overnight
0 9 * * * /path/to/pheno housekeep --auto
0 18 * * * /path/to/pheno stats --today --json >> /path/to/logs/stats.json
```

## File Structure

```
phenosemantic-skill/
├── SKILL.md              # Complete documentation
├── config.json           # Skill configuration
├── README.md            # This file
├── scripts/
│   └── pheno-wrapper.sh # Main command handler
├── templates/
│   ├── lexasome.txt.template
│   └── lexaplast.json.template
└── examples/
    ├── game_mechanics.txt
    └── game_concept_generator.json
```

## Configuration

Edit `config.json` to customize:
- Paths to phenosemantic-py and output directories
- Default mining parameters
- Lexasome categories and lexaplast templates
- Integration settings

## Integration with Rexuvia

### Daily Game Pipeline
This skill enables **Phase 0** of the daily game pipeline:

1. **Overnight Mining**: `pheno mine --overnight --lexaplast game_concepts`
2. **Morning Curation**: `pheno housekeep --rating 7+`
3. **Agent Ideation**: Feed high-rated concepts to multi-agent swarm
4. **Feedback Loop**: Successful concepts become new sequons

### Automated Workflows
Set up these cron jobs:

```bash
# Daily at 2 AM: Overnight mining
0 2 * * * pheno mine --overnight

# Daily at 9 AM: Housekeeping  
0 9 * * * pheno housekeep --auto

# Weekly: Update lexasomes from curated outputs
0 0 * * 0 pheno update lexasomes --from-outputs
```

## Creating Custom Lexasomes

1. Create a new lexasome:
   ```bash
   pheno create lexasome my_domain
   ```

2. Edit the generated file with your sequons:
   ```bash
   nano ~/.openclaw/workspace/phenosemantic-py/lexasomes/my_domain.txt
   ```

3. Use it in mining:
   ```bash
   pheno mine --lexasome my_domain --lexaplast my_generator
   ```

## Creating Custom Lexaplasts

1. Create a new lexaplast:
   ```bash
   pheno create lexaplast my_generator
   ```

2. Edit the JSON template:
   ```bash
   nano ~/.openclaw/workspace/phenosemantic-py/lexaplasts/my_generator.json
   ```

3. Test it:
   ```bash
   pheno mine --count 5 --lexaplast my_generator
   ```

## Troubleshooting

### Common Issues

1. **API Key Errors**:
   - Check `config.ini` has correct keys
   - Set environment variables: `DEEPSEEK_API_KEY`, `OPENAI_API_KEY`
   - Run `pheno config` to verify paths

2. **Command Not Found**:
   - Ensure skill is in `~/.openclaw/skills/`
   - Check file permissions: `chmod +x scripts/*.sh`

3. **Output Directory Issues**:
   - Run `pheno config --fix-paths`
   - Check disk space
   - Verify write permissions

### Debug Mode
```bash
# Enable debug output
pheno mine --debug

# Verbose housekeeping
pheno housekeep --verbose
```

## Development

### Adding New Commands
1. Add command to `SKILL.md`
2. Implement in `scripts/pheno-wrapper.sh`
3. Update `config.json` commands section
4. Test thoroughly

### Custom Templates
Place custom templates in `templates/custom/`:
- `lexasome_<type>.txt.template`
- `lexaplast_<type>.json.template`

## Performance Tips

- Use `--batch` flag for large operations
- Adjust `--delay` based on API rate limits
- Enable SQLite logging for performance tracking
- Regular housekeeping to manage output volume

## License

This skill is part of the Rexuvia project. See main project for license details.

## Support

- Check `pheno help --full` for complete documentation
- View logs in configured log directory
- Report issues to skill maintainer