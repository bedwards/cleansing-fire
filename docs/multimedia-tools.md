# Multimedia Content Generation Tools Research

## February 2026 Landscape Assessment

Research into free, cheap, local-first, and automatable tools for generating multimedia
content at scale. Every tool evaluated against these criteria:

- **Cost**: Free / open-source / cheap tier pricing
- **Local**: Can it run on local hardware without cloud dependency?
- **Automatable**: CLI, API, or scriptable interface for agent-driven pipelines?
- **Integration**: Compatibility with our stack (Python, Ollama, plugins, gatekeeper)
- **Hardware**: What does it need? Especially: can it run on Mac with Apple Silicon?

---

## 1. IMAGE GENERATION

### 1.1 Stable Diffusion Ecosystem

The Stable Diffusion ecosystem remains the most mature local image generation option.

**Models (February 2026):**
- **SDXL** - 6.6B params, the workhorse. Well-supported, huge LoRA ecosystem
- **SD 3.5** - Stability AI's latest, improved text rendering and composition
- **FLUX.1 Dev** - 12B params from Black Forest Labs (the original SD creators). Open weights, Apache 2.0 for Schnell variant
- **FLUX.2 Dev** - 32B params, released November 2025. Open weights, supports both generation and editing
- **FLUX.2 Klein** - 4B/9B params, released January 2026. Sub-second generation on consumer GPUs. 4B variant is Apache 2.0 (full commercial use). Fits in ~8GB VRAM

**Interfaces:**
- **ComfyUI** - Node-based workflow editor. The power-user choice. Supports all models, ControlNet, LoRAs, inpainting, upscaling. Complex workflows can be saved as JSON and executed via CLI/API. Has a REST API. **This is our best bet for automated image pipelines.**
  - GitHub: https://github.com/comfyanonymous/ComfyUI
  - Can run headless, workflows are JSON files, perfect for automation
  - CLI: `python main.py --listen 0.0.0.0 --port 8188`
  - API: POST workflow JSON to `/prompt` endpoint

- **AUTOMATIC1111 / Forge** - Web UI with REST API. Simpler than ComfyUI but less flexible. Forge is a performance-optimized fork. Good for one-off generation but ComfyUI is better for pipelines.

- **Draw Things** (Mac App Store) - Free, well-optimized for Apple Silicon. Supports SD 1.5, SDXL, FLUX variants, ControlNet, LoRAs. Best casual Mac option but NOT automatable (no CLI/API).

- **Stability Matrix** - One-click launcher for ComfyUI / A1111 / InvokeAI. Good for setup, not for automation.

**Mac Hardware Requirements:**
- FLUX.2 Klein 4B: Runs on 16GB RAM Macs via MLX or ComfyUI
- SDXL: 16GB RAM minimum, 32GB recommended
- FLUX.1 Dev (12B): 32GB RAM recommended
- FLUX.2 Dev (32B): Needs 64GB+ RAM or quantized versions
- Apple Silicon M1/M2/M3 all supported via MPS (Metal Performance Shaders)

**Verdict**: ComfyUI + FLUX.2 Klein is the sweet spot. Fast, free, automatable, runs on modest hardware. For higher quality, FLUX.1 Dev or SDXL with good LoRAs.

### 1.2 Ollama Image Generation (NEW - January 2026)

Ollama added experimental image generation support on January 20, 2026. This is a game-changer for our architecture since we already have the gatekeeper daemon managing Ollama.

**Supported models:**
- **Z-Image Turbo** (Alibaba) - 6B params, photorealistic output, bilingual EN/CN text rendering. Sub-second inference. Needs 12-16GB VRAM.
  - `ollama run z-image-turbo`
- **FLUX.2 Klein** (Black Forest Labs) - Same model as above but through Ollama's interface. 4B and 9B variants.
  - `ollama run flux2-klein`

**Integration with our stack:**
This plugs directly into the gatekeeper daemon. Image generation tasks can be submitted the same way as text tasks. The gatekeeper already serializes GPU access, so contention is handled.

```python
# Hypothetical gatekeeper integration
import requests
response = requests.post("http://localhost:7800/submit-sync", json={
    "model": "flux2-klein",
    "prompt": "protest march downtown, photojournalistic style",
    "type": "image"
})
```

**Verdict**: Highest priority integration. Uses existing infrastructure. The gatekeeper already handles GPU serialization.

### 1.3 SVG Generation via Code

For diagrams, infographics, and stylized graphics, code-generated SVGs are more controllable and reproducible than diffusion models.

**Libraries:**

- **D3.js** - The gold standard for data-driven SVGs. Can generate standalone SVG files via Node.js (no browser needed with jsdom). Free, MIT license.
  - CLI: `node generate-chart.js > output.svg`
  - Perfect for data visualizations, network diagrams, flow charts

