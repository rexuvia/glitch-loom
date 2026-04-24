# ModelShow Cheat Sheet

## 🚀 **Quick Commands**

```bash
# Run ModelShow with a prompt:
mdls "Your prompt here"

# Run with specific models (if needed):
mdls "Prompt" --models grok,kimi,flash

# Check unpublished results:
mspp list

# Publish a result:
mspp publish result-id
```

## 🎯 **Best Prompt Formula**

```
[Action] [Topic] [Constraint] [Audience/Analogy]
```

**Examples:**
- `Explain quantum computing using cooking analogies for beginners`
- `Design a morning routine for maximum creativity in 100 words`
- `Write a haiku about AI that also works as Python code`

## 🏆 **Top 10 Prompts (Copy & Paste)**

1. `mdls "Explain quantum superposition using a cooking analogy"`
2. `mdls "Write a Python function that generates fractal patterns"`
3. `mdls "Design a new social media platform that actually improves mental health"`
4. `mdls "Explain blockchain to your grandmother"`
5. `mdls "Create a short story where the protagonist is a sentient algorithm"`
6. `mdls "Compare three different approaches to solving climate change"`
7. `mdls "Write a haiku that also works as valid JSON"`
8. `mdls "Design a week-long learning plan for mastering basic Spanish"`
9. `mdls "What would a constitution for Mars colonists look like?"`
10. `mdls "Explain how neural networks work using only metaphors from nature"`

## 🎨 **Creative Constraints**

Add these to any prompt:
- `in exactly 100 words`
- `using only food metaphors`
- `as if explaining to a 5-year-old`
- `in the style of a Shakespearean sonnet`
- `as a series of 3 tweets`

## 🔄 **Weekly Themes**

**Monday:** Technical/Coding
**Tuesday:** Creative/Writing
**Wednesday:** Comparative Analysis
**Thursday:** Future/Speculative
**Friday:** Fun/Constrained

## 📊 **What Makes a Good Prompt?**

✅ **Specific but open-ended** - "Design a..." not "What is..."
✅ **Multiple valid approaches** - No single right answer
✅ **Tests different skills** - Creative, analytical, technical
✅ **Interesting to compare** - Models should differ meaningfully
✅ **Practical/educational value** - Results should be useful

❌ **Avoid:** Factual recall, yes/no questions, vague prompts

## 💡 **Prompt Categories**

### **Technical:**
- Coding challenges
- System design
- Technical explanations
- Algorithm design

### **Creative:**
- Story writing
- Poetry/constrained writing
- Design challenges
- Analogies/metaphors

### **Analytical:**
- Comparative analysis
- Problem-solving
- Ethical dilemmas
- Future speculation

### **Practical:**
- Life hacks/systems
- Learning plans
- Communication strategies
- Productivity tips

## 🚫 **What to Avoid**

- **Fact questions:** "What year was X invented?"
- **Yes/no:** "Is AI dangerous?"
- **Too vague:** "Tell me something interesting"
- **Real-time data:** "What's the weather in Tokyo?"
- **Overly controversial topics**

## 🔧 **Custom Prompt Builder**

```bash
# Template:
mdls "[Action] [Topic] [Constraint] [Audience]"

# Actions: Explain, Design, Write, Compare, Create, Analyze
# Topics: Choose your interest
# Constraints: in N words, using X metaphors, as a Y
# Audience: to a Z-year-old, for beginners, for experts

# Example:
mdls "Design a better voting system using game theory principles for a modern democracy"
```

## 📈 **Tracking & Improvement**

1. **Note which prompts** produce interesting comparisons
2. **Track which models excel** at which types of prompts
3. **Adjust constraints** based on results
4. **Rotate categories** to test different capabilities
5. **Balance** technical, creative, and analytical prompts

## 🎪 **Fun Challenge Prompts**

```bash
# Cross-domain creativity:
mdls "Combine principles from biology with software architecture"

# Meta-AI prompts:
mdls "What would an AI bill of rights look like?"

# Constraint madness:
mdls "Explain the internet using only pirate terminology"

# Practical creativity:
mdls "Design a board game that teaches programming concepts"
```

## 📱 **Quick Reference - Save These:**

```bash
# For testing new models:
mdls "Explain recursion using a Russian nesting doll analogy"

# For creative comparison:
mdls "Write a sonnet about machine learning"

# For practical innovation:
mdls "Design a better way to organize digital photos"

# For philosophical depth:
mdls "What does 'intelligence' mean in the age of AI?"
```

## 🎲 **Random Prompt Generator**

Pick one from each:
- **Action:** Explain | Design | Write | Compare | Create
- **Topic:** AI ethics | morning routine | alien biology | voting systems | education
- **Constraint:** in 50 words | using sports metaphors | as a poem | for beginners
- **Format:** as a tweet | as a recipe | as a manual | as a story

**Example:** `mdls "Design an alien biology using sports metaphors as a field guide"`