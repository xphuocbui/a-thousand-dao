"""Writes gallery/index.html for the map style demos (rounds 1 and 2)."""
import json
import os

here = os.path.dirname(os.path.abspath(__file__))

STYLES = [
    {"id": "pixel", "name": "Pixel tiles", "vn": "điểm ảnh",
     "blurb": "16 × 16 tiles on the GDD's grid: one tile per cell, auto-tiled roads and rivers, place icons on top. Closest to Dwarf Fortress; the grid is the art.",
     "look": "Dwarf Fortress (Steam tiles), Caves of Qud, Amazing Cultivation Simulator",
     "sheets": ["tiles", "icons"],
     "sets": [
         ("round1", "p1", "Spring", 101, "Bright, saturated tiles."),
         ("round1", "p2", "Autumn dusk", 202, "Warm reds and ochres, blue roof tiles."),
         ("round1", "p3", "Ash and jade", 303, "Muted, desaturated jade."),
         ("round2", "p4", "Glyph", 404, "Hand-drawn glyphs on tinted black cells, the roguelike look."),
         ("round2", "p5", "Warm cultivation", 505, "Foam shorelines, region and city labels."),
         ("round2", "p6", "Winter night", 606, "Cold palette at night, foam shorelines."),
     ]},
    {"id": "parchment", "name": "Painted parchment", "vn": "bản đồ giấy da",
     "blurb": "The same grid drawn as a hand-made chart: contour coastlines from a smoothed land field, ripple lines, terrain symbols, inked rivers, dashed roads, a cartouche and a compass.",
     "look": "Crusader Kings III (zoomed out), Battle Brothers",
     "sheets": ["symbols", "icons"],
     "sets": [
         ("round1", "c1", "Sepia ink", 11, "Monochrome brown ink on tan paper."),
         ("round1", "c2", "Coloured atlas", 22, "Watercolour biome washes, red roads."),
         ("round1", "c3", "Sect archive", 33, "Faded blue-grey ink, cinnabar seals, ruled sea."),
         ("round2", "c4", "Explorer's chart", 44, "Rhumb lines, junk boats, region names along curves."),
         ("round2", "c5", "Territory atlas", 55, "Sect territories as dotted borders, with a legend."),
         ("round2", "c6", "Engraved", 66, "Black ink, hatched relief, dense coastal contours."),
     ]},
    {"id": "ink", "name": "Ink-wash", "vn": "thủy mặc",
     "blurb": "Misty layered peaks that fade into paper, stippled forests, dry-brush coasts, water left as blank paper, red seals for the great places.",
     "look": "Okami, Tale of Immortal's world map",
     "sheets": ["symbols", "icons"],
     "sets": [
         ("round1", "k1", "Pure ink", 7, "Greys only, red seals."),
         ("round1", "k2", "Light colour", 8, "Thiển giáng: pale mineral greens and ochre."),
         ("round1", "k3", "Moonlit indigo", 9, "Indigo ink on grey paper, gold seals."),
         ("round2", "k4", "Scroll", 17, "Vertical place names, sampans, faint region names."),
         ("round2", "k5", "Gold on night paper", 18, "Cream and gold ink on dark paper."),
         ("round2", "k6", "Splashed ink", 19, "Phá mặc: bold blurred washes and colour splashes."),
     ]},
]
MAPS = [("A", "Thanh Vân", "temperate continent"), ("B", "Bích Hải", "island chain"), ("C", "Băng Nguyên", "cold highland")]

cards = {}
for st in STYLES:
    out = []
    for rnd, sid, name, seed, note in st["sets"]:
        base = f"{rnd}/{st['id']}/{sid}"
        sheets = "".join(
            f'<button class="sheet" data-full="{base}_{sh}.png" aria-label="Enlarge {name} {sh}"><img src="{base}_{sh}.png" alt="{name} {sh} sheet" loading="lazy" class="{"px" if st["id"] == "pixel" else ""}"></button>'
            for sh in st["sheets"])
        out.append(f'''
      <article class="set" data-base="{base}">
        <header class="set-head">
          <h3>{name}</h3>
          <p class="meta"><span>{'Round 1' if rnd == 'round1' else 'Round 2'}</span><span>id {sid}</span><span>seed {seed}</span></p>
        </header>
        <button class="map" data-full="{base}_map_A.png" aria-label="Enlarge {name} map">
          <img class="map-img {"px" if st["id"] == "pixel" else ""}" src="{base}_map_A.png" alt="{name}: demo map" loading="lazy">
        </button>
        <p class="note">{note}</p>
        <div class="sheets">{sheets}</div>
      </article>''')
    cards[st["id"]] = "".join(out)

sections = "".join(f'''
  <section class="style" id="{st['id']}" aria-labelledby="h-{st['id']}">
    <div class="style-head">
      <h2 id="h-{st['id']}">{st['name']} <span class="vn">{st['vn']}</span></h2>
      <p class="blurb">{st['blurb']}</p>
      <p class="look">Look up: {st['look']}</p>
    </div>
    <div class="grid">{cards[st['id']]}
    </div>
  </section>''' for st in STYLES)

