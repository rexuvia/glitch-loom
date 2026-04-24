# ModelShow Results
**Date:** 2026-03-06T16:44:00Z
**Prompt:** Generate a comprehensive creative list of ideas for daily or weekly cronjob prompts that would help Sky make the most of the capabilities of the OpenClaw agentic platform and others like it. Focus on practical, valuable automation that leverages OpenClaw's unique features: multi-model capabilities, sub-agent orchestration, file system access, web tools, messaging, cron management, and integration with external services.
**Models:** openrouter/x-ai/grok-4, openrouter/moonshotai/kimi-k2.5, google/gemini-2.5-flash
**Judge:** openrouter/anthropic/claude-sonnet-4.6
**Judging Mode:** Blind (model identities hidden from judge)

---

## Rankings

### 🏆 **openrouter/moonshotai/kimi-k2.5** — 9.2/10

**Judge's Assessment:**
kimi demonstrates exceptional depth and creativity with 24 well-developed automations spanning all requested categories. Its sample prompts are technically sophisticated, showing genuine understanding of multi-agent orchestration with named sub-agents, conditional logic, file path conventions, and self-modifying cron schedules.

**Full Response:**
 Here is a comprehensive automation blueprint for Sky, leveraging OpenClaw's orchestration capabilities to create a self-managing digital ecosystem.

## Personal Productivity

### 1. Context-Aware Morning Briefing Orchestrator
**Description:** An intelligent morning assistant that synthesizes calendar, communications, biometrics, and world events into a prioritized action briefing with suggested prep work.

**Schedule:** Daily, 6:30 AM (adjusted by sleep data)
- **Key Features:** Multi-model orchestration (GPT-4 for analysis, Claude for writing, local model for privacy-sensitive content), sub-agent tasking, messaging integration, file system journaling
- **Value Prop:** Eliminates morning decision fatigue; ensures you're never unprepared for meetings
- **Sample Prompt:**
  ```
  OpenClaw> Execute Morning Protocol:
  1. Spawn [CalendarAgent]: Analyze today's events, check for conflicts, download attachments, prep briefing docs.
  2. Spawn [CommAgent]: Scan emails/Slack since 6 PM yesterday. Flag >Urgent. Generate reply drafts for starred items.
  3. Spawn [ContextAgent]: Check weather, traffic patterns, and news sentiment for industry keywords.
  4. Spawn [BioAgent]: Access Oura API. If sleep score <70, suggest lighter schedule or defer non-criticals.
  5. Synthesis Model: Create prioritized markdown at /briefings/morning/{{date}}.md
  6. If CriticalAlerts > 0: Send SMS summary immediately.
  Else: Send rich email brief at 7:00 AM.
  7. Auto-update cron: If wake_time > 7:30 AM detected yesterday, adjust tomorrow's trigger to 7:00 AM.
  ```

### 2. Deep Work Session Guardian
**Description:** Automated focus session manager that prepares environment, blocks distractions, and handles interruptions gracefully.

**Schedule:** Daily, configurable trigger (e.g., 9:00 AM and 2:00 PM)
- **Key Features:** Sub-agent delegation, external API integration (smart lights, Slack status, do-not-disturb), file system (session logging)
- **Value Prop:** Protects deep work blocks; handles communication triage automatically
- **Sample Prompt:**
  ```
  OpenClaw> Initiate Focus Mode [Duration: 90min]:
  1. [EnvironmentAgent]: Call HomeAssistant API - set lights to focus temp, enable DND on phone.
  2. [StatusAgent]: Set Slack/Discord to "Deep Work - Emergency Only" with auto-responder.
  3. [GuardianAgent]: Monitor notification webhooks. Categorize interruptions:
     - Tier 1 (Boss, Production alerts): Immediate notification with 30-sec decision window
     - Tier 2 (Colleagues): Generate polite deferral responses
     - Tier 3 (Noise): Queue for batch review
  4. [JournalAgent]: Write session intent to /focus_sessions/{{datetime}}.md
  5. Post-session: Generate distraction report, restore communication states, log productivity score.
  ```

### 3. Weekly Knowledge Triage & Archive
**Description:** Processes scattered notes, screenshots, and recordings from the week into an organized second brain.

**Schedule:** Weekly, Sunday 5:00 PM
- **Key Features:** Multi-model (Whisper for audio, Vision for images, GPT for text), file system reorganization, vector DB integration
- **Value Prop:** Prevents information loss; maintains clean inbox zero for creative inputs
- **Sample Prompt:**
  ```
  OpenClaw> Triage Weekly Capture:
  1. Scan: /capture/inbox/ (photos, audio memos, quick notes, screenshots)
  2. For each item:
     - [VisionModel]: Extract text from screenshots, classify as Receipt/Reference/Idea/Todo
     - [AudioModel]: Trans voice memos, tag sentiment
  3. Route:
     - Receipts → /finance/expenses/awaiting_review/
     - Bookmarks/articles → Readwise API
     - Ideas → Obsidian vault with [[linking]] suggestions
     - Action items → Todoist with context
  4. Generate "Week in Review" with synthesized themes and forgotten items to resurface.
  ```

## Creative Projects

### 4. Multi-Modal Inspiration Harvester
**Description:** Curates personalized inspiration from across the web based on current project mood boards and past saves.

**Schedule:** Daily, 8:00 PM (low-energy creative time)
- **Key Features:** Web scraping, vision model analysis, Pinterest/Are.na API integration, file system curation
- **Value Prop:** Maintains fresh inspiration without doom-scrolling
- **Sample Prompt:**
  ```
  OpenClaw> Harvest Inspiration:
  1. Read /projects/current/moodboard.json for active aesthetic parameters (colors: #2a3b, vibe: "brutalist-nature")
  2. [ScoutAgent]: Search Behance, ArtStation, Archive.org for matches. Download top 5 novel images.
  3. [VisionModel]: Analyze compositions, generate text descriptions, compare against existing /inspiration/ to avoid duplicates.
  4. [CuratorAgent]: Create markdown gallery at /inspiration/daily/{{date}}.md with艺术性 analysis and "steal like an artist" prompts.
  5. If match score > 0.9 with current project: Send push notification "High-value inspiration found."
  ```

### 5. Creative Accountability Partner
**Description:** Tracks creative project momentum through git commits, file modifications, and check-ins, providing encouragement or tough love.

**Schedule:** Daily, 10:00 PM
- **Key Features:** Git integration, file system monitoring, sentiment analysis on journal entries, messaging
- **Value Prop:** Maintains streaks and identifies blocks before they become abandonment
- **Sample Prompt:**
  ```
  OpenClaw> Creative Pulse Check:
  1. Analyze git activity across ~/projects/ for last 24h. Calculate "creative velocity" (lines changed, commits, new files).
  2. Read /journal/creative.txt for sentiment analysis. Detect frustration keywords.
  3. If velocity = 0 AND no journal entry: 
     - Send gentle prompt: "No creative work today. 5-minute micro-project?"
  4. If velocity > threshold: 
     - Generate celebration message with stats visualization
     - Update /projects/streaks.json
  5. Weekly: Create visual progress report (ASCII art or SVG) showing consistency.
  ```

### 6. Asset Library Tagging & Cross-Reference
**Description:** Auto-organizes creative assets (fonts, textures, 3D models) using AI vision and creates smart cross-references.

**Schedule:** Weekly, Saturday morning
- **Key Features:** Vision models for image analysis, file system crawling, metadata writing, database updates
- **Value Prop:** Makes years of hoarded assets actually discoverable
- **Sample Prompt:**
  ```
  OpenClaw> Archive Maintenance:
  1. Scan /assets/unprocessed/ for new files.
  2. [VisionAgent]: Generate color palette, detect style (photorealistic, low-poly, etc.), identify objects.
  3. [TextAgent]: Read any READMEs, extract keywords.
  4. Write standardized metadata JSON alongside files.
  5. Update central SQLite index with cross-references ("This texture matches color scheme of Project X").
  6. Move to /assets/catalogued/{{category}}/ with standardized naming.
  7. Generate "Forgotten Treasures" report: surface unused assets relevant to current projects.
  ```

## Health & Wellness

### 7. Holistic Health Dashboard Generator
**Description:** Aggregates disparate health data (wearables, nutrition logs, mood journals) into actionable weekly reports with predictive insights.

