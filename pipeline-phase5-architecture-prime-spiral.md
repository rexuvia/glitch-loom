# Phase 5 · Technical Architecture — Prime Spiral

**Concept recap:** Interactive visualization that plots prime numbers across Ulam and Sacks spirals (square lattice and polar spiral respectively). Users explore emergent patterns via zoom, pan, color encodings, and annotation toggles. A daily math-to-art experience that fuses education with hypnotic visuals.

---

## 1. Targets & Constraints
- **Single self-contained HTML file** (no external build step), optimized for mobile + desktop.
- **Responsive performance** up to ~2M plotted integers (dynamic level-of-detail).
- **Interaction:** pinch/scroll zoom, drag pan, tap to toggle overlays (prime density heatmap, twin prime highlights).
- **Daily seed:** deterministic color scheme seeded from current date (for variety).
- **Accessibility:** colorblind-safe palette options, textual annotations.

---

## 2. Coordinate Systems
### Ulam Spiral (square lattice)
- Map integers to lattice positions via iterative corner stepping (right, up, left*2, down*2, right*3, ...)
- Use integer spiral algorithm to avoid storing entire grid.
- Precompute prime positions in batches (e.g., 10k integers per frame) for incremental rendering.

### Sacks Spiral (polar)
- For each integer n, angle θ = n · 2π / φ (golden angle variant) or θ = √n; radius r = √n (classic Sacks).
- Convert polar → Cartesian: x = r cos θ, y = r sin θ.
- Normalize coordinates to viewport via scale factor tied to zoom level.

---

## 3. Rendering Strategy
- Canvas 2D (fast enough with batching).
- Use **OffscreenCanvas** when available; fallback to main canvas otherwise.
- Layered rendering:
  1. **Background** gradient (date-seeded hues).
  2. **Prime points** (circles with glow).
  3. **Overlays** (twin primes, density heatmap squares, annotations).
  4. **HUD text** (FPS, current range, instructions).
- Batched draw calls using `ctx.beginPath()` + `ctx.arc()` aggregations before fill/stroke.

---

## 4. Data Pipeline
1. **Prime Generation:** Incremental Sieve of Eratosthenes.
   - Maintain rolling sieve window (chunks of 50k numbers).
   - Store primes in typed array (Uint32Array) for memory efficiency.
2. **Coordinate Cache:** For each zoom level bucket, cache normalized coordinates to avoid recomputing when returning to previous zoom.
3. **Level of Detail (LOD):**
   - Determine integer step based on zoom: e.g., skip every k-th prime when zoomed out.
   - Smooth transitions by blending alpha of skipped primes.
4. **Twin Prime Detection:** Precompute pairs (p, p+2) within current range; render connecting segments when overlay enabled.
5. **Density Heatmap:** Bin primes into grid cells (e.g., 64x64). Use counts to drive alpha of translucent squares.

---

## 5. Interaction Model
- **Pan:** Track pointer/touch drag, update `offsetX`, `offsetY` used in drawing transforms.
- **Zoom:** Mouse wheel + pinch (gesture). Update `scale` with damping; clamp between min/max.
- **Tap UI:** Floating buttons bottom-right toggle overlays, reset view, switch spiral mode.
- **Mode Switch:** Buttons to choose Ulam or Sacks; maintain separate caches but share UI.
- **Animation:** Smooth transition when switching modes (crossfade using dual canvases).

```javascript
let mode = 'ulam'; // or 'sacks'
let scale = 1;
let offsetX = 0;
let offsetY = 0;
let targetScale = 1;

function animate() {
  scale += (targetScale - scale) * 0.2; // smooth zoom
  render();
  requestAnimationFrame(animate);
}
```

---

## 6. Performance Notes
- **Frame Budget:** 16ms target. Use incremental prime generation to avoid stalls.
- **Worker Threads:** Web Worker for sieve + coordinate prep, posting batches to main thread.
- **Memory:** Limit to ~200k primes in memory simultaneously; older ones evicted when zoomed into small ranges.
- **Culling:** Skip drawing primes outside viewport bounds after applying scale/offset.
- **FPS Monitor:** Adaptive throttling—reduce per-frame batch or apply decimation when FPS < 45.

---

## 7. Visual Design
- **Palette:**
  - Background gradient seeded from date: `hue = (dayOfYear * 3) % 360`
  - Prime dots: base cyan/magenta gradient by magnitude.
  - Twin primes: neon yellow connectors.
  - Density heatmap: translucent indigo squares.
- **Glow:** apply `ctx.shadowBlur` selectively; disable when FPS drops.
- **Typography:** Orbitron for HUD headings, Inter for labels.
- **HUD Layout:** top-left instructions, top-right stats (range, prime count, FPS), bottom controls.

---

## 8. UI Components
- `#hud` div: instructions, stats.
- `#controls` div: overlay toggles, mode switch, reset.
- Tooltip on tap: display integer value & classification (prime, twin, part of prime triple).
- Accessibility toggle for colorblind palette in `#controls`.

---

## 9. File Structure
Since single HTML file, embed CSS + JS.
- `<style>` defines layout, HUD, neon aesthetic.
- `<canvas id="primeCanvas">` fills viewport.
- `<div id="hud">` and `<div id="controls">` absolutely positioned.
- `<script>` includes utility modules (sieve, LOD, rendering, interaction) in IIFE to avoid globals.

---

## 10. Deployment Checklist
- Test mobile pinch/zoom responsiveness.
- Verify performance on mid-range Android (simulate 4x slowdown).
- Check colorblind palette via Chrome DevTools filters.
- Ensure date seeding rotates colors daily.
- Validate LOD transitions (no popping).
- Confirm fallbacks when OffscreenCanvas not supported.
- Minify whitespace before final save (optional).

---

**Ready for Phase 6: Collaborative Build (Grok primary, Sonnet for refinement).**
