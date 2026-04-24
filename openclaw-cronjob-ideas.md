# OpenClaw Cronjob Ideas for Sky

*A comprehensive collection of practical automation prompts to maximize your agentic platform*

---

## 🎯 Personal Productivity

### 1. Morning Briefing Generator
**Description:** Aggregate emails, calendar events, weather, and priorities into a concise morning digest delivered via Telegram.

**Schedule:** Daily at 7:00 AM

**Key Features Used:**
- himalaya (email checking)
- web_search / web_fetch (news/weather)
- message (Telegram delivery)
- file system (memory logs)

**Value Proposition:** Start the day informed without checking multiple apps. Saves 10-15 minutes each morning.

**Sample Prompt:**
```
Generate my morning briefing:
1. Check himalaya for unread emails from the last 8 hours, summarize urgent ones
2. Fetch weather for [MY_CITY] and summarize today's forecast
3. Search for top 3 tech news headlines from Hacker News
4. Read memory/today-tasks.md if it exists and list today's priorities
5. Send a concise summary to Telegram with:
   - Weather summary
   - Email highlights (subject lines only, flag urgent)
   - Top news items
   - Today's tasks from memory
```

---

### 2. Weekly Task Review & Prioritizer
**Description:** Review completed tasks from the week, identify overdue items, and suggest priorities for the upcoming week.

**Schedule:** Weekly (Sundays at 6:00 PM)

**Key Features Used:**
- file system (memory/ logs)
- subagents (deep analysis)
- message (Telegram report)

**Value Proposition:** Automated weekly review ensures nothing falls through cracks and provides closure on the week.

**Sample Prompt:**
```
Conduct my weekly review:
1. List all memory/*.md files from the past 7 days
2. Extract all tasks mentioned (look for [ ], [x], TODO, etc.)
3. Categorize: completed, pending, overdue
4. Spawn a subagent to analyze patterns and suggest 3 priorities for next week
5. Send a formatted report to Telegram with:
   - Completion rate (X/Y tasks done)
   - Overdue items requiring attention
   - Suggested top 3 priorities for next week
   - Optional: motivation quote if completion rate > 80%
```

---

### 3. Smart Reminder System
**Description:** Parse memory files for date/time mentions and send proactive reminders before events.

**Schedule:** Daily at 8:00 PM (checking next 24 hours)

**Key Features Used:**
- file system (memory/)
- message (Telegram)
- regex pattern matching

**Value Proposition:** Never miss commitments mentioned in casual conversation or notes.

**Sample Prompt:**
```
Check for upcoming commitments:
1. Read memory/*.md files from past 7 days
2. Scan for date patterns (tomorrow, "March 7th", "next Tuesday", etc.)
3. Look for time patterns ("at 3pm", "morning", etc.)
4. Identify events happening in the next 24 hours
5. Send Telegram reminder with:
   - Event description
   - Time identified
   - Original context/source file
   - "Do you need preparation time?" inline button (optional webhook)
```

---

## 🎨 Creative Projects

### 4. Creative Prompt Generator
**Description:** Generate daily creative writing prompts, art ideas, or project starters based on current interests stored in memory.

**Schedule:** Daily at 9:00 AM

**Key Features Used:**
- file system (MEMORY.md for interests)
- subagents (creative generation)
- message (Telegram)

**Value Proposition:** Consistent creative nudges maintain momentum on side projects.

**Sample Prompt:**
```
Generate today's creative prompt:
1. Read MEMORY.md and identify creative interests (writing, art, music, code projects)
2. Read memory/current-projects.md if exists
3. Spawn a subagent with prompt: "Based on these interests [INTERESTS], generate ONE specific, actionable creative prompt for today. Make it specific enough to start in 15 minutes."
4. Send via Telegram with:
   - The creative prompt
   - Suggested time investment (15/30/60 min)
   - "I did this" tracking button
```

---

### 5. Weekly Project Progress Tracker
**Description:** Check git repositories for uncommitted changes and prompt for project updates.

**Schedule:** Weekly (Wednesdays at 7:00 PM)

**Key Features Used:**
- exec (git commands)
- file system (repo scanning)
- message (Telegram)

**Value Proposition:** Prevents work from lingering in uncommitted states. Maintains project velocity.