**Schedule:** Weekly, Monday 6:00 AM
- **Key Features:** Multi-API integration (Oura, Apple Health, Cronometer), multi-model analysis, visualization generation, messaging
- **Value Prop:** Identifies subtle patterns (e.g., "Your sleep degrades when you have 3+ coffees after Tuesday")
- **Sample Prompt:**
  ```
  OpenClaw> Health Weekly Review:
  1. [DataAgent]: Pull Oura (sleep), Apple Health (activity), Cronometer (nutrition), Exist (mood) APIs.
  2. [AnalystModel]: Correlate variables. Look for lagging indicators (mood vs. sleep debt).
  3. [CoachModel]: Generate recommendations prioritizing lowest metric.
  4. Create: /health/reports/weekly_{{date}}.html with embedded Chart.js visualizations.
  5. If HRV < baseline -10% for 3 days: Escalate to "Recovery Protocol" - suggest rest day, send notification.
  6. Archive raw data to /health/exports/ for long-term trend analysis.
  ```

### 8. Medication & Supplement Optimizer
**Description:** Tracks adherence and physiological responses to supplements, suggesting timing adjustments based on energy and sleep data.

**Schedule:** Daily, 8:00 PM (pre-bed review)
- **Key Features:** File system logging, statistical correlation, messaging reminders
- **Value Prop:** Personalizes supplement stack based on actual biomarker response vs. generic advice
- **Sample Prompt:**
  ```
  OpenClaw> Stack Analysis:
  1. Read /health/supplements/log.json for today's adherence.
  2. Query: Did user report energy crash? (Manual input or detected in journal)
  3. Cross-reference with sleep latency from last night.
  4. If magnesium taken after 4 PM AND sleep onset > 30 min: Suggest tomorrow's magnesium be taken at 2 PM.
  5. If missed > 2 supplements: Send friendly reminder with simplified protocol for tomorrow.
  6. Weekly: Generate "Supplement Efficacy Score" - which ones correlate with good days?
  ```

### 9. Nature Exposure & Circadian Enforcer
**Description:** Monforms indoor/outdoor time and light exposure, adjusting smart home and sending prompts to maintain circadian health.

**Schedule:** Daily, multiple triggers (sunrise, solar noon, sunset)
- **Key Features:** External APIs (sun times, weather), IoT integration (smart lights), geofencing/messaging
- **Value Prop:** Prevents "cave mode" during remote work; optimizes vitamin D and cortisol patterns
- **Sample Prompt:**
  ```
  OpenClaw> Circadian Check (Solar Noon):
  1. Check weather API. If sunny and UV > 3:
     - Calculate optimal 10-min outdoor window.
     - Send notification: "Step outside in next 30 min for circadian anchor."
  2. If indoor time > 3h (detected by router/phone location):
     - Trigger smart lights to 5500K.
     - Play alert sound on HomePod.
  3. Sunset -30min: Gradually dim lights to candlelight mode.
  4. Log exposure to /health/light_therapy.log for seasonal correlation analysis.
  ```

## Learning & Education

### 10. Spaced Repetition Orchestrator with Context
**Description:** Advanced Anki/RemNote manager that not only schedules reviews but pre-fetches relevant context and creates synthesis connections.

**Schedule:** Daily, 7:00 AM
- **Key Features:** SRS algorithm implementation, web search for updated info, file system knowledge base, sub-agent creation
- **Value Prop:** Moves beyond rote memorization to living knowledge that updates with current events
- **Sample Prompt:**
  ```
  OpenClaw> Knowledge Maintenance:
  1. Pull due cards from /learning/srs/database.json.
  2. For each "news" or "tech" tagged card:
     - [WebAgent]: Search for updates since card creation. Append "Latest developments" section.
  3. For conceptual clusters (>5 related cards due):
     - [SynthesisAgent]: Generate new "Connecting the Dots" card linking concepts.
  4. Create today's deck at /learning/daily_review.html with ambient music suggestion based on difficulty level.
  5. If accuracy < 80% on last session: Temporarily reduce new cards, suggest review of fundamentals.
  ```

### 11. Research Paper Digest & Contrarian Analysis
**Description:** Processes saved academic papers, generates ELI5 summaries, and actively seeks contradictory evidence to prevent echo chambers.

**Schedule:** Weekly, Wednesday 7:00 AM
- **Key Features:** PDF parsing, multi-model (summarization + critique), web search for counter-arguments, file annotation
- **Value Prop:** Actually reads your "Read Later" papers; builds critical thinking
- **Sample Prompt:**
  ```
  OpenClaw> Academic Triage:
  1. Scan /papers/unread/*.pdf. Prioritize by publication date and your current projects.
  2. [Summarizer]: Extract core thesis, methodology flaws, key findings.
  3. [DevilsAdvocate]: Search Semantic Scholar for papers citing contradictions.
  4. Create: /papers/digests/{{title}}.md with:
     - One-paragraph summary
     - "Why this might be wrong" section
     - Connection to your existing notes (auto-link [[concepts]])
  5. Move source PDF to /papers/processed/ with metadata tags.
  6. If breakthrough concept detected: Alert user with "Potential paradigm shift" flag.
  ```

### 12. Language Immersion Simulator
**Description:** Creates daily mini-immersion experiences by rewriting your actual data (emails, notes) in target language with progressive difficulty.

**Schedule:** Daily, 12:00 PM (lunch break)
- **Key Features:** File system access to personal content, translation models, TTS generation, messaging with audio
- **Value Prop:** Learns language relevant to your actual life, not generic textbook scenarios
- **Sample Prompt:**
  ```
  OpenClaw> Immersion Moment:
  1. Select 3 random recent entries from / journaling/ (respect privacy filters).
  2. [TranslationAgent]: Translate to {{target_language}} at current CEFR level +1 (stretch).
  3. [AudioAgent]: Generate TTS with native speaker voice, save to /language/audio/immersion_{{date}}.mp3.
  4. Create short quiz: 5 comprehension questions about the translated content.
  5. Send: Message with translation, audio file, and 3 new vocabulary words extracted with context.
  6. Track: Add unknown words toSRS queue, update progress in /language/stats.json.
  ```

## Home Automation

### 13. Predictive Home Maintenance Scanner
**Description:** Analyzes IoT sensor data (fridge temp, HVAC cycles, water pressure) to predict failures before they happen.

**Schedule:** Weekly, Sunday 8:00 AM
- **Key Features:** IoT integration, statistical anomaly detection, external API (zillow for appliance values), messaging
- **Value Prop:** Prevents emergency repair costs; extends appliance lifespan
- **Sample Prompt:**
  ```
  OpenClaw> Home Health Check:
  1. Query Home Assistant: 
     - HVAC runtime vs. degree days (efficiency trending?)
     - Fridge compressor cycle frequency (failing seal?)
     - Water heater energy usage patterns
  2. [PredictionModel]: Compare against ideal baselines. Calculate "failure probability score."
  3. If score > 0.7: Search local appliance repair APIs for availability, check warranty status, generate cost-benefit analysis of repair vs. replace.
  4. Create maintenance schedule: /home/maintenance_queue.json
  5. Auto-order: If HVAC filter > 90 days old, add Amazon Fresh cart link to weekly summary.
  ```

### 14. Energy Arbitrage Optimizer
**Description:** Monitors real-time electricity pricing and solar production to automatically schedule high-draw appliances for cheapest rates.

**Schedule:** Daily, 10:00 PM (scheduling next day)
- **Key Features:** API integration (utility company, solar inverter), IoT control (smart appliances), cron adjustment
- **Value Prop:** Reduces energy bills without lifestyle changes; maximizes solar self-consumption
- **Sample Prompt:**
  ```
  OpenClaw> Energy Strategy:
  1. Pull: Tomorrow's hourly utility rates from API, weather forecast (solar prediction).
  2. [Optimizer]: Schedule dishwasher, water heater, EV charging for lowest cost windows.
  3. If storm forecast: Pre-cool house, cancel solar-dependent tasks, ensure battery backup charged.
  4. Push schedules to IoT devices.
  5. Send: "Tomorrow's estimated savings: $X. Peak hours: Y-Z (avoid high usage)."
  6. Learn: Adjust weights based on actual vs. predicted solar generation.
  ```

## Financial Tracking

### 15. Transaction Narrative Intelligence
**Description:** Replaces boring spreadsheets with AI-generated financial stories that detect emotional spending patterns and lifestyle creep.

**Schedule:** Daily, 9:00 PM
- **Key Features:** Banking API integration (Plaid), categorization models, sentiment analysis, messaging
- **Value Prop:** Makes budgeting engaging; catches subscription creep and impulse patterns
- **Sample Prompt:**
  ```
  OpenClaw> Financial Narrative:
  1. [LedgerAgent]: Pull today's transactions from Plaid.
  2. [NarratorModel]: Write 3-paragraph story of day's spending:
     - "Today you invested in..." (productive spending)
     - "The $4 coffee tax..." (latte factor tracking)
     - "Alert: Dining out 40% above monthly average" (anomaly detection)
  3. Categorize: Enhanced tagging (e.g., "Emotional - Retail Therapy" vs "Planned - Replacement").
  4. Check: New recurring charges? Flag potential forgotten trials.
  5. Send: Rich notification with today's "financial vibe" and tomorrow's budget status.
  6. Export: Append to /finance/journal/{{month}}.md for long-term reflection.
  ```

