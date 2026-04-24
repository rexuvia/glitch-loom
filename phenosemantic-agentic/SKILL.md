# Phenosemantic Agentic Skill

**Version:** 0.1.0  
**Status:** Phase 1 - Core Infrastructure  
**Author:** Rexuvia AI Agent

## Overview

A phenosemantic generation skill using OpenClaw's agentic capabilities with lexasome/lexaplast architecture. Replaces Python CLI with dynamic agent orchestration, auto-ranking, and human review queues.

## Architecture

```
User Request → Agent Orchestrator → Sequon Selection → Template Filling → 
Model Routing → Generation → Auto-Ranking → Human Review Queue
```

## Core Components

### 1. Lexasomes (Modular Data Sources)
- **domains/**: Subject areas (technology, creative, academic, etc.)
- **tasks/**: What to do (analysis, generation, comparison, etc.)
- **constraints/**: How to do it (style, format, length, etc.)
- **models/**: Which models to use (strengths, costs, speeds)

### 2. Lexaplasts (JSON Templates)
- Prompt templates with variable slots
- Model selection logic
- Output format specifications

### 3. Agents
- **Sequon Selector**: Chooses items from lexasomes
- **Template Filler**: Injects sequons into templates
- **Model Router**: Selects optimal model
- **Generation Agent**: Executes LLM calls
- **Auto-Ranker**: Scores outputs for review

## Usage

### Basic Generation
```bash
# Via OpenClaw command (to be implemented)
openclaw phenosemantic generate --domain technology --task analysis --constraint concise
```

### Multi-Model Comparison
```bash
openclaw phenosemantic compare --domain creative --template multi-model
```

### Batch Processing
```bash
openclaw phenosemantic batch --count 50 --workflow creative-prompts
```

## Configuration

### Model Selection
Configured via `lexasomes/models/models.json`:
- Model strengths (reasoning, creative, technical, etc.)
- Cost per 1K tokens
- Speed ratings
- Provider specifications

### Auto-Ranking Criteria
Configured in skill logic:
- Relevance (0-10)
- Creativity (0-10)
- Accuracy (0-10)
- Clarity (0-10)
- Depth (0-10)

## Output

### Storage Location
```
~/pheno-outputs/phenosemantic-agentic/YYYY-MM-DD/
├── generated/          # Raw outputs
├── ranked/            # Auto-ranked outputs
└── reviewed/          # Human-reviewed outputs
```

### File Format (JSONL)
```json
{
  "id": "uuid",
  "timestamp": "2026-03-02T01:54:00Z",
  "template": "basic-analysis",
  "sequons": {
    "domain": "quantum-computing",
    "task": "semantic-analysis",
    "constraint": "extremely-concise"
  },
  "model": "gpt5",
  "prompt": "Perform semantic analysis on quantum computing...",
  "response": "Quantum computing leverages quantum mechanics...",
  "auto_rank": {
    "relevance": 8.5,
    "creativity": 7.2,
    "accuracy": 9.0,
    "clarity": 8.0,
    "depth": 7.5,
    "overall": 8.04
  },
  "status": "queued_for_review"
}
```

## Integration

### With Existing Phenosemantic-py
- Reuses lexasomes from `phenosemantic-py/lexasomes/`
- Compatible output format with additional metadata
- Can run alongside Python tool during transition

### With OpenClaw Ecosystem
- Uses native model routing and cost tracking
- Integrates with existing agent orchestration
- Supports all configured models (34+)

## Development Status

### Phase 1 (Current): Core Infrastructure
- ✅ Basic directory structure
- ⏳ Lexasome creation
- ⏳ Lexaplast templates
- ⏳ Sequon selector agent
- ⏳ Template filler agent
- ⏳ Single-model generation
- ⏳ Basic auto-ranking

### Phase 2: Advanced Features
- Multi-model comparison
- Weighted sequon selection
- Model routing logic
- Batch processing
- Human review queue

### Phase 3: Optimization
- Feedback loops
- Adaptive weighting
- Cost optimization
- Performance monitoring

### Phase 4: Expansion
- Specialized domains
- Advanced templates
- Collaborative swarms
- Real-time interactive mode

## Examples

### Example 1: Technology Analysis
```
Input: quantum computing analysis
→ Domain: quantum-computing (from technology.txt)
→ Task: semantic-analysis (from analysis.txt)
→ Constraint: technical-depth (from style.csv)
→ Model: GPT-5 (technical strength)
→ Output: Technical analysis with auto-rank 8.2/10
```

### Example 2: Creative Exploration
```
Input: speculative fiction world-building
→ Domain: speculative-fiction (from creative.txt)
→ Task: world-building (from generation.txt)
→ Constraint: detailed-explanation (from style.csv)
→ Models: GPT-5, Sonnet, Grok (multi-model)
→ Output: 3 perspectives with comparative ranking
```

## Maintenance

### Adding New Lexasomes
1. Add sequons to appropriate `.txt` or `.csv` file
2. Update template variable references if needed
3. Test with basic generation

### Creating New Templates
1. Create JSON file in `lexaplasts/`
2. Define variables and their lexasome sources
3. Specify model selection logic
4. Test with sample sequons

### Model Updates
1. Edit `lexasomes/models/models.json`
2. Add/remove models as available
3. Update strength/cost/speed ratings

## Troubleshooting

### Common Issues

**No outputs generated:**
- Check lexasome files exist and are readable
- Verify template variables match lexasome names
- Confirm model is available and configured

**Low auto-rank scores:**
- Review sequon combinations (may be mismatched)
- Check model selection (wrong model for task)
- Adjust ranking criteria weights if needed

**Slow generation:**
- Model may be rate-limited or slow
- Try different model with similar strengths
- Reduce concurrent generations if batch processing

### Logs
Check OpenClaw logs for agent execution details:
```bash
tail -f /tmp/openclaw/openclaw-*.log | grep phenosemantic
```

## License & Attribution

Built on phenosemantic-py concepts with OpenClaw agentic implementation.

---

*Last Updated: 2026-03-02*  
*Phase: 1 - Core Infrastructure*