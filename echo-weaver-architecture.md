# Echo Weaver - Architecture

*A node-based sonic pattern creator where visual patterns become sound*

---

## 🎯 Core Concept

Place nodes on canvas → connect them → pulses travel → sounds emerge. Every connection is a rhythm, every pattern is a song.

---

## 🏗️ Architecture Overview

### Tech Stack
- **Single-file HTML** (~500 lines)
- **Vue 3 Composition API** (CDN: petite-vue or full Vue)
- **Web Audio API** (no external audio libraries)
- **SVG** for canvas rendering (crisp, scalable, CSS-animatable)
- **CSS Custom Properties** driven by reactive refs
- **Mobile-first** responsive design

---

## 🔧 Core Mechanics

### 1. Node System

**Node Structure:**
```javascript
{
  id: uuid(),
  x: number,      // 0-100 (percentage)
  y: number,      // 0-100 (percentage)
  type: 'tone' | 'delay' | 'filter' | 'trigger',
  active: boolean,
  config: {
    // type-specific params
    frequency: 440,  // tone
    delayTime: 200,  // delay
    filterFreq: 1000 // filter
  }
}
```

**Node Types:**
- **Tone Node** - Generates sound (frequency, waveform, duration)
- **Delay Node** - Adds time offset before pulse continues
- **Filter Node** - Modifies passing pulse (pitch shift, effects)
- **Trigger Node** - Starting point, emits pulses at interval

### 2. Connection System

**Connection Structure:**
```javascript
{
  id: uuid(),
  from: nodeId,
  to: nodeId,
  active: boolean
}
```

**Connection Rules:**
- One-to-many: node can connect to multiple targets
- No self-loops (for v1)
- Visual: curved SVG paths with animated pulse dots

### 3. Pulse System

**Pulse Object:**
```javascript
{
  id: uuid(),
  currentNode: nodeId,
  nextConnection: connectionId,
  birthTime: timestamp,
  history: [nodeId, ...] // prevent loops
}
```

**Pulse Lifecycle:**
1. Spawned by Trigger node at interval (BPM-based)
2. Travels along connection (visual animation)
3. Reaches node → triggers sound + visual feedback
4. Spawns new pulses for all outgoing connections
5. Dies if no connections or hits visited node

**Timing System:**
- Global clock: `requestAnimationFrame` loop
- BPM setting (60-180) → pulse spawn interval
- Connection travel time: fixed ~500ms or distance-based
- Delay nodes add wait time before pulse continues

---

## 🎨 Vue + CSS Reactivity

### Reactive State
```javascript
const state = reactive({
  nodes: [],
  connections: [],
  pulses: [],
  playing: false,
  bpm: 120,
  audioContext: null
})
```

### CSS Variable Binding
```javascript
// In Vue component
watchEffect(() => {
  document.documentElement.style.setProperty('--pulse-speed', 
    `${60000 / state.bpm}ms`)
  
  state.nodes.forEach(node => {
    document.documentElement.style.setProperty(`--node-${node.id}-glow`,
      node.active ? '1' : '0')
  })
})
```

### Visual Feedback Patterns
- **Node activation**: Glow ring (CSS animation, triggered by `--node-*-glow`)
- **Pulse travel**: SVG circle animates along path (`<animateMotion>`)
- **Connection highlight**: Opacity/stroke-width change on pulse pass
- **Global sync**: All animations sync to BPM via `--pulse-speed`

### SVG Structure
```xml
<svg viewBox="0 0 100 100" class="canvas">
  <!-- Connections -->
  <g class="connections">
    <path v-for="conn in connections"
          :d="getConnectionPath(conn)"
          :class="{ active: conn.active }"
          :style="`--conn-opacity: ${conn.active ? 1 : 0.3}`" />
  </g>
  
  <!-- Nodes -->
  <g class="nodes">
    <g v-for="node in nodes" 
       :transform="`translate(${node.x}, ${node.y})`"
       @click="selectNode(node)">
      <circle r="2" class="node-body" 
              :class="`node-${node.type}`"
              :style="`--glow: var(--node-${node.id}-glow)`" />
      <circle r="3" class="node-ring" v-if="node.active" />
    </g>
  </g>
  
  <!-- Pulses -->
  <g class="pulses">
    <circle v-for="pulse in pulses" 
            :key="pulse.id"
            r="0.5" 
            class="pulse">
      <animateMotion :path="getPulsePath(pulse)" 
                     :dur="`${connectionTravelTime}ms`" />
    </circle>
  </g>
</svg>
```

---

## 🔊 Web Audio Integration

### Audio Context Setup
```javascript
const initAudio = () => {
  const ctx = new (window.AudioContext || window.webkitAudioContext)()
  const masterGain = ctx.createGain()
  masterGain.gain.value = 0.3
  masterGain.connect(ctx.destination)
  return { ctx, masterGain }
}
```

### Sound Triggering
```javascript
const playTone = (node, pulse) => {
  const { ctx, masterGain } = state.audio
  const osc = ctx.createOscillator()
  const gain = ctx.createGain()
  
  osc.frequency.value = node.config.frequency
  osc.type = node.config.waveform || 'sine'
  
  gain.gain.setValueAtTime(0.5, ctx.currentTime)
  gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.3)
  
  osc.connect(gain).connect(masterGain)
  osc.start()
  osc.stop(ctx.currentTime + 0.3)
}
```

### Node-Specific Audio
- **Tone**: Basic oscillator (sine/square/triangle)
- **Delay**: Store pulse, re-emit after delay
- **Filter**: Biquad filter applied to passing pulses
- **Trigger**: No sound, just spawns pulses

---

## 🎮 UX Design

### Mobile-First Controls

