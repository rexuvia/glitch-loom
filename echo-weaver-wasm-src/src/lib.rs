use wasm_bindgen::prelude::*;

// Maximum limits to prevent browser freeze
const MAX_NODES: usize = 16;
const MAX_PULSES: usize = 64;
const MAX_CONNECTIONS: usize = 32;

#[wasm_bindgen]
pub struct Node {
    pub id: u32,
    pub x: f32,
    pub y: f32,
    pub node_type: u8, // 0=tone, 1=delay, 2=filter, 3=trigger
    pub freq: f32,
    pub glowing: bool,
    pub glow_timer: f32,
}

#[wasm_bindgen]
pub struct Pulse {
    pub id: u32,
    pub from_id: u32,
    pub to_id: u32,
    pub x: f32,
    pub y: f32,
    pub progress: f32,
    pub speed: f32,
    pub active: bool,
}

#[wasm_bindgen]
pub struct Connection {
    pub from_id: u32,
    pub to_id: u32,
    pub active: bool,
}

/// The main game engine state, managed in WASM for performance.
#[wasm_bindgen]
pub struct GameEngine {
    nodes: Vec<Node>,
    pulses: Vec<Pulse>,
    connections: Vec<Connection>,
    next_id: u32,
    bpm: f32,
    beat_timer: f32,
    beat_interval: f32,
    pub time_ms: f32,
    // Serialized output buffer for JS to read
    output_buffer: Vec<f32>,
    // Track which nodes fired this tick (for audio)
    fired_nodes: Vec<u32>,
}

#[wasm_bindgen]
impl GameEngine {
    #[wasm_bindgen(constructor)]
    pub fn new(bpm: f32) -> GameEngine {
        let beat_interval = 60000.0 / bpm;
        GameEngine {
            nodes: Vec::with_capacity(MAX_NODES),
            pulses: Vec::with_capacity(MAX_PULSES),
            connections: Vec::with_capacity(MAX_CONNECTIONS),
            next_id: 1,
            bpm,
            beat_timer: 0.0,
            beat_interval,
            time_ms: 0.0,
            output_buffer: Vec::with_capacity(512),
            fired_nodes: Vec::with_capacity(8),
        }
    }

    /// Add a node at position (x,y). Returns node id or 0 if at limit.
    #[wasm_bindgen]
    pub fn add_node(&mut self, x: f32, y: f32, node_type: u8) -> u32 {
        if self.nodes.len() >= MAX_NODES {
            return 0;
        }
        let id = self.next_id;
        self.next_id += 1;
        // Frequency based on type and position
        let freq = match node_type {
            0 => 220.0 + (x / 800.0) * 660.0, // tone: 220-880 Hz
            1 => 110.0 + (y / 600.0) * 220.0, // delay: 110-330 Hz
            2 => 440.0 + (x / 800.0) * 440.0, // filter: 440-880 Hz
            _ => 55.0,                           // trigger: low
        };
        self.nodes.push(Node {
            id,
            x,
            y,
            node_type,
            freq,
            glowing: false,
            glow_timer: 0.0,
        });
        id
    }

    /// Remove a node and all its connections/pulses
    #[wasm_bindgen]
    pub fn remove_node(&mut self, id: u32) {
        self.nodes.retain(|n| n.id != id);
        self.connections.retain(|c| c.from_id != id && c.to_id != id);
        self.pulses.retain(|p| p.from_id != id && p.to_id != id);
    }

    /// Move a node
    #[wasm_bindgen]
    pub fn move_node(&mut self, id: u32, x: f32, y: f32) {
        if let Some(n) = self.nodes.iter_mut().find(|n| n.id == id) {
            n.x = x;
            n.y = y;
        }
    }

    /// Connect two nodes. Returns false if already connected or at limit.
    #[wasm_bindgen]
    pub fn connect(&mut self, from_id: u32, to_id: u32) -> bool {
        if from_id == to_id { return false; }
        if self.connections.len() >= MAX_CONNECTIONS { return false; }
        // Check not already connected
        if self.connections.iter().any(|c| c.from_id == from_id && c.to_id == to_id) {
            return false;
        }
        self.connections.push(Connection { from_id, to_id, active: true });
        true
    }