### 16. Investment Thesis Validator
**Description:** Monitors portfolio holdings against breaking news and earnings, providing briefs on whether original investment thesis still holds.

**Schedule:** Weekly, Friday 4:00 PM (market close)
- **Key Features:** Financial APIs (AlphaVantage, Finnhub), web news scraping, multi-model analysis, alerting
- **Value Prop:** Prevents holding onto stocks based on outdated information; captures sell signals
- **Sample Prompt:**
  ```
  OpenClaw> Portfolio Check-up:
  1. List: Current holdings from /finance/portfolio.json.
  2. For each holding:
     - [NewsAgent]: Scrape earnings transcripts, SEC filings, recent analyst changes.
     - [ThesisModel]: Compare against original investment thesis (stored in file).
     - Score: Alignment 0-100%.
  3. If score < 50%: Generate "Reconsideration Brief" with pros/cons of exit.
  4. If new competitor/disruptor detected in sector: Send alert with impact analysis.
  5. Create: Weekly dashboard with rebalancing suggestions based on drift from target allocation.
  ```

## Social Media Management

### 17. Authentic Engagement Response System
**Description:** Drafts genuine replies to comments/messages by analyzing conversation history and your voice, queueing for approval.

**Schedule:** Daily, 11:00 AM and 4:00 PM
- **Key Features:** API integration (Twitter, Instagram, LinkedIn), multi-model (voice matching, sentiment analysis), file system (voice profile)
- **Value Prop:** Maintains relationships without constant phone checking; ensures consistent brand voice
- **Sample Prompt:**
  ```
  OpenClaw> Engagement Batch:
  1. [MonitorAgent]: Pull unread mentions/DMs across platforms (respect rate limits).
  2. Filter: Remove spam, prioritize VIPs (list in /social/tier1_contacts.txt).
  3. [VoiceAgent]: Draft replies matching /config/my_voice_profile.json (witty/professional/supportive).
  4. Queue: Save to /social/outbox/pending_approval/ with context snippets.
  5. Send digest: "5 replies drafted. Review here: [link]. Auto-post in 2 hours unless vetoed."
  6. Learn: Update voice profile based on which drafts you edit vs. approve raw.
  ```

### 18. Content Recycling & Platform Adaptation
**Description:** Transforms long-form content (newsletters, blogs) into platform-native formats automatically while preserving nuance.

**Schedule:** Weekly, Tuesday 10:00 AM
- **Key Features:** File system (source content), multi-model (thread writers, hashtag researchers), image generation integration, scheduling APIs
- **Value Prop:** Maximizes ROI on content creation; maintains multi-platform presence efficiently
- **Sample Prompt:**
  ```
  OpenClaw> Content Atomization:
  1. Source: Read /content/newsletters/latest.md.
  2. [AtomizerAgent]: Create:
     - Twitter/X thread (5 tweets with hooks)
     - LinkedIn post (professional angle, 3 paragraphs)
     - Instagram carousel (text extraction + image prompts)
     - TikTok script (trending audio suggestions)
  3. [VisualAgent]: Generate 3 image variations for each platform using DALL-E/SD API.
  4. Post to scheduling tool (Buffer/Hypefury) with optimal timing per platform.
  5. Archive: Save repurposing map to /content/repurposed/{{date}}.json to avoid duplication.
  ```

## Content Creation

### 19. Living Document Collaboration Partner
**Description:** Maintains "evergreen" documents (READMEs, style guides, wikis) by auto-updating them when source material changes.

**Schedule:** Daily, 6:00 AM
- **Key Features:** Git integration, file system watching, multi-model (diff analysis, technical writing), PR creation
- **Value Prop:** Prevents documentation rot; reduces manual sync between code and docs
- **Sample Prompt:**
  ```
  OpenClaw> Documentation Sync:
  1. [WatchAgent]: Check git diffs in /src/ since last run for public API changes.
  2. [TechWriter]: Update corresponding markdown in /docs/.
  3. [ValidationAgent]: Run dead link check, code example syntax validation.
  4. If significant changes: Create git branch "docs/auto-update-{{date}}", commit, open PR with summary of changes.
  5. If breaking changes detected: Add "ATTENTION" banner to top of affected docs.
  6. Generate: Changelog entry suggestions for next release.
  ```

### 20. Newsletter Curation with Synthesis
**Description:** Reads RSS feeds and newsletters you subscribe to, creates personalized briefing with commentary, and suggests original angles.

**Schedule:** Daily, 7:00 PM
- **Key Features:** RSS parsing, paywall bypass tools, summarization models, file system, email integration
- **Value Prop:** Consolidates information diet; prevents filter bubbles by highlighting gaps
- **Sample Prompt:**
  ```
  OpenClaw> Information Diet:
  1. [Fetcher]: Download unread items from 50+ feeds (respect robots.txt, cache smartly).
  2. [FilterAgent]: Remove topics on /blocklist.txt, prioritize rare topics (diversity boost).
  3. [Synthesizer]: Group related stories, identify conflicting narratives between sources.
  4. [AngleGenerator]: Suggest 3 original essay angles based on gaps in coverage.
  5. Create: Personal newsletter at /newsletter/draft.md with sections:
     - "What You Missed"
     - "Consensus Check" (what everyone agrees on - beware)
     - "Rabbit Holes" (deep dives for weekend)
  6. Send: Email with click-to-add-to-calendar for suggested reading blocks.
  ```

### 21. SEO Opportunity Scout
**Description:** Monitors search trends in your niche and identifies underserved keywords with high traffic potential.

**Schedule:** Weekly, Monday 9:00 AM
- **Key Features:** Google Trends API, Ahrefs/SEMrush scraping, NLP keyword analysis, file system
- **Value Prop:** Finds content gaps before competitors; data-driven editorial calendar
- **Sample Prompt:**
  ```
  OpenClaw> SEO Intelligence:
  1. [TrendAgent]: Pull rising queries in domain {{your_niche}}.
  2. [GapAnalyzer]: Cross-reference with your existing content inventory. Find "high volume, low competition, zero coverage."
  3. [IntentClassifier]: Categorize opportunities (Informational/Commercial/Transactional).
  4. Generate: /content/opportunities/{{week}}.csv with:
     - Keyword, Volume, Difficulty, Current Top 3 Weaknesses, Suggested Angle
  5. Prioritize: Based on alignment with ongoing projects and expertise.
  6. Auto-draft: For top 3 opportunities, generate outline and save to /content/drafts/opportunity_{{keyword}}.md.
  ```

## System Maintenance

### 22. Digital Hygiene Deep Clean
**Description:** Archives old files, deduplicates photos, clears caches, and optimizes storage with intelligent retention policies.

**Schedule:** Weekly, Saturday 3:00 AM (low-usage time)
- **Key Features:** File system access, image deduplication hashing, compression algorithms, cloud API integration
- **Value Prop:** Prevents storage crises; maintains system performance; preserves important memories
- **Sample Prompt:**
  ```
  OpenClaw> Hygiene Protocol:
  1. [CleanerAgent]:
     - Downloads folder: Files >30 days old → Archive or Trash (based on extension whitelist)
     - Screenshots: OCR text extraction, then compress to 80% quality
     - Duplicates: Hash comparison, keep highest-res version
  2. [PhotoAgent]: Face recognition clustering, suggest album creation for events.
  3. Git maintenance: Run git gc on all repos, check for unpushed commits >7 days.
  4. Generate report: Space saved, items archived, security scan results (malware check).
  5. If < 20% storage remaining: Escalate to "Emergency Clean" mode with aggressive policies.
  6. Backup verification: Check cloud sync status, verify last backup timestamp.
  ```

### 23. Toxic Digital Relationship Cleanser
**Description:** Analyzes social feeds for accounts that consistently cause negative sentiment and suggests unfollows/mutes.

