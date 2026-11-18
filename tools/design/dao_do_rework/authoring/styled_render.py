"""Draw PoE 1's tree or our map in the same game-like style, at our scale (PoE 173 units = our 1.2), for a fair look.
usage: styled_render.py poe <data.json> out.png cx cy half      (cx, cy, half in our units, PoE coordinates scaled)
       styled_render.py ours <map.json> out.png ax u0 u1 v0 v1   (a region's frame, like canvas.py)"""
import sys, json, math
from PIL import Image, ImageDraw
SS = 3                                   # supersampling
LINE = (120, 98, 58); LINE_HI = (168, 138, 82)
BG = (8, 10, 13)


def draw(nodes, edges, to_px, W, H, out):
    im = Image.new('RGB', (W * SS, H * SS), BG); d = ImageDraw.Draw(im)
    for e in edges:
        pts = [to_px(p) for p in e]
        pts = [(x * SS, y * SS) for x, y in pts]
        d.line(pts, fill=LINE, width=int(3.2 * SS), joint='curve')
        d.line(pts, fill=LINE_HI, width=int(1.2 * SS), joint='curve')
    for (x, y), k in nodes:
        x, y = to_px((x, y)); x *= SS; y *= SS
        if k == 'notable':
            r = 9 * SS
            d.ellipse([x - r, y - r, x + r, y + r], fill=(40, 30, 22), outline=(214, 172, 92), width=int(2.6 * SS))
            d.ellipse([x - r * 0.55, y - r * 0.55, x + r * 0.55, y + r * 0.55], fill=(150, 104, 70))
        elif k == 'keystone':
            r = 12 * SS
            d.ellipse([x - r, y - r, x + r, y + r], fill=(46, 26, 26), outline=(214, 172, 92), width=int(3 * SS))
        elif k in ('travel', 'start', 'attribute'):
            r = 5 * SS
            d.ellipse([x - r, y - r, x + r, y + r], fill=(30, 34, 40), outline=(160, 160, 150), width=int(1.6 * SS))
        else:
            r = 5.2 * SS
            d.ellipse([x - r, y - r, x + r, y + r], fill=(52, 56, 62), outline=(176, 166, 140), width=int(1.6 * SS))
    im.resize((W, H), Image.LANCZOS).save(out)


def arcpts(a, b, c, n=16):
    r = math.dist(a, c); t1 = math.atan2(a[1] - c[1], a[0] - c[0]); t2 = math.atan2(b[1] - c[1], b[0] - c[0])
    dt = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi
    return [(c[0] + r * math.cos(t1 + dt * k / n), c[1] + r * math.sin(t1 + dt * k / n)) for k in range(n + 1)]


if sys.argv[1] == 'poe':
    d = json.load(open(sys.argv[2], encoding='utf-8'))
    cx, cy, half = map(float, sys.argv[4:7])
    sc = 1.2 / 173.0
    c = d["constants"]; radii = c["orbitRadii"]
    A16 = [0, 30, 45, 60, 90, 120, 135, 150, 180, 210, 225, 240, 270, 300, 315, 330]
    A40 = [0, 10, 20, 30, 40, 45, 50, 60, 70, 80, 90, 100, 110, 120, 130, 135, 140, 150, 160, 170, 180, 190, 200, 210, 220, 225, 230, 240, 250, 260, 270, 280, 290, 300, 310, 315, 320, 330, 340, 350]
    ang = [[math.radians(a) for a in (A16 if n == 16 else A40 if n == 40 else [360 * i / n for i in range(n)])] for n in c["skillsPerOrbit"]]
    G = d["groups"]; N = {}
    for sid, n in d["nodes"].items():
        # Not on the drawn main tree: ascendancy circles (incl. the Ascendant's path choices), cluster-jewel proxies,
        # masteries (their 368 links are not drawn in game), and the 30 Blighted anointment-only nodes (no links;
        # drawing them made the "orphan" notables and the lone keystone at (0, -18.2) in pass 2-18 renders).
        if not isinstance(n, dict) or "group" not in n or n.get("ascendancyName") or n.get("isProxy") or n.get("isMastery") or n.get("isBlighted"):
            continue
        g = G.get(str(n["group"]))
        if not g or g.get("isProxy"): continue
        o, i = n["orbit"], n["orbitIndex"]; a = ang[o][i]; r = radii[o]
        k = 'keystone' if n.get("isKeystone") else 'notable' if n.get("isNotable") else 'attribute' if (n.get("isAttribute") or not n.get("stats") and not n.get("isJewelSocket")) else 'small'
        N[int(n.get("skill", sid))] = dict(p=((g["x"] + r * math.sin(a)) * sc, (g["y"] - r * math.cos(a)) * sc), g=(g["x"] * sc, g["y"] * sc), gid=n["group"], o=o, k=k, out=[int(m) for m in n.get("out", [])])
    W = H = 1000; s = W / (2 * half)
    to_px = lambda p: ((p[0] - cx + half) * s, (p[1] - cy + half) * s)
    inside = lambda p: abs(p[0] - cx) < half * 1.2 and abs(p[1] - cy) < half * 1.2
    edges = []
    for i, n in N.items():
        for j in n['out']:
            m = N.get(j)
            if not m or not (inside(n['p']) or inside(m['p'])): continue
            if n['gid'] == m['gid'] and n['o'] == m['o'] and n['o'] > 0:
                edges.append(arcpts(n['p'], m['p'], n['g']))
            else:
                edges.append([n['p'], m['p']])
    draw([(n['p'], n['k']) for n in N.values() if inside(n['p'])], edges, to_px, W, H, sys.argv[3])
else:
    M = json.load(open(sys.argv[2], encoding='utf-8'))
    ax, u0, u1, v0, v1 = map(float, sys.argv[4:9])
    t = math.radians(ax)
    loc = lambda x, y: (x * math.cos(t) - y * math.sin(t), x * math.sin(t) + y * math.cos(t))
    P = {n['id']: loc(n['x'], n['y']) for n in M['nodes']}
    W = 1000; s = W / (u1 - u0); H = int((v1 - v0) * s)
    to_px = lambda p: ((p[0] - u0) * s, (v1 - p[1]) * s)
    inside = lambda p: u0 - 2 < p[0] < u1 + 2 and v0 - 2 < p[1] < v1 + 2
    edges = []
    for e in M['edges']:
        a, b = P[e['a']], P[e['b']]
        if not (inside(a) or inside(b)): continue
        if e.get('arc'):
            edges.append(arcpts(a, b, loc(*e['arc'])))
        else:
            edges.append([a, b])
    draw([(P[n['id']], n['kind']) for n in M['nodes'] if inside(P[n['id']])], edges, to_px, W, H, sys.argv[3])
print('ok')
