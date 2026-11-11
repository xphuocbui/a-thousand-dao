import shutil
p = 'design/arts/family-blade.json'
shutil.copy(p, 'design/arts/_logs/blade-orig.json')
s = open(p, encoding='utf-8').read()


def r(a, b):
    global s
    assert a in s, a
    s = s.replace(a, b, 1)


# flurry
r('"basic_speed": 50, "basic_coef": 0.5, "gain_on_hit": 2', '"basic_speed": 25, "basic_coef": 0.2, "gain_on_hit": 1')
r('basic attack is 50 % faster, hits half again as hard and returns', 'basic attack is 25 % faster, hits a fifth harder and returns')
# coiling
r('"c_art": 2.0, "cost_share": 0.04, "cooldown": 3', '"c_art": 1.3, "cost_share": 0.04, "cooldown": 3')
r('"pay": [{"counter": {"id": "coil", "add": -4}}], "c_mult": 2.2}', '"pay": [{"counter": {"id": "coil", "add": -4}}], "c_mult": 1.6}')
r('''  {"unlock": [{"any": [{"read": "own.counter.coil", "op": ">=", "value": 5},
                       {"read": "foe.status.slowed_time", "op": ">=", "value": 5},
                       {"read": "own.since.nocked-arrow", "op": "<=", "value": 3}]}],
   "pay": [{"counter": {"id": "coil", "add": -6}}], "c_mult": 5.5,''', '''  {"unlock": [{"read": "own.counter.coil", "op": ">=", "value": 6},
              {"any": [{"read": "foe.status.slowed_time", "op": ">=", "value": 4},
                       {"read": "own.since.nocked-arrow", "op": "<=", "value": 3}]}],
   "pay": [{"counter": {"id": "coil", "add": -6}}], "c_mult": 3.5,''')
r('the thrust after that, with 5 Coils, 5 Slowed Time, or a Nocked Arrow loosed within 3 s, spends 6 Coils and becomes five thrusts of 5.5 times', 'the thrust after that needs 6 Coils and either 4 Slowed Time or a Nocked Arrow loosed within 3 s; it spends 6 Coils and becomes five thrusts of 3.5 times')
# nocked
r('"c_art": 1.8, "cost_share": 0.03, "cooldown": 3, "kind": "phys",\n "effects": [\n  {"id": "nock-bank"', '"c_art": 1.3, "cost_share": 0.03, "cooldown": 3, "kind": "phys",\n "effects": [\n  {"id": "nock-bank"')
r('"free_hit": {"c": 0.9, "dtype": "phys"}}, {"status": {"id": "slowed_time"', '"free_hit": {"c": 0.5, "dtype": "phys"}}, {"status": {"id": "slowed_time"')
r('"free_hit": {"c": 0.5, "dtype": "phys"}}]}\n ],\n "steps"', '"free_hit": {"c": 0.3, "dtype": "phys"}}]}\n ],\n "steps"')
r('   "c_mult": 2.5},', '   "c_mult": 1.8},')
r('''  {"unlock": [{"any": [{"read": "own.since.nocked-arrow", "op": ">=", "value": 7},
                       {"read": "foe.hp_share", "op": "<=", "value": 0.35},
                       {"read": "own.counter.coil", "op": ">=", "value": 6}]}],
   "c_mult": 4.5,''', '''  {"unlock": [{"read": "own.counter.coil", "op": ">=", "value": 4},
              {"any": [{"read": "own.since.nocked-arrow", "op": ">=", "value": 7},
                       {"read": "foe.hp_share", "op": "<=", "value": 0.35},
                       {"read": "foe.status.slowed_time", "op": ">=", "value": 4}]}],
   "c_mult": 3.0,''')
r('it hits 2.5 times as hard; the firing after that, after 7 s of patience, against a foe at 35 % health or less, or with 6 Coils, is a Volley of four arrows at 4.5 times', 'it hits 1.8 times as hard; the firing after that needs 4 Coils and either 7 s of patience, a foe at 35 % health or less, or 4 Slowed Time, and is a Volley of four arrows at 3 times')
# phantom
r('"c_art": 2.2, "cost_share": 0.04, "cooldown": 3', '"c_art": 1.5, "cost_share": 0.04, "cooldown": 3')
r('   "c_mult": 2.0},', '   "c_mult": 1.5},')
r('''  {"unlock": [{"any": [{"read": "own.counter.afterimage", "op": ">=", "value": 7},
                       {"read": "own.fired_within.1.group.afterimage-sword-canon", "op": ">=", "value": 3},
                       {"read": "own.hp_share", "op": "<=", "value": 0.4}]}],
   "pay": [{"counter": {"id": "afterimage", "add": -6}}], "c_mult": 4.5,''', '''  {"unlock": [{"read": "own.counter.afterimage", "op": ">=", "value": 7},
              {"any": [{"read": "own.fired_within.1.group.afterimage-sword-canon", "op": ">=", "value": 3},
                       {"read": "own.hp_share", "op": "<=", "value": 0.4},
                       {"read": "own.state.flurry", "op": ">=", "value": 1}]}],
   "pay": [{"counter": {"id": "afterimage", "add": -6}}], "c_mult": 3.2,''')
