# Wave Collapse Weaver - Technical Architecture

## Overview
An interactive generative art tool where users place constraint tiles and watch Wave Function Collapse (WFC) algorithms paint infinite patterns in real-time.

---

## 1. WFC Algorithm Implementation Strategy

### Core Algorithm
- **Tile-based WFC**: Use a discrete tile set with defined adjacency rules
- **Superposition state**: Each cell maintains a list of possible tiles
- **Entropy calculation**: Track number of possible states per cell
- **Collapse strategy**: Always collapse lowest-entropy cell first (with random tiebreaker)
- **Propagation**: Breadth-first propagation of constraints after each collapse

### Tile System
```javascript
// Tile structure
{
  id: 'tile_name',
  edges: { top: 'A', right: 'B', bottom: 'A', left: 'C' },
  color: '#hex',
  pattern: 'svg_path' // or canvas draw function
}

// Adjacency rules: tiles connect when adjacent edges match
// Example: tile1.edges.right === tile2.edges.left
```

### Adjacency Rules
- **Edge-matching system**: Each tile edge has a socket type (letter/number)
- **Bidirectional compatibility**: If A connects to B, B connects to A
- **Rotation support**: Generate rotated variants of base tiles automatically
- **Constraint propagation**: When a cell collapses, remove incompatible options from neighbors

### Backtracking Strategy
- **Contradiction detection**: If any cell reaches 0 possible states, contradiction occurred
- **Checkpoint system**: Save state before each collapse (lightweight - just possibility arrays)
- **Rollback**: Revert to last checkpoint and try different random choice
- **Max depth**: Limit backtracking depth to prevent infinite loops (fallback: restart)

### Performance Optimizations
- **Lazy propagation**: Only propagate constraints to "dirty" cells
- **Chunk-based processing**: Process grid in chunks for large canvases
- **RequestAnimationFrame**: Smooth animation of collapse process
- **Worker threads**: Consider Web Worker for heavy computation (optional for v1)

---

## 2. UI/UX Flow

### Main Layout
```
┌─────────────────────────────────────┐
│ Header: Wave Collapse Weaver        │
├──────────┬──────────────────────────┤
│ Tile     │                          │
│ Palette  │    Canvas (grid)         │
│          │                          │
│ [tiles]  │    [interactive grid]    │
│ [preset] │                          │
│          │                          │
│ Controls │                          │
│ [play]   │                          │
│ [pause]  │                          │
│ [reset]  │                          │
│ [speed]  │                          │
└──────────┴──────────────────────────┘
```

### User Interaction Flow
1. **Initial state**: Empty/partially filled grid + tile palette
2. **Place constraints**: Click/tap to place specific tiles (locks that cell)
3. **Start generation**: Click "Generate" to run WFC
4. **Real-time animation**: Watch tiles collapse one-by-one
5. **Interaction during generation**:
   - Pause/resume
   - Adjust speed
   - Add more constraints (resets affected region)
6. **Export**: Download as PNG/SVG

### Tile Palette
- **Visual tile preview**: Show each tile type with clear visual
- **Click to select**: Highlight selected tile
- **Preset patterns**: Dropdown with pre-made tile sets:
  - "Circuit Board" - tech aesthetic
  - "Organic Flow" - curved, natural
  - "Geometric" - sharp angles, symmetrical
  - "Pixel Art" - retro aesthetic
- **Color scheme selector**: Change palette on the fly

### Canvas Controls
- **Grid size selector**: 10x10, 20x20, 30x30, 50x50
- **Zoom/pan**: For larger grids (pinch-to-zoom on mobile)
- **Click modes**:
  - Place constraint tile
  - Erase constraint
  - Pan (drag canvas)

### Generation Controls
- **Generate/Play**: Start WFC algorithm
- **Pause/Resume**: Freeze animation
- **Step Forward**: Manually advance one collapse
- **Reset**: Clear all generated tiles (keep constraints)
- **Clear All**: Reset entire canvas
- **Speed slider**: 1x to 100x (instant)

---

## 3. Visual Design

### Tile Aesthetic
**Option A: Circuit Board Theme** (recommended for launch)
- Tiles represent circuit traces, pads, components
- Edge types: straight, curved, junction, terminal
- Color: Dark background with neon traces (cyan, magenta, yellow, green)
- Style: Minimalist, clean lines, slight glow effect

**Option B: Organic Flow**
- Curved, flowing lines representing vines/rivers
- Natural color palette (greens, blues, earth tones)
- Softer, rounded shapes

### Color Schemes
```javascript
const themes = {
  cyberpunk: {
    background: '#0a0e27',
    tiles: ['#00f3ff', '#ff00ff', '#ffff00', '#00ff88'],
    glow: true
  },
  forest: {
    background: '#1a2f1a',
    tiles: ['#2d5016', '#4a7c23', '#8bc34a', '#c5e1a5'],
    glow: false
  },
  monochrome: {
    background: '#ffffff',
    tiles: ['#000000', '#333333', '#666666', '#999999'],
    glow: false
  }
}
```

### Animation Approach
- **Collapse animation**: Tile fades in + slight scale pulse (0.8 -> 1.0)
- **Duration**: 200ms per tile (adjustable via speed slider)
- **Propagation wave**: Subtle highlight pulse on cells being constrained
- **Contradiction**: Red flash if backtracking occurs
- **Constraint placement**: Lock icon + different border color

