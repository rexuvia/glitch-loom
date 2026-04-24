const fs = require('fs');
let code = fs.readFileSync('/home/ubuntu/.openclaw/workspace/elemental-garden/index.html', 'utf8');

// The issue is translating `-50%, -50%` + absolute left/top!
// When we calculate offset: 
//     const offsetX = e.clientX - (rect.left + rect.width / 2);
//     item.style.left = (e.clientX - offsetX) + 'px';
// And the item has `transform: translate(-50%, -50%)`.
// Because of `translate(-50%, -50%)`, `left` actually references the center of the element, 
// so `rect.left` is shifted. The offset math becomes completely messed up.

// Let's remove `transform: translate(-50%, -50%);` from .canvas-item in the CSS.
// Or adjust the logic.

let repl = code;
repl = repl.replace("transform: translate(-50%, -50%);", "");

fs.writeFileSync('/home/ubuntu/.openclaw/workspace/elemental-garden/index.html', repl);
