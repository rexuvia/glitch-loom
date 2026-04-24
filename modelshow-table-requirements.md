# Modelshow Results Table - Requirements Analysis

## 1. Data Structure Analysis

### Current Data Generation
- **Source:** Modelshow skill executes blind multi-model comparisons.
- **Output:** Each comparison run produces two files:
  - `.md` (human-readable markdown report)
  - `.json` (structured data for programmatic use)
- **Location:** `~/.openclaw/workspace/modelshow-results/`
- **Naming pattern:** `{slug}-{YYYY-MM-DD-HHMM}.json`

### JSON Structure (from example)
```json
{
  "meta": {
    "timestamp": "ISO 8601",
    "prompt": "user prompt",
    "models_queried": ["full model names"],
    "judge_model": "full judge model name",
    "judging_mode": "blind"
  },
  "results": [
    {
      "rank": 1,
      "model": "full model name",
      "model_alias": "alias",
      "score": 9.0,
      "response": "full response text",
      "assessment": "judge's assessment"
    },
    ...
  ],
  "judge_analysis": "full judge analysis text",
  "anonymization_map": {"Response A": "full model name", ...},
  "metadata": {
    "total_duration_ms": 18070,
    "successful_models": 4,
    "failed_models": 0,
    "timed_out_models": []
  }
}
```

### Optimal JSON Structure for Table
The existing JSON structure is already suitable for table display. However, for efficient loading of multiple results, we may want a summary index file that lists all runs with key metadata (timestamp, prompt, models, top-ranked model, etc.) to avoid loading all JSON files at once.

**Proposed index JSON:**
```json
{
  "index": [
    {
      "slug": "in-exactly-3-sentences,-explain",
      "timestamp": "2026-03-02T12:27:00Z",
      "prompt": "In exactly 3 sentences...",
      "models_queried": ["google/gemini-2.5-pro", ...],
      "top_model": "google/gemini-2.5-pro",
      "top_score": 9.0,
      "json_path": "in-exactly-3-sentences,-explain-2026-03-02-1227.json",
      "md_path": "..."
    },
    ...
  ]
}
```

**Decision:** Start with loading all JSON files directly; if performance becomes an issue, implement an index generation script.

## 2. Functional Requirements

### Core Features
1. **Listing of all comparison runs** – sorted by timestamp (newest first)
2. **Table view** – columns: timestamp, prompt (truncated), models count, top model, top score, actions
3. **Detailed view** – click on a row to expand and show full results: ranked list, responses, judge analysis
4. **Search/filter** – by prompt text, model names, date range
5. **Dynamic updates** – new results appear automatically without page refresh
6. **Export options** – download JSON, copy to clipboard, share link

### Dynamic Update Mechanisms
- **Polling:** Periodically fetch list of JSON files (e.g., every 30 seconds)
- **Server-Sent Events (SSE):** If OpenClaw gateway supports streaming new result events
- **WebSocket:** Real-time notification when a new comparison completes
- **File system watcher:** Backend watches directory and pushes updates

**Recommendation:** Start with simple polling (every 30-60s) due to simplicity and static file serving. If real-time updates are critical, consider adding SSE via OpenClaw gateway.

### User Interactions
- Click row to expand details
- Button to show/hide full response text (can be lengthy)
- Sort table by column (timestamp, score, etc.)
- Filter by model (multiselect)
- Search prompt text
- Refresh button (manual)
- Delete result (optional, with confirmation)

## 3. Technical Requirements

### Integration with OpenClaw Infrastructure
- **Frontend:** Static HTML/JS page served from secure VPN-only subdomain (`secure.rexuvia.com/modelshow`)
- **Backend:** Either:
  1. Pure static: nginx serves JSON files directly from `modelshow-results` directory (requires nginx location config)
  2. API proxy: OpenClaw gateway adds endpoints (`/api/modelshow/results`, `/api/modelshow/results/{slug}`) to serve JSON data
- **Authentication:** VPN IP restriction already ensures only authorized users access secure subdomain. No additional auth needed.

### Update Mechanism
- **Polling:** Frontend JavaScript fetches index or list of JSON files via `fetch()`.
- **Directory listing:** nginx can serve directory index if autoindex is enabled (not recommended for security). Better to have a small backend script that generates index JSON.
- **Real-time:** Could use OpenClaw's existing WebSocket connections (if any) but adds complexity.

