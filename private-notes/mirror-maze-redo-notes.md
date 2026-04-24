# Mirror Maze Redo - Design Notes

## Date: 2026-03-24

## What was there before
- Canvas/JS laser beam puzzle game with "Harmonic Resonance" mechanic
- 5 levels, mirrors you rotate, beams reflect, hit targets
- No WASM, pure JS/HTML5 Canvas, ~35KB single file

## What the issue says
- Start from scratch
- Make something "interesting and useful"
- Sort of fits with the name
- Use WASM

## Brainstorming

### What does "Mirror Maze" suggest?
- Reflection, mirrors, optical puzzles
- Mazes / navigation / paths
- The concept of mirrors in a maze (like you'd see in a funhouse or hedge maze)

### "Interesting and useful" -- what could that be?
- A raytracing / optics simulator? Educational/useful
- A light path puzzler with WASM physics
- A maze generator/solver visualizer where cells use mirrors to redirect "light"
- A tool to design optical circuits (like fiber optics / mirrors bouncing signals)
- A Sokoban-like puzzle with light rays
- An actual useful tool: a maze generator where instead of walls, you use mirrors
  - "Optical Maze" - navigate a laser through a maze using mirrors
  - Could be used to understand light reflection concepts

### WASM angle - what should be in WASM?
Options:
1. Rust WASM for maze generation + beam path solving
2. C compiled to WASM for performance-critical raycast
3. AssemblyScript (TypeScript-like → WASM)

### My decision: Rust WASM (wasm-pack) + HTML/JS frontend

**Concept: Mirror Maze Optical Puzzle Game & Solver**
- User-controlled: Place mirrors in a grid to route a laser beam from source to target
- WASM core handles: maze layout generation, beam path tracing, collision detection, puzzle solving hints
- Frontend: Canvas rendering

But wait - do I have Rust / wasm-pack on this machine?

Let me check tooling availability first, then decide on approach.

### Alternative if no Rust: Emscripten/C or pre-compiled WASM binary
- Or: Write a small WASM module in WAT (WebAssembly Text Format) directly
- WAT is verbose but gives full control without needing a compiler

### Plan B: C + Emscripten or just write WAT manually
- For the beam tracing algorithm (the computationally intensive part)
- Keep the maze/puzzle logic in WASM

### What I'll actually build:
**"Mirror Maze" - Optical Path Puzzle**

Core design:
- Grid-based puzzle where you place/rotate mirrors to direct laser beams
- WASM module handles the beam tracing algorithm (C/WAT or Rust)
- Multiple puzzles with increasing complexity
- Actually the "useful" angle: Can be used as an educational optics demonstrator
  - Shows angle of incidence = angle of reflection
  - Can visualize multiple bounces
  - Has a "free play" mode where you can explore optics freely

**The WASM part specifically:**
- Beam tracing algorithm (ray casting through the grid, computing reflections)
- Puzzle validation (checking if all targets are hit)
- Level generation (procedural puzzle generation)

### Architecture Plan:
1. Write beam tracer in C, compile with Emscripten
   - OR write in pure WAT (WebAssembly Text)
   - OR use a pre-existing WASM approach
2. JS frontend for rendering and UI

Let me check if Emscripten or Rust is available...

### Decision based on tooling:
- If `emcc` available: write C, compile to WASM
- If `cargo` + `wasm-pack` available: use Rust
- If neither: write WAT manually (verbose but works)
- If `wat2wasm` available: write WAT

### What to put in WASM vs JS:
**WASM (performance/logic critical):**
- Grid state management
- Beam path tracing (ray-mirror intersection math)
- Puzzle solution validation
- Puzzle generation/seed-based randomization

**JS:**
- Canvas rendering
- User input (mouse/touch)
- UI state (menus, level selection)
- localStorage persistence

### The "useful" angle - important to nail this:
Make it educational. Add an "optics lab" mode:
- Shows angle of incidence markers
- Shows number of reflections
- Students/curious people can experiment with mirror optics
- Could also serve as a game for teaching Snell's law / reflection law

### Refined concept:
**Mirror Maze - Interactive Optics Laboratory**
- Game mode: Puzzles to solve
- Lab mode: Free experimentation 
- The maze angle: Generated puzzle grids that look like mazes (but made of light paths)
- WASM powers the physics engine

### Level design thoughts:
- Start simple: 2-3 mirrors, clear path
- Increase: More mirrors needed, multiple light sources, targets
- Special elements: Beam splitters, color filters, prisms
  - Maybe too complex for v1
- Keep it to: Mirrors (45° reflectors), Targets, Walls, possibly Beam Splitters

### Visual style:
- Dark background (space/lab feel)
- Laser beams with glow effect
- Different beam colors for different sources
- Smooth animations
- Clean, modern UI

### Files to create:
- `index.html` - Main game file
- `wasm/beam_tracer.wat` or `wasm/beam_tracer.c` + compiled `.wasm`
- OR: all in one self-contained HTML with inline WASM (base64 encoded)

### Self-contained single file approach:
For maximum portability (like the original), embed WASM as base64 in the HTML.
This way: single `index.html` that has everything including WASM.

The WASM binary would be small (just the beam tracing logic), base64 encode it and put in HTML.
JS instantiates it at startup.

### Writing the WASM:
I'll write it in WAT (WebAssembly Text format) since that's pure text and I can create it without a compiler.
Or better: write it as a minimal C-like logic and compile if tools available, otherwise use wat2wasm.

Let me check tooling first, then proceed.

## Refinement - Final Plan

After thinking more, here's exactly what I'll build:

**Mirror Maze: A WASM-Powered Light Routing Puzzle**

Key differentiators from the old version:
1. WASM core for all physics/logic (not just "uses WASM" as a gimmick - actually does the hard work there)
2. More authentic maze aesthetic - feels like you're navigating a maze, but with light
3. "Useful" angle: Educational optics simulator with angle measurements displayed
4. Better puzzle variety with different mirror types

WASM module exports:
- `init_grid(width, height)` - Initialize puzzle grid in WASM memory
- `set_cell(x, y, type, angle)` - Set a cell in the grid  
- `get_cell(x, y)` - Get cell type/angle
- `trace_beams(source_x, source_y, direction)` - Trace all beams, return path data
- `check_solved()` - Returns 1 if all targets hit
- `generate_puzzle(seed, difficulty)` - Generate a puzzle

The WASM module manages shared memory with JS for efficiency.

Memory layout:
- Cells: 4 bytes each (type, angle, flags, reserved)
- Grid: up to 20x20 = 400 cells = 1600 bytes
- Beam paths: up to 1000 path segments × 4 bytes each = 4000 bytes
- Total: ~6KB of memory

Cell types (in WASM constants):
- 0: Empty
- 1: Wall
- 2: Mirror / (45° NE)
- 3: Mirror \ (45° NW)  
- 4: Source (laser origin)
- 5: Target (needs to be hit)
- 6: Beam splitter
- 7: Double-sided mirror (both / and \)

I'll write this in C first if emcc is available, WAT if not.

## Implementation notes

### WAT approach (if no compiler available):
Write minimal WAT that:
1. Has a flat array for grid (using i32.store/load)
2. Has a recursive beam tracing function
3. Exports the key functions

The WAT file will be ~200-300 lines, which is manageable to write by hand.
Then instantiate it via `WebAssembly.instantiate()` in JS with inline base64.

Actually, writing WAT by hand for a recursive algorithm is complex.
Better approach: Write the WASM binary generation in JS (at build time), or...

### Better approach: Use AssemblyScript-style manual WASM compilation
OR just hand-craft the WAT for the core algorithm.

Actually the cleanest approach for "single file WASM" without tooling:
1. Write algorithm in C (simple enough to be clear)
2. If emcc available, compile → base64 → embed
3. If not, write equivalent WAT manually

The C code would be about 150 lines. The WAT equivalent about 400-500 lines.
WAT is doable but tedious.

### Most pragmatic approach:
Check for wat2wasm (wabt), emcc, cargo+wasm-pack.
If any available, use it.
If nothing, write a small but complete WAT module manually.

The WAT approach actually might be best anyway for a "no dependencies" self-contained demo.
