#!/usr/bin/env python3
"""
Test DeepSeek API connection directly
This bypasses the phenosemantic CLI and tests the API key directly
"""

import os
import sys
import json
import requests

def test_deepseek_api():
    """Test DeepSeek API with a simple request"""
    
    # Get API key from config file
    config_path = os.path.expanduser("~/.config/phenosemantic/config.ini")
    
    if not os.path.exists(config_path):
        print(f"❌ Config file not found: {config_path}")
        return False
    
    # Read API key from config
    api_key = None
    with open(config_path, 'r') as f:
        for line in f:
            if line.strip().startswith("deepseek_api_key"):
                api_key = line.split('=')[1].strip()
                break
    
    if not api_key:
        print("❌ DeepSeek API key not found in config")
        return False
    
    if not api_key.startswith("sk-"):
        print(f"❌ API key doesn't look valid: {api_key[:20]}...")
        return False
    
    print(f"✅ Found API key: {api_key[:15]}...")
    
    # Test API with a simple request
    url = "https://api.deepseek.com/v1/chat/completions"
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json"
    }
    
    data = {
        "model": "deepseek-chat",
        "messages": [
            {"role": "user", "content": "Write a one-line haiku about testing APIs"}
        ],
        "max_tokens": 50,
        "temperature": 0.7
    }
    
    print("🔌 Testing DeepSeek API connection...")
    
    try:
        response = requests.post(url, headers=headers, json=data, timeout=30)
        
        if response.status_code == 200:
            result = response.json()
            message = result['choices'][0]['message']['content']
            print(f"✅ API Connection Successful!")
            print(f"📝 Response: {message}")
            return True
        elif response.status_code == 401:
            print(f"❌ API Error 401: Unauthorized")
            print(f"   Your API key may be invalid or expired")
            print(f"   Key used: {api_key[:15]}...")
            return False
        elif response.status_code == 429:
            print(f"❌ API Error 429: Rate Limited")
            print(f"   Too many requests, try again later")
            return False
        else:
            print(f"❌ API Error {response.status_code}: {response.text[:200]}")
            return False
            
    except requests.exceptions.ConnectionError:
        print("❌ Connection Error: Cannot reach DeepSeek API")
        print("   Check your internet connection")
        return False
    except requests.exceptions.Timeout:
        print("❌ Timeout Error: API request timed out")
        return False
    except Exception as e:
        print(f"❌ Unexpected Error: {str(e)}")
        return False

def test_phenosemantic_config():
    """Test if phenosemantic config is properly loaded"""
    
    print("\n🔧 Testing Phenosemantic Configuration...")
    
    # Check if we can import the config module
    try:
        # Add phenosemantic to path
        pheno_path = "/home/ubuntu/.openclaw/workspace/phenosemantic-workspace/phenosemantic-py/src"
        sys.path.insert(0, pheno_path)
        
        from phenosemantic import config
        
        print(f"✅ Phenosemantic module imported successfully")
        print(f"   Config file: {config.get_config_file_path()}")
        print(f"   DEEPSEEK_API_KEY: {'✅ Set' if config.DEEPSEEK_API_KEY else '❌ Not set'}")
        print(f"   API_PROVIDER_ORDER: {config.API_PROVIDER_ORDER}")
        
        return True
        
    except ImportError as e:
        print(f"❌ Cannot import phenosemantic: {e}")
        print(f"   Path tried: {pheno_path}")
        return False
    except Exception as e:
        print(f"❌ Error loading config: {e}")
        return False

def test_file_paths():
    """Test if all necessary files exist"""
    
    print("\n📁 Testing File Paths...")
    
    paths_to_check = [
        ("Poem subjects", "/home/ubuntu/.openclaw/workspace/phenosemantic-workspace/phenosemantic-py/lexasomes/poem_subjects.txt"),
        ("Poem styles", "/home/ubuntu/.openclaw/workspace/phenosemantic-workspace/phenosemantic-py/lexasomes/poem_styles.txt"),
        ("Poem generator", "/home/ubuntu/.openclaw/workspace/phenosemantic-workspace/phenosemantic-py/lexaplasts/funny_poem_generator.json"),
        ("Virtual env", "/home/ubuntu/.openclaw/workspace/phenosemantic-workspace/phenosemantic-py/.venv/bin/activate"),
    ]
    
    all_good = True
    for name, path in paths_to_check:
        if os.path.exists(path):
            print(f"   ✅ {name}: {path}")
        else:
            print(f"   ❌ {name}: Missing at {path}")
            all_good = False
    
    return all_good

def main():
    print("🔍 DeepSeek API Connection Test")
    print("=" * 50)
    
    # Test 1: Direct API connection
    api_ok = test_deepseek_api()
    
    # Test 2: File paths
    files_ok = test_file_paths()
    
    # Test 3: Phenosemantic config
    config_ok = test_phenosemantic_config()
    
    print("\n" + "=" * 50)
    print("📊 TEST RESULTS")
    print("=" * 50)
    
    if api_ok and files_ok and config_ok:
        print("🎉 ALL TESTS PASSED!")
        print("\n✅ API Connection: Working")
        print("✅ Files: All present")
        print("✅ Configuration: Loaded correctly")
        print("\n🚀 Ready to generate poems!")
        print("\nRun this command to test:")
        print("cd /home/ubuntu/.openclaw/workspace/phenosemantic-workspace/phenosemantic-py")
        print("source .venv/bin/activate")
        print("phenosemantic --mine 3 1000 --lexaplast funny_poem_generator.json --incognito")
        return 0
    else:
        print("⚠️ SOME TESTS FAILED")
        print("\nIssues found:")
        if not api_ok:
            print("  ❌ API connection failed")
        if not files_ok:
            print("  ❌ Missing files")
        if not config_ok:
            print("  ❌ Configuration issues")
        
        print("\n🔧 Next steps:")
        print("1. Check API key in ~/.config/phenosemantic/config.ini")
        print("2. Verify files exist in the workspace")
        print("3. Check internet connection")
        return 1

if __name__ == "__main__":
    sys.exit(main())