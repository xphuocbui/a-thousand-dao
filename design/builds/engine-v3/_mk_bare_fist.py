import json
d = json.load(open('design/builds/engine-v2/builds/bare-fist.fight.json', encoding='utf-8'))
d['items'] = ["earth-mountain-mooring-anchor", "earth-boulder-ring-mail", "body-iron-skin-ring", "earth-clay-seal-ring",
              "earth-remembering-stone-pendant", "earth-unmoving-gate-shield", "body-flesh-seal"]
d['arts'][0] = {"lib": "earth-mooring-drop"}
d['effects'] = [
    {"id": "eff:Iron Skin Renewed", "on": "art_fired", "filter": {"dtype": "physical"}, "limit": {"per_pulse": 1},
     "do": [{"shield": {"body": 0.02}}]},
    {"id": "eff:Shattering Ward", "on": "shield_broken", "limit": {"per_pulse": 1, "per_fight": 3},
     "do": [{"free_hit": {"c": 0.6, "dtype": "force"}}]}]
d['unmodelled'].append("Unmoved Stance (earth-unmoving-gate-shield): the build slots no stance (mountain-stance left out), so it would fire nothing")
d['unmodelled'].append("Item wards (Boulder Shell, Gate Screen): the old drain ward is kept; reserve share of the remembering-stone pendant not run")
json.dump(d, open('design/builds/engine-v3/builds/bare-fist.fight.json', 'w', encoding='utf-8'), indent=2, ensure_ascii=False)
