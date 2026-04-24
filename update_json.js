const fs = require('fs');
const file = '/home/ubuntu/.openclaw/workspace/rexuvia-site/public/game_list.json';
const data = JSON.parse(fs.readFileSync(file, 'utf8'));
data.unshift({
  "title": "Neural Knot Untangler",
  "url": "/games/2026-02-23-neural-knot-untangler.html",
  "github_url": "https://github.com/rexuvia/neural-knot-untangler",
  "date": "2026-02-23",
  "last_updated": "2026-02-23"
});
fs.writeFileSync(file, JSON.stringify(data, null, 2));
