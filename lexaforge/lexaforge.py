#!/usr/bin/env python3
"""
LexaForge - A clean implementation of phenosemantic concepts without the bugs.
Create and manage lexaplasts/lexasomes, mine outputs, auto-rank, schedule jobs.
"""

import os
import sys
import json
import argparse
import random
import sqlite3
import time
from datetime import datetime, timedelta
from pathlib import Path
from typing import List, Dict, Any, Optional
import urllib.request
import urllib.parse

# Configuration
BASE_DIR = Path(__file__).parent
LEXAPLASTS_DIR = BASE_DIR / "lexaplasts"
LEXASOMES_DIR = BASE_DIR / "lexasomes"
OUTPUTS_DIR = BASE_DIR / "outputs"
DB_PATH = BASE_DIR / "lexaforge.db"
LOG_FILE = BASE_DIR / "lexaforge.log"

# Ensure directories exist
for dir_path in [LEXAPLASTS_DIR, LEXASOMES_DIR, OUTPUTS_DIR]:
    dir_path.mkdir(parents=True, exist_ok=True)

# API Configuration
DEFAULT_MODEL = "openrouter/openai/gpt-4o"
DEFAULT_TEMPERATURE = 0.8
DEFAULT_MAX_TOKENS = 500

def log_message(message: str, level: str = "INFO"):
    """Log a message to file and console."""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    log_entry = f"[{timestamp}] [{level}] {message}\n"
    
    with open(LOG_FILE, "a") as f:
        f.write(log_entry)
    
    if level in ["ERROR", "WARNING"]:
        print(f"{level}: {message}")
    else:
        print(message)

def get_api_key() -> Optional[str]:
    """Get API key from environment or config."""
    # Try OpenRouter first
    api_key = os.environ.get("OPENROUTER_API_KEY")
    if api_key:
        return api_key
    
    # Try OpenAI
    api_key = os.environ.get("OPENAI_API_KEY")
    if api_key:
        return api_key
    
    # Try from OpenClaw config
    try:
        import configparser
        config_path = Path.home() / ".openclaw" / "config.ini"
        if config_path.exists():
            config = configparser.ConfigParser()
            config.read(config_path)
            api_key = config.get("openrouter", "api_key", fallback=None)
            if api_key:
                return api_key
    except:
        pass
    
    log_message("No API key found. Set OPENROUTER_API_KEY or OPENAI_API_KEY environment variable.", "ERROR")
    return None

def call_llm(prompt: str, system_prompt: str = None, model: str = None, 
             temperature: float = None, max_tokens: int = None) -> str:
    """Call LLM via OpenRouter API."""
    api_key = get_api_key()
    if not api_key:
        return "ERROR: No API key configured"
    
    model = model or DEFAULT_MODEL
    temperature = temperature or DEFAULT_TEMPERATURE
    max_tokens = max_tokens or DEFAULT_MAX_TOKENS
    
    url = "https://openrouter.ai/api/v1/chat/completions"
    
    messages = []
    if system_prompt:
        messages.append({"role": "system", "content": system_prompt})
    messages.append({"role": "user", "content": prompt})
    
    data = {
        "model": model,
        "messages": messages,
        "temperature": temperature,
        "max_tokens": max_tokens,
    }
    
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
        "HTTP-Referer": "https://lexaforge.openclaw.ai",
        "X-Title": "LexaForge"
    }
    
    try:
        req = urllib.request.Request(
            url,
            data=json.dumps(data).encode('utf-8'),
            headers=headers,
            method='POST'
        )
        
        with urllib.request.urlopen(req, timeout=30) as response:
            result = json.loads(response.read().decode('utf-8'))
            return result['choices'][0]['message']['content']
    
    except Exception as e:
        log_message(f"API call failed: {e}", "ERROR")
        return f"ERROR: {str(e)}"

