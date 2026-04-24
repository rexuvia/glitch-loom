const fs = require('fs');
let code = fs.readFileSync('/home/ubuntu/.openclaw/workspace/elemental-garden/index.html', 'utf8');

// The original logic was:
// const offsetX = e.clientX - (rect.left + rect.width / 2);
// item.style.left = (e.clientX - offsetX) + 'px';

// This means item.style.left is set to `rect.left + rect.width / 2` which is the CENTER of the rectangle!
// So if `transform: translate(-50%, -50%)` is present, it actually WORKS perfectly.
// Let's PUT BACK `transform: translate(-50%, -50%);`
code = code.replace("transition: filter 0.2s, opacity 0.3s, transform 0.05s linear;", "transform: translate(-50%, -50%);\n            transition: filter 0.2s, opacity 0.3s, transform 0.05s linear;");

fs.writeFileSync('/home/ubuntu/.openclaw/workspace/elemental-garden/index.html', code);
