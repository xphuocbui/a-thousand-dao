import shutil
p = 'design/arts/family-soul-song-seal.json'
shutil.copy(p, 'design/arts/_logs/tune2-sss-orig.json')
s = open(p, encoding='utf-8').read()
R = [('"soul_pct": 0.036', '"soul_pct": 0.052'), ('"soul_pct": 0.043', '"soul_pct": 0.062'),
     ('{"free_hit": {"c": 1.5, "dtype": "soul"}}', '{"free_hit": {"c": 2.4, "dtype": "soul"}}'),
     ('{"free_hit": {"c": 4.5, "dtype": "soul"}}', '{"free_hit": {"c": 6.0, "dtype": "soul"}}'),
     ('{"free_hit": {"c": 7.0, "dtype": "soul"}}, {"status"', '{"free_hit": {"c": 9.0, "dtype": "soul"}}, {"status"'),
     ('"empower": [\n  {"if": [{"any": [{"read": "foe.status.slackened_soul", "op": ">=", "value": 2}, {"read": "foe.qi_share"',
      '"empower": [\n  {"if": [{"read": "foe.status.slackened_soul", "op": ">=", "value": 1}, {"any": [{"read": "foe.status.slackened_soul", "op": ">=", "value": 2}, {"read": "foe.qi_share"'),
     ('"pay": [{"free_hit": {"c": 7.0, "dtype": "soul"}}, {"gain_qi"', '"pay": [{"free_hit": {"c": 10.0, "dtype": "soul"}}, {"gain_qi"'),
     ('"art_speed": 20, "basic_speed": 20, "cost_red": -0.2', '"art_speed": 35, "basic_speed": 35, "cost_red": -0.05'),
     ('"free_hit": {"c": 0.55, "dtype": "elem"}', '"free_hit": {"c": 0.9, "dtype": "elem"}'),
     ('"c_art": 0.7, "cost_share": 0.03, "cooldown": 4, "kind": "elem", "hp_cost": 0.08',
      '"c_art": 1.3, "cost_share": 0.03, "cooldown": 3, "kind": "elem", "hp_cost": 0.04'),
     ('"dmg_more": 3,', '"dmg_more": 5,'),
     ('"value": 4}, {"read": "own.since.tolling-bell-requiem", "op": "<=", "value": 2}]}],',
      '"value": 4}, {"read": "own.since.tolling-bell-requiem", "op": "<=", "value": 2}]}]}],')]
for a, b in R:
    assert a in s, a
    s = s.replace(a, b)
open(p, 'w', encoding='utf-8').write(s)
