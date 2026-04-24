# Website Update Protocol for Rexuvia.com

## Current Architecture
- **Static Site:** Vue.js SPA built with Vite
- **Hosting:** AWS S3 + CloudFront CDN
- **Build:** Local EC2 instance → `npm run build` → `dist/` folder
- **Deployment:** `deploy.sh` script syncs `dist/` to S3 + CloudFront cache invalidation

## Update Process (Current)

### 1. Make Changes
```bash
# Edit files in rexuvia-site/public/ or rexuvia-site/src/
cd ~/.openclaw/workspace/rexuvia-site
```

### 2. Rebuild Site
```bash
bash rebuild.sh
# This runs: rm -rf dist && npm run build
```

### 3. Deploy Changes
```bash
# Full deploy (everything)
bash deploy.sh

# Partial deploys:
bash deploy.sh --games        # Games only
bash deploy.sh --modelshow    # ModelShow results only
```

### 4. CloudFront Cache Invalidation
- Deploy script automatically creates invalidation
- Invalidation ID returned (e.g., `I1FEVURDQSE6X6JIZZZYVK579X`)
- Status: `Completed` means invalidation processed

## Common Issues & Solutions

### Issue 1: Browser Still Shows Old Content
**Causes:**
1. **Browser disk cache** - Even hard refresh (Ctrl+F5) might not clear
2. **Service Worker cache** - If site uses PWA features
3. **ISP/CDN intermediate cache** - Between CloudFront and browser

**Solutions:**
```bash
# 1. Force browser cache clear:
# Chrome: Ctrl+Shift+Delete → Clear cached images and files
# Firefox: Ctrl+Shift+Delete → Clear cache

# 2. Bypass cache with query string:
curl "https://rexuvia.com/modelshow-results/index.json?v=$(date +%s)"

# 3. Use incognito/private window (no cache)

# 4. Check CloudFront invalidation status:
aws cloudfront list-invalidations --distribution-id E1XVGZVNUPVUXK --region us-east-1
```

### Issue 2: CloudFront Not Updating
**Check:**
```bash
# 1. Verify S3 has new content:
aws s3 ls s3://rexuvia-site/modelshow-results/index.json
aws s3 cp s3://rexuvia-site/modelshow-results/index.json - | head -20

# 2. Check CloudFront invalidation:
aws cloudfront get-invalidation --distribution-id E1XVGZVNUPVUXK --id I1FEVURDQSE6X6JIZZZYVK579X --region us-east-1

# 3. CloudFront TTL settings might override S3 Cache-Control
# Default TTL: 24 hours (86400 seconds)
# Minimum TTL: 0 seconds
```

### Issue 3: Build Not Including Changes
**Check:**
```bash
# 1. Verify dist/ folder has changes:
diff -u rexuvia-site/public/modelshow-results/index.json rexuvia-site/dist/modelshow-results/index.json

# 2. Check Vite build output for errors:
cd rexuvia-site && npm run build 2>&1 | tail -20

# 3. Verify public/ folder files are copied:
ls -la rexuvia-site/public/modelshow-results/
ls -la rexuvia-site/dist/modelshow-results/
```

## Improved Protocol (Recommended)

### 1. Enhanced Deploy Script
Add versioning/timestamp to force cache busting:

```bash
# In deploy.sh, add version query string to HTML files:
VERSION=$(date +%s)
sed -i "s|\.js\"|\.js?v=$VERSION\"|g" dist/index.html
sed -i "s|\.css\"|\.css?v=$VERSION\"|g" dist/index.html
```

### 2. Cache Control Headers
Ensure proper headers in S3 sync:
```bash
# Current deploy.sh already sets:
# - HTML/JSON/MD: Cache-Control: no-cache
# - Assets (JS/CSS/images): Cache-Control: public,max-age=31536000,immutable
```

### 3. Verification Steps
Always verify after deploy:
```bash
# 1. Check S3:
aws s3 ls s3://rexuvia-site/modelshow-results/ --recursive | grep "index.json"

# 2. Check CloudFront (with cache busting):
curl -s "https://rexuvia.com/modelshow-results/index.json?t=$(date +%s)"

# 3. Check from different regions/locations:
curl -s -H "Cache-Control: no-cache" https://rexuvia.com/modelshow-results/index.json

# 4. Use curl with verbose to see headers:
curl -v -s -H "Cache-Control: no-cache" https://rexuvia.com/modelshow-results/index.json 2>&1 | grep -i "cache\|age"
```

### 4. Browser Testing Protocol
1. **Incognito window** - Always test here first (no cache)
2. **Clear browser cache** - Ctrl+Shift+Delete
3. **Disable cache in DevTools** - Network tab → "Disable cache" checkbox
4. **Hard refresh** - Ctrl+F5 or Ctrl+Shift+R
5. **Different browser** - Chrome vs Firefox vs Safari

## Quick Reference Commands

```bash
# Full update:
cd ~/.openclaw/workspace/rexuvia-site
bash rebuild.sh
bash deploy.sh

# ModelShow only:
bash rebuild.sh
bash deploy.sh --modelshow

# Verify:
curl -s "https://rexuvia.com/modelshow-results/index.json?$(date +%s)" | grep "tags"

# Force CloudFront refresh (if stuck):
aws cloudfront create-invalidation --distribution-id E1XVGZVNUPVUXK --paths "/*" --region us-east-1
```

## Monitoring
- **CloudFront metrics:** Cache hit rate, error rates
- **S3 access logs:** File requests
- **Build logs:** `npm run build` output
- **Deploy logs:** `deploy.sh` output with invalidation IDs

## Emergency Fix
If content is stuck in cache:
1. Update file with new name (e.g., `index_v2.json`)
2. Update references to new file
3. Deploy with `/*` invalidation
4. Wait 5-10 minutes for global propagation
```

## Root Cause Analysis

For your current issue: **The live site HAS the updated keywords** (`productivity`, `openclaw`, `planning`, `automation`, `cronjobs`).

**What you're likely seeing:** Browser disk cache or Service Worker cache.

**To fix immediately:**
1. Open Chrome DevTools (F12)
2. Go to Network tab
3. Check "Disable cache" checkbox
4. Reload page (Ctrl+R)
5. OR: Use Incognito window (Ctrl+Shift+N)

**To verify the live site is correct:**
```bash
# This shows the ACTUAL live content (bypasses browser cache):
curl -s -H "Cache-Control: no-cache" "https://rexuvia.com/modelshow-results/index.json?$(date +%s)" | grep -A7 '"tags": \[' | head -10
```

The deployment was successful - S3 has the right content, CloudFront invalidations completed. The issue is client-side browser caching.