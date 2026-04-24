# 🎭 One Command to Generate Poems

## ✅ Everything is Ready:
1. **API key verified** - curl test worked
2. **config.ini created** - in project directory
3. **Poem generator ready** - funny_poem_generator.json
4. **Virtual environment** - already set up

## 🚀 Run This Single Command:

```bash
cd /home/ubuntu/.openclaw/workspace/phenosemantic-workspace/phenosemantic-py && source .venv/bin/activate && phenosemantic --mine 3 1000 --lexaplast funny_poem_generator.json --incognito
```

## 📍 What Will Happen:
1. **Navigate** to phenosemantic directory
2. **Activate** Python virtual environment
3. **Generate** 3 funny poems with 1-second delay between each
4. **Output** poems to `/home/ubuntu/pheno-outputs/`

## 🎯 Expected Output:
You'll see the phenosemantic CLI generate 3 poems like:

```
───────────────────── Phenosemantic Text Generator & Rater ─────────────────────

Incognito Mode activated. No data will be saved.
──────────────────────── Single Run: Direct Codon Input ────────────────────────
Using Lexaplast: Funny Poem Generator
Using direct codon: [random subject] + [random style]
Calling DeepSeek API (Model: deepseek-chat)...

Output: [Funny poem will appear here]
```

## 🔧 If You Get Any Errors:

### **Error: "No module named phenosemantic"**
```bash
cd /home/ubuntu/.openclaw/workspace/phenosemantic-workspace/phenosemantic-py
source .venv/bin/activate
pip install -e .
```

### **Error: "config.ini not found"**
(It should be there - I just created it at `/home/ubuntu/.openclaw/workspace/phenosemantic-workspace/phenosemantic-py/config.ini`)

### **Error: "lexaplast not found"**
```bash
ls -la /home/ubuntu/.openclaw/workspace/phenosemantic-workspace/phenosemantic-py/lexaplasts/funny_poem_generator.json
```

## 📊 Success Verification:

**After running the command:**
1. **Check CLI output** - Should show 3 poems
2. **Check output directory** - `/home/ubuntu/pheno-outputs/funny_poem_generator/`
3. **View poems**:
   ```bash
   find /home/ubuntu/pheno-outputs -name "*.jsonl" -exec cat {} \; 2>/dev/null | grep -A2 "content"
   ```

## 🎨 Poem Examples You Might Get:

**Combination 1:** `a confused robot` + `haiku`
**Combination 2:** `a singing refrigerator` + `limerick`
**Combination 3:** `a philosophical sock` + `Dr. Seuss style`

## ⏱️ Time to Poems: 30 seconds

**Run the command now!** Let's see what hilarious poems the AI creates! 🎭🤖

---

**Once it works, we can:**
1. Create more lexasomes (game concepts, stories, etc.)
2. Set up cron jobs for daily generation
3. Integrate with your creative workflow
4. Build the full phenosemantic skill with all features

**But first: Let's get those poems generating!** 🚀