**Sample Prompt:**
```
Project health check:
1. Scan /home/ubuntu/.openclaw/workspace/ for git repositories
2. For each repo found:
   - Check for uncommitted changes (git status)
   - Check last commit date
   - Check for unpushed commits
3. Generate report:
   - Repos with uncommitted work (>3 days old = stale)
   - Repos with unpushed commits
   - Time since last commit per repo
4. Send Telegram message with:
   - Stale projects highlighted
   - Quick commit reminder if uncommitted changes exist
   - Encouragement for inactive projects >2 weeks
```

---

### 6. Inspiration Collector
**Description:** Search curated sources for relevant inspiration and save to a "swipe file" in memory.

**Schedule:** Daily at 12:00 PM

**Key Features Used:**
- web_search (targeted queries)
- web_fetch (content extraction)
- file system (append to swipe file)

**Value Proposition:** Builds a personal inspiration database over time without daily manual effort.

**Sample Prompt:**
```
Collect daily inspiration:
1. Read MEMORY.md for current focus areas/interests
2. Search for: "[interest] inspiration [current month year]"
3. Fetch top 2-3 results and extract interesting content
4. Write to memory/swipe-file.md with date stamp:
   ---
   Date: 202X-XX-XX
   Source: [URL]
   [Extracted insight/image description/quote]
   ---
5. If something particularly good found, send Telegram summary
```

---

## 💪 Health & Wellness

### 7. Hydration & Movement Reminder
**Description:** Send contextual reminders based on time of day and activity patterns logged in memory.

**Schedule:** 3x daily (10:30 AM, 2:00 PM, 4:30 PM)

**Key Features Used:**
- message (Telegram)
- file system (track responses)

**Value Proposition:** Gentle wellness nudges that compound into better habits.

**Sample Prompt:**
```
Wellness check-in:
1. Check memory/wellness-log.md for last logged activity
2. Determine which reminder this is (morning/afternoon/evening)
3. Send Telegram message:
   - Morning: "Good morning! Have you had water yet? Goal: 16oz to start the day."
   - Afternoon: "Movement break! 2 minutes of stretching or a quick walk?"
   - Evening: "Wind-down check: How much water today? Rate energy 1-10."
4. Include inline keyboard for quick logging (tapped yes/no/maybe)
5. Log response timestamp to wellness-log.md
```

---

### 8. Weekly Screen Time & Digital Wellness Report
**Description:** Analyze browser history or time-tracking data to provide insights on digital habits.

**Schedule:** Weekly (Sundays at 8:00 PM)

**Key Features Used:**
- exec (data collection)
- subagents (analysis)
- message (Telegram)

**Value Proposition:** Awareness drives improvement. Weekly cadence prevents obsession while maintaining accountability.

**Sample Prompt:**
```
Digital wellness report:
1. If time-tracking data available, load it
2. Check browser history patterns (if accessible)
3. Analyze memory/ for work vs entertainment mentions
4. Spawn subagent to calculate simple metrics:
   - Estimated productive hours vs leisure
   - Pattern changes from previous week
   - One specific suggestion for improvement
5. Send Telegram report:
   - Friendly summary of week
   - One highlight (something that went well)
   - One gentle suggestion for next week
   - No guilt, just awareness
```

---

### 9. Sleep Hygiene Reminder
**Description:** Evening wind-down prompt with personalized reminders based on sleep goals.

**Schedule:** Daily at 9:00 PM

**Key Features Used:**
- message (Telegram)
- file system (read sleep goals)

**Value Proposition:** Consistent wind-down cues improve sleep quality over time.

**Sample Prompt:**
```
Sleep wind-down reminder:
1. Read MEMORY.md for sleep goals/target bedtime
2. Calculate time until target bedtime
3. Send Telegram message:
   - "Wind-down time! Target sleep: [TIME] (in [X] hours)"
   - Checklist: Blue light reduced, last caffeine was [check timing], tomorrow planned
   - Optional: calming suggestion (meditation, reading, etc.)
4. Log that reminder was sent
```

---

## 📚 Learning & Education

### 10. Daily Learning Micro-Goal
**Description:** Extract a small, actionable learning task from current study topics.

**Schedule:** Daily at 8:00 AM

**Key Features Used:**
- file system (learning-track.md)
- web_search (current resources)
- message (Telegram)

**Value Proposition:** Breaking learning into daily micro-goals prevents overwhelm and maintains consistency.