- **Rough.js** (<9kB) - Creates hand-drawn, sketchy aesthetic SVGs. Lines, curves, shapes all look like they were drawn by hand. Great for making data visualizations feel human and approachable rather than corporate.
  - GitHub: https://github.com/rough-stuff/rough
  - **Svg2Rough.js** can convert any clean SVG into hand-drawn style
  - MIT license, works in Node.js

- **Mermaid.js** - Diagrams-as-code. Flowcharts, sequence diagrams, Gantt charts, entity relationships, all from Markdown-like text. Has a CLI tool (`@mermaid-js/mermaid-cli`) that renders to SVG/PNG/PDF.
  - `npx mmdc -i diagram.mmd -o output.svg`
  - Perfect for automated diagram generation from structured data
  - LLMs can write Mermaid syntax directly
  - Current version: 11.x (February 2026)

**Verdict**: D3.js for data visualizations, Mermaid for diagrams, Rough.js for humanized aesthetic. All automatable via Node.js CLI. LLMs can generate the code directly.

### 1.4 Meme Generation

- **Imgflip API** - Free tier for basic meme generation via REST API. Premium ($) needed for search and AI meme features. The free `/caption_image` endpoint takes a template ID + text and returns an image URL.
  - Free: generate memes from ~100 popular templates
  - Premium: $0.02/meme for AI-generated memes, search

- **memegen** (open source) - Self-hosted meme API. Stateless: URLs encode all meme parameters. No API key needed.
  - GitHub: https://github.com/jacebrowning/memegen
  - Can be run as a local Docker container
  - `GET /images/picard/top_text/bottom_text.png`

- **DIY with Pillow** - Python's PIL/Pillow library can overlay text on images programmatically. Zero external dependencies beyond the library itself. Full control over fonts, positioning, effects.

**Verdict**: Self-hosted memegen for template memes, Pillow for custom formats. Both fully automatable.

### 1.5 ASCII Art

- **pyfiglet** - Pure Python FIGlet port. Renders text in ASCII art fonts. `pip install pyfiglet`
  - `pyfiglet -f slant "CLEANSING FIRE"`
  - 500+ fonts included
  - Python API: `pyfiglet.figlet_format("text", font="slant")`

- **cowsay** - Classic quote-bubble ASCII art. Python port available.

- **art** Python package - Additional ASCII art capabilities beyond figlet.

**Verdict**: pyfiglet for banners and headers. Trivial to integrate. Good for terminal-based content and social media text posts.

---

## 2. MUSIC / AUDIO GENERATION

### 2.1 MusicGen / AudioCraft (Meta)

The strongest local option for AI music generation.

- **What**: Transformer-based music generation from text prompts. Part of Meta's AudioCraft library.
- **Models**: Small (300M), Medium (1.5B), Large (3.3B). All on Hugging Face.
- **License**: Code is MIT. Model weights are CC-BY-NC 4.0 (non-commercial).
- **Hardware**: 16GB GPU recommended for large model. Small model runs on ~4GB.
- **Local**: Yes, fully local. `pip install audiocraft`
- **Automation**: Python API. No web UI needed.

```python
from audiocraft.models import MusicGen
model = MusicGen.get_pretrained('facebook/musicgen-medium')
model.set_generation_params(duration=30)
wav = model.generate(["epic orchestral protest anthem, rising tension, drums"])
```

- **Quality**: Good for background music, ambient soundscapes, mood pieces. Not ready for polished songs with lyrics.
- **Mac**: Runs on Apple Silicon via MPS. Medium model works on 16GB Macs.

**Verdict**: Best local option. Non-commercial license is a limitation but fine for advocacy content. Can generate 30-second clips automatically.

### 2.2 Bark (Suno)

Text-to-speech with emotion, music, and sound effects.

- **What**: Transformer-based text-to-audio. Generates realistic speech with emotion, laughter, sighing, crying. Can also generate music snippets and sound effects.
- **License**: MIT (fully open, commercial OK)
- **Hardware**: Full model needs ~12GB GPU. Smaller configs work on ~2GB.
- **Local**: Yes. `pip install git+https://github.com/suno-ai/bark.git`
- **Automation**: Python API.

```python
from bark import generate_audio, SAMPLE_RATE
audio = generate_audio(
    "[laughs] The senator says he represents the people! [sighs] "
    "While taking millions from corporations.",
    history_prompt="v2/en_speaker_6"
)
```

- **Features**: 100+ speaker presets, multilingual, emotional prosody, non-verbal sounds
- **Mac**: Runs on Apple Silicon

**Verdict**: Excellent for narration with attitude. MIT license. Perfect for voiceovers on video content, satirical audio pieces.

### 2.3 Suno AI / Udio (Cloud, Free Tiers)

