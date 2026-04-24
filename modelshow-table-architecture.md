# ModelShow Results Table - Architecture Design

## Overview
Integrate ModelShow skill comparison results into the rexuvia.com website as a dynamically updated table. The table will display past comparisons, allow sorting/filtering, and automatically update when new results are generated.

## System Components

### 1. Data Flow Architecture

**Current State:**
- ModelShow skill writes JSON results to `~/.openclaw/workspace/modelshow-results/`
- Each result includes metadata, ranked models, judge analysis, anonymization map
- JSON schema already includes all necessary fields

**Proposed Flow:**
1. **Result Generation Trigger:** ModelShow skill runs via `/mdls` command
2. **Result Storage:** `save_results.py` writes JSON and Markdown files to workspace directory
3. **Post-Processing Hook:** After each successful save, invoke a script (`update_modelshow_index.py`) that:
   - Copies the JSON file to website's `public/modelshow-results/` directory (or symlinks)
   - Updates a central index file (`public/modelshow-results/index.json`) with metadata
4. **Frontend Polling:** Vue app fetches `index.json` periodically to detect new results
5. **Data Consumption:** Frontend fetches individual JSON files as needed for detail view

**Update Triggers:**
- **Immediate:** After each ModelShow run, copy JSON to public directory and update index
- **Periodic:** Optional cron job to re-index all results (for manual additions)
- **Manual:** Script to rebuild index from all JSON files

**Storage Location:**
- Primary: `~/.openclaw/workspace/modelshow-results/` (original location)
- Web-accessible: `~/.openclaw/workspace/rexuvia-site/public/modelshow-results/` (copied/symlinked)
- Index file: `public/modelshow-results/index.json`

**Index JSON Schema:**
```json
{
  "last_updated": "2026-03-04T13:00:00Z",
  "results": [
    {
      "id": "what-is-the-2026-03-02-1227",
      "slug": "what-is-the",
      "timestamp": "2026-03-02T12:27:00Z",
      "prompt": "In exactly 3 sentences, explain why prime numbers are fundamental...",
      "prompt_preview": "In exactly 3 sentences, explain why prime numbers are fundamental...",
      "models_queried": ["google/gemini-2.5-pro", "openrouter/openai/gpt-5", ...],
      "models_queried_count": 4,
      "winner_model": "google/gemini-2.5-pro",
      "winner_score": 9.0,
      "total_duration_ms": 18070,
      "json_path": "/modelshow-results/what-is-the-2026-03-02-1227.json",
      "md_path": "/modelshow-results/what-is-the-2026-03-02-1227.md"
    }
  ]
}
```

### 2. Frontend Architecture

**Single-Page Application Structure:**
- New route `/modelshow` added to Vue Router (if needed) or new section in homepage
- Component: `ModelShowTable.vue` (or integrated into existing App.vue)
- State management: Vue reactive state (`ref`, `reactive`) for results list and loading status

**Table Component Design:**
- Sortable columns: Timestamp, Prompt, Models Count, Winner, Winner Score, Duration
- Filterable by model (multi-select), date range
- Expandable rows to show more details without leaving page
- Responsive design matching existing site aesthetic

**Update Mechanism:**
- **Polling:** Fetch `index.json` every 30 seconds (configurable)
- **Optimistic updates:** When new result detected, fetch its JSON and add to table
- **No WebSockets/SSE** needed initially (static hosting)

**State Management:**
- `results`: Array of result metadata
- `loading`: Boolean for initial load
- `error`: Optional error state
- `lastPoll`: Timestamp of last successful poll

**User Interaction:**
- Click on row to expand and show full comparison (rankings, responses, judge analysis)
- Link to raw JSON/Markdown files for download
- Search/filter bar above table
- "Refresh" button for manual update

### 3. Backend/Integration Architecture

**OpenClaw Serving JSON Data:**
- Nginx currently serves static files from `dist/`
- Place JSON files in `public/modelshow-results/` → copied to `dist/modelshow-results/` during build
- No API endpoint needed; static JSON files suffice

**Security and Access Control:**
- Publicly accessible (no sensitive data)
- ModelShow results contain only prompts and model responses (no private info)
- Consider if any prompts could contain sensitive data; could filter based on config

**Index Generation Script:**
```python
# update_modelshow_index.py
1. Scan source directory for *.json files
2. Parse each JSON, extract metadata
3. Build index.json with sorted results (newest first)
4. Copy new/changed JSON files to public directory
5. Optionally prune old files (> N days) if needed
```

**Integration Points with OpenClaw:**
- Modify `save_results.py` to call index update script after successful save
- Or add a post-save hook in ModelShow skill (Step 8c) to trigger update
- Ensure file permissions allow web user (nginx) to read copied files

### 4. Data Schema Design