**Schedule:** Weekly, Sunday 7:00 PM
- **Key Features:** Social API access, sentiment analysis on engagement patterns, messaging recommendations
- **Value Prop:** Curates mental health by removing algorithmic amplification of stress
- **Sample Prompt:**
  ```
  OpenClaw> Social Audit:
  1. [AnalysisAgent]: Review interactions from past week. Flag accounts where:
     - You scroll past without engaging (disinterest)
     - Engagement leaves you feeling negative (sentiment analysis on your replies)
     - High frequency posting (noise)
  2. Generate: "Mute Suggestions" list with reasoning ("Mutual follows but no meaningful interaction in 90 days").
  3. [AlternativeAgent]: Suggest 3 accounts to follow that match interests but have positive sentiment scores.
  4. If doom-scrolling detected (>30 min sessions, 3x frequent): Suggest app limits for next week.
  5. Create: /wellbeing/social_audit/{{date}}.md with before/after feed quality estimates.
  ```

### 24. Dependency & Security Sentinel
**Description:** Monitors project dependencies for vulnerabilities, license changes, and update opportunities with impact assessment.

**Schedule:** Daily, 6:00 AM
- **Key Features:** Repository scanning (GitHub API), CVE databases, semantic versioning analysis, automated PR creation
- **Value Prop:** Prevents security debt; catches breaking changes early
- **Sample Prompt:**
  ```
  OpenClaw> Security Sweep:
  1. Scan: All repos in ~/projects for package.json, requirements.txt, Cargo.toml, etc.
  2. [SecurityAgent]: Check against CVE database, npm audit, Snyk API.
  3. [LicenseAgent]: Detect license changes in dependencies (GPL contamination risk).
  4. [ImpactAgent]: For updates available, analyze changelog for breaking changes and effort estimate.
  5. Generate: Consolidated report grouped by severity.
  6. Auto-fix: For patch-level security updates with CI passing, create PRs automatically.
  7. Alert: If critical CVE in production dependency, send immediate SMS.
  ```

---

## Implementation Strategy for Sky

**Phase 1 (Week 1):** Start with Category 1 (Morning Briefing) and Category 10 (Spaced Repetition) - these provide immediate daily value.

**Phase 2 (Week 2-3):** Add Category 15 (Financial Narrative) and Category 22 (Digital Hygiene) - set-and-forget automations.

**Phase 3 (Month 2):** Implement sub-agent orchestration for Category 4 (Inspiration Harvester) and Category 19 (Living Documents) - these leverage OpenClaw's unique multi-model strengths.

**Critical Configuration:** Store all cron triggers in `/config/crons.json` so OpenClaw can self-modify schedules based on performance (e.g., moving heavy tasks to off-peak hours if system load detected).

Each prompt should include a `self-critique` instruction at the end, instructing OpenClaw to review its own output for hallucinations before executing file writes or external API calls.

---

### 🥈 **google/gemini-2.5-flash** — 8.1/10

**Judge's Assessment:**
flash produces a polished, professionally structured list with strong code-style prompt formatting that feels genuinely implementable. The ideas are well-reasoned and cover all categories with solid specificity (actual API names, budget thresholds, specific platforms).

**Full Response:**
Here's a comprehensive and creative list of cronjob prompts designed to help Sky maximize the capabilities of the OpenClaw agentic platform, organized by category.

---

## **Sky's OpenClaw Automation Arsenal: Daily & Weekly Cronjobs**

### **Category: Personal Productivity**

**1. Title: Daily Priority & Schedule Review**
*   **Description:** OpenClaw reviews today's calendar events, outstanding tasks from a Todoist/Asana/Jira integration, and recent Slack/email highlights to suggest a prioritized daily plan. It can also block "focus time" on the calendar if needed.
*   **Schedule:** Daily (Monday-Friday, 7:00 AM)
*   **Key OpenClaw Features Used:** Multi-model (NLP for email/Slack summarization, agent for task prioritization), Sub-agent orchestration (task manager integration, calendar API), Messaging (push notification), Web tools (calendar APIs, task manager APIs), Cron management.
*   **Value Proposition:** Ensures Sky starts each day with a clear, optimized, and personalized agenda, reducing decision fatigue and increasing productivity.
*   **Sample Prompt Structure:**
    ```
    @cron(schedule="0 7 * * 1-5")
    agent.run("daily_planner_agent", {
        "Retrieve calendar events for today from Google Calendar.",
        "Fetch pending tasks from Todoist labeled 'high priority' or due today.",
        "Summarize unread emails from Outlook/Gmail in the last 12 hours looking for actionable items or urgent requests.",
        "Summarize last 10 Slack mentions/DMs from key channels.",
        "Generate a prioritized list of 3-5 main focus tasks for the day, including estimated time allocations.",
        "Suggest optimal time blocks for these tasks on Google Calendar, avoiding existing meetings.",
        "Draft a brief summary and push to Sky's Slack/Teams DM with the daily plan and focus suggestions."
    })
    ```

**2. Title: Weekly Project Progress Check-in**
*   **Description:** OpenClaw gathers updates from various project management tools (Jira, GitHub, Notion), summarizes progress on key initiatives, identifies potential roadblocks, and drafts a concise weekly status report.
*   **Schedule:** Weekly (Monday, 9:00 AM)
*   **Key OpenClaw Features Used:** Multi-model (summarization, trend analysis), Sub-agent orchestration (APIs for PM tools, GitHub), File system access (to store report drafts), Messaging (email draft).
*   **Value Proposition:** Keeps Sky informed on project health without manual data aggregation, allowing proactive intervention and efficient reporting.
*   **Sample Prompt Structure:**
    ```
    @cron(schedule="0 9 * * 1")
    agent.run("weekly_project_status_agent", {
        "Connect to Jira API: Fetch all 'In Progress' tickets assigned to Sky or their team, summarize recent activity and blockers.",
        "Connect to GitHub API: Summarize recent commits, pull requests, and open issues for designated repositories.",
        "Connect to Notion API: Extract updates from project pages or databases marked for weekly review.",
        "Cross-reference task statuses and identify potential bottlenecks or dependencies.",
        "Generate a 250-word weekly progress summary, highlighting key achievements, next steps, and identified risks.",
        "Save the summary as 'Weekly_Project_Report_YY_MM_DD.md' in the 'Reports' folder.",
        "Draft an email to 'team@example.com' with the subject 'Weekly Project Update - [Date]' and attach the report."
    })
    ```

### **Category: Creative Projects**

**3. Title: Daily Creative Spark Generator**
*   **Description:** Provides Sky with a unique creative prompt daily, tailored to their specified interests (e.g., sci-fi writing, abstract painting, music composition). It can include image inspiration, concept suggestions, or writing exercises.
*   **Schedule:** Daily (Monday-Sunday, 8:30 AM)
*   **Key OpenClaw Features Used:** Multi-model (image generation, text generation), Messaging (Slack/Teams DM), Web tools (accessing inspiration platforms, e.g., Unsplash API).
*   **Value Proposition:** Overcomes creative blocks and consistently provides fresh starting points for artistic endeavors.
*   **Sample Prompt Structure:**
    ```
    @cron(schedule="30 8 * * *")
    agent.run("creative_muse_agent", {
        "User interests: sci-fi, cyberpunk, urban exploration, character development.",
        "Generate a unique writing prompt that combines 2-3 of these themes.",
        "Find a high-resolution, royalty-free image from Unsplash that visually inspires the prompt.",
        "Suggest three potential character archetypes or plot hooks related to the prompt.",
        "Compose a short (50-word) inspirational message.",
        "Send the prompt, image URL, and suggestions to Sky's Discord DM."
    })
    ```

**4. Title: Weekly Brainstorm & Content Outline**
*   **Description:** Given a topic or a general area of interest, OpenClaw generates a detailed outline for a blog post, video script, or presentation, including sub-sections, key arguments, and potential research points.
*   **Schedule:** Weekly (Tuesday, 10:00 AM)
*   **Key OpenClaw Features Used:** Multi-model (advanced text generation, logical structuring), Web tools (research via search API), File system access (save outline).
*   **Value Proposition:** Streamlines content creation by providing a solid structural foundation, saving significant initial planning time.
*   **Sample Prompt Structure:**
    ```
    @cron(schedule="0 10 * * 2")
    agent.run("content_outline_agent", {
        "Topic: 'The Future of AI in Personal Productivity'.",
        "Target audience: Tech-savvy professionals and entrepreneurs.",
        "Desired output format: Blog post (1500-2000 words).",
        "Generate a comprehensive outline including:",
        "    - Catchy title suggestions.",
        "    - Introduction (hook, thesis statement).",
        "    - 3-5 main sections with descriptive headings.",
        "    - 2-3 sub-sections for each main section with key points to cover.",
        "    - Potential examples or use cases for each sub-section.",
        "    - Conclusion (summary, future outlook, call to action).",
        "    - 3-5 keywords for SEO optimization.",
        "Save the outline as 'AI_Productivity_Blog_Outline_YY_MM_DD.md' in the 'Content_Plans' folder."
    })
    ```

### **Category: Health/Wellness**