**Sample Prompt:**
```
Generate daily micro-learning goal:
1. Read memory/learning-track.md for current topics/resources
2. Pick ONE specific concept from the current topic
3. Search for "[concept] explained simply" example
4. Create micro-goal:
   - Concept: [specific topic]
   - Time: 15-20 minutes
   - Resource: [link or book reference]
   - Output: "Spend 15 minutes understanding [X]. Optional: write 3-sentence summary."
5. Send Telegram with the micro-goal
```

---

### 11. Weekly Knowledge Review
**Description:** Review notes taken during the week and create a spaced repetition reminder system.

**Schedule:** Weekly (Fridays at 5:00 PM)

**Key Features Used:**
- file system (notes scanning)
- subagents (concept extraction)
- message (Telegram)

**Value Proposition:** Converts scattered notes into reviewable knowledge, improving retention.

**Sample Prompt:**
```
Weekly knowledge consolidation:
1. Scan memory/*.md for new concepts/insights from this week
2. Extract 3-5 key learnings
3. Create spaced repetition schedule:
   - Review today: [most important]
   - Review in 3 days: [second learning]
   - Review next week: [third learning]
4. Send Telegram:
   - "This week you learned about: [topics]"
   - Quiz question for each key learning
   - "Review scheduled for [dates]"
5. Write to memory/review-schedule.md
```

---

### 12. Article Digest & Summary
**Description:** Summarize saved articles or bookmarks into actionable takeaways.

**Schedule:** Weekly (Saturdays at 10:00 AM)

**Key Features Used:**
- web_fetch (article extraction)
- subagents (summarization with model)
- file system (bookmarks/reading list)

**Value Proposition:** Prevents "read later" pileup. Summarization makes consumption 5x faster.

**Sample Prompt:**
```
Process reading list:
1. Read memory/reading-list.md for saved URLs
2. For each unread article (limit 3):
   - Fetch content with web_fetch
   - Spawn subagent: "Summarize into 3 bullet points + 1 actionable takeaway"
3. Send Telegram digest:
   - Article title + link
   - 3 key points
   - 1 action item
   - "Mark as read" button
4. Move processed articles to memory/reading-archive.md
```

---

## 🏠 Home Automation (Preparation Layer)

### 13. Daily Home Status Briefing
**Description:** Compile information relevant to home management (weather, calendar events requiring prep, maintenance reminders).

**Schedule:** Daily at 7:30 AM

**Key Features Used:**
- web_search (weather forecasts)
- file system (home maintenance logs)
- message (Telegram)

**Value Proposition:** Proactive home management prevents reactive scrambling.

**Sample Prompt:**
```
Home status briefing:
1. Check weather: rain, extreme temps, wind warnings
2. Check calendar events: guests? travel? special occasions?
3. Read memory/home-maintenance.md for scheduled tasks
4. Generate briefing:
   - Weather actions needed (umbrella? AC? close windows?)
   - Upcoming home tasks this week
   - Preparation needed for calendar events
5. Send Telegram with checklist format
```

---

### 14. Monthly Maintenance Reminder
**Description:** Rotate through home maintenance tasks and suggest monthly action items.

**Schedule:** Monthly (1st of month at 9:00 AM)

**Key Features Used:**
- file system (maintenance schedule)
- message (Telegram)

**Value Proposition:** Prevents "oh no I haven't done X in a year" moments through consistent rotation.

**Sample Prompt:**
```
Monthly home maintenance check:
1. Read memory/maintenance-schedule.md
2. Identify tasks for current month (rotation based on month number)
3. Generate list:
   - This month's tasks
   - Estimated time per task
   - Materials needed (if any)
4. Send Telegram:
   - "March maintenance tasks: [list]"
   - Links to how-to guides if applicable
   - "Schedule time this month" suggestion
5. Update last-checked dates
```

---

## 💰 Financial Tracking

### 15. Weekly Spending Pulse Check
**Description:** Prompt reflection on spending patterns and upcoming bills.

**Schedule:** Weekly (Sundays at 7:00 PM)

**Key Features Used:**
- message (Telegram prompts)
- file system (spending logs if available)

**Value Proposition:** Weekly awareness prevents monthly "where did my money go" surprises.

**Sample Prompt:**
```
Weekly spending reflection:
1. Send Telegram prompting reflection:
   - "Quick spending check: Any big expenses this week?"
   - "Upcoming bills to remember: [ask for input]"
   - "One financial win this week (even small)?"
2. If user responds, log to memory/spending-log.md
3. Suggest weekly budget review if spending tracking available
```

