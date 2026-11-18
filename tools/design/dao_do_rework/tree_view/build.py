"""Build the tree page: PoE 2 and/or our compiled map, drawn by the same renderer (page.html) at the same scale.

usage: python -I build.py <out.html> [--artifact] [--rot DEG] [--poe2 <GGG data.json> [--label NAME]] [--ours <map.json> [--label NAME]] ...
Prints both audits and the PoE 2 scale. Open the page in a browser (drag, scroll, hover), or take fixed views with
shot.py. The page embeds PoE 2 data: keep it out of git.
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import trees  # noqa: E402

args = sys.argv[1:]
out = args.pop(0)
ARTIFACT = '--artifact' in args          # strip the document wrapper: the Artifact viewer adds its own
args = [a for a in args if a != '--artifact']
ROT = 0.0
if '--rot' in args:          # turn our maps so the land whose axis is DEG points up (u right, v up)
    k = args.index('--rot'); ROT = float(args[k + 1]); del args[k:k + 2]
# preset views (name, cx, cy, width in map units, screen y down)
PLACES = {
    'poe2': [['Whole tree', 0, 0, 125], ['Class starts', 0, 0, 44], ['North', 0, -30, 36], ['West rim', -44, 10, 30],
             ['Jewel socket, close', 0, -38.4, 16], ['Keystone, close', -46, 18, 16], ['Clusters, close', -22, -18, 16]],
    'ours': [['Whole map', 0, 0, 260], ['Fire, whole', 0, -56, 100], ['Fire band 1 (v 27-50)', 0, -38, 52],
             ['Fire band 1, left close', -12, -40, 20], ['Fire band 1, right close', 12, -40, 20], ['Fire band 2 (v 50-66)', 0, -58, 62], ['Fire band 3 (v 64-89)', 0, -76, 66], ['Fire, whole at PoE 2 compare scale', 0, -58, 72], ['Ash big cell (where the proposal differs)', -19, -57, 24]],
}
data, audits = {}, {}
i, n_ours = 0, 0
while i < len(args):
    if args[i] == '--poe2':
        t, a = trees.load_poe2(args[i + 1])
        t['label'] = 'PoE 2'
        if i + 2 < len(args) and args[i + 2] == '--label':
            t['label'] = args[i + 3]; i += 2
        data['poe2'], audits['poe2'] = t, a
        i += 2
    elif args[i] == '--ours':
        t, a = trees.load_ours(args[i + 1])
        if ROT:
            import math as _m
            c_, s_ = _m.cos(_m.radians(ROT)), _m.sin(_m.radians(ROT))
            # screen frame: x = world x, y = -world y; land u = x cos - y sin, v = x sin + y cos (world y = -screen y)
            def _r(x, y):
                wy = -y
                return (x * c_ - wy * s_, -(x * s_ + wy * c_))
            t['nodes'] = [[*_r(n[0], n[1]), n[2], n[3]] for n in t['nodes']]
            t['edges'] = [e[:2] + (list(_r(e[2], e[3])) if len(e) > 2 else []) for e in t['edges']]
        lab = os.path.splitext(os.path.basename(args[i + 1]))[0]
        if i + 2 < len(args) and args[i + 2] == '--label':
            lab = args[i + 3]; i += 2
        t['label'] = 'Đạo Đồ · ' + lab
        key = 'ours' if n_ours == 0 else 'ours%d' % n_ours
        n_ours += 1
        data[key], audits[key] = t, a
        i += 2
    else:
        sys.exit('unknown argument ' + args[i])
START = {'ours': 2, 'ours1': 8}      # the place each tab opens on (index into PLACES); fit to the whole tree if absent
for k in data:
    data[k]['places'] = PLACES.get(k if k in PLACES else 'ours', [])
    if k in START:
        data[k]['start'] = START[k]
for k in data:  # round for size
    t = data[k]
    t['nodes'] = [[round(n[0], 3), round(n[1], 3), n[2], n[3]] for n in t['nodes']]
    t['edges'] = [[e[0], e[1]] + [round(v, 3) for v in e[2:]] for e in t['edges']]
page = open(os.path.join(HERE, 'page.html'), encoding='utf-8').read()
blob = json.dumps({'trees': data}, ensure_ascii=False, separators=(',', ':')).replace('</', '<\\/')
page = page.replace('__DATA__', blob)
if ARTIFACT:
    a, b = page.index('<!--ARTIFACT-START-->'), page.index('<!--ARTIFACT-HEAD-END-->')
    c, d = page.index('<body>') + len('<body>'), page.index('<!--ARTIFACT-END-->')
    page = page[a + len('<!--ARTIFACT-START-->'):b] + page[c:d]
open(out, 'w', encoding='utf-8').write(page)
for k, a in audits.items():
    print('==', k)
    print(json.dumps(a, indent=1, ensure_ascii=False))
if 'poe2' in audits and 'ours' in audits:
    print(trees.scale_note(audits['poe2'], audits['ours']))
print('wrote', out, '%.1f MB' % (os.path.getsize(out) / 1e6))