Cloud-based AI music generation with vocals and lyrics.

- **Suno AI**:
  - Free tier: 50 credits/day (~10 songs/day). Resets daily, no accumulation.
  - Free songs: personal use only, no commercial rights
  - Pro: $10/month for commercial rights
  - Quality: Very high. Full songs with vocals, lyrics, multiple genres
  - API: No official public API for automation. Web-only.

- **Udio**:
  - Free tier: 100 monthly credits + 10 daily
  - $10/month for most features
  - Similar quality to Suno

**Verdict**: Good for occasional high-quality songs. NOT automatable (no API). NOT local. Use for one-off anthem creation, not pipeline content.

### 2.4 Sonic Pi

Code-based live music generation using Ruby.

- **What**: Live-coding music synth. Write Ruby code, hear music in real-time.
- **License**: Free, open source
- **Local**: Yes, fully local
- **Backend**: SuperCollider synthesis engine
- **Automation**: CLI tool (`sonic-pi-cli` gem) sends OSC messages to running Sonic Pi instance. Also has an MCP server (March 2025) for AI agent integration.
- **Mac**: Native macOS app

```ruby
# Generative ambient soundscape
live_loop :ambient do
  play scale(:e3, :minor_pentatonic).choose, release: rand(4), amp: 0.3
  sleep [0.5, 1, 1.5, 2].choose
end
```

**Verdict**: Unique capability for generative/procedural music. The MCP server integration means Claude agents can compose music directly. Good for ambient soundscapes and generative pieces.

### 2.5 CLI Audio Tools

- **sox** - Swiss army knife of audio. Convert, trim, concatenate, add effects. `brew install sox`
- **ffmpeg** - Also handles audio. Extract audio from video, convert formats, mix tracks.
- **espeak-ng** - Free text-to-speech engine. Robotic but fast and fully local. Good for effect.

**Verdict**: sox + ffmpeg for audio pipeline plumbing. espeak-ng for quick-and-dirty TTS.

---

## 3. VIDEO GENERATION / EDITING

### 3.1 Local AI Video Generation (2026 State of the Art)

This space has exploded. Consumer-GPU video generation is now real.

**Top Models:**

- **LTX-2** (Lightricks + NVIDIA) - Up to 20 seconds of 4K video at 50 FPS on a single consumer GPU. Runs on 12GB VRAM (better with 48GB). Free commercial use for companies under $10M ARR.

- **Wan-2.2** - Leading open-source video model in early 2026. The small T2V-1.3B variant needs only 8.19GB VRAM, compatible with almost all consumer GPUs. Multiple variants for different quality/speed tradeoffs.

- **CogVideoX** - Runs well on consumer GPUs. Good quality short clips.

- **Open-Sora** - Democratizing video production. Multiple model sizes.

**Best Interface**: ComfyUI supports all of these models. Same workflow-as-JSON automation approach as image generation.

**Mac Support**: Limited. Most video models need NVIDIA CUDA. Apple Silicon support is emerging but not mature. Best to run on a Linux box with an NVIDIA GPU if available.

**Verdict**: Wan-2.2 (small) is the most accessible. LTX-2 for higher quality. Both through ComfyUI. Short clips (5-20 seconds) are practical now.

### 3.2 FFmpeg (Programmatic Video Editing)

The backbone of any automated video pipeline.

- **What**: Command-line video/audio processing. Transcode, cut, concatenate, overlay, filter, watermark, extract frames, generate thumbnails.
- **License**: LGPL/GPL, free
- **Local**: Yes. `brew install ffmpeg`
- **Automation**: Pure CLI. Infinitely scriptable.

```bash
# Combine image slideshow with audio
ffmpeg -framerate 1/5 -i img%03d.png -i narration.mp3 \
  -c:v libx264 -pix_fmt yuv420p -shortest output.mp4

# Add text overlay
ffmpeg -i input.mp4 -vf "drawtext=text='FOLLOW THE MONEY':fontsize=48:\
  fontcolor=white:x=(w-text_w)/2:y=50" output.mp4

# Create video from single image + audio
ffmpeg -loop 1 -i background.png -i audio.mp3 -c:v libx264 \
  -tune stillimage -c:a copy -shortest video.mp4
```

**Verdict**: Essential infrastructure. Every video pipeline uses ffmpeg. Python wrapper: `ffmpeg-python`.

### 3.3 Remotion (React-Based Video)

Programmatic video creation using React components.

- **What**: Each video frame is a React component. Write code, render to MP4.
- **License**: Free for individuals and teams up to 3 people (including commercial use). $100/month for larger teams.
- **Local**: Yes, renders locally
- **Automation**: Full CLI. `npx remotion render src/index.ts MyVideo out.mp4`
- **Use cases**: Data-driven videos, personalized content, animated infographics, social media videos

