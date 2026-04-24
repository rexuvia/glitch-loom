# 📚 Lexasome & Lexaplast Catalog

## 📊 Summary
**Total Lexasomes:** 15 files (including image_prompter subdirectory)
**Total Lexaplasts:** 7 JSON templates
**Custom Created:** 2 poem-focused resources

## 📝 LEXASOMES (Input Sources)

### 🎭 **Poem & Creative Lexasomes (Custom)**
1. **`poem_subjects.txt`** (20 entries)
   - Funny/absurd subjects for poem generation
   - Examples: "a confused robot", "a singing refrigerator", "a philosophical sock"
   - Created for humor and creativity testing

2. **`poem_styles.txt`** (20 entries)  
   - Poetry forms and styles
   - Examples: "limerick", "haiku", "Dr. Seuss style", "rap verse"
   - Created for style variation testing

### 🎮 **Modelshow Lexasomes (Original)**
3. **`modelshow_tasks.txt`** (25 entries)
   - Task types for model testing
   - Examples: "code review", "creative writing", "data analysis"
   - Used for generating test prompts

4. **`modelshow_constraints.csv`** (20 entries)
   - Weighted constraints with probabilities
   - Examples: "extremely concise", "detailed explanation", "beginner-friendly"
   - CSV format with weight values

5. **`modelshow_domains.txt`** (40+ entries)
   - Technical and creative domains
   - Examples: "distributed systems", "game design", "quantum computing"
   - Broad domain coverage

### 🖼️ **Image Prompter Lexasomes**
6. **`image_prompter/combiner.json`**
   - JSON combiner for image generation
   - Combines multiple lexasomes with rules

7. **`image_prompter/mood_lighting.txt`**
   - Mood and lighting terms
   - Examples: "cinematic", "moody", "bright studio lighting"

8. **`image_prompter/styles.txt`**
   - Artistic styles
   - Examples: "photorealistic", "watercolor", "cyberpunk"

9. **`image_prompter/subjects.txt`**
   - Image subjects
   - Examples: "portrait", "landscape", "still life"

10. **`image_prompter/techniques.txt`**
    - Artistic techniques
    - Examples: "macro photography", "long exposure", "tilt-shift"

### 📄 **General Purpose Lexasomes**
11. **`default.txt`**
    - Default/general sequons
    - Fallback when no specific lexasome specified

12. **`abstract.txt`**
    - Abstract concepts and ideas
    - Examples: "time", "memory", "consciousness"

13. **`all_words.txt`**
    - Comprehensive word list
    - Large vocabulary source

14. **`raw_mode_lexasome.txt`**
    - For raw mode generation
    - Direct LLM prompting without templates

15. **`raw_mode_llm_assay.txt`**
    - LLM assay/testing terms
    - Evaluation and testing vocabulary

## 🎨 LEXAPLASTS (Template Generators)

### 🎭 **Funny Poem Generator (Custom)**
1. **`funny_poem_generator.json`**
   - **Purpose:** Generate humorous short poems
   - **Inputs:** `poem_subjects.txt` + `poem_styles.txt`
   - **Output:** 3-8 line funny poems with explanations
   - **Model:** deepseek-chat, temperature: 0.9
   - **Status:** Ready for testing

### 🧪 **Modelshow Prompt Generator (Original)**
2. **`modelshow_prompt.json`**
   - **Purpose:** Generate test prompts for model evaluation
   - **Inputs:** `modelshow_tasks.txt` + `modelshow_constraints.csv` + `modelshow_domains.txt`
   - **Output:** Structured test prompts
   - **Model:** Various, temperature: 0.7
   - **Status:** Production-ready

### 🖼️ **Image Prompter (Original)**
3. **`image_prompter.json`**
   - **Purpose:** Generate image generation prompts
   - **Inputs:** Image prompter lexasomes
   - **Output:** Detailed image prompts
   - **Model:** Various
   - **Status:** Ready for image generation

### 🧠 **Philosophical/Thought Experiments**
4. **`trolley_problem_generator.json`**
   - **Purpose:** Generate ethical dilemma scenarios
   - **Inputs:** Various ethical/moral concepts
   - **Output:** Trolley problem variations
   - **Model:** Various
   - **Status:** Ready for ethical reasoning tests

