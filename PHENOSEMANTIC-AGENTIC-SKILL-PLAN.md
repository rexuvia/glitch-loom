# Phenosemantic Agentic Skill Plan
## Using OpenClaw's Agentic Capabilities with Lexasome/Lexaplast Architecture

**Goal:** Create an OpenClaw skill that replicates and extends phenosemantic-py functionality using native agent orchestration instead of Python CLI.

---

## 1. Core Architecture

### 1.1 Skill Structure
```
phenosemantic-agentic/
├── SKILL.md                    # Skill documentation
├── lexasomes/                  # Modular data sources
│   ├── domains/               # Domain-specific sequons
│   ├── tasks/                 # Task types
│   ├── constraints/           # Constraints and styles
│   └── models/               # Model specifications
├── lexaplasts/                # Template definitions
│   ├── basic-prompt.json     # Simple prompt template
│   ├── multi-model.json      # Multi-model comparison
│   └── analysis-chain.json   # Chain-of-thought analysis
├── agents/                    # Agent definitions
│   ├── sequon-selector.md    # Selects sequons from lexasomes
│   ├── template-filler.md    # Fills lexaplasts with sequons
│   ├── model-router.md       # Routes to appropriate models
│   └── output-ranker.md      # Ranks outputs for review
└── workflows/                # Predefined workflows
    ├── quick-analysis.md     # Fast single-model analysis
    ├── deep-dive.md          # Multi-model comparison
    └── batch-generation.md   # Batch processing
```

### 1.2 Data Flow
```
User Request → Agent Orchestrator → Sequon Selection → Template Filling → 
Model Routing → Generation → Auto-Ranking → Human Review Queue
```

---

## 2. Lexasome Structure (Modular Data)

### 2.1 Domain Lexasomes
```txt
# domains/technology.txt
artificial-intelligence
machine-learning
distributed-systems
cybersecurity
quantum-computing
bioinformatics
robotics
iot-devices
cloud-architecture
edge-computing

# domains/creative.txt
speculative-fiction
poetic-forms
character-arcs
world-building
metaphor-systems
narrative-structures
symbolic-language
genre-fusion
```

### 2.2 Task Lexasomes  
```txt
# tasks/analysis.txt
semantic-analysis
concept-mapping
taxonomy-generation
ontology-creation
relationship-extraction
pattern-identification
analogy-discovery
metaphor-detection

# tasks/generation.txt
creative-writing
technical-documentation
code-generation
research-summary
business-proposal
educational-content
marketing-copy
```

### 2.3 Constraint Lexasomes
```csv
# constraints/style.csv
constraint,weight
extremely-concise,0.3
detailed-explanation,0.4
technical-depth,0.2
beginner-friendly,0.1

# constraints/format.csv
constraint,weight
bullet-points,0.3
paragraph-form,0.3
structured-outline,0.2
dialogue-format,0.2
```

### 2.4 Model Lexasomes
```json
{
  "models": [
    {
      "id": "gpt5",
      "provider": "openrouter/openai/gpt-5",
      "strengths": ["reasoning", "analysis", "technical"],
      "cost_per_1k": 0.15,
      "speed": "medium"
    },
    {
      "id": "sonnet",
      "provider": "anthropic/claude-sonnet-4-5", 
      "strengths": ["balanced", "creative", "instruction-following"],
      "cost_per_1k": 0.03,
      "speed": "fast"
    },
    {
      "id": "grok",
      "provider": "openrouter/x-ai/grok-4",
      "strengths": ["creative", "unconventional", "humor"],
      "cost_per_1k": 0.10,
      "speed": "medium"
    }
  ]
}
```

---

## 3. Lexaplast Templates (JSON Structure)

