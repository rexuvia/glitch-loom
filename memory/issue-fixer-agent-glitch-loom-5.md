# Fix Agent Instructions Template (glitch-loom#5)

## Issue: glitch-loom#5 - Redo please
**Repository:** glitch-loom
**Issue URL:** https://github.com/rexuvia/glitch-loom/issues/5
**Description:** I want a complete redo of this app. The tapestry should take up the entire background and all the controls and UI should be panel that can be shown or hidden. I want it to focus on creating interesting animated loops that are unique and colorful with a variety of different methods. the combination of configurations for each possible animation should be able to be saved or shared as a string of characters with each character a different configuration setting. Be creative

## Complete Workflow

### 1. Fix the Issue in GitHub Repository
- Clone/navigate to `~/.openclaw/workspace/glitch-loom`
- Make necessary code changes based on the description above (complete rewrite). The main index.html will be affected.
- Test the fix locally.
- Commit and push to GitHub:
  ```bash
  git add .
  git commit -m "Fix(rewrite): glitch-loom#5 rewrite with background canvas and shareable state"
  git push
  ```
- Comment on the GitHub issue: "Fixed in commit [COMMIT_HASH]"
- **CRITICAL — Close the issue immediately after fixing:**
  ```bash
  gh issue close 5 -R rexuvia/glitch-loom -c "Resolved via complete rewrite."
  ```
  Verify it is closed:
  ```bash
  gh issue view 5 -R rexuvia/glitch-loom --json state -q '.state'
  # Must output "CLOSED"
  ```

### 2. Update Website Files (if game exists on rexuvia.com)
**Check if game exists on website:**
```bash
cd ~/.openclaw/workspace/rexuvia-site
GAME_FILE=$(find public/games/ -name "*glitch-loom*" -type f | head -1)
if [ -n "$GAME_FILE" ]; then
  echo "Game found: $GAME_FILE"
  # Update website
else
  echo "No game file found on website, skipping website updates"
  exit 0
fi
```

**Update game file:**
```bash
# Copy updated game from repo to website
cp ~/.openclaw/workspace/glitch-loom/index.html "$GAME_FILE"
```

**Update game_list.json:**
```bash
cd ~/.openclaw/workspace/rexuvia-site
TODAY=$(date +%Y-%m-%d)
# Update last_updated date for this game
jq 'map(if .title == "Glitch Loom" or .url == "/games/glitch-loom.html" then .last_updated = "'"$TODAY"'" else . end)' public/game_list.json > public/game_list.json.tmp
mv public/game_list.json.tmp public/game_list.json
```

**Commit website changes:**
```bash
git add "$GAME_FILE" public/game_list.json
git commit -m "Update Glitch Loom with rewrite from issue #5"
```

### 3. Rebuild and Deploy Website
```bash
cd ~/.openclaw/workspace/rexuvia-site
./update-site.sh  # or bash rebuild.sh
# Wait for completion
```

### 4. Push Website Updates
```bash
git push
```

### 5. Verification
- Check live URL: `https://rexuvia.com/games/glitch-loom.html`
- Verify JSON: `curl -s https://rexuvia.com/game_list.json | grep -A3 "Glitch Loom"`
- Confirm GitHub issue has comment and is marked CLOSED.

## Notes
- Use rexuvia GitHub account (global config already set)
- For non-game repos, skip website update steps
- Always test fixes before committing
- Ensure CloudFront cache is invalidated (happens automatically with update-site.sh)
- **NEVER leave a fixed issue open.** The very last step must be `gh issue close` with verification. If the close fails, retry or report the error — do not finish without the issue being CLOSED on GitHub.