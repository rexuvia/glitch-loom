#!/bin/bash
jq '.judgeModel = "gemini31or"' ~/.openclaw/skills/modelshow/config.json > temp.json && mv temp.json ~/.openclaw/skills/modelshow/config.json
