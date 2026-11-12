"""Record engine fights as replays for the fight-screen viewer (design/ux/fight-screen.md).

Emits observations, not a verdict. Each replay is the engine's own fight, unchanged: the recorder only listens
(fire_event, defend, effect marks, one state snapshot per engine step). Output: a JSON list of replays.

Run: python -I tools/design/combat_sim/export_replay.py OUT.json A.fight.json B.fight.json [C.fight.json D.fight.json ...]
     (pairs of build files; each pair fights at the first file's realm, seed 1)
"""
import json
import os
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
sys.path.insert(0, os.path.join(ROOT, "tools", "design", "combat_sim"))
_argv, sys.argv = sys.argv, sys.argv[:1]
import fight  # noqa: E402
import engine  # noqa: E402
sys.argv = _argv

KEEP_EV = ("art_id", "step", "amount", "crit", "dtype", "element", "status", "stacks", "slot", "cost")


def r2(x):
    return round(float(x), 2)


class Recorder(engine.Fight):
    def __init__(self, *a, **k):
        super().__init__(*a, **k)
        self.log, self.snaps, self.ev_stack = [], [], []
        self.eff_owner = {}

    def lab(self, s):
        return "A" if s is self.A else "B"

    def fire_event(self, s, name, ev):
        if name not in ("always", "pulse", "fight_start"):
            rec = {"t": self.t, "side": self.lab(s), "ev": name}
            for k in KEEP_EV:
                if k in (ev or {}):
                    v = ev[k]
                    rec[k] = r2(v) if isinstance(v, float) else v
            self.log.append(rec)
        self.ev_stack.append((name, ev or {}))
        try:
            return super().fire_event(s, name, ev)
        finally:
            self.ev_stack.pop()

    def mark(self, s, e):
        name, ev = self.ev_stack[-1] if self.ev_stack else ("", {})
        self.log.append({"t": self.t, "side": self.lab(s), "ev": "effect", "id": e["id"], "on": name,
                         "src": ev.get("art_id") or ev.get("status") or ""})
        return super().mark(s, e)

    def defend(self, att, dfn, D, dtype, art, ctx, is_tick=False):
        wl = sum(w["left"] for w in dfn.wshields)
        hp, body, qi = dfn.hp, dfn.body_bar, dfn.qi
        out = super().defend(att, dfn, D, dtype, art, ctx, is_tick=is_tick)
        self.log.append({"t": self.t, "side": self.lab(dfn), "ev": "defend", "from": self.lab(att),
                         "art_id": art.name if art else ("tick" if is_tick else "basic"), "dtype": dtype,
                         "raw": r2(D), "ward_sh": r2(wl - sum(w["left"] for w in dfn.wshields)),
                         "body": r2(body - dfn.body_bar), "hp": r2(hp - dfn.hp), "drain": r2(max(0.0, qi - dfn.qi))})
        return out

    def snap(self, s):
        return {"hp": r2(max(0.0, s.hp)), "body": r2(s.body_bar), "qi": r2(s.qi), "qm": r2(s.qi_max()),
                "wsh": [[r2(w["left"]), r2(w["s"].size * s.qi_base)] for w in s.wshields],
                "buffs": [[b[0], b[1]] for b in s.buffs], "debuffs": [[d[0], d[1]] for d in s.debuffs],
                "st": {k: v["stacks"] for k, v in s.statuses.items() if v.get("stacks", 0) > 0},
                "ct": {k: r2(v) for k, v in s.counters.items() if v},
                "ready": list(s.ready), "step": list(s.step), "ch": list(s.charges), "state": s.state,
                "down": bool(s.down)}

    def defeat_check(self):
        out = super().defeat_check()
        self.snaps.append({"t": self.t, "A": self.snap(self.A), "B": self.snap(self.B)})
        return out


def side_info(d, b, path):
    arts_lib, techs = fight._library()
    arts = []
    for a, ea in zip(d["arts"], b.arts):
        lib = arts_lib.get(a.get("id")) or {}
        arts.append({"id": ea.name, "name": lib.get("name", ea.name), "rule": lib.get("rule", a.get("_comment", "")),
                     "element": ea.element, "cost": r2(a.get("cost_share", 0.05)), "cd": r2(a.get("cooldown", 3.0)),
                     "steps": len(ea.steps), "empower": len(ea.empower), "group": ea.group,
                     "tags": list(ea.tags), "power": lib.get("power", "")})
    art_ids = {a["id"] for a in arts}
    owner = {}
    for a in d["arts"]:
        for e in (arts_lib.get(a.get("id")) or {}).get("effects", []):
            owner[e["id"]] = a.get("id")
    effects = []
    for e in d.get("effects", []):
        eid = e.get("id", "")
        if eid in owner or eid.startswith("tech:"):
            continue
        effects.append({"id": eid, "on": e.get("on", ""), "rule": e.get("_comment", "")})
    tech = []
    for tid in d.get("_techniques", []):
        t = techs.get(tid, {})
        tech.append({"id": tid, "name": t.get("name", tid),
                     "passives": ["%s %+g%s" % (p["key"], p["value"], (" [" + ",".join(p.get("scope", [])) + "]")
                                                if p.get("scope") else "") for p in t.get("passives", [])]})
    return {"name": os.path.basename(path).replace(".fight.json", ""), "realm": fight.REALMS[b.realm],
            "purity": d.get("purity", {}), "hpMax": None, "arts": arts, "effects": effects, "techniques": tech,
            "owner": owner, "resist": r2(b.ward_pts), "block": r2(b.block), "M": r2(b.M), "art_ids": sorted(art_ids),
            "counters": [c.get("id") for c in d.get("counters", [])]}


def load(path):
    raw = json.load(open(path, encoding="utf-8"))
    techs = list(raw.get("techniques", []) or [])
    d = fight.expand_library(raw)
    d["_techniques"] = techs
    r = fight.realm_index(d.get("realm", "luyen_khi"))
    dd = {k: v for k, v in d.items() if k != "_techniques"}
    return d, fight.to_build(dd, r, [], os.path.basename(path)), r


def main():
    args = sys.argv[1:]
    if len(args) < 3 or len(args) % 2 == 0:
        print(__doc__)
        return 2
    out, files = args[0], args[1:]
    replays = []
    for i in range(0, len(files), 2):
        da, A, r = load(files[i])
        db, B, _ = load(files[i + 1])
        f = Recorder(A, B, seed=1)
        res = f.run()
        ia, ib = side_info(da, A, files[i]), side_info(db, B, files[i + 1])
        ia["hpMax"], ib["hpMax"] = r2(f.A.hp_max), r2(f.B.hp_max)
        replays.append({"title": "%s vs %s" % (ia["name"], ib["name"]), "realm": fight.REALMS[r],
                        "end": res["t"], "win": res["win"], "A": ia, "B": ib, "log": f.log, "snaps": f.snaps})
        print("%s: %.1f s, win %s, %d events, %d snapshots" % (replays[-1]["title"], res["t"], res["win"],
                                                                len(f.log), len(f.snaps)))
    with open(out, "w", encoding="utf-8") as fh:
        json.dump(replays, fh, ensure_ascii=False, separators=(",", ":"))
    print("wrote %s (%d KB)" % (out, os.path.getsize(out) // 1024))
    return 0


if __name__ == "__main__":
    sys.exit(main())
