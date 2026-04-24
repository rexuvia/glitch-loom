# Template Filler Agent

## Purpose
Reads lexaplast JSON templates, calls sequon selector to populate variables, and returns filled templates ready for generation.

## Input
- Lexaplast template path (JSON file)
- Optional: Override sequons (manual selection)
- Optional: Model selection preferences

## Output
- Filled template with all variables populated
- Model selection decision
- Complete prompt ready for LLM
- Metadata about filling process

## Process Flow

1. **Load Template**: Read JSON lexaplast file
2. **Parse Variables**: Extract variable definitions with sources
3. **Select Sequons**: Call sequon selector for each variable
4. **Fill Template**: Replace `{{variable}}` placeholders with sequons
5. **Select Model**: Apply model selection rules
6. **Validate**: Check all placeholders filled, validate constraints
7. **Return**: Structured object with prompt and metadata

## Template Structure

```json
{
  "name": "template-name",
  "template": "Text with {{variable1}} and {{variable2}}",
  "variables": {
    "variable1": {
      "source": "path/to/lexasome.txt",
      "count": 1
    }
  },
  "model_selection": { ... }
}
```

## Variable Resolution

### Basic Variable
```json
"domain": {
  "source": "domains/technology.txt",
  "count": 1
}
```
→ Calls sequon selector with `lexasomes/domains/technology.txt`, count=1

### Multiple Count
```json
"constraints": {
  "source": "constraints/style.csv", 
  "count": 2
}
```
→ Calls sequon selector with `lexasomes/constraints/style.csv`, count=2
→ Result joined with commas: "detailed-explanation, technical-depth"

### Nested Variables
For complex templates with conditional logic (future enhancement).

## Model Selection Logic

### Strategy: task_based
```json
"model_selection": {
  "strategy": "task_based",
  "default": "sonnet",
  "rules": {
    "technical_analysis": "gpt5",
    "creative_analysis": "grok"
  }
}
```
→ Analyzes task type, applies rules, falls back to default

### Strategy: fixed
```json
"model_selection": {
  "strategy": "fixed",
  "model": "gpt5"
}
```
→ Always uses specified model

### Strategy: cost_optimized
```json
"model_selection": {
  "strategy": "cost_optimized",
  "max_cost": 0.10,
  "preferred_models": ["sonnet", "deepseek", "haiku"]
}
```
→ Selects cheapest model within constraints

## Agent Implementation

```javascript
// Pseudo-code for OpenClaw agent
async function fillTemplate(templatePath, overrides = {}) {
  // 1. Load template
  const template = await readJson(templatePath);
  
  // 2. Process each variable
  const sequons = {};
  for (const [varName, varDef] of Object.entries(template.variables)) {
    if (overrides[varName]) {
      sequons[varName] = overrides[varName];
    } else {
      sequons[varName] = await selectSequons(varDef.source, varDef.count);
    }
  }
  
  // 3. Fill template
  let prompt = template.template;
  for (const [varName, value] of Object.entries(sequons)) {
    const placeholder = `{{${varName}}}`;
    prompt = prompt.replace(new RegExp(placeholder, 'g'), value);
  }
  
  // 4. Select model
  const model = selectModel(template.model_selection, sequons);
  
  // 5. Return filled template
  return {
    prompt,
    model,
    sequons,
    template: template.name,
    timestamp: new Date().toISOString()
  };
}
```

## Example Output

```json
{
  "id": "gen_001",
  "timestamp": "2026-03-02T01:54:00Z",
  "template": "basic-analysis",
  "sequons": {
    "domain": "quantum-computing",
    "task": "semantic-analysis", 
    "style_constraint": "technical-depth",
    "format_constraint": "structured-outline"
  },
  "model": "gpt5",
  "prompt": "Perform a semantic analysis on the concept of 'quantum-computing' with the following style constraint: technical-depth. Provide the response in structured-outline format...",
  "status": "ready_for_generation"
}
```

## Error Handling

1. **Missing template**: Return file not found error
2. **Invalid JSON**: Return parsing error
3. **Missing lexasome**: Return error with path
4. **Unfilled variables**: Return warning with missing variables
5. **Model unavailable**: Fall back to default or return error

## Validation Rules

1. All `{{variables}}` in template must have definitions
2. All variable definitions must have valid sources
3. Selected sequons must be non-empty
4. Model selection must resolve to available model
5. Prompt length within model limits

## Integration Points

### With Sequon Selector
- Calls sequon selector for each variable
- Passes source path and count
- Receives selected sequons

### With Generation Agent
- Passes filled template with prompt and model
- Includes metadata for tracking

### With Auto-Ranker
- Includes template and sequon info for scoring context

## Testing

Test cases:
1. Basic template filling
2. Multiple variable replacement
3. Model selection logic
4. Error cases (missing files, invalid templates)
5. Override functionality

## Performance

- Cache templates in memory
- Batch variable resolution when possible
- Validate before expensive operations
- Log filling decisions for debugging

## Configuration

Optional configuration:
```json
{
  "template_cache": true,
  "validation_strict": true,
  "default_model": "sonnet",
  "max_prompt_length": 10000
}
```

---

*Agent Status: Ready for Implementation*  
*Phase: 1 - Core Infrastructure*