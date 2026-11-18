"""Fit check for hand authoring (2026-11-17): which of the author's own variants of ONE combo piece or ONE single piece
fit. It reports; it never writes a layout or picks a variant (rulebook: scripts may only compile, check and render).

usage: fitcheck.py <layout dir> <region> <entry index> <piece index> '<variants json>'
  variants: a list of {"tilt": deg, "bend": s, "length": l, "turn": deg} (any subset), applied to that piece only.
  For a single "piece" entry use piece index 0; tilt/bend/length/turn map to its tilt/bend/spoke/facing offset.
Prints, per variant, "fits" or the problems it causes, and the total problem count of the compile."""
import sys, json, glob, os, copy
sys.path.insert(0, 'C:/Users/xphuo/IdeaProjects/my-game/tools/design/dao_do_rework/skeleton')
import layout as L
B, G = L.B, L.G
D, REG, IDX, K, VARS = sys.argv[1], sys.argv[2], int(sys.argv[3]), int(sys.argv[4]), json.loads(sys.argv[5])
ORDER = ["fire", "earth", "metal", "water", "wood", "blend_fe", "blend_em", "blend_mw", "blend_ww", "blend_wf",
         "hub", "light", "thunder", "darkness", "shrine"]
lay = {}
for p in sorted(glob.glob(os.path.join(D, '*.json'))):
    for k, v in json.load(open(p, encoding='utf-8')).items():
        lay[k] = v
lay = dict([(k, lay[k]) for k in ORDER if k in lay] + [(k, v) for k, v in lay.items() if k not in ORDER])
B.DENSITY_CAP = 0
L.TILT_COMBOS = 0.0


def run(layout):
    M, frames = L.base()
    log = []
    L.compile_layout(layout, M, frames, log)
    return log


base_log = run(copy.deepcopy(lay))
print('as written: %d problems' % len(base_log))
for v in VARS:
    t = copy.deepcopy(lay)
    e = t[REG][IDX]
    if 'piece' in e:
        if 'tilt' in v: e['tilt'] = v['tilt']
        if 'bend' in v: e['bend'] = v['bend']
        if 'length' in v: e['spoke'] = v['length']
        if 'turn' in v: e['facing'] = e['facing'] + v['turn']
    else:
        names = e.get('row') or e.get('fan') or e.get('facing')
        n = len(names)
        for key, src in (('tilts', 'tilt'), ('bends', 'bend'), ('lengths', 'length'), ('turns', 'turn')):
            if src in v:
                cur = list(e.get(key) or ([1.6] * n if key == 'lengths' else [0] * n))
                cur[K] = v[src]
                e[key] = cur
    log = run(t)
    tag = '%s #%d' % (REG, IDX)
    piece = (e.get('piece') or names[K])
    mine = [x for x in log if x.startswith(tag) and piece in x]
    new = [x for x in log if x not in base_log]
    ok = not mine and not new
    print('%-58s %s | total %d' % (json.dumps(v), 'FITS' if ok else 'no: ' + '; '.join(x.split(': ', 1)[-1] for x in (mine + new))[:90], len(log)))
