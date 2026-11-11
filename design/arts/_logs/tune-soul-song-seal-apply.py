p = 'design/arts/family-soul-song-seal.json'
s = open(p, encoding='utf8').read()


def r(a, b):
    global s
    assert s.count(a) == 1, a
    s = s.replace(a, b)


# Bell
r('"soul_pct": 0.036', '"soul_pct": 0.05')
r('{"free_hit": {"c": 0.3, "dtype": "soul"}}]}\n ],', '{"free_hit": {"c": 0.4, "dtype": "soul"}}]}\n ],')
r('{"read": "own.counter.toll", "op": ">=", "value": 5}, {"read": "foe.status.slackened_soul", "op": ">=", "value": 2}',
  '{"read": "own.counter.toll", "op": ">=", "value": 3}, {"read": "foe.status.slackened_soul", "op": ">=", "value": 1}')
r('{"any": [{"read": "own.counter.toll", "op": ">=", "value": 8}, {"read": "own.hp_share", "op": "<=", "value": 0.4}]}],',
  '{"read": "own.counter.toll", "op": ">=", "value": 6}, {"any": [{"read": "foe.status.slackened_soul", "op": ">=", "value": 2}, {"read": "own.hp_share", "op": "<=", "value": 0.4}]}],')
# Lance
r('"soul_pct": 0.043', '"soul_pct": 0.055')
# Ambush
r('"c_art": 1.2, "cost_share": 0.04', '"c_art": 0.8, "cost_share": 0.04')
r('{"free_hit": {"c": 0.8, "dtype": "chaos"}}', '{"free_hit": {"c": 0.5, "dtype": "chaos"}}')
r('"c_mult": 3, "add_statuses"', '"c_mult": 2.2, "add_statuses"')
r('{"any": [{"read": "own.counter.seal", "op": ">=", "value": 5}, {"read": "foe.hp_share", "op": "<=", "value": 0.4}, {"read": "own.hp_share", "op": "<=", "value": 0.4}]}],\n   "pay": [{"counter": {"id": "seal", "add": -4}}], "c_mult": 7,',
  '{"read": "own.counter.seal", "op": ">=", "value": 4}, {"any": [{"read": "foe.hp_share", "op": "<=", "value": 0.5}, {"read": "own.hp_share", "op": "<=", "value": 0.4}]}],\n   "pay": [{"counter": {"id": "seal", "add": -4}}], "c_mult": 5,')
# Frozen
r('"c_art": 1.6, "cost_share": 0.05', '"c_art": 1.2, "cost_share": 0.05')
r('{"any": [{"read": "foe.status.slowed_time", "op": ">=", "value": 4}, {"read": "own.counter.seal", "op": ">=", "value": 4}, {"read": "own.since.ambush-talisman", "op": "<=", "value": 3}]}],\n   "pay": [{"counter": {"id": "seal", "add": -3}}, {"timer": {"side": "own", "which": "others", "by": -2}}], "c_mult": 5,',
  '{"read": "foe.status.slowed_time", "op": ">=", "value": 3}, {"any": [{"read": "own.counter.seal", "op": ">=", "value": 3}, {"read": "own.since.ambush-talisman", "op": "<=", "value": 3}]}],\n   "pay": [{"counter": {"id": "seal", "add": -3}}, {"timer": {"side": "own", "which": "others", "by": -1}}], "c_mult": 3.5,')
# Branding
r('"c_art": 2.9', '"c_art": 2.0')
r('{"any": [{"read": "foe.status.slackened_soul", "op": ">=", "value": 2}, {"read": "own.counter.seal", "op": ">=", "value": 5}, {"read": "foe.hp_share", "op": "<=", "value": 0.35}]}],\n   "pay": [{"counter": {"id": "seal", "add": -4}}], "c_mult": 4,',
  '{"read": "own.counter.seal", "op": ">=", "value": 2}, {"any": [{"read": "foe.status.slackened_soul", "op": ">=", "value": 2}, {"read": "foe.hp_share", "op": "<=", "value": 0.5}, {"read": "own.fired_within.1.group.nine-seal-ledger", "op": ">=", "value": 2}]}],\n   "pay": [{"counter": {"id": "seal", "add": -2}}], "c_mult": 3,')
# Lullaby, Blood-Ink
r('{"free_hit": {"c": 0.35, "dtype": "soul"}}', '{"free_hit": {"c": 0.55, "dtype": "soul"}}')
r('"c_art": 0.9, "cost_share": 0.03', '"c_art": 0.7, "cost_share": 0.03')
r('"dmg_more": 4', '"dmg_more": 3')
open(p, 'w', encoding='utf8').write(s)
