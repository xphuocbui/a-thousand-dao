"""Lint the art library (design/arts/*.json) against the Combat and Effects GDD rules.

Emits observations, not a verdict (CLAUDE.md: helpers in scripts emit observations). One line per finding:
  LINT_OVER   c_art above the art lint after its stack and curse charge
  HEAL_OVER   c_heal above heal_lint_ratio x the art lint
  CHARGE_FAIL stack + curse charge above 0.6 (Effects Formulas D; Combat Formulas C)
  SOUL_OVER   soul_pct above 0.0125 x lint or outside 0.03-0.08 (Combat E2)
  RANGE       cost_share or cooldown outside the GDD range
  SCHEMA      a field or Effect the combat engine would refuse (engine.validate)
  DUPLICATE   two arts with the same id
It also prints coverage counts by element, role and tier, and `checked N arts` so a run that read nothing
cannot look clean.

Run: python -I tools/design/arts/lint_arts.py [files...]     (default: design/arts/part-*.json)
"""
import glob
import json
import os
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
sys.path.insert(0, os.path.join(ROOT, "tools", "design", "combat_sim"))
import engine  # noqa: E402

PER_COST, PER_CD = 24, 0.25          # combat.md Formulas C (art_coef_per_cost, art_coef_per_cooldown)
COST = (0.02, 0.125)                  # combat.md cost_share range
CD = (0.5, 12.0)                      # combat.md cooldown range
HEAL_RATIO = 1.4                      # combat-defence.md heal_lint_ratio
W_BUFF, W_DEBUFF = 0.010, 0.015       # effects.md Formulas D, per stack-second
FIGHT_S = 60.0                        # a "for the fight" batch is charged as 60 s
CURSE_RULE, CURSE_HEAVY = 0.10, 0.15  # per pulse of duration (build-run suggestion 4a)
HEAVY = {"leaking_ward", "heavy_breath"}
SOUL_K, SOUL_LO, SOUL_HI = 0.0125, 0.03, 0.08
ROLES = {"damage", "stacks", "curse", "heal", "ward", "soul", "utility", "control", "summon"}
TIERS = {"common", "authored"}
FIELDS = {"id", "name", "element", "role", "tier", "tags", "c_art", "cost_share", "cooldown", "kind", "buff",
          "debuff", "c_heal", "qi_restore", "cleanse", "statuses", "split", "soul_pct", "soul_part", "bypass", "pool",
          "guards", "effects", "counters", "rule", "sources", "notes", "convert", "hp_cost", "charges", "states",
          "x", "hooks", "group", "steps", "empower", "power"}


def charge(a):
    c = 0.0
    for key, w in (("buff", W_BUFF), ("debuff", W_DEBUFF)):
        v = a.get(key)
        if v:
            n, sec = v[0], (v[1] if v[1] is not None else FIGHT_S)
            c += w * n * max(2.0, sec)
    for st in a.get("statuses", []):
        d = engine.STATUS.get(st.get("id"), {})
        if d.get("kind") == "curse":
            dur = max(1, min(5, st.get("dur", d.get("dur") or 1)))
            c += (CURSE_HEAVY if st["id"] in HEAVY else CURSE_RULE) * dur
    return c


notes_out = []