### 3.1 Basic Prompt Template
```json
{
  "name": "basic-analysis",
  "description": "Simple semantic analysis prompt",
  "template": "Perform a {{task}} on the concept of '{{domain}}' with the following constraints: {{constraint}}. Provide a {{format}} response.",
  "variables": {
    "task": {"source": "tasks/analysis.txt", "count": 1},
    "domain": {"source": "domains/technology.txt", "count": 1},
    "constraint": {"source": "constraints/style.csv", "count": 1},
    "format": {"source": "constraints/format.csv", "count": 1}
  },
  "model_selection": "auto",
  "output_format": "markdown"
}
```

### 3.2 Multi-Model Comparison Template
```json
{
  "name": "multi-model-debate",
  "description": "Compare perspectives from multiple models",
  "template": "Three AI models debate the concept of '{{domain}}' from different perspectives:\n\nModel 1 (Analytical): {{model1_perspective}}\nModel 2 (Creative): {{model2_perspective}}\nModel 3 (Technical): {{model3_perspective}}\n\nSynthesize their views into a coherent analysis.",
  "variables": {
    "domain": {"source": "domains/creative.txt", "count": 1}
  },
  "models": ["gpt5", "sonnet", "grok"],
  "output_format": "structured"
}
```

---

## 4. Agent Orchestration

### 4.1 Sequon Selector Agent
**Purpose:** Randomly selects sequons from lexasomes based on weights
**Implementation:** OpenClaw sub-agent with logic to:
- Read lexasome files
- Apply weighted selection for CSV files
- Return selected sequons as JSON

### 4.2 Template Filler Agent  
**Purpose:** Injects selected sequons into lexaplast templates
**Implementation:** Simple text replacement with validation

### 4.3 Model Router Agent
**Purpose:** Selects optimal model based on task type, cost, and speed
**Implementation:** Decision logic using model lexasome data

### 4.4 Generation Agent
**Purpose:** Executes the actual LLM call with filled template
**Implementation:** OpenClaw `sessions_spawn` with appropriate model

### 4.5 Auto-Ranker Agent
**Purpose:** Scores outputs based on predefined criteria
**Scoring Criteria:**
- Relevance to prompt (0-10)
- Creativity/novelty (0-10)
- Technical accuracy (0-10)
- Readability/clarity (0-10)
- Overall quality (0-10)

**Implementation:** Uses a scoring model (e.g., Haiku for fast scoring)

---

## 5. Auto-Ranking System

### 5.1 Ranking Criteria
```json
{
  "scoring_criteria": {
    "relevance": {
      "weight": 0.3,
      "description": "How well the output addresses the prompt"
    },
    "creativity": {
      "weight": 0.25, 
      "description": "Novelty and originality of ideas"
    },
    "accuracy": {
      "weight": 0.2,
      "description": "Factual and logical correctness"
    },
    "clarity": {
      "weight": 0.15,
      "description": "Readability and organization"
    },
    "depth": {
      "weight": 0.1,
      "description": "Thoroughness of analysis"
    }
  },
  "scoring_model": "anthropic/claude-haiku-4-5",
  "thresholds": {
    "excellent": 8.5,
    "good": 7.0,
    "average": 5.0,
    "poor": 3.0
  }
}
```

### 5.2 Human Review Queue
- Outputs sorted by auto-rank score
- Top 20% automatically approved for immediate use
- Middle 60% queued for human review
- Bottom 20% flagged for improvement or discard

### 5.3 Feedback Loop
- Human ratings feed back into ranking model training
- High-rated outputs inform future lexasome creation
- Pattern detection improves sequon selection weights

---

## 6. Workflow Examples

### 6.1 Quick Semantic Analysis
```
User: "Analyze quantum computing concepts"
→ Sequon Selector: picks "quantum-computing" from domains
→ Template Filler: uses basic-analysis template
→ Model Router: selects GPT-5 (technical strength)
→ Generation: produces analysis
→ Auto-Ranker: scores 8.2/10
→ Result: Queued for human review (good score)
```

### 6.2 Creative Concept Exploration
```
User: "Explore speculative fiction world-building"
→ Sequon Selector: picks multiple domains/tasks
→ Template Filler: uses multi-model template
→ Model Router: selects GPT-5, Sonnet, Grok
→ Generation: 3 parallel model calls
→ Auto-Ranker: compares and scores each
→ Result: Presents ranked perspectives
```

