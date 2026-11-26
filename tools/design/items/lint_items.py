"""Lint the named-item catalogue (design/items/catalogue-*.json) and the bases (design/items/bases.json).

Rules: design/gdd/item-database.md rules 6, 11, 20, 21 and Formulas D, I (user decisions 2026-11-12).
Emits observations, not a verdict (CLAUDE.md: helpers in scripts emit observations). One line per finding:
  SCHEMA        a missing or unknown field, a bad kind, grade, rarity, source or role
  BASE          a base id that is not in bases.json, or a bases.json record that is malformed
  NOT_PRICED    a modifier key with no W price (modifiers.md Formulas A): the budget cannot be assessed
  SCOPE         a modifier scope tag outside the Modifier tag vocabulary, or more than 2 tags
  OVER_BUDGET   plain modifiers above named_W_max x named_W_tolerance (Formulas I)
  EFFECT        an Effect name that is not in effects.md and is not marked new, or a new Effect missing a field
  UNIQUE_CRAFT  a unique template (rarity >= unique_rarity_min) that lists crafting as a source (rule 20d)
  UNMARKED      an item that breaks the rule 21 blueprint with no `exception` reason
  ART           an item art the art lint rejects (tools/design/arts/lint_arts.py, through the combat engine)
  WARD          a ward record missing a field or naming no starter ward to inherit its price check from
  RESERVE       a reserve art without a reserved share in 0.05-0.90 (Combat Defence & Healing Formulas C), or whose
                granted modifiers cost more than reserve_w_rate x 100 x its share (Formulas I)
  GROUP         a common art that names a công pháp suite (only named items' arts may, rule 20a)
  DUPLICATE     two items, or two arts, with the same id
Notes (not findings): W used per item, a spend under the authoring target (80 %, or 60 % with an enabler),
exceptions with their reasons, new Effects, gated art payoffs, coverage.
It ends with `checked N items, F findings` so a run that read nothing cannot look clean.

Run: python -I tools/design/items/lint_items.py [catalogue files...]   (default: design/items/catalogue-*.json)
"""
import glob
import importlib.util
import json
import os
import re
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
ITEMS = os.path.join(ROOT, "design", "items")


def _load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


tech = _load("lint_techniques", os.path.join(ROOT, "tools", "design", "arts", "lint_techniques.py"))
arts_lint = _load("lint_arts", os.path.join(ROOT, "tools", "design", "arts", "lint_arts.py"))
cat = _load("gdd_catalogue", os.path.join(ROOT, "tools", "design", "items", "gdd_catalogue.py"))   # GDD parser (2026-11-26)

# item stats the technique lint does not price (modifiers.md Stat List W, per displayed unit)
ITEM_PRICE = {"artifact_attack_pct": 0.6, "artifact_defense_pct": 0.6, "than_thuc_cost_pct": 0.8,
              "cultivation_speed_pct": 2.2, "dan_doc_resist_pct": 1.6, "tam_ma_resist_pct": 1.5, "khi_van": 5.0,
              "element_affinity_pct": 1.3, "artifact_power_pct": 1.3,
              # rare (modifiers.md rule 13, Rare table): one unit each
              "bonus_slots": 20.0, "artifact_slots": 25.0, "bonus_ward_slots": 30.0}
LOWER = set(tech.LOWER) | {"than_thuc_cost_pct"}
# Formulas D: the Thiết Bích affix is a marked change, not in data yet; Formulas I counts it in the pool
PENDING_AFFIXES = [{"id": "thiet_bich", "stat": "resist_pct", "min": 5.0, "max": 15.0, "weight": 10}]
AFFIX_COUNT = {1: 1, 2: 2, 3: 3, 4: 4}
NAMED_W_TOLERANCE = 1.05          # Formulas I (user decision 2026-11-13; was 1.25)
RESERVE_W_RATE = 1.0              # Formulas I, reserve arts: W per percentage point reserved (a guess)
SPEND_TARGET, SPEND_ENABLER = 0.80, 0.60   # Formulas I, authoring target (user decision 2026-11-12)
UNIQUE_RARITY_MIN = 5             # rule 20c
KIND_OFFSET = {"artifact": 1, "treasure": 0}
SOURCES = {"event", "npc", "quest", "craft"}
ROLES = {"weapon", "ward_gear", "body_gear", "utility", "ring", "necklace"}
FAMILIES = {"blade", "body", "earth", "fire", "force-chaos", "ice", "metal", "soul-song-seal", "thunder", "water",
            "wind", "wood", "general"}
