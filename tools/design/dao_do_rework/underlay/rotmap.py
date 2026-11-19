"""Turns a map so a land's axis points down (+y), for close-up renders. usage: python -I rotmap.py <in> <out> <axis deg>"""
import json, math, sys
M = json.load(open(sys.argv[1], encoding='utf-8')); a = math.radians(float(sys.argv[3]))
def rot(x, y):  # P(r, th) -> P(r, th - axis)
    return (x * math.cos(a) - y * math.sin(a), x * math.sin(a) + y * math.cos(a))
for n in M['nodes']:
    n['x'], n['y'] = rot(n['x'], n['y']); n['u'], n['v'] = n['x'], n['y']
for e in M['edges']:
    if e.get('arc'):
        e['arc'] = list(rot(*e['arc']))
json.dump(M, open(sys.argv[2], 'w', encoding='utf-8'), ensure_ascii=False)
