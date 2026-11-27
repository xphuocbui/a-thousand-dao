"""World-depth Stage 6 holder check: an owner's records on their real holders (production/plans/stage6/bang_tam.md,
step 6c; the method in production/plans/world-depth-implementation.md, Stage 6).

    python -I tools/design/combat_sim/sect_fight.py <owner> [--people a,b] [--gap 1] [--seeds 20] [--out DIR]

For each living person of the owner (or the named ones) whose build names a catalogue technique or a named item, it
builds a fight.py file from the cast build (the techniques' arts up to the learnt layer, at most 6; the named gear; the
root's purity; the realm's typical layers), loads the owner's sets (design/items/sets-<owner>.json) and Effects
(design/world/depth/effects/<owner>.effects.json) in memory even before they are exported or merged, and runs it
against the typical foe of its realm plus --gap. It prints one table:

    holder  realm  arts  mean_s  wins  hp_left
    holder  effect <name>  without: mean_s hp_left  runs <n>   (each Effect the holder's items, sets or techniques name)
    holder  art <id>  fires <n per fight>

`runs` counts each record of the Effect executed over all seeds (an engine probe); 0 means it never fired, and a
record that never fires needs a written reason in the owner's review file. Emits observations, not a verdict.
"""
import argparse
import collections
import contextlib
import glob
import io
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import fight as F    # noqa: E402
import engine as E   # noqa: E402

ROOT = os.path.normpath(os.path.join(HERE, "..", "..", ".."))
D = os.path.join(ROOT, "design", "world", "depth")
EL = {"thuy": "water", "bang": "ice", "tho": "earth", "hoa": "fire", "kim": "metal", "moc": "wood", "loi": "thunder",
      "phong": "wind", "quang": "light"}
MAX_ARTS = 6


def load(p):
    with open(p, encoding="utf-8") as fh:
        return json.load(fh)


def owner_people(owner):
    out = []
    for folder in ("sects", "people"):
        for f in sorted(set(glob.glob(os.path.join(D, folder, "%s.cast.json" % owner)) +
                            glob.glob(os.path.join(D, folder, "%s.*.cast.json" % owner)))):
            out += load(f)["people"]
    return out


def install_owner(owner):
    """The owner's sets and Effects, in memory, over the exported ones (a rerun after an edit needs no export)."""
    F._library()
    sets = []
    for p in [os.path.join(ROOT, "design", "items", "sets-%s.json" % owner)] + F.stage_files("items", "sets-%s.json" % owner):
        if os.path.exists(p):
            sets = load(p)   # the staged file (last) wins
    base = F.item_sets()
    keep = [s for s in base.get("sets", []) if s["id"] not in {x["id"] for x in sets}]
    F.SETS = {"constants": base.get("constants", {"set_bonus_min_pieces": 2}), "sets": keep + sets}
    lib = F.effects_library()
    names = []
    for p in [os.path.join(D, "effects", "%s.effects.json" % owner)] + F.stage_files("effects", "%s.effects.json" % owner):
        if os.path.exists(p):
            for name, e in load(p)["effects"].items():
                lib[name] = e
                if name not in names:
                    names.append(name)
    return names


def techs():
    out = {}
    for f in sorted(glob.glob(os.path.join(ROOT, "design", "techniques", "catalogue-*.json"))) +             F.stage_files("techniques", "catalogue-sect-*.json"):
        for t in load(f):
            out[t["id"]] = t
    return out


def fight_file(p, catalogue):
    b = p["build"]
    r = F.REALMS.index(p["realm"])
    arts, tl, tlayers, meters = [], [], {}, {}
    for s in [b["main"]] + list(b.get("aux", [])):
        t = catalogue.get(s.get("tech"))
        if not t:
            continue
        tid = s["tech"]
        layer = int(s.get("layer", 1))
        tl.append(tid)
        tlayers[tid] = layer
        for ab in t["abilities"]:
            if ab["unlock_layer"] <= layer and ab["ability_id"] not in [a["lib"] for a in arts]:
                arts.append({"lib": ab["ability_id"]})
        for ef in t.get("effects", []):
            if isinstance(ef, dict) and layer < int(ef.get("unlock_layer", 1)):
                continue
            ename = (ef if isinstance(ef, str) else ef.get("name", "")).split(" (")[0]
            if ename == "Playing Past the Break" and "playing_past_the_break" not in meters:
                tp = p.get("thien_phu") or {}
                th = float(tp.get("than_hon", 50))
                kv = float(tp.get("khi_van", 50))
                meters["playing_past_the_break"] = {"start": 0.0, "p": max(0.0, min(1.0, (th + kv) / 400.0))}
    pur = {}
    for k, v in list(p["root"].get("elements", {}).items()) + list(p["root"].get("variants", {}).items()):
        if k in EL:
            pur[EL[k]] = v
    named = set(F._LIB.get("items", {}))
    items = [g["named"] for g in b.get("gear", []) if g.get("named") in named]
    doc = {"name": p["key"], "realm": p["realm"], "layers": F.enemy_file("typical", r)["layers"], "purity": pur,
           "techniques": tl, "items": items, "arts": arts[:MAX_ARTS]}
    if tlayers:
        doc["tech_layers"] = tlayers
    if meters:
        doc["meters"] = meters
    return doc, items, tl


