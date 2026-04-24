const fs = require('fs');
let code = fs.readFileSync('/home/ubuntu/.openclaw/workspace/elemental-garden/index.html', 'utf8');

// Is the issue that `rect` has 0 width and height when first appended?
// When `createCanvasItem` is called:
// `DOM.workspace.appendChild(item);`
// Then immediately `startDragging(item, e)` is called.
// BUT `getBoundingClientRect` might return `left=0`, `width=0` because it hasn't rendered yet!
// THIS IS THE BUG. `rect.left` is `0`, so `offsetX` is `clientX - 0` = `clientX`. 
// Then `item.style.left` becomes `e.clientX - e.clientX` = `0px`!
// Which means the item flies to the top left of the screen (or the middle if transform -50% -50% is active).

console.log(code.substring(code.indexOf("function startDragging"), code.indexOf("function startDragging") + 800));
