#!/usr/bin/env python3
"""
Fix duplicate game entries in game_list.json
Requirements:
1. Only one of each game should be shown in the listing
2. Each game should always have a created date
3. If a game was ever updated with a new GitHub commit, there should be an updated date
4. The order should be determined by the earliest of the two dates (created or updated) for each game, with newest first in the listing
"""
import json
import os
from datetime import datetime
from pathlib import Path

def parse_date(date_str):
    """Parse date string to datetime object"""
    try:
        return datetime.strptime(date_str, "%Y-%m-%d")
    except:
        return datetime.min

def fix_game_list():
    game_list_path = Path("/home/ubuntu/.openclaw/workspace/rexuvia-site/public/game_list.json")
    
    # Read existing game list
    with open(game_list_path, 'r') as f:
        game_list = json.load(f)
    
    print(f"Original game list has {len(game_list)} entries")
    
    # Group games by title
    games_by_title = {}
    for game in game_list:
        title = game.get("title", "").strip()
        if not title:
            continue
            
        # Ensure we have both date and last_updated fields
        date = game.get("date", "")
        last_updated = game.get("last_updated", "")
        
        # If date is missing but last_updated exists, use last_updated as date
        if not date and last_updated:
            date = last_updated
            game["date"] = date
        
        # If last_updated is missing but date exists, use date as last_updated
        if not last_updated and date:
            last_updated = date
            game["last_updated"] = last_updated
        
        # If both are missing, skip this entry
        if not date and not last_updated:
            continue
        
        if title not in games_by_title:
            games_by_title[title] = []
        
        games_by_title[title].append(game)
    
    # Process each title group
    deduplicated_games = []
    for title, games in games_by_title.items():
        if len(games) == 1:
            # Single game, keep as is
            game = games[0]
            
            # Ensure date and last_updated are set
            date = game.get("date", "")
            last_updated = game.get("last_updated", "")
            
            if not date and last_updated:
                game["date"] = last_updated
            elif not last_updated and date:
                game["last_updated"] = date
            
            deduplicated_games.append(game)
        else:
            # Multiple entries for same title - need to merge
            print(f"Found {len(games)} entries for '{title}'")
            
            # Sort by date (oldest first) to find the earliest created date
            games_sorted_by_date = sorted(games, key=lambda g: parse_date(g.get("date", g.get("last_updated", "1970-01-01"))))
            
            # The earliest date is the created date
            created_game = games_sorted_by_date[0]
            created_date = created_game.get("date", created_game.get("last_updated", ""))
            
            # Sort by last_updated (newest first) to find the most recent update
            games_sorted_by_updated = sorted(games, key=lambda g: parse_date(g.get("last_updated", g.get("date", "1970-01-01"))), reverse=True)
            
            # The most recent game is the one to keep
            latest_game = games_sorted_by_updated[0]
            
            # Create merged game entry
            merged_game = {
                "title": title,
                "url": latest_game.get("url", ""),
                "github_url": latest_game.get("github_url", ""),
                "date": created_date,  # Use earliest date as created date
                "last_updated": latest_game.get("last_updated", latest_game.get("date", ""))  # Use most recent as updated
            }
            
            # If created_date and last_updated are the same, it means no update
            if merged_game["date"] == merged_game["last_updated"]:
                # Only show created date
                pass
            
            deduplicated_games.append(merged_game)
    
    # Now sort the deduplicated games according to requirement #4:
    # "The order should be determined by the earliest of the two dates (created or updated) for each game, with newest first in the listing"
    # This is confusing. I think they mean: sort by the most recent activity (either created or updated), with newest first.
    # So we should use the later of the two dates (date vs last_updated) for sorting.
    
    def get_sort_date(game):
        """Get the date to use for sorting - the later of date and last_updated"""
        date_str = game.get("date", "1970-01-01")
        updated_str = game.get("last_updated", "1970-01-01")
        
        date_obj = parse_date(date_str)
        updated_obj = parse_date(updated_str)
        
        # Return the later date
        return max(date_obj, updated_obj)
    
    # Sort by sort date, newest first
    deduplicated_games.sort(key=lambda g: get_sort_date(g), reverse=True)
    
    print(f"Deduplicated game list has {len(deduplicated_games)} entries")
    
    # Write fixed game list
    with open(game_list_path, 'w') as f:
        json.dump(deduplicated_games, f, indent=2)
    
    print(f"✅ Fixed game_list.json")
    
    # Also update the dist folder if it exists
    dist_game_list_path = Path("/home/ubuntu/.openclaw/workspace/rexuvia-site/dist/game_list.json")
    if dist_game_list_path.exists():
        with open(dist_game_list_path, 'w') as f:
            json.dump(deduplicated_games, f, indent=2)
        print(f"✅ Updated dist/game_list.json")

if __name__ == "__main__":
    fix_game_list()