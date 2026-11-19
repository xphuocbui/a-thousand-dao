"""Centre lines of the Sun underlay's flames (measurement only): each flame is one drawn shape (comps.py) running out
from the outer ring; its centre line is the mean of its pixels in thin bands of distance from the island centre.
usage: python -I flames.py <comps.json> <out.json>"""
import json, math, sys
C0 = (0.0, 112.0); k = 42 / 1024
to_map = lambda p: (-21 + p[0] * k, 112 - 21 + p[1] * k)
out = []
for c in json.load(open(sys.argv[1])):
    if not (12.9 < c['rmin'] < 13.6 and c['rmax'] > 15.5): continue
    if not (-1 <= c['ang'] <= 168): continue                    # the right half and the bottom axis flame
    pts = [to_map(p) for p in c['px']]
    r = lambda q: math.dist(q, C0)
    bands = {}
    for q in pts:
        bands.setdefault(int(r(q) / 0.22), []).append(q)
    line = []
    for b in sorted(bands):
        qs = bands[b]
        if len(qs) < 2: continue
        line.append((sum(q[0] for q in qs) / len(qs), sum(q[1] for q in qs) / len(qs)))
    # smooth a little
    sm = [line[0]] + [((line[i-1][0] + line[i][0] + line[i+1][0]) / 3, (line[i-1][1] + line[i][1] + line[i+1][1]) / 3) for i in range(1, len(line) - 1)] + [line[-1]]
    out.append({'ang': c['ang'], 'rmax': c['rmax'], 'line': [[round(x, 4), round(y, 4)] for x, y in sm]})
json.dump(out, open(sys.argv[2], 'w'))
print(len(out), 'flames:', [(f['ang'], f['rmax']) for f in sorted(out, key=lambda f: f['ang'])])