**5. Title: Daily Hydration & Movement Reminder**
*   **Description:** Based on Sky's calendar and activity patterns (if integrated), OpenClaw provides personalized reminders to drink water and take short breaks.
*   **Schedule:** Daily (Monday-Friday, every 2 hours between 9:00 AM - 5:00 PM)
*   **Key OpenClaw Features Used:** Sub-agent orchestration (calendar API), Messaging (push notification), Cron management.
*   **Value Proposition:** Promotes healthy habits by proactively nudging Sky to stay hydrated and active, especially during work hours.
*   **Sample Prompt Structure:**
    ```
    @cron(schedule="0 9-17/2 * * 1-5")
    agent.run("wellness_coach_agent", {
        "Check Sky's Google Calendar for current meetings.",
        "If no meeting is ongoing or starting in the next 15 minutes:",
        "    'Hydration reminder: Grab a glass of water!'",
        "    'Movement reminder: Time for a 5-minute stretch or walk!'"
        "Send these messages to Sky's personal Telegram/Signal chat."
    })
    ```

**6. Title: Weekly Meal Prep & Grocery List Generator**
*   **Description:** OpenClaw generates a 3-day meal plan based on dietary preferences and existing pantry inventory (if provided), then creates a grocery list, prioritizing healthy options.
*   **Schedule:** Weekly (Sunday, 11:00 AM)
*   **Key OpenClaw Features Used:** Multi-model (recipe generation, nutritional analysis), File system access (pantry list input, grocery list output), Web tools (recipe databases, nutritional info).
*   **Value Proposition:** Simplifies meal planning, promotes healthy eating, and reduces food waste by integrating with pantry inventory.
*   **Sample Prompt Structure:**
    ```
    @cron(schedule="0 11 * * 0")
    agent.run("meal_planner_agent", {
        "Dietary preferences: Vegetarian, low sugar, high protein.",
        "Dislikes: Mushrooms, kale.",
        "Pantry inventory (from 'pantry_inventory.txt'): [List of items, e.g., 'quinoa', 'canned chickpeas', 'oats', 'spinach'].",
        "Generate a 3-day (Monday-Wednesday) meal plan (Breakfast, Lunch, Dinner) focusing on simple and quick recipes.",
        "Ensure variety and adherence to dietary preferences.",
        "Create a consolidated grocery list from the meal plan, cross-referencing with pantry inventory to exclude existing items.",
        "Prioritize fresh vegetables, fruits, and whole grains.",
        "Save the meal plan as 'Meal_Plan_YY_MM_DD.md' and the grocery list as 'Grocery_List_YY_MM_DD.txt' in the 'Health_Wellness' folder."
    })
    ```

### **Category: Learning/Education**

**7. Title: Daily Micro-Learning Digest**
*   **Description:** Curates 2-3 short (5-10 minute read) articles, videos, or summaries on a rotating set of specified learning topics, sourced from reputable platforms.
*   **Schedule:** Daily (Monday-Friday, 12:00 PM)
*   **Key OpenClaw Features Used:** Multi-model (content summarization, topic relevance scoring), Web tools (RSS feeds, news APIs, academic search engines), Messaging (email/Slack).
*   **Value Proposition:** Facilitates continuous learning by delivering bite-sized, relevant educational content directly to Sky.
*   **Sample Prompt Structure:**
    ```
    @cron(schedule="0 12 * * 1-5")
    agent.run("micro_learning_agent", {
        "Learning topics: 'Quantum Computing', 'Behavioral Economics', 'Advanced Python Techniques'.",
        "Source preferences: arXiv, MIT Tech Review, Towards Data Science, Stack Overflow Blog.",
        "Find 2-3 highly-rated or recently published articles/summaries (estimated read time < 10 mins) for one of the rotating topics.",
        "Prioritize content that offers practical insights or explains complex concepts clearly.",
        "Extract key takeaways (3 bullet points) for each item.",
        "Compose a summary email to Sky with links, titles, and key takeaways, using the subject: 'Your Daily Micro-Learning Digest: [Topic]'."
    })
    ```

**8. Title: Weekly Skill Practice Challenge**
*   **Description:** Provides Sky with a coding challenge, design exercise, or language practice prompt tailored to their learning goals, along with resources or suggested approaches.
*   **Schedule:** Weekly (Saturday, 10:00 AM)
*   **Key OpenClaw Features Used:** Multi-model (challenge generation, solution hints), Web tools (coding platforms like LeetCode API, design repositories), Messaging (Slack/email).
*   **Value Proposition:** Reinforces learning and encourages active skill development through practical application.
*   **Sample Prompt Structure:**
    ```
    @cron(schedule="0 10 * * 6")
    agent.run("skill_challenge_agent", {
        "Learning goal: Improve Python algorithm efficiency.",
        "Current skill level: Intermediate.",
        "Generate a LeetCode-style coding challenge focusing on array manipulation or dynamic programming.",
        "Include:",
        "    - Problem statement using markdown formatting.",
        "    - Example input/output.",
        "    - Brief explanation of the expected time/space complexity (optional hint).",
        "    - List 2-3 relevant Python concepts to review (e.g., 'hash maps', 'two-pointer technique').",
        "Suggest a relevant resource (e.g., specific section of 'Cracking the Coding Interview' or a GeeksforGeeks article).",
        "Send the challenge to Sky's personal Slack channel."
    })
    ```

### **Category: Home Automation (Conceptual, requires API access for devices)**

**9. Title: Daily Smart Home Optimization**
*   **Description:** Based on Sky's calendar and weather forecast, OpenClaw adjusts smart home settings (thermostat, lighting, blinds) for optimal comfort and energy efficiency before Sky arrives home or wakes up.
*   **Schedule:** Daily (Monday-Friday, 6:30 AM & 5:00 PM)
*   **Key OpenClaw Features Used:** Sub-agent orchestration (smart home APIs, weather API, calendar API), Cron management.
*   **Value Proposition:** Enhances home comfort and energy efficiency automatically, without manual adjustment.
*   **Sample Prompt Structure:**
    ```
    @cron(schedule="30 6 * * 1-5")
    agent.run("morning_home_optimizer_agent", {
        "Get today's weather forecast for Sky's location.",
        "Check Sky's Google Calendar for morning meetings or if 'working from home' is scheduled.",
        "If outdoor temp < 15C and Sky is home/waking up soon: Set thermostat to 21C.",
        "If outdoor temp > 25C and Sky is home/waking up soon: Set thermostat to 24C.",
        "Open smart blinds partially if sunrise is within the last 30 minutes and no rain is expected.",
        "Turn on kitchen lights if it's still dark."
    })

    @cron(schedule="0 17 * * 1-5")
    agent.run("evening_home_optimizer_agent", {
        "Get tonight's weather forecast for Sky's location.",
        "Check Sky's Google Calendar for estimated arrival time home.",
        "If outdoor temp < 10C: Set thermostat to 20C, 30 minutes before arrival.",
        "If outdoor temp > 28C: Set thermostat to 25C, 30 minutes before arrival.",
        "Close smart blinds if sunset is near.",
        "Turn on entryway lights 10 minutes before estimated arrival."
    })
    ```

### **Category: Financial Tracking**

**10. Title: Weekly Spending Breakdown & Alert**
*   **Description:** Aggregates and categorizes transactions from linked bank accounts/credit cards, provides a spending breakdown, and alerts Sky if spending in any category is exceeding a predefined budget.
*   **Schedule:** Weekly (Sunday, 8:00 AM)
*   **Key OpenClaw Features Used:** Sub-agent orchestration (financial APIs like Plaid/Mint access), Multi-model (categorization, anomaly detection), Messaging (email/Slack).
*   **Value Proposition:** Provides clear financial oversight, helps maintain budgets, and identifies potential overspending early.
*   **Sample Prompt Structure:**
    ```
    @cron(schedule="0 8 * * 0")
    agent.run("weekly_spending_analyzer_agent", {
        "Connect to financial service API (e.g., Plaid/Mint) to fetch transactions from the last 7 days.",
        "Categorize transactions (e.g., Groceries, Dining Out, Utilities, Entertainment, Transport).",
        "Define budgets for categories: {'Groceries': 150, 'Dining Out': 100, 'Entertainment': 75}.",
        "Calculate total spending per category.",
        "Generate a summary showing spending for each category and total spending for the week.",
        "If any category exceeds its budget by more than 10%, generate an alert message.",
        "Compose an email to Sky ('sky@example.com') with the subject 'Weekly Spending Report & Budget Check [Date]' and include the summary and any alerts."
    })
    ```

### **Category: Social Media Management**

