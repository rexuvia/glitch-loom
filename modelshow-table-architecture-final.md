# ModelShow Results Table - Complete Architecture

## System Overview
Add a listing of ModelShow skill results in a dynamically updated table loaded from JSON on rexuvia.com.

## Architecture Diagram (Textual)

```
┌─────────────────────────────────────────────────────────────────────┐
│                        User                                         │
│                         │                                           │
│                         ▼                                           │
│                 OpenClaw Telegram / Discord                          │
│                         │                                           │
│                         ▼                                           │
│               /mdls <prompt> (ModelShow skill)                     │
│                         │                                           │
│                         ▼                                           │
│           ┌─────────────────────────────┐                           │
│           │  ModelShow Orchestrator     │                           │
│           │  - Spawns model agents      │                           │
│           │  - Collects responses       │                           │
│           │  - Judges blind            │                           │
│           └──────────────┬──────────────┘                           │
│                          │                                           │
│                          ▼                                           │
│           ┌─────────────────────────────┐                           │
│           │  save_results.py            │                           │
│           │  - Writes JSON + MD files   │                           │
│           │  - Returns paths            │                           │
│           └──────────────┬──────────────┘                           │
│                          │                                           │
│                          ▼                                           │
│           ┌─────────────────────────────┐                           │
│           │  update_modelshow_index.py  │                           │
│           │  - Copies JSON to web dir   │                           │
│           │  - Updates index.json        │                           │
│           └──────────────┬──────────────┘                           │
│                          │                                           │
│                          ▼                                           │
│           ┌─────────────────────────────┐                           │
│           │  rexuvia-site/public/        │                           │
│           │  modelshow-results/          │                           │
│           │  ├── index.json              │                           │
│           │  ├── result-1.json           │                           │
│           │  └── result-2.json           │                           │
│           └──────────────┬──────────────┘                           │
│                          │                                           │
│                          ▼                                           │
│           ┌─────────────────────────────┐                           │
│           │  Vue App (rexuvia.com)     │                           │
│           │  - Polls index.json        │                           │
│           │  - Renders table           │                           │
│           │  - Fetches detail JSON     │                           │
│           └──────────────┬──────────────┘                           │
│                          │                                           │
│                          ▼                                           │
│                        Browser                                      │
└─────────────────────────────────────────────────────────────────────┘
```

## Component Specifications

### 1. Data Pipeline (`update_modelshow_index.py`)
**Purpose**: Sync ModelShow results to web-accessible directory and maintain index.
**Input**: Source directory of JSON files, web directory target.
**Output**: Updated `index.json` and copied JSON/MD files.

**Key Features**:
- Incremental update (when new result added)
- Full rebuild (sync all files)
- Retention policy (prune old files)
- Atomic writes (temp file rename)
- Error tolerant

**Integration**: Called from ModelShow skill after successful save.

### 2. Frontend Component (`ModelShowTable.vue`)
**Purpose**: Display table of ModelShow results with real-time updates.
**Location**: `rexuvia-site/src/components/ModelShowTable.vue`

**State**:
- `results`: Array of result metadata
- `loading`, `error`, `selectedResultId`, `selectedResultFull`
- Sorting/filtering state

**Methods**:
- `fetchIndex()`: Poll index.json
- `fetchResult(id)`: Load individual result
- `toggleSort()`, `toggleExpand()`, etc.

**Template**:
- Table with columns: Timestamp, Prompt Preview, Models, Winner/Score, Duration, Actions
- Expandable rows for full details
- Filter controls (model, date range)
- Polling status indicator

**Styling**: Matches existing dark theme with starry background.

### 3. Integration with Existing Site
**Modifications to App.vue**:
- Import and add `<ModelShowTable />` component after Games section.
- Update `package.json` scripts: `prebuild` runs index update.

**Build Process**:
- `npm run build` → `prebuild` script runs `update_modelshow_index.py --full`
- `rebuild.sh` unchanged (already calls `npm run build`)

## Data Flow Diagrams

### Flow 1: New ModelShow Result
```
1. User triggers /mdls <prompt>
2. ModelShow skill runs → produces JSON+MD files
3. save_results.py writes files to workspace/modelshow-results/
4. SKILL.md calls update_modelshow_index.py --incremental <json_path>
5. Script copies JSON/MD to public/modelshow-results/
6. Script updates index.json (prepends new entry)
7. Frontend polls index.json (every 30s) → sees new entry
8. Frontend fetches new result JSON → updates table
```

### Flow 2: Frontend Polling
```
1. onMounted(): fetchIndex()
2. setInterval(fetchIndex, 30000)
3. fetchIndex():
   - GET /modelshow-results/index.json
   - Compare IDs with current results
   - If new IDs, fetch individual JSONs
   - Update reactive results array
4. User interacts (sort, filter, expand)
```

### Flow 3: Manual Sync (Cron)
```
0 * * * * python3 ~/.openclaw/skills/modelshow/update_modelshow_index.py \
  --source ~/.openclaw/workspace/modelshow-results \
  --web ~/.openclaw/workspace/rexuvia-site/public/modelshow-results \
  --full
```

## Technology Stack Recommendations

### Backend / Data Pipeline
- **Language**: Python 3 (already used by OpenClaw)
- **Libraries**: Standard library only (json, pathlib, shutil, datetime)
- **Integration**: Direct file copy, no network calls
- **Deployment**: Part of ModelShow skill, cron job optional

