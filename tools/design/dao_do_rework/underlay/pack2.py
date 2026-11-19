"""Geometry pack and region render for an OpenAI design round on the current tree (2026-11-19, second OpenAI round:
Thunder's inside, Water's rim). Report only.

For each region: its road nodes (and which are free: no piece hangs from them yet), fixed nodes, road links, the
pieces already there to keep clear of (all pieces in the box but those being replaced), and an image of the region
with the road ids. usage: python -I pack2.py <compiled map.json> <out dir>
"""
import json
import math
import os
import sys

from PIL import Image, ImageDraw

mp, out_dir = sys.argv[1:3]
M = json.load(open(mp, encoding='utf-8'))
N = {n['id']: n for n in M['nodes']}
r3 = lambda v: round(v, 3)
ang = lambda x, y: math.degrees(math.atan2(x, y)) % 360
THUNDER_RING = [575, 574, 573, 572, 571, 570, 569, 568, 567, 566, 565, 564, 563, 562, 577, 576]


def in_poly(p, poly):
    x, y = p
    c = False
    for (x1, y1), (x2, y2) in zip(poly, poly[1:] + poly[:1]):
        if (y1 > y) != (y2 > y) and x < x1 + (y - y1) * (x2 - x1) / (y2 - y1):
            c = not c
    return c


REGIONS = {
    'thunder_inside': {
        'cell': 932, 'theme': 'island', 'box': (-125, -82, -55, -12), 'replace': (),
        'inside': lambda p: in_poly(p, [(N[i]['x'], N[i]['y']) for i in THUNDER_RING]),
        'outline': 'inside the web ring: the polygon through road nodes ' + ', '.join(map(str, THUNDER_RING)),
    },
    'water_rim': {
        'cell': 904, 'theme': 'water', 'box': (-100, -40, -105, -50),
        'replace': ('c904 ice_flake ', 'c904 plate_flake ', 'c904 great_wave '),
        'inside': lambda p: 75.5 <= math.hypot(*p) <= 109.0 and 206.5 <= ang(*p) <= 243.0,
        'outline': 'the band of the rim between radius 75.5 and 109.0 and polar angle 206.5 to 243.0 degrees',
    },
}

piece = lambda n: (n.get('name') or '').rsplit(' ', 1)[0] + ' ' if (n.get('name') or '').startswith('c') else None
held = {}
for e in M['edges']:
    for a, b in ((e['a'], e['b']), (e['b'], e['a'])):
        if N[a]['kind'] == 'travel' and piece(N[b]):
            held.setdefault(a, set()).add(piece(N[b]).strip())
pack = {}
for reg, R in REGIONS.items():
    x0, x1, y0, y1 = R['box']
    inb = lambda n: x0 <= n['x'] <= x1 and y0 <= n['y'] <= y1
    keep = lambda n: piece(n) and not piece(n).startswith(R['replace']) if R['replace'] else bool(piece(n))
    roads = [n for n in M['nodes'] if n['kind'] == 'travel' and inb(n)]
    rid = {n['id'] for n in roads}
    free = lambda i: not (held.get(i, set()) - {p.strip() for p in R['replace']})
    lk = [[e['a'], e['b'], [r3(c) for c in e['arc']] if e.get('arc') else None] for e in M['edges']
          if e['a'] in rid and e['b'] in rid]
    nb = [n for n in M['nodes'] if inb(n) and keep(n)]
    nbid = {n['id'] for n in nb}
    nbl = [[e['a'], e['b'], [r3(c) for c in e['arc']] if e.get('arc') else None] for e in M['edges']
           if e['a'] in nbid or e['b'] in nbid]
    fixed = [n for n in M['nodes'] if inb(n) and n['kind'] in ('start', 'keystone') and not piece(n)]
    pack[reg] = {
        'cell': R['cell'], 'theme': R['theme'], 'region': R['outline'],
        'road_nodes [id,x,y,free_to_hang_from]': [[n['id'], r3(n['x']), r3(n['y']), free(n['id'])] for n in roads],
        'road_links [a,b,arc_centre_or_null]': lk,
        'fixed_nodes_never_link [id,x,y,kind]': [[n['id'], r3(n['x']), r3(n['y']), n['kind']] for n in fixed],
        'pieces_to_keep_clear nodes [x,y,kind,piece]': [[r3(n['x']), r3(n['y']), n['kind'], piece(n).strip()] for n in nb],
        'pieces_to_keep_clear links [[x,y],[x,y],arc_centre_or_null]': [
            [[r3(N[a]['x']), r3(N[a]['y'])], [r3(N[b]['x']), r3(N[b]['y'])], arc] for a, b, arc in nbl],
    }
    # the image: roads with ids (free ones in cyan), pieces to keep clear in grey, the region shaded
    W = 1100
    span = max(x1 - x0, y1 - y0)
    k = W / span
    P = lambda x, y: ((x - x0) * k, (y - y0) * k)
    im = Image.new('RGB', (W, W), (8, 9, 12))
    d = ImageDraw.Draw(im)
    for gx in range(0, W, 6):
        for gy in range(0, W, 6):
            if R['inside']((x0 + gx / k, y0 + gy / k)):
                d.point((gx, gy), fill=(40, 46, 70))
    for e in M['edges']:
        A, B = N[e['a']], N[e['b']]
        if not (inb(A) or inb(B)):
            continue
        rd = A['kind'] in ('travel', 'start') and B['kind'] in ('travel', 'start')
        if not rd and not (keep(A) or keep(B)):
            continue
        c = e.get('arc')
        if c:
            r = math.dist((A['x'], A['y']), c)
            t1 = math.atan2(A['y'] - c[1], A['x'] - c[0]); t2 = math.atan2(B['y'] - c[1], B['x'] - c[0])
            dt = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi
            pl = [P(c[0] + r * math.cos(t1 + dt * i / 16), c[1] + r * math.sin(t1 + dt * i / 16)) for i in range(17)]
        else:
            pl = [P(A['x'], A['y']), P(B['x'], B['y'])]
        d.line(pl, fill=(200, 160, 80) if rd else (110, 100, 85), width=3 if rd else 1)
    for n in nb:
        x, y = P(n['x'], n['y']); r = 5 if n['kind'] == 'notable' else 3
        d.ellipse((x - r, y - r, x + r, y + r), fill=(140, 125, 100))
    for n in roads:
        x, y = P(n['x'], n['y']); fr = free(n['id'])
        d.ellipse((x - 5, y - 5, x + 5, y + 5), fill=(90, 220, 255) if fr else (160, 140, 110))
        d.text((x + 6, y - 6), str(n['id']), fill=(255, 255, 0) if fr else (150, 150, 150))
    for n in fixed:
        x, y = P(n['x'], n['y']); d.ellipse((x - 8, y - 8, x + 8, y + 8), fill=(255, 255, 255) if n['kind'] == 'start' else (230, 80, 70))
    d.text((8, 8), f'{reg}: region shaded; free road nodes cyan with yellow ids; grey = pieces to keep clear; +x right, +y down',
           fill=(220, 220, 220))
    im.save(os.path.join(out_dir, f'region-{reg}.png'))
    print(reg, 'roads', len(roads), 'free', sum(1 for n in roads if free(n['id'])), 'keep-clear nodes', len(nb))
json.dump(pack, open(os.path.join(out_dir, 'pack2.json'), 'w'), separators=(',', ':'))
