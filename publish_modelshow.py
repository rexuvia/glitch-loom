#!/usr/bin/env python3
import json
import shutil
import sys
from pathlib import Path

def publish_modelshow_result(result_id):
    """Publish a ModelShow result following MSPP workflow."""
    
    # Paths
    private_dir = Path.home() / ".openclaw" / "workspace" / "modelshow-private"
    published_dir = Path.home() / ".openclaw" / "workspace" / "modelshow-published"
    site_dir = Path.home() / ".openclaw" / "workspace" / "rexuvia-site"
    
    # Files
    json_file = private_dir / f"{result_id}.json"
    md_file = private_dir / f"{result_id}.md"
    
    if not json_file.exists():
        print(f"Error: JSON file not found: {json_file}")
        return False
    
    # Read JSON
    with open(json_file, 'r') as f:
        data = json.load(f)
    
    # Generate keywords (simplified - in real MSPP this would use LLM)
    prompt = data['meta']['prompt']
    keywords = generate_keywords(prompt)
    
    # Inject keywords into meta
    if 'keywords' not in data['meta']:
        data['meta']['keywords'] = keywords
    
    # Write to published directory
    published_dir.mkdir(exist_ok=True)
    
    published_json = published_dir / f"{result_id}.json"
    with open(published_json, 'w') as f:
        json.dump(data, f, indent=2)
    
    # Copy markdown file
    if md_file.exists():
        shutil.copy2(md_file, published_dir / f"{result_id}.md")
    
    print(f"Published: {result_id}")
    print(f"Keywords: {', '.join(keywords)}")
    
    return True

def generate_keywords(prompt):
    """Generate keywords from prompt (simplified version)."""
    prompt_lower = prompt.lower()
    keywords = []
    
    # Basic keyword extraction
    if "consciousness" in prompt_lower or "memory" in prompt_lower:
        keywords.append("consciousness ethics")
    if "experience" in prompt_lower:
        keywords.append("experiential ethics")
    if "ordinary" in prompt_lower and "extraordinary" in prompt_lower:
        keywords.append("quality vs quantity")
    if "relationship" in prompt_lower:
        keywords.append("relational ethics")
    if "five" in prompt_lower and "one" in prompt_lower:
        keywords.append("ethical tradeoffs")
    
    # Ensure we have at least some keywords
    if not keywords:
        keywords = ["ai ethics", "philosophical dilemma", "value judgment"]
    
    return keywords[:4]  # Limit to 4 keywords

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python publish_modelshow.py <result_id>")
        sys.exit(1)
    
    result_id = sys.argv[1]
    if publish_modelshow_result(result_id):
        print("Successfully published result")
    else:
        print("Failed to publish result")
        sys.exit(1)