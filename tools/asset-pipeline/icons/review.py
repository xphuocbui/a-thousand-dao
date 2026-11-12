"""Review and install the painted icon candidates (art bible §8.6 item 9: the user picks every shipped icon).

  python -I tools/asset-pipeline/icons/review.py                      build ai/review.html (one row per icon, candidates
                                                                      at game size, the pre-pick highlighted)
  python -I tools/asset-pipeline/icons/review.py --apply DECISIONS    install the picks from the page's copied decisions
                                                                      (a JSON file), list the rejects to regenerate

Pre-pick (an observation, not a verdict): the candidate whose colour field sits closest to the icon's hue (§7.5) and
whose value contrast is highest at 48 px. The user overrides any of it on the page.
Install: assets/icons/<kind>/<prefix>_<id>.png at the class size (§8.1) and @256 for arts, plus provenance in
assets/icons/PROVENANCE.json (provider, model, quality, seed, prompt).
"""
import argparse
import base64
import colorsys
import glob
import io
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
AI = os.path.join(HERE, "ai", "openai")
ASSETS = os.path.join(ROOT, "assets", "icons")
# kind -> (asset folder, file prefix, export size)
DEST = {"art": ("arts", "art", 128), "tech": ("techniques", "tech", 128), "ward": ("wards", "ward", 96),
        "status": ("status", "status", 48), "counter": ("status", "counter", 48), "stance": ("status", "stance", 48),
        "glyph": ("status", "element", 48)}


def need_pil():
    try:
        from PIL import Image  # noqa: F401
        return True
    except ImportError:
        print("NOT_ASSESSED\tPillow missing (python -m pip install pillow)")
        return False


def hue_of(kind, iid):
    sys.path.insert(0, HERE)
    import gen_ai
    for k, i, el, what, style in gen_ai.items("all"):
        if k == kind and i == iid:
            return gen_ai.HUE[el][1]
    return None


def score(path, hexhue):
    from PIL import Image, ImageStat
    im = Image.open(path).convert("RGB").resize((48, 48), Image.LANCZOS)
    lum = ImageStat.Stat(im.convert("L")).stddev[0] / 64.0           # value contrast at game size
    if not hexhue:
        return lum
    r, g, b = [int(hexhue[i:i + 2], 16) / 255 for i in (1, 3, 5)]
    th = colorsys.rgb_to_hsv(r, g, b)[0]
    small = im.resize((12, 12))
    hs = []
    for px in small.getdata():
        h, s, v = colorsys.rgb_to_hsv(*(c / 255 for c in px))
        if s > 0.25 and v > 0.2:
            hs.append(min(abs(h - th), 1 - abs(h - th)))
    hue_fit = 1 - (sum(hs) / len(hs) * 4 if hs else 1)              # 1 = on hue
    return lum + max(-1.0, hue_fit)


def candidates():
    out = {}
    for f in sorted(glob.glob(os.path.join(AI, "*", "*.png"))):
        kind = os.path.basename(os.path.dirname(f))
        stem = os.path.basename(f)[:-4]
        iid = stem.rsplit("_", 1)[0]
        out.setdefault((kind, iid), []).append(f)
    return out


def thumb(path, size):
    from PIL import Image
    buf = io.BytesIO()
    Image.open(path).convert("RGB").resize((size, size), Image.LANCZOS).save(buf, "PNG")
    return "data:image/png;base64," + base64.b64encode(buf.getvalue()).decode("ascii")


def build():
    C = candidates()
    if not C:
        print("NO_INPUT\tno candidates under %s (run gen_ai.py first)" % AI)
        return 2
    rows = []
    for (kind, iid), files in sorted(C.items()):
        hx = hue_of(kind, iid)
        sc = [score(f, hx) for f in files]
        best = max(range(len(files)), key=lambda i: sc[i])
        rows.append({"kind": kind, "id": iid, "pick": best,
                     "c": [{"file": os.path.relpath(f, HERE).replace("\\", "/"), "big": thumb(f, 128), "small": thumb(f, 48)} for f in files]})
    html = PAGE.replace("/*ROWS*/", json.dumps(rows))
    out = os.path.join(HERE, "ai", "review.html")
    os.makedirs(os.path.dirname(out), exist_ok=True)
    open(out, "w", encoding="utf-8", newline="\n").write(html)
    print("review\t%s (%d icons, %d candidates)" % (out, len(rows), sum(len(r["c"]) for r in rows)))
    return 0


def apply(path):
    from PIL import Image
    dec = json.load(open(path, encoding="utf-8"))
    logs = {}
    lp = os.path.join(HERE, "ai", "log.jsonl")
    if os.path.exists(lp):
        for line in open(lp, encoding="utf-8"):
            r = json.loads(line)
            logs[(r["kind"], r["id"], r.get("tag", ""))] = r
    prov_p = os.path.join(ASSETS, "PROVENANCE.json")
    prov = json.load(open(prov_p, encoding="utf-8")) if os.path.exists(prov_p) else {}
    done, rejects = 0, []
    for d in dec:
        if d.get("reject"):
            rejects.append(d["id"])
            continue
        src = os.path.join(HERE, d["file"])
        folder, prefix, size = DEST[d["kind"]]
        os.makedirs(os.path.join(ASSETS, folder), exist_ok=True)
        name = "%s_%s" % (prefix, d["id"].replace("-", "_"))
        im = Image.open(src).convert("RGB")
        im.resize((size, size), Image.LANCZOS).save(os.path.join(ASSETS, folder, name + ".png"))
        if d["kind"] == "art":
            im.resize((256, 256), Image.LANCZOS).save(os.path.join(ASSETS, folder, name + "@256.png"))
        tag = os.path.basename(src)[:-4].rsplit("_", 1)[1].rstrip("0123456789")
        r = logs.get((d["kind"], d["id"], tag), {})
        prov["%s/%s" % (folder, name)] = {"source": d["file"], "provider": r.get("provider"), "model": r.get("model"),
                                          "quality": r.get("quality"), "seed": r.get("seed"), "prompt": r.get("prompt"),
                                          "picked_by": "user"}
        done += 1
    json.dump(prov, open(prov_p, "w", encoding="utf-8"), indent=1, ensure_ascii=False)
    print("installed\t%d icons; provenance in %s" % (done, prov_p))
    if rejects:
        print("rejects\t%d: python -I tools/asset-pipeline/icons/gen_ai.py --set all --ids %s --quality high --tag h"
              % (len(rejects), ",".join(rejects)))
    return 0