**11. Title: Daily Content Curation & Scheduling Suggestion**
*   **Description:** Scans news feeds and relevant industry publications for trending topics and high-engagement content, then suggests 2-3 posts for various social media platforms (Twitter, LinkedIn, Instagram) with optimized times.
*   **Schedule:** Daily (Monday-Friday, 9:00 AM)
*   **Key OpenClaw Features Used:** Multi-model (trend analysis, content summarization, engagement prediction), Web tools (news APIs, social media APIs for trend data), Messaging (draft post + suggestions).
*   **Value Proposition:** Keeps Sky's social media presence fresh and relevant with minimal manual effort, maximizing reach and engagement.
*   **Sample Prompt Structure:**
    ```
    @cron(schedule="0 9 * * 1-5")
    agent.run("social_curator_agent", {
        "Target topics: 'AI ethics', 'Future of Work', 'Sustainable Tech'.",
        "Social platforms: Twitter, LinkedIn.",
        "Scan Google News, TechCrunch, and specific RSS feeds for top 5 trending articles related to target topics.",
        "For each top article:",
        "    - Summarize it into a 280-character Twitter thread (3 tweets max).",
        "    - Draft a professional LinkedIn post (150-200 words) with key insights.",
        "    - Suggest optimal posting times for each platform based on general engagement data (e.g., '10:30 AM EST for LinkedIn').",
        "    - Include relevant hashtags.",
        "Compile these suggestions and send them to Sky's Slack DM, with options to directly schedule via Hootsuite/Buffer (if API available)."
    })
    ```

**12. Title: Weekly Engagement & Performance Report**
*   **Description:** Gathers analytics from linked social media accounts (Twitter, LinkedIn, Instagram), summarizes key metrics (followers gained, top posts, engagement rates), and identifies content themes that performed well.
*   **Schedule:** Weekly (Monday, 9:30 AM)
*   **Key OpenClaw Features Used:** Sub-agent orchestration (social media analytics APIs), Multi-model (data analysis, trend identification), File system access (save report).
*   **Value Proposition:** Provides actionable insights into social media performance, helping Sky refine content strategy.
*   **Sample Prompt Structure:**
    ```
    @cron(schedule="30 9 * * 1")
    agent.run("social_analytics_agent", {
        "Connect to Twitter Analytics API: Fetch follower growth, top 3 tweets (by likes/retweets), and overall engagement rate for the last 7 days.",
        "Connect to LinkedIn Analytics API: Fetch new connections, top 3 posts (by impressions/engagement), and reach.",
        "Connect to Instagram Analytics API: Fetch new followers, top 3 posts (by likes/comments), and profile visits.",
        "Summarize these metrics into a concise report (approx. 300 words).",
        "Identify common themes or content types among the top-performing posts.",
        "Suggest 2-3 content strategy improvements based on the performance data.",
        "Save the report as 'Social_Media_Performance_Report_YY_MM_DD.md' in the 'Social_Content' folder."
    })
    ```

### **Category: Content Creation**

**13. Title: Daily Blog Post Idea & Keyword Generator**
*   **Description:** Based on recent industry trends, competitor analysis, and target audience queries, OpenClaw suggests a blog post topic, a catchy title, key sub-headings, and relevant keywords for SEO.
*   **Schedule:** Daily (Monday-Friday, 1:00 PM)
*   **Key OpenClaw Features Used:** Multi-model (trend analysis, keyword research, content suggestion), Web tools (SEO tools API, Google Trends API, competitor scraping), File system access (save ideas).
*   **Value Proposition:** Ensures a consistent pipeline of well-researched and SEO-optimized content ideas, boosting blog visibility and engagement.
*   **Sample Prompt Structure:**
    ```
    @cron(schedule="0 13 * * 1-5")
    agent.run("blog_idea_generator_agent", {
        "Target niche: 'AI in healthcare innovation'.",
        "Target audience: Healthcare professionals, tech investors.",
        "Identify 3 trending topics related to 'AI in healthcare' from Google Trends and relevant news sources.",
        "For each topic, generate:",
        "    - A unique blog post title (5-10 words).",
        "    - 3-5 key sub-headings to cover within the post.",
        "    - 5-7 relevant long-tail keywords with moderate search volume (via keyword research API).",
        "    - A brief (2-3 sentences) summary of the blog post's angle.",
        "Compile these ideas into a structured markdown file 'Blog_Ideas_YY_MM_DD.md' and save in 'Content_Ideas'."
    })
    ```

**14. Title: Weekly Newsletter Draft Generator**
*   **Description:** Aggregates recent blog posts, significant news, and curated external content, then drafts a personalized weekly newsletter, adapting tone and structure for Sky's audience.
*   **Schedule:** Weekly (Thursday, 10:00 AM)
*   **Key OpenClaw Features Used:** Multi-model (content summarization, tone adaptation, email formatting), File system access (access recent blog posts), Web tools (news APIs, RSS feeds), Messaging (email draft).
*   **Value Proposition:** Automates a significant portion of newsletter creation, saving time while maintaining consistent communication with the audience.
*   **Sample Prompt Structure:**
    ```
    @cron(schedule="0 10 * * 4")
    agent.run("newsletter_draft_agent", {
        "Audience: 'Tech enthusiasts and early adopters'.",
        "Newsletter sections: 'Our Latest Post', 'Worth Reading', 'Upcoming Events', 'Tools We Love'.",
        "Fetch the most recent blog post from 'my_blog_posts' folder and draft a 100-word summary.",
        "Find 2 high-quality external articles (last 7 days) on 'generative AI' or 'Web3' from Ars Technica or The Verge; summarize each concisely.",
        "Look for an upcoming relevant online conference or webinar in the next 2-4 weeks.",
        "Suggest a quick 1-2 sentence recommendation for a useful tech tool or resource.",
        "Draft a complete newsletter email in HTML format, including a personalized opening and closing, and a clear call to action for each section (e.g., 'Read More').",
        "Save the HTML draft as 'Newsletter_YY_MM_DD.html' in the 'Newsletter_Drafts' folder and send as an editable draft to Sky's email."
    })
    ```

### **Category: System Maintenance**

**15. Title: Weekly Cloud Cost Optimization Scan**
*   **Description:** Accesses cloud provider APIs (AWS, Azure, GCP), identifies underutilized resources, suggests cost-saving measures (e.g., resizing instances, deleting old snapshots), and generates a summarized report.
*   **Schedule:** Weekly (Friday, 4:00 PM)
*   **Key OpenClaw Features Used:** Sub-agent orchestration (cloud APIs), Multi-model (cost analysis, recommendation engine), Messaging (email/Slack with report).
*   **Value Proposition:** Reduces cloud expenditure by proactively identifying and suggesting optimizations, saving Sky significant operational costs.
*   **Sample Prompt Structure:**
    ```
    @cron(schedule="0 16 * * 5")
    agent.run("cloud_cost_optimizer_agent", {
        "Connect to AWS Cost Explorer API and EC2 API (using provided credentials).",
        "Analyze EC2 instances for average CPU utilization over the last 30 days. Identify instances with <10% utilization.",
        "Identify unattached EBS volumes older than 90 days.",
        "Analyze S3 buckets for infrequently accessed data that could be moved to Glacier.",
        "Generate a report detailing potential weekly cost savings, listing specific resources and suggested actions (e.g., 'Resize instance i-abcdefg from t3.large to t3.medium for ~€X saving/week').",
        "Draft an email to Sky ('sky@example.com') with the subject 'Weekly Cloud Cost Optimization Report' and include the report summary and action items."
    })
    ```

**16. Title: Daily Codebase Health Check & Linting Report**
*   **Description:** For specified GitHub repositories, OpenClaw runs static analysis tools (linters, security scanners) on new commits or pull requests, highlighting potential issues and generating a concise report.
*   **Schedule:** Daily (Monday-Friday, 11:00 AM)
*   **Key OpenClaw Features Used:** Sub-agent orchestration (GitHub API, static analysis tools execution), File system access (to clone/scan repos), Multi-model (issue summarization), Messaging (Slack/email).
*   **Value Proposition:** Maintains code quality and security, catches issues early in the development lifecycle, and provides proactive feedback.
*   **Sample Prompt Structure:**
    ```
    @cron(schedule="0 11 * * 1-5")
    agent.run("code_health_agent", {
        "Repositories to monitor: 'my-project-api', 'my-project-frontend'.",
        "Threshold: Only report issues on commits from the last 24 hours to the 'main' branch.",
        "Clone/pull latest changes for each repository.",
        "Run ESLint (for frontend) and Flake8 (for API) on the detected new code.",
        "Run a basic OWASP ZAP scan or similar for common vulnerabilities (if applicable and configured).",
        "Summarize any fatal linting errors or critical security vulnerabilities detected.",
        "If issues are found, send a Slack message to the '#dev-alerts' channel with repository name, commit hash, and a brief list of top 3 most critical issues and affected files. Include a link to the detailed report saved locally."
    })
    ```

