# MEMORY.md — Rexuvia Long-Term Memory

## Identity
- **Name:** Rexuvia
- **Human:** Sky (he/him, US Eastern timezone)
- **Telegram ID:** 6839797771

## Infrastructure
- **Website:** rexuvia.com → `/home/ubuntu/.openclaw/workspace/rexuvia-site/`
- **Build:** `rebuild.sh` (rm -rf dist → npm run build → nginx reload)
- **Deployed:** `dist/` served by Nginx
- **Games:** `public/games/` as self-contained HTML files; listed in `public/game_list.json`
- **Site stack:** Vue SPA with UnoCSS, Vite build
- **Design:** Futuristic neon — dark bg #0a0a0f/#0a192f, cyan #00f0ff/#64ffda, magenta #ff00aa, green #00ff88, Orbitron + Inter fonts

## Models
- **Default:** Kimi K2.5 (openrouter/moonshotai/kimi-k2.5) with fallbacks: Gemini 2.5 Flash
- **Game creation:** Opus 4.6 via sub-agents preferred
- **34 models available** across Anthropic, Google, OpenRouter

## Channels
- WhatsApp, Telegram, Discord all enabled
- Discord: server channel #general `1471964961260699659`, groupPolicy "open"
- **Telegram issue (Mar 2-3, 2026):** Bot token missing (TELEGRAM_BOT_TOKEN not set). Weather cron unable to send messages via Telegram.

## Cron Job: Daily Game Generator
- **ID:** `f307e8ff-7822-4b5d-98bb-37934294261f`
- **Schedule:** 45 10 * * * UTC (5:45 AM Eastern)
- **Model:** GPT-5 Codex (gpt5codex) — updated Feb 24, 2026
- **Flow:** Multi-agent collaborative pipeline: 3 ideation agents (Grok/Kimi/Gemini) → cross-evaluation → consensus (Sonnet) → present 5 ideas to Sky → architecture (Sonnet) → collaborative build (Grok + Sonnet refinement) → deploy → document
- **Categories:** games, interactive art, simulations, music tools, physics toys, data viz, creative tools, puzzles

## Email
- **Provider:** Himalaya (IMAP/SMTP)
- **Accounts:** `rexuvia` (default), `rexuvia-sky`
- **Valid aliases:** `hi@rexuvia.com` (default), `sky@rexuvia.com`
- **Folders:** INBOX, Junk E-mail, Archive, skylrs, FunctionDesk, spout.dev, IPMailROOM, skjp.dev, Outbox, Deleted Items, Sent Items, Drafts

## Notion
- Budget DB data_source_id: `abcfe730-9c7f-46fe-84d9-b8a9f8c07d40`

## 🚨 CRITICAL: Website Deployment (March 6, 2026)
**Issue:** CSS/text updates not showing after using `deploy.sh --modelshow` for website changes
**Root Cause:** `deploy.sh --modelshow` only syncs ModelShow results, doesn't rebuild site or update HTML/CSS/JS
**Solution:** For ANY website changes (CSS, text, components, HTML), use:
```bash
cd ~/.openclaw/workspace/rexuvia-site
./update-site.sh   # OR: bash rebuild.sh
```
**Documentation Created:**
- `rexuvia-site/README_FOR_AGENTS.md` - Start here
- `rexuvia-site/update-site.sh` - Safe deployment script
- `rexuvia-site/AGENT_DEPLOYMENT_README.md` - Quick reference
- `rexuvia-site/DEPLOYMENT_CHECKLIST.md` - Step-by-step
- `rexuvia-site/DEPLOYMENT_GUIDE.md` - Technical details

## Games on Site
1. Glitch Loom (March 4, 2026: Weave pixel-sorted and datamoshed strands into glitch art tapestries — 5 weave patterns, 6 pixel-sort metrics, 4 datamosh effects, animation engine with GIF export)
2. Memory Palace Builder (March 3, 2026: 3D interactive spatial memory system using Three.js with WASD navigation, custom color/label object placement, and recall practice mode)
3. Flock Mind (boids simulation — March 1, 2026: emergent flocking behavior with attract/repel interaction, spatial grid optimization for 1000+ particles at 60fps)
4. Word Bird (v5 — odd-one-out category game)
5. Pendulum Waves (v1)
6. Neon Synth Pad
7. Sort Cinema (15 algorithms with Learn More modals)
8. Signal Scope (real-time audio analyzer, 8 notation formats, pitch history)
9. Neural Knot Untangler (3D graph puzzle — improved Feb 24, 2026 with GPT-5 Codex: win detection, crossing counter, instructions, difficulty levels)

## Game Repos
- Local repos at `/home/ubuntu/.openclaw/workspace/game-repos/game-<name>/` or `/home/ubuntu/.openclaw/workspace/game-repos/<name>/`
- Each has index.html + README + .gitignore
- All on GitHub under rexuvia account
- Current repos: glitch-loom, memory-palace-builder, flock-mind, word-bird, pendulum-waves, neon-synth-pad, sort-cinema, signal-scope, mirror-maze, lava-flow, elemental-garden, echo-weaver, cell-symphony, neural-knot-untangler

## GitHub
- **Bot Account (rexuvia):** Primary account for all Rexuvia projects
  - `gh` CLI active account with PAT
  - **Global git identity:** `rexuvia <rexuvia@users.noreply.github.com>`
  - Repos: flock-mind, mirror-maze, lava-flow, signal-scope, sort-cinema, neon-synth-pad, pendulum-waves, word-bird, rexuvia-site
  - All game repos and site repos use this account
  