PAGE = r"""<title>Icon Review</title>
<style>
:root { --bg: #ecebe3; --fg: #1c1e1d; --mut: #6b6e68; --line: #c9c7bb; --pick: #2f4a6b; --bad: #a8382a; }
@media (prefers-color-scheme: dark) { :root { --bg: #191b1a; --fg: #e8e5da; --mut: #9a9d96; --line: #343835; --pick: #8fb0d8; --bad: #e07a63; } }
body { background: var(--bg); color: var(--fg); font: 14px "Segoe UI", system-ui, sans-serif; margin: 0; padding: 16px; }
h1 { font-size: 20px; margin: 0 0 4px; } p { color: var(--mut); margin: 0 0 14px; max-width: 70ch; }
.bar { position: sticky; top: 0; background: var(--bg); padding: 8px 0; display: flex; gap: 10px; align-items: center; border-bottom: 1px solid var(--line); z-index: 2; flex-wrap: wrap; }
button { font: inherit; padding: 6px 12px; border: 1px solid var(--fg); background: var(--fg); color: var(--bg); border-radius: 4px; cursor: pointer; }
.row { display: grid; grid-template-columns: 170px 1fr auto; gap: 12px; align-items: center; padding: 10px 0; border-bottom: 1px solid var(--line); }
.row.rej { opacity: .45; }
.id b { display: block; } .id span { color: var(--mut); font-size: 12px; }
.cands { display: flex; gap: 12px; flex-wrap: wrap; }
.c { display: flex; gap: 6px; align-items: flex-end; padding: 4px; border: 2px solid transparent; border-radius: 6px; cursor: pointer; background: none; color: inherit; }
.c.on { border-color: var(--pick); }
.c img.big { width: 128px; height: 128px; border-radius: 4px; display: block; }
.c img.small { width: 48px; height: 48px; border-radius: 3px; display: block; }
.rej-b { background: none; color: var(--bad); border-color: var(--bad); }
.row.rej .rej-b { background: var(--bad); color: var(--bg); }
textarea { width: 100%; height: 90px; font: 12px ui-monospace, monospace; }
</style>
<h1>Icon review</h1>
<p>Each row is one icon; the outlined candidate is the pre-pick. Click another candidate to pick it, or Reject to have it
regenerated at high quality. The small copy is the in-game size. When done, press Copy decisions and paste the text into
the chat.</p>
<div class="bar"><button id="copy">Copy decisions</button><span id="stat"></span></div>
<div id="rows"></div>
<textarea id="out" readonly hidden></textarea>
<script>
const ROWS = /*ROWS*/;
const box = document.getElementById('rows');
function render() {
  box.innerHTML = ROWS.map((r, i) => `<div class="row${r.reject ? ' rej' : ''}"><div class="id"><b>${r.id}</b><span>${r.kind}</span></div>
    <div class="cands">${r.c.map((c, j) => `<button class="c${r.pick === j && !r.reject ? ' on' : ''}" data-i="${i}" data-j="${j}">
      <img class="big" src="${c.big}" alt=""><img class="small" src="${c.small}" alt=""></button>`).join('')}</div>
    <button class="rej-b" data-r="${i}">${r.reject ? 'Rejected' : 'Reject'}</button></div>`).join('');
  document.getElementById('stat').textContent = ROWS.length + ' icons, ' + ROWS.filter(r => r.reject).length + ' rejected';
}
box.addEventListener('click', (e) => {
  const c = e.target.closest('.c'); const rj = e.target.closest('.rej-b');
  if (c) { const r = ROWS[+c.dataset.i]; r.pick = +c.dataset.j; r.reject = false; render(); }
  else if (rj) { const r = ROWS[+rj.dataset.r]; r.reject = !r.reject; render(); }
});
document.getElementById('copy').onclick = async () => {
  const txt = JSON.stringify(ROWS.map(r => ({ kind: r.kind, id: r.id, file: r.c[r.pick].file, reject: !!r.reject })));
  const out = document.getElementById('out'); out.value = txt; out.hidden = false;
  try { await navigator.clipboard.writeText(txt); document.getElementById('stat').textContent = 'Copied. Paste it into the chat.'; }
  catch (e) { out.select(); document.getElementById('stat').textContent = 'Select the text below and copy it.'; }
};
render();
</script>
"""


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--apply")
    a = ap.parse_args()
    if not need_pil():
        return 2
    return apply(a.apply) if a.apply else build()


if __name__ == "__main__":
    sys.exit(main())
