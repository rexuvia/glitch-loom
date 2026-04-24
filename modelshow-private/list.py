import os, json, glob

try:
    private_dir = os.path.expanduser("~/.openclaw/workspace/modelshow-private")
    published_dir = os.path.expanduser("~/.openclaw/workspace/modelshow-published")

    private_files = [os.path.basename(f) for f in glob.glob(os.path.join(private_dir, "*.json"))]
    if not os.path.exists(published_dir):
        os.makedirs(published_dir)
    published_files = [os.path.basename(f) for f in glob.glob(os.path.join(published_dir, "*.json"))]

    unpublished = [f for f in private_files if f not in published_files and f != "anonymized.json"]

    print(f"**Found {len(unpublished)} unpublished results:**")
    for i, f in enumerate(sorted(unpublished)):
        with open(os.path.join(private_dir, f), "r") as file:
            data = json.load(file)
            prompt = data.get("meta", {}).get("prompt", "")
            if not prompt: prompt = data.get("prompt", "[no prompt found]")
            clean_prompt = prompt.replace("\n", " ").strip()
            snippet = clean_prompt[:80] + "..." if len(clean_prompt) > 80 else clean_prompt
            print(f"- `{f[:-5]}`\n  Prompt: \"{snippet}\"")
except Exception as e:
    print(f"Error: {e}")
