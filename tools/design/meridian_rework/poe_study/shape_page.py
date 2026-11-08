"""Turn audit/gallery.html into a readable shape-audit page (study only)."""
import json
import re
import sys

SP = sys.argv[1]
g = open(SP + "/audit/gallery.html", encoding="utf-8").read()
a = json.load(open(SP + "/audit/audit.json", encoding="utf-8"))
secs = re.findall(r"<section><h2>(.*?)</h2>(.*?)</section>", g, re.S)
by = {}
for h, body in secs:
    m = re.match(r"PoE (\d) · (.*?) · (\d+) \((\d+) %\)", h)
    by[(m.group(1), m.group(2))] = (int(m.group(3)), m.group(4), body)
NOTES = {
    "arc (crescent)": "Nodes on one orbit with the notable at the end. PoE 1's default; PoE 2 cut it to a sixth.",
    "ring / wheel": "A closed orbit with notables on it; often a mastery in the middle.",
    "bent line": "Straight links that turn: L, V, U-cups, hooks, brackets.",
    "lollipop (ring + tail)": "A ring on a stem, or a ring with a notable on a spoke at its centre.",
    "split (pieces joined outside)": "Two mirrored halves, ( ) brackets or rings inside rings, joined only through the road.",
    "polygon (5-6, straight)": "Hexagons, kites, cups and a heart, drawn with straight links.",
    "keystone group": "A keystone alone at a dead-end tip.",
    "lens / theta (two hubs, three lanes)": "Two hubs joined by three lanes, or a circle split by a diameter.",
    "lattice (3+ loops)": "Snowflakes, triangles in triangles, rings with spokes, an arrowhead.",
    "zigzag": "S-curves, meanders, square waves.",
    "fork (Y)": "A stem splitting into two or three tines; a spear with a forked head.",
    "diamond / square (4)": "Four nodes with the notable at the far corner.",
    "ring with spokes": "A ring with arms out of it: figures, an hourglass with handles.",
    "tri-star (Y, equal arms)": "Three equal arms from one hub; T shapes and anchors.",
    "star / fan (one hub, 4+ arms)": "X crosses, + crosses, asterisks.",
    "straight line (spoke)": "The plain stick, rare in PoE 2.",
    "pair": "Two nodes.",
    "figure-8 (two loops share a node)": "Two loops sharing a node or a side; chained diamonds, totem poles.",
    "double loop (ladder, two cells)": "Two cells side by side, or concentric rings.",
    "branching tree (2+ forks)": "Branches off branches.",
}
order = list(a["poe2"]["counts"].keys())
rows = []
for cls in order:
    p2 = a["poe2"]["counts"].get(cls, 0); p1 = a["poe1"]["counts"].get(cls, 0)
    rows.append(f"<tr><td>{cls}</td><td class=n>{100 * p2 / sum(a['poe2']['counts'].values()):.0f} %</td>"
                f"<td class=n>{100 * p1 / sum(a['poe1']['counts'].values()):.0f} %</td><td class=n>{a['poe2']['size_median'].get(cls, '–')}</td><td>{NOTES.get(cls, '')}</td></tr>")
gal = []
for cls in order:
    if ("2", cls) not in by:
        continue
    n, pct, body = by[("2", cls)]
    gal.append(f'<section class="shape"><h3>{cls} <span class="meta">PoE 2 · {n} clusters · {pct} %</span></h3><p class="note">{NOTES.get(cls, "")}</p>{body}</section>')
for cls in ("arc (crescent)", "ring / wheel", "lens / theta (two hubs, three lanes)", "split (pieces joined outside)", "lattice (3+ loops)"):
    if ("1", cls) in by:
        n, pct, body = by[("1", cls)]
        gal.append(f'<section class="shape"><h3>{cls} <span class="meta">PoE 1 · {n} clusters · {pct} %</span></h3>{body}</section>')
