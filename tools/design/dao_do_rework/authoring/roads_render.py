"""Fire skeleton only (roads, emblems, starts, keystones) with a coordinate grid. usage: roads_render.py map.json out.png ax u0 u1 v0 v1 [layout.json]"""
import sys, json, math
from PIL import Image, ImageDraw, ImageFont
M = json.load(open(sys.argv[1], encoding='utf-8')); ax, u0, u1, v0, v1 = map(float, sys.argv[3:8])
t = math.radians(ax); loc = lambda x, y: (x*math.cos(t) - y*math.sin(t), x*math.sin(t) + y*math.cos(t))
grp = {}
for g in M['groups']:
    for i in g['nodes']: grp[i] = g['shape']
keep = {n['id'] for n in M['nodes'] if n['kind'] in ('travel', 'start', 'keystone') or str(grp.get(n['id'], '')).startswith(('emblem', 'start'))}
P = {n['id']: loc(n['x'], n['y']) for n in M['nodes']}
K = {n['id']: n['kind'] for n in M['nodes']}
W = 1400; s = W/(u1-u0); H = int((v1-v0)*s)
px = lambda p: ((p[0]-u0)*s, (v1-p[1])*s)
im = Image.new('RGB', (W, H), (10, 12, 15)); d = ImageDraw.Draw(im)
f = ImageFont.load_default()
for u in range(int(u0), int(u1)+1):
    if u % 5 == 0:
        d.line([px((u, v0)), px((u, v1))], fill=(30, 34, 40)); d.text((px((u, v1))[0]+2, 2), str(u), fill=(90, 90, 90), font=f)
for v in range(int(v0), int(v1)+1):
    if v % 5 == 0:
        d.line([px((u0, v)), px((u1, v))], fill=(30, 34, 40)); d.text((2, px((u0, v))[1]+2), str(v), fill=(90, 90, 90), font=f)
for k in (-30, 30):  # wedge edges
    a = math.radians(k); d.line([px((0, 0)), px((math.sin(a)*120, math.cos(a)*120))], fill=(70, 40, 40))
def arcpts(a, b, c, n=16):
    r = math.dist(a, c); t1 = math.atan2(a[1]-c[1], a[0]-c[0]); t2 = math.atan2(b[1]-c[1], b[0]-c[0]); dt = (t2-t1+math.pi) % (2*math.pi)-math.pi
    return [(c[0]+r*math.cos(t1+dt*k/n), c[1]+r*math.sin(t1+dt*k/n)) for k in range(n+1)]
for e in M['edges']:
    if e['a'] in keep and e['b'] in keep:
        a, b = P[e['a']], P[e['b']]
        pts = arcpts(a, b, loc(*e['arc'])) if e.get('arc') else [a, b]
        emb = grp.get(e['a'], '').startswith(('emblem', 'start')) and grp.get(e['b'], '').startswith(('emblem', 'start'))
        d.line([px(p) for p in pts], fill=(90, 80, 120) if emb else (200, 165, 90), width=2 if emb else 3)
for i in keep:
    x, y = px(P[i]); u, v = P[i]
    if not (u0 <= u <= u1 and v0 <= v <= v1): continue
    if K[i] == 'keystone': r, c = 8, (220, 90, 70)
    elif K[i] in ('travel', 'start'): r, c = 4, (230, 230, 220)
    else: r, c = 2, (120, 110, 160)
    d.ellipse([x-r, y-r, x+r, y+r], fill=c)
    if K[i] in ('travel', 'keystone') and not str(grp.get(i, '')).startswith(('emblem', 'start')):
        d.text((x+5, y-11), '%.1f,%.1f' % (u, v), fill=(150, 200, 150), font=f)
im.save(sys.argv[2]); print('ok', W, H)
