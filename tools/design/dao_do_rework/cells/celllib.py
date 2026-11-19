"""Shared helpers for hand-placed Đạo Đồ cells (design/dao-do/rules-2026-11-18.md 3.10 C). Geometry and compile only: every
position and choice lives in the cell files (cellNN.py), placed by hand.

A cell file defines CELL (its id), THEME, ROAD {road node id: (x, y)} and PIECES {name: (nodes, links)}; nodes are
{key: ((x, y), kind)}, links [(a, b, arc centre or None)] with road nodes as ints. Directions: ang 0 = towards the
tree centre, + = towards +theta.
usage: python -I celllib.py <in map.json> <out map.json> cellA.py [cellB.py ...]   (cells compile in order)
"""
import importlib.util
import json
import math
import os
import sys


def P(r, th):                       # polar (r, degrees from the Fire axis) -> file frame
    t = math.radians(th)
    return (r * math.sin(t), r * math.cos(t))


def frame(at):                      # inward and +theta unit vectors at a point
    r = math.hypot(*at)
    i = (-at[0] / r, -at[1] / r)
    t = (-i[1], i[0])                 # = (cos theta, -sin theta), the +theta direction everywhere
    return i, t


def direction(at, ang):
    i, t = frame(at)
    a = math.radians(ang)
    return (math.cos(a) * i[0] + math.sin(a) * t[0], math.cos(a) * i[1] + math.sin(a) * t[1])


def orbit(O, rho, ang):             # a point on a circle round O
    D = direction(O, ang)
    return (O[0] + rho * D[0], O[1] + rho * D[1])


def bow_centre(p, q, bow, cen):     # circle centre of a link whose sagitta is bow x chord (+ bulges away from cen)
    mx, my = (p[0] + q[0]) / 2, (p[1] + q[1]) / 2
    dx, dy = q[0] - p[0], q[1] - p[1]
    L = math.hypot(dx, dy)
    nx, ny = -dy / L, dx / L
    if (mx - cen[0]) * nx + (my - cen[1]) * ny < 0:
        nx, ny = -nx, -ny
    h = bow * L
    ax, ay = mx + nx * h, my + ny * h
    r = (L * L / 4 + h * h) / (2 * abs(h))
    sg = 1 if h > 0 else -1
    return (ax - nx * r * sg, ay - ny * r * sg)


ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..'))
FAM_PATH = os.path.join(ROOT, 'design', 'dao-do', 'families', 'families-draft-2026-11-18.json')
FAM = {f['name']: f for f in json.load(open(FAM_PATH, encoding='utf-8'))['families']}
FAM['Wheel'] = {'name': 'Wheel', 'nodes': [[0, 0, 's'], [1.0, 1.0, 's'], [0, 2.0, 's'], [-1.0, 1.0, 's'], [0, 1.0, 'N']],
                'examples': [{'style': 'spoke', 'links': [[0, 1, 'c'], [1, 2, 'c'], [2, 3, 'c'], [3, 0, 'c'], [1, 4, 0]]}]}


def place(road, rxy, fam, style, stem, ang, turn=0.0, hand=False):
    """Hang catalogue family `fam` (link style `style`) off road node `road` at rxy: entry `stem` units out along
    `ang`, the figure turned `turn` degrees from the stem line, mirrored if `hand`."""
    F = FAM[fam]
    pts = [(x, -y if hand else y, k) for x, y, k in F['nodes']]
    cx = sum(x for x, _, _ in pts) / len(pts)
    cy = sum(y for _, y, _ in pts) / len(pts)
    a0 = math.atan2(cy, cx)
    D = direction(rxy, ang)
    E = direction(rxy, ang + turn)
    rot = math.atan2(E[1], E[0]) - a0
    ex, ey = rxy[0] + stem * D[0], rxy[1] + stem * D[1]
    xy = [(ex + x * math.cos(rot) - y * math.sin(rot), ey + x * math.sin(rot) + y * math.cos(rot)) for x, y, _ in pts]
    cen = (sum(x for x, _ in xy) / len(xy), sum(y for _, y in xy) / len(xy))
    links = next(x['links'] for x in F['examples'] if x['style'] == style)
    nodes = {f'n{i}': (xy[i], 'notable' if pts[i][2] == 'N' else 'small') for i in range(len(xy))}
    out = [(road, 'n0', None)]
    for i, j, bow in links:
        if bow == 'c':
            out.append((f'n{i}', f'n{j}', xy[4]))
        elif abs(bow) < 1e-9:
            out.append((f'n{i}', f'n{j}', None))
        else:
            out.append((f'n{i}', f'n{j}', bow_centre(xy[i], xy[j], bow, cen)))
    return nodes, out


def fill(PIECES, ROAD, FILL):       # FILL rows: (name, road, family, style, stem, ang, turn, hand)
    for n, r, f, s, st, a, t, h in FILL:
        PIECES[n.replace(' ', '_')] = place(r, ROAD[r], f, s, st, a, t, h)



# --- land frames, road lookup, mirroring (for land files) --------------------------------------------------------------
AXIS = {'fire': 0, 'earth': 72, 'metal': 144, 'water': 216, 'wood': 288}
BASE_MAP = os.path.join(ROOT, 'design', 'dao-do', 'cells', 'base-map.json')
_ROADS = None


def roads():
    """{id: (x, y)} of every road (travel) node of the base map."""
    global _ROADS
    if _ROADS is None:
        _ROADS = {n['id']: (n['x'], n['y']) for n in json.load(open(BASE_MAP, encoding='utf-8'))['nodes'] if n['kind'] == 'travel'}
    return _ROADS


