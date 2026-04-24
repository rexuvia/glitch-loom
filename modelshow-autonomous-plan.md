# Fully Autonomous ModelShow & MSPP Implementation Plan

## 1. Current State Analysis

**modelshow (`mdls` trigger)**:
- **Trigger**: Requires human user to send a message starting with `mdls <prompt>`.
- **Workflow**: The system parses the prompt, loads configured agents, polls their API responses via sub-agents or raw inference loops, anonymizes them, calls a judge model, and presents the formatted results back to the user via chat.
- **Output**: Saves JSON/MD to `~/.openclaw/workspace/modelshow-private/`. Outputs formatted response to the human.

**mspp (`mspp` trigger)**:
- **Trigger**: Requires human to type `mspp list` to view or `mspp publish <id>` to publish.
- **Workflow**: Parses private vs published directory. Upon publish request, extracts keywords, updates JSON, copies to `modelshow-published`, and updates the vexuvia website index.
- **Output**: Executes website static rebuild and deploy script.

**Human Input Currently Required**:
1. Providing the prompt/questions for the models.
2. Initiating the `mdls` run.
3. Reviewing unpublished runs and typing `mspp publish <id>`.

## 2. Automation Requirements

To reach full autonomy, we need:
1. **Prompt Generator**: An automated source of prompts for the models to compare. This could be a daily LLM call that invents interesting, challenging prompts, or a pull from a curated list/API.
2. **Cron Scheduler**: An OpenClaw-native or OS-native cron to kick off the generation.
3. **Headless Execution**: `modelshow` and `mspp` must be able to run without delivering a formatted response directly to a live chat user, emitting logs instead.
4. **Auto-Publish Criteria**: `mspp` needs logic to auto-approve results (e.g., if a run succeeds and a judge output is well-formed, just publish it).

## 3. Cronjob Architecture

We will implement two separate cron jobs via the OpenClaw HEARTBEAT/cron system or OS `crontab`.

### 3a. ModelShow Generator Cron (`auto_modelshow.py`)
- **Schedule**: E.g., Daily at 08:00 UTC.
- **Flow**:
  1. Trigger an LLM call to a designated "Prompt Generator" model (e.g. Opus or Sonnet) with a system prompt: *"Generate a diverse, single, highly challenging, creative, or technical prompt suitable for evaluating multiple top-tier AI models. Return ONLY the prompt text."*
  2. Parse the result.
  3. Instantiate the `modelshow` pipeline programmatically (bypassing the chat UI trigger syntax). We will modularize the core `modelshow` logic or use a CLI wrapper so `auto_modelshow.py` can call it directly: `python3 ~/.openclaw/skills/modelshow/run_modelshow.py --prompt "..."`.
  4. The results save to `modelshow-private/`.

### 3b. MSPP Auto-Publisher Cron (`auto_mspp.py`)
- **Schedule**: E.g., Daily at 09:00 UTC.
- **Flow**:
  1. Identifies all UUIDs in `modelshow-private` missing from `modelshow-published`.
  2. For each missing UUID:
     - Run `mspp publish <uuid>` programmatically.
  3. The `mspp publish` mechanism already handles keyword extraction, moving files, indexing, and site rebuilding.

*Alternatively, we could combine the two into a single pipeline (Generate -> Run ModelShow -> Publish), but splitting them gives temporal isolation and allows private auditing if ever desired.*

### 3c. Error Handling & Retries
- Use simple python `try/except` blocks in the cron wrappers.
- If the ModelShow generation fails (API timeout, < minSuccessful responses), log to a `~/.openclaw/workspace/modelshow_cron.log` and safely exit. Tomorrow's cron will try again.
- Auto-publisher should handle malformed JSON files gracefully (skip and move to a `modelshow-quarantine/` dir).

## 4. Trigger Mechanisms
- **Recommended**: System `cron` or OpenClaw HEARTBEAT events. Since we are aiming for exact timing, standard Linux `crontab` calling python scripts is the most robust.
- Entry example for crontab:
  ```cron
  0 8 * * * /usr/bin/python3 /home/ubuntu/.openclaw/skills/modelshow/auto_cron.py >> /home/ubuntu/.openclaw/workspace/modelshow_cron.log 2>&1
  0 9 * * * /usr/bin/python3 /home/ubuntu/.openclaw/skills/mspp/auto_publish_cron.py >> /home/ubuntu/.openclaw/workspace/mspp_cron.log 2>&1
  ```

## 5. Self-Healing
- **Model failures**: The existing `modelshow` logic states that if `< minSuccessful` respond, it aborts. In a headless context, this shouldn't crash the orchestrator; the wrapper grabs the exception, limits retries to 1, and on failure logs: `Skipped run due to API timeouts.`
- **Malformed files**: The existing `mspp.py` extracts prompts using basic Python; wrap json loading with `try...except json.JSONDecodeError` to ignore corrupted save data.
- **Git issues**: If `rexuvia.com` deploy fails due to git state (as seen in `update-site.sh` checking for uncommitted changes), the cron might freeze! We must supply `--force` or `CI=true` flags to `update-site.sh` or ensure `git add . && git commit` is automated without interactive `(y/n)` prompts in `update-site.sh`.

## 6. Monitoring & Alerting
- Instead of returning UI messages to the user, redirect standard alerts to a local log file.
- Add an optional step in the cron script: If execution fails, use the OpenClaw `message` API or a simple Telegram bot webhook (e.g. `curl -s -X POST https://api.telegram.org/...`) to ping the admin channel: "ModelShow Auto-Run Failed".
- On success, it can silently deploy to rexuvia.com, or send a brief "Published: [UUID]" summary telemetry message.

## 7. Resource Management
- **Token cost**: Generating 1 new prompt per day and pinging ~3-4 models + judge is well within minimal budget. Rate limits for daily intervals are practically nonexistent.
- **API Limits**: By doing this daily rather than hourly, we avoid Anthropic/OpenAI rate limit bursts.

## 8. Integration Points
- **modelshow**: Need a CLI entrypoint or wrapper script to trigger the run without OpenClaw's direct message object.
- **mspp`: Already heavily python-scripted; we just import it or execute `mspp.py publish <uid>`.
- **rexuvia-site**: `update-site.sh` script currently prompts `Continue anyway? (y/n)` if there are uncommitted changes. To be fully autonomous: we need an environment variable like `AUTO_DEPLOY=1` that bypasses the prompt and auto-commits the published JSONs, or a separate `auto-deploy.sh` that safely performs a clean `git commit -m "Auto-publish modelshow" && git push`.

