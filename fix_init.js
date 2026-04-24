const fs = require('fs');
let code = fs.readFileSync('/home/ubuntu/.openclaw/workspace/elemental-garden/index.html', 'utf8');

// Also, the game initialization needs to be explicitly handled properly.
// Is `init()` called on load? Let's check the bottom of the script.
console.log(code.substring(code.lastIndexOf("init()"), code.length));
