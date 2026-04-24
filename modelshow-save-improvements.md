# ModelShow Save Improvements

## What Was Changed

### 1. New Save Script: `save_results.py`

Created `/home/ubuntu/.openclaw/skills/modelshow/save_results.py` to handle dual-format saving:

**Features:**
- ✅ Saves both **Markdown** and **JSON** formats atomically
- ✅ Proper error handling with JSON success/failure responses
- ✅ Consistent filename slugification (first 5 words of prompt)
- ✅ Structured JSON perfect for website integration
- ✅ Human-readable Markdown with medals (🏆🥈🥉) and full analysis

**Input Format:**
```json
{
  "prompt": "...",
  "timestamp": "2026-02-28T01:20:00Z",
  "models": ["opus", "grok", "kimi"],
  "judge_model": "gemini31or",
  "ranked_results": [...],
  "deanonymized_judge_output": "...",
  "anonymization_map": {...},
  "metadata": {...}
}
```

**Output Format:**
```json
{
  "success": true,
  "md_path": "/path/to/result.md",
  "json_path": "/path/to/result.json",
  "slug": "prompt-slug"
}
```

### 2. Updated SKILL.md Step 8

Rewrote Step 8 to use the new `save_results.py` script with:
- Clear sub-steps (8a: build data, 8b: run script, 8c: handle errors)
- Explicit JSON structure for the script input
- Error handling that doesn't block result presentation
- Path updates to `formatted_output` with both file locations

### 3. File Outputs

Both files use the same naming pattern: `{slug}-{YYYY-MM-DD-HHMM}.{ext}`

#### Markdown Format
- Human-readable report
- Medals for top 3 rankings (🏆🥈🥉)
- Full response text from each model
- Judge's assessment for each model
- Complete judge analysis
- Anonymization map (audit trail)
- Metadata (duration, success/fail counts)

#### JSON Format (Website-Ready)
```json
{
  "meta": {
    "timestamp": "...",
    "prompt": "...",
    "models_queried": [...],
    "judge_model": "...",
    "judging_mode": "blind"
  },
  "results": [
    {
      "rank": 1,
      "model": "opus",
      "score": 9.5,
      "response": "...",
      "assessment": "..."
    }
  ],
  "judge_analysis": "...",
  "anonymization_map": {...},
  "metadata": {...}
}
```

## Benefits

### For Human Review
- **Markdown files** are perfect for reading results later
- Medals make rankings visually clear
- Full context preserved (responses + assessments + analysis)

### For Website Integration
- **JSON files** can be loaded directly into rexuvia.com
- Clean structured data (no parsing needed)
- Consistent schema for building UI components
- Could power a "ModelShow Results Gallery" page

### For Reliability
- Atomic save operation (both formats or neither)
- Error handling that doesn't break the user experience
- Success/failure status returned to orchestrator
- Backup created before modifying SKILL.md

## Testing

Tested with sample query:
- ✅ Both files created successfully
- ✅ Markdown format verified (medals, structure, content)
- ✅ JSON format verified (valid JSON, correct schema)
- ✅ Error handling works (missing fields detected)

## Next Steps

1. **Test with real ModelShow query** - Run `mdls <prompt>` and verify saves
2. **Website integration** - Consider adding a ModelShow results page to rexuvia.com
3. **Archive cleanup** - Optional: bulk convert old 4 MD files to dual format
4. **Monitoring** - Watch for save failures in production use

## Files Modified

- ✅ Created: `/home/ubuntu/.openclaw/skills/modelshow/save_results.py`
- ✅ Modified: `/home/ubuntu/.openclaw/skills/modelshow/SKILL.md` (Step 8)
- ✅ Backup: `/home/ubuntu/.openclaw/skills/modelshow/SKILL.md.backup`

## Rollback

If issues arise:
```bash
cd /home/ubuntu/.openclaw/skills/modelshow
cp SKILL.md.backup SKILL.md
rm save_results.py
```

## Ready to Use

The improved ModelShow skill is ready! Next time you run `mdls <query>`, results will be saved in both formats automatically.
