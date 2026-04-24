import json
import sys

with open(sys.argv[1], 'r') as f:
    data = json.load(f)

# Hardcoded keywords based on the prompt content
data['meta']['keywords'] = ["shakespeare", "history-plays", "literature", "trick-question"]

with open(sys.argv[1], 'w') as f:
    json.dump(data, f, indent=2)
