#!/usr/bin/env python3
"""
Update ModelShow results index for web display.

Usage:
  # Full rebuild
  python update_modelshow_index.py --source ~/.openclaw/workspace/modelshow-results \
                                   --web ~/.openclaw/workspace/rexuvia-site/public/modelshow-results \
                                   --full

  # Incremental update (after new result)
  python update_modelshow_index.py --source ~/.openclaw/workspace/modelshow-results \
                                   --web ~/.openclaw/workspace/rexuvia-site/public/modelshow-results \
                                   --incremental /path/to/new.json
"""

import argparse
import json
import os
import shutil
import sys
from pathlib import Path
from datetime import datetime, timedelta
from typing import Dict, List, Any, Optional
import hashlib

def parse_args():
    parser = argparse.ArgumentParser(description='Update ModelShow results index')
    parser.add_argument('--source', required=True,
                        help='Source directory containing original JSON files')
    parser.add_argument('--web', required=True,
                        help='Web directory (public) where JSON files and index will be placed')
    parser.add_argument('--full', action='store_true',
                        help='Perform full rebuild of index from all JSON files')
    parser.add_argument('--incremental', metavar='JSON_FILE',
                        help='Path to new JSON file to add to index')
    parser.add_argument('--retention-days', type=int, default=30,
                        help='Remove files older than N days (0 = keep forever)')
    parser.add_argument('--max-entries', type=int, default=1000,
                        help='Maximum number of entries to keep in index (oldest removed first)')
    parser.add_argument('--verbose', action='store_true',
                        help='Print verbose output')
    return parser.parse_args()

def load_json(filepath: Path) -> Optional[Dict]:
    """Load JSON file, return None on error."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            return json.load(f)
    except (json.JSONDecodeError, OSError) as e:
        print(f"Warning: Could not load {filepath}: {e}", file=sys.stderr)
        return None

def extract_metadata(data: Dict, filepath: Path) -> Dict[str, Any]:
    """Extract metadata for index entry."""
    meta = data.get('meta', {})
    results = data.get('results', [])
    
    # Determine winner (rank 1)
    winner = None
    winner_score = None
    if results:
        sorted_results = sorted(results, key=lambda x: x.get('rank', 999))
        winner = sorted_results[0].get('model', 'unknown')
        winner_score = sorted_results[0].get('score', 0)
    
    # Generate slug from filename (strip timestamp)
    stem = filepath.stem
    # Pattern: {slug}-{YYYY-MM-DD-HHMM}
    parts = stem.rsplit('-', 4)
    if len(parts) >= 5:
        slug = '-'.join(parts[:-4])
    else:
        slug = stem
    
    # Truncate prompt preview
    prompt = meta.get('prompt', '')
    prompt_preview = prompt[:100] + ('...' if len(prompt) > 100 else '')
    
    return {
        'id': stem,
        'slug': slug,
        'timestamp': meta.get('timestamp', ''),
        'prompt': prompt,
        'prompt_preview': prompt_preview,
        'models_queried': meta.get('models_queried', []),
        'models_queried_count': len(meta.get('models_queried', [])),
        'judge_model': meta.get('judge_model', ''),
        'winner_model': winner,
        'winner_score': winner_score,
        'total_duration_ms': data.get('metadata', {}).get('total_duration_ms', 0),
        'json_url': f"/modelshow-results/{filepath.name}",
        'md_url': f"/modelshow-results/{filepath.stem}.md",
        'tags': []
    }

def copy_if_needed(src: Path, dst: Path) -> bool:
    """Copy file if destination doesn't exist or differs."""
    if not dst.exists():
        shutil.copy2(src, dst)
        return True
    # Compare file sizes and modification times as a quick check
    if src.stat().st_size != dst.stat().st_size or \
       src.stat().st_mtime > dst.stat().st_mtime:
        shutil.copy2(src, dst)
        return True
    return False