---

### 🥉 **openrouter/x-ai/grok-4** — 6.8/10

**Judge's Assessment:**
grok provides a serviceable and comprehensive overview with clear structure, but the sample prompts are notably shallower — more descriptive sentences than executable agent instructions.

**Full Response:**
Below is a comprehensive, creative list of ideas for daily or weekly cronjob prompts designed to help Sky maximize the capabilities of the OpenClaw agentic platform (and similar systems). These ideas leverage OpenClaw's unique features, such as multi-model capabilities (e.g., switching between AI models for specialized tasks), sub-agent orchestration (e.g., delegating subtasks to specialized agents), file system access (e.g., reading/writing files), web tools (e.g., browsing or scraping data), messaging (e.g., sending notifications via email/SMS), cron management (e.g., scheduling recurring tasks), and integration with external services (e.g., APIs for calendars, finance apps, or smart home devices).

I've organized the ideas by the specified categories, with 2-3 ideas per category for variety. Each idea includes:
1. **Title**: A concise name.
2. **Brief Description**: What the cronjob does.
3. **Schedule**: Daily or weekly (with suggested timing, e.g., "Daily at 7 AM").
4. **Key OpenClaw Features Used**: The platform's capabilities leveraged.
5. **Value Proposition**: Why it's useful for Sky.
6. **Sample Prompt Structure**: A template prompt to set up the cronjob in OpenClaw (adaptable as needed).

These prompts assume OpenClaw can handle natural-language scheduling and execution. They focus on practical automation to enhance daily life without requiring constant manual input.

### Personal Productivity
1. **Daily Task Optimizer**  
   **Brief Description**: Analyzes your calendar and to-do list, prioritizes tasks using AI models, and sends an optimized daily plan.  
   **Schedule**: Daily at 6 AM.  
   **Key OpenClaw Features Used**: Sub-agent orchestration (e.g., one agent pulls calendar data, another prioritizes), integration with external services (e.g., Google Calendar API), messaging (e.g., email summary).  
   **Value Proposition**: Saves time on planning, reduces decision fatigue, and ensures high-priority tasks are addressed first, boosting overall efficiency.  
   **Sample Prompt Structure**: "Schedule a daily cronjob at 6 AM: Use sub-agents to fetch my Google Calendar events and to-do list from file 'tasks.txt'. Orchestrate a multi-model analysis (use GPT for prioritization and Claude for creativity) to create an optimized task list. Send the plan via email to sky@email.com."

2. **Weekly Reflection Journal**  
   **Brief Description**: Compiles notes from the week, generates insights and action items, and appends to a personal journal file.  
   **Schedule**: Weekly on Sunday at 8 PM.  
   **Key OpenClaw Features Used**: File system access (read/write to journal file), multi-model capabilities (e.g., one model for summarization, another for insights), cron management.  
   **Value Proposition**: Promotes self-reflection and growth by turning raw notes into actionable insights, helping track progress over time.  
   **Sample Prompt Structure**: "Set up a weekly cronjob on Sundays at 8 PM: Read notes from 'weekly_notes/' directory. Use sub-agents with different models to summarize key events and generate 3 insights/action items. Append to 'reflection_journal.md' and notify me via message."

3. **Daily Habit Tracker**  
   **Brief Description**: Checks progress on habits (e.g., via integrated apps or files) and sends motivational reminders or adjustments.  
   **Schedule**: Daily at 9 PM.  
   **Key OpenClaw Features Used**: Integration with external services (e.g., habit-tracking API like Habitica), messaging, sub-agent orchestration.  
   **Value Proposition**: Builds consistency in habits like reading or exercise, providing gentle nudges to maintain momentum and adapt goals.  
   **Sample Prompt Structure**: "Create a daily cronjob at 9 PM: Orchestrate sub-agents to pull habit data from Habitica API and local file 'habits.csv'. Analyze streaks with a reasoning model and send a motivational message via SMS with tips."

### Creative Projects
1. **Daily Idea Spark**  
   **Brief Description**: Generates fresh ideas for creative writing, art, or music based on web trends and personal themes.  
   **Schedule**: Daily at 8 AM.  
   **Key OpenClaw Features Used**: Web tools (browse for trends), multi-model capabilities (e.g., creative model for ideation), file system access (save to idea bank).  
   **Value Proposition**: Overcomes creative blocks by delivering tailored inspiration daily, building a repository of ideas for ongoing projects.  
   **Sample Prompt Structure**: "Schedule daily cronjob at 8 AM: Use web tools to scan creative trends on sites like Pinterest. Employ a multi-model setup (DALL-E for visual ideas, GPT for writing) to generate 5 ideas themed around 'nature'. Save to 'idea_bank.txt' and email me."

2. **Weekly Project Milestone Checker**  
   **Brief Description**: Reviews progress on a creative project file, suggests next steps, and orchestrates sub-tasks if needed.  
   **Schedule**: Weekly on Friday at 5 PM.  
   **Key OpenClaw Features Used**: Sub-agent orchestration (delegate tasks like research), file system access, cron management.  
   **Value Proposition**: Keeps long-term creative projects on track, providing structured guidance to maintain motivation and momentum.  
   **Sample Prompt Structure**: "Set weekly cronjob on Fridays at 5 PM: Access 'project_progress.md' file. Orchestrate sub-agents to review milestones and suggest 3 next steps. If approved via reply, auto-schedule subtasks in cron."

### Health/Wellness
1. **Daily Wellness Check-In**  
   **Brief Description**: Pulls health data (e.g., from fitness apps), analyzes trends, and sends personalized wellness tips.  
   **Schedule**: Daily at 7 AM.  
   **Key OpenClaw Features Used**: Integration with external services (e.g., Fitbit API), multi-model capabilities (analysis with health-focused models), messaging.  
   **Value Proposition**: Encourages proactive health management by spotting patterns early and offering evidence-based advice.  
   **Sample Prompt Structure**: "Daily cronjob at 7 AM: Integrate with Fitbit API to fetch sleep and activity data. Use multi-models to analyze and generate 2 wellness tips. Send via email with visualizations."

2. **Weekly Meal Planner**  
   **Brief Description**: Generates a balanced meal plan based on dietary preferences, web-sourced recipes, and shopping lists.  
   **Schedule**: Weekly on Sunday at 10 AM.  
   **Key OpenClaw Features Used**: Web tools (scrape recipes), sub-agent orchestration (one for planning, one for shopping), file system access (save plan).  
   **Value Proposition**: Simplifies nutrition by automating planning, reducing decision-making stress and promoting healthier eating habits.  
   **Sample Prompt Structure**: "Weekly cronjob on Sundays at 10 AM: Use web tools to find vegetarian recipes. Orchestrate sub-agents to create a 7-day meal plan from preferences in 'diet_prefs.txt'. Save shopping list to file and message it."

### Learning/Education
1. **Daily Knowledge Bite**  
   **Brief Description**: Delivers a short lesson or fact on a chosen topic, with quizzes for retention.  
   **Schedule**: Daily at 9 AM.  
   **Key OpenClaw Features Used**: Web tools (fetch educational content), multi-model capabilities (quiz generation), messaging.  
   **Value Proposition**: Facilitates continuous learning in bite-sized pieces, making education accessible and fun without overwhelming schedules.  
   **Sample Prompt Structure**: "Daily cronjob at 9 AM: Browse educational sites for a fact on 'AI history'. Use models to create a 1-minute lesson and quiz. Send via SMS with answers later."

2. **Weekly Skill Builder**  
   **Brief Description**: Assigns and tracks progress on micro-lessons for a skill, pulling resources and adapting based on feedback.  
   **Schedule**: Weekly on Monday at 8 AM.  
   **Key OpenClaw Features Used**: Sub-agent orchestration (track progress), integration with external services (e.g., Duolingo API), cron management.  
   **Value Proposition**: Accelerates skill acquisition through personalized, recurring practice, turning aspirations into achievable growth.  
   **Sample Prompt Structure**: "Weekly cronjob on Mondays at 8 AM: Orchestrate sub-agents to pull language lessons from Duolingo. Generate a customized exercise based on 'skill_progress.log' and schedule follow-up."

