#!/usr/bin/env python3
"""
Fix ModelShow published results to only include the most recent result.
"""
import json
import os
import shutil
from pathlib import Path
from datetime import datetime

# Paths
workspace = Path("/home/ubuntu/.openclaw/workspace")
old_results_dir = workspace / "modelshow-results"
private_dir = workspace / "modelshow-private"
published_dir = workspace / "modelshow-published"
web_dir = workspace / "rexuvia-site" / "public" / "modelshow-results"

# Ensure directories exist
published_dir.mkdir(exist_ok=True)
web_dir.mkdir(exist_ok=True)

# Find all JSON files in old results directory
json_files = []
if old_results_dir.exists():
    for f in old_results_dir.glob("*.json"):
        try:
            with open(f, 'r') as file:
                data = json.load(file)
                timestamp = data.get('meta', {}).get('timestamp', '')
                if timestamp:
                    json_files.append((f, timestamp, data))
        except:
            continue

# Also check private directory if it exists
if private_dir.exists():
    for f in private_dir.glob("*.json"):
        try:
            with open(f, 'r') as file:
                data = json.load(file)
                timestamp = data.get('meta', {}).get('timestamp', '')
                if timestamp:
                    json_files.append((f, timestamp, data))
        except:
            continue

if not json_files:
    print("No JSON files found!")
    exit(1)

# Find the most recent file
most_recent = max(json_files, key=lambda x: x[1])
most_recent_file, most_recent_timestamp, most_recent_data = most_recent

print(f"Most recent result:")
print(f"  File: {most_recent_file.name}")
print(f"  Timestamp: {most_recent_timestamp}")
print(f"  Prompt: {most_recent_data.get('prompt', '')[:80]}...")

# Clear published directory
for f in published_dir.glob("*"):
    f.unlink()

# Copy most recent result to published directory
# Copy both JSON and MD files
base_name = most_recent_file.stem
json_src = most_recent_file
md_src = most_recent_file.with_suffix('.md')

json_dst = published_dir / most_recent_file.name
shutil.copy2(json_src, json_dst)

if md_src.exists():
    md_dst = published_dir / md_src.name
    shutil.copy2(md_src, md_dst)

print(f"\nCopied to published directory:")
print(f"  {json_dst.name}")
if md_src.exists():
    print(f"  {md_dst.name}")

# Add keywords if not present
if 'meta' not in most_recent_data:
    most_recent_data['meta'] = {}
if 'keywords' not in most_recent_data['meta']:
    # Simple keyword extraction based on prompt
    prompt = most_recent_data.get('prompt', '').lower()
    keywords = []
    if 'prime' in prompt or 'security' in prompt:
        keywords.extend(['mathematics', 'cryptography', 'security'])
    if 'llm' in prompt or 'model' in prompt:
        keywords.extend(['ai', 'llm', 'explanation'])
    if 'chicken' in prompt or 'egg' in prompt:
        keywords.extend(['philosophy', 'science', 'humor'])
    
    if not keywords:
        keywords = ['ai', 'comparison', 'benchmark']
    
    most_recent_data['meta']['keywords'] = keywords
    
    # Update the JSON file
    with open(json_dst, 'w') as f:
        json.dump(most_recent_data, f, indent=2)
    
    print(f"\nAdded keywords: {keywords}")

print("\n✅ Published directory now contains only the most recent result.")