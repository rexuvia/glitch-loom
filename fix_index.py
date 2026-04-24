#!/usr/bin/env python3
"""
Create a clean index.json with only the 3 published results and proper keywords.
"""
import json
from datetime import datetime

# The 3 published results with proper data
published_results = [
    {
        "id": "in-exactly-3-sentences,-explain-2026-03-02-1227",
        "slug": "in-exactly-3-sentences,-explain",
        "timestamp": "2026-03-02T12:27:00Z",
        "prompt": "In exactly 3 sentences, explain why prime numbers are fundamental to internet security and what makes them mathematically special for this purpose.",
        "prompt_preview": "In exactly 3 sentences, explain why prime numbers are fundamental to internet security and what make...",
        "models_queried": [
            "google/gemini-2.5-pro",
            "openrouter/openai/gpt-5",
            "openrouter/deepseek/deepseek-v3.2",
            "openrouter/moonshotai/kimi-k2.5"
        ],
        "models_queried_count": 4,
        "judge_model": "deepseek/deepseek-reasoner",
        "winner_model": "google/gemini-2.5-pro",
        "winner_score": 9.0,
        "total_duration_ms": 18070,
        "json_url": "/modelshow-results/in-exactly-3-sentences,-explain-2026-03-02-1227.json",
        "md_url": "/modelshow-results/in-exactly-3-sentences,-explain-2026-03-02-1227.md",
        "tags": [
            "mathematics",
            "cryptography",
            "internet-security",
            "prime-numbers",
            "encryption"
        ]
    },
    {
        "id": "which-came-first-the-chicken-2026-02-28-0220",
        "slug": "which-came-first-the-chicken",
        "timestamp": "2026-02-28T02:20:00Z",
        "prompt": "which came first the chicken or the egg?",
        "prompt_preview": "which came first the chicken or the egg?",
        "models_queried": [
            "anthropic/claude-opus-4-6",
            "google/gemini-2.5-pro",
            "openai/gpt-5",
            "x-ai/grok-4"
        ],
        "models_queried_count": 4,
        "judge_model": "openrouter/google/gemini-3.1-pro-preview",
        "winner_model": "anthropic/claude-opus-4-6",
        "winner_score": 9.5,
        "total_duration_ms": 28000,
        "json_url": "/modelshow-results/which-came-first-the-chicken-2026-02-28-0220.json",
        "md_url": "/modelshow-results/which-came-first-the-chicken-2026-02-28-0220.md",
        "tags": [
            "philosophy",
            "science",
            "humor",
            "thought-experiment",
            "evolution",
            "biology"
        ]
    },
    {
        "id": "please-explain-in-one-concise-2026-02-28-0218",
        "slug": "please-explain-in-one-concise",
        "timestamp": "2026-02-28T02:18:00Z",
        "prompt": "please explain in one concise paragraph how LLMs work",
        "prompt_preview": "please explain in one concise paragraph how LLMs work",
        "models_queried": [
            "anthropic/claude-opus-4-6",
            "google/gemini-2.5-pro",
            "openrouter/deepseek/deepseek-v3.2",
            "openrouter/x-ai/grok-4"
        ],
        "models_queried_count": 4,
        "judge_model": "openrouter/google/gemini-3.1-pro-preview",
        "winner_model": "anthropic/claude-opus-4-6",
        "winner_score": 9.5,
        "total_duration_ms": 22000,
        "json_url": "/modelshow-results/please-explain-in-one-concise-2026-02-28-0218.json",
        "md_url": "/modelshow-results/please-explain-in-one-concise-2026-02-28-0218.md",
        "tags": [
            "artificial-intelligence",
            "llm",
            "explanation",
            "education",
            "technology",
            "ai-models"
        ]
    }
]

# Create the index
index = {
    "version": "1.0",
    "last_updated": datetime.utcnow().isoformat() + "Z",
    "count": len(published_results),
    "results": published_results
}

# Write to file
output_path = "/home/ubuntu/.openclaw/workspace/rexuvia-site/public/modelshow-results/index.json"
with open(output_path, 'w') as f:
    json.dump(index, f, indent=2)

print(f"✅ Created clean index.json with {len(published_results)} published results")
print(f"✅ All results have judge_model fields")
print(f"✅ All results have proper keyword tags")