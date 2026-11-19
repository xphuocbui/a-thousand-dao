"""Writes layout7.json. Every coordinate below is written by hand; this only lays the entries out as JSON."""
import json

name = {0: 'Fire', 72: 'Earth', 144: 'Metal', 216: 'Water', 288: 'Wood'}
blend_of = {0: 'Wood-Fire', 72: 'Fire-Earth', 144: 'Earth-Metal', 216: 'Metal-Water', 288: 'Water-Wood'}   # the blend on each land's left
inner = {0: 37.5, 72: 36.4, 144: 36.7, 216: 43.9, 288: 36.4}
outer = {0: 79.1, 72: 80.0, 144: 79.9, 216: 79.9, 288: 80.0}
HEX_LINKS = [[0, 1], [1, 2], [2, 3], [3, 4], [4, 5], [5, 0]]
adds = []
# 1. small clusters (placeholders): a six-node ring with two notables, threaded on the axis
for L in (0, 72, 144, 216, 288):
    adds.append({'land': L, 'kind': 'cluster', 'why': '%s small cluster (placeholder for its emblem)' % name[L], 'node_kinds': ['s', 's', 'N', 's', 'N', 's'], 'links': HEX_LINKS,
                 'polar': [[0.0, 45.6], [-2.48, 46.8], [-2.48, 49.2], [0.0, 50.4], [2.48, 49.2], [2.48, 46.8]]})
for L in (0, 72, 144, 216):
    adds.append({'land': L, 'kind': 'cluster', 'why': '%s blend small cluster (placeholder for its circle)' % blend_of[L], 'node_kinds': ['s', 's', 'N', 's', 'N', 's'], 'links': HEX_LINKS,
                 'polar': [[-36.0, 56.8], [-37.85, 57.9], [-37.85, 60.1], [-36.0, 61.2], [-34.15, 60.1], [-34.15, 57.9]]})
# 2. axis roads through the clusters
for L in (0, 72, 144, 216, 288):
    if L == 216:
        adds.append({'land': L, 'kind': 'road', 'why': 'Water axis road, Ice start to its cluster', 'polar': [[0.0, 43.9], [0.0, 45.6]]})
    else:
        adds.append({'land': L, 'kind': 'road', 'why': '%s axis road to its cluster' % name[L], 'polar': [[0.0, inner[L]], [0.0, 41.7], [0.0, 45.6]]})
    adds.append({'land': L, 'kind': 'road', 'why': '%s axis road from its cluster out to the open band' % name[L],
                 'polar': [[0.0, 50.4], [0.0, 53.9], [0.0, 59.1], [0.0, 64.3], [0.0, 69.3], [0.0, 74.3], [0.0, outer[L]]]})
for L in (0, 72, 144, 216, 288):
    adds.append({'land': L, 'kind': 'road', 'why': '%s blend axis road, inner part' % blend_of[L], 'polar': [[-36.0, 28.3], [-36.0, 33.2], [-36.0, 37.5], [-36.0, 41.7], [-36.0, 45.9]]})
    if L != 288:
        adds.append({'land': L, 'kind': 'road', 'why': '%s blend axis road into its cluster' % blend_of[L], 'polar': [[-36.0, 49.6], [-36.0, 53.9], [-36.0, 56.8]]})
        adds.append({'land': L, 'kind': 'road', 'why': '%s blend axis road out of its cluster' % blend_of[L], 'polar': [[-36.0, 61.2], [-36.0, 64.3], [-36.0, 69.4]]})
# 3. full-circle rings, left halves mirrored (Water and Wood per side at the Wind start; Water's ring 1 bumps over the Ice start)
RA = [[-36, 33.2], [-31, 33.2], [-26, 33.2], [-23, 33.2], [-20, 33.2], [-14, 33.2], [-8, 33.2], [0, 32.8]]
RB = [[-36, 41.7], [-32, 41.7], [-28, 41.7], [-23, 41.7], [-18, 41.7], [-13, 41.7], [-8.5, 41.7], [-4.3, 41.7], [0, 41.7]]
RBW = [[-36, 41.7], [-32, 41.7], [-28, 41.7], [-23, 41.7], [-18, 41.7], [-13, 41.7], [-8.5, 41.7], [-5.0, 42.6], [0, 42.8]]
RM = [[-36, 53.9], [-32.5, 53.9], [-29, 53.9], [-23, 53.9], [-18, 53.9], [-11, 53.9], [-7.3, 53.9], [-3.6, 53.9], [0, 53.9]]
RC = [[-36, 64.3], [-33.5, 64.3], [-31, 64.3], [-28, 64.3], [-23, 64.3], [-20, 64.3], [-17, 64.3], [-14, 64.3], [-11, 64.3], [-6, 64.3], [-3, 64.3], [0, 64.3]]
RD = [[-36, 74.3], [-32, 74.3], [-28, 74.3], [-24, 74.3], [-20, 74.3], [-17, 74.3], [-14.5, 74.3], [-12, 74.3], [-8, 74.3], [-5.5, 74.3], [-2.7, 74.3], [0, 74.3]]
wind = lambda pts, r: [[pts[0][0], r]] + pts[1:]
flip = lambda pts: [[-o, r] for o, r in pts]
for L in (0, 72, 144, 216, 288):
    adds.append({'land': L, 'mirror': L, 'kind': 'road', 'why': '%s start ring' % name[L], 'polar': RA})
    adds.append({'land': L, 'mirror': L, 'kind': 'road', 'why': '%s ring 1%s' % (name[L], ', over the Ice start' if L == 216 else ''), 'polar': RBW if L == 216 else RB})
    adds.append({'land': L, 'mirror': L, 'kind': 'road', 'why': '%s outer ring' % name[L], 'polar': RD})
    if L in (0, 72, 144):
        adds.append({'land': L, 'mirror': L, 'kind': 'road', 'why': '%s middle ring' % name[L], 'polar': RM})
        adds.append({'land': L, 'mirror': L, 'kind': 'road', 'why': '%s ring 2' % name[L], 'polar': RC})
