const fs = require('fs');
let code = fs.readFileSync('/home/ubuntu/.openclaw/workspace/elemental-garden/index.html', 'utf8');

// The issue might just be that the code is missing the logic for `startDragging` which calculates
// the mouse offset based on the initial pointerdown event. Let's see what startDragging does.
console.log(code.includes("startDragging(item, e);"));