### 6.3 Batch Generation Mode
```
User: "Generate 50 creative writing prompts"
→ Workflow: batch-generation
→ Sequon combinations: 50 unique combos
→ Parallel generation: 5 concurrent agents
→ Auto-ranking: all outputs scored
→ Output: Sorted list with scores
→ Export: JSONL file for curation
```

---

## 7. Integration with Existing Infrastructure

### 7.1 Leverage Existing Lexasomes
- Reuse lexasomes from `phenosemantic-py/lexasomes/`
- Convert CSV weighted lexasomes to agent-readable format
- Maintain compatibility with Python tool for backup

### 7.2 Model Compatibility
- Use OpenClaw's native model routing
- Support all configured models (34+ available)
- Cost tracking through OpenClaw's usage monitoring

### 7.3 Output Storage
- Store in `~/pheno-outputs/` (compatible with existing)
- JSONL format with additional agent metadata
- Include auto-rank scores and agent decisions

---

## 8. Development Phases

### Phase 1: Core Infrastructure (Week 1)
- [ ] Create skill directory structure
- [ ] Implement basic lexasome reading
- [ ] Build simple template filler
- [ ] Create single-model generation flow
- [ ] Basic auto-ranking with fixed criteria

### Phase 2: Advanced Features (Week 2)
- [ ] Multi-model comparison workflows
- [ ] Weighted sequon selection
- [ ] Model routing logic
- [ ] Batch processing capabilities
- [ ] Human review queue system

### Phase 3: Optimization (Week 3)
- [ ] Feedback loop implementation
- [ ] Adaptive lexasome weighting
- [ ] Cost optimization algorithms
- [ ] Performance monitoring
- [ ] Integration with daily game pipeline

### Phase 4: Expansion (Week 4+)
- [ ] Specialized domain lexasomes
- [ ] Advanced template types
- [ ] Collaborative agent swarms
- [ ] Real-time interactive mode
- [ ] API endpoint for external tools

---

## 9. Key Advantages Over Python CLI

### 9.1 Dynamic Adaptation
- **CLI:** Fixed algorithms, static selection
- **Agentic:** Adaptive based on context, learns from feedback

### 9.2 Multi-Model Intelligence
- **CLI:** Single model per run
- **Agentic:** Can use multiple models strategically

### 9.3 Interactive Refinement
- **CLI:** Batch processing only
- **Agentic:** Can ask clarifying questions, refine approaches

### 9.4 Explainable Decisions
- **CLI:** Opaque selection process
- **Agentic:** Can explain why specific sequons/models were chosen

### 9.5 Continuous Learning
- **CLI:** Static unless manually updated
- **Agentic:** Improves through feedback loops

---

## 10. Success Metrics

### 10.1 Quality Metrics
- Auto-rank scores improve over time
- Human review approval rate increases
- Output diversity maintained or increased
- Cost per quality output decreases

### 10.2 Usability Metrics
- Time from request to ranked output < 2 minutes
- Human review queue processed daily
- Skill usage frequency increases
- User satisfaction (feedback collected)

### 10.3 Technical Metrics
- 99% uptime for skill availability
- < 5% error rate in generation
- Efficient model usage (cost/quality ratio)
- Scalable to 100+ concurrent generations

---

## 11. Next Steps

1. **Review this plan** - Confirm architecture meets requirements
2. **Start Phase 1** - Begin with core infrastructure
3. **Test with existing data** - Use current lexasomes for validation
4. **Iterate based on feedback** - Refine based on initial results

**Estimated Timeline:** 4 weeks to full production capability
**Initial MVP:** 2 weeks for basic functionality

---

*This plan creates a phenosemantic system that leverages OpenClaw's agentic capabilities while maintaining the modular lexasome/lexaplast architecture. The auto-ranking and human review queue ensure quality control while enabling scalable generation.*