adds += [
    {'land': 216, 'kind': 'road', 'why': 'Water middle ring, left', 'polar': RM},
    {'land': 216, 'kind': 'road', 'why': 'Water middle ring, right, to the Water-Wood axis below the Wind start', 'polar': flip(wind(RM, 53.4))},
    {'land': 216, 'kind': 'road', 'why': 'Water ring 2, left', 'polar': RC},
    {'land': 216, 'kind': 'road', 'why': 'Water ring 2, right, to the Water-Wood axis above the Wind start', 'polar': flip(wind(RC, 64.6))},
    {'land': 288, 'kind': 'road', 'why': 'Wood middle ring, left, to the Water-Wood axis below the Wind start', 'polar': wind(RM, 53.4)},
    {'land': 288, 'kind': 'road', 'why': 'Wood middle ring, right', 'polar': flip(RM)},
    {'land': 288, 'kind': 'road', 'why': 'Wood ring 2, left, to the Water-Wood axis above the Wind start', 'polar': wind(RC, 64.6)},
    {'land': 288, 'kind': 'road', 'why': 'Wood ring 2, right', 'polar': flip(RC)},
]
# 4. staggered spokes (brick), mirrored, plus the new one in the band under ring 1
SP = [([[-23, 33.2], [-23, 37.5], [-23, 41.7]], 'wall', 'between the start ring and ring 1'),
      ([[-18, 41.7], [-18, 45.8], [-18, 49.9], [-18, 53.9]], 'wall', 'between ring 1 and the middle ring'),
      ([[-11, 53.9], [-11, 59.1], [-11, 64.3]], 'road', 'between the middle ring and ring 2'),
      ([[-23, 53.9], [-23, 59.1], [-23, 64.3]], 'wall', 'between the middle ring and ring 2'),
      ([[-17, 64.3], [-17, 69.3], [-17, 74.3]], 'wall', 'between ring 2 and the outer ring'),
      ([[-28, 64.3], [-28, 69.3], [-28, 74.3]], 'road', 'between ring 2 and the outer ring'),
      ([[-12, 74.3], [-12, 79.2]], 'road', 'hook into the open band')]
for L in (0, 72, 144, 216, 288):
    for pts, kind, where in SP:
        a = {'land': L, 'mirror': L, 'kind': kind, 'why': '%s spoke %s' % (name[L], where), 'polar': pts}
        if where.startswith('hook'):
            a['open'] = True
        adds.append(a)
# 5. Darkness, now that the rim ring is gone
adds.append({'land': 72, 'kind': 'road', 'why': 'Darkness connector from its rim piece at 105 degrees down to the outer ring', 'polar': [[33.0, 84.0], [33.0, 79.2], [32.0, 74.3]]})
adds.append({'land': 216, 'kind': 'road', 'why': 'Darkness connector from its rim piece at 204 degrees onto the Water hook', 'polar': [[-12.0, 79.2], [-12.0, 84.0]]})
doc = ('Layout v7 (2026-11-18). User: the bends round the big emblems were ugly; shrink each emblem to a literal small '
       'cluster. On base5 (clean base with every emblem and the rim ring removed): a small six-node cluster with two '
       'notables on each land axis at 48 and each blend axis at 59 (the Water-Wood blend keeps the Wind start), threaded '
       'on full axis roads; five full-circle rings (33.2, 41.7, 53.9, 64.3, 74.3) crossing the axes at road junctions, '
       'with one small bump over the Ice start; staggered spokes (one new in the band under ring 1), hooks into the open '
       'band, and two Darkness connectors. Hand-placed polar points; mirrored per land where marked. layout-hand is unchanged.')
json.dump({'_doc': doc, 'adds': adds}, open('layout7.json', 'w', encoding='utf-8'), indent=0)
print(len(adds), 'adds')
