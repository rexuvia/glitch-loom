#!/bin/bash
export GH_TOKEN=$(grep -A2 "rexuvia:" ~/.config/gh/hosts.yml | grep oauth_token | cut -d':' -f2 | xargs)
gh issue close 2 --repo rexuvia/word-bird -c "Fixed"
