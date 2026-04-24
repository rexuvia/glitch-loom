# 🔧 Simple API Test - Bypassing Configuration Issues

## 🎯 The Problem
Phenosemantic config module is failing to load, preventing API testing. Let's bypass it entirely.

## 🚀 Direct API Test (No Phenosemantic)

### **Step 1: Test API Key with curl**
```bash
curl -X POST https://api.deepseek.com/v1/chat/completions \
  -H "Authorization: Bearer sk-b4865f2e303f4ceb99323e2b3c9c7aef" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "deepseek-chat",
    "messages": [
      {"role": "user", "content": "Write a one-line haiku about testing APIs"}
    ],
    "max_tokens": 50
  }'
```

### **Step 2: Check Response**
- **✅ Success:** JSON response with generated text
- **❌ 401 Unauthorized:** API key invalid
- **❌ Other error:** Network/configuration issue

## 🔧 If API Works But Phenosemantic Doesn't

### **Option A: Create Local config.ini**
```bash
cd /home/ubuntu/.openclaw/workspace/phenosemantic-workspace/phenosemantic-py
cat > config.ini << 'EOF'
[API]
deepseek_api_key = sk-b4865f2e303f4ceb99323e2b3c9c7aef
openai_api_key = sk-b4865f2e303f4ceb99323e2b3c9c7aef
deepseek_api_url = https://api.deepseek.com/v1/chat/completions
openai_api_url = https://api.deepseek.com/v1/chat/completions
deepseek_default_model = deepseek-chat
openai_default_model = deepseek-chat
api_provider_order = deepseek,openai
api_timeout = 30
api_temperature = 0.7
max_tokens = 4000

[Paths]
text_outputs_base_dir = /home/ubuntu/pheno-outputs
EOF
```

### **Option B: Use Environment Variables**
```bash
export DEEPSEEK_API_KEY=sk-b4865f2e303f4ceb99323e2b3c9c7aef
export OPENAI_API_KEY=sk-b4865f2e303f4ceb99323e2b3c9c7aef
cd /home/ubuntu/.openclaw/workspace/phenosemantic-workspace/phenosemantic-py
source .venv/bin/activate
phenosemantic --lexaplast funny_poem_generator.json --incognito
```

## 📋 Quick Diagnostic

**Please run this single command:**
```bash
curl -s -X POST https://api.deepseek.com/v1/chat/completions \
  -H "Authorization: Bearer sk-b4865f2e303f4ceb99323e2b3c9c7aef" \
  -H "Content-Type: application/json" \
  -d '{"model":"deepseek-chat","messages":[{"role":"user","content":"TEST"}]}' | grep -o '"content":"[^"]*"'
```

**Expected output:** `"content":"TEST response..."`

## 🎯 Immediate Path Forward

1. **Test API directly with curl** (above command)
2. **If API works:** Create local config.ini (Option A)
3. **Test phenosemantic again**

**This bypasses all configuration loading issues and tests the core API connection directly.**

## ⏱️ Time to Resolution: 2 minutes

**Your action:** Run the curl test above
**My fix:** Provide exact config.ini based on results

**Let's get this working!** 🛠️