```tsx
// A data-driven video component
export const CorruptionTimeline: React.FC = () => {
  const frame = useCurrentFrame();
  const data = useVideoData(); // Load from JSON
  return (
    <AbsoluteFill style={{ background: '#1a1a1a' }}>
      <AnimatedChart data={data} progress={frame / 300} />
      <Title text="Where Your Tax Dollars Actually Go" />
    </AbsoluteFill>
  );
};
```

**Verdict**: Excellent for data-driven social media videos. The React model means web developers can create video templates. Fully automatable. High priority for automated content pipelines.

### 3.4 Manim (Mathematical Animation)

3Blue1Brown's animation engine, now with AI integration.

- **What**: Python library for creating precise, beautiful mathematical/explanatory animations.
- **License**: MIT (Community Edition)
- **Local**: Yes. `pip install manim`. Requires ffmpeg and optionally LaTeX.
- **Automation**: Full Python API. Each animation is a Python script.
- **New in 2025-2026**: Generative Manim project uses LLMs (GPT-4o, Claude) to generate Manim scripts from natural language descriptions.

```python
from manim import *

class MoneyFlow(Scene):
    def construct(self):
        # Animate money flowing from taxpayers to corporate interests
        taxpayer = Circle(color=BLUE).shift(LEFT * 3)
        corporation = Circle(color=RED).shift(RIGHT * 3)
        arrow = Arrow(taxpayer, corporation, color=GREEN)
        dollar = Text("$1.2 Trillion", font_size=24).next_to(arrow, UP)
        self.play(Create(taxpayer), Create(corporation))
        self.play(GrowArrow(arrow), Write(dollar))
```

- Render: `manim -ql script.py MoneyFlow` (quick low quality) or `-qh` (high quality)

**Verdict**: Perfect for explainer content. "Here's how the money moves." LLM can generate the Python scripts. Beautiful output.

### 3.5 Motion Canvas

TypeScript-based programmatic animation focused on educational/informative content.

- **What**: Create informative vector animations synchronized with voiceover.
- **License**: Free, open source (MIT)
- **Local**: Yes, Node.js-based
- **Automation**: Scriptable, all animations are TypeScript code

**Verdict**: Alternative to Manim for TypeScript-preferring teams. Similar niche.

### 3.6 Editly

Declarative video editing via JSON/CLI.

- **What**: Node.js tool for declarative NLE (non-linear editing). Define video structure as JSON, render with ffmpeg.
- **License**: MIT
- **Automation**: Full CLI + Node.js API

```json
{
  "clips": [
    { "layers": [{ "type": "title-background", "text": "Follow the Money" }] },
    { "layers": [{ "type": "image", "path": "chart.png" }] },
    { "layers": [{ "type": "title-background", "text": "Your Representatives Exposed" }] }
  ]
}
```

**Verdict**: Good for rapid slideshow/title-card videos from structured data. Simpler than Remotion but less powerful.

### 3.7 DaVinci Resolve (Free Tier)

Professional NLE with scripting.

- **What**: Full-featured video editor from Blackmagic Design. Free tier is very capable.
- **Scripting**: Python and Lua APIs. Can automate import, timeline creation, color grading, rendering.
- **Limitation**: Free version has restricted API access (cannot create new script connections externally). Headless mode (`-nogui`) works for batch processing.
- **Mac**: Native Apple Silicon support

**Verdict**: Good for human-in-the-loop polish. Limited automation in free tier. Not ideal for fully automated pipelines.

---

## 4. DATA VISUALIZATION / CHARTS

### 4.1 JavaScript Libraries (Web-Based)

**D3.js** (Data-Driven Documents)
- The most powerful visualization library. Period.
- SVG, Canvas, or HTML output
- Free, BSD license
- Can run server-side with Node.js + jsdom to generate static SVGs
- Steep learning curve but unlimited flexibility
- Perfect for: money flow Sankey diagrams, voting pattern heatmaps, network graphs of power relationships
- https://d3js.org/

**Chart.js**
- Simpler than D3. Good defaults, responsive, animated.
- Canvas-based (not SVG)
- Free, MIT license
- Best for standard chart types (bar, line, pie, radar)
- https://www.chartjs.org/

**Plotly.js**
- Interactive charts with zoom, hover tooltips, toggle legends
- Free, MIT license
- Server-side rendering possible
- Best for interactive dashboards

**Mermaid.js**
- Diagrams from text/Markdown
- CLI rendering to SVG/PNG/PDF: `npx mmdc -i input.mmd -o output.svg`
- Perfect for: flowcharts, sequence diagrams, Gantt charts, entity relationships
- LLMs can write Mermaid syntax natively
- Current: v11.x

### 4.2 Python Libraries

