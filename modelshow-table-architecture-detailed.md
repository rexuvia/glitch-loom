# ModelShow Results Table - Detailed Architecture

## 1. Data Flow Architecture

### 1.1 Current Data Generation
```
User triggers `/mdls <prompt>`
    │
    ▼
ModelShow skill executes (SKILL.md)
    │
    ▼
Spawns model agents → collects responses → anonymizes → judges
    │
    ▼
save_results.py writes two files:
    ├── {slug}-{timestamp}.json (structured data)
    └── {slug}-{timestamp}.md (human-readable report)
    │
    ▼
Files stored in ~/.openclaw/workspace/modelshow-results/
```

### 1.2 Proposed Data Flow Extension
```
After save_results.py succeeds:
    │
    ▼
Call update_modelshow_index.py (post-save hook)
    │
    ▼
update_modelshow_index.py:
    ├── Copy JSON file to rexuvia-site/public/modelshow-results/
    ├── Update index.json with new entry
    └── (Optional) prune old files (> 30 days)
    │
    ▼
Frontend (Vue app) polls index.json every 30s
    │
    ▼
Detect new entries → fetch individual JSON → update table
```

### 1.3 Storage Locations
- **Source directory**: `~/.openclaw/workspace/modelshow-results/` (original)
- **Web directory**: `~/.openclaw/workspace/rexuvia-site/public/modelshow-results/` (copied)
- **Index file**: `public/modelshow-results/index.json`
- **Individual result files**: `public/modelshow-results/{slug}-{timestamp}.json`

### 1.4 Update Triggers
1. **Primary**: After each ModelShow run, invoke `update_modelshow_index.py` as part of Step 8c in SKILL.md.
2. **Secondary**: Cron job (optional) to re-index all results daily (in case manual files added).
3. **Manual**: Script to rebuild index from scratch (for maintenance).

### 1.5 Index JSON Schema
```json
{
  "version": "1.0",
  "last_updated": "2026-03-04T13:00:00Z",
  "count": 42,
  "results": [
    {
      "id": "what-is-the-2026-03-02-1227",
      "slug": "what-is-the",
      "timestamp": "2026-03-02T12:27:00Z",
      "prompt": "In exactly 3 sentences, explain why prime numbers are fundamental to internet security and what makes them mathematically special for this purpose.",
      "prompt_preview": "In exactly 3 sentences, explain why prime numbers are fundamental...",
      "models_queried": ["google/gemini-2.5-pro", "openrouter/openai/gpt-5", "openrouter/deepseek/deepseek-v3.2", "openrouter/moonshotai/kimi-k2.5"],
      "models_queried_count": 4,
      "winner_model": "google/gemini-2.5-pro",
      "winner_score": 9.0,
      "total_duration_ms": 18070,
      "json_url": "/modelshow-results/what-is-the-2026-03-02-1227.json",
      "md_url": "/modelshow-results/what-is-the-2026-03-02-1227.md",
      "tags": []  // optional for future categorization
    }
  ]
}
```

### 1.6 Index Update Script (`update_modelshow_index.py`)
**Input**: Source directory path, web directory path, optional new JSON file path (if incremental).
**Output**: Updated index.json and copied files.

**Algorithm**:
1. If incremental mode and new JSON provided:
   - Parse new JSON, extract metadata
   - Add/update entry in index.json
   - Copy JSON file to web directory
2. If full rebuild:
   - Scan source directory for `*.json`
   - Parse each, collect metadata
   - Sort by timestamp descending
   - Write index.json
   - Copy all JSON files to web directory (skip if already exists and same size/timestamp)
3. Atomic write: write `index.json.tmp`, then rename.

**Configuration**:
- Retention policy: keep all files (default) or prune older than N days.
- Max index size: optional limit (e.g., 1000 entries) with pagination.

## 2. Frontend Architecture

### 2.1 Component Structure
```
App.vue
├── Existing sections (Hero, Transmissions, Games)
└── New section: ModelShow Results
    ├── ModelShowTable.vue (main component)
    │   ├── SearchBar.vue (optional)
    │   ├── ResultsTable.vue (table with sorting)
    │   └── ResultDetail.vue (expanded row)
    └── Polling service (composable)
```

