const PATTERN_COUNT = 45;

// Compact state representation
const state = {
  speed: 50,
  density: 50,
  colorShift: 0,
  glitchIntensity: 20,
  pattern: 0,
  scaleMod: 50,
  jitterMod: 0,
  varA: 50,
  varB: 50,
  colorIntensity: 100,
  noiseIntensity: 0
};

// UI Elements
const uiElements = {
  speed: document.getElementById('anim-speed'),
  density: document.getElementById('density'),
  colorShift: document.getElementById('color-shift'),
  glitchIntensity: document.getElementById('glitch-intensity'),
  pattern: document.getElementById('pattern-type'),
  scaleMod: document.getElementById('scale-mod'),
  jitterMod: document.getElementById('jitter-mod'),
  varA: document.getElementById('var-a'),
  varB: document.getElementById('var-b'),
  colorIntensity: document.getElementById('color-intensity'),
  noiseIntensity: document.getElementById('noise-intensity'),
  varADesc: document.getElementById('varA-desc'),
  varBDesc: document.getElementById('varB-desc'),
  stateString: document.getElementById('state-string'),
  loadString: document.getElementById('load-string'),
  panel: document.getElementById('controls-panel'),
  toggleBtn: document.getElementById('toggle-ui')
};

// Encode state to string
// pattern can now be >35 so we use 2 chars for it
function encodeState() {
  const parts = [
    state.speed.toString(36).padStart(2, '0'),
    state.density.toString(36).padStart(2, '0'),
    state.colorShift.toString(36).padStart(2, '0'),
    state.glitchIntensity.toString(36).padStart(2, '0'),
    state.pattern.toString(36).padStart(2, '0'),
    state.scaleMod.toString(36).padStart(2, '0'),
    state.jitterMod.toString(36).padStart(2, '0'),
    state.varA.toString(36).padStart(2, '0'),
    state.varB.toString(36).padStart(2, '0'),
    state.colorIntensity.toString(36).padStart(2, '0'),
    state.noiseIntensity.toString(36).padStart(2, '0')
  ];
  const str = parts.join('');
  uiElements.stateString.value = str;
  history.replaceState(null, '', '#' + str);
  return str;
}

// Decode state from string
// Supports legacy 9/13-char formats (single-char pattern) and new 14-char format
function decodeState(str) {
  try {
    if (str.length === 22) {
      // New format: includes colorIntensity and noiseIntensity
      state.speed          = parseInt(str.substr(0, 2), 36);
      state.density        = parseInt(str.substr(2, 2), 36);
      state.colorShift     = parseInt(str.substr(4, 2), 36);
      state.glitchIntensity= parseInt(str.substr(6, 2), 36);
      state.pattern        = parseInt(str.substr(8, 2), 36);
      state.scaleMod       = parseInt(str.substr(10, 2), 36);
      state.jitterMod      = parseInt(str.substr(12, 2), 36);
      state.varA           = parseInt(str.substr(14, 2), 36);
      state.varB           = parseInt(str.substr(16, 2), 36);
      state.colorIntensity = parseInt(str.substr(18, 2), 36);
      state.noiseIntensity = parseInt(str.substr(20, 2), 36);
    } else if (str.length === 18) {
      // Previous format: all 2-char fields including varA, varB
      state.speed          = parseInt(str.substr(0, 2), 36);
      state.density        = parseInt(str.substr(2, 2), 36);
      state.colorShift     = parseInt(str.substr(4, 2), 36);
      state.glitchIntensity= parseInt(str.substr(6, 2), 36);
      state.pattern        = parseInt(str.substr(8, 2), 36);
      state.scaleMod       = parseInt(str.substr(10, 2), 36);
      state.jitterMod      = parseInt(str.substr(12, 2), 36);
      state.varA           = parseInt(str.substr(14, 2), 36);
      state.varB           = parseInt(str.substr(16, 2), 36);
      state.colorIntensity = 100;
      state.noiseIntensity = 0;
    } else if (str.length === 14) {
      // Legacy: 7 fields, no varA/varB
      state.speed          = parseInt(str.substr(0, 2), 36);
      state.density        = parseInt(str.substr(2, 2), 36);
      state.colorShift     = parseInt(str.substr(4, 2), 36);
      state.glitchIntensity= parseInt(str.substr(6, 2), 36);
      state.pattern        = parseInt(str.substr(8, 2), 36);
      state.scaleMod       = parseInt(str.substr(10, 2), 36);
      state.jitterMod      = parseInt(str.substr(12, 2), 36);
      state.varA           = 50;
      state.varB           = 50;
      state.colorIntensity = 100;
      state.noiseIntensity = 0;
    } else if (str.length === 13) {
      // Legacy with scaleMod/jitterMod, single-char pattern
      state.speed          = parseInt(str.substr(0, 2), 36);
      state.density        = parseInt(str.substr(2, 2), 36);
      state.colorShift     = parseInt(str.substr(4, 2), 36);
      state.glitchIntensity= parseInt(str.substr(6, 2), 36);
      state.pattern        = parseInt(str.substr(8, 1), 36);
      state.scaleMod       = parseInt(str.substr(9, 2), 36);
      state.jitterMod      = parseInt(str.substr(11, 2), 36);
      state.varA           = 50;
      state.varB           = 50;
      state.colorIntensity = 100;
      state.noiseIntensity = 0;
    } else if (str.length === 9) {
      // Legacy minimal, single-char pattern
      state.speed          = parseInt(str.substr(0, 2), 36);
      state.density        = parseInt(str.substr(2, 2), 36);
      state.colorShift     = parseInt(str.substr(4, 2), 36);
      state.glitchIntensity= parseInt(str.substr(6, 2), 36);
      state.pattern        = parseInt(str.substr(8, 1), 36);
      state.scaleMod       = 50;
      state.jitterMod      = 0;
      state.varA           = 50;
      state.varB           = 50;
      state.colorIntensity = 100;
      state.noiseIntensity = 0;
    } else {
      return false;
    }
    updateUIFromState();
    return true;
  } catch(e) {
    return false;
  }
}

