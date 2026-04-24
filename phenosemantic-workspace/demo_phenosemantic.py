#!/usr/bin/env python3
"""
Simple demonstration of phenosemantic concept generation
This shows how lexasomes and lexaplasts work together
"""

import random
import json
import os

# Simulate lexasome reading
def read_lexasome(filename):
    """Read a lexasome file and return list of sequons"""
    with open(filename, 'r') as f:
        lines = [line.strip() for line in f if line.strip() and not line.startswith('#')]
    return lines

# Simulate codon selection
def select_codon(lexasome_files, n=2):
    """Select n random sequons from lexasomes"""
    codon = []
    for lex_file in lexasome_files:
        sequons = read_lexasome(lex_file)
        if sequons:
            codon.append(random.choice(sequons))
    return codon

# Simulate lexaplast application
def apply_lexaplast(codon, lexaplast_file):
    """Apply lexaplast template to codon"""
    with open(lexaplast_file, 'r') as f:
        lexaplast = json.load(f)
    
    prompt_template = lexaplast['prompt']
    
    # Replace placeholders with codon values
    prompt = prompt_template
    for i, value in enumerate(codon):
        prompt = prompt.replace(f'{{{{codon[{i}]}}}}', value)
    
    return {
        'prompt': prompt,
        'model': lexaplast.get('model', 'deepseek-chat'),
        'temperature': lexaplast.get('temperature', 0.7),
        'max_tokens': lexaplast.get('max_tokens', 300)
    }

# Main demonstration
def main():
    print("=" * 60)
    print("PHENOSEMANTIC DEMONSTRATION")
    print("=" * 60)
    
    # Define our lexasomes and lexaplast
    lexasomes = [
        "demo_lexasome_concepts.txt",
        "demo_lexasome_domains.txt"
    ]
    lexaplast = "demo_lexaplast.json"
    
    print("\n📚 LEXASOMES (Input Sources):")
    for i, lex_file in enumerate(lexasomes):
        sequons = read_lexasome(lex_file)
        print(f"  {i+1}. {lex_file}: {len(sequons)} sequons")
        print(f"     Sample: {', '.join(sequons[:3])}...")
    
    print("\n🎨 GENERATING CODON (Random Selection):")
    codon = select_codon(lexasomes, n=2)
    print(f"  Selected: {codon}")
    
    print("\n📝 APPLYING LEXAPLAST (Template):")
    generation_request = apply_lexaplast(codon, lexaplast)
    
    print(f"  Model: {generation_request['model']}")
    print(f"  Temperature: {generation_request['temperature']}")
    print(f"\n  PROMPT TO SEND TO LLM:")
    print("  " + "-" * 40)
    print(f"  {generation_request['prompt']}")
    print("  " + "-" * 40)
    
    print("\n🎯 WHAT WOULD HAPPEN NEXT:")
    print("  1. This prompt would be sent to DeepSeek API")
    print("  2. LLM would generate a creative concept")
    print("  3. Output would be saved for rating/curation")
    print("  4. High-rated outputs inform future lexasomes")
    
    print("\n" + "=" * 60)
    print("EXAMPLE OUTPUTS (Simulated):")
    print("=" * 60)
    
    # Generate a few example combinations
    examples = [
        (["quantum entanglement", "game mechanics"], 
         "**Quantum Entanglement Game**: Players control paired particles where actions on one instantly affect the other, creating unique cooperative puzzle mechanics that explore non-locality through gameplay."),
        
        (["bioluminescence", "interactive art"],
         "**Living Light Installation**: An interactive room where visitors' movements trigger bioluminescent patterns on responsive surfaces, creating a symbiotic dance between human presence and organic light emission."),
        
        (["fractal patterns", "music generation"],
         "**Fractal Soundscapes**: A music generator that uses fractal algorithms to create self-similar melodic structures across different time scales, producing endlessly complex yet coherent musical compositions.")
    ]
    
    for i, (example_codon, description) in enumerate(examples, 1):
        print(f"\nExample {i}: {example_codon[0]} + {example_codon[1]}")
        print(f"  → {description}")
    
    print("\n" + "=" * 60)
    print("NEXT STEPS FOR YOUR WORKSPACE:")
    print("=" * 60)
    print("1. Fix CLI interactive issue (config.ini reading)")
    print("2. Create specialized lexasomes for your needs:")
    print("   - Game mechanics")
    print("   - Creative writing prompts")  
    print("   - Technical concepts")
    print("3. Design lexaplasts for different output types")
    print("4. Set up automated mining (overnight generation)")
    print("5. Integrate with daily game pipeline")

if __name__ == "__main__":
    main()