    /// Set BPM
    #[wasm_bindgen]
    pub fn set_bpm(&mut self, bpm: f32) {
        self.bpm = bpm.max(40.0).min(300.0);
        self.beat_interval = 60000.0 / self.bpm;
    }

    /// Main update tick. delta_ms = milliseconds since last frame.
    /// Returns number of nodes that fired this tick (for audio).
    #[wasm_bindgen]
    pub fn tick(&mut self, delta_ms: f32) -> u32 {
        self.time_ms += delta_ms;
        self.fired_nodes.clear();

        // Update glow timers
        for n in self.nodes.iter_mut() {
            if n.glow_timer > 0.0 {
                n.glow_timer -= delta_ms;
                if n.glow_timer <= 0.0 {
                    n.glow_timer = 0.0;
                    n.glowing = false;
                }
            }
        }

        // Metronome: fire trigger nodes on beat
        self.beat_timer += delta_ms;
        if self.beat_timer >= self.beat_interval {
            self.beat_timer -= self.beat_interval;
            // Fire all trigger nodes (type 3)
            let trigger_ids: Vec<u32> = self.nodes.iter()
                .filter(|n| n.node_type == 3)
                .map(|n| n.id)
                .collect();
            for id in trigger_ids {
                self.fire_node(id);
            }
        }

        // Update pulses
        let mut arrived: Vec<(u32, u32)> = Vec::new(); // (pulse_id, to_node_id)
        for p in self.pulses.iter_mut() {
            if !p.active { continue; }
            p.progress += p.speed * delta_ms;
            if p.progress >= 1.0 {
                p.progress = 1.0;
                p.active = false;
                arrived.push((p.id, p.to_id));
            } else {
                // Update position by interpolating between from/to nodes
                let from_pos = self.nodes.iter().find(|n| n.id == p.from_id).map(|n| (n.x, n.y));
                let to_pos = self.nodes.iter().find(|n| n.id == p.to_id).map(|n| (n.x, n.y));
                if let (Some(from), Some(to)) = (from_pos, to_pos) {
                    p.x = from.0 + (to.0 - from.0) * p.progress;
                    p.y = from.1 + (to.1 - from.1) * p.progress;
                }
            }
        }

        // Handle arrivals - fire destination nodes
        for (pulse_id, to_id) in arrived {
            self.pulses.retain(|p| p.id != pulse_id);
            self.fire_node(to_id);
        }

        self.fired_nodes.len() as u32
    }

    /// Fire a node: make it glow and spawn pulses to its connections
    fn fire_node(&mut self, id: u32) {
        // Glow
        if let Some(n) = self.nodes.iter_mut().find(|n| n.id == id) {
            n.glowing = true;
            n.glow_timer = 150.0;
        }
        self.fired_nodes.push(id);

        // Spawn pulses to connected nodes (limit to avoid explosion)
        let outgoing: Vec<u32> = self.connections.iter()
            .filter(|c| c.from_id == id)
            .map(|c| c.to_id)
            .take(4) // Max 4 outgoing pulses per fire
            .collect();

        let pulse_speed = 1.0 / (self.beat_interval * 0.5);

        for to_id in outgoing {
            if self.pulses.iter().filter(|p| p.active).count() >= MAX_PULSES {
                break; // Don't add more pulses at limit
            }
            let from_pos = self.nodes.iter().find(|n| n.id == id).map(|n| (n.x, n.y));
            if let Some((fx, fy)) = from_pos {
                let pulse_id = self.next_id;
                self.next_id += 1;
                self.pulses.push(Pulse {
                    id: pulse_id,
                    from_id: id,
                    to_id,
                    x: fx,
                    y: fy,
                    progress: 0.0,
                    speed: pulse_speed,
                    active: true,
                });
            }
        }
    }

