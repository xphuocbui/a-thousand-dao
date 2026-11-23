"""Review page for the place catalogue and its art (overnight 2026-11-22): every named place with its painting (cut from
its patch of the near map), name, kind, look, lore and history, grouped by region, with a search box and kind
filters. Output: prototypes/place-gallery/index.html and img/ (JPEG thumbnails), for the Artifact tool.

usage: python -I tools/design/world/place_gallery.py
"""
import html
import json
import os

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
OUT = os.path.join(ROOT, "prototypes/place-gallery")


def main():
    cont = json.load(open(os.path.join(ROOT, "assets/data/world_continent.json"), encoding="utf-8"))
    cat = {e["id"]: e for e in json.load(open(os.path.join(ROOT, "design/world/place_catalogue.json"), encoding="utf-8"))["places"]}
    art = os.path.join(ROOT, "design/map/continent-11/art/places")
    os.makedirs(os.path.join(OUT, "img"), exist_ok=True)
    open(os.path.join(OUT, ".gdignore"), "w").close()
    regions = {r["id"]: r for r in cont["regions"]}
    by_region = {}
    for p in cont["places"]:
        by_region.setdefault(p["region"], []).append(p)
    files = []
    sections = []
    stage_dir = os.path.join(ROOT, "design/map/continent-11/art/stages")
    jobs = json.load(open(os.path.join(stage_dir, "jobs.json"), encoding="utf-8")) if os.path.exists(os.path.join(stage_dir, "jobs.json")) else []

    def thumb(src, name, size=360):
        im = Image.open(src).convert("RGB")
        w, h = im.size
        side = int(h * 0.62)
        im = im.crop(((w - side) // 2, (h - side) // 2, (w + side) // 2, (h + side) // 2)).resize((size, size), Image.LANCZOS)
        im.save(os.path.join(OUT, "img", name), quality=84, optimize=True)
        files.append("img/" + name)
        return "img/" + name

    levels_of = {}
    project_rows = []
    for j in jobs:
        shots = []
        for n in range(1, len(j["stages"]) + 1):
            src = os.path.join(stage_dir, "%s_%d.png" % (j["job"], n))
            if os.path.exists(src):
                shots.append((n, j["stages"][n - 1], thumb(src, "%s_%d.jpg" % (j["job"], n), 300 if j["kind"] == "level" else 360)))
        if j["kind"] == "level":
            levels_of[j["place"]] = shots
        elif shots:
            project_rows.append((j, shots))
    kinds = sorted({p["kind"] for p in cont["places"]})
    for rid in sorted(by_region):
        r = regions[rid]
        cards = []
        for p in sorted(by_region[rid], key=lambda q: q["id"]):
            e = cat.get(p["id"], {})
            src = os.path.join(art, "paint_%d.png" % p["id"])
            img = ""
            if os.path.exists(src):
                im = Image.open(src).convert("RGB")
                w, h = im.size
                side = int(h * 0.62)   # a square around the centre: the place and its land
                im = im.crop(((w - side) // 2, (h - side) // 2, (w + side) // 2, (h + side) // 2)).resize((360, 360), Image.LANCZOS)
                name = "p%d.jpg" % p["id"]
                im.save(os.path.join(OUT, "img", name), quality=84, optimize=True)
                files.append("img/" + name)
                img = '<img src="img/%s" alt="%s" loading="lazy">' % (name, html.escape(p["name"]))
            lv = levels_of.get(p["id"], [])
            lv_html = "".join('<figure><img src="%s" alt="%s level %d" loading="lazy"><figcaption>Level +%d</figcaption></figure>' % (
                src_, html.escape(p["name"]), n, n) for n, _w, src_ in lv)
            more = "".join("<p><strong>%s.</strong> %s</p>" % (k.capitalize(), html.escape(str(e[k]))) for k in ("lore", "history") if e.get(k))
            if e.get("levels"):
                more += "<p><strong>Levels.</strong> %s</p>" % " · ".join(html.escape(x) for x in e["levels"])
            if e.get("projects"):
                more += "<p><strong>Great projects.</strong> %s</p>" % " · ".join(html.escape(x) for x in e["projects"])
            if lv_html:
                more += '<div class="levels">%s</div>' % lv_html
            cards.append('<article class="card" data-kind="%s" data-text="%s">%s<div class="cap"><div class="row"><h3>%s</h3>'
                         '<span class="tag">%s%s</span></div><p>%s</p><details><summary>Lore and history</summary>%s</details></div></article>' % (
                             p["kind"], html.escape((p["name"] + " " + e.get("look", "") + " " + e.get("lore", "")).lower()),
                             img, html.escape(p["name"]), html.escape(p["kind"].replace("_", " ")), " · special" if e.get("special") else "",
                             html.escape(e.get("look", "")), more))
        sections.append('<section><div class="section-head"><h2>%s</h2><p>%s · %d places</p></div><div class="grid">%s</div></section>' % (
            html.escape(r["name"]), html.escape(r.get("gloss", "")), len(cards), "".join(cards)))
    proj = []
    for j, shots in project_rows:
        base = "img/p%d.jpg" % j["place"]
        figs = '<figure><img src="%s" alt="%s before" loading="lazy"><figcaption>Before</figcaption></figure>' % (base, html.escape(j["name"]))
        figs += "".join('<figure><img src="%s" alt="stage %d" loading="lazy"><figcaption>Stage %d: %s</figcaption></figure>' % (
            src_, n, n, html.escape(w_)) for n, w_, src_ in shots)
        proj.append('<article class="project"><h3>%s</h3><p>at %s</p><div class="stages">%s</div></article>' % (
            html.escape(j["project"]), html.escape(j["name"]), figs))
    projects_html = ('<section><div class="section-head"><h2>Great projects</h2><p>Ten projects, two to five stages each, painted '
                     'from the place&rsquo;s own painting so it grows in place (design/world/great_projects_proposal.md).</p></div>%s</section>'
                     % "".join(proj)) if proj else ""
    page = TEMPLATE.replace("%%PROJECTS%%", projects_html)
    page = page.replace("%%KINDS%%", "".join('<button type="button" class="chip" data-kind="%s" aria-pressed="false">%s</button>' % (k, k.replace("_", " ")) for k in kinds))
    page = page.replace("%%SECTIONS%%", "".join(sections)).replace("%%COUNT%%", str(len(cont["places"])))
    with open(os.path.join(OUT, "index.html"), "w", encoding="utf-8") as f:
        f.write(page)
    with open(os.path.join(OUT, "files.json"), "w", encoding="utf-8") as f:
        json.dump(files, f)
    print("gallery: %d places, %d images" % (len(cont["places"]), len(files)))


TEMPLATE = """<!-- PROTOTYPE - NOT FOR PRODUCTION -->
<title>Place Catalogue</title>
<meta name="claude:viewport-fit-sides" content="cover">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@600&family=Literata:opsz,wght@7..72,400;7..72,600&display=swap">
<style>
/* Layout: a rosewood reading room; regions as chapters, each place a parchment card with its painting. Single dark
   look by choice, like the game's board. */
:root { --wood: #2A1A12; --wood2: #3A2419; --brass: #C9A25A; --paper: #E3D4AE; --paper2: #D8C7A0; --ink: #2B2118;
  --gilt: #5E4316; --cinnabar: #84191B; --bone: #E8D9B5;
  --display: "Cormorant Garamond", Georgia, serif; --body: "Literata", Georgia, serif; color-scheme: dark; }
* { box-sizing: border-box; }
body { background: var(--wood); color: var(--bone); font-family: var(--body); font-size: 15px; line-height: 1.55; }
.wrap { max-width: 1360px; margin: 0 auto; padding-block: 32px 64px; padding-left: max(16px, env(safe-area-inset-left, 0px));
  padding-right: max(16px, env(safe-area-inset-right, 0px)); display: grid; gap: 34px; }
header { display: grid; gap: 10px; max-width: 80ch; }
h1, h2, h3 { font-family: var(--display); font-weight: 600; margin: 0; text-wrap: balance; }
h1 { font-size: clamp(32px, 5vw, 48px); color: var(--bone); }
h2 { font-size: 30px; color: var(--brass); }
h3 { font-size: 21px; color: var(--ink); }
.lede { color: #CDBF9E; }
.tools { display: flex; flex-wrap: wrap; gap: 8px; align-items: center; }
.tools input { font: inherit; padding: 8px 10px; border: 1px solid var(--brass); background: var(--wood2); color: var(--bone); min-width: min(100%, 280px); }
.chip { font: inherit; font-size: 13px; padding: 4px 10px; border: 1px solid #6E5733; background: var(--wood2); color: var(--bone); cursor: pointer; }
.chip[aria-pressed="true"] { background: var(--cinnabar); border-color: var(--brass); }
.chip:focus-visible, .tools input:focus-visible, summary:focus-visible { outline: 2px solid var(--bone); outline-offset: 2px; }
section { display: grid; gap: 14px; }
.section-head { border-bottom: 1px solid #6E5733; padding-bottom: 8px; }
.section-head p { margin: 4px 0 0; color: #CDBF9E; }
.grid { display: grid; gap: 16px; grid-template-columns: repeat(auto-fill, minmax(min(100%, 300px), 1fr)); }
.card { background: var(--paper); color: var(--ink); border: 1px solid var(--brass); outline: 1px solid #000; display: grid; grid-template-rows: auto 1fr; min-width: 0; }
.card img { width: 100%; aspect-ratio: 1; object-fit: cover; display: block; max-width: 100%; background: #111; }
.cap { padding: 12px 14px 14px; display: grid; gap: 6px; align-content: start; min-width: 0; }
.row { display: flex; justify-content: space-between; gap: 8px; align-items: baseline; flex-wrap: wrap; }
.tag { font-size: 12px; letter-spacing: .08em; text-transform: uppercase; color: var(--gilt); }
.cap p { margin: 0; font-size: 14px; }
details summary { cursor: pointer; color: var(--cinnabar); font-size: 14px; }
details p { margin-top: 6px !important; }
.hidden { display: none !important; }
.project { background: var(--wood2); border: 1px solid #6E5733; padding: 14px; display: grid; gap: 8px; }
.project h3 { color: var(--bone); }
.project p { margin: 0; color: #CDBF9E; }
.stages { display: grid; gap: 10px; grid-template-columns: repeat(auto-fit, minmax(min(100%, 200px), 1fr)); }
figure { margin: 0; display: grid; gap: 4px; min-width: 0; }
figure img { width: 100%; aspect-ratio: 1; object-fit: cover; display: block; max-width: 100%; }
figcaption { font-size: 12px; color: #CDBF9E; }
.levels { display: grid; gap: 6px; grid-template-columns: 1fr 1fr; margin-top: 6px; }
.levels figcaption { color: var(--gilt); }
</style>
<div class="wrap">
  <header>
    <h1>Place catalogue</h1>
    <p class="lede">All %%COUNT%% named places of the continent, each with the look, lore and history written overnight from the recorded world, and its own painting cut from its patch of the near map. A proposal for your review: names and recorded events are the world's; everything else is new.</p>
    <div class="tools"><input id="q" type="search" placeholder="Search names and descriptions" aria-label="Search places">%%KINDS%%</div>
  </header>
  %%PROJECTS%%
  %%SECTIONS%%
</div>
<script>
(function () {
  var q = document.getElementById("q");
  var chips = Array.prototype.slice.call(document.querySelectorAll(".chip"));
  var cards = Array.prototype.slice.call(document.querySelectorAll(".card"));
  function apply() {
    var text = q.value.trim().toLowerCase();
    var on = chips.filter(function (c) { return c.getAttribute("aria-pressed") === "true"; }).map(function (c) { return c.dataset.kind; });
    cards.forEach(function (c) {
      var ok = (!text || c.dataset.text.indexOf(text) >= 0) && (!on.length || on.indexOf(c.dataset.kind) >= 0);
      c.classList.toggle("hidden", !ok);
    });
    document.querySelectorAll("section").forEach(function (s) {
      s.classList.toggle("hidden", !s.querySelector(".card:not(.hidden)"));
    });
  }
  q.addEventListener("input", apply);
  chips.forEach(function (c) { c.addEventListener("click", function () {
    c.setAttribute("aria-pressed", c.getAttribute("aria-pressed") === "true" ? "false" : "true"); apply(); }); });
})();
</script>
"""

if __name__ == "__main__":
    main()