---

### 16. Subscription Audit Reminder
**Description:** Quarterly review of active subscriptions and their value.

**Schedule:** Quarterly (first Monday of Jan/Apr/Jul/Oct)

**Key Features Used:**
- file system (subscription list)
- message (Telegram)
- web_fetch (check current pricing)

**Value Proposition:** Catches subscription creep and reminds to evaluate value periodically.

**Sample Prompt:**
```
Quarterly subscription audit:
1. Read memory/subscriptions.md for active subscriptions
2. For each subscription, calculate monthly/yearly cost
3. Send Telegram report:
   - List all subscriptions with costs
   - Total monthly spend
   - "Do you still use [X]?" for each
   - Suggestions: annual billing discounts, cancellation candidates
4. Prompt for updates/changes
5. Update subscription list with confirmed data
```

---

## 📱 Social Media Management

### 17. Content Idea Generator
**Description:** Generate social media post ideas based on recent projects and interests.

**Schedule:** Weekly (Tuesdays at 10:00 AM)

**Key Features Used:**
- file system (memory/ projects)
- subagents (creative ideation)
- message (Telegram)

**Value Proposition:** Removes "what should I post" friction for consistent sharing.

**Sample Prompt:**
```
Generate content ideas:
1. Read memory/*.md from past 2 weeks for interesting activities
2. Scan for: projects completed, lessons learned, interesting discoveries
3. Spawn subagent: "Transform these activities into 3 social media post ideas (Twitter/X format, casual tone). Include hook + body."
4. Send Telegram:
   - 3 post ideas formatted for easy copy/paste
   - Suggested image types for each
   - Best posting time suggestion
5. Log to memory/content-ideas.md
```

---

### 18. Engagement Queue Review
**Description:** Remind to check DMs, mentions, and engagement opportunities.

**Schedule:** Daily at 5:00 PM

**Key Features Used:**
- message (Telegram reminder)
- file system (engagement log)

**Value Proposition:** Maintains relationships through consistent, managed engagement without constant checking.

**Sample Prompt:**
```
Engagement check reminder:
1. Send Telegram:
   - "Quick engagement round: 10 minutes"
   - Checklist: DMs, replies to your posts, comments to follow up
   - "Quality over quantity - pick 3 meaningful interactions"
2. Log completion if confirmed
3. Track streak in memory/social-streak.md
```

---

## ✍️ Content Creation

### 19. Weekly Writing Sprint Prompt
**Description:** Generate a specific writing topic with structure guidance for focused creation sessions.

**Schedule:** Weekly (Saturdays at 9:00 AM)

**Key Features Used:**
- file system (writing topics/ideas)
- subagents (prompt engineering)
- message (Telegram)

**Value Proposition:** Removes the blank page problem. Scheduled creation time maintains writing habit.

**Sample Prompt:**
```
Weekly writing sprint:
1. Read memory/writing-ideas.md for backlog
2. Pick highest priority or oldest idea
3. Generate structure:
   - Topic
   - 3 main points to cover
   - Target length (500/1000/2000 words)
   - Suggested opening sentence
4. Send Telegram with:
   - The writing prompt + structure
   - Timer suggestion (pomodoro style)
   - "Save to workspace/writing-drafts/" reminder
5. Remove completed idea from backlog
```

---

### 20. Content Repurposing Reminder
**Description:** Identify long-form content that could be repurposed into shorter formats.

**Schedule:** Monthly (15th at 10:00 AM)

**Key Features Used:**
- file system (content archive)
- subagents (repurposing analysis)
- message (Telegram)

**Value Proposition:** Maximizes return on content effort through strategic repurposing.

**Sample Prompt:**
```
Content repurposing audit:
1. Scan workspace/ for long-form content (blog posts, videos, podcasts)
   - Check memory/content-archive.md
2. Identify evergreen pieces >1 month old
3. For each piece, suggest 2-3 repurposed formats:
   - Thread summary
   - Infographic/ slide outline
   - Newsletter excerpt
   - Quote graphics
4. Send Telegram with repurposing opportunities
5. Add to memory/repurposing-queue.md
```

---

## 🔧 System Maintenance

### 21. Workspace Health Check
**Description:** Scan workspace for issues: large files, old temp files, orphaned processes, disk space.

**Schedule:** Daily at 3:00 AM

