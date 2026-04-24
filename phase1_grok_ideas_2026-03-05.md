# Phase 1 Grok Ideation Results - 2026-03-05

## 5 Unique Mini-App Ideas

---

### 1. Gravity Canvas
**Category:** Interactive Art / Physics Toy

**Description:** Paint with gravitational fields—drop color-emitting particles and sculpt their trajectories by placing attractors and repulsors that bend space itself.

**Why It's Interesting:**
This inverts traditional drawing: instead of direct mark-making, you design *rules* that create emergent beauty. The result is mesmerizing orbital patterns, chaotic slingshots, and delicate equilibrium spirals that evolve over time. It teaches gravitational intuition while producing genuinely stunning abstract art you'd want as a wallpaper.

**Technical Approach:**
- N-body gravitational simulation (simplified Barnes-Hut or direct for <500 particles)
- Canvas 2D with motion trails via fading/compositing
- Attractor/repulsor placement with adjustable mass
- Color inheritance based on velocity magnitude (doppler-style shifting)

**Content Expansion Plan:**
- Presets: "Binary Star," "Galaxy Collision," "Slingshot Painter"
- Challenges: Create a stable orbit, paint a target shape, achieve symmetry
- Export as looping GIF or SVG path
- Multi-user mode: two people place attractors competitively

---

### 2. Vowel Prism
**Category:** Music/Audio / Data Viz

**Description:** Speak into your microphone and watch your voice decomposed into a real-time 3D formant space where vowels bloom as distinct colored regions.

**Why It's Interesting:**
Most people have no idea their voice contains rich harmonic structure that linguists map onto "formant charts." This makes the invisible visible—you can literally *see* the difference between "ee" and "oo," watch accents shift position, and discover that singing vowels trace continuous paths through sound-space. It's scientifically grounded yet feels like magic.

**Technical Approach:**
- Web Audio API for microphone input
- LPC (Linear Predictive Coding) or FFT peak-picking for F1/F2/F3 formant extraction
- Three.js for 3D point cloud / trajectory visualization
- Color mapping vowels to IPA chart regions

**Content Expansion Plan:**
- Accent comparison mode (overlay your formants against British RP, Southern US, etc.)
- Singing trainer: hit target vowel regions to score points
- Record and playback formant trajectories as "voice sculptures"
- Language learner mode: practice foreign vowels by matching native speaker clouds

---

### 3. Rust Garden
**Category:** Simulation / Experience

**Description:** Cultivate a procedural ecosystem of crystalline structures that grow, compete, oxidize, and decay across a metallic substrate over accelerated time.

**Why It's Interesting:**
This is anti-gardening: you're not nurturing life, you're witnessing entropy made beautiful. Watch copper verdigris creep, iron bloom into rust fractals, and crystals fight for territory like slow-motion warfare. It's oddly calming—a memento mori for the material world that runs itself while you watch. No win condition, just the poetry of decay.

**Technical Approach:**
- Cellular automaton with multi-state rules (metal, oxide, crystal, void)
- Reaction-diffusion for organic spread patterns
- WebGL shaders for metallic material rendering (PBR-lite)
- Time-lapse controls: 1x to 10000x speed

**Content Expansion Plan:**
- Different substrates: copper, iron, silver, alloys with unique decay signatures
- Environmental controls: humidity, salt air, acid rain
- "Archaeology mode": bury artifacts and excavate after simulated centuries
- Community gallery of particularly beautiful decay states

---

### 4. Chord Phantom
**Category:** Creative Tool / Music

**Description:** Hum or whistle any melody and watch the app conjure ghost chords beneath it—generating harmonically plausible accompaniments in real-time that you can accept, reject, or nudge.

**Why It's Interesting:**
This solves a real creative problem: you have a melody in your head but no theory knowledge to harmonize it. Unlike AI composition tools that generate everything, this keeps *you* as the melodic author while providing intelligent harmonic scaffolding. It's genuinely useful for songwriters, and the "ghost" visualization (translucent chord tones appearing and fading) makes the process feel like collaboration with a spectral musician.

**Technical Approach:**
- Pitch detection via autocorrelation or CREPE-style ML model (TensorFlow.js)
- Rule-based + probabilistic chord suggestion (Markov chains trained on common progressions)
- Web Audio synthesis for chord playback
- MIDI export for DAW integration

**Content Expansion Plan:**
- Genre modes: jazz voicings, folk triads, neo-soul extensions
- "Ghost ensemble": add bass lines, counter-melodies as additional phantoms
- Collaboration: two people hum, app finds chords that satisfy both
- Theory overlay: show chord numerals and explain *why* each choice works

---

### 5. Ink Tides
**Category:** Puzzle / Interactive Art

**Description:** Guide droplets of colored ink through a fluid simulation to reach target zones, but the only controls you have are placing obstacles and tilting gravity—the ink has a mind of its own.

**Why It's Interesting:**
Fluid puzzles are rare because fluid simulation is hard and chaotic—which is exactly what makes this compelling. You can't micromanage; you must think in flows, eddies, and pressure gradients. Solutions feel discovered rather than solved. The ink mixing creates accidental beauty even in failure, and the emergent physics means no two runs play identically. It's a puzzle that rewards intuition over brute force.

**Technical Approach:**
- SPH (Smoothed Particle Hydrodynamics) or LBM (Lattice Boltzmann) fluid sim
- WebGL compute shaders or WASM for performance
- Obstacle placement with SDF (signed distance fields) for smooth boundaries
- Tilt = gravity vector rotation

**Content Expansion Plan:**
- Levels: simple basins → branching channels → time-pressure mixing challenges
- Ink properties: viscosity, density, surface tension as variables
- "Sandbox" mode for pure play
- Daily challenge with leaderboard based on ink efficiency (least wasted)

---

*These ideas avoid overlap with existing apps (no flocking, cellular automata music, synth pads, sorting viz, tetris variants, narrative branching, wave function collapse, or memory techniques). Each offers genuine utility or meditative depth rather than one-trick gimmicks.*

**Stats:** runtime 41s • tokens 1.4k (in 5 / out 1.3k) • prompt/cache 14.7k