**Extended JSON Schema (for frontend optimization):**
Add fields to existing JSON during index generation:
- `id`: unique identifier (slug + timestamp)
- `prompt_preview`: truncated prompt (e.g., first 100 chars)
- `winner_model`: model with rank 1
- `winner_score`: score of winner
- `models_list`: array of model aliases (for filtering)
- `tags`: optional categorization (future)

**Historical Data Storage:**
- Keep all historical JSON files indefinitely (or configurable retention)
- Store in chronological order; index includes timestamp for sorting
- Consider compression for older files (> 1 month) if storage concern

**Data Consistency:**
- Atomic writes: write index.json.tmp → rename to index.json
- Handle concurrent updates (unlikely but possible) with file locking or versioning

### 5. Deployment Architecture

**Integration with Existing rexuvia.com Site:**

1. **Directory Structure:**
```
rexuvia-site/
├── public/
│   ├── modelshow-results/
│   │   ├── index.json
│   │   ├── result-1.json
│   │   └── result-2.json
│   └── ...
├── src/
│   ├── components/
│   │   └── ModelShowTable.vue
│   └── ...
└── ...
```

2. **Build Process Modifications:**
- Add `update_modelshow_index.py` script to package.json scripts
- Modify `rebuild.sh` to run index update before `npm run build`
- Ensure JSON files are copied before build (so they're included in dist)

3. **Monitoring and Logging:**
- Log index updates (file count, new results) to syslog
- Frontend error logging to console (optional Sentry integration)
- Health check endpoint (maybe `/modelshow-results/health.json`)

**Technology Stack Recommendations:**
- **Frontend:** Vue 3 Composition API (already used), Vite (existing)
- **Styling:** Existing CSS (no new frameworks)
- **Icons:** Use existing emoji set or add simple SVG icons
- **Polling:** `setInterval` with fetch, with exponential backoff on errors
- **Build Tool:** Use existing npm scripts; add `prebuild` script

**Implementation Steps:**

Phase 1: Data Pipeline
1. Create `update_modelshow_index.py` script
2. Integrate with ModelShow skill (modify SKILL.md or save_results.py)
3. Test with existing JSON files

Phase 2: Frontend Component
1. Create `ModelShowTable.vue` component
2. Integrate into App.vue (new section or route)
3. Implement polling and table rendering

Phase 3: Polish and Deployment
1. Add filtering, sorting, search
2. Style to match site theme
3. Update rebuild.sh and test deployment
4. Monitor for errors

## Architecture Diagrams

### Data Flow Diagram
```
User triggers ModelShow
    │
    ▼
ModelShow skill runs
    │
    ▼
save_results.py writes JSON+MD
    │
    ▼
update_modelshow_index.py
    ├── Copies JSON to public/
    ├── Updates index.json
    └── (Optional) prune old files
    │
    ▼
Frontend polls index.json
    │
    ▼
Vue renders table
    │
    ▼
User sees updated results
```

### Component Diagram
```
┌─────────────────────────────────────────────────┐
│               ModelShowTable.vue                │
├─────────────────────────────────────────────────┤
│ State:                                          │
│  - results: Ref<Array>                         │
│  - loading: Ref<boolean>                       │
│  - error: Ref<string|null>                     │
├─────────────────────────────────────────────────┤
│ Methods:                                        │
│  - fetchIndex()                                │
│  - pollResults()                               │
│  - expandRow(id)                               │
│  - sortBy(column)                              │
├─────────────────────────────────────────────────┤
│ Template:                                       │
│  - Table with columns                           │
│  - Search/filter inputs                         │
│  - Expandable detail view                      │
│  - Refresh button                              │
└─────────────────────────────────────────────────┘
```

## Integration Points with OpenClaw

1. **Skill Modification:** Add post-save hook in ModelShow skill (Step 8c) to call index update script.
2. **File System:** Ensure web user (nginx) can read files copied to public directory.
3. **Cron Job (optional):** Set up periodic re-indexing via OpenClaw cron to handle manual file additions.

## Security Considerations
- JSON files contain only public data (prompts and model responses)
- Ensure no sensitive information leakage (prompts may contain personal data? Assume not)
- Rate limiting not needed for static file serving
- Index file should not expose internal paths

## Performance Considerations
- Index file size grows with results; implement pagination or lazy loading if > 1000 entries
- Polling interval configurable (default 30s)
- Cache JSON files with appropriate HTTP headers (nginx)

## Deliverables
1. Architecture document (this)
2. Component specifications
3. Data flow diagrams
4. Technology stack recommendations
5. Integration points with OpenClaw

## Next Steps
1. Implement Phase 1 (Data Pipeline)
2. Implement Phase 2 (Frontend Component)
3. Implement Phase 3 (Polish and Deployment)
4. Test with existing ModelShow results
5. Deploy to rexuvia.com