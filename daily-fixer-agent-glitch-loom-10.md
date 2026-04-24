# Fix Agent Instructions: glitch-loom#10

## Issue: glitch-loom#10 - add try to add a variable or two in the code for each pattern
**Repository:** glitch-loom
**Issue URL:** https://github.com/rexuvia/glitch-loom/issues/10
**Description:** "and make it saved in the state string and let the user customize them with sliders as well. Some patterns will not handle any variable ideally, so if needed make the variables control some very trivial aspect of the pattern, as long as they are still noticeably effecting the visual. Use your best judgement"

## Complete Workflow

### 1. Fix the Issue in GitHub Repository
- Clone/navigate to `~/.openclaw/workspace/glitch-loom`
- Make necessary code changes. Add 1-2 interactive variables/sliders for each weave pattern in `glitch-loom` that allow customization of the pattern's visual output. Ensure these new parameter values are serialized into and deserialized from the URL state string so that specific customized states can be shared.
- Test the fix locally to make sure it functions as expected.
- Commit and push to GitHub:
  ```bash
  git add .
  git commit -m "Feature: Add customizable variables for weave patterns (#10)"
  git push
  ```
- Comment on the GitHub issue: "Fixed in commit [COMMIT_HASH]"
- **CRITICAL — Close the issue immediately after fixing:**
  ```bash
  gh issue close 10 -R rexuvia/glitch-loom -c "Resolved via fix commit."
  ```
  Verify it is closed:
  ```bash
  gh issue view 10 -R rexuvia/glitch-loom --json state -q '.state'
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
# Update last_updated date for this game. The title in game_list.json is likely "Glitch Loom".
jq 'map(if .title == "Glitch Loom" or .url == "/games/glitch-loom.html" then .last_updated = "'"$TODAY"'" else . end)' public/game_list.json > public/game_list.json.tmp
mv public/game_list.json.tmp public/game_list.json
```

**Commit website changes:**
```bash
git add "$GAME_FILE" public/game_list.json
git commit -m "Update Glitch Loom with fix from issue #10"
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
- Check live URL: `https://rexuvia.com/games/glitch-loom.html` (or whatever the filename is)
- Verify JSON: `curl -s https://rexuvia.com/game_list.json | grep -A3 "Glitch Loom"`
- Confirm GitHub issue has comment and is closed.

## Notes
- Use rexuvia GitHub account (global config already set)
- Always test fixes before committing
- Ensure CloudFront cache is invalidated (happens automatically with update-site.sh)
- **NEVER leave a fixed issue open.** The very last step must be `gh issue close` with verification. If the close fails, retry or report the error — do not finish without the issue being CLOSED on GitHub.