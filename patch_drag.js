const fs = require('fs');

let code = fs.readFileSync('/home/ubuntu/.openclaw/workspace/elemental-garden/index.html', 'utf8');

// If the item was JUST added, `rect.width` will be 0 on some browsers until the next frame, 
// OR it will just be positioned at top=e.clientY, left=e.clientX, BUT `createCanvasItem` uses `item.style.left = x + 'px'`
// So `rect.left` is roughly `e.clientX`.
// 
// If x = e.clientX, and y = e.clientY, then rect's center is at `x` and `y`.
// Let's rewrite startDragging so it checks if the rect is valid, OR we just hardcode width/height to 70 / 2 = 35.

const patch = `
        function startDragging(item, e) {
            item.style.zIndex = ++highestZ;
            item.classList.add('dragging');
            
            const rect = item.getBoundingClientRect();
            // Fallback for when rect isn't fully computed yet:
            let left = rect.left !== 0 ? rect.left : parseFloat(item.style.left) - 35;
            let top = rect.top !== 0 ? rect.top : parseFloat(item.style.top) - 35;
            let width = rect.width || 70;
            let height = rect.height || 70;

            const offsetX = e.clientX - (left + width / 2);
            const offsetY = e.clientY - (top + height / 2);
            
            activeDrag = { item, offsetX, offsetY };
            
            document.addEventListener('pointermove', onPointerMove);
            document.addEventListener('pointerup', onPointerUp);
            document.addEventListener('pointercancel', onPointerUp);
            
            item.style.left = (e.clientX - offsetX) + 'px';
            item.style.top = (e.clientY - offsetY) + 'px';
        }
`;

code = code.replace(/function startDragging\([^\{]*\{[\s\S]*?function onPointerMove\(/, `
        function startDragging(item, e) {
            item.style.zIndex = ++highestZ;
            item.classList.add('dragging');
            
            const rect = item.getBoundingClientRect();
            // Calculate offset. If it's a new item, rect might be centered at clientX/Y.
            // But if we just assume no offset when spawning:
            const offsetX = e.offsetX ? e.offsetX - 35 : 0; // 35 is half the 70px width
            const offsetY = e.offsetY ? e.offsetY - 35 : 0;
            
            activeDrag = { item, offsetX: 0, offsetY: 0 }; 
            // Setting offsets to 0 ensures it snaps exactly to your finger!
            
            document.addEventListener('pointermove', onPointerMove);
            document.addEventListener('pointerup', onPointerUp);
            document.addEventListener('pointercancel', onPointerUp);
            
            item.style.left = e.clientX + 'px';
            item.style.top = e.clientY + 'px';
        }

        function onPointerMove(`);

fs.writeFileSync('/home/ubuntu/.openclaw/workspace/elemental-garden/index.html', code);
