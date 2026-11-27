"""Export the authored technique catalogue (design/techniques/catalogue-*.json) into game data.

Adds every design technique to assets/data/items_cong_phap.json "templates" (Cultivation Techniques rule 17: authored
templates carry their signature abilities), next to the hand-written templates already there, which stay as they are
(the MVP stand-ins that cover every element at the Earth and Heaven tiers). User decision 2026-11-14.

Per technique: id, name, tier, tech_kind, names, layers, bonuses (the game's scaled bonuses, read by the stat sheet),
passives (fight.py's flat combat lines with their scopes, read only by the fight compiler, so nothing counts twice),
abilities ({ability_id, unlock_layer}), seal_clusters [], origin "authored". Lore, family and suite stay in design.

    python -I tools/design/items/export_techniques.py            # write
    python -I tools/design/items/export_techniques.py --check    # exit 1 if the game data is stale
"""
import glob
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
OUT = os.path.join(ROOT, "assets", "data", "items_cong_phap.json")
DOC = ("design/gdd/cong-phap.md Parameter keys. templates are the authored catalogue: the hand-written MVP templates "
       "and every design technique, which tools/design/items/export_techniques.py adds from "
       "design/techniques/catalogue-*.json (abilities with unlock layers; passives are fight-only combat lines with "
       "scopes, read by the fight compiler; bonuses go through the stat sheet).")


def design_techniques():
    out = []
    for path in sorted(glob.glob(os.path.join(ROOT, "design", "techniques", "catalogue-*.json"))):
        with open(path, encoding="utf-8") as f:
            for t in json.load(f):
                rec = {
                    "id": t["id"], "name": t["name"], "tier": int(t["tier"]), "tech_kind": t["tech_kind"],
                    "names": list(t.get("names", [])), "layers": int(t["layers"]),
                    "bonuses": [{"stat": b["stat"], "value": b["value"]} for b in t.get("bonuses", [])],
                    "passives": [{k: p[k] for k in ("key", "value", "scope") if k in p} for p in t.get("passives", [])],
                    "abilities": [{"ability_id": a["ability_id"], "unlock_layer": int(a["unlock_layer"])}
                                  for a in t.get("abilities", [])],
                    "seal_clusters": [], "origin": "authored",
                }
                if t.get("effects"):
                    rec["effects"] = [
                        {k: (int(e[k]) if k == "unlock_layer" else e[k])
                         for k in ("name", "unlock_layer", "passive_art") if k in e}
                        for e in t["effects"] if isinstance(e, dict) and e.get("name")
                    ]
                out.append(rec)
    return out


def build():
    with open(OUT, encoding="utf-8") as f:
        data = json.load(f)
    design = design_techniques()
    ids = {t["id"] for t in design}
    kept = [t for t in data.get("templates", []) if t["id"] not in ids and t.get("source") != "design"]
    data["templates"] = kept + [dict(t, source="design") for t in design]
    data["_doc"] = DOC
    return data


def main():
    text = json.dumps(build(), indent=2, ensure_ascii=False) + "\n"
    if "--check" in sys.argv:
        old = open(OUT, encoding="utf-8").read()
        same = old == text
        print("items_cong_phap.json is current" if same else "items_cong_phap.json is STALE: run export_techniques.py")
        return 0 if same else 1
    with open(OUT, "w", encoding="utf-8", newline="\n") as f:
        f.write(text)
    d = json.loads(text)
    print("wrote %s: %d templates (%d from the design catalogue)" % (
        OUT, len(d["templates"]), sum(1 for t in d["templates"] if t.get("source") == "design")))
    return 0


if __name__ == "__main__":
    sys.exit(main())
