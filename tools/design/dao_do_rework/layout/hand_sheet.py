"""Contact sheet of the pieces left for hand work: each piece and its surroundings, overlapping pairs in red. Args: repo, scratch, out."""
import json, os, sys, math, collections as C
from PIL import Image, ImageDraw
ROOT, S, OUT = sys.argv[1:4]
M = json.load(open(os.path.join(S, 'islands', 'scaled-map.json'), encoding='utf-8'))
G = {n['id']: n for n in json.load(open(os.path.join(ROOT, 'assets/data/dao_do_map.json'), encoding='utf-8'))['nodes']}
P = {n['id']: (n['x'], n['y']) for n in M['nodes']}
hand = json.load(open(os.path.join(S, 'islands', 'piece-growth.json'), encoding='utf-8'))['hand']
D = {'road': 0.53, 'travel': 0.53, 'small': 0.68, 'notable': 1.02, 'keystone': 1.62, 'start': 1.79}
clu = C.defaultdict(list)
for i in P:
    if G[i].get('cluster') is not None: clu[str(G[i]['cluster'])].append(i)
cells = []
for c in hand:
    ids = clu[c]; xs = [P[i][0] for i in ids]; ys = [P[i][1] for i in ids]
    cx, cy = (min(xs) + max(xs)) / 2, (min(ys) + max(ys)) / 2; w = max(max(xs) - min(xs), max(ys) - min(ys)) + 6
    Sc = 300 / w; im = Image.new('RGB', (300, 320), (12, 13, 16)); d = ImageDraw.Draw(im)
    tx = lambda p: ((p[0] - cx) * Sc + 150, (p[1] - cy) * Sc + 150)
    near = [i for i in P if abs(P[i][0] - cx) < w / 2 + 1 and abs(P[i][1] - cy) < w / 2 + 1]
    ns = set(near)
    for e in M['edges']:
        if e['a'] in ns and e['b'] in ns: d.line(tx(P[e['a']]) + tx(P[e['b']]), fill=(90, 76, 54), width=1)
    sid = set(ids)
    for i in near:
        r = D[G[i]['kind']] / 2 * Sc; x, y = tx(P[i])
        col = (220, 180, 90) if G[i]['kind'] == 'notable' else (150, 150, 150) if i in sid else (70, 70, 80)
        d.ellipse((x - r, y - r, x + r, y + r), outline=col, width=2)
    for a in near:
        for b in near:
            if a < b and math.dist(P[a], P[b]) < (D[G[a]['kind']] + D[G[b]['kind']]) / 2:
                d.line(tx(P[a]) + tx(P[b]), fill=(255, 60, 60), width=3)
    d.text((4, 302), '%s %s  needs x%.2f' % (c, G[ids[0]].get('name') or '', hand[c]['needs']), fill=(220, 220, 210))
    cells.append(im)
cols = 5; sheet = Image.new('RGB', (cols * 304, ((len(cells) + cols - 1) // cols) * 324), (0, 0, 0))
for k, im in enumerate(cells): sheet.paste(im, ((k % cols) * 304, (k // cols) * 324))
sheet.save(OUT, quality=88); print(len(cells))
