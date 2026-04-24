# Architecture: Neural Knot Untangler

## 1. Component Structure (Vue 3)
- **App.vue**: Main container, handles initialization and state provision.
- **NodeGraph.vue**: Renders the 3D nodes and edges.
  - **Node.vue**: Individual neural node with reactive styling.
  - **Edge.vue**: Connection pathways between nodes.
- **UIOverlay.vue**: HUD elements, score, progress.
- **Tooltip.vue**: Educational concepts about neural networks.
- **Controls.vue**: Touch/mouse input handling overlay.

## 2. State Management (Reactive Network Graph)
Using Vue 3 `ref` and `reactive`:
- `nodes`: Array of objects `{ id, x, y, z, active, connections, type }`
- `edges`: Array of objects `{ id, sourceNodeId, targetNodeId, signalStrength, crossed }`
- `gameState`: `{ level, score, isUntangled, difficulty }`
- Signals flow through nodes. Untangling removes 'crossed' state from edges.

## 3. Key Algorithms
- **3D Rendering**: CSS 3D transforms (`transform: translate3d`) on HTML elements simulating a 3D space, rotated via touch drag.
- **Collision Detection**: 2D projection intersection tests for edges to determine if they overlap (cross) on the camera plane.
- **Path Optimization**: A* or simple shortest path to calculate optimal signal flow once nodes are untangled.

## 4. CSS Reactivity Experiments
- Bind Vue state to inline styles as CSS Custom Properties: `style="--x: ${node.x}px; --color: ${node.color}; --glow: ${node.glowStrength}"`.
- CSS uses `var(--x)` for positioning and `box-shadow` for pulse effects. This reduces DOM updates and relies on hardware-accelerated CSS.

## 5. Mobile-first Touch Controls
- Pointer Events (`pointerdown`, `pointermove`, `pointerup`) to universalize touch and mouse.
- Dragging a node moves it in the 2D plane parallel to the camera.
- Two-finger swipe rotates the 3D space.

## 6. Content Expansion Plan
- Levels: Feed-forward, Recurrent, Convolutional layout patterns.
- Mechanics: Nodes with delays, activation thresholds, inhibitory connections.

## 7. File Structure (Self-contained)
All enclosed within `2026-02-23-neural-knot-untangler.html`.
Includes `<style>`, `<script src="vue.js">` and app logic.