**Matplotlib**
- The foundational Python plotting library
- Publication-quality static charts
- Fully scriptable, no UI needed
- `pip install matplotlib`
- Extensive customization but verbose API
- Best for: static charts for reports and social media images

**Plotly (Python)**
- Interactive charts in Python
- `pip install plotly`
- Can export to static images (PNG, SVG, PDF) or interactive HTML
- Plotly Express for quick charts, Graph Objects for full control
- Dash framework for interactive dashboards

**Altair**
- Declarative statistical visualization
- Based on Vega-Lite specification
- Excellent for exploratory data analysis
- Concise API, good defaults
- `pip install altair`

**Seaborn**
- Statistical visualization built on matplotlib
- Beautiful defaults for statistical plots
- Great for correlation matrices, distributions, categorical data

### 4.3 Specific Visualization Types for Our Use Cases

**Money Flows / Financial Networks:**
- D3.js Sankey diagrams (donor -> PAC -> candidate flows)
- Plotly Sankey charts (Python API available)
- Cytoscape.js for network visualization of financial relationships

**Legislative Voting Patterns:**
- D3.js heatmaps (legislator x bill matrices)
- Plotly clustered heatmaps
- Custom chord diagrams showing voting blocs

**Power Networks / Influence Maps:**
- Sigma.js (WebGL, handles thousands of nodes, best performance)
- Cytoscape.js (graph algorithms built in, easier API)
- D3.js force-directed layouts

**Timelines:**
- vis-timeline (community fork of vis.js)
- D3.js custom timelines
- TimelineJS (Northwestern Knight Lab) - narrative timelines from spreadsheets

**Verdict**: Python Plotly for automated chart generation in our pipelines (same language as our stack). D3.js for web-published interactive content. Mermaid for quick diagrams.

---

## 5. INTERACTIVE CONTENT

### 5.1 Observable Framework

Static site generator for data apps and dashboards.

- **What**: Markdown pages with reactive JavaScript. Data loaders precompute data at build time. Interactive charts load instantly.
- **License**: ISC (free, open source)
- **Local**: Yes, builds to static files
- **Automation**: `npm run build` produces a static site. Data loaders can be Python, R, SQL, shell scripts.
- **Integration**: Data loaders can call Python scripts, so our analysis code feeds directly into visualizations.

```markdown
# Campaign Finance Dashboard

```js
const donations = FileAttachment("data/donations.csv").csv({typed: true});
Plot.plot({
  marks: [
    Plot.barY(donations, {x: "candidate", y: "amount", fill: "source"})
  ]
})
```
```

**Verdict**: Excellent for publishing interactive data stories. Data loaders bridge Python analysis to JavaScript visualization. Free, self-hostable.

### 5.2 Scrollytelling (Scrollama)

Scroll-driven interactive narratives.

- **What**: JavaScript library using IntersectionObserver to trigger visual changes as user scrolls. Lightweight (~3KB).
- **License**: MIT, free
- **Current version**: 3.2.0
- **Integration**: Pairs with D3.js for data-driven scroll stories

Use case: "As you scroll, watch how campaign donations from the fossil fuel industry correlate with environmental votes..."

**Verdict**: Perfect for long-form investigative data journalism pieces. Combine with D3.js and Observable Framework.

### 5.3 Network Graphs

For visualizing connections between people, organizations, money flows.

- **Sigma.js** - WebGL-based, handles very large graphs (thousands of nodes) with smooth performance. Uses graphology library for data structure. Best for large datasets.
  - https://www.sigmajs.org/

- **Cytoscape.js** - Graph theory library with built-in algorithms (shortest path, clustering, centrality). Easier API than Sigma. Built-in layouts.
  - https://js.cytoscape.org/

- **vis-network** - Community-maintained fork of vis.js. Drag-and-drop, good defaults. Easiest to get started but slowest for large graphs.

**Verdict**: Sigma.js for large power-network visualizations (thousands of entities). Cytoscape.js for smaller, more analytical graphs where we need graph algorithms.

### 5.4 Map Visualizations

For geographic data: district-level voting, facility locations, environmental impact zones.

- **Leaflet** - Most popular open-source mapping library. 42KB, zero dependencies. 1.4M+ monthly npm downloads. Simple API.
  - https://leafletjs.com/

- **MapLibre GL** - Open-source fork of Mapbox GL. Vector tile rendering via WebGL. Growing rapidly since mid-2024.
  - https://maplibre.org/

- **OpenFreeMap** - Free map tile server. No API key needed. Use with Leaflet or MapLibre.
  - https://openfreemap.org/

- **OpenMapTiles** - Self-hostable vector tiles from OpenStreetMap data.
  - https://openmaptiles.org/

**Verdict**: Leaflet for simple maps, MapLibre for rich vector maps. OpenFreeMap for free tiles without API keys. All fully free and self-hostable.

