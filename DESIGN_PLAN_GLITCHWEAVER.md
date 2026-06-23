# GLITCHWEAVER — Design Plan

**A genetic-algorithm sidescroller that fuses Glitch Loom (visual glitch-art weaving) and Melody Explorer (microtonal melody synthesis) into a single audiovisual evolution game.**

Working title: **GLITCHWEAVER** (alt: *Loomstrand*, *Genome Drift*, *Weave & Wail*).

Version: 1.0 design draft · Author: Rexuvia · Target: single-file HTML/JS/CSS, mobile-first, no dependencies (consistent with both source games).

---

## 1. The Core Insight

The two source games are secretly the **same game** wearing different skins:

| | Glitch Loom | Melody Explorer |
|---|---|---|
| **Genome** | sorting metric + datamosh effect + weave pattern + generator + palette (per strand) | 6 frequencies (Hz) + 6 inter-note delays (ms) + waveform |
| **Phenotype** | a woven glitch tapestry (visual) | a 6-note melodic sequence (audio) |
| **Evaluation** | the maker's eye ("does this look good?") | a 0–10 rating slider ("does this sound good?") |
| **Output** | PNG / GIF export | JSON export of rated genomes |

Both are **parameter-genome → render-phenotype → human-judges-fitness** loops. They already collect exactly the data a genetic algorithm needs (Melody Explorer literally exports rated genomes as JSON). GLITCHWEAVER turns that latent GA loop into an *explicit, playable* one, and wraps it in a sidescroller so that **moving through space = moving through the genetic search space**.

**One unified genome drives BOTH a visual tapestry AND a melody simultaneously.** A "strand" is now an audiovisual gene: it weaves a glitch pattern *and* sounds a note. The tapestry you see is the spectrogram of the song you hear, and vice versa. That synesthetic coupling is the game's signature.

---

## 2. Design Pillars

1. **One genome, two senses.** Every creature/level/segment is a single genome that renders as glitch-weave visuals AND microtonal audio. They are never decoupled.
2. **Movement = search.** The sidescroller axis IS the genetic algorithm's exploration. Drifting right advances generations; vertical lanes are alleles; the player steers selection pressure.
3. **The player is the fitness function (early) → the player trains a fitness function (late).** You start by rating with your own taste; the game learns your taste and lets you delegate, automate, and surprise yourself.
4. **Diff over absolutes.** Fun comes from *mutation deltas* — the satisfying "oh, that one tweak made it sing/shimmer." Telegraph what each gene change does.
5. **Single file, zero deps, mobile-first.** Inherited hard constraint from both source games. Canvas 2D + Web Audio API only. Touch-first controls.

---

## 3. The Unified Genome

