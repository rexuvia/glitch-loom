# Rexuvia.com Website Workflow

## Current Architecture
- **Source:** Vue.js SPA in `~/workspace/rexuvia-site/`
- **Build:** Vite (`npm run build`) → `dist/` folder
- **Hosting:** AWS S3 + CloudFront CDN
- **Deployment:** `deploy.sh` script syncs `dist/` to S3

## Workflow for Local Changes

### Option 1: Git Workflow (Recommended)
```bash
# On your local machine:
git add .
git commit -m "Description of changes"
git push origin main

# On server (after SSH):
cd ~/.openclaw/workspace/rexuvia-site
git pull origin main
bash rebuild.sh
# OR: bash deploy.sh (if rebuild.sh already called in deploy.sh)
```

### Option 2: Direct File Copy
```bash
# On your local machine (example):
scp -r local/path/* user@server:~/.openclaw/workspace/rexuvia-site/

# On server:
cd ~/.openclaw/workspace/rexuvia-site
bash rebuild.sh
```

## Common Issues & Solutions

### Issue: "Access Denied" on Website
**Possible causes:**
1. **S3 bucket permissions** - Bucket not publicly readable
2. **CloudFront OAI misconfigured** - Origin Access Identity issues
3. **File permissions on server** - Files not readable after copy
4. **Cache issues** - CloudFront serving stale/cached error pages

**Diagnosis:**
```bash
# 1. Check S3 file exists and is public:
aws s3 ls s3://rexuvia-site/index.html
aws s3api head-object --bucket rexuvia-site --key index.html

# 2. Test direct S3 URL (if bucket is website-enabled):
# Not applicable - using CloudFront

# 3. Check CloudFront distribution:
aws cloudfront get-distribution --id E1XVGZVNUPVUXK

# 4. Check file permissions on server:
ls -la ~/.openclaw/workspace/rexuvia-site/dist/
```

### Issue: Changes Not Appearing
**Checklist:**
1. ✅ Files copied to server
2. ✅ `bash rebuild.sh` executed (creates `dist/` folder)
3. ✅ `bash deploy.sh` executed (syncs to S3)
4. ✅ CloudFront cache invalidated
5. ✅ Browser cache cleared

**Debug commands:**
```bash
# 1. Verify dist folder has changes:
diff -u ~/.openclaw/workspace/rexuvia-site/public/index.html ~/.openclaw/workspace/rexuvia-site/dist/index.html

# 2. Verify S3 has new files:
aws s3 ls s3://rexuvia-site/ --recursive | grep "index.html"

# 3. Verify CloudFront (with cache busting):
curl -s "https://rexuvia.com/?v=$(date +%s)"

# 4. Check deploy script output for errors:
cd ~/.openclaw/workspace/rexuvia-site
bash deploy.sh 2>&1 | tail -20
```

### Issue: File Permission Problems After Copy
**Solution:** Fix permissions before rebuild
```bash
cd ~/.openclaw/workspace/rexuvia-site
# Make all files readable
find . -type f -exec chmod 644 {} \;
# Make directories executable
find . -type d -exec chmod 755 {} \;
# Rebuild
bash rebuild.sh
```

## Complete Workflow Script

Create `update-website.sh` on server:
```bash
#!/bin/bash
# update-website.sh - Complete website update workflow
set -e

echo "=== Website Update Workflow ==="
echo "1. Pulling latest changes..."
cd ~/.openclaw/workspace/rexuvia-site
git pull origin main 2>&1 | grep -v "Already up to date" || true

echo "2. Fixing permissions..."
find . -type f -exec chmod 644 {} \;
find . -type d -exec chmod 755 {} \;

echo "3. Rebuilding site..."
bash rebuild.sh

echo "4. Deploying to S3/CloudFront..."
bash deploy.sh

echo "5. Verifying deployment..."
curl -s -H "Cache-Control: no-cache" "https://rexuvia.com/?v=$(date +%s)" | grep -o "<title>[^<]*</title>"

echo "=== Update Complete ==="
```

## Quick Reference

### Most Common Commands
```bash
# Full update (after git pull):
cd ~/.openclaw/workspace/rexuvia-site
bash rebuild.sh
bash deploy.sh

# Partial updates:
bash deploy.sh --games        # Games only
bash deploy.sh --modelshow    # ModelShow results only

# Force cache clear:
aws cloudfront create-invalidation --distribution-id E1XVGZVNUPVUXK --paths "/*"
```

### Verification Steps
Always verify after update:
1. **Local:** `ls -la dist/` - Files exist with correct sizes
2. **S3:** `aws s3 ls s3://rexuvia-site/` - Files uploaded
3. **CloudFront:** `curl -H "Cache-Control: no-cache" https://rexuvia.com/`
4. **Browser:** Incognito window test

### Emergency Fixes
If site shows "Access Denied":
```bash
# 1. Check S3 bucket policy (might need to be set to public):
aws s3api put-bucket-policy --bucket rexuvia-site --policy '{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::rexuvia-site/*"
    }
  ]
}'

# 2. Force redeploy everything:
cd ~/.openclaw/workspace/rexuvia-site
rm -rf dist/
bash rebuild.sh
bash deploy.sh
aws cloudfront create-invalidation --distribution-id E1XVGZVNUPVUXK --paths "/*"
```

## Monitoring
- **CloudFront logs:** Access patterns, error rates
- **S3 metrics:** Request counts
- **Build logs:** `npm run build` output
- **Deploy logs:** Invalidation IDs, sync status
```

Now, let me check if there's actually an S3 bucket policy issue. Let me try to set a public read policy:

<｜DSML｜function_calls>
<｜DSML｜invoke name="exec">
<｜DSML｜parameter name="command" string="true">aws s3api put-bucket-policy --bucket rexuvia-site --policy '{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow", 
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::rexuvia-site/*"
    }
  ]
}' 2>&1