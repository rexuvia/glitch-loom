import json
import base64
import subprocess
import os

responses_dir = os.path.expanduser("~/.openclaw/workspace/modelshow-private/responses")
models = ["pro", "deepseek", "grok", "kimi", "sonnet46", "qwenmax", "mistral"]
responses = {}

for model in models:
    file_path = os.path.join(responses_dir, f"{model}.json")
    if os.path.exists(file_path):
        with open(file_path, "r") as f:
            responses[model] = json.load(f)

payload = {
    "action": "anonymize",
    "responses": responses,
    "label_style": "alphabetic",
    "shuffle": True
}

# we pipe this into judge_pipeline.py
cmd = ["python3", os.path.expanduser("~/.openclaw/skills/modelshow/judge_pipeline.py")]
process = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
stdout, stderr = process.communicate(input=json.dumps(payload).encode())

if stderr:
    print(stderr.decode())
print(stdout.decode())
