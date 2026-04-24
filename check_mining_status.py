#!/usr/bin/env python3
"""
Check mining status without needing exec approval
"""

import os
import json
from pathlib import Path

def check_outputs():
    """Check what outputs exist"""
    output_dir = Path.home() / "pheno-outputs"
    print(f"Checking {output_dir}")
    
    if not output_dir.exists():
        print("No pheno-outputs directory found")
        return
    
    for root, dirs, files in os.walk(output_dir):
        for file in files:
            if file.endswith('.jsonl'):
                path = Path(root) / file
                print(f"\nFound: {path}")
                try:
                    with open(path, 'r') as f:
                        lines = f.readlines()
                        print(f"  Lines: {len(lines)}")
                        if lines:
                            # Show first line preview
                            data = json.loads(lines[0])
                            print(f"  First prompt: {data.get('output', '')[:100]}...")
                except Exception as e:
                    print(f"  Error reading: {e}")

def check_lexasomes():
    """Check lexasome files"""
    pheno_dir = Path("/home/ubuntu/.openclaw/workspace/phenosemantic-workspace/phenosemantic-py")
    lexasomes_dir = pheno_dir / "lexasomes"
    
    print(f"\nChecking {lexasomes_dir}")
    
    if not lexasomes_dir.exists():
        print("Lexasomes directory not found")
        return
    
    # List modelshow files
    for item in lexasomes_dir.iterdir():
        if 'modelshow' in str(item.name):
            print(f"  {item.name} ({'dir' if item.is_dir() else 'file'})")
            
            if item.is_dir():
                for subitem in item.iterdir():
                    print(f"    {subitem.name}")

if __name__ == "__main__":
    print("=== Mining Status Check ===")
    check_outputs()
    check_lexasomes()