# ModelShow Results Table Integration

## Goal
Add a listing of ModelShow skill results to rexuvia.com as a dynamically updated table loaded from JSON.

## Architecture
See `modelshow-table-architecture-final.md` for full details.

## Implementation Steps

### 1. Data Pipeline (`update_modelshow_index.py`)
- Script to sync JSON files from `~/.openclaw/workspace/modelshow-results/` to `rexuvia-site/public/modelshow-results/`
- Creates/updates `index.json` with metadata for frontend
- Supports incremental updates and full rebuild
- Retention policies (optional)

**Integration**: Modify ModelShow SKILL.md to call script after saving results.

### 2. Frontend Component (`ModelShowTable.vue`)
- Vue 3 component displaying table of results
- Polling every 30 seconds for new results
- Sortable columns (timestamp, models, winner, score, duration)
- Filter by model and date range
- Expandable rows showing full comparison details

**Integration**: Add component to `App.vue` after Games section.

### 3. Build Process
- Add `prebuild` script to `package.json` that runs index update
- Ensure `rebuild.sh` works unchanged

## Files Created/Modified

### New Files
1. `~/.openclaw/skills/modelshow/update_modelshow_index.py` – sync script
2. `rexuvia-site/scripts/update_modelshow_index.py` – copy for prebuild
3. `rexuvia-site/src/components/ModelShowTable.vue` – Vue component

### Modified Files
1. `~/.openclaw/skills/modelshow/SKILL.md` – add post‑save hook
2. `rexuvia-site/package.json` – add prebuild script
3. `rexuvia-site/src/App.vue` – import and add component

## Testing

### Data Pipeline
```bash
cd ~/.openclaw/workspace
python3 ~/.openclaw/skills/modelshow/update_modelshow_index.py \
  --source modelshow-results \
  --web rexuvia-site/public/modelshow-results \
  --full --verbose
```

Check `rexuvia-site/public/modelshow-results/index.json` exists.

### Frontend
Run `npm run dev` in `rexuvia-site/` and verify table loads.

### End-to-End
Trigger a ModelShow comparison (`/mdls <prompt>`), verify JSON appears in public directory and frontend updates.

## Deployment
1. Push changes to GitHub
2. Run `./rebuild.sh` on server
3. Verify site updates

## Monitoring
- Check browser console for errors
- Verify index.json updates after each ModelShow run
- Ensure polling works (network tab)

## Next Agent Tasks
1. **Implement** `update_modelshow_index.py` (draft exists)
2. **Integrate** with ModelShow skill (modify SKILL.md)
3. **Create** Vue component (`ModelShowTable.vue`)
4. **Add** to App.vue
5. **Update** package.json prebuild script
6. **Test** end-to-end
7. **Deploy**