map_buttons = "".join(f'<button class="chip" data-map="{k}" aria-pressed="{"true" if k == "A" else "false"}"><b>{k}</b> {n} <span>{d}</span></button>' for k, n, d in MAPS)
style_links = "".join(f'<a class="chip link" href="#{st["id"]}">{st["name"]}</a>' for st in STYLES)

html = f'''<title>Map Style Trials</title>
<meta name="claude:viewport-fit-sides" content="cover">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=IM+Fell+English+SC&family=IBM+Plex+Sans:wght@400;600&family=IBM+Plex+Mono:wght@400&display=swap">
<style>
/* Layout: a cartographer's proof sheet. A sticky switcher (map A/B/C, style jump), then one section per style with six set cards. */
:root {{
  --bg: #eceee9; --surface: #f8f9f6; --fg: #1d2622; --muted: #5b6862; --line: #c9cfc9; --accent: #2c6e5e;
  --display: "IM Fell English SC", "Palatino Linotype", Georgia, serif;
  --body: "IBM Plex Sans", "Segoe UI", system-ui, sans-serif;
  --mono: "IBM Plex Mono", ui-monospace, Consolas, monospace;
}}
@media (prefers-color-scheme: dark) {{ :root:not([data-theme="light"]) {{
  --bg: #121614; --surface: #1a201d; --fg: #e3e8e4; --muted: #9aa8a1; --line: #2e3833; --accent: #74c3ab; color-scheme: dark; }} }}
:root[data-theme="dark"] {{ --bg: #121614; --surface: #1a201d; --fg: #e3e8e4; --muted: #9aa8a1; --line: #2e3833; --accent: #74c3ab; color-scheme: dark; }}
body {{ background: var(--bg); color: var(--fg); font-family: var(--body); line-height: 1.5;
  padding-left: max(16px, env(safe-area-inset-left, 0px)); padding-right: max(16px, env(safe-area-inset-right, 0px)); padding-block: 0 48px; }}
body::before {{ content: ""; position: fixed; inset: 0 0 auto; height: env(safe-area-inset-top, 0px); z-index: 10; background: var(--bg); }}
.wrap {{ max-width: 1320px; margin: 0 auto; }}
.intro {{ padding-block: 36px 12px; display: grid; gap: 8px; }}
h1 {{ font-family: var(--display); font-weight: 400; font-size: clamp(30px, 5vw, 46px); line-height: 1.05; margin: 0; text-wrap: balance; }}
.intro p {{ margin: 0; max-width: 68ch; color: var(--muted); }}
.intro p b {{ color: var(--fg); font-weight: 600; }}
.bar {{ position: sticky; top: env(safe-area-inset-top, 0px); z-index: 5; background: var(--bg); border-bottom: 1px solid var(--line);
  padding-block: 10px; display: flex; flex-wrap: wrap; gap: 8px 16px; align-items: center; }}
.bar .group {{ display: flex; flex-wrap: wrap; gap: 6px; align-items: center; }}
.bar .label {{ font-family: var(--mono); font-size: 11px; letter-spacing: 0.08em; text-transform: uppercase; color: var(--muted); }}
.chip {{ font: inherit; font-size: 13px; color: var(--fg); background: var(--surface); border: 1px solid var(--line); border-radius: 999px;
  padding: 4px 12px; cursor: pointer; text-decoration: none; }}
.chip span {{ color: var(--muted); }}
.chip[aria-pressed="true"] {{ background: var(--accent); border-color: var(--accent); color: var(--bg); }}
.chip[aria-pressed="true"] span {{ color: var(--bg); opacity: 0.8; }}
.chip:focus-visible, button:focus-visible {{ outline: 2px solid var(--accent); outline-offset: 2px; }}
.style {{ padding-block: 32px 8px; display: grid; gap: 16px; scroll-margin-top: 64px; }}
.style-head {{ display: grid; gap: 4px; }}
h2 {{ font-family: var(--display); font-weight: 400; font-size: clamp(24px, 3.4vw, 32px); margin: 0; }}
h2 .vn {{ font-family: var(--body); font-size: 14px; color: var(--muted); letter-spacing: 0.04em; margin-left: 6px; }}
.blurb {{ margin: 0; max-width: 72ch; }}
.look {{ margin: 0; font-size: 13px; color: var(--muted); }}
.grid {{ display: grid; grid-template-columns: repeat(auto-fill, minmax(min(100%, 380px), 1fr)); gap: 20px; }}
.set {{ display: grid; gap: 8px; align-content: start; min-width: 0; }}
.set-head {{ display: flex; flex-wrap: wrap; justify-content: space-between; align-items: baseline; gap: 4px 12px; }}
h3 {{ margin: 0; font-size: 16px; font-weight: 600; }}
.meta {{ margin: 0; display: flex; gap: 10px; font-family: var(--mono); font-size: 11px; color: var(--muted); font-variant-numeric: tabular-nums; }}
.note {{ margin: 0; font-size: 13px; color: var(--muted); }}
button.map, button.sheet {{ padding: 0; border: 1px solid var(--line); background: var(--surface); cursor: zoom-in; display: block; width: 100%; }}
.map-img {{ display: block; width: 100%; height: auto; aspect-ratio: 3 / 2; object-fit: contain; background: var(--surface); }}
.sheets {{ display: flex; gap: 8px; min-width: 0; }}
.sheets .sheet {{ flex: 1 1 0; min-width: 0; height: 72px; }}
.sheets img {{ width: 100%; height: 100%; object-fit: contain; display: block; }}
img.px {{ image-rendering: pixelated; }}
dialog {{ border: 1px solid var(--line); background: var(--surface); color: var(--fg); padding: 12px; max-width: min(96vw, 1500px); }}
dialog::backdrop {{ background: rgba(0, 0, 0, 0.6); }}
dialog img {{ display: block; max-width: 100%; max-height: 82vh; width: auto; height: auto; margin: 0 auto; }}
dialog .row {{ display: flex; justify-content: space-between; align-items: center; gap: 12px; margin-bottom: 8px; }}
dialog .row span {{ font-family: var(--mono); font-size: 12px; color: var(--muted); overflow-wrap: anywhere; }}
.foot {{ margin-top: 40px; font-size: 13px; color: var(--muted); max-width: 72ch; }}
@media (prefers-reduced-motion: no-preference) {{ .map-img {{ transition: opacity 0.2s; }} }}
</style>

<div class="wrap">
  <div class="intro">
    <h1>Map Style Trials</h1>
    <p>Three candidate looks for the Game UI world map (Travel &amp; Map GDD, Visual/Audio). Each style has <b>six seeded sets</b>
      (three in round 1, three more in round 2), and every set draws the <b>same three hand-authored maps</b> from one shared data file,
      so you can compare like with like. Choose a map below; click any image to see it full size.</p>
  </div>
  <nav class="bar" aria-label="Map and style">
    <div class="group" role="group" aria-label="Map shown in every set"><span class="label">Map</span>{map_buttons}</div>
    <div class="group"><span class="label">Jump to</span>{style_links}</div>
  </nav>
  {sections}
  <p class="foot">Hand-authored with the pxl and vex art skills. Source and rebuild steps: <code>prototypes/map-style-demos/README.md</code>.
    Every map is the GDD grid (28 × 18 cells); the parchment and ink styles draw that grid as contours and brush marks instead of squares.</p>
</div>

<dialog id="viewer" aria-label="Full-size image">
  <div class="row"><span id="viewer-name"></span><button class="chip" id="viewer-close">Close</button></div>
  <img id="viewer-img" alt="">
</dialog>

<script>
(() => {{
  const viewer = document.getElementById("viewer");
  const vimg = document.getElementById("viewer-img");
  const vname = document.getElementById("viewer-name");
  let current = "A";
  try {{ const m = localStorage.getItem("map-style-map"); if (m && "ABC".includes(m)) current = m; }} catch (e) {{}}
  const setMap = (k) => {{
    current = k;
    document.querySelectorAll(".chip[data-map]").forEach((b) => b.setAttribute("aria-pressed", String(b.dataset.map === k)));
    document.querySelectorAll(".set").forEach((card) => {{
      const src = card.dataset.base + "_map_" + k + ".png";
      card.querySelector(".map-img").src = src;
      card.querySelector("button.map").dataset.full = src;
    }});
    try {{ localStorage.setItem("map-style-map", k); }} catch (e) {{}}
  }};
  document.querySelectorAll(".chip[data-map]").forEach((b) => b.addEventListener("click", () => setMap(b.dataset.map)));
  document.addEventListener("click", (e) => {{
    const b = e.target.closest("button.map, button.sheet");
    if (!b) return;
    vimg.src = b.dataset.full;
    vimg.className = b.querySelector("img").classList.contains("px") ? "px" : "";
    vname.textContent = b.dataset.full;
    viewer.showModal();
  }});
  document.getElementById("viewer-close").addEventListener("click", () => viewer.close());
  viewer.addEventListener("click", (e) => {{ if (e.target === viewer) viewer.close(); }});
  setMap(current);
}})();
</script>
'''
open(os.path.join(here, 'index.html'), 'w', encoding='utf-8', newline='\n').write(html)
files = {}
for root, _, fs in os.walk(here):
    for f in fs:
        if f.endswith('.png'):
            rel = os.path.relpath(os.path.join(root, f), here).replace(os.sep, '/')
            files[rel] = os.path.join(root, f).replace(os.sep, '/')
json.dump(files, open(os.path.join(here, 'files.json'), 'w'), indent=0)
print('ok', len(html), len(files))
