# Fix Agent Instructions Template

## Issue: glitch-loom#8 - Add two new modification sliders to UI and update state string
**Repository:** glitch-loom
**Issue URL:** https://github.com/rexuvia/glitch-loom/issues/8
**Description:** Please improve glitch loom by adding two new kinds of modifications sliders to the UI, and update the state string format to include them.

## Complete Workflow

### 1. Fix the Issue in GitHub Repository
- Clone/navigate to `~/.openclaw/workspace/glitch-loom`
- Make necessary code changes to `index.html` to add two new modifier sliders (for example, contrast, brightness, hue shift, glitch intensity, block size, etc. - pick two distinct and cool webgl/canvas/glitch parameters that fit the glitch loom motif).
- Update the state string export/import logic in the code so the new parameters are saved and loaded correctly in the shareable URL strings.
- Test the fix locally
- Commit and push to GitHub:
  ```bash
  git add index.html
  git commit -m "Fix: Add two new modification sliders and update state string (Issue #8)"
  git push
  ```
- **CRITICAL — Close the issue immediately after fixing:**
  ```bash
  gh issue close 8 -R rexuvia/glitch-loom -c "Resolved via fix commit."
  ```
  Verify it is closed:
  ```bash
  gh issue view 8 -R rexuvia/glitch-loom --json state -q '.state'
  # Must output "CLOSED"
  ```

### 2. Update Website Files
**Check if game exists on website:**
```bash
cd ~/.openclaw/workspace/rexuvia-site
GAME_FILE=$(find public/games/ -name "*glitch-loom*" -type f | head -1)
if [ -n "$GAME_FILE" ]; then
  echo "Game found: $GAME_FILE"
else
  echo "No game file found on website, skipping website updates"
  exit 0
fi
```

**Update game file:**
```bash
# Copy updated game from repo to website
cp ~/.openclaw/workspace/glitch-loom/index.html "public/games/glitch-loom.html" # Assuming filename is glitch-loom.html, verify first
```

**Update game_list.json:**
```bash
cd ~/.openclaw/workspace/rexuvia-site
TODAY=$(date +%Y-%m-%d)
# Update last_updated date for this game
jq 'map(if .url == "/games/glitch-loom.html" then .last_updated = "'"$TODAY"'" else . end)' public/game_list.json > public/game_list.json.tmp
mv public/game_list.json.tmp public/game_list.json
```

**Commit website changes:**
```bash
git add "public/games/glitch-loom.html" public/game_list.json
git commit -m "Update Glitch Loom with fix from issue #8"
```

### 3. Rebuild and Deploy Website
```bash
cd ~/.openclaw/workspace/rexuvia-site
./update-site.sh
```

### 4. Push Website Updates
```bash
git push
```

### 5. Verification
- Check live URL: `https://rexuvia.com/games/glitch-loom.html`
- Verify JSON: `curl -s https://rexuvia.com/game_list.json | grep -A3 "Glitch Loom"`
- Confirm GitHub issue has comment and is CLOSED.