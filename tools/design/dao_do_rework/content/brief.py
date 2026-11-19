"""Print what an area's content records need (observations only): python -I brief.py <area> [B|M|S]

For each piece of the tier (default B; a mirrored pair once): key, size, the notables in walk order with their
distance from the entry (the crown marked *), and for big pictures the step-A idea, lines, capability and Effect.
"""
import collections
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import pieces as P   # noqa: E402

ROOT = os.path.abspath(os.path.join(HERE, '..', '..', '..', '..'))
MAP = os.path.join(ROOT, 'design', 'dao-do', 'cells', 'versions', 'v5-frozen-2026-11-19', 'dao-do-map.json')


def main():
    area = sys.argv[1]
    tier = sys.argv[2] if len(sys.argv) > 2 else 'B'
    m, nodes, adj = P.load(MAP)
    ideas = collections.defaultdict(list)
    src = os.path.join(ROOT, 'design', 'dao-do', 'content', 'src', 'ideas.py')
    exec(compile(open(src, encoding='utf-8').read(), src, 'exec'),
         {'I': lambda ar, key, idea, lines, cap=None, effect=None, pending=(), note='':
          ideas[(ar, key)].append((idea, lines, cap, effect, list(pending)))})
    seen = set()
    ps_all = P.pieces(m, nodes, adj, area)
    cell_ideas = collections.defaultdict(list)
    for q in ps_all:
        for idea, *_ in ideas.get((area, q['key'])) or ideas.get((area, q.get('twin'))) or []:
            cell_ideas[q['key'].split(' ')[0]].append(idea.split(' (')[0])
    for p in ps_all:
        start_fig = tier == 'M' and p['tier'] == 'B' and not p['named']   # start figures are filled in step D
        if (p['tier'] != tier and not start_fig) or p['key'] in seen:
            continue
        seen |= {p['key'], p.get('twin')}
        nts = [i for i in p['order'] if nodes[i]['kind'] == 'notable']
        marks = ' '.join(f"{i}{'*' if i == p['crown'] else ''}@{p['dist'][i]}" for i in nts)
        pair = f" pair:{p['twin']}" if p.get('twin') else ''
        near = ''
        if tier != 'B':
            near = ' | cell: ' + ', '.join(dict.fromkeys(cell_ideas.get(p['key'].split(' ')[0], []))) if p['named'] else ' | start figure'
        print(f"{p['key']} n={p['n']} nts={len(nts)} r{p['r']:.0f} {p['off']:+.0f}{pair}{near}" if tier != 'B' else
              f"{p['key']} n={p['n']} smalls={p['n'] - len(nts)} r{p['r']:.0f} {p['off']:+.0f}{pair} | notables: {marks}")
        for idea, lines, cap, eff, pend in ideas.get((area, p['key'])) or ideas.get((area, p.get('twin'))) or []:
            print(f"    {idea} :: {lines}" + (f" cap={cap}" if cap else '') + (f" effect={eff}" if eff else '')
                  + (f" pending={pend}" if pend else ''))


if __name__ == '__main__':
    main()