**Key Features Used:**
- exec (disk usage, find commands)
- file system (scanning)
- message (Telegram if issues found)

**Value Proposition:** Prevents disk space emergencies and maintains system hygiene silently.

**Sample Prompt:**
```
Workspace health check:
1. Check disk usage: df -h /home/ubuntu
2. Find large files (>500MB): find workspace/ -size +500M -type f 2>/dev/null
3. Check for temp files: /tmp, *.tmp, .cache size
4. Check memory/ file sizes (alert if >10MB)
5. Look for git repos with untracked/uncommitted changes
6. If any issues:
   - Send Telegram alert with specific issues
   - Suggest cleanup commands
   - Else: silent pass (log to sys-health.log)
```

---

### 22. Backup Status Verification
**Description:** Check that important files are committed/pushed or backed up appropriately.

**Schedule:** Daily at 11:00 PM

**Key Features Used:**
- exec (git status, git push)
- file system (checking)
- message (silent notification on failure)

**Value Proposition:** Peace of mind that work is protected without manual checking.

**Sample Prompt:**
```
Backup verification:
1. Check each git repo in workspace/:
   - Any uncommitted changes? -> auto-commit with timestamp
   - Any unpushed commits? -> auto-push
2. Check for non-git important files (large datasets, configs)
3. Verify critical files exist:
   - MEMORY.md exists
   - TOOLS.md exists
   - AGENTS.md exists
4. If auto-push fails or critical files missing:
   - Send Telegram backup alert
   - Else: log success to backup.log
```

---

### 23. Dependency Update Check
**Description:** Check for outdated dependencies in project repositories.

**Schedule:** Weekly (Mondays at 10:00 AM)

**Key Features Used:**
- exec (npm outdated, pip list --outdated, cargo outdated)
- file system (package manifests)
- message (Telegram report)

**Value Proposition:** Maintains security and access to latest features without constant manual checking.

**Sample Prompt:**
```
Dependency update check:
1. Scan workspace/ for package files:
   - package.json (npm outdated)
   - requirements.txt (pip list --outdated)
   - Cargo.toml (cargo outdated)
   - go.mod (go list -u -m all)
2. For each, check outdated packages
3. Generate report:
   - Project name
   - Outdated packages (major/minor/patch)
   - Security advisories if available (can query npm audit)
4. Send Telegram if updates available
5. Offer to create update branch (optional)
```

---

### 24. Weekly OpenClaw Feature Exploration
**Description:** Suggest one underutilized OpenClaw feature to explore based on usage patterns.

**Schedule:** Weekly (Thursdays at 4:00 PM)

**Key Features Used:**
- file system (history analysis)
- subagents (suggestion generation)
- message (Telegram)

**Value Proposition:** Ensures you're getting full value from the platform's capabilities.

**Sample Prompt:**
```
Feature exploration:
1. Analyze memory/ for patterns:
   - What tools are used frequently?
   - What categories are underutilized?
2. Pick one feature from underused category
3. Generate mini-tutorial:
   - What it does
   - When to use it
   - One concrete example for your context
4. Send Telegram:
   - "This week's power user tip: [feature]"
   - Brief explanation + your-context example
   - "Try it out: [sample prompt]"
```

---

## 💡 Special-Purpose Automation

### 25. Birthday & Anniversary Reminder
**Description:** Check contacts/calendar for upcoming important dates and suggest gifts/actions.

**Schedule:** Daily at 8:00 AM (checking 7 days ahead)

**Key Features Used:**
- file system (contacts/important-dates.md)
- web_search (gift ideas)
- message (Telegram)

**Value Proposition:** Never miss important relationship moments. Advance notice allows for thoughtful preparation.

**Sample Prompt:**
```
Important dates check:
1. Read memory/important-dates.md for birthdays/anniversaries
2. Find dates in next 7 days
3. For each upcoming date:
   - Calculate days until
   - Search for "gift ideas [person's interests] 202X"
4. Send Telegram:
   - List upcoming events with countdown
   - Suggested gift ideas based on their interests
   - "Order by [date] to arrive on time" reminder
   - Link to gift if available
```

---

### 26. Weekly Reflection & Gratitude Log
**Description:** Prompt reflection on the week's wins, challenges, and gratitude items.

**Schedule:** Weekly (Sundays at 8:00 PM)

**Key Features Used:**
- file system (journal entry)
- message (Telegram prompts)

