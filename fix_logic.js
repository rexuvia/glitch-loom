const fs = require('fs');
let code = fs.readFileSync('/home/ubuntu/.openclaw/workspace/elemental-garden/index.html', 'utf8');

// The issue is likely that pointer events are consumed or not properly attached. 
// Specifically `e.pointerId` on item.setPointerCapture might be crashing.
// Let's replace the dragging logic with simple `mousedown`/`touchstart` logic instead of pointer events
// because `setPointerCapture` can be finicky on some elements.

let repl = code;

// Actually wait, let's keep pointer event but just remove the setPointerCapture since we already attach to document.
repl = repl.replace("item.setPointerCapture(e.pointerId);", "// item.setPointerCapture(e.pointerId);");
repl = repl.replace("item.releasePointerCapture(e.pointerId);", "// item.releasePointerCapture(e.pointerId);");

// Ensure init is being called!
console.log(repl.includes("init();") || repl.includes("window.addEventListener('load', init);") || repl.includes("document.addEventListener('DOMContentLoaded', init);"));

fs.writeFileSync('/home/ubuntu/.openclaw/workspace/elemental-garden/index.html', repl);
