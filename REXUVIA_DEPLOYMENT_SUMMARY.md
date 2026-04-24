# Rexuvia Deployment Summary

## 📍 Location
`~/workspace/rexuvia-site/`

## 🚀 Deployment Commands

### **For Agents (Recommended):**
```bash
cd ~/.openclaw/workspace/rexuvia-site
./update-site.sh
```

### **Manual (if you know what you're doing):**
```bash
# Website changes (CSS, text, components, HTML):
bash rebuild.sh

# OR
bash deploy.sh

# Only ModelShow results:
bash deploy.sh --modelshow

# Only games:
bash deploy.sh --games
```

## 📚 Documentation Files

### **In rexuvia-site/ directory:**
1. `AGENT_DEPLOYMENT_README.md` - Quick guide for agents
2. `DEPLOYMENT_GUIDE.md` - Detailed technical guide
3. `update-site.sh` - Safe deployment script

### **In workspace root:**
1. `WEBSITE_UPDATE_PROTOCOL.md` - Complete update process
2. `WEBSITE_WORKFLOW.md` - Workflow with troubleshooting

## 🎯 Key Points for Agents

### **DO:**
- Use `./update-site.sh` for any changes
- Test in Incognito browser after deploy
- Wait 30 seconds for CloudFront propagation

### **DON'T:**
- Use `deploy.sh --modelshow` for website changes
- Forget to check if changes are visible
- Assume browser cache is cleared

## 🔧 Architecture

```
Local changes → git push → Server (git pull) → rebuild.sh → S3 → CloudFront
```

### **Critical:**
- CSS/JS files get content-based hashes
- HTML must reference correct hashes
- `deploy.sh --modelshow` doesn't update HTML/CSS/JS

## 🆘 Troubleshooting

### **Changes not showing?**
1. Did you run `rebuild.sh` (not `deploy.sh --modelshow`)?
2. Test in Incognito window
3. Wait 1-2 minutes for cache

### **"Access Denied"?**
1. Wait for CloudFront propagation
2. Clear browser cache
3. Check S3 permissions

## 📞 Quick Verification
```bash
curl -s -H "Cache-Control: no-cache" "https://rexuvia.com/?v=$(date +%s)" | grep -o "<title>[^<]*</title>"
# Should show: <title>Rexuvia — Autonomous Agent Swarm</title>
```