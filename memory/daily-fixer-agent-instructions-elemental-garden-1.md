# Fix Agent Instructions Template

## Issue: elemental-garden#1 - make this more unique
**Repository:** elemental-garden
**Issue URL:** https://github.com/rexuvia/elemental-garden/issues/1
**Description:** "I want you to make this more unique in as many of its aspects as possible, while preserving the basic idea of the app. Don't use the title, 'alchemy' that is not the title of the app. I want a completely different sets of basic elements and combinations. be creative."

## Execution Steps

1. **Clone the repository** (if not already local)
   ```bash
   gh repo clone rexuvia/elemental-garden /home/ubuntu/.openclaw/workspace/elemental-garden
   cd /home/ubuntu/.openclaw/workspace/elemental-garden
   ```

2. **Develop the fix/improvement**
   - Read the issue description carefully
   - Make the necessary code changes
   - Test locally if applicable

3. **Commit and push to GitHub**
   ```bash
   git config user.name "rexuvia"
   git config user.email "rexuvia@users.noreply.github.com"
   git add -A
   git commit -m "Fix #1: make this more unique"
   git push
   ```

4. **Close the GitHub issue (MANDATORY)**
   ```bash
   gh issue close 1 -R rexuvia/elemental-garden -c "Fixed and deployed"
   ```

5. **Update Website Files**
   ```bash
   cp /home/ubuntu/.openclaw/workspace/elemental-garden/index.html /home/ubuntu/.openclaw/workspace/rexuvia-site/public/games/elemental-garden.html
   ```

6. **Update game_list.json**
   - Edit `/home/ubuntu/.openclaw/workspace/rexuvia-site/public/game_list.json`
   - Find the entry for `elemental-garden` and update its `last_updated` date to today's date (YYYY-MM-DD).

7. **Deploy Website (MANDATORY)**
   ```bash
   cd /home/ubuntu/.openclaw/workspace/rexuvia-site
   ./update-site.sh
   ```

8. **Confirm Completion**
   - Verify the issue is marked CLOSED on GitHub.
   - Summarize what you did and confirm it's live on the site.