function updateUIFromState() {
  uiElements.speed.value = state.speed;
  uiElements.density.value = state.density;
  uiElements.colorShift.value = state.colorShift;
  uiElements.glitchIntensity.value = state.glitchIntensity;
  uiElements.pattern.value = state.pattern;
  uiElements.scaleMod.value = state.scaleMod;
  uiElements.jitterMod.value = state.jitterMod;
  uiElements.varA.value = state.varA;
  uiElements.varB.value = state.varB;
  uiElements.colorIntensity.value = state.colorIntensity;
  uiElements.noiseIntensity.value = state.noiseIntensity;
  updateVarDescriptions();
  encodeState();
}

function updateStateFromUI() {
  state.speed = parseInt(uiElements.speed.value);
  state.density = parseInt(uiElements.density.value);
  state.colorShift = parseInt(uiElements.colorShift.value);
  state.glitchIntensity = parseInt(uiElements.glitchIntensity.value);
  state.pattern = parseInt(uiElements.pattern.value);
  state.scaleMod = parseInt(uiElements.scaleMod.value);
  state.jitterMod = parseInt(uiElements.jitterMod.value);
  state.varA = parseInt(uiElements.varA.value);
  state.varB = parseInt(uiElements.varB.value);
  state.colorIntensity = parseInt(uiElements.colorIntensity.value);
  state.noiseIntensity = parseInt(uiElements.noiseIntensity.value);
  updateVarDescriptions();
  encodeState();
}

// Event Listeners
['speed', 'density', 'colorShift', 'glitchIntensity', 'pattern', 'scaleMod', 'jitterMod', 'varA', 'varB', 'colorIntensity', 'noiseIntensity'].forEach(key => {
  uiElements[key].addEventListener('input', updateStateFromUI);
});
// Also update descriptions on pattern change
uiElements.pattern.addEventListener('change', updateVarDescriptions);

document.getElementById('btn-randomize').addEventListener('click', () => {
  uiElements.speed.value = Math.floor(Math.random() * 100) + 1;
  uiElements.density.value = Math.floor(Math.random() * 190) + 10;
  uiElements.colorShift.value = Math.floor(Math.random() * 360);
  uiElements.glitchIntensity.value = Math.floor(Math.random() * 100);
  uiElements.pattern.value = Math.floor(Math.random() * PATTERN_COUNT);
  uiElements.scaleMod.value = Math.floor(Math.random() * 100) + 1;
  uiElements.jitterMod.value = Math.floor(Math.random() * 100);
  uiElements.varA.value = Math.floor(Math.random() * 101);
  uiElements.varB.value = Math.floor(Math.random() * 101);
  uiElements.colorIntensity.value = Math.floor(Math.random() * 101);
  uiElements.noiseIntensity.value = Math.floor(Math.random() * 101);
  updateStateFromUI();
});

document.getElementById('btn-copy-state').addEventListener('click', () => {
  uiElements.stateString.select();
  document.execCommand('copy');
});

document.getElementById('btn-share-link').addEventListener('click', () => {
  const stateStr = encodeState();
  const url = window.location.origin + window.location.pathname + '#' + stateStr;
  navigator.clipboard.writeText(url).then(() => {
    const btn = document.getElementById('btn-share-link');
    const orig = btn.textContent;
    btn.textContent = 'Copied!';
    setTimeout(() => { btn.textContent = orig; }, 1500);
  }).catch(() => {
    const ta = document.createElement('textarea');
    ta.value = url;
    document.body.appendChild(ta);
    ta.select();
    document.execCommand('copy');
    document.body.removeChild(ta);
    const btn = document.getElementById('btn-share-link');
    const orig = btn.textContent;
    btn.textContent = 'Copied!';
    setTimeout(() => { btn.textContent = orig; }, 1500);
  });
});

document.getElementById('btn-load-state').addEventListener('click', () => {
  decodeState(uiElements.loadString.value.trim());
});

uiElements.toggleBtn.addEventListener('click', () => {
  uiElements.panel.classList.toggle('hidden');
  uiElements.toggleBtn.textContent = uiElements.panel.classList.contains('hidden') ? 'Show UI' : 'Hide UI';
});


// Animation Engine
const canvas = document.getElementById('main-canvas');
const ctx = canvas.getContext('2d');
let time = 0;

// Persistent buffers for stateful patterns
let rdA = null, rdB = null, rdA2 = null, rdB2 = null;
let rdW = 0, rdH = 0;

function initRD(w, h) {
  rdW = w; rdH = h;
  rdA  = new Float32Array(w * h).fill(1);
  rdB  = new Float32Array(w * h).fill(0);
  rdA2 = new Float32Array(w * h);
  rdB2 = new Float32Array(w * h);
  // Seed a few spots
  for (let i = 0; i < 8; i++) {
    let sx = Math.floor(Math.random() * w);
    let sy = Math.floor(Math.random() * h);
    for (let dy = -3; dy <= 3; dy++)
      for (let dx = -3; dx <= 3; dx++) {
        let idx = ((sy+dy+h)%h) * w + ((sx+dx+w)%w);
        rdB[idx] = 1;
      }
  }
}

