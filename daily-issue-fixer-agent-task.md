# Daily Issue Fixer - Agent Task

## Purpose
Find and process the oldest unaddressed issue by user "schbz" in rexuvia/* repositories.

## Steps to Execute

1. **Check for waiting responses first**
   - Look for `memory/issue-fixer-waiting-*.json` files
   - If found, remind Sky to respond to those first

2. **Find oldest unaddressed issue**
   - Use `gh repo list rexuvia` to get all repos
   - For each repo, use `gh issue list --author schbz --state open`
   - **Filter out already-processed issues using BOTH of these checks:**
     - a) Check `memory/issue-fixer-cache.json` `processed_issues` array — skip if `"repo#number"` is listed
     - b) Only consider issues whose GitHub state is `OPEN` (the `gh issue list --state open` already does this)
   - If an issue appears in the cache but is still open on GitHub, it may have been processed but not closed — **skip it anyway** (it was already worked on)
   - Find the issue with oldest `createdAt` date among the remaining unprocessed issues

3. **Analyze the issue**
   - Get issue details with `gh issue view`
   - Determine type: bug, feature, or documentation
   - Create brief analysis

4. **Send Telegram message with options**
   - Present issue details
   - Ask how to proceed (fix now, plan first, investigate, skip, stop)
   - Include model selection options
   - Store issue info in waiting file

5. **Wait for response**
   - Response should come via Telegram
   - Process response with appropriate action

## Response Handling

When Sky responds with numbers (e.g., "1 4" = fix now with GPT-5 Codex):

1. **Parse response** - action choice + model choice
2. **Update cache** - mark issue as processed in `memory/issue-fixer-cache.json` (add `"repo#number"` to `processed_issues` and set `last_processed` to current ISO timestamp)
3. **Take action** based on choice:
   - 1: Spawn fix agent with specified model (see **Complete Fix Workflow** below)
   - 2: Spawn planning agent
   - 3: Spawn research agent  
   - 4: Skip and remove from waiting — also close the issue on GitHub with `gh issue close <number> -R rexuvia/<repo> -c "Skipped by daily fixer"`
   - 5: Disable daily fixer cron job

**IMPORTANT:** For action 1 (Fix Now), the spawned fix agent's instructions MUST include explicitly closing the GitHub issue after the fix. Use the template from `daily-fixer-agent-instructions-template.md` which includes the `gh issue close` step.

## Complete Fix Workflow (for Action 1: Fix Now)

When spawning a fix agent, **use the template from `daily-fixer-agent-instructions-template.md`** and customize it with:
- Repository name
- Issue number and title  
- Game title (if applicable)
- Specific fix instructions

**Key improvements from the cell-symphony experience:**
1. **Automatic website file detection** - Check if game exists on rexuvia.com
2. **Automatic game file update** - Copy from repo to website
3. **Automatic JSON update** - Update `last_updated` date in `game_list.json`
4. **Automatic rebuild** - Run `./update-site.sh` to deploy
5. **Complete verification** - Check live URLs and GitHub
6. **MANDATORY: Close the GitHub issue** - Run `gh issue close <number> -R rexuvia/<repo>` and verify the state is CLOSED. This prevents the daily fixer from re-processing the same issue.

**Template usage example for cell-symphony#1:**
```markdown
# Fix Agent Instructions Template

## Issue: cell-symphony#1 - Speed slider reversal
**Repository:** cell-symphony
**Issue URL:** https://github.com/rexuvia/cell-symphony/issues/1
**Description:** "When the slider is on the left the speed is faster than when it is on the right. This is counterintuitive for most users. Please fix"

[Rest of template with specific paths...]
```

**Critical:** Always include the complete website update workflow when fixing game issues. The template ensures nothing is missed.

## Current Issues Found (2026-03-16)

1. **word-bird#1** - obstacle spacing adjustment (2026-03-11T22:31:43Z)
2. **cell-symphony#1** - Speed slider reversal (2026-03-11T22:50:20Z) *[PROCESSED 2026-03-17]*
3. **neon-synth-pad#1** - readme fixes needed (2026-03-13T01:37:13Z)

## Notes
- **Always perform complete website updates** when fixing game issues
- Use proper git identity (rexuvia account for rexuvia/* repos)
- Test fixes before committing
- Update issue with comment when fixed
- **Always close the GitHub issue after fixing** — run `gh issue close <number> -R rexuvia/<repo> -c "Fixed"` and verify it shows CLOSED
- For non-game repositories (like docs, skills), skip website update steps
- Verify all changes are live before marking as complete
- An issue in the `processed_issues` cache should NEVER be presented to Sky again, even if it somehow remains open on GitHub