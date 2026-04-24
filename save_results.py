#!/usr/bin/env python3
"""
Save ModelShow results to both MD and JSON formats.
Usage: python3 save_results.py <<'ENDJSON'
{
  "prompt": "...",
  "timestamp": "2026-02-28T01:00:00Z",
  "models": ["opus", "grok", "kimi"],
  "judge_model": "gemini31or",
  "ranked_results": [
    {
      "rank": 1,
      "model": "opus",
      "score": 9.5,
      "placeholder": "Response A",
      "response_text": "...",
      "judge_notes": "..."
    }
  ],
  "deanonymized_judge_output": "...",
  "anonymization_map": {"Response A": "opus", "Response B": "grok"},
  "metadata": {
    "total_duration_ms": 45000,
    "successful_models": 3,
    "failed_models": 0,
    "timed_out_models": []
  }
}
ENDJSON
"""

import sys
import json
import os
from pathlib import Path
from datetime import datetime

def slugify(text, max_words=5):
    """Convert text to slug: first N words, lowercased, hyphenated."""
    words = text.strip().split()[:max_words]
    return '-'.join(w.lower().replace("'", "").replace('"', '') for w in words)

def format_timestamp(iso_string):
    """Convert ISO timestamp to YYYY-MM-DD-HHMM format."""
    dt = datetime.fromisoformat(iso_string.replace('Z', '+00:00'))
    return dt.strftime('%Y-%m-%d-%H%M')

def get_medal(rank):
    """Return medal emoji for rank."""
    medals = {1: '🏆', 2: '🥈', 3: '🥉'}
    return medals.get(rank, '')

def save_markdown(data, output_path):
    """Generate and save markdown report."""
    md = []
    md.append("# ModelShow Results")
    md.append(f"**Date:** {data['timestamp']}")
    md.append(f"**Prompt:** {data['prompt']}")
    md.append(f"**Models:** {', '.join(data['models'])}")
    md.append(f"**Judge:** {data['judge_model']}")
    md.append(f"**Judging Mode:** Blind (model identities hidden from judge)")
    md.append("")
    md.append("---")
    md.append("")
    
    # Rankings section
    md.append("## Rankings")
    md.append("")
    
    for result in sorted(data['ranked_results'], key=lambda x: x['rank']):
        medal = get_medal(result['rank'])
        md.append(f"### {medal} **{result['model']}** — {result['score']}/10")
        md.append("")
        md.append("**Judge's Assessment:**")
        md.append(result.get('judge_notes', '(No notes available)'))
        md.append("")
        md.append("**Full Response:**")
        md.append(result.get('response_text', '(No response text available)'))
        md.append("")
        md.append("---")
        md.append("")
    
    # Full judge analysis
    md.append("## Judge's Full Analysis")
    md.append("")
    md.append(data.get('deanonymized_judge_output', '(No analysis available)'))
    md.append("")
    md.append("---")
    md.append("")
    
    # Anonymization key (audit trail)
    md.append("## Blind Judging Key (Audit)")
    md.append("")
    for placeholder, model in data.get('anonymization_map', {}).items():
        md.append(f"- {placeholder} → {model}")
    md.append("")
    md.append("---")
    md.append("")
    
    # Metadata
    meta = data.get('metadata', {})
    md.append("## Metadata")
    md.append("")
    md.append(f"- **Total Duration:** {meta.get('total_duration_ms', 0) / 1000:.1f}s")
    md.append(f"- **Successful Models:** {meta.get('successful_models', len(data['ranked_results']))}")
    md.append(f"- **Failed Models:** {meta.get('failed_models', 0)}")
    if meta.get('timed_out_models'):
        md.append(f"- **Timed Out:** {', '.join(meta['timed_out_models'])}")
    md.append("")
    
    # Write file
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(md))
    
    return output_path

def save_json(data, output_path):
    """Save structured JSON for website integration."""
    json_data = {
        "meta": {
            "timestamp": data['timestamp'],
            "prompt": data['prompt'],
            "models_queried": data['models'],
            "judge_model": data['judge_model'],
            "judging_mode": "blind"
        },
        "results": [
            {
                "rank": r['rank'],
                "model": r['model'],
                "score": r['score'],
                "response": r.get('response_text', ''),
                "assessment": r.get('judge_notes', '')
            }
            for r in sorted(data['ranked_results'], key=lambda x: x['rank'])
        ],
        "judge_analysis": data.get('deanonymized_judge_output', ''),
        "anonymization_map": data.get('anonymization_map', {}),
        "metadata": data.get('metadata', {})
    }
    
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(json_data, f, indent=2, ensure_ascii=False)
    
    return output_path

def main():
    try:
        # Read JSON from stdin
        input_data = sys.stdin.read()
        data = json.loads(input_data)
        
        # Validate required fields
        required = ['prompt', 'timestamp', 'models', 'judge_model', 'ranked_results']
        missing = [f for f in required if f not in data]
        if missing:
            print(json.dumps({
                "success": False,
                "error": f"Missing required fields: {', '.join(missing)}"
            }))
            sys.exit(1)
        
        # Expand output directory (handle ~)
        output_dir = Path(data.get('output_dir', '~/.openclaw/workspace/modelshow-results')).expanduser()
        output_dir.mkdir(parents=True, exist_ok=True)
        
        # Generate filename
        slug = slugify(data['prompt'])
        timestamp_str = format_timestamp(data['timestamp'])
        base_name = f"{slug}-{timestamp_str}"
        
        md_path = output_dir / f"{base_name}.md"
        json_path = output_dir / f"{base_name}.json"
        
        # Save both formats
        saved_md = save_markdown(data, md_path)
        saved_json = save_json(data, json_path)
        
        # Return success with paths
        result = {
            "success": True,
            "md_path": str(saved_md),
            "json_path": str(saved_json),
            "slug": slug
        }
        print(json.dumps(result, indent=2))
        
    except json.JSONDecodeError as e:
        print(json.dumps({
            "success": False,
            "error": f"Invalid JSON input: {str(e)}"
        }))
        sys.exit(1)
    except Exception as e:
        print(json.dumps({
            "success": False,
            "error": f"Unexpected error: {str(e)}"
        }))
        sys.exit(1)

if __name__ == '__main__':
    main()
