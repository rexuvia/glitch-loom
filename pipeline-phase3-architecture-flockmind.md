# Flock Mind - Technical Architecture

## Game Concept
Interactive boids simulation where thousands of particles exhibit emergent flocking behavior through separation, alignment, and cohesion rules. Users interact as attractors/repulsors to influence the flock.

---

## 1. Core Structure

**Single HTML File Organization:**
```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Flock Mind</title>
  <style>/* Embedded CSS */</style>
</head>
<body>
  <canvas id="canvas"></canvas>
  <div id="controls"><!-- UI controls --></div>
  <script>/* All JavaScript */</script>
</body>
</html>
```

---

## 2. Rendering Strategy

**Canvas Setup:**
- Full viewport canvas: `canvas.width = window.innerWidth; canvas.height = window.innerHeight`
- 2D context with alpha for trails effect
- requestAnimationFrame loop at 60fps target

**Animation Loop:**
```javascript
function animate() {
  // 1. Clear with fade effect (trails)
  ctx.fillStyle = 'rgba(10, 10, 15, 0.15)';
  ctx.fillRect(0, 0, canvas.width, canvas.height);
  
  // 2. Update boid positions (physics)
  updateBoids();
  
  // 3. Render boids
  renderBoids();
  
  requestAnimationFrame(animate);
}
```

**Particle Drawing:**
- Small triangles pointing in velocity direction
- Color based on speed (cyan slow → magenta fast)
- Glow effect with ctx.shadowBlur

---

## 3. Boids Algorithm

**Core Data Structure:**
```javascript
class Boid {
  constructor(x, y) {
    this.position = {x, y};
    this.velocity = {x: random(-1, 1), y: random(-1, 1)};
    this.acceleration = {x: 0, y: 0};
    this.maxSpeed = 3;
    this.maxForce = 0.1;
  }
}
```

**Three Rules Implementation:**

**Separation** - Avoid crowding neighbors
```javascript
separation(boids) {
  const desiredSeparation = 25;
  const steer = {x: 0, y: 0};
  let count = 0;
  
  for (let other of boids) {
    const d = distance(this.position, other.position);
    if (d > 0 && d < desiredSeparation) {
      const diff = subtract(this.position, other.position);
      normalize(diff);
      divide(diff, d); // Weight by distance
      add(steer, diff);
      count++;
    }
  }
  
  if (count > 0) {
    divide(steer, count);
    normalize(steer);
    multiply(steer, this.maxSpeed);
    subtract(steer, this.velocity);
    limit(steer, this.maxForce);
  }
  return steer;
}
```

**Alignment** - Steer toward average heading
```javascript
alignment(boids) {
  const neighborDist = 50;
  const sum = {x: 0, y: 0};
  let count = 0;
  
  for (let other of boids) {
    const d = distance(this.position, other.position);
    if (d > 0 && d < neighborDist) {
      add(sum, other.velocity);
      count++;
    }
  }
  
  if (count > 0) {
    divide(sum, count);
    normalize(sum);
    multiply(sum, this.maxSpeed);
    const steer = subtract(sum, this.velocity);
    limit(steer, this.maxForce);
    return steer;
  }
  return {x: 0, y: 0};
}
```

**Cohesion** - Move toward average position
```javascript
cohesion(boids) {
  const neighborDist = 50;
  const sum = {x: 0, y: 0};
  let count = 0;
  
  for (let other of boids) {
    const d = distance(this.position, other.position);
    if (d > 0 && d < neighborDist) {
      add(sum, other.position);
      count++;
    }
  }
  
  if (count > 0) {
    divide(sum, count);
    return this.seek(sum);
  }
  return {x: 0, y: 0};
}
```

**Update Logic:**
```javascript
update(boids) {
  // Apply three rules
  const sep = this.separation(boids);
  const ali = this.alignment(boids);
  const coh = this.cohesion(boids);
  
  // Weight forces
  multiply(sep, 1.5);
  multiply(ali, 1.0);
  multiply(coh, 1.0);
  
  // Apply forces
  this.applyForce(sep);
  this.applyForce(ali);
  this.applyForce(coh);
  
  // Update velocity and position
  add(this.velocity, this.acceleration);
  limit(this.velocity, this.maxSpeed);
  add(this.position, this.velocity);
  multiply(this.acceleration, 0); // Reset
  
  // Wrap edges
  this.wrapEdges();
}
```

---

## 4. Spatial Optimization

**Problem:** O(n²) neighbor checks kill performance with 1000+ boids.

**Solution: Spatial Grid Hashing**

