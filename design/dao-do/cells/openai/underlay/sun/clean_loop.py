"""Cleanup loop for the traced Sun tree (report-driven): compile, check, and for each issue in the tree drop the
shortest drawn stroke involved (or the small sun involved), until clean. Writes sun_drops.json. Run from the repo root."""
import collections, json, os, re, subprocess
D = 'design/dao-do/cells/openai/underlay/sun/sun_drops.json'
drops = json.load(open(D)) if os.path.exists(D) else {'strokes': [], 'suns': []}
for it in range(40):
    json.dump(drops, open(D, 'w'))
    O = 'design/dao-do/cells/openai'
    files = ['design/dao-do/cells/sun_trace.py', 'design/dao-do/cells/moon_trace.py', 'design/dao-do/cells/thunder_trace.py', O + '/oai2_chaos.py', O + '/pagoda/oai_pagoda2.py', 'design/dao-do/cells/keystones_islands.py']
    subprocess.run(['sh', O + '/check.sh', 'sunclean'] + files, capture_output=True, text=True)
    out = subprocess.run(['python', '-I', O + '/oai_check.py', 'design/dao-do/cells/out/sunclean-map.json', '931'], capture_output=True, text=True).stdout
    issues = [l for l in out.splitlines() if l.startswith(('SPACING', 'CROSSING', 'RULE'))]
    tree_issues = [l for l in issues if 'branch_' in l]
    issues = [l for l in issues if 'keystone_gate' not in l]
    print(it, len(issues), 'issues,', len(tree_issues), 'in the tree', flush=True)
    if not tree_issues:
        print('\n'.join(issues[:10])); break
    M = json.load(open('design/dao-do/cells/out/sunclean-map.json', encoding='utf-8'))
    size = collections.Counter()
    for n in M['nodes']:
        m = re.match(r'c931 (branch_\d+)(?:p\d+)?_[rl] e(\d+)_', n.get('name') or '')
        if m: size[(m.group(1), int(m.group(2)))] += 1
    new = set()
    for l in tree_issues:
        cands = []
        for b, key in re.findall(r'c931 (branch_\d+)(?:p\d+)?_[rl] (\S+)', l):
            m = re.match(r'e(\d+)_', key)
            if m:
                cands.append((size[(b, int(m.group(1)))], 'stroke', (b, int(m.group(1)))))
            m = re.match(r'sun(\d+)_', key)
            if m:
                cands.append((5, 'sun', int(m.group(1))))
        if cands:
            new.add(min(cands)[1:])
    if not new:
        print('issues left with no stroke to drop:'); print('\n'.join(tree_issues[:12])); break
    added = False
    for kind, v in new:
        if kind == 'stroke' and list(v) not in drops['strokes']:
            drops['strokes'].append(list(v)); added = True
        if kind == 'sun' and v not in drops['suns']:
            drops['suns'].append(v); added = True
    if not added:
        # stuck on trunk strokes (not leaves): force the smallest one involved, if it holds at most 8 nodes
        drops.setdefault('force', [])
        f = sorted((size[v], v) for kind, v in new if kind == 'stroke' and v[1] not in drops['force'] and size[v] <= 8)
        if not f:
            print('stuck:'); print('\n'.join(tree_issues[:12])); break
        drops['force'].append(f[0][1][1])
json.dump(drops, open(D, 'w'))
print('dropped', len(drops['strokes']), 'strokes and', len(drops['suns']), 'suns')