### 5.5 Interactive Timelines

- **TimelineJS** (Knight Lab) - Create timelines from Google Sheets or JSON. Embeddable. Free. Good for narrative timelines of corruption, legislative history.
- **vis-timeline** - Programmable timeline component. Drag, zoom, group items.
- **Custom D3.js** - Most flexible but most work.

---

## 6. AUTOMATED CONTENT PIPELINES

### 6.1 The Full Pipeline Vision

```
Data Sources          Analysis              Visualization        Distribution
─────────────         ────────              ─────────────        ────────────
OpenSecrets API  ──→  Python analysis  ──→  Plotly charts   ──→  Static images
Congress API     ──→  Ollama summaries ──→  D3.js interactives → Web pages
Court records    ──→  Pattern detection ──→ Manim animations ──→ Video
News RSS feeds   ──→  Sentiment analysis ──→ Mermaid diagrams ──→ Social media
Financial data   ──→  Network analysis ──→  Sigma.js graphs ──→  Newsletter
```

### 6.2 Pipeline 1: Data -> Chart -> Social Media Image

Fully automatable today with existing tools.

```python
# 1. Fetch data (Python)
import requests
data = requests.get("https://api.opensecrets.org/...").json()

# 2. Analyze (Python + Ollama via gatekeeper)
analysis = requests.post("http://localhost:7800/submit-sync", json={
    "prompt": f"Analyze this campaign finance data and identify the top 5 most concerning patterns: {data}"
}).json()

# 3. Generate chart (Python + Plotly)
import plotly.express as px
fig = px.bar(df, x="candidate", y="corporate_donations", title="Who's Bought?")
fig.write_image("chart.png", width=1200, height=630)  # Social media dimensions

# 4. Add context text overlay (Pillow)
from PIL import Image, ImageDraw, ImageFont
img = Image.open("chart.png")
draw = ImageDraw.Draw(img)
draw.text((50, 550), analysis["summary"], fill="white")
img.save("social_post.png")

# 5. Post (CLI tools or API)
# Could use platform APIs, scheduled posting tools, etc.
```

### 6.3 Pipeline 2: Data -> Analysis -> Animated Explainer Video

```bash
#!/bin/bash
# 1. Fetch and analyze data
python3 analyze_votes.py --output data.json

# 2. Generate Manim animation script via Ollama
python3 -c "
import requests, json
data = json.load(open('data.json'))
resp = requests.post('http://localhost:7800/submit-sync', json={
    'prompt': f'Write a Manim Python script that animates this voting data as a bar chart race: {json.dumps(data[:20])}'
})
with open('animation.py', 'w') as f:
    f.write(resp.json()['result'])
"

# 3. Render animation
manim -qh animation.py VotingAnimation

# 4. Generate narration with Bark
python3 generate_narration.py --text "Here's how your representatives actually voted..."

# 5. Combine with FFmpeg
ffmpeg -i media/videos/VotingAnimation/1080p60/VotingAnimation.mp4 \
       -i narration.wav -c:v copy -c:a aac -shortest final.mp4
```

### 6.4 Pipeline 3: RSS -> AI Analysis -> Image -> Post

```python
# Automated news monitoring and response pipeline
import feedparser

# 1. Monitor RSS feeds
feed = feedparser.parse("https://example.com/politics/rss")

for entry in feed.entries[:5]:
    # 2. Analyze via Ollama
    analysis = gatekeeper_submit_sync(
        f"Analyze this headline for corporate influence angles: {entry.title}\n{entry.summary}"
    )

    # 3. Generate response image via Ollama (FLUX.2 Klein)
    image = gatekeeper_submit_sync(
        prompt=f"Editorial cartoon style: {analysis['visual_concept']}",
        model="flux2-klein",
        type="image"
    )

    # 4. Or generate meme via memegen
    meme_url = f"http://localhost:5000/images/custom/{quote(analysis['top_text'])}/{quote(analysis['bottom_text'])}.png"

    # 5. Queue for review or auto-post
    save_to_queue(image, analysis, entry)
```

### 6.5 Pipeline 4: Interactive Data Story

Using Observable Framework for a full investigative piece.

```
project/
├── src/
│   ├── index.md              # Main narrative with scrollytelling
│   ├── data/
│   │   ├── donations.csv.py  # Python data loader
│   │   ├── votes.csv.py      # Python data loader
│   │   └── network.json.py   # Python network analysis
│   └── components/
│       ├── sankey.js          # D3 Sankey diagram
│       ├── network.js         # Sigma.js network graph
│       └── timeline.js        # Interactive timeline
├── observablehq.config.js
└── package.json
```