**Value Proposition:** Builds mindfulness and gratitude practice through gentle structured prompts.

**Sample Prompt:**
```
Weekly reflection:
1. Read memory/*.md for this week's activities
2. Generate reflection prompts based on actual events
3. Send Telegram:
   - "This week you worked on: [projects from memory]"
   - Questions:
     * What was your biggest win this week?
     * One thing you learned?
     * Something you're grateful for?
     * One thing to improve next week?
4. If user responds, append to memory/weekly-reflections.md with timestamp
```

---

### 27. Travel Preparation Assistant
**Description:** When travel is detected in calendar or mentions, generate prep checklist and monitor changes.

**Schedule:** Triggered when travel mentioned, or daily check (3 days before)

**Key Features Used:**
- file system (travel dates)
- web_search (weather, destination info)
- message (Telegram)

**Value Proposition:** Comprehensive travel readiness without the stress of remembering everything.

**Sample Prompt:**
```
Travel preparation check:
1. Read memory/upcoming-travel.md for dates/destinations
2. Check if departure is within 3 days
3. Fetch:
   - Weather forecast for destination
   - Any travel advisories
   - Local time difference
4. Send Telegram checklist:
   - Weather: [forecast]
   - Pre-departure: documents, chargers, medications
   - Arrival prep: transportation, accommodation confirmed
   - Bonus: one local tip about destination
5. Set reminder for 24h before departure
```

---

### 28. Model Show Reminder & Scheduler
**Description:** Remind to run model comparisons on interesting questions and track results.

**Schedule:** Weekly (Fridays at 2:00 PM)

**Key Features Used:**
- file system (past modelshows)
- web_search (interesting questions)
- message (Telegram)

**Value Proposition:** Maintains habit of model comparison for quality validation of outputs.

**Sample Prompt:**
```
Model show Friday:
1. Check memory/modelshow-history.md for past questions
2. Search for "interesting questions to ask AI 202X" or trending topics
3. Suggest 2-3 comparison questions:
   - One practical (how-to)
   - One creative (story/poem)
   - One analytical (explain a concept)
4. Send Telegram:
   - "Model Show Friday! Pick a question or suggest your own:"
   - Listed suggestions
   - Recent model improvements to test
5. Log results when completed
```

---

## 📋 Implementation Tips

### Setting Up These Cronjobs

```bash
# View existing cronjobs
openclaw cron list

# Add a new cronjob
openclaw cron add "0 7 * * *" "Generate morning briefing"

# Example for daily at 7 AM
openclaw cron add "0 7 * * *" "morning-briefing" "Generate and send morning briefing"

# Weekly (Sundays at 6 PM)
openclaw cron add "0 18 * * 0" "weekly-review" "Weekly task review"
```

### File Organization

Create these supporting files in `memory/`:

```
memory/
├── daily-tasks.md          # Today/tomorrow tasks
├── wellness-log.md         # Health tracking
├── learning-track.md       # Current learning topics
├── swipe-file.md          # Inspiration collection
├── maintenance-schedule.md # Home maintenance
├── spending-log.md         # Financial tracking
├── subscriptions.md        # Active subscriptions
├── content-ideas.md        # Social media queue
├── writing-ideas.md        # Writing backlog
├── important-dates.md      # Birthdays/anniversaries
├── weekly-reflections.md   # Reflection journal
└── modelshow-history.md    # Past model comparisons
```

### Best Practices

1. **Start small:** Pick 2-3 that resonate most, add gradually
2. **Silent successes:** Many should only notify on issues (backup failures, not successes)
3. **User control:** Always include opt-out mechanisms
4. **Context-aware:** Read memory before acting, don't assume
5. **Fail gracefully:** If a cron task fails, log it but don't spam
6. **Track usage:** Log when cronjobs run to identify which are valuable

---

## 🚀 Quick-Start Starter Pack

For immediate value, start with these 5:

| Time | Task | Impact |
|------|------|--------|
| 7:00 AM Daily | Morning Brief | Saves 15 min/day |
| 7:30 PM Daily | Backup Check | Peace of mind |
| Sunday 6:00 PM | Weekly Review | Weekly clarity |
| Wednesday 7:00 PM | Project Health Check | Momentum maintenance |
| Friday 2:00 PM | Model Show | Quality habit |

---

*Generated for Sky - Customize prompts to match your specific workflow and preferences*