FIELDS = {"id", "name", "family", "kind", "base", "grade", "rarity", "modifiers", "effects", "arts", "wards",
          "reserve_arts", "exception", "sources", "lore", "build_use", "notes", "holder",
          "set", "made_by", "made_year", "legendary_key", "where", "unique"}   # world-depth signature items (rule 20f)
# world-depth sect catalogues (catalogue-sect-<key>.json, ADR-0009) are unpriced (user rule: no W price until the game
# is finished): the W sum is still noted, OVER_BUDGET and the spend note are skipped there.
UNPRICED_PREFIX = "catalogue-sect-"
REQUIRED = {"id", "name", "family", "kind", "base", "modifiers", "effects", "sources", "build_use"}
NEW_EFFECT_FIELDS = {"name", "rule", "payload"}
WARD_FIELDS = {"id", "name", "payload", "payment", "activation", "check_from"}
BASE_FIELDS = {"id", "name", "english", "roles", "attack", "defense", "base_value", "weight",
               "damage_type", "status", "common_art", "common_ward", "notes", "tags"}


def price_of(key, stats_w):
    if key in tech.PRICE:
        return tech.PRICE[key]
    if key in ITEM_PRICE:
        return ITEM_PRICE[key]
    return stats_w.get(key)


def w_affix(stats_w):
    data = json.load(open(os.path.join(ROOT, "assets", "data", "items_artifacts.json"), encoding="utf-8"))
    pool = list(data["affixes"])
    have = {a["id"] for a in pool}
    pool += [a for a in PENDING_AFFIXES if a["id"] not in have]
    num = den = 0.0
    for a in pool:
        p = price_of(a["stat"], stats_w) or 0.0
        num += a["weight"] * abs((a["min"] + a["max"]) / 2) * p
        den += a["weight"]
    return num / den


def modifiers_w(mods, stats_w, where, out):
    w, priced = 0.0, True
    for i, m in enumerate(mods):
        key, val, scope = m.get("key"), m.get("value"), list(m.get("scope", []))
        if not isinstance(val, (int, float)):
            out.append("SCHEMA\t%s\tmodifiers[%d] value %r is not a number" % (where, i, val))
            priced = False
            continue
        bad = [s for s in scope if s not in tech.TIER]
        if bad or len(scope) > 2:
            out.append("SCOPE\t%s\tmodifiers[%d] %s scope %r: tags outside the Modifier vocabulary or more than 2"
                       % (where, i, key, scope))
            priced = False
            continue
        if key in tech.MORE_KEYS:
            out.append("NOT_PRICED\t%s\tmodifiers[%d] %r: `more` points are Effect payloads only on items"
                       % (where, i, key))
            priced = False
            continue
        p = price_of(key, stats_w)
        if p is None:
            out.append("NOT_PRICED\t%s\tmodifiers[%d] %r has no W price (modifiers.md Formulas A)" % (where, i, key))
            priced = False
            continue
        tags = scope + ([tech.IMPLIED[key]] if key in tech.IMPLIED and tech.IMPLIED[key] not in scope else [])
        good = val * (-1 if key in LOWER else 1) > 0
        w += abs(val) * p / tech.breadth(tags) * (1 if good else -1)
    return w, priced


def blueprint(item, base, arts, wards, reserves, effects):
    """What rule 21 expects of this item's first role; returns a list of what differs (empty when it fits)."""
    role = base["roles"][0]
    attack = [a for a in arts if a.get("role") not in ("ward",)]
    diff = []
    if role == "weapon":
        if len(attack) != 1:
            diff.append("a weapon gives one attack art, it has %d" % len(attack))
        if wards:
            diff.append("a weapon carries a ward")
    elif role in ("body_gear", "ward_gear"):
        if len(wards) != 1:
            diff.append("%s gives one ward art, it has %d" % (role, len(wards)))
        if attack:
            diff.append("%s carries an attack art" % role)
    else:
        if attack or wards:
            diff.append("a %s gives an Effect or modifiers and optionally a reserve art, not attack arts or wards" % role)
        if len(reserves) > 1:
            diff.append("more than one reserve art")
        if not effects and not item.get("modifiers"):
            diff.append("a %s with neither an Effect nor modifiers" % role)
    return diff


