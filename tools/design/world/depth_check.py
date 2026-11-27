"""Checker for the world-depth pass (design/world/depth/schema.md). Observations, not verdicts.

Reads every design/world/depth/sects/*.cast.json, people/*.cast.json, *.techniques.json and *.items.json and prints
findings: schema, unique keys and names, ages against realm, masters (older, higher realm), ties that resolve, roots
against admission (rules-proposals R2, from each sect's lineage elements), variant requirements, trait / technique /
art / item / base / modifier ids, gear counts, backstory lengths by tier, and realm counts against quotas.json.
Also counts (observation only) people outside the NPC Traits total trait bands.

Run: python -I tools/design/world/depth_check.py [--quiet]   (exit 0 always; counts at the end)
"""
import collections
import glob
import json
import pathlib
import re
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import depth_tree  # noqa: E402

ROOT = pathlib.Path(__file__).resolve().parents[3]
D = ROOT / "design/world/depth"
START = 1200
REALMS = ["luyen_khi", "truc_co", "ket_dan", "nguyen_anh", "hoa_than"]
AGE_MIN = [16, 30, 80, 200, 500]
LIFE = [120, 200, 500, 1000, 2000]
RANKS = {"tong_chu", "truong_lao", "noi_mon", "ngoai_mon", "founder", "last_head", "retired_head", "war_marshal",
         "former_officer", "thai_thuong", "chan_truyen", "khach_khanh", "chap_su", "tap_dich", ""}
EXEMPT_RANKS = {"khach_khanh", "tap_dich"}
ARCH = {"kiem_tu", "dan_su", "the_tu", "tran_su", "linh_thuc_su", "phap_tu", "tan_tu"}
BASE_EL = {"kim", "moc", "thuy", "hoa", "tho"}
VAR_REQ = {"phong": [], "loi": ["hoa", "kim"], "am": ["tho", "thuy"], "quang": ["hoa"], "bang": ["thuy"],
           "hon_don": ["moc", "hoa", "tho", "kim", "thuy"]}
TIE_KINDS = {"master", "disciple", "parent", "child", "spouse", "dao_partner", "sibling", "sworn_sibling", "friend",
             "rival", "enemy", "debt", "creditor", "lover", "former_master", "feud", "former_disciple",
             "grandparent", "grandchild", "cousin", "ancestor", "descendant", "aunt_uncle", "niece_nephew", "in_law"}
WORDS = {"A": (100, 320), "B": (35, 140), "C": (5, 70)}
# NPC Traits rule 2a total bands (amended 2026-11-25, ruling group 12: tier A 6-12); the export trims over-band people,
# so this is an observation count, never a finding
BANDS = {"A": (6, 12), "B": (5, 8), "C": (4, 6)}
ADMIT_MIN, ADMIT_CORE = 30, 45
CORE_RANKS = {"noi_mon", "chan_truyen", "truong_lao", "thai_thuong", "tong_chu", "chap_su"}


def load(p):
    return json.loads(pathlib.Path(p).read_text(encoding="utf-8"))


