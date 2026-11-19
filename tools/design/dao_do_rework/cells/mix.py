"""Size mix and repeated drawings of the hand-placed pieces in a compiled map (rules-2026-11-18.md 3.3). Report only.

A piece is every node sharing one '<cell> <piece>' name prefix (one cluster). Size: small 1-5 nodes, medium 6-8,
big 9+ (targets, reported not enforced: about 50 / 33 / 14 % of pieces; PoE 2 has 53% small). A drawing's signature is
its node count, kinds and its sorted pairwise distances rounded to 0.3 units, so turned or mirrored copies match.
Rule 3.3: a medium drawing appears at most three times in the whole tree, a big one once.

usage: python -I tools/design/dao_do_rework/cells/mix.py <map.json> [land] [--cells]
"""
import collections
import json
import math
import sys

AXIS = {'fire': 0, 'earth': 72, 'metal': 144, 'water': 216, 'wood': 288}


def land_of(x, y):
    g = math.degrees(math.atan2(x, y))
    return min(AXIS, key=lambda L: abs((g - AXIS[L] + 180) % 360 - 180))


def main():
    M = json.load(open(sys.argv[1], encoding='utf-8'))
    want = sys.argv[2] if len(sys.argv) > 2 and not sys.argv[2].startswith('--') else None
    pieces = collections.defaultdict(list)
    for n in M['nodes']:
        nm = n.get('name') or ''
        if nm[:1] == 'c' and nm[1:2].isdigit():
            pieces[nm.rsplit(' ', 1)[0]].append(n)
    sig_count = collections.Counter()
    info = {}
    for p, ns in pieces.items():
        pts = [(n['x'], n['y']) for n in ns]
        d = sorted(round(math.dist(a, b) / 0.3) for i, a in enumerate(pts) for b in pts[i + 1:])
        sig = (len(ns), sum(n['kind'] == 'notable' for n in ns), tuple(d))
        cx, cy = sum(x for x, _ in pts) / len(pts), sum(y for _, y in pts) / len(pts)
        cell = int(p.split(' ')[0][1:])
        land = 'border' if 911 <= cell <= 915 else land_of(cx, cy)
        size = 'small' if len(ns) <= 5 else 'medium' if len(ns) <= 8 else 'big'
        info[p] = (land, size, sig, cell, len(ns))
        if size != 'small':
            sig_count[sig] += 1
    lands = [want] if want else list(AXIS) + ['border']
    for L in lands:
        rows = [v for v in info.values() if v[0] == L]
        if not rows:
            continue
        c = collections.Counter(v[1] for v in rows)
        tot = len(rows)
        print(f"{L:<7} pieces {tot:4d}  small {c['small']:4d} ({100 * c['small'] / tot:3.0f}%)  medium {c['medium']:3d} "
              f"({100 * c['medium'] / tot:3.0f}%)  big {c['big']:3d} ({100 * c['big'] / tot:3.0f}%)  "
              f"nodes {sum(v[4] for v in rows)}  mean {sum(v[4] for v in rows) / tot:.1f}")
    over = [(p, info[p][1], sig_count[info[p][2]]) for p in info
            if (info[p][1] == 'medium' and sig_count[info[p][2]] > 3) or (info[p][1] == 'big' and sig_count[info[p][2]] > 1)]
    over = [o for o in over if not want or info[o[0]][0] == want]
    print('repeated drawings over the 3.3 limit:', len(over), sorted(over)[:20])
    if '--cells' in sys.argv:
        per = collections.defaultdict(collections.Counter)
        for v in info.values():
            if not want or v[0] == want:
                per[v[3]][v[1]] += 1
        for cell in sorted(per):
            print(f"  cell {cell:>3}: small {per[cell]['small']:2d} medium {per[cell]['medium']:2d} big {per[cell]['big']:2d}")


if __name__ == '__main__':
    main()