**Bottom Sheet Panel:**
```
[▶ Play] [BPM: 120 ▲▼] [Clear] [Presets ▾]
```

**Interaction Modes:**
1. **Place Mode** (default): Tap canvas → place node
2. **Connect Mode**: Drag from node → another node
3. **Edit Mode**: Tap node → edit panel slides up
4. **Move Mode**: Long-press + drag to reposition

**Gestures:**
- **Single tap**: Place node / select node
- **Drag between nodes**: Create connection
- **Long-press node**: Delete node
- **Two-finger pinch**: (future) Zoom/pan canvas

### Visual Feedback
- **Pulse trail**: Fading afterglow along path
- **Node glow intensity**: Based on recent activity
- **Connection thickness**: Pulses per second
- **Color coding**: Node types have distinct hues
  - Trigger: cyan
  - Tone: pink
  - Delay: amber
  - Filter: purple

### Preset Patterns
Stored as JSON, loaded on demand:
1. **Simple Loop** - 3 tones in triangle
2. **Cascade** - Linear chain with delays
3. **Spiral** - Circular pattern with pitch climb
4. **Chaos** - Dense web for ambient texture

---

## 📦 Implementation Structure

### Single-File Layout
```html
<!DOCTYPE html>
<html>
<head>
  <style>/* ~200 lines CSS */</style>
</head>
<body>
  <div id="app">
    <svg class="canvas"><!-- SVG structure --></svg>
    <div class="controls"><!-- UI controls --></div>
  </div>
  
  <script src="https://unpkg.com/vue@3"></script>
  <script>
    const { createApp, reactive, computed, watchEffect } = Vue
    
    createApp({
      setup() {
        // ~200 lines logic
        return { state, methods }
      }
    }).mount('#app')
  </script>
</body>
</html>
```

### State Management
No external store needed - single reactive object:
```javascript
const state = reactive({
  // Data
  nodes: [],
  connections: [],
  pulses: [],
  
  // Config
  playing: false,
  bpm: 120,
  mode: 'place',
  selectedNode: null,
  
  // Audio
  audio: null,
  
  // Animation
  lastFrame: 0,
  clock: 0
})
```

### Core Methods
```javascript
{
  // Canvas
  addNode(x, y, type),
  removeNode(id),
  moveNode(id, x, y),
  
  // Connections
  addConnection(fromId, toId),
  removeConnection(id),
  
  // Pulses
  spawnPulse(nodeId),
  updatePulses(deltaTime),
  
  // Audio
  triggerNodeSound(node, pulse),
  
  // System
  startPlaying(),
  stopPlaying(),
  clearCanvas(),
  loadPreset(name)
}
```

---

## 🚀 Expansion Ideas

### Phase 2 Features
- **Recording**: Capture pattern → WAV export
- **Sample nodes**: Upload/play audio samples
- **Probability**: Connections have chance % to fire
- **Velocity**: Pulse speed affects volume
- **Quantization**: Snap to beat grid

### Phase 3 Features
- **Multi-user**: Real-time collaborative canvas
- **Physics**: Nodes repel/attract (force-directed)
- **3D mode**: Depth dimension with CSS transforms
- **MIDI out**: Sync with external instruments
- **Shader effects**: WebGL visual layer

### Advanced Node Types
- **Splitter**: One input → multiple outputs with delay
- **Merger**: Wait for N inputs before firing
- **Random**: Randomize pitch/timing on pass
- **Sequencer**: Cycle through note sequence
- **Reverb**: Spatial audio effect

---

## 🎪 Mesmerizing Details

### Visual Polish
- **Starfield background**: Subtle particle system
- **Glow bloom**: CSS blur filters on active elements
- **Gradient paths**: Connections shimmer with CSS gradients
- **Easing**: Elastic/bounce for UI animations
- **Color shift**: Hue rotates slowly over time

### Audio Polish
- **Reverb tail**: All notes have subtle reverb
- **Envelope shaping**: ADSR for each tone
- **Pitch drift**: Slight detuning for organic feel
- **Stereo panning**: Position-based L/R balance
- **Dynamic compression**: Masterbus limiter prevents clipping

### Performance
- **RAF loop**: Single animation frame callback
- **Object pooling**: Reuse pulse objects
- **Culling**: Don't render off-screen elements
- **Lazy audio**: Create/destroy oscillators on-demand
- **Throttled updates**: CSS vars update at 30fps max

---

## 📱 Mobile Optimization

### Touch Targets
- Minimum 44×44px tap areas
- Nodes scale up slightly on touch devices
- Bottom sheet has handle for easy dragging

### Performance
- Limit active pulses (max 50)
- Limit active nodes (max 20 for mobile)
- Reduce particle effects on low-end devices
- Use `will-change` for animated elements

### PWA Ready
Add manifest + service worker for install:
- Offline-first
- Add to home screen
- Full-screen mode
- Persistent state in localStorage

---

## 🧪 Testing Checklist

- [ ] Audio context starts on user gesture (iOS requirement)
- [ ] Touch events work on mobile Safari
- [ ] SVG scales properly on all screen sizes
- [ ] No audio glitches when spawning many pulses
- [ ] Preset patterns load correctly
- [ ] Clear/reset doesn't break audio context
- [ ] BPM changes update pulse timing smoothly
- [ ] Long sessions don't leak memory

---

## 🎬 Getting Started

**Minimal viable version:**
1. Canvas with click → place tone node
2. Drag between nodes → create connection
3. Play button → spawns pulses from first node
4. Pulses trigger Web Audio tones
5. Visual glow on node activation

**Build from there.**

---

*Echo Weaver: Where patterns become sound, and sound becomes alive.*