### Grid Appearance
- **Cell borders**: Subtle grid lines (low opacity)
- **Hover state**: Highlight cell on mouse-over
- **Locked cells**: Thicker border + lock indicator
- **Empty cells**: Show superposition count (number of possible tiles)

---

## 4. Technical Approach

### Tech Stack
- **Pure vanilla JS** (no frameworks) - single HTML file
- **HTML5 Canvas** for rendering (better performance than SVG for large grids)
- **CSS3** for UI styling and animations
- **ES6+** modern JavaScript features

### File Structure (Single HTML)
```html
<!DOCTYPE html>
<html>
<head>
  <style>/* All CSS */</style>
</head>
<body>
  <!-- UI structure -->
  <script>
    // 1. Tile definitions
    // 2. WFC algorithm core
    // 3. Canvas rendering
    // 4. UI event handlers
    // 5. Animation loop
    // 6. Initialization
  </script>
</body>
</html>
```

### Code Architecture
```javascript
// Core modules (namespaced to avoid globals)
const WaveCollapseWeaver = {
  // Tile system
  Tiles: {
    library: {},
    presets: {},
    generateRotations(baseTile) {},
    checkCompatibility(tile1, tile2, direction) {}
  },
  
  // WFC Algorithm
  WFC: {
    grid: [],
    constraints: [],
    history: [],
    
    initialize(width, height) {},
    collapse() {},
    propagate(x, y) {},
    findLowestEntropy() {},
    checkContradiction() {},
    backtrack() {},
    step() {} // Single iteration
  },
  
  // Rendering
  Renderer: {
    canvas: null,
    ctx: null,
    
    init() {},
    drawGrid() {},
    drawTile(x, y, tile) {},
    highlightCell(x, y) {},
    animateCollapse(x, y, tile) {}
  },
  
  // UI Controller
  UI: {
    selectedTile: null,
    isGenerating: false,
    speed: 1,
    
    handleCanvasClick(x, y) {},
    handleToolSelect(tool) {},
    handleGenerate() {},
    handlePause() {},
    handleReset() {}
  },
  
  // Animation loop
  Animation: {
    running: false,
    lastFrame: 0,
    
    start() {},
    stop() {},
    loop(timestamp) {}
  }
}
```

### Performance Optimization

**For Real-time Generation:**
1. **Batch rendering**: Redraw only changed cells, not entire canvas
2. **Dirty flags**: Track which cells need redraw
3. **Offscreen canvas**: Pre-render tile sprites to offscreen canvas
4. **RequestAnimationFrame**: Smooth 60fps animation
5. **Throttle propagation**: Limit propagation steps per frame (configurable)

**Memory:**
- Reuse tile objects (don't create new instances)
- Clear history after successful generation
- Limit checkpoint depth

**Scalability:**
- Graceful degradation for mobile (smaller default grid)
- Reduce animation complexity on slower devices
- Disable glow effects if frame rate drops

### Mobile Responsiveness
- **Responsive layout**: Stack palette below canvas on narrow screens
- **Touch events**: Support tap to place, pinch to zoom, drag to pan
- **Larger touch targets**: 44px minimum for buttons
- **Viewport meta tag**: Prevent unwanted zoom
- **Portrait/landscape**: Adapt layout to orientation

### Browser Compatibility
- Target: Modern browsers (Chrome, Firefox, Safari, Edge)
- ES6+ features: Arrow functions, const/let, template literals, classes
- Canvas API: Widely supported
- Fallback: Display warning for ancient browsers (IE)

---

## 5. Implementation Phases

### Phase 1: Core WFC Engine
- Implement basic tile system with edge matching
- WFC algorithm: collapse, propagate, entropy calculation
- Simple console/DOM output to verify correctness

### Phase 2: Canvas Rendering
- Draw grid on canvas
- Render tiles with basic shapes/colors
- Handle canvas resize

### Phase 3: User Interaction
- Click to place constraints
- Tool selection (place, erase)
- Generate button triggers WFC

### Phase 4: Animation
- Animate collapse process frame-by-frame
- Smooth transitions, visual feedback
- Speed control

### Phase 5: Polish
- Tile presets with beautiful designs
- Color themes
- Mobile optimization
- Export functionality

---

## 6. Tile Preset: "Circuit Board" (Default)

### Tile Types (Base set before rotations)
1. **Straight**: Horizontal/vertical line
   - Edges: A-B-A-B (connects opposite sides)
   
2. **Corner**: 90-degree turn
   - Edges: A-A-B-B (connects adjacent sides)
   
3. **T-Junction**: Three-way connection
   - Edges: A-B-B-B (connects three sides)
   
4. **Cross**: Four-way connection
   - Edges: B-B-B-B (connects all sides)
   
5. **Terminal**: Dead end
   - Edges: A-C-C-C (only one connection)
   
6. **Empty**: No connection
   - Edges: C-C-C-C (isolates neighbors)

Edge types:
- A = connector socket
- B = connector socket (compatible with A)
- C = blank (only connects to other blanks)

This creates interesting, varied circuit patterns!

---

## 7. Success Metrics

A successful implementation will:
✓ Generate valid, constraint-respecting patterns every time
✓ Animate smoothly at 30+ fps on desktop, 20+ fps on mobile
✓ Handle 30x30 grid without lag
✓ Provide intuitive, delightful UX
✓ Look visually stunning with chosen aesthetic
✓ Work on mobile (responsive + touch)
✓ Single-file, no external dependencies
✓ Load in < 1 second

---

## Next Steps: Implementation
Hand this architecture to Grok for initial build, then Sonnet for refinement.
