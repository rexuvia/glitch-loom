#!/usr/bin/env python3
"""
Update game_list.json to include the latest game "Glitch Loom"
"""
import json
import os
from pathlib import Path

games_dir = Path("/home/ubuntu/.openclaw/workspace/rexuvia-site/public/games")
game_list_path = Path("/home/ubuntu/.openclaw/workspace/rexuvia-site/public/game_list.json")

# Read existing game list
with open(game_list_path, 'r') as f:
    game_list = json.load(f)

# Check for Glitch Loom
glitch_loom_exists = any(game["title"] == "Glitch Loom" for game in game_list)

if not glitch_loom_exists:
    # Add Glitch Loom to the beginning (most recent first)
    glitch_loom = {
        "title": "Glitch Loom",
        "url": "/games/glitch-loom.html",
        "github_url": "https://github.com/rexuvia/glitch-loom",
        "date": "2026-03-04",
        "last_updated": "2026-03-04"
    }
    
    # Check if the file actually exists
    if (games_dir / "glitch-loom.html").exists():
        game_list.insert(0, glitch_loom)
        print("✅ Added Glitch Loom to game_list.json")
    else:
        # Check for any 2026-03-04 game
        for html_file in games_dir.glob("*.html"):
            if "2026-03-04" in html_file.name:
                game_name = html_file.stem.replace("-", " ").title()
                glitch_loom["title"] = game_name
                glitch_loom["url"] = f"/games/{html_file.name}"
                game_list.insert(0, glitch_loom)
                print(f"✅ Added {game_name} (2026-03-04) to game_list.json")
                break
else:
    print("✅ Glitch Loom already in game_list.json")

# Write updated list
with open(game_list_path, 'w') as f:
    json.dump(game_list, f, indent=2)

print(f"✅ Updated game_list.json with {len(game_list)} games")