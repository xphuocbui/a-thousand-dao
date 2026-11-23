"""Export the place catalogue (design/world/place_catalogue.json) to game data: assets/data/world_place_lore.json,
keyed by continent place id, with the look, lore, history, special flag, levels and great-project kinds. The art
briefs stay in design/ (they feed the art pipeline, not the game).

usage: python -I tools/design/world/export_place_lore.py
"""
import json
import os

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
cat = json.load(open(os.path.join(ROOT, "design/world/place_catalogue.json"), encoding="utf-8"))
out = {"schema_version": 1,
       "_doc": "Each named place's look, lore and history (design/world/place_catalogue.json; proposal of 2026-11-22, "
               "pending the user's review), keyed by continent place id; exported by tools/design/world/export_place_lore.py.",
       "status": cat.get("status", ""),
       "places": {str(e["id"]): {k: e.get(k) for k in ("name", "look", "lore", "history", "special", "levels", "projects")
                                 if e.get(k) not in (None, "", [])} for e in cat["places"]}}
with open(os.path.join(ROOT, "assets/data/world_place_lore.json"), "w", encoding="utf-8") as f:
    json.dump(out, f, ensure_ascii=False, indent=1)
print("exported", len(out["places"]), "places")
