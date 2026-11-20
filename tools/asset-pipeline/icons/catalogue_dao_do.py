"""Check the Đạo Đồ icon subjects against the tree, and write the icon catalogue (art bible §7.9).

Checks (observations; exit 1 if any icon a node needs has no subject): every small-node and plain-notable main stat
has a stat icon (after STAT_ALIAS), every content idea, capability, Effect notable, keystone and start has its subject.

Writes assets/icons/dao_do/CATALOGUE.json (tracked, so the descriptions survive): one entry per icon with its kind,
id, hue, hand-written subject, the exact prompt sent, the candidate files, and what it serves (stat key, idea string,
capability id, node ids). Reuse: regenerate any icon from its prompt, or point a new node at an existing id.

Run (from the repo root): python -I tools/asset-pipeline/icons/catalogue_dao_do.py
"""
import glob
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
sys.path.insert(0, HERE)
import gen_ai as G  # noqa: E402
import picks_dao_do as PK  # noqa: E402
import subjects_dao_do as D  # noqa: E402

OUT = os.path.join(ROOT, "assets", "icons", "dao_do", "CATALOGUE.json")
STYLE = {"dd_roadmotif": G.ROAD_STYLE, "dd_frame": G.FRAME_STYLE}


def main():
    m = json.load(open(os.path.join(ROOT, "assets", "data", "dao_do_map.json"), encoding="utf-8"))
    nodes = m["nodes"]
    idea_of = {}
    for f in glob.glob(os.path.join(ROOT, "design", "dao-do", "content", "*.json")):
        for k, v in json.load(open(f, encoding="utf-8"))["nodes"].items():
            if v.get("idea"):
                idea_of[int(k)] = v["idea"]
    uses = {}                                         # (kind, id) -> {"serves": ..., "nodes": [...]}

    def use(kind, iid, serves, nid):
        u = uses.setdefault((kind, iid), {"serves": serves, "nodes": []})
        u["nodes"].append(nid)

    missing = []
    for n in nodes:
        k = n["kind"]
        if k == "small" or (k == "notable" and not idea_of.get(n["id"]) and not n.get("cap") and not n.get("effect")
                            and not (D.name_slug(n["name"]) in D.NOTE and PK.pick("dd_note", D.name_slug(n["name"]))[0])):
            if not n.get("mods"):
                continue
            st = max(n["mods"], key=lambda x: x["w"])["stat"] if k == "notable" else n["mods"][0]["stat"]
            sc = tuple(max(n["mods"], key=lambda x: x["w"]).get("scope") or []) if k == "notable" else tuple(n["mods"][0].get("scope") or [])
            key = D.statc_key(st, sc)
            use("dd_statc", key, {"stat": D.STAT_ALIAS.get(st, st), "scope": list(sc)}, n["id"])
        elif k == "notable" and n.get("cap"):
            use("dd_cap", "cap_%s" % n["cap"], {"capability": n["cap"], "name": n["name"]}, n["id"])
        elif k == "notable" and n.get("effect"):
            use("dd_effect", D.name_slug(n["effect"]), {"effect": n["effect"], "notable": n["name"]}, n["id"])
        elif k == "notable" and D.name_slug(n["name"]) in D.NOTE and PK.pick("dd_note", D.name_slug(n["name"]))[0]:
            use("dd_note", D.name_slug(n["name"]), {"notable": n["name"], "idea": idea_of.get(n["id"])}, n["id"])
        elif k == "notable":
            idea = idea_of[n["id"]]
            use("dd_idea", D.idea_slug(idea), {"idea": idea}, n["id"])
        elif k == "keystone":
            use("dd_keystone", D.name_slug(n["name"]), {"keystone": n["name"], "closes": n.get("closes")}, n["id"])
    for root, nid in m["starts"].items():
        use("dd_start", root, {"root": root}, nid if isinstance(nid, int) else nid.get("node", nid))
    for (kind, iid) in sorted(uses):
        if iid not in D.TABLE[kind]:
            missing.append("%s/%s" % (kind, iid))
    unused = ["%s/%s" % (k, i) for k in D.FULL for i in D.TABLE[k] if (k, i) not in uses]
    counts = {k: len(D.TABLE[k]) for k in D.FULL}
    print("subjects\t%s = %d" % (counts, sum(counts.values())))
    print("missing\t%d %s" % (len(missing), " ".join(missing)))
    print("unused\t%d %s" % (len(unused), " ".join(unused)))
    cat = []
    for kind, table in D.TABLE.items():
        for iid, (hue, subj) in table.items():
            f, tag = PK.pick(kind, iid)
            rec = PK.record(kind, iid, tag) if tag else {}
            u = uses.get((kind, iid), {})
            cat.append({"kind": kind, "id": iid, "hue": hue, "subject": subj,
                        "pick": os.path.relpath(f, ROOT).replace("\\", "/") if f else None,
                        "quality": rec.get("quality"), "low": rec.get("quality") == "low",
                        "prompt": rec.get("prompt"), "model": rec.get("model"),
                        "candidates": [{"file": c[0], "tag": c[1], "quality": c[2], "prompt": c[3]} for c in PK.candidates(kind, iid)],
                        "serves": u.get("serves"), "node_count": len(u.get("nodes", [])), "nodes": u.get("nodes", [])})
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    json.dump({"_doc": "Đạo Đồ node icons (art bible 7.9): per icon its subject, the file in use (pick), that file's real "
                       "prompt, model and quality from the generator log (\"low\": true marks a low-quality painting to redo "
                       "at medium later), every candidate on disk, and the nodes it serves. Written by "
                       "tools/asset-pipeline/icons/catalogue_dao_do.py; do not edit by hand.",
               "icons": cat}, open(OUT, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    print("catalogue\t%s (%d icons)" % (os.path.relpath(OUT, ROOT), len(cat)))
    return 1 if missing else 0


if __name__ == "__main__":
    sys.exit(main())