function stepRD() {
  const dA = 1.0, dB = 0.5;
  const feed = 0.02 + (state.varA / 100) * 0.06;  // 0.02 - 0.08
  const kill = 0.04 + (state.varB / 100) * 0.04;  // 0.04 - 0.08
  const w = rdW, h = rdH;
  for (let y = 0; y < h; y++) {
    for (let x = 0; x < w; x++) {
      const i = y * w + x;
      const a = rdA[i], b = rdB[i];
      const lap_a =
        rdA[((y-1+h)%h)*w + x] + rdA[((y+1)%h)*w + x] +
        rdA[y*w + (x-1+w)%w]   + rdA[y*w + (x+1)%w] - 4*a;
      const lap_b =
        rdB[((y-1+h)%h)*w + x] + rdB[((y+1)%h)*w + x] +
        rdB[y*w + (x-1+w)%w]   + rdB[y*w + (x+1)%w] - 4*b;
      const reaction = a * b * b;
      rdA2[i] = Math.max(0, Math.min(1, a + dA*lap_a - reaction + feed*(1-a)));
      rdB2[i] = Math.max(0, Math.min(1, b + dB*lap_b + reaction - (kill+feed)*b));
    }
  }
  const tmp = rdA; rdA = rdA2; rdA2 = tmp;
  const tmp2 = rdB; rdB = rdB2; rdB2 = tmp2;
}

// Lorenz attractor state
let lx = 0.1, ly = 0, lz = 0;
let lx2 = 10, ly2 = 0, lz2 = 25;

function resize() {
  canvas.width = window.innerWidth;
  canvas.height = window.innerHeight;
  rdA = null; // force RD reinit on next use
}
window.addEventListener('resize', resize);
resize();

// Per-pattern variable descriptions (shown next to slider labels)
const VAR_DESCS = {
  0:  ['Frequency',      'Amplitude'],
  1:  ['Grid Spacing',   'Threshold'],
  2:  ['Arm Count',      'Tightness'],
  3:  ['Complexity',     'Turbulence'],
  4:  ['Ring Count',     'Spread'],
  5:  ['Arm Twist',      'Rotation Speed'],
  6:  ['Cell Size',      'Blink Rate'],
  7:  ['C-Real Offset',  'Max Iterations'],
  8:  ['XOR Frequency',  'Cutoff'],
  9:  ['Wave Blend',     'Phase Offset'],
  10: ['X Frequency',    'Y Frequency'],
  11: ['X Period',       'Y Period'],
  12: ['Source Spread',  'Wave Density'],
  13: ['Grid Size',      'Pulse Speed'],
  14: ['Hex Size',       'Wave Depth'],
  15: ['Diagonal Freq',  'Line Width'],
  16: ['Arm Count',      'Tightness'],
  17: ['Arm Count',      'Fade Strength'],
  18: ['Spiral Arms',    'Ring Density'],
  19: ['C-Offset',       'Max Iterations'],
  20: ['Zoom Depth',     'Drift Speed'],
  21: ['Iteration Depth','Root Spin'],
  22: ['Seed Count',     'Edge Sharpness'],
  23: ['Lattice Size',   'Scroll Speed'],
  24: ['Ring Density',   'Petal Count'],
  25: ['Sector Count',   'Radial Freq'],
  26: ['Star Density',   'Twinkle Speed'],
  27: ['Twist Rate',     'Depth Speed'],
  28: ['Feed Rate',      'Kill Rate'],
  29: ['Center Offset',  'Frequency'],
  30: ['X Frequency',    'Y Frequency'],
  31: ['Layer Count',    'Radial Weight'],
  32: ['Branch Width',   'Flash Speed'],
  33: ['Column Count',   'Drop Length'],
  34: ['Bar Count',      'Shift Amount'],
  35: ['Grid Resolution','XOR Speed'],
  36: ['Line Spacing',   'Scan Speed'],
  37: ['Sort Size',      'Sort Speed'],
  38: ['Field Size',     'Wave Speed'],
  39: ['Zoom Level',     'Tile Density'],
  40: ['Rho',            'Sigma'],
  41: ['Param A',        'Param B'],
  42: ['Cloud Density',  'Threshold'],
  43: ['Band Freq',      'Shimmer'],
  44: ['Warp Strength',  'Accretion Arms']
};

function updateVarDescriptions() {
  const descs = VAR_DESCS[state.pattern] || ['Param A', 'Param B'];
  uiElements.varADesc.textContent = '– ' + descs[0];
  uiElements.varBDesc.textContent = '– ' + descs[1];
}