def load_bases(out):
    path = os.path.join(ITEMS, "bases.json")
    try:
        bases = json.load(open(path, encoding="utf-8"))
    except (OSError, ValueError) as e:
        print("UNREADABLE\t%s\t%s" % (path, e))
        sys.exit(2)
    by = {}
    for b in bases:
        bid = b.get("id", "?")
        if bid in by:
            out.append("DUPLICATE\tbases.json\tbase %s" % bid)
        by[bid] = b
        extra = set(b) - BASE_FIELDS
        if extra:
            out.append("BASE\tbases.json\t%s: unknown field(s) %s" % (bid, ", ".join(sorted(extra))))
        roles = b.get("roles") or []
        if not roles or any(r not in ROLES for r in roles):
            out.append("BASE\tbases.json\t%s: roles %r" % (bid, roles))
            continue
        first = roles[0]
        if first == "weapon" and not b.get("common_art"):
            out.append("BASE\tbases.json\t%s: a weapon base names no common attack art (rule 21)" % bid)
        if first in ("body_gear", "ward_gear") and not b.get("common_ward"):
            out.append("BASE\tbases.json\t%s: a %s base names no common ward (rule 21)" % (bid, first))
        if first in ("ring", "necklace", "utility") and (b.get("common_art") or b.get("common_ward")):
            out.append("BASE\tbases.json\t%s: a rolled %s gives modifiers only (rule 21)" % (bid, first))
    return by


