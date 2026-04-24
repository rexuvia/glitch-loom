#!/usr/bin/env python3
"""
Output ranking system for phenosemantic-manager.
"""

import json
import sqlite3
from pathlib import Path
from datetime import datetime
import statistics
from typing import List, Dict, Any

BASE_DIR = Path(__file__).parent.parent
DB_PATH = BASE_DIR / "db" / "pheno-manager.db"
RAW_OUTPUTS_DIR = BASE_DIR / "outputs" / "raw"
RANKED_OUTPUTS_DIR = BASE_DIR / "outputs" / "ranked"

def load_outputs(job_id: str) -> List[Dict[str, Any]]:
    """Load outputs from a job."""
    # First try to find by job ID
    output_files = list(RAW_OUTPUTS_DIR.glob(f"{job_id}*.jsonl"))
    
    # If not found, try to find latest
    if not output_files and job_id == "latest":
        output_files = sorted(RAW_OUTPUTS_DIR.glob("*.jsonl"), reverse=True)
        if output_files:
            output_files = [output_files[0]]
    
    if not output_files:
        raise FileNotFoundError(f"No output files found for job {job_id}")
    
    outputs = []
    for output_file in output_files:
        with open(output_file, "r") as f:
            for line in f:
                try:
                    data = json.loads(line.strip())
                    outputs.append(data)
                except json.JSONDecodeError:
                    continue
    
    return outputs

def calculate_simple_metrics(outputs: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Calculate simple quality metrics for outputs."""
    ranked = []
    
    for i, output in enumerate(outputs):
        text = output.get("text", "")
        
        # Basic metrics
        char_count = len(text)
        word_count = len(text.split())
        sentence_count = text.count('.') + text.count('!') + text.count('?')
        
        # Quality heuristics
        score = 0
        
        # Length score (optimal: 100-500 chars)
        if 100 <= char_count <= 500:
            score += 3
        elif 50 <= char_count < 100 or 500 < char_count <= 1000:
            score += 1
        
        # Structure score (has paragraphs/sentences)
        if sentence_count >= 2:
            score += 2
        if '\n' in text:  # Has paragraphs
            score += 1
        
        # Complexity score (varied vocabulary)
        words = text.lower().split()
        unique_words = set(words)
        if len(words) > 0:
            uniqueness = len(unique_words) / len(words)
            if uniqueness > 0.7:
                score += 2
            elif uniqueness > 0.5:
                score += 1
        
        # Add to ranked list
        ranked_output = output.copy()
        ranked_output.update({
            "rank_metrics": {
                "char_count": char_count,
                "word_count": word_count,
                "sentence_count": sentence_count,
                "uniqueness_ratio": len(unique_words) / max(len(words), 1),
                "simple_score": score
            },
            "rank": 0,  # Will be set after sorting
            "rank_timestamp": datetime.now().isoformat()
        })
        ranked.append(ranked_output)
    
    # Sort by score
    ranked.sort(key=lambda x: x["rank_metrics"]["simple_score"], reverse=True)
    
    # Add rank numbers
    for i, output in enumerate(ranked):
        output["rank"] = i + 1
    
    return ranked

def save_ranked_outputs(job_id: str, ranked_outputs: List[Dict[str, Any]]):
    """Save ranked outputs to file."""
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    output_file = RANKED_OUTPUTS_DIR / f"{job_id}-ranked-{timestamp}.jsonl"
    
    RANKED_OUTPUTS_DIR.mkdir(parents=True, exist_ok=True)
    
    with open(output_file, "w") as f:
        for output in ranked_outputs:
            f.write(json.dumps(output) + "\n")
    
    return output_file

def update_job_ranking(job_id: str, ranked_file: Path, top_n: int = 10):
    """Update job record with ranking information."""
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    # Get top outputs
    top_outputs = []
    with open(ranked_file, "r") as f:
        for i, line in enumerate(f):
            if i >= top_n:
                break
            try:
                data = json.loads(line.strip())
                top_outputs.append(data.get("text", "")[:100] + "...")
            except json.JSONDecodeError:
                continue
    
    cursor.execute('''
    UPDATE jobs 
    SET ranked_file = ?, ranking_completed = ?
    WHERE id = ?
    ''', (str(ranked_file), datetime.now().isoformat(), job_id))
    
    conn.commit()
    conn.close()
    
    return top_outputs

def rank_command(args):
    """Rank outputs from a mining job."""
    try:
        print(f"Ranking outputs for job: {args.job}")
        
        # Load outputs
        outputs = load_outputs(args.job)
        print(f"  Loaded {len(outputs)} outputs")
        
        if not outputs:
            print("  No outputs to rank")
            return
        
        # Calculate metrics and rank
        print("  Calculating metrics...")
        ranked_outputs = calculate_simple_metrics(outputs)
        
        # Save ranked outputs
        ranked_file = save_ranked_outputs(args.job, ranked_outputs)
        print(f"  Saved ranked outputs to: {ranked_file}")
        
        # Update job record
        top_outputs = update_job_ranking(args.job, ranked_file, args.top)
        
        # Show top results
        print(f"\nTop {min(args.top, len(ranked_outputs))} outputs:")
        print("-" * 80)
        
        for i, output in enumerate(ranked_outputs[:args.top]):
            text = output.get("text", "")
            score = output["rank_metrics"]["simple_score"]
            
            # Truncate for display
            if len(text) > 100:
                text = text[:97] + "..."
            
            print(f"{i+1:2d}. [Score: {score:2d}] {text}")
        
        print(f"\nRanking complete. Full results in: {ranked_file}")
        
    except Exception as e:
        print(f"Error ranking outputs: {e}")
        raise

if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description="Rank outputs from a mining job")
    parser.add_argument("--job", required=True, help="Job ID or 'latest'")
    parser.add_argument("--top", type=int, default=10, help="Show top N results")
    
    args = parser.parse_args()
    rank_command(args)