```javascript
class SpatialGrid {
  constructor(cellSize) {
    this.cellSize = cellSize;
    this.grid = new Map();
  }
  
  hash(x, y) {
    const col = Math.floor(x / this.cellSize);
    const row = Math.floor(y / this.cellSize);
    return `${col},${row}`;
  }
  
  clear() {
    this.grid.clear();
  }
  
  insert(boid) {
    const key = this.hash(boid.position.x, boid.position.y);
    if (!this.grid.has(key)) this.grid.set(key, []);
    this.grid.get(key).push(boid);
  }
  
  getNearby(boid, radius) {
    const nearby = [];
    const cellRadius = Math.ceil(radius / this.cellSize);
    const centerCol = Math.floor(boid.position.x / this.cellSize);
    const centerRow = Math.floor(boid.position.y / this.cellSize);
    
    for (let col = centerCol - cellRadius; col <= centerCol + cellRadius; col++) {
      for (let row = centerRow - cellRadius; row <= centerRow + cellRadius; row++) {
        const key = `${col},${row}`;
        if (this.grid.has(key)) {
          nearby.push(...this.grid.get(key));
        }
      }
    }
    return nearby;
  }
}
```

**Usage:**
```javascript
const grid = new SpatialGrid(50); // Cell size = neighbor detection radius

function updateBoids() {
  grid.clear();
  boids.forEach(b => grid.insert(b));
  
  boids.forEach(boid => {
    const nearby = grid.getNearby(boid, 50);
    boid.update(nearby); // Only check nearby boids
  });
}
```

**Performance Gain:** O(n²) → O(n) with typical distributions.

---

## 5. Interaction Model

**Mouse/Touch Controls:**

```javascript
let mousePos = {x: 0, y: 0};
let isPressed = false;
let interactionMode = 'attract'; // 'attract' | 'repel'

canvas.addEventListener('mousemove', (e) => {
  mousePos = {x: e.clientX, y: e.clientY};
});

canvas.addEventListener('touchmove', (e) => {
  e.preventDefault();
  mousePos = {x: e.touches[0].clientX, y: e.touches[0].clientY};
});

canvas.addEventListener('mousedown', () => isPressed = true);
canvas.addEventListener('mouseup', () => isPressed = false);
canvas.addEventListener('touchstart', () => isPressed = true);
canvas.addEventListener('touchend', () => isPressed = false);
```

**Force Application:**
```javascript
function applyInteractionForce(boid) {
  if (!isPressed) return;
  
  const d = distance(boid.position, mousePos);
  const radius = 150;
  
  if (d < radius) {
    const force = subtract(
      interactionMode === 'attract' ? mousePos : boid.position,
      interactionMode === 'attract' ? boid.position : mousePos
    );
    normalize(force);
    const strength = map(d, 0, radius, 0.5, 0); // Stronger when closer
    multiply(force, strength);
    boid.applyForce(force);
  }
}
```

---

## 6. Performance Strategy

**Frame Budget:** 16.67ms (60fps)

**Optimizations:**

1. **Spatial hashing** - Reduces neighbor checks from O(n²) to O(n)
2. **Object pooling** - Reuse vector objects instead of creating new ones
3. **Batch rendering** - Single path for all boids
4. **Fade trails** - Use translucent fillRect instead of clearRect
5. **Limit boid count** - Cap at 1500 on mobile, 2500 on desktop
6. **RAF throttling** - Skip frames if behind schedule

**Performance Monitoring:**
```javascript
let lastFrameTime = performance.now();
let fps = 60;

function animate() {
  const now = performance.now();
  const delta = now - lastFrameTime;
  fps = Math.round(1000 / delta);
  lastFrameTime = now;
  
  // Display FPS in corner
  ctx.fillStyle = '#00f0ff';
  ctx.font = '12px monospace';
  ctx.fillText(`${fps} fps | ${boids.length} boids`, 10, 20);
  
  // ... rest of animation
}
```

---

## 7. UI/UX Design

**Minimal Controls:**
```html
<div id="controls">
  <button id="modeToggle">Mode: Attract</button>
  <input type="range" id="boidCount" min="100" max="2000" value="800" step="100">
  <span id="countDisplay">800 boids</span>
  <button id="reset">Reset</button>
</div>
```

**Styling:**
```css
#controls {
  position: fixed;
  bottom: 20px;
  left: 50%;
  transform: translateX(-50%);
  background: rgba(10, 10, 15, 0.8);
  border: 1px solid #00f0ff;
  border-radius: 8px;
  padding: 15px 20px;
  display: flex;
  gap: 15px;
  align-items: center;
  backdrop-filter: blur(10px);
}

button {
  background: linear-gradient(135deg, #00f0ff, #ff00aa);
  border: none;
  padding: 8px 16px;
  border-radius: 4px;
  color: #fff;
  font-weight: 600;
  cursor: pointer;
  transition: transform 0.2s;
}

button:active {
  transform: scale(0.95);
}

input[type="range"] {
  width: 150px;
}
```

