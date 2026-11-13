"""Builds gallery.html for the continent candidates: previews, game-grid views and each candidate's map check.

Usage:
    python -I tools/design/map/make_gallery.py prototypes/continent-candidates
"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from continent_gen import BIOMES  # noqa: E402

PAGE = r"""<title>Continent Candidates</title>
<meta name="claude:viewport-fit-sides" content="cover">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,500;9..144,650&family=IBM+Plex+Sans:wght@400;500;600&family=IBM+Plex+Mono:wght@400;500&display=swap">
<style>
/* Layout: an atlas plate index. A header with the view switch and legend, then a grid of numbered plates;
   a plate opens full size with its map check. */
:root {
  --paper: #eef1f2; --sheet: #ffffff; --ink: #1d2a33; --muted: #5d6c76; --rule: #cfd8dc;
  --sea: #2f5d86; --sea-soft: #dbe7f0; --warn: #9a5a12;
  --display: "Fraunces", Georgia, "Times New Roman", serif;
  --body: "IBM Plex Sans", system-ui, -apple-system, "Segoe UI", sans-serif;
  --mono: "IBM Plex Mono", ui-monospace, Consolas, monospace;
}
@media (prefers-color-scheme: dark) { :root:not([data-theme="light"]) {
  --paper: #11181d; --sheet: #182229; --ink: #e3e9ec; --muted: #93a3ad; --rule: #2b3842;
  --sea: #7fb0d8; --sea-soft: #1f3344; --warn: #e0a65a; color-scheme: dark } }
:root[data-theme="dark"] {
  --paper: #11181d; --sheet: #182229; --ink: #e3e9ec; --muted: #93a3ad; --rule: #2b3842;
  --sea: #7fb0d8; --sea-soft: #1f3344; --warn: #e0a65a; color-scheme: dark }
body { background: var(--paper); color: var(--ink); font: 15px/1.5 var(--body); }
.wrap { max-width: 1240px; margin: 0 auto; padding-block: 28px 56px;
  padding-left: max(16px, env(safe-area-inset-left, 0px)); padding-right: max(16px, env(safe-area-inset-right, 0px)); }
header { display: grid; gap: 14px; margin-bottom: 22px; }
h1 { font: 650 clamp(28px, 4vw, 40px)/1.1 var(--display); margin: 0; text-wrap: balance; letter-spacing: -0.01em; }
.lede { margin: 0; color: var(--muted); max-width: 68ch; }
.bar { display: flex; flex-wrap: wrap; gap: 12px 20px; align-items: center; }
.switch { display: inline-flex; border: 1px solid var(--rule); border-radius: 999px; padding: 3px; background: var(--sheet); }
.switch button { font: 500 13px var(--body); color: var(--muted); background: none; border: 0; padding: 6px 14px;
  border-radius: 999px; cursor: pointer; }
.switch button[aria-pressed="true"] { background: var(--sea); color: var(--sheet); }
.switch button:focus-visible, .plate:focus-visible, .close:focus-visible { outline: 2px solid var(--sea); outline-offset: 2px; }
.legend { display: flex; flex-wrap: wrap; gap: 4px 12px; font-size: 12px; color: var(--muted); }
.legend span { display: inline-flex; align-items: center; gap: 5px; }
.legend i { width: 10px; height: 10px; border-radius: 2px; display: inline-block; outline: 1px solid rgba(0,0,0,.12); }
.grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(min(100%, 360px), 1fr)); gap: 18px; }
.plate { display: grid; gap: 10px; background: var(--sheet); border: 1px solid var(--rule); border-radius: 6px;
  padding: 10px 10px 12px; cursor: pointer; text-align: left; color: inherit; font: inherit; }
.plate:hover { border-color: var(--sea); }
.plate img { width: 100%; height: auto; display: block; border-radius: 3px; aspect-ratio: 3 / 2; image-rendering: auto; }
.grid.gridview .plate img, dialog img.tiles { image-rendering: pixelated; }
.head { display: flex; justify-content: space-between; align-items: baseline; gap: 8px; }
.num { font: 650 20px var(--display); }
.facts { font: 12px/1.4 var(--mono); color: var(--muted); font-variant-numeric: tabular-nums; }
.shares { display: flex; height: 10px; border-radius: 2px; overflow: hidden; outline: 1px solid var(--rule); }
.missing { font-size: 12px; color: var(--warn); }
dialog { width: min(1200px, calc(100vw - 32px)); max-height: calc(100vh - 32px); border: 1px solid var(--rule);
  border-radius: 8px; padding: 18px; background: var(--sheet); color: var(--ink); }
dialog::backdrop { background: rgba(10, 16, 20, .6); }
.dhead { display: flex; justify-content: space-between; align-items: center; gap: 12px; margin-bottom: 12px; }
.dhead h2 { font: 650 24px var(--display); margin: 0; }
.close { font: 500 13px var(--body); border: 1px solid var(--rule); background: var(--paper); color: var(--ink);
  border-radius: 999px; padding: 6px 14px; cursor: pointer; }
.pair { display: grid; grid-template-columns: repeat(auto-fit, minmax(min(100%, 420px), 1fr)); gap: 12px; }
.pair figure { margin: 0; display: grid; gap: 4px; }
.pair figcaption { font-size: 12px; color: var(--muted); }
.pair img { width: 100%; height: auto; border-radius: 3px; }
.table { margin-top: 14px; display: grid; grid-template-columns: repeat(auto-fill, minmax(190px, 1fr)); gap: 4px 18px;
  font: 13px/1.5 var(--mono); font-variant-numeric: tabular-nums; }
.table div { display: flex; justify-content: space-between; gap: 8px; border-bottom: 1px dotted var(--rule); }
.table i { width: 9px; height: 9px; border-radius: 2px; display: inline-block; margin-right: 6px; }
.note { margin-top: 12px; font-size: 13px; color: var(--muted); }
</style>

<div class="wrap">
  <header>
    <h1>Continent Candidates</h1>
    <p class="lede">Twelve continents from the geography generator, round 4: each tile now holds a natural mix of up to
      three biomes, drawn from a map four times finer underneath. Each coast is grown from hundreds of
      small regions and partly drowned by a rising sea, then straightened by waves on soft, low shores; only hilly
      and glaciated coasts keep their capes and fjords. Ranges follow curving plate edges; rivers carve the land into
      ridges and valleys; climate runs in two seasons. Pick the one that feels most like the world, or name what to
      change. Open a plate for both views and its full map check.</p>
    <div class="bar">
      <div class="switch" role="group" aria-label="View">
        <button id="v-nat" type="button" aria-pressed="true">Natural view</button>
        <button id="v-grid" type="button" aria-pressed="false">Game grid (__GRID__)</button>
      </div>
      <div class="legend" id="legend"></div>
    </div>
  </header>
  <main class="grid" id="grid"></main>
</div>

<dialog id="dlg" aria-labelledby="dtitle">
  <div class="dhead"><h2 id="dtitle"></h2><button class="close" id="close" type="button">Close</button></div>
  <div class="pair">
    <figure><img id="dnat" alt=""><figcaption>Natural view, full size: the fine map (about 6 km a cell, 16 cells a tile) with hillshade, rivers, lakes and volcanoes. Open the image on its own to zoom in.</figcaption></figure>
    <figure><img id="dgrid" class="tiles" alt=""><figcaption>Game grid: each tile (about 25 km) coloured by its mix of up to three biomes; rivers blue, lava red, hot springs orange, ore veins darkened</figcaption></figure>
  </div>
  <div class="table" id="dtable"></div>
  <p class="note" id="dnote"></p>
</dialog>

<script>
const BIOMES = __BIOMES__;
const CANDS = __CANDS__;
const pct = v => (v * 100).toFixed(v < 0.01 && v > 0 ? 1 : 0) + "%";
const rgb = c => `rgb(${c[0]},${c[1]},${c[2]})`;
const landBiomes = BIOMES.filter(b => b[0] !== "sea");
document.getElementById("legend").innerHTML = landBiomes
  .map(b => `<span><i style="background:${rgb(b[2])}"></i>${b[1]}</span>`).join("");
const grid = document.getElementById("grid");
let view = "preview";
function render() {
  grid.classList.toggle("gridview", view === "tiles");
  grid.innerHTML = CANDS.map((c, n) => {
    const s = c.stats;
    const bar = landBiomes.filter(b => (s.biome_share_of_land[b[0]] || 0) > 0)
      .map(b => `<span title="${b[1]} ${pct(s.biome_share_of_land[b[0]])}" style="flex:${s.biome_share_of_land[b[0]]};background:${rgb(b[2])}"></span>`).join("");
    const miss = s.missing_biomes.filter(m => m !== "miasma");
    return `<button class="plate" type="button" data-n="${n}" aria-label="Open candidate ${c.seed}">
      <img src="${c.dir}/${view}.png" alt="Candidate ${c.seed}, ${view === "tiles" ? "game grid" : "natural view"}" loading="lazy">
      <div class="head"><span class="num">No. ${c.seed}</span>
        <span class="facts">land ${pct(s.land_share)} · ${s.islands} islands</span></div>
      <div class="shares" aria-hidden="true">${bar}</div>
      <div class="facts">${s.river_mouths} rivers reach the sea · ${s.lakes} lakes · ${s.volcanoes} volcanoes · ${pct(s.mixed_land_tile_share)} mixed tiles</div>
      ${miss.length ? `<div class="missing">No ${miss.map(m => BIOMES.find(b => b[0] === m)[1].toLowerCase()).join(", ")}</div>` : ""}
    </button>`;
  }).join("");
}
function setView(v) {
  view = v;
  document.getElementById("v-nat").setAttribute("aria-pressed", v === "preview");
  document.getElementById("v-grid").setAttribute("aria-pressed", v === "tiles");
  render();
}
document.getElementById("v-nat").onclick = () => setView("preview");
document.getElementById("v-grid").onclick = () => setView("tiles");
const dlg = document.getElementById("dlg");
grid.addEventListener("click", e => {
  const p = e.target.closest(".plate"); if (!p) return;
  const c = CANDS[+p.dataset.n], s = c.stats;
  document.getElementById("dtitle").textContent = `Candidate No. ${c.seed}`;
  document.getElementById("dnat").src = `${c.dir}/detail.jpg`;
  document.getElementById("dnat").alt = `Candidate ${c.seed}, natural view`;
  document.getElementById("dgrid").src = `${c.dir}/tiles.png`;
  document.getElementById("dgrid").alt = `Candidate ${c.seed}, game grid`;
  document.getElementById("dtable").innerHTML = landBiomes
    .map(b => `<div><span><i style="background:${rgb(b[2])}"></i>${b[1]}</span><span title="tiles where it is the main biome · share of land · tiles where it is any part">${s.biome_tiles[b[0]]} · ${pct(s.biome_share_of_land[b[0]] || 0)} · in ${(s.tiles_with_biome_as_part || {})[b[0]] || 0}</span></div>`).join("");
  document.getElementById("dnote").textContent =
    `Land ${pct(s.land_share)} of the map; the main landmass holds ${pct(s.main_landmass_share_of_land)} of it. ` +
    `${s.islands} islands, ${s.river_mouths} rivers reaching the sea, ${s.lakes} lakes, ${s.salt_flats} salt flats, ` +
    `${s.volcanoes} volcanoes. Rivers running uphill: ${s.rivers_uphill}. ${pct(s.mixed_land_tile_share)} of land tiles hold two or three biomes ` +
    `(${s.land_tiles_by_parts["2"]} with two, ${s.land_tiles_by_parts["3"]} with three); a tile's main biome averages ${s.mean_main_share}% of it. ` +
    `Table: tiles where the biome is the main one · its share of land · tiles where it is any part. The miasma wasteland is never generated; it is authored later.`;
  dlg.showModal();
});
document.getElementById("close").onclick = () => dlg.close();
dlg.addEventListener("click", e => { if (e.target === dlg) dlg.close(); });
render();
</script>
"""


def main():
    root = sys.argv[1] if len(sys.argv) > 1 else "prototypes/continent-candidates"
    cands = []
    for d in sorted(os.listdir(root)):
        meta = os.path.join(root, d, "meta.json")
        if d.startswith("cand-") and os.path.exists(meta):
            with open(meta, encoding="utf-8") as fh:
                m = json.load(fh)
            cands.append({"dir": d, "seed": m["seed"], "stats": m["stats"]})
            grid = "%d × %d" % (m["params"]["tiles_w"], m["params"]["tiles_h"])
    html = (PAGE.replace("__BIOMES__", json.dumps([[k, n, list(c)] for k, n, c in BIOMES]))
            .replace("__CANDS__", json.dumps(cands)).replace("__GRID__", grid))
    out = os.path.join(root, "gallery.html")
    with open(out, "w", encoding="utf-8") as fh:
        fh.write(html)
    print("wrote", out, "with", len(cands), "candidates")


if __name__ == "__main__":
    main()