- **Personal Account (schbz):** Sky's personal account
  - `gh` CLI secondary account with PAT
  - Repos: florida-caves (private), rexuvia-spout-notes (private)
  - Use local git config override when working on Sky's personal repos: `git config user.name "schbz" && git config user.email "schbz@users.noreply.github.com"`
  
- **Strategy:** Default to rexuvia (global config). Override locally only for Sky's personal repos when explicitly requested
- **Workflow:** Sky sends natural language git commands via Telegram, I execute them
- **Cloned repos live at:** `/home/ubuntu/.openclaw/workspace/<repo-name>/`

## Key Lessons
- Always `rm -rf dist` before Vite build to prevent stale cache
- Games must be single self-contained HTML files, mobile-first
- Sub-agent pattern works well for game creation with detailed prompts
- Static HTML games live in `public/games/`, Vue SPA handles routing
- **Sub-agents CANNOT spawn sub-agents** (no nested spawning). For multi-model swarms, orchestrate from the main session — spawn each phase directly with the right model, read outputs between phases, then spawn the next. Don't use a "coordinator" sub-agent for this.
- Always verify git pushes landed on GitHub (check via `gh api`) — local git can say "up to date" while remote is stale
- **Git commit authorship:** Comes from `git config user.name/email`, NOT from `gh` CLI active account. Global config now set to rexuvia. Use local overrides (`git config --local`) for Sky's personal repos when needed.
- **Isolated cron sessions can't reliably send Telegram messages.** Use main session systemEvent for simple tasks, or explicitly instruct isolated agents to use the message tool with exact params.
- **Validate JS in generated HTML** before deploying — Unicode characters (curly quotes etc.) can silently break entire scripts
- **GPT-5 Codex** excels at game improvements — successfully added full gameplay loop to Neural Knot Untangler (win detection, crossing counter, instructions, difficulty levels) in single shot
- **GitHub Issues:** Always close the GitHub issue immediately after successfully addressing it and confirming the fix.

## ThinkTank Skill (New Project - Feb 23, 2026)
- **Repo:** https://github.com/schbz/openclaw-skill-thinktank (private, schbz account)
- **Local:** `/home/ubuntu/.openclaw/workspace/openclaw-skill-thinktank/`
- **Purpose:** Multi-model swarm intelligence skill for OpenClaw
- **Keyword:** `thinktank` (not "swarm")
- **Status:** Prototype v0.1.0, iterating via cron-based improvements
- **Git identity:** schbz (personal project)

### Improvement Pipeline (3 Cron Jobs)
**Round 1:** Tomorrow 6 AM ET (11:00 UTC) - ID: `ee7d957f-1919-4d67-9e70-15e4d49c1e5c`
- Analyzes skill, proposes 3 improvements
- Sends options via Telegram, waits for Sky's selection (1, 2, or 3)
- Replies with `IMPROVEMENT_PENDING_ROUND_1` marker

**Round 2:** Tomorrow 7 AM ET (12:00 UTC) - ID: `c07565c5-dbdf-4f03-9cd0-b15a725ad57e`
- Builds on Round 1, proposes 3 new improvements
- Replies with `IMPROVEMENT_PENDING_ROUND_2` marker

**Round 3:** Tomorrow 9 AM ET (14:00 UTC) - ID: `cd0f5229-03fb-4286-b0c2-a7578a98b611`
- Final polish round, proposes 3 improvements
- Replies with `IMPROVEMENT_PENDING_ROUND_3` marker

**How it works:**
1. Cron runs in main session, analyzes repo, sends 3 options via Telegram
2. Replies with `IMPROVEMENT_PENDING_ROUND_X` and stops
3. When Sky replies with "1", "2", or "3", I (main session) detect it's a thinktank response
4. I spawn a sub-agent to execute the chosen improvement
5. Sub-agent commits and pushes to GitHub
6. Confirms completion to Sky

**Detection logic:** When Sky sends "1", "2", or "3" shortly after seeing IMPROVEMENT_PENDING marker, it's a thinktank selection.

## Daily Issue Fixer Workflow Improvement (March 17, 2026)
**Problem:** Fixing GitHub issues only updated repositories, not the live website
**Solution:** Enhanced workflow with complete website synchronization
**Changes made:**
1. Updated `daily-issue-fixer-agent-task.md` with complete website update instructions
2. Created `daily-fixer-agent-instructions-template.md` for consistent agent prompts
3. **Complete workflow now includes:**
   - GitHub repo fix
   - Website game file update (if exists)
   - `game_list.json` date update
   - Website rebuild and deploy
   - CloudFront cache invalidation
   - Verification of live updates
**Result:** Future fixes will update everything automatically when Sky responds "1 4"

## Daily Issue Fixer Milestone (April 9-15, 2026)
**Achievement:** All rexuvia/* repositories have zero open issues for 7 consecutive days!
**Status:** Backlog fully cleared and maintained - 22 repositories checked daily, no open issues from schbz or any other users
**Processed Issues (6 total):**
- elemental-garden#1
- glitch-loom#5, #6, #7, #9, #10
**System:** Daily checks continue to maintain clean state - system now in maintenance mode with 7-day streak

## Pending
- Pendulum Gate implementation (design doc at `rexuvia-site/pendulum-redesign.md`)
- ThinkTank skill improvements (3 rounds scheduled for tomorrow)
- ThinkTank public release (after improvements complete)
