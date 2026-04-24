# LexaForge

A clean, bug-free implementation of phenosemantic concepts for OpenClaw.

## What It Does

LexaForge lets you:
- **Create lexaplasts** - Templates for generating content
- **Create lexasomes** - Building blocks (words, phrases, concepts)
- **Mine outputs** - Generate content by combining lexaplasts and lexasomes
- **Schedule jobs** - Run mining overnight
- **Auto-rank results** - Coming soon!

## Quick Demo

```bash
# 1. Initialize
cd /home/ubuntu/.openclaw/workspace/lexaforge
python3 lexaforge.py init

# 2. Create example lexaplast
python3 lexaforge.py create-lexaplast game-ideas --template game-concepts

# 3. Create example lexasomes
python3 lexaforge.py create-lexasome mechanics --type txt
echo "procedural generation" >> lexasomes/mechanics.txt
echo "physics simulation" >> lexasomes/mechanics.txt
echo "roguelike elements" >> lexasomes/mechanics.txt

python3 lexaforge.py create-lexasome genres --type txt
echo "science fiction" >> lexasomes/genres.txt
echo "fantasy" >> lexasomes/genres.txt
echo "mystery" >> lexasomes/genres.txt

# 4. Mine 5 game ideas (test)
python3 lexaforge.py mine --lexaplast game-ideas --lexasome mechanics genres --count 5 --name test

# 5. View results
ls outputs/
python3 lexaforge.py view-outputs --job <latest-job-id> --limit 5
```

## File Structure

```
lexaforge/
├── lexaforge.py          # Main CLI script
├── SKILL.md              # OpenClaw skill documentation
├── README.md             # This file
├── lexaplasts/           # Your lexaplast JSON files
├── lexasomes/            # Your lexasome TXT/CSV files
├── outputs/              # Generated outputs (JSONL)
├── lexaforge.db          # SQLite database for tracking
└── lexaforge.log         # Activity logs
```

## How It Works

1. **Lexaplast** = Recipe for generation
   - System prompt: "You are a game designer..."
   - User template: "Design a game with {mechanic} in {genre}"
   - Parameters: temperature, model, etc.

2. **Lexasome** = Ingredients
   - mechanics.txt: "procedural generation", "physics simulation"
   - genres.txt: "science fiction", "fantasy"

3. **Mining** = Cooking
   - Combine: "Design a game with procedural generation in science fiction"
   - Call LLM, get output
   - Repeat N times

## Use Cases

### Daily Game Ideas
```bash
# Schedule nightly mining
python3 lexaforge.py schedule \
  --name nightly-games \
  --lexaplast game-ideas \
  --lexasome mechanics genres platforms \
  --count 100 \
  --time 03:00
```

### Creative Writing Prompts
```bash
# Create writing prompt generator
python3 lexaforge.py create-lexaplast writing-prompts --template creative

# Mine prompts
python3 lexaforge.py mine \
  --lexaplast writing-prompts \
  --lexasome genres characters settings \
  --count 50 \
  --temperature 0.9
```

### Technical Questions
```bash
# Create technical question generator
python3 lexaforge.py create-lexaplast tech-questions --template technical

# Mine interview questions
python3 lexaforge.py mine \
  --lexaplast tech-questions \
  --lexasome languages concepts \
  --count 30 \
  --temperature 0.7
```

## Next Steps

1. **Test the basic flow** - Make sure mining works
2. **Add more lexaplasts/lexasomes** - Build your library
3. **Schedule overnight jobs** - Wake up to fresh ideas
4. **Rate and curate outputs** - Build quality datasets

## Need Help?

Check `SKILL.md` for detailed documentation or run:
```bash
python3 lexaforge.py --help
```

---

**Status:** Ready for testing! The core functionality is implemented and should work without the frustrations of phenosemantic-py.