def init_database():
    """Initialize SQLite database."""
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    # Jobs table
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS jobs (
        id TEXT PRIMARY KEY,
        name TEXT,
        lexaplast TEXT,
        lexasomes TEXT,
        count INTEGER,
        status TEXT,
        start_time TIMESTAMP,
        end_time TIMESTAMP,
        output_file TEXT,
        error TEXT
    )
    ''')
    
    # Outputs table
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS outputs (
        id TEXT PRIMARY KEY,
        job_id TEXT,
        text TEXT,
        sequons TEXT,
        rating INTEGER DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (job_id) REFERENCES jobs (id)
    )
    ''')
    
    # Scheduled jobs
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS scheduled_jobs (
        id TEXT PRIMARY KEY,
        name TEXT UNIQUE,
        lexaplast TEXT,
        lexasomes TEXT,
        count INTEGER,
        schedule_time TEXT,
        enabled BOOLEAN DEFAULT 1,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
    ''')
    
    conn.commit()
    conn.close()
    log_message("Database initialized")

def create_lexaplast(name: str, template: str = None, interactive: bool = False):
    """Create a new lexaplast."""
    lexaplast_path = LEXAPLASTS_DIR / f"{name}.json"
    
    if lexaplast_path.exists():
        log_message(f"Lexaplast '{name}' already exists", "WARNING")
        return False
    
    if template:
        # Use built-in template
        templates = {
            "creative": {
                "name": name,
                "description": "Creative writing and idea generation",
                "system_prompt": "You are a creative assistant. Generate interesting and novel ideas.",
                "user_prompt_template": "Generate a {domain} {task} with {constraint}",
                "parameters": {
                    "temperature": 0.8,
                    "max_tokens": 500,
                    "model": DEFAULT_MODEL
                }
            },
            "technical": {
                "name": name,
                "description": "Technical questions and problems",
                "system_prompt": "You are a technical expert. Generate challenging and insightful technical content.",
                "user_prompt_template": "Create a {domain} {task} that demonstrates {constraint}",
                "parameters": {
                    "temperature": 0.7,
                    "max_tokens": 400,
                    "model": DEFAULT_MODEL
                }
            },
            "game-concepts": {
                "name": name,
                "description": "Game idea generation",
                "system_prompt": "You are a game designer. Generate novel and engaging game concepts.",
                "user_prompt_template": "Design a game that combines {mechanic1} with {mechanic2} for {platform}",
                "parameters": {
                    "temperature": 0.85,
                    "max_tokens": 600,
                    "model": DEFAULT_MODEL
                }
            }
        }
        
        if template in templates:
            lexaplast = templates[template]
        else:
            log_message(f"Template '{template}' not found. Available: {list(templates.keys())}", "ERROR")
            return False
    
    elif interactive:
        # Interactive creation
        print(f"\nCreating lexaplast '{name}' interactively:")
        description = input("Description: ").strip() or f"Lexaplast for {name}"
        system_prompt = input("System prompt: ").strip() or "You are a helpful assistant."
        user_prompt = input("User prompt template (use {placeholders}): ").strip() or "Generate {domain} {task}"
        
        lexaplast = {
            "name": name,
            "description": description,
            "system_prompt": system_prompt,
            "user_prompt_template": user_prompt,
            "parameters": {
                "temperature": 0.8,
                "max_tokens": 500,
                "model": DEFAULT_MODEL
            }
        }
    
    else:
        # Minimal lexaplast
        lexaplast = {
            "name": name,
            "description": f"Lexaplast for {name}",
            "system_prompt": "You are a helpful assistant.",
            "user_prompt_template": "Generate {domain} {task}",
            "parameters": {
                "temperature": 0.8,
                "max_tokens": 500,
                "model": DEFAULT_MODEL
            }
        }
    
    with open(lexaplast_path, "w") as f:
        json.dump(lexaplast, f, indent=2)
    
    log_message(f"Created lexaplast '{name}' at {lexaplast_path}")
    return True

def create_lexasome(name: str, lexatype: str = "txt", entries: List[str] = None):
    """Create a new lexasome."""
    if lexatype == "txt":
        lexasome_path = LEXASOMES_DIR / f"{name}.txt"
        with open(lexasome_path, "w") as f:
            f.write(f"# Lexasome: {name}\n")
            f.write(f"# Created: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
            if entries:
                for entry in entries:
                    f.write(f"{entry}\n")
    
    elif lexatype == "csv":
        lexasome_path = LEXASOMES_DIR / f"{name}.csv"
        with open(lexasome_path, "w") as f:
            f.write("sequon,weight\n")
            if entries:
                for entry in entries:
                    f.write(f"{entry},1.0\n")
    
    else:
        log_message(f"Unsupported lexatype: {lexatype}", "ERROR")
        return False
    
    log_message(f"Created {lexatype} lexasome '{name}' at {lexasome_path}")
    return True

def load_lexaplast(name: str) -> Optional[Dict[str, Any]]:
    """Load a lexaplast by name."""
    lexaplast_path = LEXAPLASTS_DIR / f"{name}.json"
    if not lexaplast_path.exists():
        log_message(f"Lexaplast '{name}' not found", "ERROR")
        return None
    
    with open(lexaplast_path, "r") as f:
        return json.load(f)

def load_lexasome(name: str) -> List[str]:
    """Load a lexasome by name."""
    # Try different extensions
    for ext in ["txt", "csv"]:
        lexasome_path = LEXASOMES_DIR / f"{name}.{ext}"
        if lexasome_path.exists():
            with open(lexasome_path, "r") as f:
                lines = [line.strip() for line in f if line.strip() and not line.startswith("#")]
                
                if ext == "csv":
                    # Skip header and parse CSV
                    if lines and lines[0].startswith("sequon"):
                        lines = lines[1:]
                    entries = [line.split(",")[0].strip() for line in lines if "," in line]
                else:
                    entries = lines
                
                return entries
    
    log_message(f"Lexasome '{name}' not found", "ERROR")
    return []

def mine_outputs(lexaplast_name: str, lexasome_names: List[str], count: int = 100, 
                 job_name: str = None, temperature: float = None) -> str:
    """Mine outputs using lexaplast and lexasomes."""
    # Load lexaplast
    lexaplast = load_lexaplast(lexaplast_name)
    if not lexaplast:
        return None
    
    # Load lexasomes
    lexasome_entries = {}
    for lexasome_name in lexasome_names:
        entries = load_lexasome(lexasome_name)
        if entries:
            lexasome_entries[lexasome_name] = entries
        else:
            log_message(f"Warning: Lexasome '{lexasome_name}' empty or not found", "WARNING")
    
    if not lexasome_entries:
        log_message("No valid lexasomes found", "ERROR")
        return None
    
    # Create job ID
    job_id = datetime.now().strftime("%Y%m%d-%H%M%S")
    output_file = OUTPUTS_DIR / f"{job_id}.jsonl"
    
    # Record job
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute('''
    INSERT INTO jobs (id, name, lexaplast, lexasomes, count, status, start_time, output_file)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ''', (
        job_id,
        job_name or f"mine-{job_id}",
        lexaplast_name,
        json.dumps(lexasome_names),
        count,
        "running",
        datetime.now().isoformat(),
        str(output_file)
    ))
    conn.commit()
    
    log_message(f"Starting mining job {job_id}: {count} outputs")
    
    # Mine outputs
    successful = 0
    with open(output_file, "w") as f:
        for i in range(count):
            try:
                # Select random entries from each lexasome
                selected_sequons = {}
                for lex_name, entries in lexasome_entries.items():
                    if entries:
                        selected = random.choice(entries)
                        selected_sequons[lex_name] = selected
                
                # Build prompt
                prompt_template = lexaplast["user_prompt_template"]
                prompt = prompt_template.format(**selected_sequons)
                
                # Call LLM
                response = call_llm(
                    prompt=prompt,
                    system_prompt=lexaplast["system_prompt"],
                    model=lexaplast["parameters"].get("model", DEFAULT_MODEL),
                    temperature=temperature or lexaplast["parameters"].get("temperature", DEFAULT_TEMPERATURE),
                    max_tokens=lexaplast["parameters"].get("max_tokens", DEFAULT_MAX_TOKENS)
                )
                
                if response and not response.startswith("ERROR"):
                    # Save output
                    output_data = {
                        "text": response,
                        "sequons": selected_sequons,
                        "job_id": job_id,
                        "index": i,
                        "timestamp": datetime.now().isoformat(),
                        "lexaplast": lexaplast_name,
                        "model": lexaplast["parameters"].get("model", DEFAULT_MODEL)
                    }
                    
                    f.write(json.dumps(output_data) + "\n")
                    
                    # Save to database
                    cursor.execute('''
                    INSERT INTO outputs (id, job_id, text, sequons)
                    VALUES (?, ?, ?, ?)
                    ''', (
                        f"{job_id}-{i}",
                        job_id,
                        response,
                        json.dumps(selected_sequons)
                    ))
                    
                    successful += 1
                    if successful % 10 == 0:
                        log_message(f"  Generated {successful}/{count} outputs")
                
                # Small delay to avoid rate limits
                time.sleep(0.5)
                
            except Exception as e:
                log_message(f"Error generating output {i}: {e}", "ERROR")
    
    # Update job status
    cursor.execute('''
    UPDATE jobs 
    SET status = ?, end_time = ?
    WHERE id = ?
    ''', ("completed" if successful > 0 else "failed", datetime.now().isoformat(), job_id))
    conn.commit()
    conn.close()
    
    log_message(f"Mining completed: {successful}/{count} outputs generated")
    return job_id

def list_lexaplasts():
    """List all lexaplasts."""
    lexaplasts = list(LEXAPLASTS_DIR.glob("*.json"))
    
    if not lexaplasts:
        print("No lexaplasts found.")
        return
    
    print(f"Found {len(lexaplasts)} lexaplasts:\n")
    for lexaplast_path in sorted(lexaplasts):
        with open(lexaplast_path, "r") as f:
            try:
                data = json.load(f)
                name = data.get("name", lexaplast_path.stem)
                description = data.get("description", "No description")
                print(f"  {name}: {description}")
            except:
                print(f"  {lexaplast_path.stem}: (invalid JSON)")

def list_lexasomes():
    """List all lexasomes."""
    lexasomes = []
    for ext in ["txt", "csv"]:
        lexasomes.extend(LEXASOMES_DIR.glob(f"*.{ext}"))
    
    if not lexasomes:
        print("No lexasomes found.")
        return
    
    print(f"Found {len(lexasomes)} lexasomes:\n")
    for lexasome_path in sorted(lexasomes):
        entries = load_lexasome(lexasome_path.stem)
        print(f"  {lexasome_path.stem}.{lexasome_path.suffix[1:]}: {len(entries)} entries")

def view_outputs(job_id: str, limit: int = 10):
    """View outputs from a job."""
    output_file = OUTPUTS_DIR / f"{job_id}.jsonl"
    
    if not output_file.exists():
        print(f"Output file not found for job {job_id}")
        return
    
    print(f"Outputs from job {job_id}:\n")
    
    count = 0
    with open(output_file, "r") as f:
        for line in f:
            if count >= limit:
                print(f"\n... and more outputs in {output_file}")
                break
            
            try:
                data = json.loads(line.strip())
                text = data.get("text", "").replace("\n", " ")
                if len(text) > 100:
                    text = text[:97] + "..."
                
                print(f"{count+1:3d}. {text}")
                count += 1
            except json.JSONDecodeError:
                print(f"{count+1:3d}. (Invalid JSON)")
                count += 1
    
    if count == 0:
        print("No outputs found.")

def schedule_job(name: str, lexaplast: str, lexasomes: List[str], count: int, schedule_time: str):
    """Schedule a mining job."""
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    cursor.execute('''
    INSERT OR REPLACE INTO scheduled_jobs (id, name, lexaplast, lexasomes, count, schedule_time)
    VALUES (?, ?, ?, ?, ?, ?)
    ''', (
        f"schedule-{datetime.now().strftime('%Y%m%d-%H%M%S')}",
        name,
        lexaplast,
        json.dumps(lexasomes),
        count,
        schedule_time
    ))
    
    conn.commit()
    conn.close()
    
    log_message(f"Scheduled job '{name}' for {schedule_time}")
    print(f"Scheduled: {name} at {schedule_time}")
    print(f"Will mine {count} outputs using lexaplast '{lexaplast}' with lexasomes: {', '.join(lexasomes)}")

def list_scheduled_jobs():
    """List all scheduled jobs."""
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute('SELECT name, lexaplast, lexasomes, count, schedule_time, enabled FROM scheduled_jobs ORDER BY schedule_time')
    jobs = cursor.fetchall()
    conn.close()
    
    if not jobs:
        print("No scheduled jobs found.")
        return
    
    print(f"Found {len(jobs)} scheduled jobs:\n")
    print(f"{'Name':<20} {'Time':<10} {'Lexaplast':<15} {'Count':<6} {'Status':<10}")
    print("-" * 70)
    
    for name, lexaplast, lexasomes, count, schedule_time, enabled in jobs:
        status = "ENABLED" if enabled else "DISABLED"
        print(f"{name:<20} {schedule_time:<10} {lexaplast:<15} {count:<6} {status:<10}")

def main():
    """Main entry point."""
    init_database()
    
    parser = argparse.ArgumentParser(
        description="LexaForge - Clean phenosemantic implementation",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python3 lexaforge.py init
  python3 lexaforge.py create-lexaplast game-concepts --template creative
  python3 lexaforge.py create-lexasome mechanics --type txt
  python3 lexaforge.py mine --lexaplast game-concepts --lexasome mechanics --count 10
  python3 lexaforge.py list-lexaplasts
  python3 lexaforge.py view-outputs --job 20260302-012345
  python3 lexaforge.py schedule --name nightly --lexaplast game-concepts --lexasome mechanics --count 100 --time 03:00
        """
    )
    
    subparsers = parser.add_subparsers(dest="command", help="Command to execute")
    
    # Init command
    subparsers.add_parser("init", help="Initialize LexaForge")
    
    # Lexaplast commands
    lexaplast_parser = subparsers.add_parser("create-lexaplast", help="Create a new lexaplast")
    lexaplast_parser.add_argument("name", help="Name of the lexaplast")
    lexaplast_parser.add_argument("--template", help="Template to use (creative, technical, game-concepts)")
    lexaplast_parser.add_argument("--interactive", action="store_true", help="Create interactively")
    
    subparsers.add_parser("list-lexaplasts", help="List all lexaplasts")
    
    # Lexasome commands
    lexasome_parser = subparsers.add_parser("create-lexasome", help="Create a new lexasome")
    lexasome_parser.add_argument("name", help="Name of the lexasome")
    lexasome_parser.add_argument("--type", choices=["txt", "csv"], default="txt", help="Type of lexasome")
    
    subparsers.add_parser("list-lexasomes", help="List all lexasomes")
    
    # Mining commands
    mine_parser = subparsers.add_parser("mine", help="Mine outputs")
    mine_parser.add_argument("--lexaplast", required=True, help="Lexaplast to use")
    mine_parser.add_argument("--lexasome", required=True, nargs="+", help="Lexasomes to use")
    mine_parser.add_argument("--count", type=int, default=100, help="Number of outputs to generate")
    mine_parser.add_argument("--name", help="Name for this mining job")
    mine_parser.add_argument("--temperature", type=float, help="Generation temperature (overrides lexaplast)")
    
    # Output commands
    view_parser = subparsers.add_parser("view-outputs", help="View outputs from a job")
    view_parser.add_argument("--job", required=True, help="Job ID")
    view_parser.add_argument("--limit", type=int, default=10, help="Maximum outputs to show")
    
    # Scheduling commands
    schedule_parser = subparsers.add_parser("schedule", help="Schedule a mining job")
    schedule_parser.add_argument("--name", required=True, help="Name for the scheduled job")
    schedule_parser.add_argument("--lexaplast", required=True, help="Lexaplast to use")
    schedule_parser.add_argument("--lexasome", required=True, nargs="+", help="Lexasomes to use")
    schedule_parser.add_argument("--count", type=int, default=100, help="Number of outputs to generate")
    schedule_parser.add_argument("--time", required=True, help="Schedule time (HH:MM, 24-hour)")
    
    subparsers.add_parser("list-scheduled", help="List scheduled jobs")
    
    # Parse arguments
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        return
    
    # Execute command
    try:
        if args.command == "init":
            init_database()
            print("LexaForge initialized successfully!")
            
        elif args.command == "create-lexaplast":
            create_lexaplast(args.name, args.template, args.interactive)
            
        elif args.command == "list-lexaplasts":
            list_lexaplasts()
            
        elif args.command == "create-lexasome":
            create_lexasome(args.name, args.type)
            
        elif args.command == "list-lexasomes":
            list_lexasomes()
            
        elif args.command == "mine":
            job_id = mine_outputs(
                lexaplast_name=args.lexaplast,
                lexasome_names=args.lexasome,
                count=args.count,
                job_name=args.name,
                temperature=args.temperature
            )
            if job_id:
                print(f"\nMining job started: {job_id}")
                print(f"Check outputs with: python3 lexaforge.py view-outputs --job {job_id}")
                
        elif args.command == "view-outputs":
            view_outputs(args.job, args.limit)
            
        elif args.command == "schedule":
            schedule_job(
                name=args.name,
                lexaplast=args.lexaplast,
                lexasomes=args.lexasome,
                count=args.count,
                schedule_time=args.time
            )
            
        elif args.command == "list-scheduled":
            list_scheduled_jobs()
            
        else:
            print(f"Unknown command: {args.command}")
            parser.print_help()
    
    except KeyboardInterrupt:
        print("\nInterrupted.")
        sys.exit(1)
    except Exception as e:
        log_message(f"Error in command '{args.command}': {e}", "ERROR")
        print(f"Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()