def main():
    findings, notes = [], []
    bases = load_bases(findings)
    common = os.path.join(ITEMS, "common-arts.json")
    common_arts = json.load(open(common, encoding="utf-8")) if os.path.exists(common) else []
    findings += ["ART\tcommon-arts.json\t" + f.split("\t", 1)[1] for f in arts_lint.lint(common_arts, "common-arts.json")]
    common_ids = {a["id"] for a in common_arts}
    for a in common_arts:
        if a.get("group"):
            findings.append("GROUP\tcommon-arts.json\t%s names suite %r; only named items' arts may (rule 20a)"
                            % (a["id"], a["group"]))
    for b in bases.values():
        if b.get("common_art") and b["common_art"] not in common_ids:
            findings.append("BASE\tbases.json\t%s: common art %r is not in common-arts.json" % (b["id"], b["common_art"]))
    gd = cat.build()
    stats_w = {s["key"]: s["w"] for s in gd["stats"] if s.get("w") is not None}
    eff_names = {re.sub(r"\s*\(.*$", "", e["name"]).strip().lower(): e for e in gd["effects"]}
    # an Effect with an engine record in combat_effects.json counts as known (world-depth Effects live there, ADR-0009)
    for k in json.load(open(os.path.join(ROOT, "assets", "data", "combat_effects.json"), encoding="utf-8"))["effects"]:
        eff_names.setdefault(k.strip().lower(), {"group": ""})
    stage = os.environ.get("DEPTH_STAGE", "")   # world-depth Stage 6: the job's own staged Effects count as known
    for f in (glob.glob(os.path.join(stage, "effects", "*.effects.json")) if stage else []):
        for k in json.load(open(f, encoding="utf-8"))["effects"]:
            eff_names.setdefault(k.strip().lower(), {"group": ""})
    starter_wards = set()
    try:
        cd = open(os.path.join(ROOT, "design", "gdd", "combat-defence.md"), encoding="utf-8").read()
        for m in re.finditer(r"^\| ([A-Z][^|(]+?) \([^)]*\) \|", cd.split("### H. Starter ward catalogue", 1)[1].split("**Body pieces.**")[0], re.M):
            starter_wards.add(m.group(1).strip().lower())
    except (OSError, IndexError):
        pass
    wa = w_affix(stats_w)
    notes.append("budget\tw_affix\t%.2f W per affix (Formulas I); limits by grade %s" %
                 (wa, ", ".join("%d: %.1f W" % (g, AFFIX_COUNT[g] * wa * NAMED_W_TOLERANCE) for g in AFFIX_COUNT)))

    files = sys.argv[1:] or sorted(glob.glob(os.path.join(ITEMS, "catalogue-*.json")))
    if not files:
        print("NO_INPUT\tno catalogue files found (design/items/catalogue-*.json)")
        return 2
    allitems, allarts = [], []
    for f in files:
        try:
            items = json.load(open(f, encoding="utf-8"))
        except (OSError, ValueError) as e:
            print("UNREADABLE\t%s\t%s" % (f, e))
            return 2
        fname = os.path.basename(f)
        unpriced = fname.startswith(UNPRICED_PREFIX)
        for it in items:
            iid = it.get("id", "?")
            where = "%s\t%s" % (fname, iid)
            miss = REQUIRED - set(it)
            if miss:
                findings.append("SCHEMA\t%s\tmissing %s" % (where, ", ".join(sorted(miss))))
                continue
            extra = set(it) - FIELDS
            if extra:
                findings.append("SCHEMA\t%s\tunknown field(s) %s" % (where, ", ".join(sorted(extra))))
            if it["family"] not in FAMILIES:
                findings.append("SCHEMA\t%s\tfamily %r" % (where, it["family"]))
            base = bases.get(it["base"])
            if not base:
                findings.append("BASE\t%s\tbase %r is not in bases.json" % (where, it["base"]))
                continue
            kind = it["kind"]
            if kind == "artifact":
                g = it.get("grade")
                if g not in AFFIX_COUNT:
                    findings.append("SCHEMA\t%s\tgrade %r: a named artifact has grade 1-4 (rule 20a)" % (where, g))
                    continue
                rarity = g + KIND_OFFSET["artifact"]
            elif kind == "treasure":
                rarity = it.get("rarity")
                if rarity not in (4, 5):
                    findings.append("SCHEMA\t%s\trarity %r: a named treasure is rarity 4-5" % (where, rarity))
                    continue
                g = rarity - 1
            else:
                findings.append("SCHEMA\t%s\tkind %r is not artifact or treasure" % (where, kind))
                continue
            unique = rarity >= UNIQUE_RARITY_MIN or bool(it.get("unique"))   # signature items: always (rule 20f)
            src = set(it["sources"])
            if not src or src - SOURCES:
                findings.append("SCHEMA\t%s\tsources %r: some of %s" % (where, sorted(src), ", ".join(sorted(SOURCES))))
            if unique and "craft" in src:
                findings.append("UNIQUE_CRAFT\t%s\ta unique item (rarity %d) is never crafted (rule 20d)" % (where, rarity))
            if unique and "npc" in src and not it.get("holder"):
                notes.append("note\t%s\tunique with an NPC source but no `holder` sketch" % where)
            # budget
            w, priced = modifiers_w(it["modifiers"], stats_w, where, findings)
            limit = AFFIX_COUNT[g] * wa
            if priced and not unpriced and w > limit * NAMED_W_TOLERANCE + 0.05:
                findings.append("OVER_BUDGET\t%s\tmodifiers %.1f W, grade %d budget %.1f W (x%.2f = %.1f)"
                                % (where, w, g, limit, NAMED_W_TOLERANCE, limit * NAMED_W_TOLERANCE))
            notes.append("w\t%s\t%s W of %.1f (grade %d, rarity %d%s%s)" % (
                where, ("%.1f" % w) if priced else "NOT ASSESSED", limit, g, rarity, ", unique" if unique else "",
                ", unpriced, world-depth" if unpriced else ""))
            has_enabler = any((isinstance(e, dict) and e.get("tier") in ("enabler", "keystone")) or
                              (isinstance(e, str) and eff_names.get(e.strip().lower(), {}).get("group") in ("Enablers", "Keystones"))
                              for e in it["effects"])
            floor = SPEND_ENABLER if has_enabler else SPEND_TARGET
            if priced and not unpriced and w < floor * limit - 0.05:
                notes.append("spend\t%s\t%.0f %% of the budget, under the %.0f %% target%s"
                             % (where, 100 * w / limit, 100 * floor, " for an enabler item" if has_enabler else ""))
            # effects
            effs = it["effects"]
            for e in effs:
                if isinstance(e, str):
                    if e.strip().lower() not in eff_names:
                        findings.append("EFFECT\t%s\t%r is not in effects.md; mark it {\"new\": true, ...}" % (where, e))
                elif isinstance(e, dict) and e.get("new"):
                    m = NEW_EFFECT_FIELDS - set(e)
                    if m:
                        findings.append("EFFECT\t%s\tnew Effect %r lacks %s" % (where, e.get("name"), ", ".join(sorted(m))))
                    notes.append("new_effect\t%s\t%s" % (where, e.get("name")))
                else:
                    findings.append("EFFECT\t%s\t%r: a name from effects.md or a {\"new\": true} record" % (where, e))
            # arts, wards, reserve arts
            arts = it.get("arts", [])
            for a in arts:
                allarts.append(a)
            for f2 in arts_lint.lint(arts, fname):
                findings.append("ART\t%s\t%s" % (where, f2.split("\t", 2)[-1]))
            wards = it.get("wards", [])
            for wd in wards:
                m = WARD_FIELDS - set(wd)
                if m:
                    findings.append("WARD\t%s\tward %r lacks %s" % (where, wd.get("name"), ", ".join(sorted(m))))
                elif starter_wards and re.sub(r"\s*\(.*$", "", wd["check_from"]).strip().lower() not in starter_wards:
                    findings.append("WARD\t%s\tward %r inherits its check from %r, not a starter ward"
                                    % (where, wd["name"], wd["check_from"]))
            reserves = it.get("reserve_arts", [])
            for r in reserves:
                share = r.get("reserve")
                if not isinstance(share, (int, float)) or not 0.05 <= share <= 0.90:
                    findings.append("RESERVE\t%s\treserve art %r: reserve %r outside 0.05-0.90" % (where, r.get("name"), share))
                    continue
                rw, rpriced = modifiers_w(r.get("grants", []), stats_w, where, findings)
                rmax = RESERVE_W_RATE * 100 * share
                if rpriced and rw > rmax + 0.05:
                    findings.append("RESERVE\t%s\treserve art %r grants %.1f W, its %.0f %% reservation buys %.1f W"
                                    % (where, r.get("name"), rw, 100 * share, rmax))
                notes.append("reserve\t%s\t%s: %.1f W of %.1f (%.0f %% reserved)" % (where, r.get("name"), rw, rmax, 100 * share))
            diff = blueprint(it, base, arts, wards, reserves, effs)
            if diff and not it.get("exception"):
                findings.append("UNMARKED\t%s\tbreaks the rule 21 blueprint (%s) with no `exception` reason"
                                % (where, "; ".join(diff)))
            elif it.get("exception"):
                notes.append("exception\t%s\t%s%s" % (where, it["exception"], "" if diff else " (fits the blueprint anyway)"))
            allitems.append(dict(it, _rarity=rarity, _unique=unique, _role=base["roles"][0]))
    ids = {}
    for it in allitems:
        ids[it["id"]] = ids.get(it["id"], 0) + 1
    findings += ["DUPLICATE\t(all)\titem %s in %d entries" % (k, v) for k, v in ids.items() if v > 1]
    aids = {}
    for a in allarts + common_arts:
        aids[a.get("id")] = aids.get(a.get("id"), 0) + 1
    findings += ["DUPLICATE\t(all)\tart %s in %d entries" % (k, v) for k, v in aids.items() if v > 1]
    notes += [n for n in arts_lint.notes_out if n.startswith("engine_payoff")]   # gated payoffs, reported, never capped
    for line in findings + notes:
        print(line)
    by = {}
    for it in allitems:
        k = "%s rarity %d" % (it["family"], it["_rarity"])
        by[k] = by.get(k, 0) + 1
    print("coverage\tfamily/rarity\t" + ", ".join("%s: %d" % kv for kv in sorted(by.items())))
    roles = {}
    for it in allitems:
        roles[it["_role"]] = roles.get(it["_role"], 0) + 1
    print("coverage\trole\t" + ", ".join("%s %d" % kv for kv in sorted(roles.items())))
    print("coverage\tunique\t%d of %d" % (sum(1 for it in allitems if it["_unique"]), len(allitems)))
    print("checked %d items, %d bases, %d common arts, %d findings" % (len(allitems), len(bases), len(common_arts), len(findings)))
    return 1 if findings else 0


if __name__ == "__main__":
    sys.exit(main())
