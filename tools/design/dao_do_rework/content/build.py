"""Compile and check one area's Đạo Đồ content (observations only; never chooses content).

Usage (repo root): python -I tools/design/dao_do_rework/content/build.py <area> [<area> ...] [--all]
Reads design/dao-do/content/src/<area>.py, writes design/dao-do/content/<area>.json, prints errors, warnings and a
summary. --all also checks notable names across every compiled area.
"""
import collections
import hashlib
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import content_lib as L          # noqa: E402
import pieces as P               # noqa: E402

ROOT = L.ROOT
MAP = os.path.join(ROOT, 'design', 'dao-do', 'cells', 'versions', 'v5-frozen-2026-11-19', 'dao-do-map.json')
CDIR = os.path.join(ROOT, 'design', 'dao-do', 'content')


def build(area, m, nodes, adj, sha):
    L.AREA.clear()
    errs_pre = []
    src = os.path.join(CDIR, 'src', area.replace('-', '_') + '.py')
    g = {k: getattr(L, k) for k in ('BIG', 'MED', 'SM', 'KEY', 'N', 'n', 'ONE')}
    exec(compile(open(src, encoding='utf-8').read(), src, 'exec'), g)
    ps = {p['key']: p for p in P.pieces(m, nodes, adj, area)}
    ideas = collections.defaultdict(list)
    gi = {'I': lambda ar, key, idea, lines, cap=None, effect=None, pending=(), note='':
          ideas[(ar, key)].append(dict(idea=idea, lines=lines))}
    isrc = os.path.join(CDIR, 'src', 'ideas.py')
    exec(compile(open(isrc, encoding='utf-8').read(), isrc, 'exec'), gi)
    for rec in L.AREA:
        if rec['kind'] != 'B':
            continue
        p = ps.get(rec['key'])
        cand = ideas.get((area, rec['key'])) or (p and p.get('twin') and ideas.get((area, p['twin']))) or []
        if not cand:
            errs_pre.append(f"{rec['key']}: no step-A idea"); continue
        lines = [ln for c in cand for ln in c['lines'][:2]] + [ln for c in cand for ln in c['lines'][2:]]
        rec['idea'] = rec['idea'] or ' + '.join(c['idea'] for c in cand)
        rec['a'] = rec['a'] or tuple(cand[0]['lines'][0])
        rec['b'] = rec['b'] or tuple(cand[0]['lines'][1]) if len(cand) == 1 else (rec['b'] or tuple(cand[1]['lines'][0]))
        if rec['a'][0] == 'density_bonus' or (rec['b'] and rec['b'][0] == 'density_bonus'):
            errs_pre.append(f"{rec['key']}: density floors to 0 on small nodes")
    errs, warns, out, done = list(errs_pre), [], {}, set()
    caps = []

    def put(p, rec, copy_main):
        if p['key'] in done:
            errs.append(f"{p['key']}: content given twice"); return
        done.add(p['key'])
        tier = p['tier']
        if rec['kind'] in ('B', 'M', 'S') and rec['kind'] != tier and not (rec['kind'] == 'M' and not p['named']):
            warns.append(f"{p['key']}: authored as {rec['kind']} but the piece is {tier} ({p['n']} nodes)")
        sm = [i for i in p['order'] if nodes[i]['kind'] == 'small']
        nt = [i for i in p['order'] if nodes[i]['kind'] == 'notable']
        if len(rec['nts']) != len(nt):
            errs.append(f"{p['key']}: {len(rec['nts'])} notables written, the piece has {len(nt)}"); return
        lines = {'A': rec['a'], 'B': rec['b'], 'C': rec['c']}
        for k, i in enumerate(sm):
            if rec.get('smalls'):
                ln = rec['smalls'][k % len(rec['smalls'])]
            else:
                ln = lines[rec['pat'][k % len(rec['pat'])]]
            if ln is None:
                errs.append(f"{p['key']}: pattern {rec['pat']} names a missing line"); return
            v = L.check_mod(ln[0], ln[1], L.SMALL, f"{p['key']} #{i}", 'small node', errs, warns)
            out[i] = dict(piece=p['key'], kind='small', idea=rec['idea'], mods=[[ln[0], ln[1], L.SMALL, v]])
        effects = 0
        for x, i in zip(rec['nts'], nt):
            rule_here = (x.cap or x.effect) and copy_main
            mods = x.mods if (copy_main or not (x.cap or x.effect)) else (x.alt or [])
            name = x.name if (copy_main or not x.alt_name) else x.alt_name
            if (x.cap or x.effect) and not copy_main and not x.alt:
                errs.append(f"{p['key']} #{i}: the twin copy needs alt=(...) for the notable holding {x.cap or x.effect}")
            budget = sum(mm[2] for mm in mods)
            want = L.NOTABLE
            if x.cap and copy_main:
                want = L.F_TIER[x.cap[1]] * L.NOTABLE
                caps.append((x.cap[0], p['key'], i))
            if abs(budget - want) > 0.01:
                errs.append(f"{p['key']} #{i} {name}: {budget} W, should be {want} W")
            if x.effect and copy_main:
                effects += 1
                if rec['kind'] != 'B' or i != p['crown']:
                    warns.append(f"{p['key']} #{i}: Effect {x.effect} not on a big picture's crown (method §4.6)")
            vals = [[k, s, w, L.check_mod(k, s, w, f"{p['key']} #{i}", 'notable', errs, warns)] for k, s, w in mods]
            pend = [[k, s, w] for k, s, w in x.pending]
            for k, s, w in x.pending:
                if k in L.STATS and L.STATS[k]['status'] != 'Pending' and frozenset(L.scope_tags(s)) in L.STATS[k]['scopes']:
                    warns.append(f"{p['key']} #{i}: pending {k}[{s}] is not Pending: move it to mods")
            out[i] = dict(piece=p['key'], kind='notable', idea=rec['idea'], name=name, mods=vals, pending=pend,
                          cap=(x.cap[0] if rule_here and x.cap else None), effect=(x.effect if rule_here else None),
                          twin_copy=not copy_main)
        if effects > 1:
            errs.append(f"{p['key']}: {effects} Effects (at most one per big picture)")
        if copy_main and rec['kind'] in ('B', 'M'):   # method §4.3: each notable a different pairing (weights ignored)
            seen_pairs = collections.Counter(frozenset((k, sc) for k, sc, w in x.mods) for x in rec['nts'] if len(x.mods) >= 2)
            for pr, cnt in seen_pairs.items():
                if cnt > 1:
                    warns.append(f"{p['key']}: the same pairing on {cnt} notables: {' + '.join(sorted(k + '[' + sc + ']' for k, sc in pr))}")
        if copy_main and rec['kind'] == 'M' and p['named']:   # method §4.4: a medium supports its cell's big picture, not its main line
            cell = p['key'].split(' ')[0]
            for q in L.AREA:
                if q['kind'] == 'B' and q['key'].split(' ')[0] == cell and q.get('a') and tuple(q['a']) == tuple(rec['a']):
                    warns.append(f"{p['key']}: medium theme {rec['a'][0]}[{rec['a'][1]}] is the main line of {q['key']}")

    for rec in L.AREA:
        if rec['kind'] == 'O':
            for i in rec['ids']:
                nd = nodes.get(i)
                if not nd or nd['kind'] != 'small' or nd.get('cluster') is not None or nd['region'] != area:
                    errs.append(f"ONE #{i}: not a loose small node of {area}"); continue
                if i in out:
                    errs.append(f"ONE #{i}: given twice"); continue
                v = L.check_mod(rec['a'][0], rec['a'][1], L.SMALL, f"loose #{i}", 'small node', errs, warns)
                out[i] = dict(piece='loose', kind='small', idea=None, mods=[[rec['a'][0], rec['a'][1], L.SMALL, v]])
            continue
        if rec['kind'] == 'K':
            kn = next((n for n in m['nodes'] if n['kind'] == 'keystone' and (n.get('name') or '').startswith(rec['key'] + ' ')), None)
            if not kn:
                errs.append(f"keystone {rec['key']}: not found"); continue
            w = sum(mm[2] for mm in rec['mods'])
            if w < 50:
                errs.append(f"keystone {rec['key']}: plain side {w} W < 50 W")
            vals = [[k, s, ww, L.check_mod(k, s, ww, f"keystone {rec['key']}", 'keystone', errs, warns)] for k, s, ww in rec['mods']]
            out[kn['id']] = dict(piece=rec['key'], kind='keystone', name=rec['name'], effect=rec['effect'],
                                 closes=rec['closes'], mods=vals)
            done.add(rec['key']); continue
        p = ps.get(rec['key'])
        if not p:
            errs.append(f"{rec['key']}: no such piece in {area}"); continue
        tw = ps.get(p.get('twin')) if rec.get('twin', True) and p.get('twin') else None
        if tw:
            main, other = (p, tw) if p['off'] < tw['off'] else (tw, p)
            put(main, rec, True); put(other, rec, False)
        else:
            put(p, rec, True)
    missing = [k for k, p in ps.items() if k not in done]
    return out, errs, warns, missing, caps, ps


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    m, nodes, adj = P.load(MAP)
    sha = hashlib.sha256(open(MAP, 'rb').read()).hexdigest()
    for area in args:
        out, errs, warns, missing, caps, ps = build(area, m, nodes, adj, sha)
        json.dump(dict(map='v5-frozen-2026-11-19', map_sha256=sha, area=area,
                       nodes={str(k): v for k, v in sorted(out.items())}),
                  open(os.path.join(CDIR, area + '.json'), 'w', encoding='utf-8'), ensure_ascii=False, indent=0)
        kinds = collections.Counter(v['kind'] for v in out.values())
        print(f"== {area}: {len(out)} nodes filled ({dict(kinds)}); pieces without content: {len(missing)}")
        for e in errs:
            print('  ERROR', e)
        for w in warns:
            print('  warn ', w)
        if missing:
            tiers = collections.Counter(ps[k]['tier'] for k in missing)
            print(f"  missing by tier: {dict(tiers)}")
        if caps:
            print('  capabilities:', ', '.join(f'{c} on {k} #{i}' for c, k, i in caps))
    if '--all' in sys.argv:
        names = collections.defaultdict(list)
        for f in sorted(os.listdir(CDIR)):
            if f.endswith('.json'):
                d = json.load(open(os.path.join(CDIR, f), encoding='utf-8'))
                for i, v in d['nodes'].items():
                    if v.get('name') and not v.get('twin_copy'):
                        names[v['name']].append(f"{d['area']}#{i}")
        dup = {k: v for k, v in names.items() if len(v) > 1}
        print(f"== names: {len(names)} distinct; repeated: {len(dup)}")
        for k, v in list(dup.items())[:40]:
            print('  ', k, v)


if __name__ == '__main__':
    main()