### 🏠 **Housekeeping Template**
5. **`housekeeper.json`**
   - **Purpose:** Process and rate generated outputs
   - **Inputs:** Generated outputs for evaluation
   - **Output:** Ratings and categorization
   - **Model:** Various
   - **Status:** For output curation workflow

### 🔬 **Lexaplasm Generator**
6. **`lexaplasm.json`**
   - **Purpose:** Meta-generation of lexaplasts
   - **Inputs:** Existing lexaplasts/patterns
   - **Output:** New lexaplast templates
   - **Model:** Various
   - **Status:** For template evolution

### 📄 **Default Template**
7. **`default.json`**
   - **Purpose:** Fallback generation template
   - **Inputs:** `default.txt` lexasome
   - **Output:** General creative outputs
   - **Model:** Various
   - **Status:** Always available fallback

## 🎯 **Ready-to-Use Combinations**

### **For Humor/Creativity Testing:**
```bash
# Funny poems
phenosemantic --lexaplast funny_poem_generator.json

# With mining mode (generate multiple)
phenosemantic --mine 10 500 --lexaplast funny_poem_generator.json
```

### **For Model/API Testing:**
```bash
# Test prompts
phenosemantic --lexaplast modelshow_prompt.json

# Batch generation
phenosemantic --mine 20 1000 --lexaplast modelshow_prompt.json
```

### **For Image Generation:**
```bash
# Image prompts
phenosemantic --lexaplast image_prompter.json
```

### **For Ethical Reasoning:**
```bash
# Trolley problems
phenosemantic --lexaplast trolley_problem_generator.json
```

## 🔧 **Customization Potential**

### **Easy Modifications:**
1. **Add to existing lexasomes:**
   ```bash
   echo "a quantum-entangled spoon" >> lexasomes/poem_subjects.txt
   echo "beatnik poetry" >> lexasomes/poem_styles.txt
   ```

2. **Create new lexasomes:**
   ```bash
   # Game mechanics
   echo "procedural generation" >> lexasomes/game_mechanics.txt
   echo "emergent behavior" >> lexasomes/game_mechanics.txt
   ```

3. **Modify lexaplasts:**
   - Edit JSON files in `lexaplasts/` directory
   - Change prompts, models, parameters

### **New Lexaplast Ideas:**
- `game_concept_generator.json` - Game design concepts
- `story_generator.json` - Short story prompts  
- `code_review_generator.json` - Code review scenarios
- `analogy_generator.json` - Creative analogies
- `debate_topic_generator.json` - Debate/argument topics

## 📊 **Usage Statistics**

### **Most Versatile:**
1. **`modelshow_prompt.json`** - Broad testing applications
2. **`funny_poem_generator.json`** - Creative/humor testing
3. **`default.json`** - General purpose fallback

### **Specialized:**
1. **`image_prompter.json`** - Visual content generation
2. **`trolley_problem_generator.json`** - Ethical reasoning
3. **`housekeeper.json`** - Output curation

## 🚀 **Immediate Testing Recommendations**

### **Quick API Test:**
```bash
# 1. Test with funny poems (most engaging)
phenosemantic --mine 3 1000 --lexaplast funny_poem_generator.json --incognito

# 2. Test with model prompts (most reliable)
phenosemantic --mine 2 500 --lexaplast modelshow_prompt.json --incognito

# 3. Simple test
phenosemantic --lexaplast default.json --incognito
```

### **Expected Output Locations:**
- `/home/ubuntu/pheno-outputs/funny_poem_generator/`
- `/home/ubuntu/pheno-outputs/ModelshowPrompt/`
- `/home/ubuntu/pheno-outputs/default/`

## 📞 **Next Steps**

**With working API connection, you can immediately:**
1. Generate 3 funny poems for testing
2. Create 10 model test prompts
3. Experiment with image prompt generation
4. Test ethical reasoning scenarios

**All resources are configured and ready - just need API connectivity verification!** 🎭