"""Render a region of the PoE 1 passive tree from GGG's export and sprites (study only). Args: data dir, out dir."""
import json, math, os, sys, random
from PIL import Image, ImageDraw
D, OUT = sys.argv[1], sys.argv[2]
d = json.load(open(os.path.join(D, 'data.json'), encoding='utf-8')); S = d['sprites']; Z = '0.2109'; z = float(Z)
sheets = {}
def sheet(k):
    if k not in sheets:
        f = [x for x in os.listdir(D) if x.startswith('z_' + k + '.')][0]; sheets[k] = Image.open(os.path.join(D, f)).convert('RGBA')
    return sheets[k]
def spr(k, name):
    c = S[k][Z]['coords'].get(name)
    return None if not c else sheet(k).crop((c['x'], c['y'], c['x'] + c['w'], c['y'] + c['h']))
R = d['constants']['orbitRadii']; SPO = d['constants']['skillsPerOrbit']
A16 = [0, 30, 45, 60, 90, 120, 135, 150, 180, 210, 225, 240, 270, 300, 315, 330]
A40 = [0, 10, 20, 30, 40, 45, 50, 60, 70, 80, 90, 100, 110, 120, 130, 135, 140, 150, 160, 170, 180, 190, 200, 210, 220, 225, 230, 240, 250, 260, 270, 280, 290, 300, 310, 315, 320, 330, 340, 350]
nodes = {k: v for k, v in d['nodes'].items() if isinstance(v, dict) and str(v.get('group')) in d['groups'] and not v.get('ascendancyName') and not v.get('isProxy')}
def pos(n):
    g = d['groups'][str(n['group'])]; o = n['orbit']; k = SPO[o]
    a = math.radians(A16[n['orbitIndex']] if k == 16 else A40[n['orbitIndex']] if k == 40 else 360 * n['orbitIndex'] / k)
    return g['x'] + R[o] * math.sin(a), g['y'] - R[o] * math.cos(a)
P = {k: pos(v) for k, v in nodes.items()}
def render(cx, cy, ww, out, active=()):
    W = int(ww * z); img = Image.new('RGBA', (W, W), (0, 0, 0, 255))
    bg = spr('background', 'Background2')
    for x in range(0, W, bg.size[0]):
        for y in range(0, W, bg.size[1]): img.alpha_composite(bg, (x, y))
    tx = lambda X: (X - (cx - ww / 2)) * z; ty = lambda Y: (Y - (cy - ww / 2)) * z
    for g in d['groups'].values():
        b = g.get('background')
        if not b: continue
        im = spr('groupBackground', b['image'])
        if im is None: continue
        if b.get('isHalfImage'):
            full = Image.new('RGBA', (im.size[0], im.size[1] * 2), (0, 0, 0, 0)); full.paste(im, (0, 0)); full.paste(im.transpose(Image.FLIP_TOP_BOTTOM), (0, im.size[1])); im = full
        x, y = tx(g['x']), ty(g['y'])
        if -400 < x < W + 400 and -400 < y < W + 400: img.alpha_composite(im, (int(x - im.size[0] / 2), int(y - im.size[1] / 2)))
    dr = ImageDraw.Draw(img)
    for k, n in nodes.items():
        for o in n.get('out', []):
            if o not in nodes: continue
            (x1, y1), (x2, y2) = P[k], P[o]
            col = (230, 190, 110, 255) if (k in active and o in active) else (88, 74, 52, 255)
            dr.line((tx(x1), ty(y1), tx(x2), ty(y2)), fill=col, width=3 if k in active and o in active else 2)
    for k, n in nodes.items():
        x, y = tx(P[k][0]), ty(P[k][1])
        if not (-60 < x < W + 60 and -60 < y < W + 60) or n.get('isJewelSocket') or n.get('isMastery'): continue
        act = k in active
        kind = 'keystone' if n.get('isKeystone') else 'notable' if n.get('isNotable') else 'normal'
        ic = spr(kind + ('Active' if act else 'Inactive'), n.get('icon', ''))
        fr = spr('frame', {'keystone': 'KeystoneFrame' + ('Allocated' if act else 'Unallocated'),
                           'notable': 'NotableFrame' + ('Allocated' if act else 'Unallocated'),
                           'normal': 'PSSkillFrame' + ('Active' if act else '')}[kind])
        if ic: img.alpha_composite(ic, (int(x - ic.size[0] / 2), int(y - ic.size[1] / 2)))
        if fr: img.alpha_composite(fr, (int(x - fr.size[0] / 2), int(y - fr.size[1] / 2)))
    img.convert('RGB').save(out, quality=90)
render(-1200, -1800, 9000, os.path.join(OUT, 'poe1_unalloc.jpg'))
adj = {}
for k, n in nodes.items():
    for o in n.get('out', []) + n.get('in', []):
        if o in nodes: adj.setdefault(k, set()).add(o); adj.setdefault(o, set()).add(k)
cls = [k for k, v in nodes.items() if v.get('classStartIndex') == 3]
random.seed(3)
seen = list(cls); q = list(cls)
while q and len(seen) < 160:
    x = q.pop(0)
    for y in sorted(adj.get(x, ())):
        if y not in seen and random.random() < 0.5: seen.append(y); q.append(y)
render(-1200, -1800, 9000, os.path.join(OUT, 'poe1_alloc.jpg'), set(seen))
print('ok', len(nodes), 'class start', cls)
