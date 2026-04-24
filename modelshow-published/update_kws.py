import json
import sys

filepath = sys.argv[1]
with open(filepath, 'r') as f:
    data = json.load(f)

data['meta']['keywords'] = ["trick-question", "hallucination", "general knowledge", "history", "literature"]

with open(filepath, 'w') as f:
    json.dump(data, f, indent=2)