### Home Automation
1. **Daily Home Status Report**  
   **Brief Description**: Checks smart home devices, reports anomalies, and automates adjustments like lighting schedules.  
   **Schedule**: Daily at 6 PM.  
   **Key OpenClaw Features Used**: Integration with external services (e.g., Home Assistant API), sub-agent orchestration, messaging.  
   **Value Proposition**: Enhances home safety and efficiency by automating monitoring, freeing up mental energy for other tasks.  
   **Sample Prompt Structure**: "Daily cronjob at 6 PM: Integrate with Home Assistant to check device status. Use sub-agents to analyze and auto-adjust lights if needed. Send report via email."

2. **Weekly Energy Optimizer**  
   **Brief Description**: Analyzes utility data and suggests optimizations, integrating with smart plugs for automation.  
   **Schedule**: Weekly on Saturday at 9 AM.  
   **Key OpenClaw Features Used**: Web tools (fetch energy data), multi-model capabilities (optimization analysis), integration with external services.  
   **Value Proposition**: Reduces bills and environmental impact through data-driven tweaks, making home management smarter.  
   **Sample Prompt Structure**: "Weekly cronjob on Saturdays at 9 AM: Use web tools to pull energy usage data. Multi-model analysis for optimizations; integrate with smart plugs to schedule changes. Notify via message."

### Financial Tracking
1. **Daily Expense Scanner**  
   **Brief Description**: Scans bank notifications or files for expenses, categorizes them, and flags overspending.  
   **Schedule**: Daily at 10 PM.  
   **Key OpenClaw Features Used**: File system access (read expense logs), integration with external services (e.g., bank API), messaging.  
   **Value Proposition**: Provides real-time financial awareness, helping avoid surprises and stick to budgets effortlessly.  
   **Sample Prompt Structure**: "Daily cronjob at 10 PM: Access 'expenses.csv' and bank API. Categorize entries and alert via SMS if over budget in any category."

2. **Weekly Budget Forecast**  
   **Brief Description**: Generates a forecast based on trends, with visualizations and savings tips.  
   **Schedule**: Weekly on Sunday at 7 PM.  
   **Key OpenClaw Features Used**: Multi-model capabilities (forecasting), sub-agent orchestration, file system access.  
   **Value Proposition**: Empowers better financial decisions by predicting future states and offering proactive advice.  
   **Sample Prompt Structure**: "Weekly cronjob on Sundays at 7 PM: Orchestrate sub-agents to analyze 'budget_data/' files. Use models for forecasting and tips; save visualization to file and email."

### Social Media Management
1. **Daily Engagement Booster**  
   **Brief Description**: Analyzes social feeds, suggests responses, and auto-posts curated content.  
   **Schedule**: Daily at 11 AM.  
   **Key OpenClaw Features Used**: Web tools (scrape social data), integration with external services (e.g., Twitter API), sub-agent orchestration.  
   **Value Proposition**: Grows online presence efficiently, saving time on manual engagement while maintaining authenticity.  
   **Sample Prompt Structure**: "Daily cronjob at 11 AM: Use web tools and Twitter API to fetch mentions. Orchestrate sub-agents to draft responses and post one curated update."

2. **Weekly Content Calendar**  
   **Brief Description**: Plans and schedules a week's worth of posts based on trends and analytics.  
   **Schedule**: Weekly on Monday at 10 AM.  
   **Key OpenClaw Features Used**: Multi-model capabilities (content generation), cron management (schedule posts), messaging.  
   **Value Proposition**: Streamlines social strategy, ensuring consistent posting and higher engagement without daily effort.  
   **Sample Prompt Structure**: "Weekly cronjob on Mondays at 10 AM: Generate 7 post ideas using trend analysis models. Schedule via cron and notify me for approval."

### Content Creation
1. **Daily Blog Post Ideator**  
   **Brief Description**: Brainstorms blog topics, outlines drafts, and saves to a content queue.  
   **Schedule**: Daily at 7 AM.  
   **Key OpenClaw Features Used**: Multi-model capabilities (ideation and outlining), file system access, web tools (research).  
   **Value Proposition**: Fuels consistent content output, reducing writer's block and building a content pipeline.  
   **Sample Prompt Structure**: "Daily cronjob at 7 AM: Use web tools for topic research. Multi-model to outline a blog post on 'tech trends'; save draft to 'content_queue/'."

2. **Weekly Video Script Generator**  
   **Brief Description**: Creates scripts for videos, incorporating visuals and SEO keywords from web data.  
   **Schedule**: Weekly on Thursday at 2 PM.  
   **Key OpenClaw Features Used**: Sub-agent orchestration (script + visuals), integration with external services (e.g., YouTube API for trends).  
   **Value Proposition**: Accelerates video production, making it easier to create engaging, optimized content regularly.  
   **Sample Prompt Structure**: "Weekly cronjob on Thursdays at 2 PM: Orchestrate sub-agents to fetch YouTube trends and generate a 5-minute script. Include SEO tips and save to file."

### System Maintenance
1. **Daily Backup Runner**  
   **Brief Description**: Automates file backups to cloud storage and verifies integrity.  
   **Schedule**: Daily at 2 AM.  
   **Key OpenClaw Features Used**: File system access, integration with external services (e.g., Google Drive API), messaging (alert on issues).  
   **Value Proposition**: Ensures data security with minimal effort, preventing loss from hardware failures or accidents.  
   **Sample Prompt Structure**: "Daily cronjob at 2 AM: Access key directories and backup to Google Drive. Verify files and send success/failure message."

2. **Weekly System Health Scan**  
   **Brief Description**: Scans for updates, cleans files, and reports on system performance.  
   **Schedule**: Weekly on Friday at 3 AM.  
   **Key OpenClaw Features Used**: Sub-agent orchestration (scans and cleans), cron management, web tools (check for updates).  
   **Value Proposition**: Maintains optimal system performance, catching issues early to avoid downtime.  
   **Sample Prompt Structure**: "Weekly cronjob on Fridays at 3 AM: Orchestrate sub-agents to scan for updates via web and clean temp files. Generate health report and email it."

These ideas can be customized further based on Sky's specific setup. To implement, input the sample prompts directly into OpenClaw's interface for scheduling. If you need more details or expansions, let me know!

---

## Judge's Full Analysis

### Rankings

1st: ****openrouter/moonshotai/kimi-k2.5**** — Score: 9.2/10
**openrouter/moonshotai/kimi-k2.5** demonstrates exceptional depth and creativity with 24 well-developed automations spanning all requested categories. Its sample prompts are technically sophisticated, showing genuine understanding of multi-agent orchestration with named sub-agents, conditional logic, file path conventions, and self-modifying cron schedules. The implementation strategy and unique ideas (e.g., "toxic digital relationship cleanser," "energy arbitrage optimizer," "living document collaboration partner") show innovative thinking that goes well beyond generic suggestions.

2nd: ****google/gemini-2.5-flash**** — Score: 8.1/10
**google/gemini-2.5-flash** produces a polished, professionally structured list with strong code-style prompt formatting that feels genuinely implementable. The ideas are well-reasoned and cover all categories with solid specificity (actual API names, budget thresholds, specific platforms). It falls slightly behind **openrouter/moonshotai/kimi-k2.5** in creativity and depth of sub-agent orchestration detail, and its prompts, while well-formatted, feel more like task lists than true agentic orchestration blueprints.

3rd: ****openrouter/x-ai/grok-4**** — Score: 6.8/10
**openrouter/x-ai/grok-4** provides a serviceable and comprehensive overview with clear structure, but the sample prompts are notably shallower — more descriptive sentences than executable agent instructions. Ideas tend toward the generic (daily backup, habit tracker, expense scanner) without the creative differentiation seen in the other responses. The multi-model and sub-agent orchestration usage is mentioned but not meaningfully demonstrated in the actual prompt structures.

### Overall Summary
All three responses cover the requested categories, but they diverge significantly in depth and technical authenticity. **openrouter/moonshotai/kimi-k2.5** distinguishes itself through genuinely agentic prompt design — spawning named sub-agents, implementing conditional branching, writing to specific file paths, self-modifying cron schedules, and integrating security critique loops — reflecting real understanding of what an agentic platform like OpenClaw enables. **google/gemini-2.5-flash** is a strong runner-up with clean, professional formatting and specific API references, but its orchestration remains relatively flat compared to **openrouter/moonshotai/kimi-k2.5**'s layered multi-agent architecture. **openrouter/x-ai/grok-4** reads more as a brainstorming document than an implementable automation guide, with prompts that describe intent rather than demonstrate platform capability.

---

## Blind Judging Key (Audit)

- Response A → openrouter/x-ai/grok-4
- Response B → google/gemini-2.5-flash
- Response C → openrouter/moonshotai/kimi-k2.5

---

## Metadata

- **Total Duration:** 180.0s
- **Successful Models:** 3
- **Failed Models:** 0