Data loaders run Python scripts at build time, generating static data snapshots. The JavaScript components render interactive visualizations. The whole thing builds to a static site deployable anywhere.

### 6.6 Tool Chain Summary for Automation

| Step | Tool | Automatable | Language |
|------|------|-------------|----------|
| Data fetching | Python requests/scrapy | CLI/API | Python |
| Text analysis | Ollama via gatekeeper | API | Python |
| Chart generation | Plotly / matplotlib | API | Python |
| Diagram generation | Mermaid CLI | CLI | Text/Markdown |
| Image generation | Ollama FLUX.2 / ComfyUI | API | Python |
| SVG generation | D3.js + Node.js | CLI | JavaScript |
| Narration | Bark | API | Python |
| Music | MusicGen / AudioCraft | API | Python |
| Animation | Manim | CLI | Python |
| Video composition | FFmpeg | CLI | Shell |
| Video rendering | Remotion | CLI | TypeScript |
| Meme creation | memegen / Pillow | API | Python |
| Interactive stories | Observable Framework | CLI build | JS + Python |
| Network graphs | Sigma.js / Cytoscape.js | Web | JavaScript |
| Maps | Leaflet / MapLibre | Web | JavaScript |
| ASCII art | pyfiglet | CLI/API | Python |

---

## 7. RECOMMENDED PRIORITY ORDER

### Immediate (Already Compatible with Our Stack)

1. **Ollama image generation** (FLUX.2 Klein, Z-Image Turbo) - Plugs into gatekeeper directly
2. **Plotly** (Python charts) - Same language as our stack, `pip install plotly`
3. **Mermaid CLI** - Diagrams from text, LLMs write the syntax naturally
4. **pyfiglet** - Trivial to add, good for terminal/text content
5. **FFmpeg** - Essential plumbing, `brew install ffmpeg`
6. **Pillow** - Image manipulation, text overlays, meme creation

### Short-Term (Minimal Setup)

7. **Bark** - Narration with emotion, MIT license, Python API
8. **MusicGen** - Background music generation, Python API
9. **Manim** - Animated explainers, Python, LLM can generate scripts
10. **ComfyUI** - Advanced image generation workflows, REST API
11. **memegen** - Self-hosted meme API

### Medium-Term (New Infrastructure)

12. **Remotion** - React-based video generation (needs Node.js pipeline)
13. **Observable Framework** - Interactive data stories (needs Node.js build)
14. **D3.js** - Complex interactive visualizations (needs web publishing)
15. **Scrollama** - Scrollytelling narratives (needs web publishing)
16. **Sigma.js / Cytoscape.js** - Network graphs (needs web publishing)
17. **Leaflet / MapLibre** - Geographic visualizations (needs web publishing)

### Situational

18. **Sonic Pi** - Generative music (unique but niche)
19. **Wan-2.2 / LTX-2** - AI video generation (needs NVIDIA GPU)
20. **Motion Canvas** - TypeScript animations (alternative to Manim)
21. **Suno AI / Udio** - High-quality songs (cloud, manual, limited free tier)
22. **DaVinci Resolve** - Video polish (human-in-the-loop)

---

## 8. HARDWARE CONSIDERATIONS

### Mac with Apple Silicon (M1/M2/M3/M4)

**Works well:**
- Ollama (all models including image generation)
- Stable Diffusion / FLUX via ComfyUI (MPS backend)
- Bark (MPS backend)
- MusicGen small/medium (MPS backend)
- All Python visualization libraries
- FFmpeg, Remotion, Manim
- All JavaScript tools (Node.js)

**Works but slower:**
- FLUX.1 Dev (12B) - needs 32GB+ RAM Mac
- MusicGen large - slow on MPS vs CUDA
- SDXL with large LoRA stacks

**Does not work well:**
- AI video generation (LTX-2, Wan-2.2) - need NVIDIA CUDA
- FLUX.2 Dev (32B) - needs 64GB+ RAM

### Ideal Budget Setup for Scale

- Mac with 32GB+ RAM for development and light generation
- One Linux box with NVIDIA RTX 4090 (24GB VRAM) for heavy AI generation
- Both running Ollama, gatekeeper manages GPU access on each

### No-Cost Option

Everything above marked "Immediate" and "Short-Term" runs on a single Mac with 16GB RAM. The entire Python pipeline (Ollama + Plotly + Bark + Manim + FFmpeg + Pillow) needs zero cloud spending.

---

## 9. KEY ARCHITECTURAL INSIGHT

The gatekeeper daemon is the linchpin. By routing all GPU-intensive tasks through the gatekeeper:

1. **Image generation** (Ollama FLUX.2 Klein) serializes with text tasks
2. **Audio generation** (Bark, MusicGen) can be added as task types
3. **Chart generation** (Plotly) runs on CPU, no contention
4. **Video rendering** (FFmpeg, Manim) runs on CPU, no contention
5. **AI analysis** (Ollama text models) already works