function computePattern(px, py, pattern, t) {
  // Normalize varA/varB from 0-100 to 0.0-1.0 for easy use in patterns
  const vA = state.varA / 100;
  const vB = state.varB / 100;
  switch (pattern) {
    case 0: { // Wave — vA: frequency (5-20), vB: amplitude (0.3-1.5)
      let freq = 5 + vA * 15;
      let amp = 0.3 + vB * 1.2;
      return Math.sin(px * freq + t) * Math.cos(py * freq - t) * amp;
    }
    case 1: { // Grid — vA: grid spacing (8-40), vB: threshold (0.1-0.9)
      let spacing = 8 + vA * 32;
      let thresh = 0.1 + vB * 0.8;
      return (Math.sin(px * spacing + t) > thresh ? 1 : 0) ^ (Math.cos(py * spacing - t) > thresh ? 1 : 0);
    }
    case 2: { // Spiral — vA: arm count (2-12), vB: tightness (8-40)
      let dx = px - 0.5, dy = py - 0.5;
      let angle = Math.atan2(dy, dx);
      let dist = Math.sqrt(dx*dx + dy*dy);
      let arms = 2 + Math.floor(vA * 10);
      let tight = 8 + vB * 32;
      return Math.sin(angle * arms + dist * tight - t * 2);
    }
    case 3: { // Noise — vA: complexity (20-80), vB: turbulence mix (10-60)
      let complex = 20 + vA * 60;
      let turb = 10 + vB * 50;
      return Math.sin(px * complex + t) * Math.cos(py * complex + t * 1.5) * Math.sin((px+py)*turb - t);
    }
    case 4: { // Pulse — vA: ring count (20-80), vB: spread factor (5-20)
      let dist = Math.sqrt((px-0.5)**2 + (py-0.5)**2);
      let rings = 20 + vA * 60;
      let spread = 5 + vB * 15;
      return Math.sin(dist * rings - t * 5) * Math.cos(px * spread);
    }
    case 5: { // Vortex — vA: arm twist (4-20), vB: rotation speed (1-6)
      let dx = px - 0.5, dy = py - 0.5;
      let angle = Math.atan2(dy, dx);
      let dist = Math.sqrt(dx*dx + dy*dy);
      let twist = 4 + vA * 16;
      let rotSpd = 1 + vB * 5;
      return Math.sin(angle * twist + dist * 50 - t * rotSpd) * Math.cos(angle * 2 + t);
    }
    case 6: { // Matrix — vA: cell size (15-50), vB: blink rate (1-5)
      let cellSz = 15 + vA * 35;
      let blink = 1 + vB * 4;
      return (Math.sin(px * cellSz) * Math.cos(py * cellSz - t * blink) > 0.5) ? 1 : -1;
    }
    case 7: { // Fractal (Julia) — vA: c-real offset (-0.5 to 0.5), vB: max iterations (5-20)
      let zx = px * 4 - 2, zy = py * 4 - 2;
      let cOff = (vA - 0.5);
      let cx = Math.sin(t * 0.5) + cOff, cy = Math.cos(t * 0.5);
      let maxIter = 5 + Math.floor(vB * 15);
      let iter = 0;
      while (zx*zx + zy*zy < 4 && iter < maxIter) {
        let xt = zx*zx - zy*zy + cx;
        zy = 2*zx*zy + cy;
        zx = xt;
        iter++;
      }
      return iter / maxIter;
    }
    case 8: { // Circuit — vA: XOR frequency (10-40), vB: cutoff (0.2-0.8)
      let xorFreq = 10 + vA * 30;
      let cutoff = 0.2 + vB * 0.6;
      return Math.sin((px * xorFreq) ^ (py * xorFreq) + t) > cutoff ? 1 : 0;
    }

    // ── Wave Variants ──
    case 9: { // Double Wave — vA: blend ratio (0-1), vB: phase offset (0-6.28)
      let blend = vA;
      let phase = vB * Math.PI * 2;
      let w1 = Math.sin(px * 12 + t + phase) * Math.cos(py * 8 - t * 1.2);
      let w2 = Math.sin(py * 12 + t * 0.7) * Math.cos(px * 8 + t * 0.9);
      return w1 * blend + w2 * (1 - blend);
    }
    case 10: { // Cross Wave — vA: X frequency (5-30), vB: Y frequency (5-30)
      let fx = 5 + vA * 25;
      let fy = 5 + vB * 25;
      let wx = Math.sin(px * fx + t * 1.1);
      let wy = Math.sin(py * fy - t * 0.9);
      return wx * wy;
    }
    case 11: { // Standing Wave — vA: X period (5-25), vB: Y period (5-25)
      let xp = 5 + vA * 20;
      let yp = 5 + vB * 20;
      return Math.sin(px * xp + t) * Math.sin(py * yp + t);
    }
    case 12: { // Wave Interference — vA: source spread (0.1-0.5), vB: wave density (15-60)
      let spread = 0.1 + vA * 0.4;
      let waveDens = 15 + vB * 45;
      let dx1 = px - (0.5 - spread), dy1 = py - (0.5 - spread);
      let dx2 = px - (0.5 + spread), dy2 = py - (0.5 + spread);
      let r1 = Math.sqrt(dx1*dx1 + dy1*dy1);
      let r2 = Math.sqrt(dx2*dx2 + dy2*dy2);
      return Math.sin(r1 * waveDens - t * 4) + Math.sin(r2 * waveDens - t * 4);
    }

    // ── Grid Variants ──
    case 13: { // Checker Pulse — vA: grid size (5-20), vB: pulse speed (1-8)
      let gridSz = 5 + Math.floor(vA * 15);
      let pulseSpd = 1 + vB * 7;
      let gx = Math.floor(px * gridSz), gy = Math.floor(py * gridSz);
      let phase = ((gx + gy) % 2 === 0) ? t : -t;
      return Math.sin(phase * pulseSpd) * 0.8 + Math.sin(px * 20 + py * 20) * 0.2;
    }
    case 14: { // Hex Grid — vA: hex size (5-20), vB: wave depth (10-40)
      let hexSz = 5 + vA * 15;
      let waveD = 10 + vB * 30;
      let q = px * hexSz, r = py * hexSz;
      let hx = q - r * 0.5;
      let hy = r * Math.sqrt(3) * 0.5;
      let cellX = hx % 1.0;
      let cellY = hy % 1.0;
      let distHex = Math.sqrt(cellX*cellX + cellY*cellY);
      return Math.sin(distHex * waveD - t * 2);
    }
    case 15: { // Diagonal Grid — vA: diagonal freq (10-40), vB: line width influence
      let dFreq = 10 + vA * 30;
      let lineW = 0.1 + vB * 0.8;
      let d1 = Math.sin((px + py) * dFreq + t);
      let d2 = Math.sin((px - py) * dFreq - t);
      return (d1 > lineW ? 1 : -1) * (d2 > lineW ? 1 : -1);
    }

    // ── Spiral Variants ──
    case 16: { // Multi-Arm Spiral — vA: arm count (3-15), vB: tightness (10-50)
      let dx = px - 0.5, dy = py - 0.5;
      let angle = Math.atan2(dy, dx);
      let dist = Math.sqrt(dx*dx + dy*dy);
      let arms = 3 + Math.floor(vA * 12);
      let tight = 10 + vB * 40;
      return Math.sin(angle * arms + dist * tight - t * 2);
    }
    case 17: { // Inverted Spiral — vA: arm count (3-10), vB: fade strength (0.5-3)
      let dx = px - 0.5, dy = py - 0.5;
      let angle = Math.atan2(dy, dx);
      let dist = Math.sqrt(dx*dx + dy*dy);
      let arms = 3 + Math.floor(vA * 7);
      let fade = 0.5 + vB * 2.5;
      return Math.sin(angle * arms - dist * 30 + t * 2) * (1 - dist * fade);
    }
    case 18: { // Spiral Web — vA: spiral arms (3-12), vB: ring density (20-60)
      let dx = px - 0.5, dy = py - 0.5;
      let angle = Math.atan2(dy, dx);
      let dist = Math.sqrt(dx*dx + dy*dy);
      let sArms = 3 + Math.floor(vA * 9);
      let ringD = 20 + vB * 40;
      let spiral = Math.sin(angle * sArms + dist * 20 - t * 2);
      let rings  = Math.sin(dist * ringD - t * 3);
      return spiral * rings;
    }

    // ── Fractal Variants ──
    case 19: { // Burning Julia — vA: c-offset (-0.5 to 0.5), vB: max iterations (6-20)
      let zx = px * 4 - 2, zy = py * 4 - 2;
      let cOff = (vA - 0.5);
      let cx = Math.sin(t * 0.3) + cOff, cy = Math.cos(t * 0.4);
      let maxIter = 6 + Math.floor(vB * 14);
      let iter = 0;
      while (zx*zx + zy*zy < 4 && iter < maxIter) {
        let xt = Math.abs(zx*zx - zy*zy) + cx;
        zy = Math.abs(2*zx*zy) + cy;
        zx = xt;
        iter++;
      }
      return iter / maxIter;
    }
    case 20: { // Mandelbrot Zoom — vA: zoom depth (0.5-3), vB: drift speed (0.01-0.15)
      let zoomD = 0.5 + vA * 2.5;
      let drift = 0.01 + vB * 0.14;
      let zoom = zoomD + Math.sin(t * 0.1) * 0.8;
      let cx = px * 3.5 / zoom - 2.5 / zoom + Math.sin(t * drift) * 0.3;
      let cy = py * 3.5 / zoom - 1.75 / zoom + Math.cos(t * drift * 0.7) * 0.3;
      let zx = 0, zy = 0, iter = 0;
      while (zx*zx + zy*zy < 4 && iter < 12) {
        let xt = zx*zx - zy*zy + cx;
        zy = 2*zx*zy + cy;
        zx = xt;
        iter++;
      }
      return iter / 12;
    }
    case 21: { // Newton Basin — vA: iteration depth (6-20), vB: root spin speed (0.01-0.15)
      let maxIter = 6 + Math.floor(vA * 14);
      let spinSpd = 0.01 + vB * 0.14;
      let zx = px * 3 - 1.5, zy = py * 3 - 1.5;
      let iter = 0;
      while (iter < maxIter) {
        let denom = 3 * ((zx*zx - zy*zy)*(zx*zx - zy*zy) + (2*zx*zy)*(2*zx*zy));
        if (denom < 1e-6) break;
        let nx = (2/3)*zx + (zx*zx - zy*zy) / denom;
        let ny = (2/3)*zy - 2*zx*zy / denom;
        if (Math.abs(nx-zx) + Math.abs(ny-zy) < 0.001) break;
        zx = nx; zy = ny;
        iter++;
      }
      let root = Math.atan2(zy, zx) / (Math.PI * 2) + 0.5 + t * spinSpd;
      return Math.sin(root * Math.PI * 6) * (iter / maxIter);
    }

    // ── New: Geometric ──
    case 22: { // Voronoi — vA: seed count (3-12), vB: edge sharpness (30-150)
      let seedCnt = 3 + Math.floor(vA * 9);
      let sharpness = 30 + vB * 120;
      let minDist = 9999, secondMin = 9999;
      for (let i = 0; i < seedCnt; i++) {
        let angle = (i / seedCnt) * Math.PI * 2 + t * 0.3;
        let sx = 0.5 + Math.cos(angle + t * 0.2) * 0.3;
        let sy = 0.5 + Math.sin(angle * 1.3 + t * 0.15) * 0.3;
        let d = Math.sqrt((px-sx)**2 + (py-sy)**2);
        if (d < minDist) { secondMin = minDist; minDist = d; }
        else if (d < secondMin) secondMin = d;
      }
      return Math.sin((secondMin - minDist) * sharpness - t * 2);
    }
    case 23: { // Diamond Lattice — vA: lattice size (5-25), vB: scroll speed (0.1-1.5)
      let latSz = 5 + vA * 20;
      let scroll = 0.1 + vB * 1.4;
      let dx = Math.abs((px * latSz + t * scroll) % 2 - 1);
      let dy = Math.abs((py * latSz + t * scroll * 0.6) % 2 - 1);
      return Math.sin((dx + dy) * Math.PI * 5 - t * 3);
    }
    case 24: { // Hypnotic Rings — vA: ring density (20-100), vB: petal count (2-10)
      let dx = px - 0.5, dy = py - 0.5;
      let dist = Math.sqrt(dx*dx + dy*dy);
      let angle = Math.atan2(dy, dx);
      let ringD = 20 + vA * 80;
      let petals = 2 + Math.floor(vB * 8);
      return Math.sin(dist * ringD - t * 5) * Math.cos(angle * petals + t);
    }
    case 25: { // Kaleidoscope — vA: sector count (4-16), vB: radial frequency (10-40)
      let dx = px - 0.5, dy = py - 0.5;
      let angle = Math.atan2(dy, dx);
      let dist = Math.sqrt(dx*dx + dy*dy);
      let sectors = 4 + Math.floor(vA * 12);
      let radFreq = 10 + vB * 30;
      let sectorAngle = Math.PI * 2 / sectors;
      let sector = Math.floor((angle + Math.PI) / (sectorAngle / 2)) % 2;
      let foldedAngle = ((angle + Math.PI) % (sectorAngle / 2));
      if (sector === 1) foldedAngle = sectorAngle / 2 - foldedAngle;
      return Math.sin(foldedAngle * 20 + dist * radFreq - t * 2) * Math.cos(dist * 15 + t);
    }
    case 26: { // Starfield — vA: star density (0.7-0.95 cutoff), vB: twinkle speed (1-8)
      let densityCut = 0.7 + vA * 0.25;
      let twinkleSpd = 1 + vB * 7;
      let hash = Math.sin(Math.floor(px * 80) * 127.1 + Math.floor(py * 80) * 311.7) * 43758.5453;
      let frac = hash - Math.floor(hash);
      let blink = Math.sin(frac * 100 + t * (1 + frac * twinkleSpd));
      return frac > densityCut ? blink : -1;
    }
    case 27: { // Tunnel — vA: twist rate (10-40), vB: depth speed (5-20)
      let dx = px - 0.5, dy = py - 0.5;
      let dist = Math.sqrt(dx*dx + dy*dy);
      let angle = Math.atan2(dy, dx);
      let u = angle / (Math.PI * 2) + 0.5;
      let v = 0.2 / (dist + 0.001);
      let twistR = 10 + vA * 30;
      let depthSpd = 5 + vB * 15;
      return Math.sin(u * twistR + t * 2) * Math.cos((v + t) * depthSpd);
    }

    // ── New: Organic ──
    case 28: { // Reaction Diffusion — vA/vB handled in render() for feed/kill rates
      return 0;
    }
    case 29: { // Moire — vA: center offset (0.1-0.5), vB: frequency (40-120)
      let cOff = 0.1 + vA * 0.4;
      let freq = 40 + vB * 80;
      let r1 = Math.sqrt((px-(0.5-cOff))**2 + (py-0.5)**2);
      let r2 = Math.sqrt((px-(0.5+cOff) + Math.sin(t*0.5)*0.1)**2 + (py-0.5)**2);
      return Math.sin(r1 * freq) * Math.sin(r2 * freq);
    }
    case 30: { // Lissajous Web — vA: X frequency (1-8), vB: Y frequency (1-8)
      let freqX = 1 + Math.floor(vA * 7);
      let freqY = 1 + Math.floor(vB * 7);
      let lxv = Math.sin(freqX * px * Math.PI * 2 + t);
      let lyv = Math.sin(freqY * py * Math.PI * 2 + t * 0.7);
      return Math.sin((lxv + lyv) * 10 + t * 0.5);
    }
    case 31: { // Plasma — vA: layer count (3-8 harmonic layers), vB: radial weight (0-1)
      let layers = 3 + Math.floor(vA * 5);
      let radW = vB;
      let sum = 0;
      for (let i = 1; i <= layers; i++) {
        sum += Math.sin(px * (5 + i * 3) + t * (0.5 + i * 0.3));
        sum += Math.sin(py * (5 + i * 3) + t * (0.3 + i * 0.2));
      }
      let c4 = Math.sin(Math.sqrt((px-0.5)**2 + (py-0.5)**2) * 20 - t * 2);
      return (sum / (layers * 2)) * (1 - radW) + c4 * radW;
    }
    case 32: { // Lightning — vA: branch width (0.005-0.04), vB: flash speed (3-15)
      let bWidth = 0.005 + vA * 0.035;
      let flashSpd = 3 + vB * 12;
      let fy = Math.abs(py - 0.5) * 2;
      let noise = Math.sin(px * 80 + t * flashSpd) * 0.08 + Math.sin(px * 30 + t * 3) * 0.15;
      let branch = Math.abs(px - 0.5 - noise);
      return branch < bWidth ? 1 : Math.sin(branch * 300 - t * 10) * (1 - fy);
    }

    // ── New: Digital ──
    case 33: { // Data Stream — vA: column count (10-40), vB: drop length (0.05-0.3)
      let colCnt = 10 + Math.floor(vA * 30);
      let dropLen = 0.05 + vB * 0.25;
      let col = Math.floor(px * colCnt);
      let offset = Math.sin(col * 1.7) * 5 + Math.cos(col * 0.9) * 3;
      let drop = (py * colCnt + offset + t * 4) % 1.0;
      return drop < dropLen ? 1 : (drop < dropLen * 3 ? 0.3 : -1);
    }
    case 34: { // Glitch Bars — vA: bar count (5-30), vB: shift amount (0.05-0.5)
      let barCnt = 5 + Math.floor(vA * 25);
      let shiftAmt = 0.05 + vB * 0.45;
      let bar = Math.floor(py * barCnt);
      let active = Math.sin(bar * 7.3 + t * 2) > 0.5;
      if (!active) return -1;
      let shift = Math.sin(bar * 3.1 + t) * shiftAmt;
      return Math.sin((px + shift) * 30 + t * 3);
    }
    case 35: { // Bit Shift — vA: grid resolution (8-32), vB: XOR speed (1-8)
      let gridRes = 8 + Math.floor(vA * 24);
      let xorSpd = 1 + vB * 7;
      let ix = Math.floor(px * gridRes);
      let iy = Math.floor(py * gridRes);
      let bits = (ix ^ iy ^ Math.floor(t * xorSpd)) & 0xF;
      return (bits / 15) * 2 - 1;
    }
    case 36: { // Scanlines — vA: line spacing (20-80), vB: scan speed (1-5)
      let lineSp = 20 + Math.floor(vA * 60);
      let scanSpd = 1 + vB * 4;
      let line = Math.floor(py * lineSp);
      let scanVal = Math.sin(px * 20 + t * scanSpd) * Math.cos(py * lineSp - t);
      let scanOpacity = (line % 3 === 0) ? 0.2 : 1.0;
      return scanVal * scanOpacity;
    }
    case 37: { // Pixel Sort — vA: sort grid size (15-50), vB: sort speed (2-10)
      let sortSz = 15 + Math.floor(vA * 35);
      let sortSpd = 2 + vB * 8;
      let col2 = Math.floor(px * sortSz);
      let row2 = Math.floor(py * sortSz);
      let sortedRow = (row2 + Math.floor(t * sortSpd * Math.abs(Math.sin(col2 * 0.3)))) % sortSz;
      return Math.sin(sortedRow * 0.7 + col2 * 1.3 + t);
    }

    // ── New: Mathematical ──
    case 38: { // Lemniscate — vA: field size (0.05-0.3), vB: wave speed (1-6)
      let cx = px - 0.5, cy = py - 0.5;
      let fieldSz = 0.05 + vA * 0.25;
      let waveSpd = 1 + vB * 5;
      let a2 = fieldSz + Math.sin(t * 0.5) * 0.05;
      let r2 = cx*cx + cy*cy;
      let lemniscate = r2*r2 - 2*a2*(cx*cx - cy*cy);
      return Math.sin(lemniscate * 100 - t * waveSpd);
    }
    case 39: { // Hyperbolic Tiling — vA: zoom level (1-3), vB: tile density (4-16)
      let zoomLvl = 1 + vA * 2;
      let tileD = 4 + vB * 12;
      let zx = (px * 2 - 1) / zoomLvl, zy = (py * 2 - 1) / zoomLvl;
      let r = zx*zx + zy*zy;
      if (r >= 1) return -1;
      let inv = 1 / (1 - r + 0.001);
      let tx = zx * inv, ty = zy * inv;
      return Math.sin(tx * tileD + t) * Math.cos(ty * tileD + t * 0.7);
    }
    case 40: { // Strange Attractor — vA: rho (15-40), vB: sigma (5-20)
      let ax = px * 2 - 1, ay = py * 2 - 1;
      let sigma = 5 + vB * 15;
      let rho = 15 + vA * 25;
      let beta = 8/3;
      let lx0 = Math.sin(t * 0.5 + ax * 5) * 0.5;
      let ly0 = Math.cos(t * 0.3 + ay * 5) * 0.5;
      let lz0 = Math.sin(t * 0.7 + (ax+ay) * 3) * 0.5;
      let val = Math.sin((sigma*(ly0-lx0)*0.1) + (lx0*(rho-lz0)*0.01) - ly0 + t);
      return val;
    }
    case 41: { // Clifford Attractor — vA: param a (0.5-3), vB: param b (0.5-3)
      let a = 0.5 + vA * 2.5 + Math.sin(t * 0.1) * 0.3;
      let b = 0.5 + vB * 2.5 + Math.cos(t * 0.07) * 0.3;
      let c2 = 0.9 + Math.sin(t * 0.13) * 0.3;
      let d = 0.4 + Math.cos(t * 0.09) * 0.3;
      let fx = px * 4 - 2, fy = py * 4 - 2;
      let nx = Math.sin(a * fy) + c2 * Math.cos(a * fx);
      let ny = Math.sin(b * fx) + d * Math.cos(b * fy);
      return Math.sin(nx * 5 + ny * 5 + t);
    }

    // ── New: Space ──
    case 42: { // Nebula — vA: cloud density (10-35), vB: visibility threshold (-0.2 to 0.4)
      let cloudD = 10 + vA * 25;
      let thresh = -0.2 + vB * 0.6;
      let n1 = Math.sin(px * cloudD + t * 0.5) * Math.cos(py * (cloudD * 0.75) + t * 0.3);
      let n2 = Math.cos(px * (cloudD * 0.6) - t * 0.4) * Math.sin(py * (cloudD * 0.9) + t * 0.6);
      let n3 = Math.sin((px+py) * cloudD * 1.25 - t) * 0.5;
      let density = (n1 + n2 + n3) / 3;
      return density > thresh ? density : -1;
    }
    case 43: { // Aurora — vA: band frequency (3-12), vB: shimmer intensity (10-60)
      let bandF = 3 + vA * 9;
      let shimmerInt = 10 + vB * 50;
      let band = Math.sin(py * bandF - t * 0.5 + Math.sin(px * 4 + t * 0.3) * 0.5);
      let shimmer = Math.sin(px * shimmerInt + t * 3) * 0.3;
      let envelope = Math.exp(-((py - 0.35 - shimmer * 0.1)**2) * 30);
      return band * envelope;
    }
    case 44: { // Event Horizon — vA: warp strength (1-5), vB: accretion arms (4-16)
      let dx = px - 0.5, dy = py - 0.5;
      let dist = Math.sqrt(dx*dx + dy*dy);
      let angle = Math.atan2(dy, dx);
      let warpStr = 1 + vA * 4;
      let accArms = 4 + Math.floor(vB * 12);
      let warp = Math.pow(Math.max(0, 1 - dist * 2.5), 3);
      let frame = angle + warp * warpStr + t * 0.5;
      let accretion = Math.sin(frame * accArms) * warp;
      return dist < 0.08 ? -1 : accretion + Math.sin(dist * 50 - t * 4) * (1 - warp) * 0.3;
    }

    default:
      return 0;
  }
}

