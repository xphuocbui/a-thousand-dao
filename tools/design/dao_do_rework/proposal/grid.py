"""Render a crop of a cells JSON tree in file coordinates (y down as in the editor, Fire at the bottom) with a labelled grid. Render only."""
import json, sys
src, tree, cx, cy, R, out = sys.argv[1], sys.argv[2], float(sys.argv[3]), float(sys.argv[4]), float(sys.argv[5]), sys.argv[6]
D = json.load(open(src))[tree]
px = 1800 / (2 * R); W = int(2 * R * px)
X = lambda x: (x - cx + R) * px
Y = lambda y: (y - cy + R) * px          # file frame, y down as the editor shows it (Fire at the bottom)
cols = ['#2f5a3a', '#2a4a6b', '#6b5a2a', '#4a2a6b', '#6b2a2a', '#2a5a5a']
s = ['<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" style="background:#0b0d10;font-family:Consolas">' % (W, W)]
for c in D['cells']:
    if abs(c['c'][0] - cx) > 2 * R or abs(c['c'][1] - cy) > 2 * R: continue
    d = ''.join('M' + 'L'.join('%.1f %.1f' % (X(p[0]), Y(p[1])) for p in pl) + 'Z' for pl in c['ps'])
    col = '#5a2a6b' if c['a'] > 290 else cols[c['id'] % len(cols)]
    s.append('<path d="%s" fill="%s" fill-opacity="0.55"/>' % (d, col))
g0x = int((cx - R) // 5 * 5); g0y = int((cy - R) // 5 * 5)
for gx in range(g0x, int(cx + R) + 5, 5):
    s.append('<line x1="%.1f" y1="0" x2="%.1f" y2="%d" stroke="#ffffff" stroke-opacity="%.2f"/>' % (X(gx), X(gx), W, 0.22 if gx % 10 == 0 else 0.08))
    s.append('<text x="%.1f" y="14" fill="#9ab" font-size="13">%d</text>' % (X(gx) + 2, gx))
for gy in range(g0y, int(cy + R) + 5, 5):
    s.append('<line x1="0" y1="%.1f" x2="%d" y2="%.1f" stroke="#ffffff" stroke-opacity="%.2f"/>' % (Y(gy), W, Y(gy), 0.22 if gy % 10 == 0 else 0.08))
    s.append('<text x="2" y="%.1f" fill="#9ab" font-size="13">%d</text>' % (Y(gy) - 2, gy))
for l in D['lines']:
    if all(abs(p[0] - cx) > R + 2 or abs(p[1] - cy) > R + 2 for p in l['p']): continue
    col = {'r': '#c8a060', 'w': '#e3b56a', 'c': '#7f8b98', 'p': '#5fe08a', 'pw': '#5fe08a'}[l['k']]
    s.append('<polyline points="%s" fill="none" stroke="%s" stroke-width="%s" %s/>' % (' '.join('%.1f,%.1f' % (X(p[0]), Y(p[1])) for p in l['p']), col, 3.5 if l['k'] in ('r', 'p') else 2, 'stroke-dasharray="9 5"' if l['k'] in ('w', 'pw') else ''))
for a in D.get('adds', []):
    s.append('<polyline points="%s" fill="none" stroke="#5fe08a" stroke-width="5" stroke-opacity="0.85" %s/>' % (' '.join('%.1f,%.1f' % (X(p[0]), Y(p[1])) for p in a['p']), 'stroke-dasharray="12 6"' if a['k'] == 'pw' else ''))
for n in D['nodes']:
    if abs(n[0] - cx) < R + 1 and abs(n[1] - cy) < R + 1:
        s.append('<circle cx="%.1f" cy="%.1f" r="%d" fill="%s"/>' % (X(n[0]), Y(n[1]), 6 if n[2] in ('travel', 'start', 'keystone') else 4, {'travel': '#c8a060', 'notable': '#e0c070', 'start': '#fff', 'keystone': '#e06050'}.get(n[2], '#9aa5b1')))
for c in D['cells']:
    if abs(c['c'][0] - cx) < R and abs(c['c'][1] - cy) < R:
        s.append('<text x="%.1f" y="%.1f" fill="#fff" font-size="22" text-anchor="middle" stroke="#000" stroke-width="4" paint-order="stroke">#%d %.0f</text>' % (X(c['c'][0]), Y(c['c'][1]), c['id'], c['a']))
s.append('</svg>')
open(out, 'w').write('<html><body style="margin:0">' + ''.join(s) + '</body></html>')
