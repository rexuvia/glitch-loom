#!/usr/bin/env python3
"""
Test the funny poem generator
This simulates what phenosemantic would do
"""

import random
import json
import os

# Read lexasomes
def read_lexasome(filename):
    """Read a lexasome file and return list of sequons"""
    full_path = f"/home/ubuntu/.openclaw/workspace/phenosemantic-workspace/phenosemantic-py/lexasomes/{filename}"
    with open(full_path, 'r') as f:
        lines = [line.strip() for line in f if line.strip() and not line.startswith('#')]
    return lines

# Read lexaplast
def read_lexaplast(filename):
    """Read a lexaplast file"""
    full_path = f"/home/ubuntu/.openclaw/workspace/phenosemantic-workspace/phenosemantic-py/lexaplasts/{filename}"
    with open(full_path, 'r') as f:
        return json.load(f)

# Generate test poems
def generate_test_poems():
    print("🎭 FUNNY POEM GENERATOR TEST")
    print("=" * 50)
    
    # Read resources
    subjects = read_lexasome("poem_subjects.txt")
    styles = read_lexasome("poem_styles.txt")
    lexaplast = read_lexaplast("funny_poem_generator.json")
    
    print(f"📚 Loaded {len(subjects)} subjects and {len(styles)} styles")
    print(f"📝 Using lexaplast: {lexaplast['name']}")
    print()
    
    # Generate 3 test combinations
    print("✨ GENERATING 3 FUNNY POEMS:")
    print()
    
    for i in range(3):
        subject = random.choice(subjects)
        style = random.choice(styles)
        
        print(f"Poem {i+1}: {subject} in {style} style")
        print("-" * 40)
        
        # Show what the prompt would be
        prompt_template = lexaplast['prompt']
        prompt = prompt_template.replace("{{codon[0]}}", subject).replace("{{codon[1]}}", style)
        
        print("Prompt that would be sent to DeepSeek:")
        print(f'  "{prompt[:100]}..."')
        print()
        
        # Show example output
        print("Example of what DeepSeek might generate:")
        if style == "haiku":
            print(f"  {subject.title()}\n")
            print("  Five syllables here")
            print("  Seven more in this next line")
            print(f"  {subject.split()[-1]} finds peace")
        elif style == "limerick":
            print(f"  The {subject.split()[-1]} That Could\n")
            print(f"  There once was a {subject}")
            print("  Whose story is quite absurd")
            print("  It did something strange")
            print("  With a notable change")
            print("  And everyone thought it was weird!")
        elif style == "dr. seuss style":
            print(f"  The {subject.title()}\n")
            print(f"  Oh, the {subject} so sly and so sneaky")
            print(f"  Would dance about, feeling quite cheeky")
            print("  With a flip and a flop")
            print("  And a hippity-hop")
            print("  It became something rather unique-y!")
        else:
            print(f"  Ode to a {subject}\n")
            print(f"  You {subject}, so peculiar and odd")
            print("  A creation that surely is flawed")
            print("  Yet in your strange way")
            print("  You brighten the day")
            print("  With a smile and a casual nod")
        
        print()
        print("=" * 50)
        print()
    
    print("🎯 REAL API TEST READY")
    print("=" * 50)
    print("To generate actual poems with DeepSeek API:")
    print()
    print("cd /home/ubuntu/.openclaw/workspace/phenosemantic-workspace/phenosemantic-py")
    print("source .venv/bin/activate")
    print('phenosemantic --mine 5 1000 --lexaplast funny_poem_generator.json --incognito')
    print()
    print("Or use the skill (once installed):")
    print("pheno mine --count 5 --lexaplast funny_poem_generator.json")

if __name__ == "__main__":
    generate_test_poems()