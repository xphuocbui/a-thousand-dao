"""Vector drawing of a compiled map for the zoomable viewer on the sketches page. Report only, no judging.

Writes one SVG whose <g id="tree"> holds: road links, other base links, base nodes, then one <g class="pc"> per
hand-placed piece (data-c cell, data-p piece, data-n nodes, data-k notables) and cell-number labels (<g class="lbl">).
A piece's links are grouped by their 'color' (colour_links.py), each group carrying it as the CSS variable --c.
Coordinates are map units, Fire at the bottom (y down), the same frame as render_tree.py. Arc links use the edge's
'arc' centre and the shorter way round, as render_tree.py does.

usage: python -I tools/design/dao_do_rework/cells/viewer_svg.py <map.json> <out.svg>
"""
import collections
import json
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..', '..', '..'))
INV = os.path.join(ROOT, 'design', 'dao-do', 'cells', 'inventory.json')
AXIS = {'fire': 0, 'earth': 72, 'metal': 144, 'water': 216, 'wood': 288}
RAD = {'small': 0.22, 'travel': 0.22, 'notable': 0.42, 'keystone': 0.65, 'start': 0.6}


def f(v):
    s = f'{v:.2f}'.rstrip('0').rstrip('.')
    return '0' if s in ('-0', '') else s


def circle(x, y, r):
    return f'M{f(x - r)} {f(y)}a{f(r)} {f(r)} 0 1 0 {f(2 * r)} 0a{f(r)} {f(r)} 0 1 0 {f(-2 * r)} 0'


def link(A, B, c):
    if not c:
        return f'M{f(A[0])} {f(A[1])}L{f(B[0])} {f(B[1])}'
    r = math.dist(A, c)
    t1 = math.atan2(A[1] - c[1], A[0] - c[0])
    t2 = math.atan2(B[1] - c[1], B[0] - c[0])
    dt = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi
    return f'M{f(A[0])} {f(A[1])}A{f(r)} {f(r)} 0 0 {1 if dt > 0 else 0} {f(B[0])} {f(B[1])}'


def esc(s):
    return s.replace('&', '&amp;').replace('"', '&quot;').replace('<', '&lt;')


def main():
    mp, out = sys.argv[1:3]
    M = json.load(open(mp, encoding='utf-8'))
    N = {n['id']: n for n in M['nodes']}
    piece = {}
    for n in M['nodes']:
        nm = n.get('name') or ''
        if nm[:1] == 'c' and nm[1:2].isdigit():
            piece[n['id']] = nm.rsplit(' ', 1)[0]
    P = collections.defaultdict(lambda: {'lk': collections.defaultdict(list), 'small': [], 'notable': [], 'keystone': []})
    road, other, base_small, singles = [], [], [], []
    for e in M['edges']:
        A, B = N[e['a']], N[e['b']]
        d = link((A['x'], A['y']), (B['x'], B['y']), e.get('arc'))
        p = piece.get(e['a']) or piece.get(e['b'])
        if p:
            P[p]['lk'][e.get('color')].append(d)
        elif A['kind'] in ('travel', 'start') and B['kind'] in ('travel', 'start'):
            road.append(d)
        else:
            other.append(d)
    for n in M['nodes']:
        k = n['kind']
        if n['id'] in piece:
            P[piece[n['id']]][k if k in ('notable', 'keystone') else 'small'].append(circle(n['x'], n['y'], RAD[k]))
        elif k in ('small', 'travel'):
            base_small.append(circle(n['x'], n['y'], RAD[k]))
        else:
            singles.append((n, k))
    o = ['<svg xmlns="http://www.w3.org/2000/svg" viewBox="-138 -138 276 276"><g id="tree">',
         f'<path class="rd" d="{"".join(road)}"/>', f'<path class="lk" d="{"".join(other)}"/>',
         f'<path class="sm" d="{"".join(base_small)}"/>']
    for n, k in singles:
        cls = {'notable': 'nt', 'keystone': 'ks', 'start': 'st'}[k]
        nm = n.get('name') or ('axis notable' if k == 'notable' else k)
        o.append(f'<circle class="{cls} one" cx="{f(n["x"])}" cy="{f(n["y"])}" r="{RAD[k]}" data-name="{esc(nm)}"/>')
    for p in sorted(P, key=lambda s: (int(s.split(' ')[0][1:]), s)):
        g = P[p]
        cell, name = p.split(' ', 1)
        nn = len(g['small']) + len(g['notable']) + len(g['keystone'])
        o.append(f'<g class="pc" data-c="{cell[1:]}" data-p="{esc(name)}" data-n="{nn}" data-k="{len(g["notable"])}">')
        for col, ds in sorted(g['lk'].items(), key=lambda kv: kv[0] or ''):
            st = f' style="--c:{col}"' if col else ''
            o.append(f'<path class="lk"{st} d="{"".join(ds)}"/>')
        for k, cls in (('small', 'sm'), ('notable', 'nt'), ('keystone', 'ks')):
            if g[k]:
                o.append(f'<path class="{cls}" d="{"".join(g[k])}"/>')
        o.append('</g>')
    inv = json.load(open(INV, encoding='utf-8'))
    lab = []
    for L, cells in inv.items():
        for c in cells:
            g = math.radians(AXIS[L] + c['th'])
            lab.append((c['cell'], c['r'] * math.sin(g), c['r'] * math.cos(g)))
    for i, L in enumerate(AXIS):
        g = math.radians(AXIS[L])
        lab.append((901 + i, 80 * math.sin(g), 80 * math.cos(g)))
        b = math.radians(AXIS[L] + 36)
        lab.append((911 + i, 88 * math.sin(b), 88 * math.cos(b)))
    o.append('<g class="lbl">' + ''.join(f'<text x="{f(x)}" y="{f(y)}">{c}</text>' for c, x, y in lab) + '</g>')
    o.append('</g></svg>')
    open(out, 'w', encoding='utf-8').write(''.join(o))
    print(out, len(P), 'pieces', os.path.getsize(out) // 1024, 'KB')


if __name__ == '__main__':
    main()
