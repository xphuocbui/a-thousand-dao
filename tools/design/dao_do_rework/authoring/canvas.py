"""Authoring canvas: one land of a map json drawn axis-up in the land's frame (u right, v = distance out), with a grid.
usage: canvas.py map.json out.html axis u0 u1 v0 v1 [step [cx cy]]"""
import sys, json, math
NOLABELS = '--nolabels' in sys.argv          # whole-map views: no road coordinates, smaller nodes
NOCOORDS = '--nocoords' in sys.argv          # region views on a page: names of combos, no road coordinates
sys.argv = [a for a in sys.argv if a not in ('--nolabels', '--nocoords')]
MAP, OUT = sys.argv[1], sys.argv[2]
ax, u0, u1, v0, v1 = map(float, sys.argv[3:8]); step = float(sys.argv[8]) if len(sys.argv) > 8 else 5.0
M = json.load(open(MAP, encoding='utf-8')); N = {n['id']: n for n in M['nodes']}
t = math.radians(ax)
CX, CY = (float(sys.argv[9]), float(sys.argv[10])) if len(sys.argv) > 10 else (0.0, 0.0)     # a disc's centre
loc = lambda x, y: ((x - CX) * math.cos(t) - (y - CY) * math.sin(t), (x - CX) * math.sin(t) + (y - CY) * math.cos(t))
P = {i: loc(n['x'], n['y']) for i, n in N.items()}
sc = 1400 / (u1 - u0); W = (u1 - u0) * sc; H = (v1 - v0) * sc
X = lambda u: (u - u0) * sc; Y = lambda v: (v1 - v) * sc
out = ['<svg viewBox="0 0 %.0f %.0f" width="%.0f" height="%.0f" style="background:#0e1319">' % (W, H, W, H)]
k = math.ceil(u0 / step) * step
while k <= u1:
    out.append('<line x1="%.1f" y1="0" x2="%.1f" y2="%.1f" stroke="%s" stroke-width="1"/>' % (X(k), X(k), H, '#3a4656' if k else '#5b6b80'))
    out.append('<text x="%.1f" y="14" fill="#7d8a99" font-size="12">u%g</text>' % (X(k) + 2, k)); k += step
k = math.ceil(v0 / step) * step
while k <= v1:
    out.append('<line x1="0" y1="%.1f" x2="%.1f" y2="%.1f" stroke="#3a4656" stroke-width="1"/>' % (Y(k), W, Y(k)))
    out.append('<text x="4" y="%.1f" fill="#7d8a99" font-size="12">v%g</text>' % (Y(k) - 3, k)); k += step
inb = lambda p: u0 - 2 < p[0] < u1 + 2 and v0 - 2 < p[1] < v1 + 2
SW = 0.9 if NOLABELS else 2
# combos (user 2026-11-16): a soft wash behind each combo's clusters and its name, one colour per combo
PAL = ['#e0763a', '#4fb3a9', '#c75fa0', '#8fb84a', '#5d8fe0', '#d9a441', '#a37be0', '#e05a5a']
combos = {}
for g in M.get('groups', []):
    if g.get('combo'):
        combos.setdefault(g['combo'], []).extend(g['nodes'])
for k_, (name, ids) in enumerate(sorted(combos.items())):
    col = PAL[k_ % len(PAL)]
    pts = [P[i] for i in ids if i in P and inb(P[i])]
    for q in pts:
        out.append('<circle cx="%.1f" cy="%.1f" r="%.1f" fill="%s" fill-opacity="0.16"/>' % (X(q[0]), Y(q[1]), 0.95 * sc, col))
    if pts and not NOLABELS:
        cx = sum(q[0] for q in pts) / len(pts); cy = max(q[1] for q in pts)
        label = name.split(' ', 2)[-1] if name.count(' ') >= 2 else name
        out.append('<text x="%.1f" y="%.1f" fill="%s" font-size="13" font-weight="600" text-anchor="middle">%s</text>' % (X(cx), Y(cy) - 14, col, label))
for e in M['edges']:
    a, b = P[e['a']], P[e['b']]
    if not (inb(a) or inb(b)): continue
    col = '#c8c2b4' if N[e['a']].get('cluster') is not None and N[e['a']].get('cluster') == N[e['b']].get('cluster') else '#8d8676'
    if e.get('arc'):
        c = loc(*e['arc']); r = math.dist(a, c) * sc
        t1 = math.atan2(a[1] - c[1], a[0] - c[0]); t2 = math.atan2(b[1] - c[1], b[0] - c[0]); dd = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi
        out.append('<path d="M%.1f,%.1f A%.1f,%.1f 0 0 %d %.1f,%.1f" fill="none" stroke="%s" stroke-width="%s"/>' % (X(a[0]), Y(a[1]), r, r, 0 if dd > 0 else 1, X(b[0]), Y(b[1]), col, SW))
    else:
        out.append('<line x1="%.1f" y1="%.1f" x2="%.1f" y2="%.1f" stroke="%s" stroke-width="%s"/>' % (X(a[0]), Y(a[1]), X(b[0]), Y(b[1]), col, SW))
for i, n in N.items():
    p = P[i]
    if not inb(p): continue
    k_ = n['kind']
    if k_ == 'travel':
        w_ = 3.0 if NOLABELS else 9.0
        out.append('<rect x="%.1f" y="%.1f" width="%g" height="%g" fill="#5b8bd6"/>' % (X(p[0]) - w_ / 2, Y(p[1]) - w_ / 2, w_, w_))
        if not NOLABELS and not NOCOORDS:
            out.append('<text x="%.1f" y="%.1f" fill="#9fb6d8" font-size="10">%.1f,%.1f</text>' % (X(p[0]) + 6, Y(p[1]) - 5, p[0], p[1]))
    else:
        r = {'notable': 7, 'keystone': 9, 'start': 10}.get(k_, 4)
        if NOLABELS:
            r = {'notable': 2.6, 'keystone': 3.6, 'start': 4.5}.get(k_, 1.5)
        col = {'notable': '#d8b25a', 'keystone': '#e0506a', 'start': '#7aa7ec'}.get(k_, '#c8c2b4')
        out.append('<circle cx="%.1f" cy="%.1f" r="%s" fill="%s"/>' % (X(p[0]), Y(p[1]), r, col))
out.append('</svg>')
open(OUT, 'w', encoding='utf-8').write('<html><body style="margin:0;background:#0b0f15">' + ''.join(out) + '</body></html>')
print('ok', int(W), int(H))
