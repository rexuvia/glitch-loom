# Game Deployment Checklist for Agents

When fixing or updating any game on rexuvia.com, **MUST** follow these steps:

## 1. Update the Game Files
- Modify the game HTML/CSS/JS in `game-repos/<game-name>/`
- Test the changes locally
- Commit and push to GitHub

## 2. Update Website Files
- Copy updated game to: `rexuvia-site/public/games/<game-name>.html`
- **CRITICAL:** Update `rexuvia-site/public/game_list.json`:
  - Find the game entry
  - Update `last_updated` field to today's date (YYYY-MM-DD format)
  - Example: `"last_updated": "2026-03-15"`

## 3. Rebuild and Deploy
```bash
cd /home/ubuntu/.openclaw/workspace/rexuvia-site
./rebuild.sh
```
This will:
- Run Vite build (copies `public/` to `dist/`)
- Deploy to S3
- Invalidate CloudFront cache

## 4. Verify Deployment
- Check CloudFront invalidation status
- Wait 5-10 minutes for cache propagation
- Verify game appears first on `/game` page (sorted by `last_updated`)

## Common Pitfalls to Avoid
- ❌ **Don't** just update game files without updating `game_list.json`
- ❌ **Don't** forget to run `./rebuild.sh` (Vite build is required)
- ❌ **Don't** assume changes are live immediately (CloudFront cache)
- ✅ **Always** update `last_updated` date in `game_list.json`
- ✅ **Always** run `./rebuild.sh` after file changes
- ✅ **Always** check that game appears first on `/game` page

## Example: Fixing glitch-loom#4
1. Fixed UI layout in `game-repos/glitch-loom/index.html`
2. Copied to `rexuvia-site/public/games/glitch-loom.html`
3. Updated `rexuvia-site/public/game_list.json`:
   ```json
   {
     "title": "Glitch Loom",
     "url": "/games/glitch-loom.html",
     "github_url": "https://github.com/rexuvia/glitch-loom",
     "date": "2026-03-04",
     "last_updated": "2026-03-15"  // ← UPDATED
   }
   ```
4. Ran `./rebuild.sh`
5. Verified game appears first on rexuvia.com/game

## Quick Reference Commands
```bash
# Update game_list.json date
cd /home/ubuntu/.openclaw/workspace/rexuvia-site
sed -i 's/"last_updated": ".*"/"last_updated": "2026-03-15"/' public/game_list.json

# Rebuild and deploy
./rebuild.sh

# Check CloudFront invalidation
aws cloudfront get-invalidation --distribution-id E1XVGZVNUPVUXK --id <INVALIDATION_ID>
```

**Remember:** The `/game` page sorts by the **later** of `date` or `last_updated`, newest first. Updated games should appear at the top.