A plugin architecture for multimedia generation:

```
plugins/
├── generate-chart.py      # Plotly chart from data JSON
├── generate-diagram.py    # Mermaid diagram from description
├── generate-image.py      # Ollama FLUX.2 image from prompt
├── generate-narration.py  # Bark TTS from text
├── generate-music.py      # MusicGen from description
├── generate-animation.py  # Manim script from description
├── generate-meme.py       # memegen/Pillow meme from template+text
├── compose-video.py       # FFmpeg composition from assets
└── generate-ascii.py      # pyfiglet ASCII art
```

Each plugin: accepts JSON stdin, produces JSON stdout (with file paths to generated assets). Fits the existing plugin architecture exactly.

---

## SOURCES

### Image Generation
- [Best Open-Source Image Generation Models 2026 - BentoML](https://www.bentoml.com/blog/a-guide-to-open-source-image-generation-models)
- [FLUX Local Setup Guide 2026](https://localaimaster.com/blog/flux-local-image-generation)
- [FLUX.2 Klein Launch - VentureBeat](https://venturebeat.com/technology/black-forest-labs-launches-open-source-flux-2-klein-to-generate-ai-images-in)
- [Local SD Toolkits for macOS](https://slavadubrov.github.io/blog/2025/05/10/quick-guide-on-local-stable-diffusion-toolkits-for-macos/)
- [FLUX vs Stable Diffusion 2026](https://pxz.ai/blog/flux-vs-stable-diffusion:-technical-&-real-world-comparison-2026)
- [Ollama Image Generation - GIGAZINE](https://gigazine.net/gsc_news/en/20260123-ollama-ai-image-generation/)
- [Ollama Image Generation Deployment](https://www.adwaitx.com/ollama-local-image-generation-z-image-flux2/)
- [Rough.js](https://roughjs.com/)
- [Svg2Rough.js - GitHub](https://github.com/fskpf/svg2roughjs)
- [Imgflip API](https://imgflip.com/api)
- [memegen - GitHub](https://github.com/jacebrowning/memegen)
- [Mermaid.js](https://mermaid.js.org/)
- [Mermaid CLI - GitHub](https://github.com/mermaid-js/mermaid-cli)

### Music / Audio
- [AudioCraft / MusicGen - Meta](https://ai.meta.com/resources/models-and-libraries/audiocraft/)
- [AudioCraft GitHub](https://github.com/facebookresearch/audiocraft)
- [Bark - GitHub](https://github.com/suno-ai/bark)
- [Suno AI Pricing 2026](https://musicmake.ai/blog/suno-ai-pricing-plans-2026)
- [Suno vs Udio 2026](https://www.tldl.io/blog/suno-vs-udio-comparison)
- [Sonic Pi MCP Server](https://playbooks.com/mcp/vinayak-mehta-sonic-pi)
- [sonic-pi-cli - GitHub](https://github.com/Widdershin/sonic-pi-cli)

### Video
- [Open-Source Video Generation Models 2026 - Hyperstack](https://www.hyperstack.cloud/blog/case-study/best-open-source-video-generation-models)
- [LTX-2 Local Setup Guide](https://bonega.ai/en/blog/run-ai-video-locally-rtx-ltx-2-comfyui-2026)
- [Wan-2.2 and Open Source Video Models](https://aifreeforever.com/blog/open-source-ai-video-models-free-tools-to-make-videos)
- [Remotion](https://www.remotion.dev/)
- [Remotion GitHub](https://github.com/remotion-dev/remotion)
- [Manim Community](https://www.manim.community/)
- [Generative Manim](https://www.blog.brightcoding.dev/2026/02/22/generative-manim-ai-powered-video-creation-revolution)
- [Motion Canvas](https://motioncanvas.io/)
- [Editly - GitHub](https://github.com/mifi/editly)
- [FFmpeg](https://www.ffmpeg.org/)
- [DaVinci Resolve Scripting API](https://deric.github.io/DaVinciResolve-API-Docs/)

### Data Visualization
- [D3.js](https://d3js.org/)
- [Observable Framework - GitHub](https://github.com/observablehq/framework)
- [Plotly Python](https://plotly.com/python/)
- [Cytoscape.js](https://js.cytoscape.org/)
- [Sigma.js](https://www.sigmajs.org/)
- [Chart.js](https://www.chartjs.org/)

### Interactive Content
- [Scrollama - GitHub](https://github.com/russellsamora/scrollama)
- [Leaflet](https://leafletjs.com/)
- [MapLibre](https://maplibre.org/)
- [OpenFreeMap](https://openfreemap.org/)
- [TimelineJS - Knight Lab](https://timeline.knightlab.com/)
