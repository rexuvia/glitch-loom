const fs = require('fs');
let code = fs.readFileSync('/home/ubuntu/.openclaw/workspace/elemental-garden/index.html', 'utf8');

// The collision check:
// "If dragged outside the workspace, maybe destroy it?"
// if (cxA < workspaceRect.left) { draggedItem.remove(); return; }
//
// BUT `workspaceRect.left` might be the exact pixel you drag! Let's just remove that "destroy" logic.

code = code.replace(/if \(cxA < workspaceRect\.left\) \{[\s\S]*?return;\n            \}/g, `// Removing destroy logic when dragging off-screen. It's safer to just let it drop.`);

fs.writeFileSync('/home/ubuntu/.openclaw/workspace/elemental-garden/index.html', code);