def prune_old_files(web_dir: Path, retention_days: int, max_entries: int,
                    index_entries: List[Dict]) -> List[Dict]:
    """Remove JSON/MD files older than retention_days and limit entries."""
    if retention_days <= 0 and max_entries <= 0:
        return index_entries
    
    now = datetime.now()
    cutoff = now - timedelta(days=retention_days) if retention_days > 0 else None
    
    # Build mapping from id to timestamp
    id_to_timestamp = {e['id']: e['timestamp'] for e in index_entries}
    
    # Scan web directory for files not in index
    for filepath in web_dir.glob('*.json'):
        if filepath.name == 'index.json':
            continue
        file_id = filepath.stem
        if file_id not in id_to_timestamp:
            # Orphaned file (not in index) - delete
            if args.verbose:
                print(f"Removing orphaned file: {filepath.name}")
            filepath.unlink(missing_ok=True)
            # Also delete corresponding .md file
            md_file = web_dir / f"{file_id}.md"
            if md_file.exists():
                md_file.unlink(missing_ok=True)
    
    # Sort entries by timestamp descending (newest first)
    sorted_entries = sorted(index_entries,
                           key=lambda x: x.get('timestamp', ''),
                           reverse=True)
    
    # Apply max entries limit
    if max_entries > 0 and len(sorted_entries) > max_entries:
        removed = sorted_entries[max_entries:]
        kept = sorted_entries[:max_entries]
        removed_ids = {e['id'] for e in removed}
        
        # Remove files for removed entries
        for entry in removed:
            json_file = web_dir / f"{entry['id']}.json"
            md_file = web_dir / f"{entry['id']}.md"
            if json_file.exists():
                if args.verbose:
                    print(f"Removing due to max entries: {json_file.name}")
                json_file.unlink(missing_ok=True)
            if md_file.exists():
                md_file.unlink(missing_ok=True)
        
        index_entries = kept
    
    # Apply retention days cutoff
    if cutoff:
        kept = []
        for entry in index_entries:
            try:
                ts = datetime.fromisoformat(entry['timestamp'].replace('Z', '+00:00'))
                if ts >= cutoff:
                    kept.append(entry)
                else:
                    # Remove old file
                    json_file = web_dir / f"{entry['id']}.json"
                    md_file = web_dir / f"{entry['id']}.md"
                    if json_file.exists():
                        if args.verbose:
                            print(f"Removing old file ({retention_days} days): {json_file.name}")
                        json_file.unlink(missing_ok=True)
                    if md_file.exists():
                        md_file.unlink(missing_ok=True)
            except ValueError:
                kept.append(entry)  # Keep if timestamp parsing fails
        index_entries = kept
    
    return index_entries

def main():
    args = parse_args()
    source_dir = Path(args.source).expanduser()
    web_dir = Path(args.web).expanduser()
    
    if not source_dir.exists():
        print(f"Error: Source directory does not exist: {source_dir}", file=sys.stderr)
        sys.exit(1)
    
    web_dir.mkdir(parents=True, exist_ok=True)
    
    index_file = web_dir / 'index.json'
    existing_index = []
    
    # Load existing index if present
    if index_file.exists():
        try:
            with open(index_file, 'r', encoding='utf-8') as f:
                existing_data = json.load(f)
                existing_index = existing_data.get('results', [])
        except (json.JSONDecodeError, OSError) as e:
            print(f"Warning: Could not load existing index: {e}", file=sys.stderr)
            existing_index = []
    
    if args.incremental:
        # Add single new file
        new_file = Path(args.incremental).expanduser()
        if not new_file.exists():
            print(f"Error: New JSON file does not exist: {new_file}", file=sys.stderr)
            sys.exit(1)
        
        data = load_json(new_file)
        if data is None:
            sys.exit(1)
        
        metadata = extract_metadata(data, new_file)
        
        # Copy JSON file to web directory
        dst_json = web_dir / new_file.name
        copy_if_needed(new_file, dst_json)
        
        # Copy corresponding MD file if exists
        src_md = new_file.with_suffix('.md')
        dst_md = web_dir / src_md.name
        if src_md.exists():
            copy_if_needed(src_md, dst_md)
        
        # Update index: remove existing entry with same id, prepend new
        new_id = metadata['id']
        existing_index = [e for e in existing_index if e['id'] != new_id]
        existing_index.insert(0, metadata)  # newest first
        
        if args.verbose:
            print(f"Added {new_id} to index")
            
    elif args.full:
        # Full rebuild: scan all JSON files in source directory
        existing_index = []
        json_files = list(source_dir.glob('*.json'))
        
        for json_path in json_files:
            if json_path.name == 'index.json':
                continue
            data = load_json(json_path)
            if data is None:
                continue
            
            metadata = extract_metadata(data, json_path)
            existing_index.append(metadata)
            
            # Copy JSON file
            dst_json = web_dir / json_path.name
            copy_if_needed(json_path, dst_json)
            
            # Copy MD file
            md_path = json_path.with_suffix('.md')
            dst_md = web_dir / md_path.name
            if md_path.exists():
                copy_if_needed(md_path, dst_md)
        
        if args.verbose:
            print(f"Processed {len(json_files)} JSON files")
    
    else:
        print("Error: Must specify either --full or --incremental", file=sys.stderr)
        sys.exit(1)
    
    # Sort by timestamp descending (newest first)
    existing_index.sort(key=lambda x: x.get('timestamp', ''), reverse=True)
    
    # Prune old files if retention or max entries specified
    existing_index = prune_old_files(web_dir, args.retention_days, args.max_entries, existing_index)
    
    # Write index.json atomically
    index_data = {
        'version': '1.0',
        'last_updated': datetime.now().isoformat() + 'Z',
        'count': len(existing_index),
        'results': existing_index
    }
    
    tmp_index = web_dir / 'index.json.tmp'
    try:
        with open(tmp_index, 'w', encoding='utf-8') as f:
            json.dump(index_data, f, indent=2, ensure_ascii=False)
        tmp_index.replace(index_file)
        if args.verbose:
            print(f"Updated index with {len(existing_index)} entries at {index_file}")
    except OSError as e:
        print(f"Error writing index: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    main()