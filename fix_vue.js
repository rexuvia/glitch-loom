const fs = require('fs');
let content = fs.readFileSync('rexuvia-site/src/components/ModelShowResults.vue', 'utf8');

content = content.replace(/\/\* \.ms-refresh-btn, \*\/\n/g, '');

fs.writeFileSync('rexuvia-site/src/components/ModelShowResults.vue', content);
