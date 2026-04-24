# 🎭 Manual Testing Instructions for Phenosemantic

## ✅ Installation Complete!
Everything is configured and ready for testing.

## 🚀 Quick Test (2 minutes)

### Step 1: Navigate to workspace
```bash
cd /home/ubuntu/.openclaw/workspace/phenosemantic-workspace/phenosemantic-py
```

### Step 2: Activate virtual environment
```bash
source .venv/bin/activate
```

### Step 3: Generate 3 funny poems
```bash
phenosemantic --mine 3 1000 --lexaplast funny_poem_generator.json --incognito
```

### Step 4: Check output
```bash
ls -la /home/ubuntu/pheno-outputs/
```

## 📋 What This Will Generate

The system will create 3 funny poems by randomly combining:

**Subjects (20 options):**
- a confused robot
- a singing refrigerator  
- a philosophical sock
- a time-traveling teapot
- a melodramatic pencil
- ...and 15 more!

**Styles (20 options):**
- limerick
- haiku
- sonnet
- Dr. Seuss style
- rap verse
- ...and 15 more!

## 🎯 Expected Output

Each poem will look like:
```
[POEM TITLE]

[3-8 lines of funny poem]

[Optional: Why it's funny]
```

Example output file location:
```
/home/ubuntu/pheno-outputs/funny_poem_generator/2026-03-02.jsonl
```

## 🔧 Troubleshooting

### If you get "API key not found":
```bash
# Check config file
cat ~/.config/phenosemantic/config.ini | grep deepseek_api_key

# Should show:
# deepseek_api_key = sk-b4865f2e303f4ceb99323e2b3c9c7aef
```

### If you get "file not found" errors:
```bash
# Check files exist
ls -la /home/ubuntu/.openclaw/workspace/phenosemantic-workspace/phenosemantic-py/lexaplasts/funny_poem_generator.json
ls -la /home/ubuntu/.openclaw/workspace/phenosemantic-workspace/phenosemantic-py/lexasomes/poem_*.txt
```

### If virtual environment fails:
```bash
# Recreate if needed
cd /home/ubuntu/.openclaw/workspace/phenosemantic-workspace/phenosemantic-py
python3 -m venv .venv
source .venv/bin/activate
pip install -e .
```

## 📊 Success Verification

**If successful, you'll see:**
1. CLI output showing poem generation
2. New files in `/home/ubuntu/pheno-outputs/`
3. No error messages

**Please report:**
- ✅ Poems generated successfully
- ⚠️ Partial success with errors
- ❌ Complete failure

## 🎨 Customization Options

Want to test different things? Easy modifications:

### Add more subjects:
```bash
echo "a quantum-entangled spoon" >> lexasomes/poem_subjects.txt
echo "a bilingual dictionary" >> lexasomes/poem_subjects.txt
```

### Test with different count:
```bash
# Generate 5 poems
phenosemantic --mine 5 500 --lexaplast funny_poem_generator.json --incognito

# Generate 1 poem quickly  
phenosemantic --mine 1 100 --lexaplast funny_poem_generator.json --incognito
```

## ⏱️ Time Estimate

- **Test run:** 1-2 minutes
- **Debugging:** 2-5 minutes if issues
- **Customization:** 1 minute per change

## 📞 Next Steps After Testing

**Once you confirm it works, I'll:**
1. Fix the final skill wrapper issues
2. Create installation script
3. Set up cron jobs for automation
4. Integrate with daily game pipeline

**If there are issues, I'll:**
1. Debug based on your error messages
2. Provide specific fixes
3. Create alternative testing methods

## 🎯 Let's Do This!

**Your action:** Run the 3-poem test above
**My readiness:** All files configured, waiting for your test results

**Expected outcome:** Hilarious poems about confused robots and singing refrigerators! 🤖🎶

---

*Once you run the test, please share:*
1. *Did it work? (✅/⚠️/❌)*
2. *Any error messages?*
3. *How many poems were generated?*
4. *Sample of first poem (if successful)*

Then we'll proceed to the next phase! 🚀