function render() {
  time += state.speed * 0.01;

  const w = canvas.width;
  const h = canvas.height;

  // Clear with slight trail effect
  ctx.fillStyle = `rgba(0,0,0,${0.1 + (100-state.glitchIntensity)*0.005})`;
  ctx.fillRect(0, 0, w, h);

  const cells = state.density;
  const cellW = w / cells;
  const cellH = h / cells;

  ctx.lineWidth = 1;

  // Handle Reaction Diffusion specially (pattern 28)
  if (state.pattern === 28) {
    const rdSize = Math.min(64, Math.floor(cells * 0.5) + 8);
    if (!rdA || rdW !== rdSize || rdH !== rdSize) initRD(rdSize, rdSize);
    for (let i = 0; i < 3; i++) stepRD();

    for (let y = 0; y < rdSize; y++) {
      for (let x = 0; x < rdSize; x++) {
        const val = rdA[y * rdSize + x] - rdB[y * rdSize + x];
        const px2 = x / rdSize, py2 = y / rdSize;
        const screenX = px2 * w;
        const screenY = py2 * h;
        const tileW = w / rdSize;
        const tileH = h / rdSize;

        let cx = screenX, cy = screenY;
        if (Math.random() * 100 < state.glitchIntensity) {
          cx += (Math.random() - 0.5) * tileW * 5;
          cy += (Math.random() - 0.5) * tileH * 5;
        }
        cx += (Math.random() - 0.5) * state.jitterMod * 0.5;
        cy += (Math.random() - 0.5) * state.jitterMod * 0.5;

        if (val > 0.1) {
          let hue = (state.colorShift + val * 180 + (x/rdSize)*90 + time*10) % 360;
          let saturation = state.colorIntensity; // 0-100%
          let lightness = 50; // Keep lightness at 50% for vibrancy
          ctx.fillStyle = `hsla(${hue}, ${saturation}%, ${lightness}%, 0.8)`;
          ctx.fillRect(cx, cy, tileW * (0.5 + val) * (state.scaleMod / 50), tileH * (0.5 + val) * (state.scaleMod / 50));
        }
      }
    }
    requestAnimationFrame(render);
    return;
  }

  for (let y = 0; y < cells; y++) {
    for (let x = 0; x < cells; x++) {
      let px = x / cells;
      let py = y / cells;

      let val = computePattern(px, py, state.pattern, time);

      // Add noise to pattern value
      if (state.noiseIntensity > 0) {
        val += (Math.random() - 0.5) * (state.noiseIntensity / 50);
        val = Math.max(-1, Math.min(1, val)); // Clamp to reasonable range
      }

      // Glitch effect
      let cx = x * cellW;
      let cy = y * cellH;
      if (Math.random() * 100 < state.glitchIntensity) {
        cx += (Math.random() - 0.5) * cellW * 5;
        cy += (Math.random() - 0.5) * cellH * 5;
      }
      cx += (Math.random() - 0.5) * state.jitterMod * 0.5;
      cy += (Math.random() - 0.5) * state.jitterMod * 0.5;

      if (val > 0) {
        let hue = (state.colorShift + (val * 180) + (x/cells)*90 + time*10) % 360;
        let saturation = state.colorIntensity; // 0-100%
        let lightness = 50; // Keep lightness at 50% for vibrancy
        ctx.fillStyle = `hsla(${hue}, ${saturation}%, ${lightness}%, 0.8)`;
        ctx.fillRect(cx, cy, cellW * (0.5 + val) * (state.scaleMod / 50), cellH * (0.5 + val) * (state.scaleMod / 50));
      }
    }
  }

  requestAnimationFrame(render);
}

// Load state from URL hash if present
function loadFromURL() {
  const hash = window.location.hash.slice(1);
  if (hash && (hash.length === 9 || hash.length === 13 || hash.length === 14 || hash.length === 18 || hash.length === 22)) {
    if (decodeState(hash)) return true;
  }
  return false;
}

window.addEventListener('hashchange', () => {
  loadFromURL();
});

// Init
const loadedFromHash = loadFromURL();
if (!loadedFromHash) {
  updateUIFromState();
  encodeState();
}
render();