def run(d, args, without=None):
    """mean time, wins, hp share left, record runs by id, art fires (silences fight.py's own printing)."""
    cnt = collections.Counter()
    orig = E.Fight.do

    def do(self, s, e, acts, n, ev):
        if s is self.A:
            cnt[e.get("id")] += 1
        return orig(self, s, e, acts, n, ev)
    E.Fight.do = do
    try:
        dd = F.expand_library(json.loads(json.dumps(d)))
        if without:
            dd["effects"] = [e for e in dd.get("effects", []) if not str(e.get("id", "")).startswith(without)]
        r = F.REALMS.index(dd["realm"])
        with contextlib.redirect_stdout(io.StringIO()):
            build = F.to_build(dd, r, [], "build")
            enemy = F.to_build(F.enemy_file("typical", min(4, r + args.gap)), min(4, r + args.gap), [], "enemy")
            out = F.run(build, enemy, args.seeds)
        return out, cnt, [a.name for a in build.arts]
    finally:
        E.Fight.do = orig


def effect_names(d, items, tl, owner_effects):
    """The Effects a holder's items, sets and techniques name (library names)."""
    names = []
    t_layers = d.get("tech_layers") or {}
    for tid in tl:
        t = F._LIB.get("techs", {}).get(tid, {})
        cur = int(t_layers[tid]) if tid in t_layers else int(t.get("layers", 15))
        for ef in t.get("effects", []):
            if isinstance(ef, dict) and cur < int(ef.get("unlock_layer", 1)):
                continue
            n = (ef if isinstance(ef, str) else ef.get("name", "")).split(" (")[0]
            names.append(n)
    for iid in items:
        for ef in F._LIB["items"].get(iid, {}).get("effects", []):
            n = (ef if isinstance(ef, str) else ef.get("name", "")).split(" (")[0]
            names.append(n)
    worn = set(items)
    for s in F.item_sets().get("sets", []):
        n_pc = len(set(s["pieces"]) & worn)
        for b in s.get("bonuses", []):
            if b.get("effect") and n_pc >= int(b.get("pieces", len(set(s["pieces"])))):
                names.append(str(b["effect"]).split(" (")[0])
    return [n for n in dict.fromkeys(names) if n]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("owner")
    ap.add_argument("--people", default="")
    ap.add_argument("--gap", type=int, default=0)
    ap.add_argument("--seeds", type=int, default=20)
    ap.add_argument("--out", default="")
    args = ap.parse_args()
    owner_effects = install_owner(args.owner)
    catalogue = techs()
    want = set(x for x in args.people.split(",") if x)
    lib_items = set(F._LIB.get("items", {}))
    print("holder\trealm\tarts\tmean_s\twins\thp_left")
    for p in owner_people(args.owner):
        if not p.get("alive") or not p.get("build") or (want and p["key"] not in want):
            continue
        b = p["build"]
        authored = any(catalogue.get(s.get("tech"), {}).get("owner") for s in [b["main"]] + list(b.get("aux", []))) \
            or any(g.get("named") in lib_items for g in b.get("gear", []))
        if not authored and not want:
            continue
        d, items, tl = fight_file(p, catalogue)
        if args.out:
            with open(os.path.join(args.out, p["key"] + ".fight.json"), "w", encoding="utf-8") as fh:
                json.dump(d, fh, ensure_ascii=False)
        try:
            out, cnt, arts = run(d, args)
        except Exception as e:   # a record the engine refuses: report it, go on
            print("%s\t%s\tREFUSED\t%s" % (p["key"], p["realm"], str(e)[:200]))
            continue
        print("%s\t%s\t%s\t%.1f\t%d\t%.0f%%" % (p["key"], p["realm"], ",".join(arts), out["t"], out["win"], 100 * out["hp_left"]))
        for a, n in zip(arts, out["fires"]):
            print("%s\tart %s\tfires %.1f%s" % (p["key"], a, n, "\tNEVER_FIRED" if n == 0 else ""))
        for name in effect_names(d, items, tl, owner_effects):
            recs = [k for k in cnt if str(k).startswith("eff:%s" % name)]
            runs = sum(cnt[k] for k in recs)
            wo, _, _ = run(d, args, without="eff:%s" % name)
            print("%s\teffect %s\twith %.1f s %.0f%%\twithout %.1f s %.0f%%\truns %d%s" % (
                p["key"], name, out["t"], 100 * out["hp_left"], wo["t"], 100 * wo["hp_left"], runs,
                "\tNEVER_RAN" if runs == 0 else ""))
    return 0


if __name__ == "__main__":
    sys.exit(main())