def road(i):
    return roads()[i]


def L(r, th, land):                 # polar in a land's frame: th degrees from the land's axis (+ = towards +theta)
    return P(r, AXIS[land] + th)


def reflect(p, land):               # mirror a point across the land's axis
    a = math.radians(AXIS[land]); u = (math.sin(a), math.cos(a)); k = 2 * (p[0] * u[0] + p[1] * u[1])
    return (k * u[0] - p[0], k * u[1] - p[1])


def mirror_road(i, land):           # the road node at the mirror position of road node i
    q = reflect(road(i), land)
    j = min(roads(), key=lambda k: math.dist(roads()[k], q))
    if math.dist(roads()[j], q) > 0.1:
        raise ValueError(f'road node {i} has no mirror road node in {land}')
    return j


def mirror_pieces(pieces, land):
    """The same pieces reflected across the land's axis (road node ids swapped for their mirror partners)."""
    out = {}
    for name, (nodes, links) in pieces.items():
        nn = {k: (reflect(xy, land), kind) for k, (xy, kind) in nodes.items()}
        ll = [(mirror_road(a, land) if isinstance(a, int) else a, mirror_road(b, land) if isinstance(b, int) else b,
               reflect(c, land) if c else None) for a, b, c in links]
        out[name] = (nn, ll)
    return out


def reflect_line(p, a, b):          # mirror point p across the line through points a and b
    dx, dy = b[0] - a[0], b[1] - a[1]
    t = ((p[0] - a[0]) * dx + (p[1] - a[1]) * dy) / (dx * dx + dy * dy)
    fx, fy = a[0] + t * dx, a[1] + t * dy
    return (2 * fx - p[0], 2 * fy - p[1])


def wall_pair(half, wa, wb):
    """A half figure and its mirror across the wall line through road nodes wa and wb (user 2026-11-18: "the symmetry
    mirror thing by the cell wall"). half = {name: (nodes, links)} drawn on one side of the wall. Returns (half,
    mirrored) so each half goes in the cell on its own side. Road node ids in the links map to the road node at the
    mirrored position: nodes on the wall line map to themselves; any other must have a road node within 0.1 of its
    mirror point, or ValueError."""
    A, B = road(wa), road(wb)

    def rmap(i):
        q = reflect_line(road(i), A, B)
        j = min(roads(), key=lambda k: math.dist(roads()[k], q))
        if math.dist(roads()[j], q) > 0.1:
            raise ValueError(f'road node {i} has no mirror across wall {wa}-{wb}')
        return j

    out = {}
    for name, (nodes, links) in half.items():
        nn = {k: (reflect_line(xy, A, B), kind) for k, (xy, kind) in nodes.items()}
        ll = [(rmap(x) if isinstance(x, int) else x, rmap(y) if isinstance(y, int) else y,
               reflect_line(c, A, B) if c else None) for x, y, c in links]
        out[name] = (nn, ll)
    return half, out


def fill_rows(pieces, rows):         # FILL rows with road ids looked up from the base map
    for n, r, f, s, st, a, t, h in rows:
        pieces[n.replace(' ', '_')] = place(r, road(r), f, s, st, a, t, h)
    return pieces


def load(path):
    here = os.path.dirname(os.path.abspath(__file__))     # cell files import celllib from here
    if here not in sys.path:
        sys.path.insert(0, here)
    sys.path.insert(0, os.path.dirname(os.path.abspath(path)))
    spec = importlib.util.spec_from_file_location(os.path.basename(path)[:-3], path)
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


def compile_cells(inp, out, cells):
    M = json.load(open(inp, encoding='utf-8'))
    nid = max(n['id'] for n in M['nodes']) + 1
    cl = max([n['cluster'] for n in M['nodes'] if isinstance(n.get('cluster'), int)] + [8999]) + 1
    for path in cells:
        C = load(path)
        groups = C.CELLS.items() if hasattr(C, 'CELLS') else [(C.CELL, C.PIECES)]
        for cell_id, pieces in groups:
            cl, nid = _emit(M, C.THEME, cell_id, pieces, cl, nid)
    json.dump(M, open(out, 'w', encoding='utf-8'), ensure_ascii=False)


def _emit(M, theme, cell_id, pieces, cl, nid):
    if True:
        tag = f'c{cell_id}'
        for name, (nodes, links) in pieces.items():
            ids = {}
            for k, ((x, y), kind) in nodes.items():
                ids[k] = nid
                M['nodes'].append({'id': nid, 'x': round(x, 4), 'y': round(y, 4), 'kind': kind, 'theme': theme,
                                   'cluster': cl, 'region': theme, 'name': f'{tag} {name} {k}',
                                   'u': round(x, 4), 'v': round(y, 4)})
                nid += 1
            for a, b, arc in links:
                ed = {'a': ids.get(a, a), 'b': ids.get(b, b), 'ph': 'cell' + str(cell_id)}
                if arc:
                    ed['arc'] = [round(arc[0], 4), round(arc[1], 4)]
                M['edges'].append(ed)
            cl += 1
        print(f'cell {cell_id}: {len(pieces)} pieces, {sum(len(v[0]) for v in pieces.values())} nodes')
    return cl, nid


if __name__ == '__main__':
    compile_cells(sys.argv[1], sys.argv[2], sys.argv[3:])
