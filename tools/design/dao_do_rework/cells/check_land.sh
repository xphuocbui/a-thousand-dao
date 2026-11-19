#!/bin/sh
# usage: sh tools/design/dao_do_rework/cells/check_land.sh <tag> <cell or land files...>   (run from the repo root)
#   compiles the files onto design/dao-do/cells/base-map.json (in order), audits the whole map (the base map alone shows
#   "other link <0.6 4 nodes", outside every cell), checks the cluster rules of every hand-placed piece and lists nodes
#   per cell. Output: design/dao-do/cells/out/<tag>-map.json and temp files carrying <tag>. Report only.
T=tools/design/dao_do_rework/cells; D=design/dao-do/cells; O=$D/out
TAG=$1; shift
mkdir -p "$O"
python -I "$T/celllib.py" "$D/base-map.json" "$O/$TAG-map.json" "$@" > "$O/$TAG-compile.txt" || { cat "$O/$TAG-compile.txt"; exit 1; }
tail -n 3 "$O/$TAG-compile.txt"
python -I tools/design/dao_do_rework/authoring/audit.py "$O/$TAG-map.json" --list | grep -v "by phase\|by kinds" | head -24
python -I - "$O/$TAG-map.json" "$O/$TAG" <<'PYEOF'
import json, sys, subprocess, collections, os
mp, pre = sys.argv[1:3]
M = json.load(open(mp)); ids = {}
for n in M['nodes']:
    c = n.get('cluster')
    if c is not None and c not in ids:
        nm = n.get('name') or str(c)
        ids[c] = {'id': c, 'form': nm.split(' ')[1] if nm.startswith('c') and ' ' in nm else 'base' + str(c), 'region': n.get('region'), 'name': nm}
M['clusters'] = list(ids.values()); json.dump(M, open(pre + '-rules-in.json', 'w'))
subprocess.run(['python', '-I', 'tools/design/dao_do_rework/cluster_rules.py', pre + '-rules-in.json', '--json', pre + '-rules-out.json'], capture_output=True)
d = json.load(open(pre + '-rules-out.json'))
rows = [r for r in d['clusters'] if str(r.get('name', '')).startswith('c') and str(r.get('name', ''))[1:2].isdigit()]
bad = [(r['name'].rsplit(' ', 1)[0], [k for k in ('R0', 'R2', 'R3', 'R4') if r[k] is False]) for r in rows if any(r[k] is False for k in ('R0', 'R2', 'R3', 'R4'))]
print('rules:', len(rows), 'pieces;', bad or 'all pass')
per = collections.Counter(n['name'].split(' ')[0] for n in M['nodes'] if str(n.get('name', '')).startswith('c') and str(n.get('name', ''))[1:2].isdigit())
print('nodes per cell:', dict(sorted(per.items(), key=lambda kv: int(kv[0][1:]))))
for f in (pre + '-rules-in.json', pre + '-rules-out.json'): os.remove(f)
PYEOF