**Visual Feedback:**
- Cursor glow when pressed (attractor/repulsor visualization)
- Boid color shifts with speed
- Trail fade creates motion blur effect
- Subtle particle glow for depth

---

## 8. Visual Design

**Color Palette:**
- Background: `#0a0a0f` (dark space)
- Slow boids: `#00f0ff` (cyan)
- Fast boids: `#ff00aa` (magenta)
- UI accent: `#64ffda` (teal)
- Glow: `rgba(0, 240, 255, 0.3)`

**Particle Appearance:**
```javascript
function drawBoid(boid) {
  const speed = magnitude(boid.velocity);
  const speedRatio = speed / boid.maxSpeed;
  
  // Color gradient based on speed
  const r = Math.floor(speedRatio * 255);
  const g = 0;
  const b = Math.floor((1 - speedRatio) * 255);
  const color = `rgb(${r}, ${g}, ${b})`;
  
  // Glow effect
  ctx.shadowBlur = 8;
  ctx.shadowColor = color;
  
  // Draw triangle pointing in velocity direction
  const angle = Math.atan2(boid.velocity.y, boid.velocity.x);
  ctx.save();
  ctx.translate(boid.position.x, boid.position.y);
  ctx.rotate(angle);
  
  ctx.fillStyle = color;
  ctx.beginPath();
  ctx.moveTo(6, 0);
  ctx.lineTo(-3, 3);
  ctx.lineTo(-3, -3);
  ctx.closePath();
  ctx.fill();
  
  ctx.restore();
  ctx.shadowBlur = 0;
}
```

---

## 9. Code Structure

**Key Functions:**

```javascript
// Vector math utilities
function add(v1, v2) { v1.x += v2.x; v1.y += v2.y; }
function subtract(v1, v2) { return {x: v1.x - v2.x, y: v1.y - v2.y}; }
function multiply(v, scalar) { v.x *= scalar; v.y *= scalar; }
function divide(v, scalar) { v.x /= scalar; v.y /= scalar; }
function magnitude(v) { return Math.sqrt(v.x * v.x + v.y * v.y); }
function normalize(v) { const m = magnitude(v); if (m > 0) divide(v, m); }
function limit(v, max) { if (magnitude(v) > max) { normalize(v); multiply(v, max); } }
function distance(p1, p2) { return magnitude(subtract(p1, p2)); }

// Initialization
function createBoids(count) { /* ... */ }

// Update loop
function updateBoids() { /* ... */ }

// Rendering
function renderBoids() { /* ... */ }
function drawBoid(boid) { /* ... */ }

// Interaction
function applyInteractionForce(boid) { /* ... */ }

// UI handlers
function handleModeToggle() { /* ... */ }
function handleBoidCountChange(newCount) { /* ... */ }
function handleReset() { /* ... */ }
```

**Initialization:**
```javascript
const canvas = document.getElementById('canvas');
const ctx = canvas.getContext('2d');
let boids = [];
const grid = new SpatialGrid(50);

function init() {
  resizeCanvas();
  boids = createBoids(800);
  setupEventListeners();
  animate();
}

function resizeCanvas() {
  canvas.width = window.innerWidth;
  canvas.height = window.innerHeight;
}

window.addEventListener('resize', resizeCanvas);
window.addEventListener('load', init);
```

---

## 10. Implementation Notes

**Gotchas:**

1. **Vector mutation** - Be careful with in-place vector operations. Clone when needed.
2. **Edge wrapping** - Boids should wrap at canvas edges for infinite space feel.
3. **Mobile performance** - Reduce boid count on smaller viewports automatically.
4. **Touch events** - Always `preventDefault()` on touchmove to avoid scroll.
5. **Safari quirks** - Test shadowBlur performance; may need fallback.

**Best Practices:**

- Start with fewer boids (500) and tune up
- Test on mobile early - performance varies wildly
- Use `const` for vector utilities to enable inlining
- Profile with Chrome DevTools Performance tab
- Consider WebGL upgrade path if Canvas hits limits

**Expansion Path:**

Once core works, add:
- Obstacle drawing (boids avoid drawn shapes)
- Predator mode (red boid chases others)
- Flock presets (schools, murmurations, swarms)
- Recording/replay
- Particle trails toggle
- Wind forces
- Multiple flock types with different behaviors

---

## Summary

**Tech Stack:** Pure HTML5 Canvas + JavaScript  
**Target Performance:** 60fps with 1000+ boids  
**Key Innovation:** Spatial grid optimization + emergent beauty  
**Mobile-First:** Touch controls, responsive, adaptive particle count  

Ready for Phase 4: Implementation by builder agent.
