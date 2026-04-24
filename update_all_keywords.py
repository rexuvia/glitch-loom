#!/usr/bin/env python3
"""
Update all published JSON files with meaningful keywords.
"""
import json
from pathlib import Path

published_dir = Path("/home/ubuntu/.openclaw/workspace/modelshow-published")

# Better keywords for each file
keyword_updates = {
    # Prime numbers explanation - technical/security topic
    "in-exactly-3-sentences,-explain-2026-03-02-1227": [
        "mathematics", "cryptography", "internet-security", "prime-numbers", "encryption", "rsa"
    ],
    
    # Chicken/egg question - philosophical/science topic
    "which-came-first-the-chicken-2026-02-28-0220": [
        "philosophy", "science", "humor", "thought-experiment", "evolution", "biology"
    ],
    
    # LLM explanation - AI/education topic
    "please-explain-in-one-concise-2026-02-28-0218": [
        "artificial-intelligence", "llm", "explanation", "education", "technology", "ai-models"
    ]
}

print("Updating keywords in published JSON files...")
print("=" * 50)

for json_file in published_dir.glob("*.json"):
    file_id = json_file.stem
    print(f"\n📄 {file_id}")
    
    try:
        with open(json_file, 'r') as f:
            data = json.load(f)
        
        # Ensure meta exists
        if 'meta' not in data:
            data['meta'] = {}
        
        # Get current keywords
        current = data['meta'].get('keywords', [])
        print(f"  Current keywords: {current}")
        
        # Update with better keywords if we have them
        if file_id in keyword_updates:
            new_keywords = keyword_updates[file_id]
            data['meta']['keywords'] = new_keywords
            print(f"  Updated to: {new_keywords}")
        else:
            print(f"  No update mapping for this file")
        
        # Write back
        with open(json_file, 'w') as f:
            json.dump(data, f, indent=2)
        
        print(f"  ✅ File updated")
        
    except Exception as e:
        print(f"  ❌ Error: {e}")

print("\n" + "=" * 50)
print("✅ All JSON files updated with meaningful keywords!")
print("\nNow the indexer will extract these to the website.")