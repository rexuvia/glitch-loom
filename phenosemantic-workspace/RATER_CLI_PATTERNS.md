# 📊 Rater CLI Patterns & Best Practices

Based on typical `rater_cli` directory structures in phenosemantic projects, here are the patterns and examples for creating effective lexasomes and lexaplasts.

## 🎯 **Core Principles from Rater CLI**

### **1. Lexasome Design Patterns**

**Text Lexasomes (.txt):**
```
# Clear categorization header
# One sequon per line
# Group related sequons
# Avoid ambiguity

# Example: quality_criteria.txt
originality
creativity
clarity
coherence
accuracy
```

**Weighted Lexasomes (.csv):**
```
# sequon,weight
# Higher weight = more frequent selection
extremely_important,0.3
important,0.25
moderate,0.2
minor,0.15
optional,0.1
```

**JSON Combiners (.json):**
```json
{
  "name": "combined_criteria",
  "description": "Combine multiple criteria sources",
  "sources": [
    {"file": "core_criteria.txt", "weight": 0.6},
    {"file": "specialized_criteria.txt", "weight": 0.4}
  ],
  "selection_rules": {
    "min_from_each": 1,
    "max_total": 3,
    "allow_duplicates": false
  }
}
```

### **2. Lexaplast Structure Patterns**

**Basic Structure:**
```json
{
  "name": "descriptive_name",
  "ui_label": "ShortLabel",
  "description": "Clear purpose description",
  
  "codon": {
    "lexasomes": ["source1.txt", "source2.csv"],
    "n": 2,
    "selection_mode": "random|sequential|weighted"
  },
  
  "template_string": "Clear instructions with {{$codon}} or {{codon[0]}} placeholders",
  
  "model": "model-name",
  "temperature": 0.7,
  "max_tokens": 300,
  
  "metadata": {
    "category": "evaluation|generation|analysis",
    "difficulty": "easy|medium|hard",
    "purpose": "specific_use_case"
  },
  
  "examples": [
    {
      "codon": ["example_sequon1", "example_sequon2"],
      "output": "Example output showing expected format"
    }
  ],
  
  "validation": {
    "required_sections": ["section1", "section2"],
    "min_length": 50,
    "max_length": 500
  }
}
```

### **3. Rater-Specific Patterns**

**Evaluation Lexaplasts:**
- Focus on structured output (ratings, feedback, suggestions)
- Lower temperature (0.2-0.4) for consistency
- Include validation rules
- Provide clear examples of good/bad evaluations

**Housekeeping Integration:**
- Lexaplasts designed to process `{{output_to_rate}}` placeholder
- Output structured for easy parsing
- Compatible with rating workflows

### **4. File Organization**

**Typical rater_cli structure:**
```
rater_cli/
├── lexasomes/
│   ├── quality_dimensions.txt
│   ├── output_categories.txt
│   ├── rating_scales.csv
│   └── evaluation_methods.json
├── lexaplasts/
│   ├── output_rater.json
│   ├── quality_assessor.json
│   └── improvement_suggester.json
├── examples/
│   ├── good_ratings.jsonl
│   └── bad_ratings.jsonl
└── templates/
    ├── rating_report.md
    └── evaluation_summary.json
```

### **5. Best Practices Observed**

**For Lexasomes:**
1. **Specific over general** - "technical_writing" not just "writing"
2. **Consistent granularity** - All sequons at similar specificity level
3. **Clear categorization** - Use comments to group related sequons
4. **Avoid overlap** - Minimize semantic duplication
5. **Practical utility** - Choose sequons actually useful for generation

**For Lexaplasts:**
1. **Clear purpose** - Each lexaplast has specific, narrow function
2. **Structured output** - Use consistent formats for parsing
3. **Appropriate parameters** - Match temperature/tokens to task
4. **Good examples** - Show expected input/output patterns
5. **Validation rules** - Define what makes output valid

### **6. Common Patterns in Examples**

**Rating Tasks:**
```json
{
  "template_string": "Rate this {{output_type}} on {{criteria}}:\n\n{{output_to_rate}}\n\nProvide: 1-10 score, strengths, weaknesses, suggestions.",
  "temperature": 0.3,
  "metadata": {"category": "evaluation"}
}
```

**Comparison Tasks:**
```json
{
  "template_string": "Compare these two {{item_type}}s on {{comparison_basis}}:\n\nItem A: {{item_a}}\nItem B: {{item_b}}\n\nIdentify: similarities, differences, which is better and why.",
  "temperature": 0.4
}
```

**Improvement Tasks:**
```json
{
  "template_string": "Improve this {{item_type}} by addressing {{improvement_areas}}:\n\n{{item_to_improve}}\n\nProvide: revised version, explanation of changes.",
  "temperature": 0.5
}
```

### **7. Integration Patterns**

**With Housekeeping:**
- Lexaplasts accept `{{output_to_rate}}` parameter
- Output includes machine-readable ratings
- Structured for batch processing

**With Mining Workflows:**
- Generate → Rate → Curate pipeline
- High-rated outputs become training data
- Continuous improvement loop

### **8. Example: Complete Rater Workflow**

1. **Mining Phase:** Generate outputs with creative lexaplasts
2. **Rating Phase:** Process outputs with rater lexaplasts
3. **Curation Phase:** Filter based on ratings
4. **Improvement Phase:** Use ratings to refine lexasomes

### **9. Key Takeaways**

**Effective rater_cli lexasomes/lexaplasts:**
- Are **purpose-built** for specific evaluation tasks
- Produce **structured, parseable** outputs
- Include **validation** to ensure quality
- Have **clear examples** of expected behavior
- Integrate **seamlessly** with phenosemantic workflows

**Our current implementation follows these patterns well!** The `funny_poem_generator.json` and associated lexasomes demonstrate good practices:
- Clear purpose and structure
- Appropriate parameters
- Good examples
- Proper categorization

**To improve further:** We could add more specialized lexasomes and create rater-specific lexaplasts for evaluating generated outputs.