html = f"""<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>PoE Cluster Shapes</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Marcellus&family=IBM+Plex+Sans:wght@400;500;600&family=IBM+Plex+Mono:wght@400;500&display=swap">
<style>
:root{{--bg:#eef0ee;--panel:#ffffff;--card:#fbfaf6;--fg:#1b2026;--muted:#5c6670;--line:#d6dad6;--edge:#8a8f96;--stub:#d4501e;
--f-display:"Marcellus",Georgia,serif;--f-body:"IBM Plex Sans",system-ui,sans-serif;--f-mono:"IBM Plex Mono",ui-monospace,monospace}}
@media (prefers-color-scheme: dark){{:root:not([data-theme="light"]){{--bg:#101417;--panel:#171c21;--card:#1d2329;--fg:#e4e7ea;--muted:#97a1ab;--line:#28313a;--edge:#7d8790;--stub:#ff7a45;color-scheme:dark}}}}
:root[data-theme="dark"]{{--bg:#101417;--panel:#171c21;--card:#1d2329;--fg:#e4e7ea;--muted:#97a1ab;--line:#28313a;--edge:#7d8790;--stub:#ff7a45;color-scheme:dark}}
*{{box-sizing:border-box}}body{{background:var(--bg);color:var(--fg);font:15px/1.55 var(--f-body);margin:0}}
.wrap{{max-width:1280px;margin:0 auto;padding:26px 16px 56px;display:grid;gap:22px}}
.eyebrow{{font:500 12px/1 var(--f-mono);letter-spacing:.08em;text-transform:uppercase;color:var(--muted)}}
h1{{font:400 clamp(28px,4.6vw,42px)/1.08 var(--f-display);margin:6px 0}}h2{{font:400 22px/1.2 var(--f-display);margin:0 0 8px}}
h3{{font:600 15px/1.3 var(--f-body);margin:0}}.meta{{font:400 12.5px var(--f-mono);color:var(--muted);margin-left:6px}}
.lede,.note{{color:var(--muted);max-width:76ch;margin:4px 0 8px}}.note{{font-size:13.5px}}
.tablebox{{overflow-x:auto;border:1px solid var(--line);border-radius:6px;background:var(--panel)}}
table{{border-collapse:collapse;width:100%;font-size:13.5px}}th,td{{text-align:left;padding:7px 10px;border-bottom:1px solid var(--line);vertical-align:top}}
th{{font:600 12px var(--f-body);color:var(--muted);text-transform:uppercase;letter-spacing:.05em}}td.n{{font-family:var(--f-mono);white-space:nowrap}}
.shape{{background:var(--panel);border:1px solid var(--line);border-radius:6px;padding:12px}}
.row{{display:flex;flex-wrap:wrap;gap:6px}}figure{{margin:0;width:140px;background:var(--card);border:1px solid var(--line);border-radius:4px}}
figcaption{{padding:3px 5px;font-size:10.5px;color:var(--muted);height:30px;overflow:hidden}}
svg line,svg path{{stroke:var(--edge)}}svg line[stroke="#d4501e"]{{stroke:var(--stub)}}
</style></head><body><div class="wrap">
<header><div class="eyebrow">Meridian Map rework · study</div><h1>PoE Cluster Shapes</h1>
<p class="lede">Every PoE 1 and PoE 2 cluster that holds a notable or a keystone (621 in PoE 2, 387 in PoE 1), sorted by how its nodes link and how they are drawn. PoE 1 is mostly arcs and rings; PoE 2 keeps those to under a third and draws the rest as figures. Orange stubs mark where a road joins. Gold nodes are notables, red ones keystones.</p></header>
<section><h2>The catalogue</h2><div class="tablebox"><table><thead><tr><th>Shape</th><th>PoE 2</th><th>PoE 1</th><th>Median nodes</th><th>What it looks like</th></tr></thead><tbody>{''.join(rows)}</tbody></table></div></section>
<section><h2>What it means for the Meridian Map</h2><ul class="lede">
<li>Crescents and rings should be under a third of the clusters, and rarely the 3–4 node ones.</li>
<li>Small clusters take figures: kites, L and V bends, zigzags, tri-stars, crosses. Bigger ones take pictograms that fit their theme (a heart, an hourglass, a sword, a coin).</li>
<li>Three road nodes in four carry two or more clusters (PoE 1 and 2 alike), and about one in four carries four.</li>
<li>Clusters grow outward (PoE 2 median 4, 5, 5 from the inner to the outer third; 34 % of outer clusters hold 7+ nodes), and a small cluster sits on the same road node as a 6+ cluster 58 % of the time.</li></ul></section>
{''.join(gal)}
</div></body></html>"""
open(SP + "/audit/poe-cluster-shapes.html", "w", encoding="utf-8").write(html)
print("ok")
