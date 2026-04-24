#!/usr/bin/env python3
"""
Update published Modelshow results to only include the most recent one.
"""
import json
import os
import shutil
from pathlib import Path
from datetime import datetime

# Paths
workspace = Path("/home/ubuntu/.openclaw/workspace")

# Find all JSON files in the workspace
all_json_files = []
for root, dirs, files in os.walk(workspace):
    for file in files:
        if file.endswith('.json') and 'modelshow' in root.lower():
            full_path = Path(root) / file
            try:
                with open(full_path, 'r') as f:
                    data = json.load(f)
                    timestamp = data.get('meta', {}).get('timestamp', '')
                    if timestamp:
                        all_json_files.append((full_path, timestamp, data))
            except:
                continue

if not all_json_files:
    print("No Modelshow JSON files found!")
    exit(1)

# Find the most recent file
most_recent = max(all_json_files, key=lambda x: x[1])
most_recent_file, most_recent_timestamp, most_recent_data = most_recent

print(f"Most recent Modelshow result:")
print(f"  File: {most_recent_file}")
print(f"  Timestamp: {most_recent_timestamp}")
print(f"  Prompt: {most_recent_data.get('prompt', '')[:80]}...")

# Create published directory
published_dir = workspace / "modelshow-published"
published_dir.mkdir(exist_ok=True)

# Clear published directory
for f in published_dir.glob("*"):
    f.unlink()

# Copy most recent result to published directory
json_dst = published_dir / most_recent_file.name
shutil.copy2(most_recent_file, json_dst)

# Also copy MD file if it exists
md_src = most_recent_file.with_suffix('.md')
if md_src.exists():
    md_dst = published_dir / md_src.name
    shutil.copy2(md_src, md_dst)

print(f"\n✅ Published directory now contains only the most recent result:")
print(f"  {json_dst.name}")
if md_src.exists():
    print(f"  {md_dst.name}")

# Now update the web index
print("\nUpdating web index...")
web_dir = workspace / "rexuvia-site" / "public" / "modelshow-results"

# Run the indexer
import subprocess
result = subprocess.run([
    "python3", "/home/ubuntu/.openclaw/skills/modelshow/update_modelshow_index.py",
    "--source", str(published_dir),
    "--web", str(web_dir),
    "--full", "--retention-days", "0"
], capture_output=True, text=True)

if result.returncode == 0:
    print("✅ Web index updated successfully")
else:
    print(f"❌ Error updating web index: {result.stderr}")

# Check the new index
index_file = web_dir / "index.json"
if index_file.exists():
    with open(index_file, 'r') as f:
        index_data = json.load(f)
    print(f"\n📊 New index has {index_data.get('count', 0)} result(s)")
    for result in index_data.get('results', []):
        print(f"  - {result.get('id')} ({result.get('timestamp')})")