r('it hits twice as hard; the firing after that, with 7 Afterimages, three canon arts in one pulse, or you at 40 % health or less, spends 6 Afterimages and is three cuts of 4.5 times', 'it hits 1.5 times as hard; the firing after that needs 7 Afterimages and either three canon arts in one pulse, you at 40 % health or less, or Flurry on; it spends 6 Afterimages and is three cuts of 3.2 times')
# flying
r('"c_art": 2.2, "cost_share": 0.06, "cooldown": 8', '"c_art": 1.5, "cost_share": 0.06, "cooldown": 8')
r('"summon": {"c": 0.5, "dtype": "phys", "cd": 1.5, "for": 12}}]},\n  {"id": "flying-sword-trail"', '"summon": {"c": 0.3, "dtype": "phys", "cd": 1.5, "for": 12}}]},\n  {"id": "flying-sword-trail"')
r('''  {"if": [{"any": [{"read": "own.counter.afterimage", "op": ">=", "value": 5},
                   {"read": "own.fired_within.1.group.afterimage-sword-canon", "op": ">=", "value": 3},
                   {"read": "foe.status.bleed", "op": ">=", "value": 4},
                   {"read": "own.since.flying-sword", "op": ">=", "value": 10}]}],
   "pay": [{"summon": {"c": 0.5, "dtype": "phys", "cd": 1.5, "for": 12}}, {"summon": {"c": 0.5, "dtype": "phys", "cd": 1.5, "for": 12}}],
   "c_mult": 6}''', '''  {"if": [{"read": "own.counter.afterimage", "op": ">=", "value": 6},
          {"any": [{"read": "own.fired_within.1.group.afterimage-sword-canon", "op": ">=", "value": 3},
                   {"read": "foe.status.bleed", "op": ">=", "value": 4},
                   {"read": "own.since.flying-sword", "op": ">=", "value": 10}]}],
   "pay": [{"summon": {"c": 0.3, "dtype": "phys", "cd": 1.5, "for": 12}}, {"summon": {"c": 0.3, "dtype": "phys", "cd": 1.5, "for": 12}}],
   "c_mult": 3.5}''')
r('With 5 Afterimages, three canon arts in one pulse, 4 Bleed on the foe, or 10 s since the last firing, the strike hits 6 times', 'With 6 Afterimages and either three canon arts in one pulse, 4 Bleed on the foe, or 10 s since the last firing, the strike hits 3.5 times')
# triple
r('"c_art": 2.4, "cost_share": 0.03, "cooldown": 6', '"c_art": 1.6, "cost_share": 0.03, "cooldown": 6')
r('"free_hit": {"c": 0.3, "dtype": "phys"}}]}\n ],\n "empower"', '"free_hit": {"c": 0.2, "dtype": "phys"}}]}\n ],\n "empower"')
r('''  {"if": [{"any": [{"read": "own.counter.draw", "op": ">=", "value": 3},
                   {"read": "foe.status.bleed", "op": ">=", "value": 3},
                   {"read": "own.fired_within.1.group.afterimage-sword-canon", "op": ">=", "value": 3},
                   {"read": "own.hp_share", "op": "<=", "value": 0.4}]}],
   "c_mult": 4}''', '''  {"if": [{"read": "own.counter.draw", "op": ">=", "value": 2},
          {"any": [{"read": "foe.status.bleed", "op": ">=", "value": 2},
                   {"read": "own.fired_within.1.group.afterimage-sword-canon", "op": ">=", "value": 3},
                   {"read": "own.hp_share", "op": "<=", "value": 0.4}]}],
   "c_mult": 3}''')
r('a draw with 3 draws in 4 s, 3 Bleed on the foe, three canon arts in one pulse, or you at 40 % health or less hits 4 times', 'a draw with 2 draws in 4 s and either 2 Bleed on the foe, three canon arts in one pulse, or you at 40 % health or less hits 3 times')
r('adds a 0.3-coefficient', 'adds a 0.2-coefficient')
open(p, 'w', encoding='utf-8').write(s)
