import json
import sys

# Read the ASCII art
with open('cat_30x30_perfect.txt', 'r') as f:
    ascii_art = f.read()

# Read the JSON file
with open('modelshow-published/generate-a-30-by-30-2026-03-15-1216.json', 'r') as f:
    data = json.load(f)

# Update the response for the winning model (pro/gemini-2.5-pro)
for i, result in enumerate(data['results']):
    if result['model_alias'] == 'pro':
        # Keep the commentary but append the actual ASCII art
        original_response = result['response']
        new_response = f"{original_response}\n\n**Actual 30x30 ASCII Art:**\n\n```\n{ascii_art}\n```"
        data['results'][i]['response'] = new_response
        print(f"Updated response for {result['model']}")
        break

# Write back
with open('modelshow-published/generate-a-30-by-30-2026-03-15-1216.json', 'w') as f:
    json.dump(data, f, indent=2)

print("JSON updated successfully")