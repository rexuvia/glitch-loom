import json

games_path = "/home/ubuntu/.openclaw/workspace/rexuvia-site/public/game_list.json"

with open(games_path, 'r') as f:
    games = json.load(f)

# Remove if exists
games = [g for g in games if g.get("title") != "Glitch Loom"]

# Add to front
glitch_loom = {
    "title": "Glitch Loom",
    "url": "/games/glitch-loom.html",
    "github_url": "https://github.com/rexuvia/glitch-loom",
    "date": "2026-03-04",
    "last_updated": "2026-03-04"
}
games.insert(0, glitch_loom)

with open(games_path, 'w') as f:
    json.dump(games, f, indent=2)
print("Added Glitch Loom")
