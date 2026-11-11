import json
def P(k,v,s=()): return {"key":k,"value":v,"scope":list(s)}
T=[
{"id":"afterimage-sword-canon","name":"Afterimage Sword Canon (Tàn Ảnh Kiếm Kinh)","tier":2,"tech_kind":"secret","names":["kim"],"layers":12,
 "bonuses":[{"stat":"attack_pct","value":10},{"stat":"khi_huyet_pct","value":10}],
 "passives":[P("crit_chance_pct",9,["sword"]),P("crit_damage_pct",30,["sword"]),P("art_speed_pct",10),P("status_duration_pct",15)],
 "abilities":[{"ability_id":"flurry-stance","unlock_layer":1},{"ability_id":"phantom-sword","unlock_layer":2},{"ability_id":"triple-draw","unlock_layer":4},{"ability_id":"flying-sword","unlock_layer":6}],
 "effects":[],"origin":"authored","suite":"afterimage-sword-canon","family":"blade",
 "lore":"A fast-handed scripture whose swordsman leaves a trail of cuts that keep striking after the blade has moved on."},
{"id":"hunters-reach-canon","name":"Hunter's Reach Canon (Liệp Trình Kinh)","tier":0,"tech_kind":"main","names":["kim"],"layers":6,
 "bonuses":[],
 "passives":[P("crit_chance_pct",3),P("art_speed_pct",5),P("status_duration_pct",5,["curse"])],
 "abilities":[{"ability_id":"pinning-arrow","unlock_layer":1},{"ability_id":"nocked-arrow","unlock_layer":3},{"ability_id":"coiling-thrust","unlock_layer":5}],
 "effects":[],"origin":"authored","suite":"hunters-reach-canon","family":"blade",
 "lore":"A patient hunter's method of bow and spear that slows the quarry before the final thrust."},
{"id":"debt-ledger-blade","name":"Debt Ledger Blade (Huyết Trái Đao Lục)","tier":0,"tech_kind":"secret","names":["kim"],"layers":6,
 "bonuses":[],
 "passives":[P("leech_health_pct",15),P("art_cost_health_pct",-10),P("health_regen_inc_pct",5)],
 "abilities":[{"ability_id":"debt-blade","unlock_layer":1}],
 "effects":[],"origin":"authored","suite":"","family":"blade",
 "lore":"A mercenary's blade manual that lends strength against the health owed to the next breath."},
]
json.dump(T,open("design/techniques/catalogue-blade.json","w",encoding="utf-8"),ensure_ascii=False,indent=1)