### 2.2 Component: ModelShowTable.vue
**Props**: None (self-contained)
**State**:
- `results`: `Ref<Array>` – list of result metadata from index.json
- `loading`: `Ref<boolean>` – initial load
- `error`: `Ref<string|null>` – error message
- `selectedResult`: `Ref<string|null>` – ID of expanded row
- `sortBy`: `Ref<string>` – column to sort by
- `sortOrder`: `Ref<'asc'|'desc'>`
- `filterModel`: `Ref<string>` – selected model filter
- `filterDateFrom`, `filterDateTo`: `Ref<string>` – date range

**Methods**:
- `fetchIndex()`: GET `/modelshow-results/index.json`
- `fetchResult(id)`: GET `/modelshow-results/{id}.json`
- `pollResults()`: setInterval calling `fetchIndex`
- `sort(column)`: toggle sort order
- `expand(id)`: load full result and set selectedResult
- `clearFilters()`: reset filters

**Template**:
- Header: "ModelShow Comparison Results"
- Controls: Search input, model multi-select, date range, refresh button
- Table: columns (Timestamp, Prompt Preview, Models, Winner, Score, Duration)
- Each row expandable to show full comparison (rankings, responses, judge analysis)
- Footer: Polling status (Last updated X seconds ago), count of results

**Styling**: Match existing site design (dark theme, starry background, card-like rows).

### 2.3 Update Mechanism
- **Polling**: `setInterval(fetchIndex, 30000)` (30 seconds)
- **Optimistic updates**: When index changes (new entries), fetch individual JSON for new IDs.
- **Error handling**: Retry with exponential backoff, show error banner.
- **Offline support**: Cache results in localStorage, show stale data with warning.

### 2.4 State Management
Use Vue 3 Composition API with `ref` and `computed`. No need for Pinia/Vuex.

### 2.5 Routing
Option A: Add new route `/modelshow` (requires Vue Router).
Option B: Add new section to homepage (simpler, no routing).
Recommendation: Start with Option B (new section). If many results, later add dedicated route.

## 3. Backend/Integration Architecture

### 3.1 Serving Static Files
- Nginx serves `dist/` directory.
- Place JSON files under `public/modelshow-results/` → copied to `dist/modelshow-results/`.
- No backend API needed.

### 3.2 Security
- JSON files are public (no sensitive data).
- Ensure prompts don't contain private info (already assumption).
- No authentication required.
- Consider adding `X-Robots-Tag: noindex` if desired.

### 3.3 Integration with OpenClaw Skill
**Modify SKILL.md**:
Add after Step 8c (save results):
```bash
# Step 8d: Update web index
python3 ~/.openclaw/skills/modelshow/update_modelshow_index.py \
  --source ~/.openclaw/workspace/modelshow-results \
  --web ~/.openclaw/workspace/rexuvia-site/public/modelshow-results \
  --incremental "$json_path"
```

**Alternative**: Modify `save_results.py` to call index update internally (cleaner).

**Fallback**: Cron job runs every hour to sync any missing files.

### 3.4 File Permissions
- Ensure nginx user (www-data) can read files in public directory.
- Copy with `shutil.copy2` preserving metadata.

## 4. Data Schema Design

### 4.1 Extended Metadata (for index)
Derived from existing JSON fields:
- `id`: `${slug}-${timestamp_formatted}` (unique)
- `slug`: from filename
- `timestamp`: ISO string from `meta.timestamp`
- `prompt`: full prompt (could be truncated in preview)
- `prompt_preview`: first 100 characters with ellipsis
- `models_queried`: `meta.models_queried` (full model names)
- `models_queried_count`: length
- `winner_model`: `results[0].model` (rank 1)
- `winner_score`: `results[0].score`
- `total_duration_ms`: `metadata.total_duration_ms`
- `json_url`: relative URL to JSON file
- `md_url`: relative URL to Markdown file

