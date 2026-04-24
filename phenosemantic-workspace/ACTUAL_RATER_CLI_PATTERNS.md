# 📊 ACTUAL Rater CLI Patterns (From phenos/rater_cli)

## 🎯 **Actual Lexaplast Structure**

**Key Differences from Our Implementation:**
1. Uses `system_message` + `user_prompt_template` instead of `template_string`
2. Placeholder is `{codon}` (no `$` prefix)
3. Simpler structure without `examples`, `metadata`, `validation` sections
4. Uses `ui_label` for output categorization

**Actual Format:**
```json
{
  "name": "Descriptive Name",
  "system_message": "You are a [role] that [does something].",
  "user_prompt_template": "Instructions with {codon} placeholder. Specific requirements.",
  "ui_label": "OutputLabel",
  "temperature": 0.7,
  "description": "Brief description",
  "author": "Name",
  "copyright": "MIT"
}
```

## 📝 **Actual Lexasome Patterns**

**Text Files (.txt):**
- Can include metadata comment at top: `# METADATA: {"name": "...", "description": "...", "author": "..."}`
- One sequon per line
- Comments with `#`
- Can have duplicates (seen in funny.txt)

**CSV Files (.csv):**
- Format: `sequon, weight` (note space after comma)
- Metadata comment at top
- Weights are integers (not decimals)

**JSON Combiners (.json):**
- Combine multiple sources
- Can include static strings
- Specify `select_count` for each source

## 🎭 **Examples from rater_cli**

### **1. default.json (Lexaplast)**
```json
{
    "name": "Ordered Sentence Generator",
    "system_message": "You are a linguistic assistant...",
    "user_prompt_template": "Create one single, grammatically correct sentence...: {codon}",
    "ui_label": "Sentence",
    "temperature": 0.7,
    "description": "Takes a sequence of sequons...",
    "author": "System Default",
    "copyright": "MIT"
}
```

### **2. micro_poem.json (Lexaplast)**
```json
{
    "name": "Verse Weaver",
    "system_message": "You are an AI poet...",
    "user_prompt_template": "Craft a short poem... inspired by the sequons: {codon}",
    "ui_label": "Poem",
    "temperature": 0.8,
    "description": "Generates short, thematic poems...",
    "author": "Schuyler Sloane",
    "copyright": "MIT"
}
```

### **3. funny.txt (Lexasome)**
```
# METADATA: {"name": "Funny word list", "description": "...", "author": "Schuyler"}
spatula
glove
unicycle
pigeon
fluffy
...
```

### **4. weighted.csv (Lexasome)**
```
# METADATA: {"name": "Weighted Technical Terms", "...", "author": "TechGuru"}
Algorithm, 3
API, 1
Application, 7
...
```

### **5. combiner.json (Lexasome Combiner)**
```json
{
  "name": "Comprehensive Sequon Source Combiner",
  "description": "Combines sequons from multiple sources...",
  "author": "PhenoBot",
  "copyright": "MIT",
  "ui_label_suggestion": "MixedSeed",
  "format_version": 1,
  "sequon_sources": [
    {"file": "weighted.csv", "select_count": 3},
    {"file": "default.txt", "select_count": 1},
    {"static": "around the mullberry bush"},
    {"file": "abstract.txt", "select_count": 3},
    {"file": "default.txt", "select_count": 1}
  ]
}
```

## 🔧 **Key Insights**

### **Simplicity Over Complexity:**
- No `examples` section in lexaplasts
- No `metadata` object beyond basic fields
- No `validation` rules
- Simpler is better

### **Placeholder Usage:**
- Always `{codon}` (not `{{$codon}}` or `{{codon[0]}}`)
- Gets replaced with ALL sequons in order
- No individual sequon access

### **Temperature Ranges:**
- `0.6` for structured tasks (game plots)
- `0.7` for general generation (sentences)
- `0.8` for creative tasks (poems)

### **UI Label Purpose:**
- Used for output categorization
- Appears in filenames/directories
- Should be short and descriptive

## 🚀 **Updating Our Implementation**

**Our current `funny_poem_generator.json` should be simplified to:**

```json
{
  "name": "Funny Poem Generator",
  "system_message": "You are a humorous poet that creates funny short poems.",
  "user_prompt_template": "Write a funny short poem inspired by these sequons: {codon}. Make it humorous, creative, and 3-8 lines. Include a brief explanation of why it's funny.",
  "ui_label": "FunnyPoem",
  "temperature": 0.8,
  "description": "Generates humorous short poems based on input sequons.",
  "author": "Rexuvia",
  "copyright": "MIT"
}
```

**Our lexasomes are already correct!** They follow the right format.

## 📈 **Benefits of This Simpler Approach:**

1. **Easier to create** - Less boilerplate
2. **More flexible** - Works with existing phenosemantic code
3. **Consistent** - Matches established patterns
4. **Maintainable** - Simpler structure = fewer bugs

## 🎯 **Action Items:**

1. Simplify our lexaplasts to match `system_message` + `user_prompt_template` format
2. Keep our lexasomes as-is (they're already correct)
3. Test with the simplified format
4. Consider adding metadata comments to lexasome files

**The actual patterns are simpler than we thought!** This makes our implementation easier to maintain and more compatible with existing tools.