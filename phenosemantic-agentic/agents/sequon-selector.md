# Sequon Selector Agent

## Purpose
Randomly selects sequons from lexasome files based on file type and weights.

## Input
- Lexasome file paths
- Number of sequons to select per file
- Optional: Specific sequon constraints

## Output
- JSON object with selected sequons
- Metadata about selection process

## Supported File Types

### 1. Plain Text (.txt)
- Each line is a sequon
- Equal probability selection
- Example: `domains/technology.txt`

### 2. Weighted CSV (.csv)
- First column: sequon
- Second column: weight (float)
- Weighted random selection
- Example: `constraints/style.csv`

### 3. JSON (.json)
- Structured data (e.g., models.json)
- Can specify selection path
- Example: `models/models.json`

## Selection Logic

### For .txt files:
```python
import random
with open(filepath, 'r') as f:
    sequons = [line.strip() for line in f if line.strip()]
selected = random.sample(sequons, count) if count < len(sequons) else sequons
```

### For .csv files:
```python
import csv, random
sequons, weights = [], []
with open(filepath, 'r') as f:
    reader = csv.DictReader(f)
    for row in reader:
        sequons.append(row['constraint'])
        weights.append(float(row['weight']))
selected = random.choices(sequons, weights=weights, k=count)
```

## Agent Implementation (OpenClaw)

```javascript
// Pseudo-code for OpenClaw agent
async function selectSequons(filepath, count = 1) {
  if (filepath.endsWith('.txt')) {
    return selectFromTxt(filepath, count);
  } else if (filepath.endsWith('.csv')) {
    return selectFromCsv(filepath, count);
  } else if (filepath.endsWith('.json')) {
    return selectFromJson(filepath, count);
  }
}
```

## Example Usage

### Single Selection
```bash
# Select 1 domain from technology.txt
selectSequons('lexasomes/domains/technology.txt', 1)
# Output: { "domain": "quantum-computing" }
```

### Multiple Selections
```bash
# Select 2 constraints from style.csv
selectSequons('lexasomes/constraints/style.csv', 2)
# Output: { "constraints": ["detailed-explanation", "technical-depth"] }
```

## Error Handling

1. **File not found**: Return error with suggestion
2. **Empty file**: Return empty selection with warning
3. **Invalid format**: Return parsing error
4. **Count > available**: Return all available with warning

## Integration with Template Filler

The sequon selector is called by the template filler agent to populate template variables:

```
Template Filler → For each variable → Sequon Selector → Selected sequons
```

## Testing

Test cases to implement:
1. Basic .txt file selection
2. Weighted .csv selection
3. JSON path selection
4. Error cases (missing files, invalid formats)
5. Edge cases (empty files, single item)

## Performance Considerations

- Cache lexasome files in memory for repeated access
- Use efficient random selection algorithms
- Handle large files with streaming if needed
- Log selection decisions for debugging

## Configuration

Optional configuration file `sequon-selector-config.json`:
```json
{
  "cache_ttl": 300,
  "default_count": 1,
  "random_seed": null,
  "log_level": "info"
}
```

---

*Agent Status: Ready for Implementation*  
*Phase: 1 - Core Infrastructure*