### Performance Considerations
- Number of results could grow large (hundreds). Need pagination or virtual scrolling.
- JSON files average ~5-10KB each; loading all at once may be okay for up to 100 results (~1MB). Use lazy loading.
- Cache control: JSON files are immutable; can set long cache headers.

### Cross-Origin Considerations
If frontend is served from `secure.rexuvia.com` and JSON files are served from same origin (via nginx location), no CORS issues. If served from different path, ensure CORS headers.

## 4. UI/UX Requirements

### Table Design
- Clean, modern design matching existing Rexuvia secure portal aesthetic (dark theme, grid background, accent color #e87461)
- Responsive table: horizontal scroll on mobile, or card layout for small screens
- Column visibility: allow hiding columns (e.g., response text)
- Row highlighting on hover

### Mobile Responsiveness
- Stack table rows as cards on narrow screens
- Ensure touch-friendly tap targets
- Collapsible sections for details

### Visual Indicators for Updates
- Badge showing "New" for results added since page load
- Subtle animation when new row appears
- Timestamp relative time (e.g., "2 minutes ago") with auto-update

### Loading States
- Skeleton loading while fetching data
- Error handling: display message if JSON fails to load

## 5. Integration Points

### Modelshow Skill Writing to JSON
- Skill already saves JSON via `save_results.py`. No changes needed.
- Optionally, skill could trigger a webhook or update an index file after each save.

### Web Interface Reading JSON
**Option A: Direct static file serving**
1. Add nginx location to serve `~/.openclaw/workspace/modelshow-results/` under `/modelshow-results/` path on secure subdomain.
2. Frontend fetches `/modelshow-results/` (returns HTML directory listing) or better, a pre-generated `index.json`.
3. Frontend loads each JSON file via its path.

**Option B: API proxy via OpenClaw gateway**
1. Extend OpenClaw gateway with REST endpoints:
   - `GET /api/modelshow/results` – list all results (metadata)
   - `GET /api/modelshow/results/{slug}` – get full JSON
2. Gateway reads files from disk (same directory).
3. Frontend uses existing API base URL.

**Recommendation:** Start with Option A (simpler, no code changes to OpenClaw). Create a small script that generates `index.json` on a schedule (cron) or on each new result.

### Authentication/Security Considerations
- Already protected by VPN IP allowlist (secure.rexuvia.com).
- JSON files may contain model responses and judge assessments; not sensitive but should remain private.
- Ensure directory listing is disabled to avoid exposing file names unintentionally (though not critical).
- If public exposure is desired later, consider redacting internal model aliases.

## 6. Proposed Architecture

### Phase 1: Minimal Viable Table
1. **Nginx config:** Add location block in `secure.rexuvia.com` server to serve `modelshow-results` directory as static files at path `/modelshow-results/`.
2. **Index generation:** Create a Python script that scans directory, generates `index.json` with metadata, run via cron every minute.
3. **HTML page:** Create `modelshow.html` in secure directory with Vue.js or plain JavaScript that:
   - Fetches `index.json`
   - Renders table
   - Polls for updates every 60s
   - Supports expanding rows for details
4. **Add link:** Update secure portal `index.html` to include a card linking to `/modelshow.html`.

### Phase 2: Enhanced Features
- Search and filter UI
- Sortable columns
- Real-time updates via SSE (if needed)
- Export functionality
- Delete result (with confirmation)

### Phase 3: Integration with OpenClaw Gateway
- Move API endpoints into OpenClaw for better integration with other data (sessions, skills).
- Use existing authentication mechanisms.

## 7. Open Questions
- Should the table be accessible from the main OpenClaw dashboard (port 18789) instead of secure portal?
- Is there a preference for using Vue components consistent with the main site (rexuvia-site) or plain JS for simplicity?
- What is the expected frequency of new results? Determines polling interval.
- Should we archive old results or implement pagination from the start?

## Next Steps for Implementation
1. Create detailed technical design document (architecture)
2. Implement nginx configuration change
3. Develop index generation script
4. Build frontend HTML/JS page
5. Test with existing JSON files
6. Deploy and iterate based on feedback.