    /// Get node data as flat f32 array: [id, x, y, type, freq, glowing, ...]
    /// Format per node: 6 floats
    #[wasm_bindgen]
    pub fn get_nodes_buffer(&mut self) -> Vec<f32> {
        self.output_buffer.clear();
        for n in self.nodes.iter() {
            self.output_buffer.push(n.id as f32);
            self.output_buffer.push(n.x);
            self.output_buffer.push(n.y);
            self.output_buffer.push(n.node_type as f32);
            self.output_buffer.push(n.freq);
            self.output_buffer.push(if n.glowing { 1.0 } else { 0.0 });
        }
        self.output_buffer.clone()
    }

    /// Get pulse data as flat f32 array: [from_id, to_id, x, y, progress, ...]
    /// 5 floats per pulse, only active pulses
    #[wasm_bindgen]
    pub fn get_pulses_buffer(&mut self) -> Vec<f32> {
        self.output_buffer.clear();
        for p in self.pulses.iter().filter(|p| p.active) {
            self.output_buffer.push(p.from_id as f32);
            self.output_buffer.push(p.to_id as f32);
            self.output_buffer.push(p.x);
            self.output_buffer.push(p.y);
            self.output_buffer.push(p.progress);
        }
        self.output_buffer.clone()
    }

    /// Get connections buffer: [from_id, to_id, ...]
    #[wasm_bindgen]
    pub fn get_connections_buffer(&mut self) -> Vec<f32> {
        self.output_buffer.clear();
        for c in self.connections.iter() {
            self.output_buffer.push(c.from_id as f32);
            self.output_buffer.push(c.to_id as f32);
        }
        self.output_buffer.clone()
    }

    /// Get fired node IDs this tick for audio scheduling
    #[wasm_bindgen]
    pub fn get_fired_nodes(&mut self) -> Vec<f32> {
        self.output_buffer.clear();
        for &id in self.fired_nodes.iter() {
            // Get node freq too
            if let Some(n) = self.nodes.iter().find(|n| n.id == id) {
                self.output_buffer.push(id as f32);
                self.output_buffer.push(n.freq);
                self.output_buffer.push(n.node_type as f32);
            }
        }
        self.output_buffer.clone()
    }

    /// Get node count
    #[wasm_bindgen]
    pub fn node_count(&self) -> u32 {
        self.nodes.len() as u32
    }

    /// Clear all state
    #[wasm_bindgen]
    pub fn clear(&mut self) {
        self.nodes.clear();
        self.pulses.clear();
        self.connections.clear();
        self.beat_timer = 0.0;
    }

    /// Load a preset by index
    #[wasm_bindgen]
    pub fn load_preset(&mut self, preset: u32, width: f32, height: f32) {
        self.clear();
        let cx = width / 2.0;
        let cy = height / 2.0;

        match preset {
            0 => {
                // Simple: one trigger + one tone in a loop
                let t = self.add_node(cx - 100.0, cy, 3); // trigger
                let s = self.add_node(cx + 100.0, cy, 0); // tone
                self.connect(t, s);
                self.connect(s, t);
            }
            1 => {
                // Cascade: trigger fans out to 3 tones
                let t = self.add_node(cx, cy - 120.0, 3);
                let a = self.add_node(cx - 150.0, cy + 60.0, 0);
                let b = self.add_node(cx, cy + 60.0, 1);
                let c = self.add_node(cx + 150.0, cy + 60.0, 2);
                self.connect(t, a);
                self.connect(t, b);
                self.connect(t, c);
            }
            2 => {
                // Ring: 4 nodes in a circle passing pulses
                let a = self.add_node(cx, cy - 130.0, 3);
                let b = self.add_node(cx + 130.0, cy, 0);
                let c = self.add_node(cx, cy + 130.0, 1);
                let d = self.add_node(cx - 130.0, cy, 2);
                self.connect(a, b);
                self.connect(b, c);
                self.connect(c, d);
                self.connect(d, a);
            }
            _ => {
                // Dual triggers
                let t1 = self.add_node(cx - 150.0, cy - 80.0, 3);
                let t2 = self.add_node(cx + 150.0, cy + 80.0, 3);
                let f = self.add_node(cx, cy, 2);
                let s = self.add_node(cx, cy - 150.0, 0);
                self.connect(t1, f);
                self.connect(t2, f);
                self.connect(f, s);
                self.connect(s, t1);
            }
        }
    }
}