def main():
    quiet = "--quiet" in sys.argv
    find = collections.Counter()
    lines = []

    def f(kind, msg):
        find[kind] += 1
        lines.append("%-12s %s" % (kind, msg))

    hist = load(ROOT / "assets/data/world_history.json")
    # the old cast to compare with: an exported owner's people now come from the depth files themselves (ADR-0009,
    # Stage 7), so they are left out of the comparison
    exported = set(hist.get("depth_sects", []))
    old = {p["key"]: p for p in hist["people"] if p.get("sect") not in exported and not p.get("tier")}
    t1 = load(ROOT / "assets/data/traits.json")
    v1 = {k: {x["name"] for x in t1[k]} for k in ["personality", "callings", "fate", "gained"]}
    pers_set = {x["name"]: x.get("set") for x in t1["personality"]}  # same set = opposites (traits.json)
    t2 = load(D / "traits-v2.json")
    v2 = {k: {x["id"] for x in t2[k]} for k in t2["kinds"]}
    techs = set()
    for fn in glob.glob(str(ROOT / "design/techniques/catalogue-*.json")):
        techs |= {x["id"] for x in load(fn)}
    # the game's own technique catalogue (generated commons and named game techniques) counts too
    techs |= set(re.findall(r'"id":\s*"([a-z0-9_\-]+)"', (ROOT / "assets/data/items_cong_phap.json").read_text(encoding="utf-8")))
    arts = set()
    for fn in glob.glob(str(ROOT / "design/arts/family-*.json")):
        arts |= {x["id"] for x in load(fn)}
    items, mods = set(), set()
    for fn in glob.glob(str(ROOT / "design/items/catalogue-*.json")):
        promoted = pathlib.Path(fn).name.startswith("catalogue-sect-")   # depth items promoted (ADR-0009, Stage 6)
        for i in load(fn):
            if not promoted:
                items.add(i["id"])
            mods |= {m["key"] for m in i.get("modifiers", [])}
    named_game = {i["id"] for i in load(ROOT / "assets/data/items_named.json").get("items", [])} \
        if (ROOT / "assets/data/items_named.json").exists() else set()
    items |= named_game
    bases = {b["id"] for b in load(ROOT / "design/items/bases.json")}
    place_recs = {p["id"]: p for p in load(ROOT / "assets/data/world_continent.json")["places"]}
    places = set(place_recs)
    r1 = collections.Counter()
    trees = 0

    lineage = {}
    for fn in sorted(glob.glob(str(D / "sects/*.techniques.json"))) + sorted(glob.glob(str(D / "people/*.techniques.json"))):
        t = load(fn)
        if t.get("sect"):
            lineage[t["sect"]] = t.get("lineage", {})
        for x in t.get("techniques", []):
            techs.add(x["id"])
            for a in x.get("arts", []):
                if isinstance(a, str) and a not in arts:
                    f("art", "%s: technique %s names unknown art %s" % (t.get("sect") or pathlib.Path(fn).name, x["id"], a))
    for s, lin in lineage.items():
        for k in ["main", "outer"]:
            if lin.get(k) and lin[k] not in techs:
                f("lineage", "%s: lineage %s %s is not a technique" % (s, k, lin[k]))
    holders = {}
    for fn in sorted(glob.glob(str(D / "sects/*.items.json"))) + sorted(glob.glob(str(D / "people/*.items.json"))):
        t = load(fn)
        for i in t.get("items", []):
            if i["id"] in items:
                f("item", "duplicate item id %s" % i["id"])
            items.add(i["id"])
            if i.get("base") and i["base"] not in bases:
                f("item", "%s: unknown base %s" % (i["id"], i["base"]))
            for m in i.get("modifiers", []):
                if m.get("key") not in mods:
                    f("item", "%s: modifier key %s not used in design/items" % (i["id"], m.get("key")))
            if i.get("holder"):
                holders[i["id"]] = i["holder"]
        for st in t.get("sets", []):
            for pc in st.get("pieces", []):
                if pc not in items:
                    f("set", "%s: piece %s missing" % (st.get("id"), pc))

    people, src = {}, {}
    for fn in sorted(glob.glob(str(D / "sects/*.cast.json"))) + sorted(glob.glob(str(D / "people/*.cast.json"))):
        for p in load(fn).get("people", []):
            k = p.get("key", "")
            if k in people:
                f("dup-key", "%s in %s and %s" % (k, src[k], pathlib.Path(fn).name))
            people[k] = p
            src[k] = pathlib.Path(fn).name
    allk = set(people) | set(old)
    names = collections.defaultdict(list)
    for k, p in people.items():
        names[p.get("name_hv", "")].append(k)
    for k, p in old.items():
        if k not in people:
            names[p.get("name", "")].append(k)
    for n, ks in names.items():
        if len(ks) > 1:
            f("dup-name", "%s: %s" % (n, ", ".join(ks)))

    count = collections.defaultdict(collections.Counter)
    tiers = collections.Counter()
    band, band_max = collections.Counter(), collections.Counter()
    for k, p in people.items():
        where = "%s (%s)" % (k, src[k])
        alive = bool(p.get("alive", True))
        tier = p.get("tier", "")
        tiers[tier] += 1
        if tier not in WORDS:
            f("schema", "%s: tier %r" % (where, tier))
        if not re.fullmatch(r"[a-z0-9_]+", k):
            f("schema", "%s: key not snake_case" % where)
        if p.get("rank", "") not in RANKS:
            f("schema", "%s: rank %r" % (where, p.get("rank")))
        if k in old:
            o = old[k]
            for a, b in [("born", "born"), ("sect", "sect"), ("rank", "rank")]:
                if str(o.get(b, "")) != str(p.get(a, "")) and "changed" not in p:
                    f("existing", "%s: %s %r -> %r without a 'changed' note" % (where, a, o.get(b), p.get(a)))
        realm = p.get("realm") if alive else p.get("peak_realm", p.get("realm"))
        if realm not in REALMS:
            f("schema", "%s: realm %r" % (where, realm))
            continue
        ri = REALMS.index(realm)
        if alive:
            count[p.get("sect", "")][realm] += 1
            age = START - int(p.get("born", START))
            if age < AGE_MIN[ri] or age >= LIFE[ri]:
                f("age", "%s: age %d at %s (min %d, life %d)" % (where, age, realm, AGE_MIN[ri], LIFE[ri]))
        for fld in ["home", "birthplace"]:
            v = p.get(fld)
            if alive and v is not None and v not in places:
                f("place", "%s: %s %r not a place id" % (where, fld, v))
        words = len(str(p.get("backstory", "")).split())
        lo, hi = WORDS.get(tier, (0, 9999))
        if words < lo or words > hi:
            f("backstory", "%s: tier %s backstory %d words (%d-%d)" % (where, tier, words, lo, hi))
        if tier in ("A", "B") and alive:
            bs = str(p.get("backstory", ""))
            if not any(x in bs for x in allk - {k}) and not re.search(r"\b[CAVN]\d{3}\b|N-[a-z_]+-\d+", bs):
                f("connect", "%s: backstory names no other person key or event id" % where)
        tr = p.get("traits", {})
        n_tr = sum(len(v) if isinstance(v, list) else (1 if v else 0) for v in tr.values())
        lo_b, hi_b = BANDS.get(tier, (0, 99))
        band["over_" + tier if n_tr > hi_b else "under_" + tier if n_tr < lo_b else "in"] += 1
        band_max[tier] = max(band_max[tier], n_tr)
        if tier == "A" and not tr.get("talent"):
            band["A_no_talent"] += 1
        if len(tr.get("personality", [])) != 3:
            f("trait", "%s: %d personality traits" % (where, len(tr.get("personality", []))))
        sets = [pers_set.get(x) for x in tr.get("personality", []) if x in pers_set]
        if len(set(sets)) < len(sets):
            f("trait", "%s: opposite personality traits %s" % (where, tr.get("personality")))
        for x in tr.get("personality", []):
            if x not in v1["personality"]:
                f("trait", "%s: personality %s unknown" % (where, x))
        if tr.get("calling") and tr["calling"] not in v1["callings"]:
            f("trait", "%s: calling %s unknown" % (where, tr["calling"]))
        for kind, pool in [("fate_given", v1["fate"]), ("gained", v1["gained"])]:
            for x in tr.get(kind, []) or []:
                if x not in pool:
                    f("trait", "%s: %s %s unknown" % (where, kind, x))
        if not tr.get("upbringing"):
            f("trait", "%s: no upbringing" % where)
        for kind in ["upbringing", "lifestyle", "health", "coping"]:
            x = tr.get(kind)
            if x and x not in v2[kind]:
                f("trait", "%s: %s %s unknown" % (where, kind, x))
        if len(tr.get("path", []) or []) > 2:
            f("trait", "%s: %d path traits (at most 2, NPC Traits rule)" % (where, len(tr.get("path", []))))
        for x in tr.get("path", []) or []:
            if x not in v2["path"]:
                f("trait", "%s: path %s unknown" % (where, x))
        for x in tr.get("talent", []) or []:
            if x.get("id") not in v2["talent"] or x.get("tier") not in (1, 2, 3):
                f("trait", "%s: talent %s" % (where, x))
        for t in p.get("ties", []):
            if t.get("to") not in allk:
                f("tie", "%s: tie to unknown %s" % (where, t.get("to")))
            if t.get("kind") not in TIE_KINDS:
                f("tie", "%s: tie kind %s" % (where, t.get("kind")))
        m = p.get("master")
        if m:
            mp = people.get(m) or old.get(m)
            if not mp:
                f("master", "%s: master %s unknown" % (where, m))
            else:
                mr = mp.get("realm") or mp.get("peak_realm")
                if int(mp.get("born", 0)) >= int(p.get("born", 0)):
                    f("master", "%s: master %s not older" % (where, m))
                if alive and mp.get("alive", True) and mr in REALMS and REALMS.index(mr) <= ri:
                    f("master", "%s: master %s not of a higher realm" % (where, m))
        if not alive:
            continue
        root = p.get("root", {})
        el, va = root.get("elements", {}), root.get("variants", {})
        bp = place_recs.get(p.get("birthplace"))
        if bp and el:
            top = max(el, key=el.get)
            share = bp["qi"]["shares"].get(top, 0.0)
            r1["strong" if share >= 30 else "even" if share >= 15 else "against"] += 1
        if not el and not va.get("phong"):
            f("root", "%s: no root" % where)
        for e, v in el.items():
            if e not in BASE_EL or not (1 <= v <= 100):
                f("root", "%s: element %s %s" % (where, e, v))
        for v, pv in va.items():
            if v not in VAR_REQ:
                f("root", "%s: variant %s unknown/archived" % (where, v))
            elif any(r not in el for r in VAR_REQ[v]):
                f("root", "%s: variant %s lacks required %s" % (where, v, VAR_REQ[v]))
        lin = lineage.get(p.get("sect", ""))
        if lin and lin.get("elements") and p.get("rank") not in EXEMPT_RANKS and not p.get("exception"):
            les = lin["elements"]
            base = [e for e in les if e in BASE_EL]
            var = [e for e in les if e in VAR_REQ]
            have = [e for e in base if el.get(e, 0) >= ADMIT_MIN] + [v for v in var if va.get(v, 0) > 0]
            if not have:
                f("admit", "%s: root %s holds none of lineage %s" % (where, el | va, les))
            if p.get("rank") in CORE_RANKS:
                main_el = les[0]
                ok = (el.get(main_el, 0) >= ADMIT_CORE) if main_el in BASE_EL else (va.get(main_el, 0) > 0)
                if var and not any(va.get(v, 0) > 0 for v in var):
                    ok = False
                if not ok:
                    f("admit", "%s: core rank %s lacks main element %s (or the variant)" % (where, p.get("rank"), les))
        b = p.get("build")
        if tier in ("A", "B", "C") and not b:
            f("build", "%s: no build" % where)
            continue
        if b:
            if b.get("archetype") not in ARCH:
                f("build", "%s: archetype %s" % (where, b.get("archetype")))
            mt = (b.get("main") or {}).get("tech")
            if mt not in techs and not re.fullmatch(r"(hoang|huyen|dia|thien)_(kim|moc|thuy|hoa|tho|bang|loi|am|quang|phong|hon_don)", str(mt)):
                f("build", "%s: main technique %s unknown" % (where, mt))
            for a in b.get("aux", []):
                if a.get("tech") not in techs and not re.fullmatch(r"(hoang|huyen|dia|thien)_[a-z_]+", str(a.get("tech"))):
                    f("build", "%s: aux technique %s unknown" % (where, a.get("tech")))
            g = b.get("gear", [])
            want_gear = min(1 + ri, 3)
            # User-approved exception: Trúc Cơ (ri == 1) escapers may carry utility ngoc_boi mf-way-out-knot alongside weapon + robe.
            if ri == 1 and len(g) == 3 and any(x.get("named") == "mf-way-out-knot" for x in g):
                want_gear = 3
            if tier in ("A", "B") and len(g) != want_gear:
                f("build", "%s: %d gear pieces, want %d" % (where, len(g), want_gear))
            for x in g:
                if "named" in x:
                    if x["named"] not in items:
                        f("build", "%s: named gear %s unknown" % (where, x["named"]))
                elif x.get("base") not in bases or not (1 <= int(x.get("grade", 0)) <= 4):
                    f("build", "%s: gear %s" % (where, x))
            st = (b.get("tree") or {}).get("start")
            if st and st not in el and st not in va:
                f("build", "%s: tree start %s not in root" % (where, st))
            rr = depth_tree.route_report(p)
            if rr:
                trees += 1
                for why in rr["bad"]:
                    f("tree", "%s: %s" % (where, why))
                if rr["over"]:
                    f("tree", "%s: targets %s past the %d points (spent %d)" % (where, rr["over"], rr["points"], rr["spent"]))
        for i in p.get("items", []):
            if i not in items:
                f("item", "%s: holds unknown item %s" % (where, i))
            elif holders.get(i) and holders[i] != k:
                f("item", "%s: item %s held by %s" % (where, i, holders[i]))

    qp = D / "quotas.json"
    if qp.exists():
        q = load(qp)
        totals = collections.Counter()
        for s, c in count.items():
            totals.update(c)
        for r, cap in q.get("world_living_max", {}).items():
            old_only = sum(1 for k2, o in old.items() if o.get("alive") and o.get("realm") == r and k2 not in people)
            if totals[r] + old_only > cap:
                f("quota", "world: %s %d authored living (+%d old not deepened) > %d" % (r, totals[r], old_only, cap))
        per = dict(q.get("per_sect_max", {}))
        for s in load(ROOT / "assets/data/world_continent.json")["minor_sects"]:
            caps = dict(q.get("minor_default", {}))
            if s["key"] in q.get("minor_with_nguyen_anh", []):
                caps["nguyen_anh"] = 1
            per.setdefault(s["key"], caps)
        for s, caps in per.items():
            for r, cap in caps.items():
                if count[s][r] > cap:
                    f("quota", "%s: %s %d > %d" % (s, r, count[s][r], cap))
    # World Generation Formula F on the final seats (seats.json, from tools/design/world/depth_seats.py; Wind exempt)
    sp = D / "seats.json"
    if not sp.exists():
        f("seat", "no seats.json: run tools/design/world/depth_seats.py")
    else:
        import depth_seats  # noqa: E402
        fresh = depth_seats.build()
        if fresh != load(sp):
            f("seat", "seats.json is stale against the sect pages: run tools/design/world/depth_seats.py")
        for u in fresh["unread"]:
            f("seat", "%s: the page's seat or leans cannot be read (%s)" % (u["key"], u["why"]))
        for r in fresh["sects"]:
            if not r["fit"]:
                f("seat", "%s: seat %s fails Formula F for leans %s (%s)" % (r["key"], r["seat"], r["leans"], r["notes"]))
    if not quiet:
        print("\n".join(lines))
    tot = collections.Counter()
    for c in count.values():
        tot.update(c)
    print("people %d (alive by realm %s), tiers %s, sects with cast %d, techniques known %d, items known %d" % (
        len(people), dict(tot), dict(tiers), len(count), len(techs), len(items)))
    tot1 = sum(r1.values()) or 1
    print("R1 (observation): living people whose strongest element is >= 30 %% of their birthplace's qi: %d%%, 15-30 %%: %d%%, "
          "< 15 %%: %d%% (of %d with a birthplace)" % (100 * r1["strong"] // tot1, 100 * r1["even"] // tot1,
                                                         100 * r1["against"] // tot1, tot1))
    print("trait bands (observation; A %s, B %s, C %s; the export trims over-band people, NPC Traits rule 2a): "
          "over band %s, under band %s, most traits %s, tier A without a talent %d" % (
              "%d-%d" % BANDS["A"], "%d-%d" % BANDS["B"], "%d-%d" % BANDS["C"],
              {t: band["over_" + t] for t in "ABC"}, {t: band["under_" + t] for t in "ABC"},
              dict(sorted(band_max.items())), band["A_no_talent"]))
    print("builds with Đạo Đồ targets: %d" % trees)
    print("findings: %s" % (dict(find) or "none"))


if __name__ == "__main__":
    main()
