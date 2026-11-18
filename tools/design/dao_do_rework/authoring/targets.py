"""Our Đạo Đồ against the PoE targets of design/dao-do/authoring-notes.md, per region and in total.
Needs no PoE data: the targets were measured once (2026-11-16, combos2.py / poe_study) and are written in below.
Like the other helpers it reports observations, never a verdict.   usage: targets.py map.json [--regions]"""
import sys, json, collections, statistics as st

# measured on PoE 2 (PoE 1 in brackets in the notes)
POE = {"size_median": 5, "size_le9": 90, "notables_1_2_3": (60, 24, 13), "road_load_0_1_2_3_4": (16, 20, 21, 20, 22),
       "keystone_share": 0.8}
ORDER = ['fire', 'earth', 'metal', 'water', 'wood', 'blend_fe', 'blend_em', 'blend_mw', 'blend_ww', 'blend_wf',
         'hub', 'light', 'thunder', 'darkness', 'shrine']
SK = ('small', 'notable', 'keystone')

M = json.load(open(sys.argv[1], encoding='utf-8'))
N = {n['id']: n for n in M['nodes']}
adj = collections.defaultdict(set)
for e in M['edges']:
    adj[e['a']].add(e['b']); adj[e['b']].add(e['a'])
gid = {}
for k, g in enumerate(M['groups']):
    for i in g['nodes']:
        gid[i] = k


def measure(regs):
    gs = [(k, g) for k, g in enumerate(M['groups']) if g.get('region') in regs
          and not g['shape'].startswith(('start', 'emblem')) and g['shape'] != 'keystone']
    sizes, nots, combo, fill, shapes = [], [], 0, 0, collections.Counter()
    for k, g in gs:
        ids = [i for i in g['nodes'] if N[i]['kind'] in SK]
        if not ids:
            continue
        sizes.append(len(ids)); nots.append(sum(N[i]['kind'] == 'notable' for i in ids)); shapes[g['shape']] += 1
        if g.get('combo'):
            combo += len(ids)
        else:
            fill += len(ids)
    rn = [n for n in M['nodes'] if n.get('region') in regs]
    tr = [n['id'] for n in rn if n['kind'] == 'travel']
    load = collections.Counter(min(4, len({gid[j] for j in adj[t] if j in gid and N[j]['kind'] in SK
                                           and not M['groups'][gid[j]]['shape'].startswith(('start', 'emblem'))})) for t in tr)
    k_ = len(sizes) or 1; t_ = len(tr) or 1
    nc = collections.Counter(min(x, 3) for x in nots)
    return {"nodes": len(rn), "clusters": len(sizes),
            "size_mean": round(st.mean(sizes), 1) if sizes else 0, "size_median": st.median(sizes) if sizes else 0,
            "size_le5": round(100 * sum(s <= 5 for s in sizes) / k_), "size_le9": round(100 * sum(s <= 9 for s in sizes) / k_),
            "notables": sum(nots), "notables_1_2_3": tuple(round(100 * nc[i] / k_) for i in (1, 2, 3)),
            "road_load_0_1_2_3_4": tuple(round(100 * load[i] / t_) for i in range(5)),
            "keystones": sum(n['kind'] == 'keystone' for n in rn),
            "keystone_share": round(100 * sum(n['kind'] == 'keystone' for n in rn) / max(1, len(rn)), 2),
            "combo_share": round(100 * combo / max(1, combo + fill)),
            "commonest": shapes.most_common(3)}


def row(name, m):
    return ("%-9s nodes %5d  clusters %4d  size mean %4.1f med %4.1f  <=5 %3d%%  <=9 %3d%%  notables %4d  1/2/3+ %2d/%2d/%2d%%  "
            "road load 0-4+ %s  keystones %2d (%.2f%%)  combo share %2d%%" % (
                name, m['nodes'], m['clusters'], m['size_mean'], m['size_median'], m['size_le5'], m['size_le9'], m['notables'],
                *m['notables_1_2_3'], '/'.join('%d' % x for x in m['road_load_0_1_2_3_4']), m['keystones'],
                m['keystone_share'], m['combo_share']))


if '--regions' in sys.argv:
    for r in ORDER:
        print(row(r, measure({r})))
lands = measure(set(ORDER[:5])); rest = measure(set(ORDER[5:])); tot = measure(set(ORDER))
print(row('lands', lands)); print(row('others', rest)); print(row('all', tot))
print('PoE 2    size median %s, <=9 %d%%; notables 1/2/3+ %s%%; road load 0-4+ %s%%; keystones %.1f%% of nodes' % (
    POE['size_median'], POE['size_le9'], '/'.join(map(str, POE['notables_1_2_3'])),
    '/'.join(map(str, POE['road_load_0_1_2_3_4'])), POE['keystone_share']))
