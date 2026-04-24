const fs = require('fs');
let code = fs.readFileSync('/home/ubuntu/.openclaw/workspace/elemental-garden/index.html', 'utf8');
const search = "function checkCombinations(";
const startIdx = code.indexOf(search);
console.log(code.substring(startIdx, startIdx + 800));
