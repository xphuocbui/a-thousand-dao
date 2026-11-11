import sys
p = 'design/arts/family-force-chaos.json'
s = open(p, encoding='utf-8').read()
R = [
('"kind": "elem", "c_art": 2.3,\n "statuses": [{"id": "qi_disruption"', '"kind": "elem", "c_art": 2.0,\n "statuses": [{"id": "qi_disruption"'),
('"c_mult": 2.0, "add_statuses"', '"c_mult": 1.7, "add_statuses"'),
('"c_mult": 5.0, "qi_restore": 0.08}', '"c_mult": 4.0, "qi_restore": 0.08}'),
('"c_art": 3.0,', '"c_art": 2.6,'),
('"c_art": 1.4,', '"c_art": 0.9,'),
('"c_mult": 4.0},\n  {"if": [{"read": "own.counter.fray", "op": "<", "value": 6}, {"read": "foe.distinct_statuses", "op": ">=", "value": 4}],\n   "c_mult": 3.5}', '"c_mult": 3.0},\n  {"if": [{"read": "own.counter.fray", "op": "<", "value": 6}, {"read": "foe.distinct_statuses", "op": ">=", "value": 4}],\n   "c_mult": 2.5}'),
('"c_art": 2.2,', '"c_art": 1.3,'),
('"c_art": 2.0,\n "statuses": [{"id": "stagnation"', '"c_art": 1.2,\n "statuses": [{"id": "stagnation"'),
('"dmg_more": 12}', '"dmg_more": 6}'),
('"c_mult": 1.8, "add', '"c_mult": 1.4, "add'),
('"c_mult": 4.0, "add_statuses": [{"id": "stagnation", "stacks": 3', '"c_mult": 3.0, "add_statuses": [{"id": "stagnation", "stacks": 3'),
('"kind": "elem", "c_art": 2.5, "hp_cost"', '"kind": "elem", "c_art": 1.4, "hp_cost"'),
('"dmg_more": 6, "for": 2}}]},\n  {"id": "rite-recoup"', '"dmg_more": 4, "for": 2}}]},\n  {"id": "rite-recoup"'),
('"leech_hp": 20', '"leech_hp": 12'),
]
for a, b in R:
    assert a in s, a[:60]
    s = s.replace(a, b)
open(p, 'w', encoding='utf-8').write(s)