### Frontend
- **Framework**: Vue 3 Composition API (already used)
- **Build Tool**: Vite (existing)
- **Styling**: CSS (no new frameworks)
- **Polling**: Native `fetch` + `setInterval`
- **State Management**: Vue reactive API (`ref`, `computed`)
- **Icons**: Unicode emoji (🏆🥈🥉) for medals

### Infrastructure
- **Web Server**: Nginx serving static files from `dist/`
- **File Storage**: Local filesystem (same machine)
- **Update Mechanism**: File copy + polling
- **Security**: All data public, no authentication needed

## Integration Points with OpenClaw

### 1. ModelShow Skill Modification
**File**: `~/.openclaw/skills/modelshow/SKILL.md`
**Location**: Step 8 (Save Results), after successful save.

**Add Step 8d**:
```bash
# Step 8d: Update web index
if [[ -f "$json_path" ]]; then
    python3 ~/.openclaw/skills/modelshow/update_modelshow_index.py \
        --source ~/.openclaw/workspace/modelshow-results \
        --web ~/.openclaw/workspace/rexuvia-site/public/modelshow-results \
        --incremental "$json_path"
fi
```

**Placement**: After `save_results.py` execution, before presenting results.

### 2. Cron Integration (Optional)
Add to OpenClaw cron for periodic full sync:
```bash
0 * * * * python3 ~/.openclaw/skills/modelshow/update_modelshow_index.py \
  --source ~/.openclaw/workspace/modelshow-results \
  --web ~/.openclaw/workspace/rexuvia-site/public/modelshow-results \
  --full
```

### 3. Build Process Integration
**File**: `rexuvia-site/package.json`
Add prebuild script:
```json
"scripts": {
  "prebuild": "python scripts/update_modelshow_index.py --source ~/.openclaw/workspace/modelshow-results --web ./public/modelshow-results --full",
  "build": "vite build",
  ...
}
```

**Note**: Ensure script is copied to `rexuvia-site/scripts/` directory.

### 4. Directory Permissions
Ensure nginx user (www-data) can read files in `public/modelshow-results/`. Default permissions (644) should suffice.

## Data Schema

### Index JSON (`index.json`)
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
      "prompt": "Full prompt text...",
      "prompt_preview": "First 100 chars...",
      "models_queried": ["google/gemini-2.5-pro", "openrouter/openai/gpt-5"],
      "models_queried_count": 4,
      "winner_model": "google/gemini-2.5-pro",
      "winner_score": 9.0,
      "total_duration_ms": 18070,
      "json_url": "/modelshow-results/what-is-the-2026-03-02-1227.json",
      "md_url": "/modelshow-results/what-is-the-2026-03-02-1227.md",
      "tags": []
    }
  ]
}
```

### Individual Result JSON (existing schema)
Same as current ModelShow output.

## Deployment Steps

### Phase 1: Data Pipeline
1. Place `update_modelshow_index.py` in `~/.openclaw/skills/modelshow/`
2. Test with existing JSON files:
   ```bash
   cd ~/.openclaw/workspace
   python3 ~/.openclaw/skills/modelshow/update_modelshow_index.py \
     --source modelshow-results \
     --web rexuvia-site/public/modelshow-results \
     --full --verbose
   ```
3. Verify `rexuvia-site/public/modelshow-results/index.json` created.
4. Modify SKILL.md to call script after save.

### Phase 2: Frontend Component
1. Create `ModelShowTable.vue` in `rexuvia-site/src/components/`
2. Add component to `App.vue`
3. Add CSS styles to `App.vue` (or separate CSS module)
4. Test with local dev server (`npm run dev`)

### Phase 3: Build Integration
1. Copy `update_modelshow_index.py` to `rexuvia-site/scripts/`
2. Update `package.json` prebuild script
3. Run `npm run build` to verify index generation
4. Deploy with `./rebuild.sh`

### Phase 4: Monitoring & Polish
1. Verify polling works (check browser console)
2. Add error handling (network errors, malformed JSON)
3. Add loading skeletons
4. Optimize performance (virtual scrolling if many results)

## Security Considerations
- **Data Exposure**: All prompts and model responses are public; ensure no private data in prompts.
- **File Permissions**: Web directory readable by nginx user.
- **Rate Limiting**: None needed (static files).
- **Index Size**: Limit entries to prevent huge downloads (max 1000 entries).

## Performance Considerations
- **Index Size**: Keep under 1MB; implement pagination if >1000 entries.
- **Polling Interval**: 30 seconds reasonable.
- **Caching**: Set appropriate Cache-Control headers in nginx.
- **Lazy Loading**: Load individual JSON only when expanded.

## Future Enhancements
1. **Real-time Updates**: Server-Sent Events (SSE) if backend added.
2. **Search**: Full-text search across prompts/responses.
3. **Charts**: Visualize model performance over time.
4. **Tags**: Categorize prompts (e.g., "coding", "creative", "reasoning").
5. **User Interactions**: Upvote/downvote results, comments.

## Deliverables Summary
1. **Architecture Document** (this file)
2. **Component Specifications** (`ModelShowTable.vue` spec)
3. **Data Flow Diagrams** (textual)
4. **Technology Stack Recommendations** (Vue 3, Python, etc.)
5. **Integration Points** (SKILL.md modification, cron, build process)

## Next Agent Tasks
1. Implement `update_modelshow_index.py` (already drafted)
2. Integrate with ModelShow skill (modify SKILL.md)
3. Create Vue component (`ModelShowTable.vue`)
4. Integrate into App.vue
5. Update build process
6. Test end-to-end
7. Deploy to rexuvia.com