A genome is a fixed-length vector of **N strands** (default N=6, echoing Melody Explorer's 6 notes and giving a 6-lane sidescroller). Each strand carries audiovisual genes:

```
Strand i {
  // --- AUDIO genes (from Melody Explorer) ---
  freq      : float  // 100–8000 Hz, log2-uniform encoded as 0..1
  delay     : float  // 100–400 ms before next note
  waveform  : enum   // sine | triangle | square | sawtooth
  envelope  : float  // attack/release shaping 0..1

  // --- VISUAL genes (from Glitch Loom) ---
  sortMetric  : enum  // brightness | hue | saturation | R | G | B
  sortThresh  : float // span detection threshold 0..1
  moshType    : enum  // blockDisplace | channelShift | pixelRepeat | feedback
  moshAmount  : float // intensity 0..1
  generator   : enum  // gradient | noise | geometric | plasma | fractal
  hue         : float // palette anchor 0..1 (0..360°)

  // --- SHARED / COUPLING genes ---
  weave    : enum  // plain | twill | satin | herringbone  (warp/weft topology)
  orient   : enum  // warp (vertical) | weft (horizontal)
}
```

### 3.1 The Synesthetic Coupling (the heart of the fusion)

The genome is rendered through a **single mapping layer** so audio and visuals are not independent — they are two projections of one vector. Default couplings (all overridable as the game's "rules of physics"):

- `freq` ↔ vertical position of the strand on the loom **and** the pitch you hear. High note = high strand.
- `delay` ↔ horizontal spacing of the weft floats **and** the rhythm. Tight rhythm = dense weave.
- `hue` ↔ palette color **and** stereo pan / timbre brightness (warm hue = warmer waveform bias).
- `moshAmount` ↔ visual datamosh intensity **and** audio distortion / detune wobble. A glitchy-looking strand sounds glitchy.
- `sortMetric` ↔ how pixels cascade **and** note ordering (ascending/descending arpeggiation of the strand's micro-notes).
- `weave` topology ↔ how strands *interleave* visually **and** how their notes overlap/counterpoint in time.

> Net effect: **the tapestry is a score and the score is a tapestry.** Look at a level and you can roughly hum it; hear a melody and you can sketch its weave.

### 3.2 Encoding

All genes normalized to `0..1` floats internally for clean crossover/mutation; enums are quantized buckets of that float. This makes the genome a flat `Float32Array(N * 12)` — cheap to mutate, crossover, serialize, and diff. Serialization is the **state string** (base64 of the Float32Array), reusing Melody Explorer's "generate a new state string on save" pattern for shareable seeds and resume.

---

## 4. The Sidescroller, Reframed as a GA

The screen is a **horizontally scrolling loom** that the player flies/weaves through.

### 4.1 Spatial = Genetic mapping

- **Horizontal scroll (X) = generations / time.** As you move right, you advance through the search. The world is procedurally woven ahead of you from the current population.
- **Vertical lanes (Y) = the N strands / alleles.** With N=6 strands you have 6 lanes. The avatar ("the **Shuttle**" — a weaving-loom shuttle) occupies one lane at a time and can dart between lanes.
- **The on-screen tapestry behind the Shuttle IS the rendered phenotype of the current genome**, woven in real time as you advance. The soundtrack playing IS that same genome's melody, looping per generation.

### 4.2 The Population

At any moment a small population (default 8 genomes) exists. The world ahead is generated by rendering candidate genomes as **"glyph gates"** — visual+audio chunks the Shuttle flies toward. Each gate is one candidate offspring.

### 4.3 The Core Loop (one "generation")

```
1. SEED      — current best genome(s) render the active tapestry + melody (the "home" weave).
2. SPAWN     — GA produces 8 offspring via crossover+mutation of the parent pool.
               Each offspring is a GATE ahead in the scroll, previewed visually (its
               weave) and sonically (a short audio sting when it nears).
3. STEER     — player flies the Shuttle through the lane(s) toward the gate(s) they like,
               collecting/selecting them. Steering = applying selection pressure.
4. EVALUATE  — selected gates get a fitness signal (see §5). Hazards/decay penalize.
5. BREED     — top genomes become parents; population re-pooled.
6. SCROLL    — world advances one generation; the home tapestry visibly mutates toward
               what the player has been selecting. Repeat.
```

Every generation, the **persistent tapestry on the left edge grows** — a literal woven record of the run, like Melody Explorer's history table but as art. By end of a run you've woven a unique piece *and* composed a unique track, both export-able (PNG/GIF + WAV/JSON), inheriting both source games' export features.

---

## 5. The Fitness Function — three escalating modes

This is where the "exploration game" gets its depth. Fitness evolves from manual → assisted → autonomous, giving a difficulty/mastery curve.

### Mode A — Hand-Weaver (early game, pure Melody-Explorer-style rating)
The player IS the fitness function. Flying through a gate = implicitly rating it. Optional explicit 0–10 rating (slider/quick-tap) for gates you linger on, exactly like Melody Explorer's slider. Selected genomes breed; ignored ones die. Teaches the player the gene→phenotype mappings.

### Mode B — Loom-Sense (mid game, learned surrogate fitness)
The game trains a tiny **surrogate fitness model** on the player's accumulated ratings (a simple linear/logistic regressor or k-NN over the normalized genome vector — trivially implementable in JS, no ML libs). It begins **predicting** which gates you'll like and highlights them (a shimmer/aura). The player can:
- **Trust** it (auto-collect predicted-good gates → faster scrolling, combo bonus), or
- **Defy** it (manually pick something it rated low → if you then rate it high, the model retrains and you earn "Surprise" score — rewarding novelty/exploration over exploitation).

This is the literal "genetic algorithm + learned fitness" exploration mechanic, and it gamifies the explore/exploit tradeoff.

### Mode C — Autoloom (late game / endless / "ascension")
The player sets **high-level objectives** instead of rating individuals — e.g. "maximize hue diversity," "minimize rhythmic entropy," "evolve toward consonance," "max datamosh chaos." The GA + surrogate run semi-autonomously; the player's job shifts to **steering meta-parameters** (mutation rate, selection pressure, niche/diversity pressure) in real time via the cockpit, dodging hazards while the loom evolves itself. It becomes a "gardener of an evolving system" game.

---

## 6. GA Mechanics, Made Tactile

Abstract GA operators are surfaced as **player-facing verbs / power-ups** so the algorithm is the gameplay, not hidden plumbing.

| GA operator | In-game form | Player feel |
|---|---|---|
| **Mutation** | "Glitch Bursts" — flying through a datamosh storm randomly perturbs genes | risk/reward chaos |
| **Mutation rate** | a cockpit dial ("Entropy") | crank it for wild exploration, lower for fine-tuning |
| **Crossover** | "Splice Gates" — fly through two gates close together to breed them mid-air | deliberate combination |
| **Selection pressure** | scroll speed / lane width | faster = harsher selection, only the loved survive |
| **Elitism** | "Anchor" a beloved genome to the persistent tapestry so it can't be lost | safety |
| **Diversity / niching** | "Prism" power-up forces dissimilar offspring | escape local optima |
| **Fitness** | rating gates + surrogate (see §5) | your taste, learned |
| **Generations** | distance traveled / biome milestones | progress |

**Telegraphing deltas (Pillar 4):** when a gate is an offspring, the HUD shows a tiny **gene-diff strip** vs. the parent — which 1–3 genes mutated, shown as before→after micro-swatches + a 2-note audio diff. This makes "what changed and why it matters" legible, which is the single biggest UX risk for a GA game.

---

## 7. Structure: Biomes & Progression

The endless scroll is punctuated by **Biomes** — each biome locks/weights the search toward a region of genome space, reusing Glitch Loom's 17 presets and Melody Explorer's frequency bands as named destinations.

Example biome arc (each ~one "level"):
1. **Cyberpunk Foundry** — channel-shift moshing, neon palette, midrange melodies. Tutorial biome (Hand-Weaver mode).
2. **Vaporwave Tides** — satin weave, pastel gradients, slow consonant melodies. Introduces surrogate (Loom-Sense).
3. **Inferno Spindle** — high mutation, fractal generators, dissonant high freqs. Hazard-heavy.
4. **Aurora Drift** — diversity/niching focus; rewards exploration breadth.
5. **The Open Loom (endless)** — Autoloom mode; player-defined objectives; leaderboard for most "beautiful" (surrogate-scored) + most "novel" (diversity-scored) tapestries.

Biome transitions = a **woven-piece "checkpoint"**: the current best genome is committed to the gallery and becomes the seed for the next biome (carrying inheritance forward — literal generational continuity across levels).

---

## 8. Controls (mobile-first, inherited constraint)

- **Drag / tilt or swipe up-down** → move Shuttle between lanes (steer selection).
- **Tap / hold** → collect/select gate; hold to open quick-rate radial (0–10).
- **Two-finger pinch or cockpit dials** → adjust Entropy (mutation rate) & Selection pressure.
- **Dedicated buttons** → Anchor (elitism), Splice (crossover), Prism (diversity).
- Desktop: arrow/WASD lanes, mouse for gate select, number keys 0–9 for instant rating (reuse Melody Explorer's keyboard-rating pattern), space = play/replay current genome's melody.

Audio respects the iOS/Safari **first-tap unlock** requirement (carried from Melody Explorer's known constraint).

---

## 9. Audiovisual Rendering Pipeline

Reuse and merge the existing engines (both already pure-JS, Canvas2D + Web Audio):

**Visual (from Glitch Loom):**
- Each strand → procedural generator (gradient/noise/geometric/plasma/fractal) → pixel-sort by metric/threshold → datamosh effect → composited via weave topology onto an OffscreenCanvas → blitted as the scrolling background tapestry.
- Performance: render genomes to small OffscreenCanvas tiles, cache per-genome, scroll as textured quads. Only re-render a tile when its genome mutates. GIF export reuses Glitch Loom's pure-JS LZW encoder.

**Audio (from Melody Explorer):**
- Each strand → OscillatorNode(waveform) at `freq`, scheduled with `delay`, 20ms attack / 35ms sustain / 60ms release envelope (no clicks). The N strands of a genome = one looping bar.
- The "active genome" loops as the soundtrack; gates emit short stings as they approach (spatialized by lane via StereoPannerNode).
- WAV export via offline render of the winning genome; JSON export of the full rated population (reuse Melody Explorer's export schema, extended with visual genes).

**Coupling layer (new):** a single `renderGenome(g)` that both `drawTapestry(g, ctx)` and `playMelody(g, audioCtx)` consume, guaranteeing the synesthetic link from §3.1.

---

## 10. Scoring & Meta

- **Beauty score** — surrogate-fitness of genomes you committed (rewards exploitation).
- **Novelty score** — genome-space diversity of your gallery (rewards exploration). Explicit explore/exploit dual scoring.
- **Surprise** — times you defied the surrogate and were right (it retrained).
- **Run artifact** — every run outputs: a woven PNG/GIF tapestry + a WAV/JSON track. Shareable via the base64 state string (one URL re-seeds the whole run).
- **Gallery / dailies** — daily seed challenge (same starting genome for everyone; leaderboard by beauty & novelty), fitting the existing Rexuvia daily-game cadence.

---

## 11. Technical Plan (single file, no deps)

```
index.html (single file, ~mobile-first, CSS custom props, dark neon aesthetic — matches both games)
├─ Genome module      : Float32Array(N*12), encode/decode/serialize(base64 state string)
├─ GA module          : mutate(rate), crossover, select(topK), niching/diversity metric
├─ Surrogate module   : linear/logistic or k-NN over normalized genome; train(ratings), predict()
├─ Visual engine      : port of Glitch Loom (generators, pixel sort, datamosh, weave, GIF/PNG export)
├─ Audio engine       : port of Melody Explorer (oscillators, envelopes, scheduler, WAV/JSON export)
├─ Coupling layer     : renderGenome() → shared mappings (freq↔Y↔pitch, hue↔color↔timbre, etc.)
├─ Sidescroller loop  : requestAnimationFrame; scroll, lanes, gates, hazards, Shuttle, collisions
├─ Fitness modes      : Hand-Weaver / Loom-Sense / Autoloom state machine
├─ HUD                : gene-diff strip, cockpit dials, rating radial, scores
└─ Persistence        : localStorage (gallery, surrogate weights, best genomes), state-string URLs
```

**Performance budget (mobile):** N=6 strands, population=8, OffscreenCanvas genome tiles cached + only re-rendered on mutation, ≤4 simultaneous oscillators per bar. Target 60fps on mid-tier mobile; degrade gracefully (lower tile res, fewer simultaneous gates).

**Build/deploy:** mirror existing pipeline — single `index.html`, copy to `rexuvia-site/public/games/`, add to `game_list.json`, `bash rebuild.sh`, new repo `rexuvia/glitchweaver`.

---

## 12. Risks & Mitigations

| Risk | Mitigation |
|---|---|
| GA feels abstract / opaque | Gene-diff strip + audio diff telegraphs every mutation (§6); operators are visible verbs. |
| Audiovisual coupling feels arbitrary | Keep mappings few, strong, and consistent; show a "Rosetta" legend in tutorial biome. |
| Per-genome render too slow on mobile | Cache OffscreenCanvas tiles; re-render only on mutation; cap population/strands. |
| Surrogate model overfits / feels random | Start with simple linear model + lots of data before trusting; "Defy" mechanic turns its mistakes into fun. |
| Audio fatigue (random microtonal = harsh) | Bias frequency genome toward consonant ratios in early biomes; let dissonance be a late-game choice. |
| Scope creep (3 fitness modes is a lot) | Ship Mode A first (fully playable as MVP); B and C are post-MVP unlocks. |

---

## 13. Build Phases

- **MVP (Phase 1):** Unified genome + coupling layer + sidescroller scroll with 6 lanes + Hand-Weaver fitness (fly-through selection + rating) + 1 biome + PNG/WAV export. Proves the fusion is fun.
- **Phase 2:** GA operators as power-ups (mutation/crossover/elitism/diversity), gene-diff HUD, multiple biomes, gallery + state-string sharing.
- **Phase 3:** Loom-Sense surrogate model + explore/exploit scoring; Autoloom endless mode; daily seed leaderboard; GIF export.

---

## 14. One-line Pitch

> **GLITCHWEAVER** — fly a weaver's shuttle through an evolving search-space where every level is a genome that you both *see* as a glitch tapestry and *hear* as a melody; steer the genetic algorithm with your taste, teach it to predict you, then watch it surprise you.
