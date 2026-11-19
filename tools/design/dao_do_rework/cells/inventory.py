"""Build the per-land cell inventory used for hand-filling cells (rules-2026-11-18.md 3.10 C). Report only.

For every cell of the cell division (cells2.py output): which land fills it (land cells by label; hub cells by the
land they face; the two Wind-start cells by Wood), its area, band (between which rings), centroid in land-local polar
(r, th from the land's axis), the road nodes and other nodes on its walls (every face read), and its mirror partner
(same land, centroid mirrored across the axis within 1.5 units, area within 3).

usage: python -I tools/design/dao_do_rework/cells/inventory.py <base-map.json> <cells.json> <out inventory.json>
"""
import collections
import json
import math
import sys

AXIS = {'fire': 0, 'earth': 72, 'metal': 144, 'water': 216, 'wood': 288}
RINGS = (33.2, 41.7, 53.9, 64.3, 74.3)


def gth(x, y):
    return math.degrees(math.atan2(x, y))


def wrap(a):
    return (a + 180) % 360 - 180


def dseg(p, a, b):
    ax, ay = a
    bx, by = b
    px, py = p
    dx, dy = bx - ax, by - ay
    L = dx * dx + dy * dy
    t = 0 if L == 0 else max(0, min(1, ((px - ax) * dx + (py - ay) * dy) / L))
    return math.dist(p, (ax + t * dx, ay + t * dy))


def owner(c):
    if c['land'] in AXIS:
        return c['land']
    if c['land'] == 'hub' and c['a'] > 50:
        th = gth(*c['c'])
        return min(AXIS, key=lambda L: abs(wrap(th - AXIS[L])))
    if c['land'] == 'border_ww':
        return 'wood'
    return None


def main():
    M = json.load(open(sys.argv[1], encoding='utf-8'))
    cells = json.load(open(sys.argv[2], encoding='utf-8'))['ours']['cells']
    inv = collections.defaultdict(list)
    for c in cells:
        land = owner(c)
        if not land:
            continue
        polys = c['ps']
        wall = [n for n in M['nodes'] if any(min(dseg((n['x'], n['y']), poly[i], poly[(i + 1) % len(poly)])
                                                 for i in range(len(poly))) < 0.05 for poly in polys)]
        cx, cy = c['c']
        r = math.hypot(cx, cy)
        inner = [R for R in RINGS if R <= r]
        outer = [R for R in RINGS if R > r]
        roads, others = [], []
        for n in wall:
            rec = {'id': n['id'], 'kind': n['kind'], 'r': round(math.hypot(n['x'], n['y']), 1),
                   'th': round(wrap(gth(n['x'], n['y']) - AXIS[land]), 1)}
            (roads if n['kind'] == 'travel' else others).append(rec)
        inv[land].append({'cell': c['id'], 'label': c['land'], 'area': c['a'],
                          'band': f"{inner[-1] if inner else 0}-{outer[0] if outer else 'rim'}",
                          'r': round(r, 1), 'th': round(wrap(gth(cx, cy) - AXIS[land]), 1), 'faces': len(polys),
                          'roads': sorted(roads, key=lambda d: (d['r'], d['th'])),
                          'other_walls': sorted(others, key=lambda d: (d['r'], d['th']))})
    for cs in inv.values():
        for c in cs:
            c['mirror'] = None
            for d in cs:
                if d is not c and abs(c['area'] - d['area']) < 3 and \
                        math.hypot(c['r'] - d['r'], math.radians(c['th'] + d['th']) * c['r']) < 1.5:
                    c['mirror'] = d['cell']
    json.dump(inv, open(sys.argv[3], 'w', encoding='utf-8'), indent=0)
    for land in AXIS:
        print(land, len(inv[land]), 'cells', sum(len(c['roads']) for c in inv[land]), 'wall road nodes')


if __name__ == '__main__':
    main()
