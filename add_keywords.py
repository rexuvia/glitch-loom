#!/usr/bin/env python3
"""
Add keywords to published ModelShow JSON files that are missing them.
"""
import json
import os
from pathlib import Path

published_dir = Path("/home/ubuntu/.openclaw/workspace/modelshow-published")

# Keywords for each file based on prompt content
keyword_map = {
    "in-exactly-3-sentences,-explain-2026-03-02-1227": [
        "mathematics", "cryptography", "security", "prime-numbers", "encryption"
    ],
    "which-came-first-the-chicken-2026-02-28-0220": [
        "philosophy", "science", "humor", "thought-experiment", "chicken-egg"
    ],
    "please-explain-in-one-concise-2026-02-28-0218": [
        "ai", "llm", "explanation", "education", "technology"
    ]
}

for json_file in published_dir.glob("*.json"):
    file_id = json_file.stem
    print(f"Processing: {file_id}")
    
    try:
        with open(json_file, 'r') as f:
            data = json.load(f)
        
        # Check if keywords already exist
        if 'meta' not in data:
            data['meta'] = {}
        
        current_keywords = data['meta'].get('keywords', [])
        
        if current_keywords:
            print(f"  Already has keywords: {current_keywords}")
            # Check if we should add more
            if file_id in keyword_map:
                # Add any missing keywords from our map
                existing_set = set(current_keywords)
                suggested = keyword_map[file_id]
                to_add = [k for k in suggested if k not in existing_set]
                
                if to_add:
                    data['meta']['keywords'] = current_keywords + to_add
                    print(f"  Added keywords: {to_add}")
                else:
                    print(f"  All suggested keywords already present")
        else:
            # Add keywords from our map
            if file_id in keyword_map:
                data['meta']['keywords'] = keyword_map[file_id]
                print(f"  Added keywords: {keyword_map[file_id]}")
            else:
                # Extract from prompt
                prompt = data.get('meta', {}).get('prompt', '').lower()
                if 'prime' in prompt or 'security' in prompt:
                    data['meta']['keywords'] = ["mathematics", "cryptography", "security"]
                elif 'llm' in prompt or 'explain' in prompt:
                    data['meta']['keywords'] = ["ai", "llm", "explanation"]
                elif 'chicken' in prompt or 'egg' in prompt:
                    data['meta']['keywords'] = ["philosophy", "science", "humor"]
                else:
                    data['meta']['keywords'] = ["ai", "comparison", "benchmark"]
                print(f"  Extracted keywords: {data['meta']['keywords']}")
        
        # Write back the file
        with open(json_file, 'w') as f:
            json.dump(data, f, indent=2)
        
        print(f"  ✅ Updated {json_file.name}")
        
    except Exception as e:
        print(f"  ❌ Error processing {json_file.name}: {e}")

print("\n✅ All JSON files updated with keywords!")
print("\nNow updating the website index...")