def lint(arts, src):
    out = []
    seen = set()
    for a in arts:
        aid = a.get("id", "?")
        if aid in seen:
            out.append("DUPLICATE\t%s\t%s" % (src, aid))
        seen.add(aid)
        bad = set(a) - FIELDS
        if bad:
            out.append("SCHEMA\t%s\t%s: unknown fields %s" % (src, aid, sorted(bad)))
        if a.get("role") not in ROLES:
            out.append("SCHEMA\t%s\t%s: role %r not in %s" % (src, aid, a.get("role"), sorted(ROLES)))
        if a.get("tier") not in TIERS:
            out.append("SCHEMA\t%s\t%s: tier %r not in %s" % (src, aid, a.get("tier"), sorted(TIERS)))
        cost, cd = a.get("cost_share", 0.05), a.get("cooldown", 3.0)
        if not COST[0] <= cost <= COST[1]:
            out.append("RANGE\t%s\t%s: cost_share %.3f outside %.3f-%.3f" % (src, aid, cost, *COST))
        if not CD[0] <= cd <= CD[1]:
            out.append("RANGE\t%s\t%s: cooldown %.2f outside %.1f-%.0f s" % (src, aid, cd, *CD))
        lint_c = 1.0 * (1 + PER_COST * cost) + PER_CD * (cd - 1)
        ch = charge(a)
        if ch > 0.6 + 1e-9:
            out.append("CHARGE_FAIL\t%s\t%s: charge %.2f above 0.6" % (src, aid, ch))
        limit = lint_c * (1 - min(ch, 0.6))
        c = a.get("c_art", 0.0) * sum(a.get("split") or [1.0])
        if c > limit + 1e-6:
            out.append("LINT_OVER\t%s\t%s: c_art %.2f (x split) over %.2f (lint %.2f, charge %.2f)" % (src, aid, c, limit, lint_c, ch))
        # steps and empowers: a payoff above the lint must be gated (unlock / if); it is reported, never capped
        for kind, lst, gate in (("step", a.get("steps", []), "unlock"), ("empower", a.get("empower", []), "if")):
            for j, st in enumerate(lst):
                sc = st.get("c_art", a.get("c_art", 0.0)) * st.get("c_mult", 1.0) * sum(st.get("split") or a.get("split") or [1.0])
                if sc > limit + 1e-6:
                    if st.get(gate):
                        notes_out.append("engine_payoff\t%s\t%s %s %d: x%.2f of the lint, gated" % (src, aid, kind, j + 1, sc / max(1e-9, limit)))
                    else:
                        out.append("UNGATED\t%s\t%s %s %d: above the lint with no %s condition" % (src, aid, kind, j + 1, gate))
        if a.get("power") == "engine" and not (a.get("steps") or a.get("empower") or a.get("effects")):
            out.append("SCHEMA\t%s\t%s: power 'engine' but no steps, empower or effects" % (src, aid))
        if a.get("c_heal", 0) > HEAL_RATIO * lint_c + 1e-6:
            out.append("HEAL_OVER\t%s\t%s: c_heal %.2f over %.2f" % (src, aid, a["c_heal"], HEAL_RATIO * lint_c))
        sp = a.get("soul_pct", 0)
        if sp and (sp > SOUL_K * lint_c + 1e-9 or not SOUL_LO <= sp <= SOUL_HI):
            out.append("SOUL_OVER\t%s\t%s: soul_pct %.3f (limit %.3f, range %.2f-%.2f)" % (src, aid, sp, min(SOUL_HI, SOUL_K * lint_c), SOUL_LO, SOUL_HI))
        # schema check through the engine: one dummy build holding this art and its Effects
        try:
            art = engine.Art(aid, a.get("c_art", 0.0), cost, cd, a.get("element", ""), a.get("kind", "phys"),
                             tuple(a.get("buff", ())), tuple(a.get("debuff", ())), a.get("c_heal", 0.0),
                             a.get("qi_restore", 0.0), int(a.get("cleanse", 0)), 1.0, tuple(a.get("tags", ())),
                             list(a.get("guards", [])), list(a.get("statuses", [])), list(a.get("split", [])),
                             a.get("soul_pct", 0.0), a.get("soul_part", 0.0), a.get("bypass", 0.0), a.get("pool", "qi"),
                             dict(a.get("convert", {})), a.get("hp_cost", 0.0), int(a.get("charges", 1)),
                             a.get("group", ""), list(a.get("steps", [])), list(a.get("empower", [])))
            if art.element not in engine.ELEMENTS:
                raise engine.EngineError("element %r" % art.element)
            b = engine.Build("lint", arts=[art], effects=list(a.get("effects", [])), counters=list(a.get("counters", [])),
                             states=list(a.get("states", [])))
            engine.validate(b)
            for st in a.get("statuses", []):
                if st.get("id") not in engine.STATUS:
                    raise engine.EngineError("status %r" % st.get("id"))
        except (engine.EngineError, TypeError) as e:
            out.append("SCHEMA\t%s\t%s: %s" % (src, aid, e))
    return out


def main():
    files = sys.argv[1:] or sorted(glob.glob(os.path.join(ROOT, "design", "arts", "part-*.json")))
    if not files:
        print("NO_INPUT\tno art files found (design/arts/part-*.json)")
        return 2
    allarts, findings = [], []
    for f in files:
        try:
            arts = json.load(open(f, encoding="utf-8"))
        except (OSError, ValueError) as e:
            print("UNREADABLE\t%s\t%s" % (f, e))
            return 2
        findings += lint(arts, os.path.basename(f))
        allarts += arts
    ids = {}
    for a in allarts:
        ids.setdefault(a.get("id"), 0)
        ids[a.get("id")] += 1
    findings += ["DUPLICATE\t(all)\t%s in %d files" % (k, v) for k, v in ids.items() if v > 1]
    for line in findings:
        print(line)
    for line in notes_out:
        print(line)
    eng = sum(1 for a in allarts if a.get("power") == "engine")
    print("coverage\tpower\tengine %d, standalone %d" % (eng, len(allarts) - eng))
    def counts(key):
        c = {}
        for a in allarts:
            c[a.get(key, "?")] = c.get(a.get(key, "?"), 0) + 1
        return ", ".join("%s %d" % (k or "none", v) for k, v in sorted(c.items(), key=lambda x: str(x[0])))
    print("coverage\telement\t" + counts("element"))
    print("coverage\trole\t" + counts("role"))
    print("coverage\ttier\t" + counts("tier"))
    print("checked %d arts in %d files, %d findings" % (len(allarts), len(files), len(findings)))
    return 1 if findings else 0


if __name__ == "__main__":
    sys.exit(main())