### 4.2 Historical Data Storage
- Keep all JSON files indefinitely (storage cheap).
- Index includes all entries; frontend can paginate.
- Option to archive older files (> 1 year) to cold storage.

### 4.3 Data Consistency
- Atomic index update (write temp file, rename).
- Handle concurrent updates (if two ModelShow runs finish simultaneously) with file locking (flock) or version stamps.

## 5. Deployment Architecture

### 5.1 Directory Layout
```
rexuvia-site/
├── public/
│   ├── modelshow-results/
│   │   ├── index.json
│   │   ├── what-is-the-2026-03-02-1227.json
│   │   └── ...
│   └── ...
├── src/
│   ├── components/
│   │   └── ModelShowTable.vue
│   └── ...
└── scripts/
    └── update_modelshow_index.py
```

### 5.2 Build Process Modifications
**package.json**:
```json
{
  "scripts": {
    "prebuild": "python scripts/update_modelshow_index.py --full",
    "build": "vite build",
    ...
  }
}
```

**rebuild.sh** (already calls `npm run build`):
No change needed; prebuild will run automatically.

### 5.3 Monitoring
- Log index updates (number of results, new entries) to syslog.
- Frontend console errors.
- Health endpoint: `public/modelshow-results/health.json` with timestamp and count.

### 5.4 Technology Stack
- **Frontend**: Vue 3, Composition API, Vite (existing)
- **Styling**: CSS modules (existing)
- **Icons**: Unicode emoji (🏆🥈🥉) or inline SVG
- **Polling**: native `fetch` + `setInterval`
- **Date formatting**: `Intl.DateTimeFormat`
- **Sorting/filtering**: Computed properties

### 5.5 Performance Considerations
- Index file size: keep under 1MB (approx 5000 entries). Implement pagination if needed.
- Lazy-load individual result JSON only when expanded.
- Cache static assets with appropriate HTTP headers (`Cache-Control: public, max-age=60` for index.json, longer for individual JSON).
- Compression: nginx gzip.

## 6. Implementation Steps

### Phase 1: Data Pipeline (Backend)
1. Create `update_modelshow_index.py` script.
2. Test with existing JSON files.
3. Integrate with ModelShow skill (modify SKILL.md).
4. Set up cron job for periodic sync (optional).

### Phase 2: Frontend Component
1. Create `ModelShowTable.vue` component.
2. Add to App.vue (new section).
3. Implement polling and basic table.
4. Style to match site.

### Phase 3: Advanced Features
1. Sorting, filtering, search.
2. Expandable detail view.
3. Error handling and loading states.
4. Responsive design.

### Phase 4: Deployment
1. Update rebuild.sh if needed.
2. Deploy and test on staging (rexuvia.com).
3. Monitor for errors.
4. Document usage.

## 7. Integration Points with OpenClaw

### 7.1 Skill Integration
- Modify SKILL.md Step 8d.
- Ensure script is executable and dependencies (Python 3) available.

### 7.2 Cron Integration (optional)
Add to OpenClaw cron:
```bash
0 * * * * python3 ~/.openclaw/skills/modelshow/update_modelshow_index.py --full
```

### 7.3 File Watching (optional)
Use `inotifywait` to watch source directory for new JSON files and trigger update automatically.

## 8. Testing Plan
1. **Unit tests**: Python script (pytest), Vue component (vitest).
2. **Integration test**: Run ModelShow, verify index updated, frontend shows new entry.
3. **End-to-end test**: Deploy to test environment, simulate user interaction.

## 9. Deliverables
1. Architecture document (this)
2. Component specifications (Vue component API)
3. Data flow diagrams (textual)
4. Technology stack recommendations
5. Integration points with OpenClaw

## 10. Next Agent Tasks
The next agent should implement Phase 1 (Data Pipeline) and Phase 2 (Frontend Component) based on this architecture.

**Priority**: 
1. Write `update_modelshow_index.py`.
2. Integrate with ModelShow skill.
3. Create Vue component.
4. Add to App.vue.
5. Test end-to-end.