"""Colours the links of the traced islands as their underlay pictures draw them (report only, display data).

For each link of a traced piece, the picture is sampled at three points along the link (a few pixels round each, the
strongest line pixel: bright, not a grey road disc, off the roads); where the traced half is a mirror and the picture
has nothing there, the mirrored point is sampled. The link's colour is the per-channel median, lifted so its brightest
channel is at least 200, rounded to a 3-digit hex colour. A link with no sample takes its piece's most common colour, or (a hand-added piece off the picture) its island's. Writes edge['color'] ('#rrggbb')
into the map (in place). Thunder is not coloured yet (the user is not pleased with it, 2026-11-19). Chaos: the
purple swirl and the five element motifs round the hub (2026-11-19).

usage: python -I tools/design/dao_do_rework/cells/colour_links.py <map.json>
"""
import collections
import json
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..', '..', '..'))
UL = os.path.join(ROOT, 'design', 'dao-do', 'cells', 'openai', 'underlay')
sys.path.insert(0, HERE)
sys.path.insert(0, UL)
from celllib import road  # noqa: E402
from trace_fine import Fine  # noqa: E402

# (name prefix, picture, centre x, centre y, half size, mirror axis or None, picture's own roads elsewhere)
RULES = [
    ('c933 moon_lotus ', 'shrine/lotus-1.png', 0.0, -115.53, 8.5, 0.0, True),
    ('c933 shrine_eclipse ', 'shrine/eclipse-2.png', 107.8, -24.9, 10.0, 107.808, False),
    ('c933 ', 'moon-2.png', 0.0, -103.0, 21.0, 0.0, False),
    ('c931 ', 'sun/inout-3.png', 0.0, 112.0, 21.0, 0.0, False),
    ('c79 swirl_arm', 'chaos2/replace-1.png', 0.0, 0.0, 33.0, None, False),
    ('c3 flames_', 'chaos2/beside-1.png', 0.0, 0.0, 33.0, None, False),
    ('c2 ridges_', 'chaos2/beside-1.png', 0.0, 0.0, 33.0, None, False),
    ('c4 blades_', 'chaos2/beside-1.png', 0.0, 0.0, 33.0, None, False),
    ('c5 waves_', 'chaos2/beside-1.png', 0.0, 0.0, 33.0, None, False),
    ('c1 vines_', 'chaos2/beside-1.png', 0.0, 0.0, 33.0, None, False),
]


def sample_points(A, B, c):
    pts = []
    for t in (0.25, 0.5, 0.75):
        if c:
            r = math.dist(A, c)
            t1, t2 = math.atan2(A[1] - c[1], A[0] - c[0]), math.atan2(B[1] - c[1], B[0] - c[0])
            dt = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi
            a = t1 + dt * t
            pts.append((c[0] + r * math.cos(a), c[1] + r * math.sin(a)))
        else:
            pts.append((A[0] + (B[0] - A[0]) * t, A[1] + (B[1] - A[1]) * t))
    return pts


def strongest(U, q, rad=5):
    x0, y0 = U.to_px(q)
    best, bv = None, 0
    for dx in range(-rad, rad + 1):
        for dy in range(-rad, rad + 1):
            x, y = int(x0) + dx, int(y0) + dy
            if not (0 <= x < U.W and 0 <= y < U.H) or not U.line_px(x, y):
                continue
            r, g, b = U.px[x, y]
            v = max(r, g, b) + (max(r, g, b) - min(r, g, b))
            if v > bv:
                best, bv = (r, g, b), v
    return best


def lift(c):
    m = max(c)
    k = 200 / m if m < 200 else 1.0
    return '#' + ''.join('%x' % min(15, int(round(v * k / 17))) for v in c)      # 4096 steps keep the drawing small


def main():
    mp = sys.argv[1]
    M = json.load(open(mp, encoding='utf-8'))
    N = {n['id']: n for n in M['nodes']}
    unders = {}
    piece_cols = collections.defaultdict(collections.Counter)
    isle_cols = collections.defaultdict(collections.Counter)
    todo = []
    for e in M['edges']:
        names = [N[e['a']].get('name') or '', N[e['b']].get('name') or '']
        rule = next((r for r in RULES if any(nm.startswith(r[0]) for nm in names)), None)
        if not rule:
            continue
        if rule[1] not in unders:
            U = Fine(os.path.join(UL, rule[1]), rule[2], rule[3], rule[4], road, gold_is_road=rule[6])
            U.path((rule[2], rule[3]), (rule[2] + 0.1, rule[3]))
            unders[rule[1]] = U
        U = unders[rule[1]]
        piece = next(nm for nm in names if nm.startswith(rule[0])).rsplit(' ', 1)[0]
        A, B = (N[e['a']]['x'], N[e['a']]['y']), (N[e['b']]['x'], N[e['b']]['y'])
        cols = []
        for q in sample_points(A, B, e.get('arc')):
            c = strongest(U, q)
            if c is None and rule[5] is not None:
                c = strongest(U, (2 * rule[5] - q[0], q[1]))
            if c:
                cols.append(c)
        if cols:
            med = tuple(sorted(c[i] for c in cols)[len(cols) // 2] for i in range(3))
            e['color'] = lift(med)
            piece_cols[piece][e['color']] += 1
            isle_cols[rule[0]][e['color']] += 1
        else:
            todo.append((e, piece, rule[0]))
    for e, piece, isle in todo:
        if piece_cols[piece]:
            e['color'] = piece_cols[piece].most_common(1)[0][0]
        elif isle_cols[isle]:                             # a hand-added piece off the picture: the island's colour
            e['color'] = isle_cols[isle].most_common(1)[0][0]
    json.dump(M, open(mp, 'w', encoding='utf-8'), ensure_ascii=False)
    n = sum(1 for e in M['edges'] if e.get('color'))
    print(f'{mp}: {n} links coloured ({len(todo)} from their piece), pictures {sorted(unders)}')


if __name__ == '__main__':
    main()
