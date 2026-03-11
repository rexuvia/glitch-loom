# Glitch Loom

**Weave pixel-sorted and datamoshed strands into glitch art tapestries**

A browser-based generative art tool modeled on the metaphor of a weaving loom. Upload an image (or use the built-in generator), apply different glitch processing pipelines to create strands, then weave those strands together on a grid to produce unique glitch art tapestries.

## Features

### 🧵 Weave Patterns
- **Plain Weave** - Simple alternating pattern
- **Twill Weave** - Diagonal offset pattern
- **Satin Weave** - Long floats with few interlacings
- **Herringbone** - V-shaped pattern
- **Custom** - Paint your own pattern

### 🎨 Pixel Sorting (6 Metrics)
- **Brightness** - Luminance-weighted sorting
- **Hue** - Color wheel sorting
- **Saturation** - Intensity sorting
- **Red/Green/Blue** - Channel-specific sorting
- **Span-based** with threshold detection

### ⚡ Datamosh Effects (4 Types)
- **Block Displacement** - P-frame simulation
- **Channel Shift** - Chromatic aberration
- **Pixel Repeat** - Frozen frame effect
- **Feedback Loop** - Ghost echo trails

### 🎲 Procedural Generators
- **Gradient** - Smooth color transitions
- **Noise** - Sin-octave Perlin-like noise
- **Geometric** - Radial patterns
- **Plasma** - Wave interference
- **Fractal** - Mandelbrot exploration

### 🎞️ Animation & Export
- **Multi-frame GIF generation**
- **Forward/Ping-pong/Random** animation modes
- **Pure JS GIF encoder** (no libraries)
- **PNG export** for still images
- **Preset system** with 5 built-in presets

## Built-in Presets

1. **Cyberpunk** - Neon grids with channel shifts
2. **Vaporwave** - Pastel gradients with subtle sorting
3. **Glitch Noir** - High contrast, dramatic effects
4. **Aurora** - Northern lights simulation
5. **Inferno** - Fire-like heat maps
6. **Ocean Depths** - Deep blue aquatic patterns
7. **Forest Canopy** - Green organic textures
8. **Neon Grid** - Intense neon color grids
9. **Solar Flare** - Radiant sunburst effects
10. **Arctic Ice** - Cool icy blue tones
11. **Cyber Grid** - Futuristic digital grids
12. **Mystic Fog** - Ethereal purple mist
13. **Lava Flow** - Molten red and orange flows
14. **Electric Storm** - High-energy blue lightning
15. **Desert Sunset** - Warm desert twilight
16. **Crystal Cave** - Refractive crystal patterns
17. **Retro Arcade** - Classic 8-bit arcade colors

## How to Use

1. **Start with** an uploaded image or generated pattern
2. **Add strands** using the + buttons (warp = vertical, weft = horizontal)
3. **Configure each strand** with sorting/metrics or datamosh effects
4. **Choose a weave pattern** or paint a custom one
5. **Adjust colors** with the palette swatches
6. **Animate** with the animation controls
7. **Export** as PNG or animated GIF

## Technical Details

- **Single HTML file** - No external dependencies
- **Mobile-first responsive** design
- **Pure JavaScript** implementation
- **Canvas 2D** for all rendering
- **OffscreenCanvas** for performance
- **LZW compression** for GIF encoding

## Development

Created via the Rexuvia Daily Game Pipeline using multi-agent collaboration:
- **Ideation**: Grok, Kimi, Gemini
- **Architecture**: Claude Sonnet 4.6
- **Implementation**: Grok + Sonnet refinement
- **Deployment**: Automated to rexuvia.com

## Live Demo

Play online at: [https://rexuvia.com/games/glitch-loom.html](https://rexuvia.com/games/glitch-loom.html)

## License

MIT License - See LICENSE file for details